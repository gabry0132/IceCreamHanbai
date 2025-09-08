<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String errorMsg = (String)request.getAttribute("errorMsg");
    if (errorMsg == null) {
        errorMsg = "エラーが発生しました。";
    }
%>
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>エラー画面</title>
     <link rel="stylesheet" type="text/css" href="css/error.css">

</head>
<body>
    <h1>
        エラーが発生しました。
    </h1>
    <p>
        <%= errorMsg %>
    </p>
    <form action="index.jsp" method="post">
        <button class="normal-button">
            トップページへ戻る
        </button>
    </form>
</body>
</html>