<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Calendar" %>
<%
  // 文字コードの指定
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

  //    String staffID = session.getAttribute("staffID");
//    String staffID = session.getAttribute("staffName");
  String staffID = "00";      //仮にシステムの登録だとします
  String staffName = "システム";      //仮にシステムの登録だとします

  String registerType = request.getParameter("registerType");

  //開始のパラメータ
  String productID = request.getParameter("productID");
  String quantityBoxes = request.getParameter("orderQuantityBoxes");

  //停止のパラメータ
  String orderID = request.getParameter("orderID");

  //画面に使う変数
  String name = null;
  int purchaseCost = 0;
  int unitPerBox = 0;
  int confirmDays = 0;
  int shippingDays = 0;
  String image = null;
  String priceMessage = null;
  String expectedArrivalDate = null;

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
  Calendar calendar = Calendar.getInstance();

  try {

    //オブジェクトの代入
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

    sql = new StringBuffer();
    sql.append("select name, purchaseCost, unitPerBox, confirmDays, shippingDays, image from products where productID = " + productID);

    rs = stmt.executeQuery(sql.toString());
    if(rs.next()){
      name = rs.getString("name");
      purchaseCost = rs.getInt("purchaseCost");
      unitPerBox = rs.getInt("unitPerBox");
      confirmDays = rs.getInt("confirmDays");
      shippingDays = rs.getInt("shippingDays");
      image = rs.getString("image");

      priceMessage = "単位 " + unitPerBox + "個 × 単価 " + purchaseCost + "円 ＝ 合計 " + (Integer.parseInt(quantityBoxes) * unitPerBox) + "個（" + ((Integer.parseInt(quantityBoxes) * unitPerBox) * purchaseCost) + "円）";
      calendar.add(Calendar.DATE, (confirmDays + shippingDays));
      expectedArrivalDate = calendar.get(Calendar.YEAR) + "年 " + calendar.get(Calendar.MONTH) + "月 " + calendar.get(Calendar.DATE) + "日";

    } else {
      throw new Exception("対象の商品が見つかりませんでした");
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
%><!DOCTYPE html>

<html lang="ja">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">

    <title>発注開始確認</title>

    <link rel="stylesheet" type="text/css" href="css/sales-order-confirm.css">

</head>

<body>


  <% if(ermsg != null){ %>

    <h4>エラーが発生しました。</h4>
    <p><%=ermsg%></p>

  <% } else { %>

    <div id="order-everything-wrapper">

      <% if(registerType.equals("start")){ %>

        <h2>発注開始を確定する</h2>

        <div id="main-section-wrapper">

          <div id="left-section-wrapper">
            <img class="image" id="start-image" src="<%=request.getContextPath()%>/images/<%=image%>" width="100" height="100" alt="<%=name%>">
          </div>

          <div id="right-section-wrapper">
            <table>
              <tr>
                <td class="order-table-left-side"><%=productID%></td>
                <td><%=name%></td>
              </tr>
              <tr>
                <td class="table-left-side">発注箱数</td>
                <td><%=quantityBoxes%></td>
              </tr>
              <tr>
                <td colspan="2" id="orderStartQuantityPriceMessage"><%=priceMessage%></td>   <!-- <<<<<<<<<<<<<<<<<<<<<<<<< -->
              </tr>
              <tr>
                <td class="table-left-side">発注確認期間</td>
                <td><%=confirmDays%>日</td>
              </tr>
              <tr>
                <td class="table-left-side">出荷後配達期間</td>
                <td><%=shippingDays%>日</td>
              </tr>
              <tr>
                <td class="table-left-side">入荷予定日</td>
                <td><%=expectedArrivalDate%></td>
              </tr>
            </table>

          </div>

        </div>

        <div id="buttons-holder">

          <form action="orders.jsp" method="post">
            <input type="hidden" name="productIDCancelledStart" value="<%=productID%>">
            <input type="hidden" name="quantityBoxesFromStart" value="<%=quantityBoxes%>">
            <button class="normal-button">内容を修正する</button>
          </form>

          <form action="order-register.jsp" method="post">
            <input type="hidden" name="registerType" value="<%=registerType%>">
            <input type="hidden" name="productID" value="<%=productID%>">
            <input type="hidden" name="productName" value="<%=name%>">
            <input type="hidden" name="quantityBoxes" value="<%=quantityBoxes%>">

            <button class="normal-button">開始</button>
          </form>
        </div>

      <% } else if (registerType.equals("stop")) { %>

<%--        <h2>売上データ削除確認</h2>--%>

<%--        <div id="main-section-wrapper">--%>

<%--          <div id="left-section-wrapper">--%>
<%--            <img class="image" id="add-image" src="<%=request.getContextPath()%>/images/<%=productImage%>" width="100" height="100" alt="<%=productName%>">--%>
<%--            <p id="delete-text"><%=productName%> の売上データ (売上ID: <%=saleID%>)を削除します。<br>対象の<b><%=saleQuantitiy%>個</b>を在庫に戻しますか？</p>--%>
<%--          </div>--%>

<%--        </div>--%>

<%--        <div id="buttons-holder">--%>
<%--          <form action="sales.jsp" method="post">--%>
<%--            <button class="normal-button">中止</button>--%>
<%--          </form>--%>
<%--          <form action="sales-register.jsp" method="post">--%>
<%--            <input type="hidden" name="registerType" value="<%=registerType%>">--%>
<%--            <input type="hidden" name="saleID" value="<%=saleID%>">--%>
<%--            <input type="hidden" name="returnQuantity" value="true">--%>

<%--            <button class="delete-button"><%=saleQuantitiy%>個を戻して削除</button>--%>
<%--          </form>--%>
<%--          <form action="sales-register.jsp" method="post">--%>
<%--            <input type="hidden" name="registerType" value="<%=registerType%>">--%>
<%--            <input type="hidden" name="saleID" value="<%=saleID%>">--%>

<%--            <button class="delete-button">このまま削除</button>--%>
<%--          </form>--%>
<%--        </div>--%>


      <% } %>

    </div>



  <% } %>




</body>

</html>

