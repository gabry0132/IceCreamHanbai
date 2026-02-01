<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.time.LocalDate" %>
<%
    // 文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

//    String staffID = session.getAttribute("staffID");
//    String staffName = session.getAttribute("staffName");
//    String isAdmin = session.getAttribute("isAdmin");
    String staffID = "00";      //仮にシステムの登録だとします
    String staffName = "システム";      //仮にシステムの登録だとします
    boolean isAdmin = true;

    //商品詳細ページから来た場合：
    String startFromProductID = request.getParameter("startFromProductID");
    boolean shouldStartFromID = startFromProductID != null;
    String previousPage = request.getParameter("previousPage");
    if(previousPage == null) previousPage = "main.jsp";
    
    //ページング変数
    int numberOfPages = 1;
    int pageLimitOffset = 15;   //1ページに何件が表示されるか
    int selectedPage = 1;
    if(request.getParameter("targetPage") != null) selectedPage = Integer.parseInt(request.getParameter("targetPage"));
    selectedPage--; //オフセット計算に使うので -1にします

    //検索条件
    String productSearch = request.getParameter("productSearch");
    String staffSearch = request.getParameter("staffSearch");
    String startDateSuffix = " 00:00:00";
    String endDateSuffix = " 23:59:59";
    String searchStartDate = request.getParameter("searchStartDate");
    if(searchStartDate != null){
        if(searchStartDate.equals("")) searchStartDate = null;
    }
    String searchEndDate = request.getParameter("searchEndDate");
    if(searchEndDate != null){
        if(searchEndDate.equals("")) searchEndDate = null;
    }
    boolean searchArrivedOnly = request.getParameter("searchArrivedOnly") != null;
    boolean searchStoppedOnly = request.getParameter("searchStoppedOnly") != null;

    //発注開始確認画面から戻った時のパラメータ
    String productIDCancelledStart = request.getParameter("productIDCancelledStart"); //対象商品のIDです
    String quantityBoxesFromStart = request.getParameter("quantityBoxesFromStart");   //入力した箱数
    boolean returnFromStart = (productIDCancelledStart != null);

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

    HashMap<String,String> order = null;
    ArrayList<HashMap<String,String>> ordersList = new ArrayList<>();
    ArrayList<HashMap<String, String>> staffList = new ArrayList<>();
    ArrayList<HashMap<String, String>> productsList = new ArrayList<>();

    try {

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();
        
        //合計ページ数を先に取得します
        sql = new StringBuffer();
        sql.append("select count(orderID) as count from orders where deleteFlag = 0 ");
        if(searchArrivedOnly) sql.append(" and completed = 1 ");
        if(searchStoppedOnly) sql.append(" and stoppedFlag = 1 ");
        if(productSearch != null) sql.append(" and productID = " + productSearch);
        if(staffSearch != null) sql.append(" and initiator = '" + staffSearch + "' ");
        if(searchStartDate != null) sql.append(" and startDateTime > '" + searchStartDate + startDateSuffix + "' ");
        if(searchEndDate != null) sql.append(" and startDateTime < '" + searchEndDate + endDateSuffix + "' ");
        rs = stmt.executeQuery(sql.toString());

        if (rs.next()) {
            numberOfPages = rs.getInt("count") / pageLimitOffset;
            if(rs.getInt("count") % pageLimitOffset != 0) numberOfPages++;
        }

        //発注データ取得
        sql = new StringBuffer();
        sql.append("select o.orderID, o.productID, o.initiator, o.quantity, o.startDateTime, o.completed, o.stoppedFlag, ");
        sql.append("p.name as productName, p.image as productImage, p.unitPerBox, p.confirmDays as productConfirmDays, p.shippingDays as productShippingDays, s.name as staffName from orders as o ");
        sql.append("inner join products as p on o.productID = p.productID ");
        sql.append("inner join staff as s on o.initiator = s.staffID ");
        sql.append("where o.deleteFlag = 0 and p.deleteFlag = 0 and s.deleteFlag = 0 "); //削除されたスタックの発注は表示しないとします。
        if(searchArrivedOnly) sql.append(" and completed = 1 ");
        if(searchStoppedOnly) sql.append(" and stoppedFlag = 1 ");
        if(productSearch != null) sql.append(" and o.productID = " + productSearch);
        if(staffSearch != null) sql.append(" and initiator = '" + staffSearch + "' ");
        if(searchStartDate != null) sql.append(" and startDateTime > '" + searchStartDate + startDateSuffix + "' ");
        if(searchEndDate != null) sql.append(" and startDateTime < '" + searchEndDate + endDateSuffix + "' ");
        sql.append(" order by startDateTime desc limit " + pageLimitOffset + " offset " + (selectedPage * pageLimitOffset));

        rs = stmt.executeQuery(sql.toString());

        String timestampStr = null;
        Calendar todayCalendar = Calendar.getInstance();
        String orderStatus = null;
        String orderStatusJap = null;

        while(rs.next()){
            order = new HashMap<String,String>();
            order.put("orderID", rs.getString("orderID"));
            order.put("productID", rs.getString("productID"));
            order.put("initiator", rs.getString("initiator"));
            order.put("startDateTime", rs.getString("startDateTime"));
            order.put("completed", rs.getString("completed"));
            order.put("stoppedFlag", rs.getString("stoppedFlag"));
            order.put("productName", rs.getString("productName"));
            order.put("productImage", rs.getString("productImage"));
            order.put("unitPerBox", rs.getString("unitPerBox"));
            order.put("quantityBoxes", rs.getString("quantity"));
            order.put("quantityUnits", (rs.getInt("quantity") * rs.getInt("unitPerBox")) + "");
            order.put("staffName", rs.getString("staffName"));

            //発注のステータスを計算する
            timestampStr = rs.getString("startDateTime").split(" ")[0];
            Calendar orderStartedDate = Calendar.getInstance();
            orderStartedDate.set(Calendar.YEAR, Integer.parseInt(timestampStr.split("-")[0]));
            orderStartedDate.set(Calendar.MONTH, Integer.parseInt(timestampStr.split("-")[1]) - 1);
            orderStartedDate.set(Calendar.DATE, Integer.parseInt(timestampStr.split("-")[2]));

            Calendar orderConfirmedDate = (Calendar) orderStartedDate.clone();
            orderConfirmedDate.add(Calendar.DATE, rs.getInt("productConfirmDays"));
            Calendar orderArrivalDate = (Calendar) orderConfirmedDate.clone();
            orderArrivalDate.add(Calendar.DATE, rs.getInt("productShippingDays"));

            if(rs.getString("completed").equals("1")) {
                orderStatus = "arrived";
                orderStatusJap = "入荷済み";
            } else if(rs.getString("stoppedFlag").equals("1")){
                orderStatus = "stopped";
                orderStatusJap = "停止済み";
            } else {
                if(todayCalendar.before(orderConfirmedDate)) {
                    orderStatus = "confirming";
                    orderStatusJap = "発注確認中";
                } else {
                    orderStatus = "sending";
                    orderStatusJap = "配達中";
                }
            }

            order.put("orderStatus", orderStatus);
            order.put("orderStatusJap", orderStatusJap);

            ordersList.add(order);
        }

        //-----スタッフ一覧-----
        sql = new StringBuffer();
        sql.append("select staffID, name from staff where deleteFlag = 0");
        rs = stmt.executeQuery(sql.toString());
        while (rs.next()) {
            HashMap<String, String> map = new HashMap<>();
            map.put("staffID", rs.getString("staffID"));
            map.put("staffName", rs.getString("name"));
            staffList.add(map);
        }

        //-----商品一覧-----
        sql = new StringBuffer();
        sql.append("select productID, name, quantity, image from products");
        rs = stmt.executeQuery(sql.toString());

        while (rs.next()) {
            HashMap<String, String> map = new HashMap<>();
            map.put("productID", rs.getString("productID"));
            map.put("name", rs.getString("name"));
            map.put("image", rs.getString("image"));
            map.put("quantity", rs.getString("quantity"));
            productsList.add(map);
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
    <title>発注データ一覧</title>
    <link rel="stylesheet" type="text/css" href="css/orders.css">
</head>
<body>

<% if(ermsg != null){ %>

    <h4>エラーが発生しました。</h4>
    <p><%=ermsg%></p>

<% } else { %>

<% } %>

    <div id="everything-wrapper">

        <div id="top-text-holder">
            <h1>発注一覧</h1>
            <%if(isAdmin){%><span>管理者モード</span><%}%>
        </div>

        <div id="top-area-container">

            <form action="orders.jsp" method="post" id="search-form">

                <div id="search-params-container">

                    <div id="pulldown-menus-container">

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

                        <select id="staffSearch" name="staffSearch">
                            <option hidden disabled selected value>販売の人事</option>
                            <%
                                for(int i=0; i<staffList.size(); i++){
                            %>
                            <option value="<%= staffList.get(i).get("staffID") %>"><%= staffList.get(i).get("staffID") %> <%= staffList.get(i).get("staffName") %></option>
                            <%
                                }
                            %>
                        </select>

                    </div>

                    <div id="dates-menus-container">

                        <div class="date-row-wrapper">
                            <input type="date" name="searchStartDate" id="searchStartDate">
                            <p>から</p>
                        </div>
                        <div class="date-row-wrapper">
                            <input type="date" name="searchEndDate" id="searchEndDate">
                            <p>まで</p>
                        </div>

                    </div>

                    <div id="search-checkboxes-container">

                        <div>
                            <input type="checkbox" id="searchArrivedOnly" name="searchArrivedOnly">
                            <p>入荷済のみ</p>
                        </div>

                        <div>
                            <input type="checkbox" id="searchStoppedOnly" name="searchStoppedOnly">
                            <p>停止のみ</p>
                        </div>

                    </div>

                    <div id="search-buttons-holder">
                        <button class="submit">この条件で検索</button>
                        <button class="normal-button" id="reset-search" type="button">条件をクリア</button>
                    </div>

                </div>

            </form>

            <button class="normal-button" id="btn-start" type="button" onclick="openStartPopup()"><b>発注を<br>開始する</b></button>

        </div>

        <div class="back-button-holder">
            <form action="<%=previousPage%>" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

        <% if(!searchArrivedOnly && !searchStoppedOnly){ %>

            <div id="selectDisplayFilters-holder">

                <input type="checkbox" class="displayFilterCheckbox" id="showConfirmingCheckbox" checked>
                <p class="displayFilterExplanationP">確認中を表示する</p>

                <input type="checkbox" class="displayFilterCheckbox" id="showSendingCheckbox" checked>
                <p class="displayFilterExplanationP">配達中を表示する</p>

                <input type="checkbox" class="displayFilterCheckbox" id="showArrivedCheckbox" checked>
                <p class="displayFilterExplanationP">入荷済を表示する</p>

                <input type="checkbox" class="displayFilterCheckbox" id="showStoppedCheckbox" checked>
                <p class="displayFilterExplanationP">停止済を表示する</p>

            </div>

        <% } %>

        <div id="orders-holder">

            <%
                if(!ordersList.isEmpty()){
                    for(int i=0; i < ordersList.size(); i++){
            %>
            <div class="order-box <%=ordersList.get(i).get("orderStatus")%>">
                <div class="order-image-txt-holder">
                    <a href="product-details.jsp?productID=<%=ordersList.get(i).get("productID")%>&previousPage=orders.jsp" class="image-wrapper-anchor">
                        <img class="image" src="<%=request.getContextPath()%>/images/<%=ordersList.get(i).get("productImage")%>" width="100" height="100" alt="<%=ordersList.get(i).get("productName")%>">
                    </a>
                    <p class="order-text"><%if(ordersList.get(i).get("orderStatus").equals("stopped")){%><s><%}%><b><%= ordersList.get(i).get("startDateTime") %></b>に <a href="product-details.jsp?productID=<%=ordersList.get(i).get("productID")%>&previousPage=orders.jsp" class="product-name-anchor"><%= ordersList.get(i).get("productName") %></a>が <%= ordersList.get(i).get("quantityBoxes") %>箱 （<%=ordersList.get(i).get("quantityUnits")%>個） 発注されました。(<%= ordersList.get(i).get("staffName") %>より)<%if(ordersList.get(i).get("orderStatus").equals("stopped")){%></s><%}%></p>
                </div>
                <% if(isAdmin){ %>
                <div class="order-status-box">
                    <p class="orderStatusText"><%=ordersList.get(i).get("orderStatusJap")%></p>
                    <% if(ordersList.get(i).get("orderStatus").equals("confirming") && isAdmin){ %>
                        <form action="order-confirm.jsp" method="post" id="stopOrder-form">
                            <input type="hidden" name="stopOrderID" value="<%=ordersList.get(i).get("orderID")%>">
                            <input type="hidden" name="registerType" value="stop">
                            <button type="submit" class="edit-button" id="stopOrderBtn">停止する</button>
                        </form>
                    <% } %>
                </div>
                <% } %>
            </div>
            <%
                    }
                } else {
            %>

                    <h4>データが見つかりませんでした。</h4>

            <% } %>

        </div>

        <div class="back-button-holder">
            <form action="<%=previousPage%>" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

        <div id="page-selector-wrapper">

            <% for (int i = 1; i <= numberOfPages; i++) { %>
            <span class="page-number-span <% if(i - 1  == selectedPage){ %> current-page <% } %>" onclick="reloadOnPage(<%=i%>)"><%=i%></span>
            <% } %>

        </div>

        <%--        ページングのための非表示フォーム--%>
        <form action="orders.jsp" method="post" id="pageingSearch">
            <% if(productSearch != null){ %>     <input type="hidden" name="productSearch" value="<%=productSearch%>">      <% } %>
            <% if(staffSearch != null){ %>       <input type="hidden" name="staffSearch" value="<%=staffSearch%>">          <% } %>
            <% if(searchStartDate != null){ %>   <input type="hidden" name="searchStartDate" value="<%=searchStartDate%>">  <% } %>
            <% if(searchEndDate != null){ %>     <input type="hidden" name="searchEndDate" value="<%=searchEndDate%>">      <% } %>
            <% if(searchArrivedOnly){ %>         <input type="hidden" name="searchArrivedOnly" value="true">                <% } %>
            <% if(searchStoppedOnly){ %>         <input type="hidden" name="searchStoppedOnly" value="true">                <% } %>
            <input type="hidden" name="targetPage" id="targetPage">
        </form>

    </div>

    <div id="black-background">

    </div>

    <!-- 発注開始ポップアップ -->
    <form action="order-confirm.jsp" method="post" id="start-form">

        <div id="start-popup">

            <div id="start-title-section">
                <h2>発注を開始する</h2>
                <p class="close" onclick="closeAllPopups()">✖</p>
            </div>

            <div id="start-pop-contents">

                <div id="start-top-section">
                    <img class="image" id="start-image" src="<%=request.getContextPath()%>/images/placeholder.png" width="200" height="200" alt="アイスを選択してください">
                    <select name="productID" id="product">
                        <option hidden disabled selected value>商品を選択</option>
                        <!--動的に画像を変更する-->
                        <%
                            for(int i=0; i < productsList.size(); i++){
                        %>
                        <option value="<%= productsList.get(i).get("productID") %>" <% if(returnFromStart){ %><% if(productIDCancelledStart.equals(productsList.get(i).get("productID"))){%> selected <% } } %>><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
                        <%
                            }
                        %>
                    </select>
                </div>

                <div id="start-middle-section">
                    <table>
                        <tr>
                            <td class="table-left-side">発注箱数</td>
                            <td><input type="number" id="orderQuantityBoxes" name="orderQuantityBoxes" value="1" min="1" max="999" disabled></td>
                        </tr>
                        <tr>
                            <td colspan="2" id="orderStartQuantityPriceMessage"></td>
                        </tr>
                        <tr>
                            <td>発注確認期間</td>
                            <td id="orderStartCheckingTimespan"></td>
                        </tr>
                        <tr>
                            <td>出荷後配達期間</td>
                            <td id="orderStartDeliveryTimespan"></td>
                        </tr>
                        <tr>
                            <td>入荷予定日</td>
                            <td id="orderStartExpectedDeliveryDate"></td>
                        </tr>
                    </table>
                </div>

                <input type="hidden" name="registerType" value="start">

                <div id="start-buttons-holder">
                    <button type="button" class="normal-button" onclick="closeAllPopups()">キャンセル</button>
                    <button type="submit" id="startOrderSubmitBtn" class="normal-button" disabled>発注開始</button>
                </div>
            </div>
        </div>

    </form>

<%--    <!-- 発注停止ポップアップ -->--%>
<%--    <form action="order-confirm.jsp" method="post" id="stop-form">--%>

<%--        <div id="stop-popup">--%>

<%--            <div id="stop-title-section">--%>
<%--                <h2>発注を開始する</h2>--%>
<%--                <p class="close" onclick="closeAllPopups()">✖</p>--%>
<%--            </div>--%>

<%--            <div id="stop-pop-contents">--%>

<%--                <div id="stop-top-section">--%>
<%--                    <img class="image" id="stop-image" src="<%=request.getContextPath()%>/images/placeholder.png" width="200" height="200" alt="アイスを選択してください">--%>
<%--                    <div id="stop-top-text-holder">--%>
<%--                        <p id="stopProductID">00001</p>--%>
<%--                        <p id="stopProductName">ガリガリ君</p>--%>
<%--                    </div>--%>
<%--                </div>--%>

<%--                <div id="stop-middle-section">--%>
<%--                    <table>--%>
<%--                        <tr>--%>
<%--                            <td class="table-left-side">発注箱数</td>--%>
<%--                            <!-- keep empty and write in js -->--%>
<%--                            <td id="orderStopQuantityBoxes">3箱</td>--%>

<%--                        </tr>--%>
<%--                        <tr>--%>
<%--                            <!-- keep empty and write in js -->--%>
<%--                            <!-- example of when getting 3 boxes -->--%>
<%--                            <td colspan="2" id="orderStopQuantityPriceMessage">単位 12個 - 単価 60円 -> 合計 36個（1,800円）</td>--%>
<%--                        </tr>--%>
<%--                        <tr>--%>
<%--                            <td>発注確認期間</td>--%>
<%--                            <!-- fetch from js, 日 to be added via js -->--%>
<%--                            <td id="orderStopCheckingTimespan">1日</td>--%>
<%--                        </tr>--%>
<%--                        <tr>--%>
<%--                            <td>出荷後配達期間</td>--%>
<%--                            <!-- fetch from js, 日 to be added via js -->--%>
<%--                            <td id="orderStopDeliveryTimespan">2日</td>--%>
<%--                        </tr>--%>
<%--                        <tr>--%>
<%--                            <td>入荷予定日</td>--%>
<%--                            <!-- calculate based on today + the 2 rows above -->--%>
<%--                            <td id="orderStopExpectedDeliveryDate">2026年 3月 12日</td>--%>
<%--                        </tr>--%>
<%--                    </table>--%>
<%--                </div>--%>

<%--                <input type="hidden" name="registerType" value="stop">--%>

<%--                <div id="stop-buttons-holder">--%>
<%--                    <button type="button" class="normal-button" onclick="closeAllPopups()">キャンセル</button>--%>
<%--                    <button type="submit" class="normal-button">発注開始</button>--%>
<%--                </div>--%>
<%--            </div>--%>
<%--        </div>--%>

<%--    </form>--%>

    <script>
        let blackBackground = document.getElementById("black-background");

        //表示モードのフィルター
        let showConfirmingCheckbox = document.getElementById("showConfirmingCheckbox");
        let showSendingCheckbox = document.getElementById("showSendingCheckbox");
        let showArrivedCheckbox = document.getElementById("showArrivedCheckbox");
        let showStoppedCheckbox = document.getElementById("showStoppedCheckbox");

        //開始ポップアップ変数
        let startPopup = document.getElementById("start-popup");
        let startOrderSubmitBtn = document.getElementById("startOrderSubmitBtn");
        let startImage = document.getElementById("start-image");
        let orderQuantityBoxesInput = document.getElementById("orderQuantityBoxes");
        let orderStartQuantityPriceMessage = document.getElementById("orderStartQuantityPriceMessage");
        let orderStartCheckingTimespan = document.getElementById("orderStartCheckingTimespan");
        let orderStartDeliveryTimespan = document.getElementById("orderStartDeliveryTimespan");
        let orderStartExpectedDeliveryDate = document.getElementById("orderStartExpectedDeliveryDate");
        let lastRecordedUnitPerBox = 0;
        let lastRecordedPurchaseCost = 0;

        //停止ポップアップ変数
        let stopPopup = document.getElementById("stop-popup");

        //イベントリスナーの設定
        blackBackground.addEventListener("click", closeAllPopups);
        document.getElementById("reset-search").addEventListener("click", () => {
            document.getElementById("search-form").reset();
            document.getElementById("searchArrivedOnly").checked = false;
            document.getElementById("searchStoppedOnly").checked = false;
        })
        orderQuantityBoxesInput.addEventListener("input", (e) => {
            composeOrderStartQuantityPriceMessage(lastRecordedUnitPerBox, lastRecordedPurchaseCost);
        })
        if(showConfirmingCheckbox) showConfirmingCheckbox.addEventListener("input", recalculateDisplayFilters);
        if(showSendingCheckbox) showSendingCheckbox.addEventListener("input", recalculateDisplayFilters);
        if(showArrivedCheckbox) showArrivedCheckbox.addEventListener("input", recalculateDisplayFilters);
        if(showStoppedCheckbox) showStoppedCheckbox.addEventListener("input", recalculateDisplayFilters);

        //検索条件があればここで設定します。
        <% if(productSearch != null){ %> document.getElementById("productSearch").value = "<%=productSearch%>" <% } %>
        <% if(staffSearch != null){ %> document.getElementById("staffSearch").value = "<%=staffSearch%>" <% } %>
        <% if(searchStartDate != null){ %> document.getElementById("searchStartDate").value = "<%=searchStartDate%>" <% } %>
        <% if(searchEndDate != null){ %> document.getElementById("searchEndDate").value = "<%=searchEndDate%>" <% } %>
        <% if(searchArrivedOnly){ %> document.getElementById("searchArrivedOnly").checked = true <%}%>
        <% if(searchStoppedOnly){ %> document.getElementById("searchStoppedOnly").checked = true <%}%>

        document.getElementById("product").addEventListener("input", (e) => {
            let productID = e.target.value;
            setUpStartDiv(productID);
        });

        if(<%=returnFromStart%>){
            //商品の切り替えはJava内で行っています。対象オプションに selected を追加しています。
            orderQuantityBoxesInput.value = <%=quantityBoxesFromStart%>;
            let productSelect = document.getElementById("product")
            productSelect.dispatchEvent(new Event("input"));
            setUpStartDiv();
            openStartPopup();
        }

        if(<%=shouldStartFromID%>){
            let productSelect = document.getElementById("product");
            productSelect.value = "<%=startFromProductID%>";
            productSelect.dispatchEvent(new Event("input"));
            setUpStartDiv();
            openStartPopup();
        }

        function recalculateDisplayFilters() {
            let showConfirming = Boolean(document.getElementById("showConfirmingCheckbox").checked);
            let showSending = Boolean(document.getElementById("showSendingCheckbox").checked);
            let showArrived = Boolean(document.getElementById("showArrivedCheckbox").checked);
            let showStopped = Boolean(document.getElementById("showStoppedCheckbox").checked);

            let orderBoxes = Array.from(document.getElementsByClassName("order-box"));
            orderBoxes.forEach((orderBox) => {
                let toBeShown = false;
                if(orderBox.classList.contains("arrived") && showArrived)               toBeShown = true;
                else if(orderBox.classList.contains("confirming") && showConfirming)    toBeShown = true;
                else if(orderBox.classList.contains("sending") && showSending)          toBeShown = true;
                else if(orderBox.classList.contains("stopped") && showStopped)          toBeShown = true;

                if(toBeShown) orderBox.style.display = "flex";
                else orderBox.style.display = "none";
            })
        }

        function setUpStartDiv(productID){
            let url = "http://localhost:8080/IceCreamHanbai_war_exploded/getProductDetails?productID=" + productID;
            let product = null;
            fetch(url)
                .then(res => res.json())
                .then(json => {
                    if(json.product){   //取得成功
                        product = json.product;

                        lastRecordedUnitPerBox = Number(product.unitPerBox);
                        lastRecordedPurchaseCost = Number(product.purchaseCost);

                        startImage.src = "<%=request.getContextPath()%>/images/" + product.image;
                        orderQuantityBoxesInput.disabled = false;
                        startOrderSubmitBtn.disabled = false;
                        composeOrderStartQuantityPriceMessage(Number(product.unitPerBox), Number(product.purchaseCost));
                        orderStartCheckingTimespan.innerHTML = product.confirmDays + "日";
                        orderStartDeliveryTimespan.innerHTML = product.shippingDays + "日";
                        composeOrderStartExpectedDeliveryDate(Number(product.confirmDays) + Number(product.shippingDays));
                    }
                });
        }

        function composeOrderStartQuantityPriceMessage(unitPerBox, purchaseCost){
            let orderQuantityBoxes = Number(orderQuantityBoxesInput.value);
            let max = orderQuantityBoxesInput.max;
            if(orderQuantityBoxes > max) {
                orderQuantityBoxesInput.value = max;
                orderQuantityBoxes = max;
            }
            let message = "単位 " + unitPerBox + " 個 × 単価 " + purchaseCost + "円 ＝ 合計 " + formatCommaEveryThreeDigits(unitPerBox * orderQuantityBoxes) + "個（" + formatCommaEveryThreeDigits(purchaseCost * unitPerBox * orderQuantityBoxes) + "円）";
            orderStartQuantityPriceMessage.innerHTML = message;
        }

        function formatCommaEveryThreeDigits(price){
            price += "";
            if (price.length < 4) return price;
            let newPrice = "";
            for (let i = 0; i <= price.length; i++) {
                if(i != 0 && i % 4 == 0) newPrice = "," + newPrice;
                newPrice = price.charAt(price.length - i) + newPrice;
            }
            return newPrice;
        }

        function composeOrderStartExpectedDeliveryDate(daysToAdd){
            let currentDate = new Date();
            let arrivalDate = addDays(currentDate, daysToAdd);
            orderStartExpectedDeliveryDate.innerHTML = arrivalDate.getFullYear() + "年 " + (arrivalDate.getMonth() + 1) + "月 " + arrivalDate.getDate() + "日";
        }

        function addDays(date, days) {
            var result = new Date(date);
            result.setDate(result.getDate() + days);
            return result;
        }

        //発注開始ポップアップを開く
        function openStartPopup(){
            blackBackground.style.display = "flex";
            startPopup.style.display = "flex";
        }

        //発注停止ポップアップを開く
        function openStopPopup(){
            blackBackground.style.display = "flex";
            stopPopup.style.display = "flex";
        }

        function closeAllPopups(){
            blackBackground.style.display = "none";
            startPopup.style.display = "none";
            stopPopup.style.display = "none";
            cleanPopups();
        }

        function cleanPopups() {
            //開始ポップアップ
            document.getElementById("product").selectedIndex = 0;
            startImage.src = "<%=request.getContextPath()%>/images/placeholder.png";
            orderQuantityBoxesInput.value = 1;
            orderQuantityBoxesInput.disabled = true;
            startOrderSubmitBtn.disabled = true;
            orderStartQuantityPriceMessage.innerHTML = "";
            orderStartCheckingTimespan.innerHTML = "";
            orderStartDeliveryTimespan.innerHTML = "";
            orderStartExpectedDeliveryDate.innerHTML = "";
        }

        function reloadOnPage(targetPage){
            document.getElementById("targetPage").value = Number(targetPage);
            document.getElementById("pageingSearch").submit();
        }

    </script>

</body>

</html>

