<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String registerType = request.getParameter("registerType");

    //修正と削除の場合のパラメータ
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
    //image足りない
    String image = "";

    //追加の場合は今の時点で画像を登録する


    //削除
    String quantity;
    if(registerType.equals("delete")){
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

        try {

            //オブジェクトの代入
            Class.forName(driver).newInstance();
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            sql = new StringBuffer();
            sql.append("select name, quantity, image from products ");
            sql.append("where deleteFlag = 0 and productID=");
            sql.append(productID);

            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                productName = rs.getString("name");
                quantity = rs.getString("quantity");
                image = rs.getString("string");
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
    }

%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta HTTP-EQUIV="content-type" CONTENT="text/html;charset=UTF-8">
    <link rel="stylesheet" type="text/css" href="css/staff-confirm.css">			
    <title>人事管理</title>
</head>
<body>
    <div id="main_container">
        <h1 class="left-title">人事登録の入力確認</h1>
        <div id="table_container">
            <table id="staff_check">
                <tr>
                    <td>名前</td>
                    <td id="staff_name">伊藤 太郎</td>
                </tr>
                <tr>
                    <td>人事ID</td>
                    <td id="staff_id">123456</td>
                </tr>
                <tr>
                    <td>パスワード</td>
                    <td id="staff_password">A12b34C</td>
                </tr>
                <tr>
                    <td>電話番号</td>
                    <td id="staff_phone">12-4321-2222</td>
                </tr>
                <tr>
                    <td>住所</td>
                    <td id="staff_address">静岡県清水</td>
                </tr>
                <tr>
                    <td>入店日付</td>
                    <td id="staff_comeday">2023/02/11</td>
                </tr>
            </table>
            <div id="button-group">
                <!-- botton押すとidをstaff.htmlに送ってpopup=ture -->
                <!-- <button onclick="window.location.href='staff.jsp?id=' + 123456 + '&staff_change_popup=true'" id="btn">
                    内容を修正する
                </button> -->
                <form action="staff.jsp" method="post">
                    <button class="normal-button">内容を修正する</button>
                </form>
                <form action="staff-register.html" method="post">
                    <button class="normal-button">登録</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
