<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
    boolean isAdmin = (boolean) session.getAttribute("isAdmin");
    if(!isAdmin){
        response.sendRedirect("error.jsp?errorMsg=" + URLEncoder.encode("管理者権限が必要です。", "UTF-8"));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/logs-selector.css">
    <title>ログセレクター</title>
</head>
<body>
<h2>どちらのログを確認しますか</h2>

<div id="buttons-holder">

    <form action="logs.jsp" method="post">
        <input type="hidden" id="activityType" name="activityType" value="">
    </form>

    <button type="button" class="normal-button">商品</button>
    <button type="button" class="normal-button">売上</button>
    <button type="button" class="normal-button">お知らせ</button>
    <button type="button" class="normal-button">すべて</button>
</div>

<script>
    buttons = Array.from(document.getElementsByTagName("button"));
    activityType = document.getElementById("activityType");
    buttons.forEach(button => {
        button.addEventListener("click", () => {
            activityType.value = button.innerHTML;
            document.forms[0].submit();
        })
    });
</script>
</body>
</html>