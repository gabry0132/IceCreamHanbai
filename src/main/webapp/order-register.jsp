<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
  // 文字コードの指定
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

  //    String staffID = session.getAttribute("staffID");
//    String staffID = session.getAttribute("staffName");
  String staffID = "00";      //仮にシステムの登録だとします
  String staffName = "システム";      //仮にシステムの登録だとします

  String registerType = request.getParameter("registerType");
  String logtypeIDforOrders = null;   //ログに使います

  //開始の時のパラメータ
  String productID = request.getParameter("productID");
  String productName = request.getParameter("productName");
  String quantityBoxes = request.getParameter("quantityBoxes");

  //停止の時のパラメータ
  String orderID = request.getParameter("orderID");

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
  int updatedRows = 0;

  try {

    //オブジェクトの代入
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

    //ログのために商品に関わるログタイプIDを取得。
    sql = new StringBuffer();
    sql.append("select logtypeID from logtypes where type='発注'");
    rs = stmt.executeQuery(sql.toString());

    if(rs.next()){
      logtypeIDforOrders = rs.getString("logtypeID");
    } else {
      throw new Exception("発注ログタイプIDの取得が失敗しました。");
    }

    if(registerType.equals("start")) {

      sql = new StringBuffer();
      sql.append("insert into orders(productID, initiator, quantity)");
      sql.append("values(" + productID + ",'" + staffID + "'," + quantityBoxes + ")");

      updatedRows = stmt.executeUpdate(sql.toString());
      if (updatedRows == 0) {
        throw new Exception("発注開始処理が失敗しました");
      }

      //ログの登録を行います。
      sql = new StringBuffer();
      sql.append("insert into logs (logtypeID, text, productID) value (");
      sql.append(logtypeIDforOrders);
      sql.append(",'");
      sql.append(productName + " × " + quantityBoxes + "個の発注が " + staffName + " により 開始されました");
      sql.append("',");
      sql.append(productID);
      sql.append(")");

      updatedRows = stmt.executeUpdate(sql.toString());
      if (updatedRows == 0) {
        throw new Exception("発注開始のログ登録処理が失敗しました。");
      }


    } else if (registerType.equals("stop")) {

//      sql.append("update Order set deleteFlag = 1 where productID = ");
//      sql.append(StrproductID);

      rs = stmt.executeQuery(sql.toString());
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
%>
<!DOCTYPE html>

<html lang="ja">

  <head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">

    <title>発注登録・停止結果確認</title>

    <link rel="stylesheet" type="text/css" href="css/sales-order-register.css">

  </head>

  <body>
    <div>
      <%
        if (ermsg != null){
      %>
          <h2>エラーが発生しました。</h2>
          <p><%=ermsg%></p>
      <%
        } else {
      %>

        <%
          if (registerType.equals("start")){
        %>
        <h1>商品の発注が正常に開始しました。</h1>
        <%
          } else if (registerType.equals("stop")) {
        %>
          <h1>商品の発注が正常に停止しました。</h1>
        <%}%>
      <%}%>

      <form action="orders.jsp" method="post">
        <button class="normal-button">発注一覧に戻る</button>
      </form>

    </div>
  </body>


</html>

