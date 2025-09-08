<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.util.Random"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String registerType = request.getParameter("registerType");

    //削除の場合のパラメータ
    String staffID = request.getParameter("staffID");

    //修正の場合のパラメータ
    String changed_staff_name = request.getParameter("name");
    String changed_staff_password = request.getParameter("password");
    String changed_staff_tel = request.getParameter("tel");
    String changed_staff_address = request.getParameter("address");

    //追加の場合のパラメータ、パスワードとIDは↓のランタイム生成する
    String name = request.getParameter("name");
    String tel = request.getParameter("tel");
    String address = request.getParameter("address");
    String workStartDate = request.getParameter("workStartDate");

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

        if(registerType.equals("add")) {
            //追加の時ランタイムIDとpassword機能
            //まずA-Z,a-z,0-9のASCII codeを加減してArray[]のsizeを決める
            int password_totalSize = ('Z' - 'A' + 1) + ('z' - 'a' + 1) + ('9' - '0' + 1);
            int id_totalSize = ('9' - '0' + 1);
            //A-Z,a-z,0-9全部入るArray[]の生成
            char[] PasswordCharArray = new char[password_totalSize];
            char[] IdCharArray = new char[id_totalSize];
            int index = 0;
            int ID_index = 0;
            //追加CharArray[]中にA-Zを入る
            for (char put = 'A'; put <= 'Z'; put++) {
                PasswordCharArray[index++] = put;
            }
            //追加CharArray[]中にa-zを入る
            for (char put = 'a'; put <= 'z'; put++) {
                PasswordCharArray[index++] = put;
            }
            //追加CharArray[]中に0-9を入る
            for (char put = '0'; put <= '9'; put++) {
                PasswordCharArray[index++] = put;
                IdCharArray[ID_index++] = put;
            }
            //それで、PasswordCharArrayはA-Z,a-z,0-9の文字入った
            //IdCharArrayは0-9の文字入った
            //次はパスワードと社員ID(6桁の数字)を生成する と重複排除
            boolean repeated = true;
            while (repeated) {
                password = "";
                for (int i = 0; i < 7; i++) {
                    int randomun = (int) (Math.random() * password_totalSize);
                    password += PasswordCharArray[randomun];
                }
                sql.setLength(0);
                // => sql = new StringBuffer();
                sql.append("select count(password) as same from staff ");
                sql.append("where password = '");
                sql.append(password);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());
                if (rs.next()) {
                    int count = rs.getInt("same");
                    if (count == 0) {
                        repeated = false;
                    }
                }
            }
            //同じのやり方で生成されたIDを重複排除する
            repeated = true;
            while (repeated) {
                staffID = "";
                int randomun = 0;
                randomun = 1 + (int) (Math.random() * (id_totalSize - 1));
                staffID += IdCharArray[randomun];
                for (int i = 0; i < 5; i++) {
                    randomun = (int) (Math.random() * id_totalSize);
                    staffID += IdCharArray[randomun];
                }
                sql.setLength(0);
                sql.append("select count(staffID) as same from staff ");
                sql.append("where staffID = '");
                sql.append(staffID);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());
                if (rs.next()) {
                    int count = rs.getInt("same");
                    if (count == 0) {
                        repeated = false;
                    }
                }
            }
            sql = new StringBuffer();
        } else if (registerType.equals("change")) {


        }

        sql.append("select name, password, tel ,address, workStartDate from staff ");
        sql.append("where deleteFlag = 0 and staffID=");
        sql.append(staffID);

        rs = stmt.executeQuery(sql.toString());

        if(rs.next()){
            name = rs.getString("name");
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
    finally {
        try {
            if (rs != null) {
                rs.close();
            }
            if (stmt != null) {
                stmt.close();
            }
            if (con != null) {
                con.close();
            }
        } catch (SQLException e) {
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
