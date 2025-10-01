<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%
  //データベースに接続するために使用する変数宣言
  Connection con = null;
  Statement stmt = null;
  StringBuffer sql = null;
  ResultSet rs = null;

  String registerType = request.getParameter("registerType");

  String StrunitPerBox = request.getParameter("unitPerBox");
  String StrproductID = request.getParameter("productID");
  String Strinitiator = request.getParameter("initiator");

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

    sql = new StringBuffer();

    if(registerType.equals("add")) {

      sql.append("insert into Order");

      rs = stmt.executeQuery(sql.toString());
    } else if (registerType.equals("delete")) {

      sql.append("update Order set deleteFlag = 1 where productID = ");
      sql.append(StrproductID);

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

    <link rel="stylesheet" type="text/css" href="css/order-register.css">

  </head>

  <body>
    <div>
      <%
        if (ermsg != null){
      %>
      <h1>エラーが発生しました。</h1>
      <%}else {%>
      <%
        if (registerType.equals("add")){
      %>
      <h1>商品の発注が正常に開始しました。</h1>
      <%
        } else if (registerType.equals("delete")) {
      %>
      <h1>商品の発注が正常に停止しました。</h1>
      <%}%>
      <%}%>




      <div>
        <form action="order.jsp">
          <button>発注管理に戻る</button>
        </form>
      </div>
    </div>
  </body>


</html>

