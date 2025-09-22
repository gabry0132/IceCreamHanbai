<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<!DOCTYPE html>
<html lang="ja">
 
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width">
  <title>メインメニュー</title>
  <link rel="stylesheet" href="css/main.css">
</head>

<body>

  <div id="top-text-holder">
    <h1>アイス販売管理システム</h1>
    <span>管理者モード</span>
  </div>

  <div id="top-buttons">
    <form action="products.jsp" method="post">
      <button class="normal-button">商品管理</button>
    </form>
    <form action="sales.jsp" method="post">
      <button class="normal-button">売上管理</button>
    </form>
    <form action="order.jsp" method="post">
      <button class="normal-button">発注管理</button>
    </form>
    <form action="system-menu.html" method="post">
      <button class="normal-button">システム管理</button>
    </form>
  </div>

  <form action="index.html" method="post" id="logout-form">
    <button class="normal-button" id="logout-button">ログアウト</button>
  </form>  

  <h2>アラート一覧</h2>

  <div id="alerts-container">

    <div class="alert-box">
      <img class="image" src="images/ice1.png" width="70" height="70" alt="ice1"> 
      <p class="alert-text">板チョコアイスが後 <b>4個</b> 売ったら自動発注が開始されます。</p>
      <form action="#" method="post" class="order-now-form">
        <button class="normal-button ordernow-button">今から発注</button>
      </form>
    </div>
    
    <div class="alert-box">
      <img class="image" src="images/ice2.jpg" width="70" height="70" alt="ice2"> 
      <p class="alert-text">ガリガリ君が後 <b>3個</b> 売ったら自動発注が開始されます。</p>
      <form action="#" method="post" class="order-now-form">
        <button class="normal-button ordernow-button">今から発注</button>
      </form>
    </div>

  </div>

</body>
</html>
