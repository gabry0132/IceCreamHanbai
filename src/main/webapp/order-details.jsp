<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
  //データベースに接続するために使用する変数宣言
  Connection con = null;
  Statement stmt = null;
  StringBuffer sql = null;
  ResultSet rs = null;

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
    sql.append("select");

    rs = stmt.executeQuery(sql.toString());


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

    <link rel="stylesheet" type="text/css" href="css/order-details.css">

  </head>

  <body>
    
    <div>
      <h1>発注開始を確定する</h1>
      <div id="wrapper">
        <table>
          <tr>
            <td>
              <img src="images/ice1.png" alt="">
            </td>
            <td>商品の名前とID</td>
          </tr>
          <tr>
            <td>発注個数</td>
            <td><%= StrunitPerBox%>>×24個</td>
          </tr>
          <tr>
            <td>届く予定日</td>
            <td>２日後の日付</td>
          </tr>
          <tr>
            <td>
              <form action="order.jsp">
                <button>内容修正</button>
              </form>
            </td>
            <td>
              <form action="order-register.jsp">
                <button>発注開始</button>
                <input type="hidden" id="unitPerBox">
                <input type="hidden" id="productID">
                <input type="hidden" id="initiator">

                <!-- 登録を個別するための非表示項目 -->
                <input type="hidden" name="registerType" value="add">
              </form>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </body>

</html>

