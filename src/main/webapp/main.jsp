<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

//    String logout = request.getParameter("logout");
//    if(logout != null){
//        session.removeAttribute("userID");
//    }

//    String staffID = (String) session.getAttribute("staffID");
//
//    if(staffID != null){
//        response.sendRedirect("index.jsp");
//    }

//  boolean isAdmin = (boolean) session.getAttribute("isAdmin");
  boolean isAdmin = true; //fix this

  Connection con = null;
  Statement stmt = null;
  StringBuffer sql = null;
  ResultSet rs = null;

  String user = "root";
  String password = "root";
  String url = "jdbc:mysql://localhost/icehanbaikanri";
  String driver = "com.mysql.jdbc.Driver";

  HashMap<String, String> alert;
  ArrayList<HashMap<String, String>> alerts = new ArrayList<>();

  //確認メッセージ
  StringBuffer ermsg = null;

  try {
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

                                                //check again when orders is finilized
    sql = new StringBuffer();
    sql.append("select products.productID, name, image, (products.quantity - autoOrderLimit) as toOrder from products ");
    sql.append("left join orders on products.productID = orders.productid ");
    sql.append("where (orders.completed != 0 or orders.completed is null) and products.quantity < alertNumber and products.stopAutoOrder = 0 ");

    rs = stmt.executeQuery(sql.toString());

    while(rs.next()) {

      alert = new HashMap<>();
      alert.put("productID", rs.getString("productID"));
      alert.put("name", rs.getString("name"));
      alert.put("image", rs.getString("image"));
      alert.put("toOrder", rs.getString("toOrder"));
      alerts.add(alert);

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
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width">
  <title>メインメニュー</title>
  <link rel="stylesheet" href="css/main.css">
</head>

<body>

  <div id="top-text-holder">
    <h1>アイス販売管理システム</h1>
    <% if(isAdmin){ %>
      <span>管理者モード</span>
    <% } %>
  </div>

  <div id="top-buttons">
    <form action="products.jsp" method="post">
      <button class="normal-button">商品管理</button>
    </form>
    <form action="sales.jsp" method="post">
      <button class="normal-button">売上管理</button>
    </form>
    <% if(isAdmin){ %>
      <form action="order.jsp" method="post">
        <button class="normal-button">発注管理</button>
      </form>
      <form action="system-menu.html" method="post">
        <button class="normal-button">システム管理</button>
      </form>
    <% } %>
  </div>

  <form action="index.jsp" method="post" id="logout-form">
    <input type="hidden" name="logout" value="logout">
    <button class="normal-button" id="logout-button">ログアウト</button>
  </form>  

  <h2>アラート一覧</h2>

  <% if(alerts.isEmpty()){ %>

    <h4>アラートがありません。</h4>

  <% } else { %>

    <div id="alerts-container">

      <% for (int i = 0; i < alerts.size(); i++) { %>

        <div class="alert-box">
          <img class="image" src="<%=request.getContextPath()%>/images/<%=alerts.get(i).get("image")%>" width="70" height="70" alt="<%=alerts.get(i).get("name")%>">
          <p class="alert-text"><%=alerts.get(i).get("name")%> が後 <b><%=alerts.get(i).get("toOrder")%>個</b> 売ったら自動発注が開始されます。</p>
          <% if(isAdmin){ %>
            <form action="order-details.jsp" method="post" class="order-now-form">
              <input type="hidden" name="productID" value="<%=alerts.get(i).get("productID")%>">
              <input type="hidden" name="previousPage" value="main.jsp">
              <button class="normal-button ordernow-button">今から発注</button>
            </form>
          <% } %>
        </div>

      <% } %>

    </div>

  <% } %>

</body>
</html>
