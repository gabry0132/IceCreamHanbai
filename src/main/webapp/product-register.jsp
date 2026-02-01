<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.io.File" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String staffID = "00";      //仮にシステムの登録だとします
    String staffName = "システム";      //仮にシステムの登録だとします
    boolean isAdmin = true;

    String registerType = request.getParameter("registerType");
    String previousPage = request.getParameter("previousPage");

    //修正・削除の場合のパラメータ
    String productID = request.getParameter("productID");

    //追加の場合のパラメータ
    String productName = request.getParameter("name");                      //detailsUpdateの場合にももらいます。
    String maker = request.getParameter("maker");                           //detailsUpdateの場合にももらいます。
    String flavor = request.getParameter("flavor");                         //detailsUpdateの場合にももらいます。
    String type = request.getParameter("type");                             //detailsUpdateの場合にももらいます。
    String cost = request.getParameter("cost");                             //detailsUpdateの場合にももらいます。
    String price = request.getParameter("price");                           //detailsUpdateの場合にももらいます。
    String instockQuantity = request.getParameter("instockQuantity");
    String alertNumber = request.getParameter("alertNumber");               //alertUpdateの場合にももらいます。
    String autoOrderLimit = request.getParameter("autoOrderLimit");         //alertUpdateの場合にももらいます。
    String autoOrderQuantity = request.getParameter("autoOrderQuantity");   //alertUpdateの場合にももらいます。
    String confirmDays = request.getParameter("confirmDays");
    String shippingDays = request.getParameter("shippingDays");
    String unitPerBox = request.getParameter("unitPerBox");
    String imageFileName = request.getParameter("imageFileName");

    //detailsUpdateの場合。対象の項目だけが送信されます。追加処理と同じ名前を持つ項目も含めて、変更すべきなのは一つ以上必ずある。
    String oldImageFile = request.getParameter("oldImageFile");
    String newImageFile = request.getParameter("newImageFile");

    //削除の際に在庫に残っている状態のみ貰う項目。
    String setQuantityToZero = request.getParameter("setQuantityToZero");

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

    String logtypeIDforProducts = null;

    try{	//ロードに失敗したときのための例外処理

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();
        sql = new StringBuffer();

        //ログのために商品に関わるログタイプIDを取得。
        sql.append("select logtypeID from logtypes where type='商品'");
        rs = stmt.executeQuery(sql.toString());

        if(rs.next()){
            logtypeIDforProducts = rs.getString("logtypeID");
        } else {
            throw new Exception("商品ログタイプIDの取得が失敗しました。");
        }

        sql = new StringBuffer();
        int updatedRows = 0;

        if(registerType.equals("add")) {

            sql.append("insert into products (name, purchaseCost, quantity, price, alertNumber, autoOrderLimit, ");
            sql.append("autoOrderQuantity, unitPerBox, confirmDays, shippingDays, image) ");
            sql.append(" values( ");
            sql.append("'" + productName + "', ");
            sql.append(cost + ", ");
            sql.append(instockQuantity + ", ");
            sql.append(price + ", ");
            sql.append(alertNumber + ", ");
            sql.append(autoOrderLimit + ", ");
            sql.append(autoOrderQuantity + ", ");
            sql.append(unitPerBox + ", ");
            sql.append(confirmDays + ", ");
            sql.append(shippingDays + ", '");
            sql.append(imageFileName + "'");
            sql.append(" ) ");
            //System.out.println(sql.toString());
            updatedRows = stmt.executeUpdate(sql.toString());

            //取得したデータを繰り返し処理を表示する
            if (updatedRows == 0) {
                throw new Exception("商品の追加が失敗しました。");
            }

            //作成された主キーを取得してログを登録します。商品追加の直後にしなければなりません。
            sql = new StringBuffer();
            sql.append("select last_insert_id() as id");
            rs = stmt.executeQuery(sql.toString());

            if (rs.next()) {
                productID = rs.getString("id");
            } else {
                throw new Exception("商品の追加後の処理が失敗しました。");
            }

            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforProducts);
            sql.append(",'");
            sql.append(productName + " が " + staffName + " に追加されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("商品追加のログ登録処理が失敗しました。");
            }

            //最後にタグを登録します。
            updatedRows = 0;
            sql = new StringBuffer();
            sql.append("insert into hastags (productID, tagID) values ");
            sql.append("(" + productID + "," + maker + "),");
            sql.append("(" + productID + "," + flavor + "),");
            sql.append("(" + productID + "," + type + ")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows < 3) {
                throw new Exception("タグ付け処理が失敗しました。");
            }

        } else if (registerType.equals("detailsUpdate")){

            //動的にしてみたら複雑なので一つ一つ自分のクエリにします。
            if(productName != null) {
                sql = new StringBuffer();
                sql.append("update products set name = '" + productName + "' where productID = " + productID);
                updatedRows = stmt.executeUpdate(sql.toString());
                if(updatedRows == 0) throw new Exception("商品名の更新が失敗しました。データベースの管理者を連絡してください。");
            }
            if(cost != null) {
                sql = new StringBuffer();
                sql.append("update products set purchaseCost = " + cost + " where productID = " + productID);
                updatedRows = stmt.executeUpdate(sql.toString());
                if(updatedRows == 0) throw new Exception("商品購入コストの更新が失敗しました。データベースの管理者を連絡してください。");
            }
            if(price != null) {
                sql = new StringBuffer();
                sql.append("update products set price = " + price + " where productID = " + productID);
                updatedRows = stmt.executeUpdate(sql.toString());
                if(updatedRows == 0) throw new Exception("商品値段の更新が失敗しました。データベースの管理者を連絡してください。");
            }
            //タグも修正された場合だけにhatagsIDを取得します。
            if(maker != null || flavor != null || type != null){
                sql = new StringBuffer();
                sql.append("select hastagsID, type from hastags inner join tags on hastags.tagID = tags.tagID inner join tagtypes on tags.tagTypeID = tagtypes.tagTypeID ");
                sql.append("where productID = " + productID + " and hastags.deleteFlag = 0");
                rs = stmt.executeQuery(sql.toString());
                String makerID = "";
                String flavorID = "";
                String typeID = "";
                while(rs.next()){
                    if(rs.getString("type").equals("メーカー")) makerID = rs.getString("hastagsID");
                    else if(rs.getString("type").equals("味")) flavorID = rs.getString("hastagsID");
                    else if(rs.getString("type").equals("種類")) typeID = rs.getString("hastagsID");
                }

                //実際の変更を行います。
                if(maker != null) {
                    sql = new StringBuffer();
                    sql.append("update hastags set tagID = " + maker + " where hastagsID = " + makerID);
                    updatedRows = stmt.executeUpdate(sql.toString());
                    if(updatedRows == 0) throw new Exception("メーカータグの更新が失敗しました。データベースの管理者を連絡してください。");
                }
                if(flavor != null) {
                    sql = new StringBuffer();
                    sql.append("update hastags set tagID = " + flavor + " where hastagsID = " + flavorID);
                    updatedRows = stmt.executeUpdate(sql.toString());
                    if(updatedRows == 0) throw new Exception("メーカータグの更新が失敗しました。データベースの管理者を連絡してください。");
                }
                if(type != null) {
                    sql = new StringBuffer();
                    sql.append("update hastags set tagID = " + type + " where hastagsID = " + typeID);
                    updatedRows = stmt.executeUpdate(sql.toString());
                    if(updatedRows == 0) throw new Exception("メーカータグの更新が失敗しました。データベースの管理者を連絡してください。");
                }
            }

            //画像の変更もあれば古くなった画像の削除に加えて登録します。
            if(oldImageFile != null && newImageFile != null){
                //古い画像の削除
                String relativePath = "\\images";
                String targetUrl = application.getRealPath(relativePath);
                File file = new File(targetUrl + "\\" + oldImageFile);
                if(!file.delete()){
                    System.out.println("Error deleting file");
                }
                //新しい画像に更新
                sql = new StringBuffer();
                sql.append("update products set image = '" + newImageFile + "' where productID = " + productID);
                updatedRows = stmt.executeUpdate(sql.toString());
                if(updatedRows == 0) throw new Exception("画像のの更新が失敗しました。データベースの管理者を連絡してください。");
            }

            //ログのために商品名が必要ですが、登録しない場合は持っていないので取得します。
            if(productName == null){
                sql = new StringBuffer();
                sql.append("select name from products where productID = " + productID);
                rs = stmt.executeQuery(sql.toString());

                if(rs.next()){
                    productName = rs.getString("name");
                } else {
                    productName = "商品ID: " + productID;
                }
            }
            //ログを登録します。
            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforProducts);
            sql.append(",'");
            sql.append(productName + " の詳細データが " + staffName + " に変更されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("商品追加のログ登録処理が失敗しました。");
            }

        } else if (registerType.equals("toggleAutoOrder")){

            sql.append("select stopAutoOrder from products where productID = ");
            sql.append(productID);
            rs = stmt.executeQuery(sql.toString());
            int stopAutoOrder = 0;

            if(rs.next()){
                stopAutoOrder = rs.getInt("stopAutoOrder");
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }

            sql = new StringBuffer();
            sql.append("update products set stopAutoOrder = ");
            if(stopAutoOrder == 0) sql.append("1");
            else sql.append("0");
            sql.append(" where productID =  ");
            sql.append(productID);
            //System.out.println(sql.toString());
            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                ermsg = new StringBuffer();
                ermsg.append("商品の削除が失敗しました。");
            }

            //ログを登録します。
            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforProducts);
            sql.append(",'");
            sql.append(productName + " の自動発注機能が " + staffName + " に");
            if(stopAutoOrder == 0) sql.append("無効化されました");
            else sql.append("有効化されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("商品追加のログ登録処理が失敗しました。");
            }

        } else if (registerType.equals("alertUpdate")) {

            sql.append("update products set alertNumber = ");
            sql.append(alertNumber);
            sql.append(", autoOrderLimit = ");
            sql.append(autoOrderLimit);
            sql.append(", autoOrderQuantity = ");
            sql.append(autoOrderQuantity);
            sql.append(" where productID = ");
            sql.append(productID);
            //System.out.println(sql.toString());
            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("商品のアラート・自動発注設定の更新が失敗しました。");
            }

            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforProducts);
            sql.append(",'");
            sql.append(productName + " のアラート・自動発注設定が " + staffName + " に変更されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("商品追加のログ登録処理が失敗しました。");
            }

        } else if (registerType.equals("delete")) {

            int quantity = 0;

            sql.append("select quantity from products where productID = ");
            sql.append(productID);
            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                quantity = rs.getInt("quantity");
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }

            if(setQuantityToZero != null){
                if(setQuantityToZero.equals("true")){
                    sql = new StringBuffer();
                    sql.append("update products set quantity = 0 where productID = ");
                    sql.append(productID);
                    updatedRows = stmt.executeUpdate(sql.toString());

                    if (updatedRows == 0) {
                        throw new Exception("商品の在庫数初期設定が失敗しました。削除を中止します。");
                    }

                    quantity = 0;

                    sql = new StringBuffer();
                    sql.append("insert into logs (logtypeID, text, productID) value (");
                    sql.append(logtypeIDforProducts);
                    sql.append(",'");
                    sql.append(productName + " の在庫数が削除の際にゼロに設定されました。");
                    sql.append("',");
                    sql.append(productID);
                    sql.append(")");

                    updatedRows = stmt.executeUpdate(sql.toString());
                    if (updatedRows == 0) {
                        throw new Exception("商品追加のログ登録処理が失敗しました。");
                    }
                }
            }

            sql = new StringBuffer();
            sql.append("update products set deleteFlag = 1 where productID = ");
            sql.append(productID);
            //System.out.println(sql.toString());
            updatedRows = stmt.executeUpdate(sql.toString());

            if (updatedRows == 0) {
                throw new Exception("商品の削除が失敗しました。");
            }

            sql = new StringBuffer();
            sql.append("insert into logs (logtypeID, text, productID) value (");
            sql.append(logtypeIDforProducts);
            sql.append(",'");
            if(quantity > 0) sql.append(productName + " が " + quantity + "個 は残った状態で " + staffName + " に削除されました");
            else sql.append(productName + " が " + staffName + " に削除されました");
            sql.append("',");
            sql.append(productID);
            sql.append(")");

            updatedRows = stmt.executeUpdate(sql.toString());
            if (updatedRows == 0) {
                throw new Exception("商品追加のログ登録処理が失敗しました。");
            }

        }

    }catch(ClassNotFoundException e){
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品登録結果確認</title>
    <link rel="stylesheet" href="css/product-register.css">
</head>
<body>

    <%
        if(ermsg != null){
    %>

        <h2>エラーが発生しました。</h2>
        <p><%=ermsg%></p>

        <form action="products.jsp" method="post">
            <button class="normal-button">商品画面へ戻る</button>
        </form>

    <%
        } else {
    %>

        <div id="everything-wrapper">

            <%
                if(registerType.equals("add")){

            %>

                <h1>商品の追加が正常に完了しました。</h1>

            <%
                } else if(registerType.equals("detailsUpdate")){
            %>

                <h1>商品詳細データの更新が正常に完了しました。</h1>

            <%
                } else if(registerType.equals("toggleAutoOrder")){
            %>

                <h1>対象商品の自動発注設定を切り替えました。</h1>

            <%
                } else if(registerType.equals("alertUpdate")){
            %>

                <h1>商品のアラート・自動発注設定の変更が正常に完了しました。</h1>

            <%
                } else if(registerType.equals("delete")){
            %>

                <h1>商品の削除が正常に完了しました。</h1>

            <%
                }
            %>

            <div id="return-forms-holder">

                <% if(previousPage != null){ %>
                    <form action="<%=previousPage%>" method="post">
                        <button class="normal-button">前のページに戻る</button>
                    </form>
                <% } %>

                <form action="products.jsp" method="post">
                    <button class="normal-button">商品画面へ戻る</button>
                </form>

            </div>


        </div>

    <%
        }
    %>

</body>
</html>