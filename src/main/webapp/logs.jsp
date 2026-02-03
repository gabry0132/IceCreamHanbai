<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLEncoder" %>
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

  String activityType = request.getParameter("activityType"); //検索条件にもなります
  if(activityType == null) activityType = "すべて";

  //検索条件
  String productSearch = request.getParameter("productSearch");
  String startDateSuffix = " 00:00:00";
  String endDateSuffix = " 23:59:59";
  String searchStartDate = request.getParameter("searchStartDate");
  if(searchStartDate != null){
    if(searchStartDate.isEmpty()) searchStartDate = null;
  }
  String searchEndDate = request.getParameter("searchEndDate");
  if(searchEndDate != null){
    if(searchEndDate.isEmpty()) searchEndDate = null;
  }

  //ページング変数
  int numberOfPages = 1;
  int pageLimitOffset = 15;   //1ページに何件が表示されるか
  int selectedPage = 1;
  if(request.getParameter("targetPage") != null) selectedPage = Integer.parseInt(request.getParameter("targetPage"));
  selectedPage--; //オフセット計算に使うので -1にします

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
  HashMap<String,String> map;
  ArrayList<HashMap<String,String>> logs = new ArrayList<>();
  ArrayList<HashMap<String,String>> productsList = new ArrayList<>();
  ArrayList<HashMap<String,String>> logTypes = new ArrayList<>();

  try {
    //オブジェクトの代入
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

    //全てのlogtypeを取得する
    sql = new StringBuffer();
    sql.append("select type, typeEng from logtypes where deleteFlag = 0");

    rs = stmt.executeQuery(sql.toString());
    while(rs.next()){
      map = new HashMap<>();
      map.put("type", rs.getString("type"));
      map.put("typeEng", rs.getString("typeEng"));
      logTypes.add(map);
    }

    //商品一覧を取得する
    sql = new StringBuffer();
    sql.append("select productID, name, quantity, image from products");
    rs = stmt.executeQuery(sql.toString());

    while (rs.next()) {
      map = new HashMap<>();
      map.put("productID", rs.getString("productID"));
      map.put("name", rs.getString("name"));
      productsList.add(map);
    }

    //合計ページ数を先に取得します
    sql = new StringBuffer();
    sql.append("select count(activityLogID) as count from logs where deleteFlag = 0 ");
    if(activityType != null) {
      if(!activityType.equals("すべて")){
        sql.append(" and type = '" + activityType +"'");
      }
    }
    if(productSearch != null) sql.append(" and logs.productID = " + productSearch);
    if(searchStartDate != null) sql.append(" and dateTime > '" + searchStartDate + startDateSuffix + "' ");
    if(searchEndDate != null) sql.append(" and dateTime < '" + searchEndDate + endDateSuffix + "' ");
    rs = stmt.executeQuery(sql.toString());

    if (rs.next()) {
      numberOfPages = rs.getInt("count") / pageLimitOffset;
      if(rs.getInt("count") % pageLimitOffset != 0) numberOfPages++;
    }

    //ページ内の検索を開始する。
    sql = new StringBuffer();
    sql.append("select type, typeEng, text, logs.productID as productID, dateTime, image, products.name as name from logs inner join logtypes on logs.logtypeID = logtypes.logtypeID left join products on logs.productID = products.productID ");
    sql.append("where logs.deleteFlag = 0 and logtypes.deleteFlag = 0 ");
    if(activityType != null) {
      if(!activityType.equals("すべて")){
        sql.append(" and type = '" + activityType +"'");
      }
    }
    if(productSearch != null) sql.append(" and logs.productID = " + productSearch);
    if(searchStartDate != null) sql.append(" and dateTime > '" + searchStartDate + startDateSuffix + "' ");
    if(searchEndDate != null) sql.append(" and dateTime < '" + searchEndDate + endDateSuffix + "' ");
    sql.append(" order by dateTime desc limit " + pageLimitOffset + " offset " + (selectedPage * pageLimitOffset));

    rs = stmt.executeQuery(sql.toString());
    while(rs.next()){
      map = new HashMap<>();
      map.put("type", rs.getString("type"));
      map.put("typeEng", rs.getString("typeEng"));
      map.put("productID", rs.getString("productID"));
      //商品が対象の場合は、名前にもクリックできるようにしたいので<a>タグに含まれない残りの文章を別で保存します。
      //商品が対象じゃなければ文章そのまま保存されます。
      map.put("name", rs.getString("name"));
      map.put("text", rs.getString("text").replace(rs.getString("name"), ""));
      map.put("dateTime", rs.getString("dateTime"));
      map.put("image", rs.getString("image"));
      logs.add(map);
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
  <title>アクティビティログ画面</title>
  <link rel="stylesheet" href="css/logs.css">
</head>

<body>

  <h1>アクティビティログ</h1>

  <div id="search-area">

    <form action="logs.jsp" method="post" id="search-form">

      <div>
        <div class="search-row">
          <select name="activityType" id="activityType">
            <% for(int i = 0; i < logTypes.size(); i++) { %>
              <option<% if(logTypes.get(i).get("type").equals(activityType)){ %> selected<%}%> value="<%=logTypes.get(i).get("type")%>"><%=logTypes.get(i).get("type")%></option>
            <%}%>
            <option<% if(activityType.equals("すべて")){ %> selected<%}%>>すべて</option>
          </select>
          <label>
            <input type="date" name="searchStartDate" id="searchStartDate">
            から
          </label>
        </div>
        
        <div class="search-row">
          <select id="productSearch" name="productSearch">
            <option hidden disabled selected value>商品を選択</option>
            <%
              for(int i=0; i < productsList.size(); i++){
            %>
            <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
            <%
              }
            %>
          </select>
          <label>
            <input type="date" name="searchEndDate" id="searchEndDate">
            まで
          </label>
        </div>
      </div>

      <div id="search-buttons-holder">
        <button class="submit">この条件で検索</button>
        <button class="normal-button" type="reset">条件をクリア</button>
      </div>
      
    </form>

    <div class="back-button-holder">
      <form action="main.jsp" method="post">
          <button class="normal-button">戻る</button>
      </form>
    </div>

  </div>

  <% if(logs.isEmpty()){ %>

    <h3>ログデータがありません。</h3>

  <% } else { %>

    <div id="log-list">

      <% for(int i = 0; i < logs.size(); i++) { %>

        <div class="log-item <%=logs.get(i).get("typeEng")%>">
          <!-- check this again -->
          <div class="log-label"><%=logs.get(i).get("type")%></div>
          <div class="log-date"><%=logs.get(i).get("dateTime")%></div>
          <% if(logs.get(i).get("productID") != null){ %>
            <!--商品に関わるお知らせがほとんどなので基本的に画像を出す。出さなくていい場合はlog-labelだけでいいです。-->
            <a href="product-details.jsp?productID=<%=logs.get(i).get("productID")%>&previousPage=logs.jsp&activityType=<%=activityType%>">
              <img src="images/<%=logs.get(i).get("image")%>" class="log-image" width="50" height="50" alt="<%=logs.get(i).get("name")%>">
            </a>
          <% } %>
          <div class="log-text"><% if(logs.get(i).get("productID") != null){ %><a href="product-details.jsp?productID=<%=logs.get(i).get("productID")%>&previousPage=logs.jsp&activityType=<%=activityType%>"><%=logs.get(i).get("name")%></a><%}%><%=logs.get(i).get("text")%></div>
        </div>

      <% } %>

    </div>

  <% } %>

  <div class="back-button-holder">
    <form action="main.jsp" method="post">
        <button class="normal-button">戻る</button>
    </form>
  </div>

  <div id="page-selector-wrapper">

    <% for (int i = 1; i <= numberOfPages; i++) { %>
      <span class="page-number-span <% if(i - 1  == selectedPage){ %> current-page <% } %>" onclick="reloadOnPage(<%=i%>)"><%=i%></span>
    <% } %>

  </div>

  <%--        ページングのための非表示フォーム--%>
  <form action="logs.jsp" method="post" id="pageingSearch">
    <% if(productSearch != null){ %>     <input type="hidden" name="productSearch" value="<%=productSearch%>">      <% } %>
    <% if(searchStartDate != null){ %>   <input type="hidden" name="searchStartDate" value="<%=searchStartDate%>">  <% } %>
    <% if(searchEndDate != null){ %>     <input type="hidden" name="searchEndDate" value="<%=searchEndDate%>">      <% } %>
    <input type="hidden" name="targetPage" id="targetPage">
  </form>

  <script>
    //activityType以外の検索条件を設定する。
    <% if(productSearch != null){ %> document.getElementById("productSearch").value = "<%=productSearch%>" <% } %>
    <% if(searchStartDate != null){ %> document.getElementById("searchStartDate").value = "<%=searchStartDate%>" <% } %>
    <% if(searchEndDate != null){ %> document.getElementById("searchEndDate").value = "<%=searchEndDate%>" <% } %>

    function reloadOnPage(targetPage){
      document.getElementById("targetPage").value = Number(targetPage);
      document.getElementById("pageingSearch").submit();
    }
  </script>

</body>
</html>
