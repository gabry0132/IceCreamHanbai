<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    //    String staffID = session.getAttribute("staffID");
//    String staffID = session.getAttribute("staffName");
    String staffID = "00";      //仮にシステムの登録だとします
    String staffName = "システム";      //仮にシステムの登録だとします

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
    String logtypeIDforSales = "";       //ログに使います
    String productName = "";                //ログに使います
    int recordedQuantity = 0;               //商品テーブルから引数するために使います

    try {
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //ログのために商品に関わるログタイプIDを取得。
        sql = new StringBuffer();
        sql.append("select logtypeID from logtypes where type='売上'");
        rs = stmt.executeQuery(sql.toString());

        if(rs.next()){
            logtypeIDforSales = rs.getString("logtypeID");
        } else {
            throw new Exception("商品ログタイプIDの取得が失敗しました。");
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
    <link rel="stylesheet" href="css/sales-register.css">
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