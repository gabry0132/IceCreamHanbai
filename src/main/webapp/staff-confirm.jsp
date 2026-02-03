<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLEncoder" %>
<%
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
    if(!isAdmin){
        response.sendRedirect("error.jsp?errorMsg=" + URLEncoder.encode("管理者権限が必要です。", "UTF-8"));
        return;
    }

    String registerType = request.getParameter("registerType");

    //削除の場合のパラメータ
    String deleteStaffID = request.getParameter("delete_staffID");
    String deleteStaffName = request.getParameter("delete_name");
    
    //退職のパラメータ
    String quitStaffID = request.getParameter("quit_staffID");
    String quitStaffName = request.getParameter("quit_name");

    //修正の場合のパラメータ
    String changeStaffID = request.getParameter("change_staffID");
    String changed_staff_name = request.getParameter("name_change");
    String changed_staff_password = request.getParameter("password_change");
    String changed_staff_tel = request.getParameter("phone_change");
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
    String url = "jdbc:mysql://localhost/icehanbaikanri";
    String driver = "com.mysql.jdbc.Driver";

    //確認メッセージ
    StringBuffer ermsg = null;

    try {

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //何のButtonを押して、何の処理をするのを確認する
        if(registerType.equals("add")) {
            //追加の時ランタイムIDとpassword機能

            char[] passwordCharArray = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
                    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                    '0','1','2','3','4','5','6','7','8','9'};
            char[] idCharArray = {'0','1','2','3','4','5','6','7','8','9'};

            //パスワード(6桁の数字)を生成する と重複排除
            boolean repeated = true;
            int randomInt = 0;
            do {
                generatedPassword = "";

                for (int i = 0; i < 7; i++) {
                    randomInt = (int) (Math.random() * passwordCharArray.length);
                    generatedPassword += passwordCharArray[randomInt];
                }

                sql = new StringBuffer();
                sql.append("select count(password) as same from staff ");
                sql.append("where password = '");
                sql.append(generatedPassword);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());

                if(rs.next()){
                    if(rs.getInt("same") == 0) repeated = false;
                }
            } while(repeated);

            repeated = true;
            do{
                generatedID = "";
                for (int i = 0; i < 5; i++) {
                    randomInt = (int) (Math.random() * idCharArray.length);
                    generatedID += idCharArray[randomInt];
                }

                sql = new StringBuffer();
                sql.append("select count(staffID) as same from staff ");
                sql.append("where staffID = '");
                sql.append(generatedID);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());

                if(rs.next()){
                    if(rs.getInt("same") == 0) repeated = false;
                }
            } while (repeated);

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
    <% if(registerType.equals("add")) {   %>
        <h1 class="left-title">人事登録の入力確認</h1>
        <div class="table_container">
            <table class="staff-table">
                <tr>
                    <td>名前</td>
                    <td><%=name%></td>
                </tr>
                <tr>
                    <td>人事ID</td>
                    <td><%=generatedID%></td>
                </tr>
                <tr>
                    <td>パスワード</td>
                    <td><%=generatedPassword%></td>
                </tr>
                <tr>
                    <td>電話番号</td>
                    <td><%=tel%></td>
                </tr>
                <tr>
                    <td>住所</td>
                    <td><%=address%></td>
                </tr>
                <tr>
                    <td>入店日付</td>
                    <td><%=workStartDate%></td>
                </tr>
            </table>
            <div class="button-group">
                <form action="staff.jsp" method="post">
                    <button class="normal-button">内容を修正する</button>
                </form>
                <form action="staff-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="add">
                    <input type="hidden" name="name" value="<%=name%>">
                    <input type="hidden" name="generatedID" value="<%=generatedID%>">
                    <input type="hidden" name="generatedPassword" value="<%=generatedPassword%>">
                    <input type="hidden" name="tel" value="<%=tel%>">
                    <input type="hidden" name="address" value="<%=address%>">
                    <input type="hidden" name="workStartDate" value="<%=workStartDate%>">
                    <button class="normal-button">登録</button>
                </form>
            </div>
        </div>
    <% } else if(registerType.equals("change")) {   %>
        <h1 class="left-title">人事修正の確認</h1>
        <div id="table_container">
            <table class="staff-table">
                <tr>
                    <td>名前</td>
                    <td><%=changed_staff_name%></td>
                </tr>
                <tr>
                    <td>人事ID</td>
                    <td><%=changeStaffID%></td>
                </tr>
                <tr>
                    <td>パスワード</td>
                    <td><%=changed_staff_password%></td>
                </tr>
                <tr>
                    <td>電話番号</td>
                    <td><%=changed_staff_tel%></td>
                </tr>
                <tr>
                    <td>住所</td>
                    <td><%=changed_staff_address%></td>
                </tr>
            </table>
            <div class="button-group">
                <form action="staff.jsp" method="post">
                    <button class="normal-button">キャンセル</button>
                </form>
                <form action="staff-register.jsp" method="post">

                    <input type="hidden" name="registerType" value="change">
                    <input type="hidden" name="targetStaffID" value="<%=changeStaffID%>">
                    <input type="hidden" name="changed_staff_name" value="<%=changed_staff_name%>">
                    <input type="hidden" name="changed_staff_password" value="<%=changed_staff_password%>">
                    <input type="hidden" name="changed_staff_tel" value="<%=changed_staff_tel%>">
                    <input type="hidden" name="changed_staff_address" value="<%=changed_staff_address%>">
                    <button class="normal-button">登録</button>
                </form>
            </div>
        </div>
    <% } else if(registerType.equals("delete")) {   %>
        <h1 class="left-title">人事削除の確認</h1>
        <div id="table_container">
            <table class="staff-table">
                <tr>
                    <td>名前</td>
                    <td><%=deleteStaffName%></td>
                </tr>
                <tr>
                    <td>人事ID</td>
                    <td><%=deleteStaffID%></td>
                </tr>
            </table>
            <div class="button-group">
                <form action="staff.jsp" method="post">
                    <button class="normal-button">キャンセル</button>
                </form>
                <form action="staff-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="delete">
                    <input type="hidden" name="name" value="<%=deleteStaffName%>">
                    <input type="hidden" name="targetStaffID" value="<%=deleteStaffID%>">
                    <button class="normal-button">削除</button>
                </form>
            </div>
        </div>
    <% } else if(registerType.equals("quit")) {   %>
        <h1 class="left-title">人事退職の確認</h1>
        <div id="table_container">
            <table class="staff-table">
                <tr>
                    <td>名前</td>
                    <td><%=quitStaffName%></td>
                </tr>
                <tr>
                    <td>人事ID</td>
                    <td><%=quitStaffID%></td>
                </tr>
            </table>
            <div class="button-group">
                <form action="staff.jsp" method="post">
                    <button class="normal-button">キャンセル</button>
                </form>
                <form action="staff-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="quit">
                    <input type="hidden" name="name" value="<%=quitStaffName%>">
                    <input type="hidden" name="targetStaffID" value="<%=quitStaffID%>">
                    <button class="normal-button">退職を確定する</button>
                </form>
            </div>
        </div>
    <% } %>
</div>
</body>
</html>
