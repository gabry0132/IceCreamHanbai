<%@ page import="java.net.URLEncoder" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>システム管理</title>
    <link rel="stylesheet" href="css/system-menu.css">
</head>
<body>
    <div id="everything-wrapper">
        <h1>システム管理</h1>
        <div id="button-holder">
            <form action="staff.jsp" method="post" id="staff-form">
                <button class="normal-button">人事管理</button>
            </form>
            <form action="tags.jsp" method="post" id="tag-form">
                <button class="normal-button">タグ管理</button>
            </form>
            <form action="logs-selector.jsp" method="post" id="activityLog-form">
                <button class="normal-button">アクティビティログ</button>
            </form>
        </div>
        <div id="back-button-holder">
            <form action="main.jsp" method="post" id="return-form">
                <button type="submit" id="back-button">戻る</button>
            </form>
        </div>
    </div>
</body>
</html>