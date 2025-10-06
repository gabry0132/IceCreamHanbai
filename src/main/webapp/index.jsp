<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String staffID = request.getParameter("staffID");
    String pass = request.getParameter("pass");
    String logout = request.getParameter("logout");

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

    if(logout != null){
        session.removeAttribute("staffID");
        session.removeAttribute("isAdmin");
    }

    if(staffID != null){

        try {
            //オブジェクトの代入
            Class.forName(driver).newInstance();
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            sql = new StringBuffer();
            sql.append("select staffID, password, adminFlag from  staff ");
            sql.append("where staffID = '");
            sql.append(staffID);
            sql.append("' ");

            rs = stmt.executeQuery(sql.toString());

            if (rs.next()) {

                if(staffID.equals(rs.getString("staffID")) && pass.equals(rs.getString("password"))){
                    // ログイン成功
//                    session.setMaxInactiveInterval(300);
                    session.setAttribute("staffID", staffID);
                    if(rs.getInt("adminFlag") == 1){
                        session.setAttribute("isAdmin", true);
                    } else {
                        session.setAttribute("isAdmin", false);
                    }

                    response.sendRedirect("main.jsp");
                    return; // ここで処理終了

                } else {
                    // ログイン失敗
                    request.setAttribute("errorMsg", "社員番号またはパスワードが違います。");
                    RequestDispatcher rd = request.getRequestDispatcher("error.jsp");
                    rd.forward(request, response);
                    return;

                }

            } else {
                // ログイン失敗
                request.setAttribute("errorMsg", "社員番号またはパスワードが違います。");
                RequestDispatcher rd = request.getRequestDispatcher("error.jsp");
                rd.forward(request, response);
                return;
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

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>ログイン画面</title>
    <link rel="stylesheet" type="text/css" href="index.css">

</head>

<body>

<h1>ログイン画面</h1>

<form action="login.jsp" method="post">
    <div id="login-container">
        <div id="syainbangou">
            <p class="login-text">社員番号　</p>
            <input type="text" name="staffID" id="staffID">
        </div>

        <div id="password-container">
            <p class="login-text">パスワード</p>
            <input type="password" name="pass" id="pass">
        </div>
    </div>

    <div id="button-container">
        <button type="reset">クリア</button>
        <button>ログイン</button>
    </div>
</form>

</body>

</html>