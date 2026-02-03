<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.time.LocalDate" %>
<%
    // 文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    //セッション管理
    String staffID = (String) session.getAttribute("staffID");
    if(staffID == null){
        response.sendRedirect("index.jsp");
        return;
    }
    String staffName = (String) session.getAttribute("staffName");
    boolean isAdmin = session.getAttribute("isAdmin") == null ? false : (boolean) session.getAttribute("isAdmin");

    String registerType = request.getParameter("registerType");

    //作成・修正の場合にもらうパラメータ
    String productID = request.getParameter("productID");
    String saleTime = request.getParameter("saleTime");
    String saleQuantitiy = request.getParameter("saleQuantity");

    //修正の場合のパラメータ
    String editStaffID = request.getParameter("editStaffID");
    String saleID = request.getParameter("saleID");                 //削除にも使います

    //削除のパラメータ
    boolean returnQuantity = request.getParameter("returnQuantity") != null;

    //CSVから読み込むためのパラメータ
    Part filePart = null;
    if(registerType.equals("fromCSV")){
        filePart = request.getPart("fileInput");
    }
    String targetDate = request.getParameter("targetDate");
    String adjustedDate = request.getParameter("readFileAdjustDate");
    HashMap<String, String> map = new HashMap<>();
    ArrayList<HashMap<String, String>> salesList = new ArrayList<HashMap<String, String>>();

    //データベースに接続するために使用する変数宣言
    Connection con = null;
    Statement stmt = null;
    StringBuffer sql = null;
    ResultSet rs = null;

    //ローカルのMySqlに接続する設定
    String user = "root";
    String password = "root";
    String url = "jdbc:mysql://localhost/icehanbaikanri";
    String driver = "com.mysql.jdbc.Driver";

    //確認メッセージ
    StringBuffer ermsg = null;
    int updatedRows = 0;
    String logtypeIDforSales = "";          //ログに使います
    String logtypeIDforNotices = "";         //csv読み込みログに使います
    String productName = "";                //ログに使います
    int recordedQuantity = 0;               //商品テーブルから引数するために使います

    try {
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //ログのために商品に関わるログタイプIDを取得。
        sql = new StringBuffer();
        sql.append("select logtypeID, typeEng from logtypes where type='売上' or type='お知らせ'");
        rs = stmt.executeQuery(sql.toString());

        if(rs.next()){
            if(rs.getString("typeEng").equals("sales")) logtypeIDforSales = rs.getString("logtypeID");
            else if(rs.getString("typeEng").equals("notice")) logtypeIDforNotices = rs.getString("logtypeID");
        } else {
            throw new Exception("売上ログタイプIDの取得が失敗しました。");
        }

        if(registerType.equals("create")) {

            //売上IDはセキュリティのため10桁の乱数に設定します。
            //重複させません。
            String generatedID;
            do {
                generatedID = "";
                for (int i = 0; i < 9; i++) {
                    generatedID += (int) (Math.random() * 10);
                }
                sql = new StringBuffer();
                sql.append("select count(salesID) as count from sales ");
                sql.append("where salesID = ");
                sql.append(generatedID);
                rs = stmt.executeQuery(sql.toString());
                rs.next();
            } while (rs.getInt("count") > 0);

            //登録するまえに量数の最終チェックを行います。
            sql = new StringBuffer();
            sql.append("select name, quantity from products where productID = ");
            sql.append(productID);
            rs = stmt.executeQuery(sql.toString());
            if(rs.next()){

                productName = rs.getString("name");
                recordedQuantity = rs.getInt("quantity");

                if(recordedQuantity < Integer.parseInt(saleQuantitiy)){
                    throw new Exception("在庫数エラー、もう一度売上の量数をご確認ください。");
                }
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }

            //実際の登録を行います。
            sql = new StringBuffer();
            sql.append("insert into sales(salesID, productID, staffID, quantity, dateTime) values( ");
            sql.append(generatedID);
            sql.append(",");
            sql.append(productID);
            sql.append(",'");
            sql.append(staffID);
            sql.append("',");
            sql.append(saleQuantitiy);
            sql.append(",'");
            sql.append(saleTime);
            sql.append("')");

            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("売上の作成が失敗しました。");
            }

            //数量の引数を行って商品テーブルに登録します。
            sql = new StringBuffer();
            sql.append("update products set quantity = ");
            sql.append((recordedQuantity - Integer.parseInt(saleQuantitiy)));
            sql.append(" where productID = ");
            sql.append(productID);

            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("売上に登録された量数で在庫数を減らす処理が失敗しました。");
            }

            //ログの登録を行います。
            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforSales);
            sql.append(",'");
            sql.append(productName + " が " + staffName + " により " + saleQuantitiy + "個 の売上が登録されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("売上作成のログ登録処理が失敗しました。");
            }
        } else if(registerType.equals("edit")){

            if(!isAdmin) throw new Exception("管理者権限が必要。");

            //修正の場合は数量のチェックを行いません。このまま数量の差を反映させます。負数になる可能性があります。
            int registeredQuantity = 0;
            int registeredSaleQuantity = 0;
            sql = new StringBuffer();
            sql.append("select name, quantity from products where productID = ");
            sql.append(productID);
            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                productName = rs.getString("name");
                registeredQuantity = rs.getInt("quantity");
            } else {
                throw new Exception("商品ログタイプIDの取得が失敗しました。");
            }

            sql = new StringBuffer();
            sql.append("select quantity from sales where salesID = ");
            sql.append(saleID);
            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                registeredSaleQuantity = rs.getInt("quantity");
            } else {
                throw new Exception("商品ログタイプIDの取得が失敗しました。");
            }

            int newQuantity = registeredQuantity + (registeredSaleQuantity - Integer.parseInt(saleQuantitiy));

            //実際にupdateを行います。
            sql = new StringBuffer();
            sql.append("update sales set productID = ");
            sql.append(productID);
            sql.append(", staffID = '");
            sql.append(editStaffID);
            sql.append("', quantity = ");
            sql.append(saleQuantitiy);
            sql.append(", dateTime = '");
            sql.append(saleTime);
            sql.append("' where salesID = ");
            sql.append(saleID);

            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("売上修正処理が失敗しました。");
            }

            //数量の引数を行って商品テーブルに登録します。
            sql = new StringBuffer();
            sql.append("update products set quantity = ");
            sql.append(newQuantity);
            sql.append(" where productID = ");
            sql.append(productID);

            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("売上修正に登録された量数の差で在庫数を更新する処理が失敗しました。");
            }

            //ログの登録を行います。
            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforSales);
            sql.append(",'");
            sql.append(productName + " の売上ID: " + saleID + " が " + staffName + " により変更されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("売上修正のログ登録処理が失敗しました。");
            }

        } else if(registerType.equals("delete")){

            if(!isAdmin) throw new Exception("管理者権限が必要。");

            int quantityToReturn = 0;
            int currentQuantity = 0;

            //量数を返す必要があれば先に処理します。
            if(returnQuantity){
                sql = new StringBuffer();
                sql.append("select products.quantity as zaiko, products.productID, sales.quantity as saleQuantity from products inner join sales on products.productID = sales.productID where salesID = ");
                sql.append(saleID);
                rs = stmt.executeQuery(sql.toString());

                if(rs.next()){
                    currentQuantity = rs.getInt("zaiko");
                    quantityToReturn = rs.getInt("saleQuantity");
                    productID = rs.getString("productID");
                } else {
                    throw new Exception("対象の商品が見つかりませんでした。");
                }

                sql = new StringBuffer();
                sql.append("update products set quantity = ");
                sql.append(currentQuantity + quantityToReturn);
                sql.append(" where productID = ");
                sql.append(productID);

                updatedRows = stmt.executeUpdate(sql.toString());

                if (updatedRows == 0) {
                    throw new Exception("商品：在庫数の取り戻しに失敗しました。");
                }
            }

            sql = new StringBuffer();
            sql.append("update sales set deleteFlag = 1 where salesID =");
            sql.append(saleID);

            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("売上の削除が失敗しました。");
            }

            //ログの登録を行います。
            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforSales);
            sql.append(",'");
            sql.append(productName + " の売上ID: " + saleID + " が " + staffName + " により削除され");
            if(returnQuantity) sql.append("、" + quantityToReturn + "個　が戻されました。");
            else sql.append("ました。");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("売上削除のログ登録処理が失敗しました。");
            }

        } else if(registerType.equals("fromCSV")){

            boolean acceptAll = false;

            //対象の日付を取得します。
            if(targetDate.equals("today")){
                targetDate = LocalDate.now().toString();
            } else if (targetDate.equals("yesterday")) {
                targetDate = LocalDate.now().minusDays(1).toString();
            } else if (targetDate.equals("adjust")){
                if (adjustedDate != null) targetDate = adjustedDate;
            } else {
                acceptAll = true;
            }
            //昨日

            if(filePart != null && filePart.getSize() > 0){
                InputStream inputStream = filePart.getInputStream();
                BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));

                //データを保存します。
                String line;
                while((line = reader.readLine()) != null){
                    map = new HashMap<>();
                    String date = line.split(",")[0].split(" ")[0];
                    if(date.equals(targetDate) || acceptAll){
                        map.put("dateTime", line.split(",")[0]);
                        map.put("productID", line.split(",")[1]);
                        map.put("staffID", line.split(",")[2]);
                        map.put("quantity", line.split(",")[3]);
                        map.put("deleteFlag", line.split(",")[4]);
                        salesList.add(map);
                    }
                }

                if(salesList.isEmpty()) throw new Exception("CSVファイルからデータの読み込みが失敗しました。");

                //売上ごとのIDを作成しいます。
                for (int i = 0; i < salesList.size(); i++) {
                    //売上IDはセキュリティのため10桁の乱数に設定します。
                    //重複させません。
                    String generatedID;
                    do {
                        generatedID = "";
                        for (int j = 0; j < 9; j++) {
                            generatedID += (int) (Math.random() * 10);
                        }
                        sql = new StringBuffer();
                        sql.append("select count(salesID) as count from sales ");
                        sql.append("where salesID = ");
                        sql.append(generatedID);
                        rs = stmt.executeQuery(sql.toString());
                        rs.next();
                    } while (rs.getInt("count") > 0);
                    salesList.get(i).put("saleID", generatedID);
                }

                //実際の登録を行います。
                sql = new StringBuffer();
                sql.append("insert into sales(salesID, productID, staffID, quantity, dateTime, deleteFlag) values ");
                for (int i = 0; i < salesList.size(); i++) {
                    if(i != 0) sql.append(",");
                    sql.append("(");
                    sql.append(salesList.get(i).get("saleID"));
                    sql.append(",");
                    sql.append(salesList.get(i).get("productID"));
                    sql.append(",'");
                    sql.append(salesList.get(i).get("staffID"));
                    sql.append("',");
                    sql.append(salesList.get(i).get("quantity"));
                    sql.append(",'");
                    sql.append(salesList.get(i).get("dateTime"));
                    sql.append("',");
                    sql.append(salesList.get(i).get("deleteFlag"));
                    sql.append(")");
                }

                updatedRows = stmt.executeUpdate(sql.toString());

                if (updatedRows == 0) {
                    throw new Exception("ファイルからの売上登録が失敗しました。");
                }

                //ログの登録を行います。
                sql = new StringBuffer();
                sql.append("insert into logs (logtypeID, text) value (");
                sql.append(logtypeIDforNotices);
                sql.append(",'");
                sql.append(staffName + " のcsv読み込みにより " + salesList.size() + "件 売上が登録されました。");
                sql.append("')");

                updatedRows = stmt.executeUpdate(sql.toString());
                if (updatedRows == 0) {
                    throw new Exception("csv読み込み後のログ処理が失敗しました。");
                }

            }

        }

    } catch(ClassNotFoundException e){
        ermsg = new StringBuffer();
        ermsg.append(e.getMessage());
    }catch(SQLException e){
        ermsg = new StringBuffer();
        ermsg.append(e.getMessage());
    }catch(Exception e){
        ermsg = new StringBuffer();
        ermsg.append(e.getMessage());
    }
    finally{
        try{
            if(rs != null){
                rs.close();
            }
            if(stmt != null){
                stmt.close();
            }
            if(con != null){
                con.close();
            }
        }catch(SQLException e){
            ermsg = new StringBuffer();
            ermsg.append(e.getMessage());
        }
    }

%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/sales-order-register.css">
    <title>売上データ登録完了</title>
</head>
<body>
    <%
        if(ermsg != null){
    %>

        <h2>エラーが発生しました。</h2>
        <p><%=ermsg%></p>

    <%
    } else {
    %>
        <% if(registerType.equals("create")){ %>
            <h1>売上データの登録が正常に完了しました。</h1>
        <% } else if (registerType.equals("edit")){ %>
            <h1>売上データの修正が正常に完了しました。</h1>
        <% } else if (registerType.equals("fromCSV")){ %>
            <h1>ファイルからの売上データ登録が正常に完了しました。</h1>
        <% } else if (registerType.equals("delete")){ %>
            <% if(returnQuantity){ %>
                <h3>量数を在庫に戻し、売上データの削除が正常に完了しました。</h3>
            <% } else { %>
                <h1>売上データの削除が正常に完了しました。</h1>
            <% } %>
        <% } %>
    <% } %>

    <form action="sales.jsp" method="post">
        <button class="normal-button">売上データ一覧に戻る</button>
    </form>

</body>
</html>