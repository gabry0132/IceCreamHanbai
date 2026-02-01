<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>
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
  String staffID = "00";      //仮にシステムの登録だとします
  String staffName = "システム";      //仮にシステムの登録だとします
  boolean isAdmin = true; //fix this

  Connection con = null;
  Statement stmt = null;
  StringBuffer sql = null;
  ResultSet rs = null;

  String user = "root";
  String password = "root";
  String url = "jdbc:mysql://localhost/icehanbaikanri";
  String driver = "com.mysql.jdbc.Driver";

  HashMap<String, String> map;
  ArrayList<HashMap<String, String>> standardList = new ArrayList<>();
  
  HashMap<String, Integer> productIDandQuantityToAddCombo = null;
  ArrayList<HashMap<String, Integer>> productsList = new ArrayList<>();
  ArrayList<String> ordersToComplete = new ArrayList<>();
  boolean alreadyRegisteredProduct = false;
  ArrayList<HashMap<String, String>> alerts = new ArrayList<>();
  int affectedRows = 0;

  //確認メッセージ
  StringBuffer ermsg = null;
  String[] orderTimestampSplit = null;
  Calendar orderDate = Calendar.getInstance();
  Calendar currentDate = Calendar.getInstance();

  try {
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

    //*********************
    //**** 　入荷処理　 *****
    //*********************

    //発注開始日時を使って、入荷済みのものを検索して発注した分を在庫に入るようにします。
    sql = new StringBuffer();
    sql.append("select o.orderID, o.productID, o.quantity as quantityBoxes, o.startDateTime, ");
    sql.append("p.quantity as inStockQuantity, p.unitPerBox, p.confirmDays, p.shippingDays ");
    sql.append("from orders o inner join products p on o.productID = p.productID ");
    sql.append("where o.deleteFlag = 0 and o.stoppedFlag = 0 and o.completed = 0 ");  //completedがゼロだったら対象になります。
    sql.append("and p.deleteFlag = 0 ");

    rs = stmt.executeQuery(sql.toString());
    while(rs.next()){

      //入荷済みかどうか判断
      //2026-01-30 23:06:24の形で来る
      orderTimestampSplit = rs.getString("startDateTime").split(" ")[0].split("-");
      orderDate.set(Calendar.YEAR, Integer.parseInt(orderTimestampSplit[0]));
      orderDate.set(Calendar.MONTH, Integer.parseInt(orderTimestampSplit[1]) - 1);
      orderDate.set(Calendar.DATE, Integer.parseInt(orderTimestampSplit[2]));
      //入荷日付を計算する
      orderDate.add(Calendar.DATE, rs.getInt("confirmDays") + rs.getInt("shippingDays"));

      //当日入荷は対象する。
      if(currentDate.compareTo(orderDate) >= 0){
        alreadyRegisteredProduct = false;
        for (int i = 0; i < productsList.size(); i++) {
          if(productsList.get(i).get("productID").equals(rs.getString("productID"))){
            productsList.get(i).put("quantityToAdd", productsList.get(i).get("quantityToAdd") + (rs.getInt("quantityBoxes") * rs.getInt("unitPerBox")));
            alreadyRegisteredProduct = true;
          }
        }
        if(!alreadyRegisteredProduct){
          productIDandQuantityToAddCombo = new HashMap<>();
          productIDandQuantityToAddCombo.put("productID", rs.getInt("productID"));
          productIDandQuantityToAddCombo.put("inStockQuantity", rs.getInt("inStockQuantity"));
          productIDandQuantityToAddCombo.put("quantityToAdd", (rs.getInt("quantityBoxes") * rs.getInt("unitPerBox")));
          productsList.add(productIDandQuantityToAddCombo);
        }
        ordersToComplete.add(rs.getString("orderID"));
      }
    }

    //入荷にあたって在庫を増やします
    for (int i = 0; i < productsList.size(); i++) {
      sql = new StringBuffer();
      sql.append("update products set quantity = " + (productsList.get(i).get("inStockQuantity") + productsList.get(i).get("quantityToAdd")) + " ");
      sql.append(" where productID = " + productsList.get(i).get("productID"));   //deleteFlagを無視します

      affectedRows = stmt.executeUpdate(sql.toString());
      if(affectedRows == 0) throw new Exception("商品ID " + productsList.get(i).get("productID") + " の入荷処理が失敗しました。　エラーはループ内の " + i +"回目に発生しています。" );
    }

    //無事入荷処理が終わったことを発注テーブルに登録します
    if(!ordersToComplete.isEmpty()){
      sql = new StringBuffer();
      sql.append("update orders set completed = 1 where orderID in (");
      for (int i = 0; i < ordersToComplete.size(); i++) {
        if(i != 0) sql.append(",");
        sql.append(ordersToComplete.get(i));
      }
      sql.append(")");
      affectedRows = stmt.executeUpdate(sql.toString());
      if(affectedRows == 0) throw new Exception("発注テーブルでの入荷処理完成登録が失敗しました。" );
    }

    //*********************
    //***　自動発注処理　****
    //*********************

    //対象商品を取得する
    sql = new StringBuffer();
    sql.append("select p.productID, p.name, p.autoOrderQuantity, p.unitPerBox ");
    sql.append("from products p left join orders o on o.orderID = ");
    sql.append("( ");
    sql.append(" select max(o2.orderID) from orders o2 where o2.productID = p.productID and o2.stoppedFlag != 1 ");
    sql.append(") ");
    sql.append("where p.quantity <= p.autoOrderLimit and p.stopAutoOrder = 0 and p.deleteFlag = 0 ");
    sql.append("and (o.orderID is null or (o.orderID is not null and o.completed = 1)) ");

    rs = stmt.executeQuery(sql.toString());
    while(rs.next()){
      map = new HashMap<>();
      map.put("productID", rs.getString("productID"));
      map.put("productName", rs.getString("name"));
      map.put("autoOrderQuantity", rs.getString("autoOrderQuantity"));
      map.put("unitPerBox", rs.getString("unitPerBox"));
      standardList.add(map);
    }

    //ログすべきであればログタイプIDを取得する
    String logtypeIDforOrders = null;
    if(!standardList.isEmpty()){
      //ログのために発注に関わるログタイプIDを取得。
      sql = new StringBuffer();
      sql.append("select logtypeID from logtypes where type='発注'");
      rs = stmt.executeQuery(sql.toString());

      if(rs.next()){
        logtypeIDforOrders = rs.getString("logtypeID");
      } else {
        throw new Exception("発注ログタイプIDの取得が失敗しました。");
      }
    }

    //実際の発注開始を行う
    for (int i = 0; i < standardList.size(); i++) {
      sql = new StringBuffer();
      sql.append("insert into orders(productID, initiator, quantity) ");
      sql.append("values(" + standardList.get(i).get("productID") + ",'" + staffID + "'," + standardList.get(i).get("autoOrderQuantity") + ")");

      affectedRows = stmt.executeUpdate(sql.toString());
      if (affectedRows == 0) {
        throw new Exception("発注開始処理が失敗しました");
      }

      //ログの登録を行います。
      sql = new StringBuffer();
      sql.append("insert into logs (logtypeID, text, productID) value (");
      sql.append(logtypeIDforOrders);
      sql.append(",'");
      sql.append(standardList.get(i).get("productName") + " × " + standardList.get(i).get("autoOrderQuantity") + "箱の発注が システム により 自動開始されました");
      sql.append("',");
      sql.append(standardList.get(i).get("productID"));
      sql.append(")");

      affectedRows = stmt.executeUpdate(sql.toString());
      if (affectedRows == 0) {
        throw new Exception("発注開始のログ登録処理が失敗しました。");
      }
    }

    //アラート取得処理
    sql = new StringBuffer();
    sql.append("select products.productID, name, image, (products.quantity - autoOrderLimit) as toOrder from products ");
    sql.append("left join orders on products.productID = orders.productid ");
    sql.append("where (orders.completed != 0 or orders.completed is null) and products.quantity < alertNumber and products.stopAutoOrder = 0 ");

    rs = stmt.executeQuery(sql.toString());

    while(rs.next()) {

      map = new HashMap<>();
      map.put("productID", rs.getString("productID"));
      map.put("name", rs.getString("name"));
      map.put("image", rs.getString("image"));
      map.put("toOrder", rs.getString("toOrder"));
      alerts.add(map);

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
      <form action="orders.jsp" method="post">
        <button class="normal-button">発注管理</button>
      </form>
      <form action="system-menu.jsp" method="post">
        <button class="normal-button">システム管理</button>
      </form>
    <% } %>
  </div>

  <form action="index.jsp" method="post" id="logout-form">
    <input type="hidden" name="logout" value="logout">
    <button class="normal-button" id="logout-button">ログアウト</button>
  </form>  

  <h2>アラート一覧</h2>

  <% if (ermsg != null){ %>

    <h2>エラーが発生しました。</h2>
    <p><%=ermsg%></p>

  <% } %>

  <% if(alerts.isEmpty()){ %>

    <h4>アラートがありません。</h4>

  <% } else { %>

    <div id="alerts-container">

      <% for (int i = 0; i < alerts.size(); i++) { %>

        <div class="alert-box">
          <a href="product-details.jsp?productID=<%=alerts.get(i).get("productID")%>&previousPage=main.jsp" class="image-wrapper-anchor">
            <img class="image" src="<%=request.getContextPath()%>/images/<%=alerts.get(i).get("image")%>" width="70" height="70" alt="<%=alerts.get(i).get("name")%>">
          </a>
          <p class="alert-text"><%=alerts.get(i).get("name")%> が後 <b><%=alerts.get(i).get("toOrder")%>個</b> 売ったら自動発注が開始されます。</p>
          <% if(isAdmin){ %>
            <form action="orders.jsp" method="post" class="order-now-form">
              <input type="hidden" name="startFromProductID" value="<%=alerts.get(i).get("productID")%>">
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
