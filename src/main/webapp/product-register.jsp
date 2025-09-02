<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String registerType = request.getParameter("registerType");

    //修正・削除の場合のパラメータ
    String productID = request.getParameter("productID");

    //追加の場合のパラメータ
    String productName = request.getParameter("name");
    String maker = request.getParameter("maker");
    String flavor = request.getParameter("flavor");
    String type = request.getParameter("type");
    String cost = request.getParameter("cost");
    String price = request.getParameter("price");
    String instockQuantity = request.getParameter("instockQuantity");
    String alertNumber = request.getParameter("alertNumber");
    String autoOrderLimit = request.getParameter("autoOrderLimit");
    String autoOrderQuantity = request.getParameter("autoOrderQuantity");
    String confirmDays = request.getParameter("confirmDays");
    String shippingDays = request.getParameter("shippingDays");
    String imageFileName = request.getParameter("imageFileName");

    //追加の場合は既に画像を登録してある

    //データベースに接続するために使用する変数宣言
    Connection con = null;
    Statement stmt = null;
    StringBuffer sql = null;
    ResultSet rs = null;

    //ローカルのMySqlに接続する設定
    String user = "root";
    String password = "root";
    String url = "jdbc:mysql://localhost/minishopping_site";
    String driver = "com.mysql.jdbc.Driver";

    //確認メッセージ
    StringBuffer ermsg = null;

    try{	//ロードに失敗したときのための例外処理

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();
        sql = new StringBuffer();

        if(registerType.equals("add")) {

            int addedRows = 0;

            //SQLステートメントの作成と発行
            sql.append("insert into products (name, maker, flavor, type, purchaseCost, price, alertNumber, autoOrderLimit, ");
            sql.append(" autoOrderQuantity, confirmDays, shippingDays, image) ");
            sql.append(" values( ");
            sql.append("'" + productName + "', ");
            sql.append(maker + ", ");
            sql.append(flavor + ", ");
            sql.append(type + ", ");
            sql.append(cost + ", ");
            sql.append(price + ", ");
            sql.append(alertNumber + ", ");
            sql.append(autoOrderLimit + ", ");
            sql.append(autoOrderQuantity + ", ");
            sql.append(confirmDays + ", ");
            sql.append(shippingDays + ", ");
            sql.append(imageFileName + ", ");
            sql.append(" ) ");
            //System.out.println(sql.toString());
            addedRows = stmt.executeUpdate(sql.toString());

            //取得したデータを繰り返し処理を表示する
            if (addedRows == 0) {

                ermsg = new StringBuffer();
                ermsg.append("商品の追加が失敗しました。");

            }

        } else if (registerType.equals("delete")) {

            int updatedRows = 0;

            sql.append("update products set deleteFlag = 1 where productID= ");
            sql.append(productID);
            //System.out.println(sql.toString());
            updatedRows = stmt.executeUpdate(sql.toString());

            //取得したデータを繰り返し処理を表示する
            if (updatedRows == 0) {

                ermsg = new StringBuffer();
                ermsg.append("商品の削除が失敗しました。");

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

    <%
        } else {
    %>

        <div id="everything-wrapper">

            <%
                if(registerType.equals("add")){

            %>

                <h1>商品の追加が正常に完了しました。</h1>

            <%
                } else if(registerType.equals("delete")){
            %>

                <h1>商品の削除が正常に完了しました。</h1>

            <%
                }
            %>


            <form action="products.jsp" method="post">
                <button class="normal-button">商品画面へ戻る</button>
            </form>

        </div>

    <%
        }
    %>

</body>
</html>