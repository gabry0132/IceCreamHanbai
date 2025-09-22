<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.util.Random"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.sql.*" %>
<%
    //Button押す→Confirm以上の社員データを追加していいですか？→Register　人事追加は成功しました
    //ここでは追加してもいいですかの処理、社員IDと初期パスポートの生成はこちら
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    String registerType = request.getParameter("registerType");

    //削除の場合のパラメータ
    String staffID = request.getParameter("staffID");
    String delete_staff_name = request.getParameter("check_name");
    String delete_staff_password = request.getParameter("check_password");
    String delete_staff_tel = request.getParameter("check_tel");
    String delete_staff_address = request.getParameter("check_address");
    String delete_staff_workStartDate = request.getParameter("check_workStartDate");
    //修正の場合のパラメータ
    String changed_staff_name = request.getParameter("name_change");
    String changed_staff_password = request.getParameter("password_change");
    String changed_staff_tel = request.getParameter("tel_change");
    String changed_staff_address = request.getParameter("address_change");

    //追加の場合のパラメータ、パスワードとIDは↓のランタイム生成する
    String generatedPassword = "";
    String generatedID = "";
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
    String url = "jdbc:mysql://localhost/icekanrihanbai";
    String driver = "com.mysql.jdbc.Driver";

    //確認メッセージ
    StringBuffer ermsg = null;

    try {

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();
        sql = new StringBuffer();
        //何のButtonを押して、何の処理をするのを確認する
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
            for (int i = 0; i < 7; i++) {
                int randomun = (int) (Math.random() * password_totalSize);
                generatedPassword += PasswordCharArray[randomun];
            }
            while (repeated) {
                sql.setLength(0);
                // => sql = new StringBuffer();
                sql.append("select count(password) as same from staff ");
                sql.append("where password = '");
                sql.append(generatedPassword);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());
                    if (rs.next() && rs.getInt("same") == 0 ) {
                            repeated = false;
                    }else {
                        generatedPassword = "";
                        for (int i = 0; i < 7; i++) {
                            int randomun = (int) (Math.random() * password_totalSize);
                            generatedPassword += PasswordCharArray[randomun];
                        }
                    }
                }

                //同じのやり方で生成されたIDを重複排除する
                repeated = true;
                int randomun = 1 + (int) (Math.random() * (id_totalSize - 1));
                for (int i = 0; i < 5; i++) {
                    randomun = (int) (Math.random() * id_totalSize);
                    generatedID += IdCharArray[randomun];
                }
                while (repeated) {
                    sql.setLength(0);
                    sql.append("select count(staffID) as same from staff ");
                    sql.append("where staffID = '");
                    sql.append(generatedID);
                    sql.append("'");
                    rs = stmt.executeQuery(sql.toString());
                    if (rs.next() && rs.getInt("same")==0) {
                             repeated = false;
                    }else {
                        generatedID="";
                        for (int i = 0; i < 5; i++) {
                            randomun = (int) (Math.random() * id_totalSize);
                            generatedID += IdCharArray[randomun];
                        }
                    }
                }
                sql = new StringBuffer();

        } else if (registerType.equals("change")) {


        } else if (registerType.equals("delete")){


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
<% if(registerType.equals("add")) {   %>
<form action="staff-register.jsp" method="post">
<div id="main_container">
    <h1 class="left-title">人事登録の入力確認</h1>
    <div id="table_container">
        <table id="staff_check">
            <tr>
                <td>名前</td>
                <td id="staff_name"><%=name%></td>
            </tr>
            <tr>
                <td>人事ID</td>
                <td id="staff_id"><%=generatedID%></td>
            </tr>
            <tr>
                <td>パスワード</td>
                <td id="staff_password"><%=generatedPassword%></td>
            </tr>
            <tr>
                <td>電話番号</td>
                <td id="staff_phone"><%=tel%></td>
            </tr>
            <tr>
                <td>住所</td>
                <td id="staff_address"><%=address%></td>
            </tr>
            <tr>
                <td>入店日付</td>
                <td id="staff_comeday"><%=workStartDate%></td>
            </tr>
        </table>
        <div id="button-group">
            <!-- botton押すとidをstaff.htmlに送ってpopup=ture -->
            <!-- <button onclick="window.location.href='staff.jsp?id=' + 123456 + '&staff_change_popup=true'" id="btn">
                内容を修正する
            </button> -->
            <form action="staff.jsp" method="post">
                <input type="hidden" name="staffID" value="<%=staffID%>">
                <input type="hidden" name="change_open()" value="true">
                <button class="normal-button">内容を修正する</button>
            </form>
                <button class="normal-button">登録</button>
        </div>
    </div>
</div>
</form>
<% } %>
<% if(registerType.equals("change")) {   %>
<div id="main_container">
    <h1 class="left-title">人事修正の確認</h1>
    <div id="table_container">
        <table id="staff_check">
            <tr>
                <td>名前</td>
                <td id="staff_name"><%=changed_staff_name%></td>
            </tr>
            <tr>
                <td>人事ID</td>
                <td id="staff_id"><%=staffID%></td>
            </tr>
            <tr>
                <td>パスワード</td>
                <td id="staff_password"><%=changed_staff_password%></td>
            </tr>
            <tr>
                <td>電話番号</td>
                <td id="staff_phone"><%=changed_staff_tel%></td>
            </tr>
            <tr>
                <td>住所</td>
                <td id="staff_address"><%=changed_staff_address%></td>
            </tr>
            <tr>
                <td>入店日付</td>
                <td id="staff_comeday"><%=workStartDate%></td>
            </tr>
        </table>
        <div id="button-group">
            <form action="staff.jsp" method="post">
                <button class="normal-button">キャンセル</button>
            </form>
            <form action="staff-register.jsp" method="post">
                <input type="hidden" name="staffID" value="<%= staffID %>">
                <input type="hidden" name="changed_staff_name" value="<%=changed_staff_name%>">
                <input type="hidden" name="changed_staff_password" value="<%=changed_staff_password%>">
                <input type="hidden" name="changed_staff_tel" value="<%=changed_staff_tel%>">
                <input type="hidden" name="changed_staff_address" value="<%=changed_staff_address%>">
                <input type="hidden" name="workStartDate" value="<%=workStartDate%>">
                <button class="normal-button">登録</button>
            </form>
        </div>
    </div>
</div>
<% } %>
<% if(registerType.equals("delete")) {   %>
<div id="main_container">
    <h1 class="left-title">人事削除の確認</h1>
    <div id="table_container">
        <table id="staff_check">
            <tr>
                <td>名前</td>
                <td id="staff_name"><%=delete_staff_name%></td>
            </tr>
            <tr>
                <td>人事ID</td>
                <td id="staff_id"><%=staffID%></td>
            </tr>
            <tr>
                <td>パスワード</td>
                <td id="staff_password"><%=delete_staff_password%></td>
            </tr>

            <tr>
                <td>電話番号</td>
                <td id="staff_phone"><%=delete_staff_tel%></td>
            </tr>
            <tr>
                <td>住所</td>
                <td id="staff_address"><%=delete_staff_address%></td>
            </tr>
            <tr>
                <td>入店日付</td>
                <td id="staff_comeday"><%=delete_staff_workStartDate%></td>
            </tr>
        </table>
        <div id="button-group">
            <form action="staff.jsp" method="post">
                <button class="normal-button">キャンセル</button>
            </form>
            <form action="staff-register.jsp" method="post">
                <input type="hidden" name="staffID" value="<%=staffID%>">
                <button class="normal-button">削除</button>
            </form>
        </div>
    </div>
</div>
<% } %>
</body>
</html>
