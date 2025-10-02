<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
  request.setCharacterEncoding("UTF-8");
  response.setCharacterEncoding("UTF-8");

  String activityType = request.getParameter("activityType");

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
  ArrayList<String> logTypes = new ArrayList<>();

  try {
    //オブジェクトの代入
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

    //全てのlogtypeを取得
    sql = new StringBuffer();
    sql.append("select type from logtypes where deleteFlag = 0");

    rs = stmt.executeQuery(sql.toString());
    while(rs.next()){
      logTypes.add(rs.getString("type"));
    }

    //ページ内の検索を開始する。
    sql = new StringBuffer();
    sql.append("select type, text, logs.productID as productID, dateTime, image, products.name as name from logs inner join logtypes on logs.logtypeID = logtypes.logtypeID left join products on logs.productID = products.productID where logs.deleteFlag = 0 and logtypes.deleteFlag = 0");
    if(activityType != null) sql.append(" and type = " + activityType);

    rs = stmt.executeQuery(sql.toString());
    while(rs.next()){
      map = new HashMap<>();
      map.put("type", rs.getString("type"));
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

    <form action="logs.html" method="post" id="search-form">

      <div>
        <div class="search-row">
          <select name="searchmaker" id="serchmaker">
            <% for(int i = 0; i < logTypes.size(); i++) { %>
              <option><%=logTypes.get(i)%></option>
            <%}%>
            <option selected>すべて</option>
          </select>
          <label>
            <input type="date">
            から
          </label>
        </div>
        
        <div class="search-row">
          <select>
            <option hidden disabled selected value>商品を選択</option>
            <option>商品A</option>
            <option>商品B</option>
            <option>商品C</option>
          </select>
          <label>
            <input type="date">
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
      <form action="main.html" method="post">
          <button class="normal-button">戻る</button>
      </form>
    </div>

  </div>

  <% if(logs.size() == 0){ %>

    <h3>ログデータが取得できませんでした。</h3>

  <% } else { %>

    <div id="log-list">

      <% for(int i = 0; i < logs.size(); i++) { %>

        <div class="log-item order">
          <!-- check this again -->
          <div class="log-label"><%=logs.get(i).get("type")%></div>
          <div class="log-date"><%=logs.get(i).get("dateTime")%></div>
          <% if(logs.get(i).get("productID") != null){ %>
            <!--商品に関わるお知らせがほとんどなので基本的に画像を出す。出さなくていい場合はlog-labelだけでいいです。-->
            <a href="product-details.jsp?productID=<%=logs.get(i).get("productID")%>">
              <img src="images/<%=logs.get(i).get("image")%>" class="log-image" width="50" height="50" alt="<%=logs.get(i).get("name")%>">
            </a>
          <% } %>
          <div class="log-text"><% if(logs.get(i).get("productID") != null){ %><a href="product-details.jsp?productID=<%=logs.get(i).get("productID")%>"><%=logs.get(i).get("name")%></a><%}%><%=logs.get(i).get("text")%></div>
        </div>

      <% } %>

    </div>

  <% } %>

  <div class="back-button-holder">
    <form action="main.html" method="post">
        <button class="normal-button">戻る</button>
    </form>
  </div>

  <!--本来は複数のaタグにするか、スパンのテキストに応じてJavaScriptで検索開始-->
  <div id="page-selector-wrapper">
    <a href="logs.html">
      <p id="page-selector">1　<span>2</span></p>
    </a>
  </div>

  <script>
    //検索条件を設定する。
    let activityType = "<%=activityType%>";
    if(activityType == null){
      let activityTypeSelect = document.getElementById("serchmaker");
      activityTypeSelect.value = activityType;
    }
  </script>

</body>
</html>
