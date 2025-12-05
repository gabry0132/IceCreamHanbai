<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
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
    String createFromProductID = request.getParameter("createFromProductID");
    boolean shouldCreateFromID = createFromProductID != null;
    String previousPage = request.getParameter("previousPage");
    if(previousPage == null) previousPage = "main.jsp";

    //ページング変数
    int numberOfPages = 1;
    int pageLimitOffset = 15;   //1ページに何件が表示されるか
    int selectedPage = 1;
    if(request.getParameter("selectedPage") != null) selectedPage = Integer.parseInt(request.getParameter("selectedPage"));
    selectedPage--; //オフセット計算に使うので -1にします

    //検索条件                                      <<<<<<<<<<<<<<<<<<<<<<<unfinished
    String productSearch = request.getParameter("productSearch");
    String staffSearch = request.getParameter("staffSearch");
    String searchStartDate = request.getParameter("searchStartDate");
    if(searchStartDate != null){
        if(searchStartDate.equals("")) searchStartDate = null;
    }
    String searchEndDate = request.getParameter("searchEndDate");
    if(searchEndDate != null){
        if(searchEndDate.equals("")) searchEndDate = null;
    }

    //売上データ作成から戻った時にもらうパラメータ
    String productIDCancelledCreate = request.getParameter("productIDCancelledCreate"); //対象商品のIDです
    String saleTimeSelector = request.getParameter("sale_time_selector");
//    String saleTime = request.getParameter("sale_time");          //戻っても自動設定させません
    String saleQuantity = request.getParameter("saleQuantity");
    boolean returnFromCreate = (productIDCancelledCreate != null);

    // データベース接続情報
    String USER = "root";
    String PASSWORD = "root";
    String URL = "jdbc:mysql://localhost/icehanbaikanri";
    String DRIVER = "com.mysql.jdbc.Driver";
    String sql = "";

    // エラーメッセージ格納用
    String ERMSG = null;

    // 結果格納用リスト
    ArrayList<HashMap<String, String>> salesList = new ArrayList<>();
    ArrayList<HashMap<String, String>> staffList = new ArrayList<>();
    ArrayList<HashMap<String, String>> productsList = new ArrayList<>();

    try {
        // JDBCドライバのロード
        Class.forName(DRIVER);

        //合計ページ数を取得します。
        sql = "select count(salesID) as count from sales where deleteFlag = 0 ";
        if(productSearch != null) sql += " and s.productID = " + productSearch;
        if(staffSearch != null) sql += " and s.staffID = " + staffSearch;
        if(searchStartDate != null) sql += " and s.dateTime > " + searchStartDate;
        if(searchEndDate != null) sql += " and s.dateTime < " + searchEndDate;
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("select count(salesID) as count from sales where deleteFlag = 0 ")
        ) {

            if (rs.next()) {
                numberOfPages = (rs.getInt("count") / pageLimitOffset) + 1;
            }
        }

        //売上のクエリ
        sql = "SELECT p.productID, p.name, p.image, s.salesID, s.dateTime, s.quantity, st.staffID, st.name AS staffName FROM Products p JOIN Sales s ON p.productID = s.productID JOIN Staff st ON s.staffID = st.staffID where s.deleteFlag = 0 ";
        if(productSearch != null) sql += " and s.productID = " + productSearch;
        if(staffSearch != null) sql += " and s.staffID = '" + staffSearch + "' ";
        if(searchStartDate != null) sql += " and s.dateTime > '" + searchStartDate + "' ";
        if(searchEndDate != null) sql += " and s.dateTime < '" + searchEndDate + "' ";
        sql += " order by dateTime desc limit " + pageLimitOffset + " offset " + (selectedPage * pageLimitOffset);

        //-----売上一覧-----
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(sql)
        ) {

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("salesID", rs.getString("salesID"));
                map.put("productID", rs.getString("productID"));
                map.put("productName", rs.getString("name"));
                map.put("imageFileName", rs.getString("image"));
                map.put("dateTime", rs.getString("dateTime").substring(0, rs.getString("dateTime").lastIndexOf(".")));    //なぜか秒は17.0の形で来ます。「.0」を捨てます。
                map.put("quantity", rs.getString("quantity"));
                map.put("staffID", rs.getString("staffID"));
                map.put("staffName", rs.getString("staffName"));
                salesList.add(map);
            }
        }

        //-----スタッフ一覧-----
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("select staffID, name from staff where deleteFlag = 0;")
        ) {

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("staffID", rs.getString("staffID"));
                map.put("staffName", rs.getString("name"));
                staffList.add(map);
            }
        }

        //-----商品一覧-----
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("select productID, name, quantity, image from products;")
        ) {

            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("productID", rs.getString("productID"));
                map.put("name", rs.getString("name"));
                map.put("image", rs.getString("image"));
                map.put("quantity", rs.getString("quantity"));
                productsList.add(map);
            }
        }

    } catch (Exception e) {
        ERMSG = e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>売上データ一覧</title>
    <link rel="stylesheet" href="css/sales.css">
</head>
<body>

<% if(ERMSG != null){ %>

    <h4>エラーが発生しました。</h4>
    <p><%=ERMSG%></p>

<% } else { %>

    <div id="everything-wrapper">
        
        <div id="top-text-holder">
            <h1>売上データ一覧</h1>
            <%if(isAdmin){%><span>管理者モード</span><%}%>
        </div>

        <div id="top-buttons">
            <form action="readFromFile.jsp" method="post">
                <button class="normal-button">ファイルから読み込み</button>
            </form>
            <div id="grouping-toggle-button">
                <p id="grouping-toggle-button-text">集計オプション</p>
                <img id="grouping-toggle-button-image" src="<%=request.getContextPath()%>/images/upDownArrow.png" width="30" height="30" alt="矢印">
            </div>
        </div>

        <div id="groupingDiv">

            <div id="groupingSettingsDiv">

                <div class="groupingSettingsRow">

                    <p class="groupingSettingsRowIntro">一般集計</p>

                    <div class="optionsInRowWrapper ">

                        <div class="groupingOptionHolder" id="dailyTot-grOpt">
                            <p class="groupingOptionIntro">今日の</p>

                            <div id="dailyTot-grOpt-radioHolders">
                                <input type="radio" name="dailyTotCalculationMode" value="sales" checked>個数
                                <br>
                                <input type="radio" name="dailyTotCalculationMode" value="profits">利益
                            </div>
                            
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="dailyTot-btn">確認</button>
                            </div>
                        </div>
                        
                        <div class="groupingOptionHolder" id="weeklyTot-grOpt">
                            <p class="groupingOptionIntro">今週の</p>

                            <div id="weeklyTot-grOpt-radioHolders">
                                <input type="radio" name="weeklyTotCalculationMode" value="sales" checked>個数
                                <br>
                                <input type="radio" name="weeklyTotCalculationMode" value="profits">利益
                            </div>
                            
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="weeklyTot-btn">確認</button>
                            </div>
                        </div>
                        
                        <div class="groupingOptionHolder" id="monthlyTot-grOpt">
                            <p class="groupingOptionIntro">今月の</p>

                            <div id="monthlyTot-grOpt-radioHolders">
                                <input type="radio" name="monthlyTotCalculationMode" value="sales" checked>個数
                                <br>
                                <input type="radio" name="monthlyTotCalculationMode" value="profits">利益
                            </div>
                            
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="monthlyTot-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="yearlyTot-grOpt">
                            <p class="groupingOptionIntro">今年の</p>

                            <div id="yearlyTot-grOpt-radioHolders">
                                <input type="radio" name="yearlyTotCalculationMode" value="sales" checked>個数
                                <br>
                                <input type="radio" name="yearlyTotCalculationMode" value="profits">利益
                            </div>
                            
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="yearlyTot-btn">確認</button>
                            </div>
                        </div>

                    </div>

                </div>

                <div class="groupingSettingsRow">

                    <p class="groupingSettingsRowIntro">売上ランキング</p>

                    <div class="optionsInRowWrapper  innerDivsMarginBottomAuto">

                        <div class="groupingOptionHolder" id="TopTot-grOpt">
                            <p class="groupingOptionIntro">全体的 トップ</p>

                            <select name="itemLimit" id="topTotItemLimit">
                                <option value="5">5</option>
                                <option value="10" selected>10</option>
                                <option value="15">15</option>
                                <option value="20">20</option>
                                <option value="30">30</option>
                                <option value="50">50</option>
                                <option value="unlimited">無制限</option>
                            </select> 商品
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="topTot-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="yearTopTen-grOpt">
                            <p class="groupingOptionIntro">年 トップ10</p>

                            <select class="recentYearsSelect" name="yearTopTen" id="yearTopTen"></select> 年
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="yearTopTen-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="periodTopTen-grOpt">
                            <p class="groupingOptionIntro">期間 トップ10</p>

                            <div class="periodGroupingOption-periodHolder">

                                <input type="checkbox" name="periodTopTen-DetailedCheckbox" id="periodTopTen-DetailedCheckbox">詳細指定

                                <div id="periodTopTen-NONDetailedSearchParams">
                                    <div>
                                        <select class="recentYearsSelect" name="periodTopTen-year" id="periodTopTen-year"></select> 年　
                                    </div>
                                    <div>
                                        <select class="allMonthsSelect" name="periodTopTen-month" id="periodTopTen-month"></select> 月
                                    </div>
                                </div>

                                <div id="periodTopTen-DetailedSearchParams">
                                    <div>
                                        <input type="date" name="periodTopTen-startDate" id="periodTopTen-startDate"> から
                                    </div>
                                    <div>
                                        <input type="date" name="periodTopTen-endDate" id="periodTopTen-endDate"> まで
                                    </div>
                                </div>

                            </div>

                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="periodTopTen-btn">確認</button>
                            </div>

                        </div>

                    </div>

                </div>

                <div class="groupingSettingsRow">

                    <div class="optionsInRowWrapper  innerDivsMarginBottomAuto">

                        <div class="groupingOptionHolder" id="worstTot-grOpt">
                            <p class="groupingOptionIntro">全体的 ワースト</p>

                            <select name="itemLimit" id="worstTotItemLimit">
                                <option value="5">5</option>
                                <option value="10" selected>10</option>
                                <option value="15">15</option>
                                <option value="20">20</option>
                                <option value="30">30</option>
                                <option value="50">50</option>
                                <option value="unlimited">無制限</option>
                            </select> 商品
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="worstTot-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="yearWorstTen-grOpt">
                            <p class="groupingOptionIntro">年 ワースト10</p>

                            <select class="recentYearsSelect" name="yearWorstTen" id="yearWorstTen"></select> 年
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="yearWorstTen-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="periodWorstTen-grOpt">
                            <p class="groupingOptionIntro">期間 ワースト10</p>

                            <div class="periodGroupingOption-periodHolder">

                                <input type="checkbox" name="periodWorstTen-DetailedCheckbox" id="periodWorstTen-DetailedCheckbox">詳細指定

                                <div id="periodWorstTen-NONDetailedSearchParams">
                                    <div>
                                        <select class="recentYearsSelect" name="periodWorstTen-year" id="periodWorstTen-year"></select> 年　
                                    </div>
                                    <div>
                                        <select class="allMonthsSelect" name="periodWorstTen-month" id="periodWorstTen-month"></select> 月
                                    </div>
                                </div>

                                <div id="periodWorstTen-DetailedSearchParams">
                                    <div>
                                        <input type="date" name="periodWorstTen-startDate" id="periodWorstTen-startDate"> から
                                    </div>
                                    <div>
                                        <input type="date" name="periodWorstTen-endDate" id="periodWorstTen-endDate"> まで
                                    </div>
                                </div>

                            </div>

                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="periodWorstTen-btn">確認</button>
                            </div>

                        </div>
                    </div>

                </div>

                <div class="groupingSettingsRow">

                    <p class="groupingSettingsRowIntro">割合 売上高チャート</p>

                    <div class="optionsInRowWrapper">

                        <div class="groupingOptionHolder" id="percentageSales-grOpt">
                            <p class="groupingOptionIntro">売上個数</p>

                            <select class="recentYearsSelect" name="percentageSalesYear" id="percentageSalesYear"></select> 年
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="percentageSales-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="percentageProfits-grOpt">
                            <p class="groupingOptionIntro">利益</p>

                            <select class="recentYearsSelect" name="percentageProfitsYear" id="percentageProfitsYear"></select> 年
                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="percentageProfits-btn">確認</button>
                            </div>
                        </div>

                    </div>

                </div>


                <div class="groupingSettingsRow">

                    <p class="groupingSettingsRowIntro">販売動向</p>

                    <div class="optionsInRowWrapper">

                        <div class="groupingOptionHolder" id="compareGeneral-grOpt">

                            <p class="groupingOptionIntro">全体的確認・売上個数</p>

                            <div id="compareGeneral-grOpt-radioHolders">
                                <input type="radio" name="compareGeneralTimeFrame" value="6" checked>6ヶ月間
                                <input type="radio" name="compareGeneralTimeFrame" value="12">1年間
                            </div>

                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="compareGeneral-btn">確認</button>
                            </div>
                        </div>

                        <div class="groupingOptionHolder" id="compareGeneralSales-grOpt">

                            <p class="groupingOptionIntro">全体的確認・利益</p>

                            <div id="compareGeneralSales-grOpt-radioHolders">
                                <input type="radio" name="compareGeneralSalesTimeFrame" value="6" checked>6ヶ月間
                                <input type="radio" name="compareGeneralSalesTimeFrame" value="12">1年間
                            </div>

                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="compareGeneralSales-btn">確認</button>
                            </div>
                        </div>

                    </div>

                </div>

                <div class="groupingSettingsRow">

                    <div class="optionsInRowWrapper">

                        <div class="groupingOptionHolder" id="compare-grOpt">
                            <p class="groupingOptionIntro">動向確認・商品比較</p>

                            <div class="compareOptionSelectionRow">
                                <select class="productToBeComparedSelect" name="productToBeCompared1" id="productToBeCompared1">
                                    <option hidden disabled selected value>商品を選択</option>
                                    <% for(int i=0; i<productsList.size(); i++){ %>
                                        <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
                                    <% } %>
                                </select>　　　　

                                <select class="productToBeComparedSelect" name="productToBeCompared2" id="productToBeCompared2">
                                    <option hidden disabled selected value>商品を選択</option>
                                    <% for(int i=0; i<productsList.size(); i++){ %>
                                        <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
                                    <% } %>
                                </select>（任意）
                            </div>

                            <div class="compareOptionSelectionRow">
                                <select class="productToBeComparedSelect" name="productToBeCompared3" id="productToBeCompared3">
                                    <option hidden disabled selected value>商品を選択</option>
                                    <% for(int i=0; i<productsList.size(); i++){ %>
                                        <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
                                    <% } %>
                                </select>（任意）

                                <select class="productToBeComparedSelect" name="productToBeCompared4" id="productToBeCompared4">
                                    <option hidden disabled selected value>商品を選択</option>
                                    <% for(int i=0; i<productsList.size(); i++){ %>
                                        <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
                                    <% } %>
                                </select>（任意）
                            </div>

                            <div id="compare-grOpt-radioHolders">
                                <input type="radio" name="compareTimeFrame" value="6" checked>6ヶ月間
                                <input type="radio" name="compareTimeFrame" value="12">1年間
                            </div>

                            <div class="groupingOption-button-holder">
                                <button class="groupingOption-button" id="clear-compare-btn">クリア</button>
                                <button class="groupingOption-button" id="compare-btn">確認</button>
                            </div>
                        </div>

                    </div>

                </div>


            </div>

            <!-- fetchの結果をここに表示する -->
            <div id="groupingResultsDiv">
                <p id="groupingResultPlaceholder">集計オプションを選んでください</p>
                <div id="fullScreenCanvasButtonHolder">
                    <img title="全画面へ" src="<%=request.getContextPath()%>/images/fullScreen-icon.png" width="32" height="32" alt="全画面に切り替え">
                </div>
                <canvas id="smallCanvas"></canvas>
            </div>

            <div id="fullscreenChartDiv">
                <canvas id="fullScreenCanvas"></canvas>
                <div id="closeFullScreenCanvas">✖</div>
            </div>

        </div>

        <div id="top-area-container">

            <form action="sales.jsp" method="post" id="search-form">
                
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
                    
                    <div id="search-buttons-holder">
                        <button class="submit">この条件で検索</button>
                        <button class="normal-button" id="reset-search" type="reset">条件をクリア</button>
                    </div>
                    
                </div>

            </form>
                
            <button class="normal-button" id="btn-add" type="button" onclick="openAddPopup()"><b>売上データを<br>作成する</b></button>

        </div>

        <div class="back-button-holder">
            <form action="<%=previousPage%>" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

        <div id="sales-holder">
<%
            if(!salesList.isEmpty()){
                for(int i=0; i < salesList.size(); i++){
%>
                    <div class="sale-box">
                        <div class="sale-image-txt-holder">
                            <a href="product-details.jsp?productID=<%=salesList.get(i).get("productID")%>&previousPage=sales.jsp" class="image-wrapper-anchor">
                                <img class="image" src="<%=request.getContextPath()%>/images/<%=salesList.get(i).get("imageFileName")%>" width="100" height="100" alt="<%=salesList.get(i).get("productName")%>">
                            </a>
                            <p class="sale-text"><b><%= salesList.get(i).get("dateTime") %></b>に <a href="product-details.jsp?productID=<%=salesList.get(i).get("productID")%>&previousPage=sales.jsp" class="product-name-anchor"><%= salesList.get(i).get("productName") %></a>が <%= salesList.get(i).get("quantity") %>個 販売されました。(<%= salesList.get(i).get("staffName") %>より)</p>
                        </div>
                        <% if(isAdmin){ %>
                            <div class="sale-button-box">
                                <button type="button" class="edit-button" onclick="openEditPopup(<%=salesList.get(i).get("salesID")%>)">修正</button>
                                <form action="sales-confirm.jsp" method="post" class="deleteForm">
                                    <input type="hidden" name="registerType" value="delete">
                                    <input type="hidden" name="saleID" value="<%=salesList.get(i).get("salesID")%>">
                                    <input type="hidden" name="productID" value="<%=salesList.get(i).get("productID")%>">
                                    <button type="submit" class="delete-button">削除</button>
                                </form>
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
        <form action="sales.jsp" method="post" id="pageingSearch">
            <% if(productSearch != null){ %>     <input type="hidden" name="productSearch" value="<%=productSearch%>">      <% } %>
            <% if(staffSearch != null){ %>       <input type="hidden" name="staffSearch" value="<%=staffSearch%>">          <% } %>
            <% if(searchStartDate != null){ %>   <input type="hidden" name="searchStartDate" value="<%=searchStartDate%>">  <% } %>
            <% if(searchEndDate != null){ %>     <input type="hidden" name="searchEndDate" value="<%=searchEndDate%>">      <% } %>
            <input type="hidden" name="targetPage" id="targetPage">
        </form>

    </div>

    <div id="black-background">

    </div>

    <!-- 売上データ追加 -->
    <form action="sales-confirm.jsp" method="post" id="create-form">
    
        <div id="create-popup">
            
            <div id="create-title-section">
                <h2>売上データ作成</h2>
                <p class="close" onclick="closeAllPopups()">✖</p>
            </div>

            <div id="create-pop-contents">
    
                <div id="create-top-section">
                    <img class="image" id="add-image" src="<%=request.getContextPath()%>/images/placeholder.png" width="200" height="200" alt="アイスを選択してください">
                    <select name="productID" id="product">
                        <option hidden disabled selected value>商品を選択</option>
                        <!--動的に画像を変更する-->
<%--                        <% if(salesList.isEmpty()){ %><option hidden disabled selected value>商品を選択</option><% } %>--%>
<%
                            for(int i=0; i<productsList.size(); i++){
%>
                                <option value="<%= productsList.get(i).get("productID") %>" <% if(returnFromCreate){ %><% if(productIDCancelledCreate.equals(productsList.get(i).get("productID"))){%> selected <% } } %>><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
<%
                            }
%>
                    </select>
                </div>
    
                <div id="create-middle-section">
                    <table>
                        <tr>
                            <td class="table-left-side">販売日時</td>
                            <td>
                                <div class="sale-time-setting">
                                    <div class="sale-time-button-holder">
                                        <input type="radio" onclick="checkRadioCreate()" name="sale_time_selector" id="now-time-create" value="今現在" checked>今現在
                                        <input type="radio" onclick="checkRadioCreate()" name="sale_time_selector" id="adjust-time-create" value="指定する">指定する
                                    </div>
                                    <input type="datetime-local" name="sale_time" id="sale-time-input" class="sale-time-textbox" step="1">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>販売担当</td>
                            <td><input type="text" class="sale-staff" name="sale_staff" id="<%=staffID%>" value="<%=staffName%>" disabled></td>
                        </tr>
                        <tr>
                            <td>販売個数</td>
                            <td><input type="number" class="sale-quantity-input" name="sale_quantity" id="sale-quantity-create" min="1" max="<%=productsList.get(0).get("quantity")%>" value="1"></td>
                        </tr>
                    </table>
                </div>

                <input type="hidden" name="registerType" value="create">

                <div id="create-buttons-holder">
                    <button type="button" class="normal-button" onclick="closeAllPopups()">キャンセル</button>
                    <button type="submit" class="normal-button">作成</button>
                </div>
            </div>
        </div>

    </form>

    <!-- 売上データ編集 -->
    <form action="sales-confirm.jsp" method="post" id="edit-form">

        <div id="edit-popup">
            
            <div id="edit-title-section">
                <h2>売上データ修正</h2>
                <p class="close" onclick="closeAllPopups()">✖</p>
            </div>
    
            <div id="edit-pop-contents">
    
                <div id="edit-top-section">
                    <img src="<%=request.getContextPath()%>/images/placeholder.png" class="sale-image" id="edit-image" alt="アイスを選択してください" width="120" height="120">
                    <select name="productID" id="product-edit">
                        <% if(salesList.isEmpty()){ %><option hidden disabled selected value>商品を選択</option><% } %>
                        <%
                            for(int i=0; i<productsList.size(); i++){
                        %>
                        <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
                        <%
                            }
                        %>
                    </select>
                </div>
    
                <div id="edit-middle-section">
                    <table>
                        <tr>
                            <td class="table-left-side">販売日時</td>
                            <td>
                                <div class="sale-time-setting">
                                    <div class="sale-time-button-holder">
                                        <!-- checked追加しても動作しないのでJS側で設定する -->
                                        <input type="radio" onclick="checkRadioEdit()" name="sale-time-edit" id="now-time-edit" value="今現在">今現在
                                        <input type="radio" onclick="checkRadioEdit()" name="sale-time-edit" id="adjust-time-edit" value="指定する" checked>指定する
                                    </div>
                                    <input type="datetime-local" name="sale_time" id="edit-time-textbox" class="sale-time-textbox" step="1">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>販売担当</td>
                            <td>
                                <select name="sale-staff-edit" id="sale-staff-edit">
                                    <% for (int i = 0; i < staffList.size(); i++) { %>
                                        <option value="<%=staffList.get(i).get("staffID")%>"><%=staffList.get(i).get("staffName")%></option>
                                    <% } %>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>販売個数</td>
                            <td><input type="number" name="sale_quantity" class="sale-quantity-input" id="sale-quantity-edit" min="1" max="999"></td>
                        </tr>
                    </table>

                </div>

                <p id="edit-warning-message">売上修正の時点で量数と在庫数のチェックが行われないのでご注意ください。<br>修正後、量数の差が在庫数に反映されます。</p>

                <input type="hidden" name="registerType" value="edit">
                <input type="hidden" name="saleID" id="edit-saleID">
    
                <div id="edit-buttons-holder">
                    <button type="button" class="normal-button" onclick="closeAllPopups()">キャンセル</button>
                    <button type="submit" class="normal-button">修正</button>
                </div>
    
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.0"></script>
    <script src="salesGrouping.js"></script>
    <script>
        document.getElementById('now-time-create').checked = true;
        document.getElementById('now-time-edit').checked = true;
        let inputBoxes = document.getElementsByClassName("sale-time-textbox");
        let blackBackground = document.getElementById("black-background");
        let createPopup = document.getElementById("create-popup");
        let editPopup = document.getElementById("edit-popup");
        let saleQuantities = Array.from(document.getElementsByClassName("sale-quantity-input"));

        //検索条件があればここで設定します。
        <% if(productSearch != null){ %> document.getElementById("productSearch").value = "<%=productSearch%>" <% } %>
        <% if(staffSearch != null){ %> document.getElementById("staffSearch").value = "<%=staffSearch%>" <% } %>
        <% if(searchStartDate != null){ %> document.getElementById("searchStartDate").value = "<%=searchStartDate%>" <% } %>
        <% if(searchEndDate != null){ %> document.getElementById("searchEndDate").value = "<%=searchEndDate%>" <% } %>

        //商品データをJSに渡します
        let products = [];
        <% for(int i = 0; i < productsList.size(); i++) { %>
            products.push({
                "productID": "<%=productsList.get(i).get("productID")%>",
                "image": "<%=productsList.get(i).get("image")%>",
                "quantity": "<%=productsList.get(i).get("quantity")%>"
            });
        <% } %>

        //セールデータをJSに渡します
        let sales = [];
        <% for(int i = 0; i < salesList.size(); i++) { %>
            sales.push({
                "saleID": "<%=salesList.get(i).get("salesID")%>",
                "productID": "<%=salesList.get(i).get("productID")%>",
                "productName": "<%=salesList.get(i).get("productName")%>",
                "image": "<%=salesList.get(i).get("imageFileName")%>",
                "dateTime": "<%=salesList.get(i).get("dateTime")%>",
                "quantity": "<%=salesList.get(i).get("quantity")%>",
                "staffID": "<%=salesList.get(i).get("staffID")%>"
            });
        <% } %>

        //対象商品が変わった時の処理を行う。
        document.getElementById("product").addEventListener("input", (event) => {
            products.forEach(product => {
                if(product.productID === event.target.value){
                    //売上データ作成ポップアップ内に別の商品を選択するとの画像変更
                    document.getElementById("add-image").src = "<%=request.getContextPath()%>/images/" + product.image;
                    //量数範囲の設定
                    let saleQuantity = document.getElementById("sale-quantity-create");
                    saleQuantity.setAttribute("max", product.quantity);
                    saleQuantity.value = checkQuantity(Number(saleQuantity.value), Number(saleQuantity.min), Number(saleQuantity.max));
                }
            })
        });

        //作成から戻ったら綺麗に設定する。
        if(<%=returnFromCreate%>) {
            //商品の切り替えはJava内で行っています。対象オプションに selected を追加しています。
            let saleTimeSelector = "<%=saleTimeSelector%>";
            if(saleTimeSelector === "今現在"){
                document.getElementById("now-time-create").checked = "true";
            } else if (saleTimeSelector === "指定する"){
                document.getElementById("adjust-time-create").checked = "true";
                //指定の場合でも再設定させます。
                inputBoxes[0].value = "";
            }
            checkRadioCreate();
            document.getElementById("sale-quantity-create").value = <%=saleQuantity%>;
            //最後に画像リフレッシュのためイベントを実行させます。
            document.getElementById("product").dispatchEvent(new Event("input"));
            openAddPopup();
        }

        //商品詳細画面から来た時に自動的に追加ポップアップ内の対象商品を選択する
        if(<%=shouldCreateFromID%>){
            let productSelect = document.getElementById("product");
            productSelect.value = "<%=createFromProductID%>";
            productSelect.dispatchEvent(new Event("input"));
            openAddPopup();
        }

        saleQuantities.forEach(saleQuantity => {
            saleQuantity.addEventListener("input", () => {
                console.log("in here")
                saleQuantity.value = checkQuantity(Number(saleQuantity.value), Number(saleQuantity.min), Number(saleQuantity.max));
            });
        });

        blackBackground.addEventListener("click", closeAllPopups);

        function checkRadioCreate(){
            if(document.getElementById("now-time-create").checked){
                inputBoxes[0].style.display = "none";
                inputBoxes[0].value = "";
                document.getElementById("sale-time-input").removeAttribute("required");
            }else if(document.getElementById("adjust-time-create").checked){
                inputBoxes[0].style.display = "flex";
                document.getElementById("sale-time-input").required = "true";
            }
        }
       
        function checkRadioEdit(){
            if(document.getElementById("now-time-edit").checked){
                inputBoxes[1].style.display = "none";
                // inputBoxes[1].value = "";    //修正なので残します。
            }else if(document.getElementById("adjust-time-edit").checked){
                inputBoxes[1].style.display = "flex";
            }
        }

        function openAddPopup(){
            blackBackground.style.display = "flex";
            createPopup.style.display = "flex";
        }
        
        function openEditPopup(saleID){
            setupEditPopup(saleID);
            blackBackground.style.display = "flex";
            editPopup.style.display = "flex";
        }

        function setupEditPopup(saleID){
            sales.forEach(sale => {
                if(sale.saleID == saleID){
                    document.getElementById("edit-image").src = "<%=request.getContextPath()%>/images/" + sale.image;
                    document.getElementById("edit-image").alt = sale.productName;
                    document.getElementById("product-edit").value = sale.productID;
                    document.getElementById("adjust-time-edit").checked = "true";
                    document.getElementById("edit-time-textbox").value = sale.dateTime;
                    document.getElementById("sale-staff-edit").value = sale.staffID;
                    document.getElementById("sale-quantity-edit").value = sale.quantity;
                    document.getElementById("edit-saleID").value = sale.saleID;
                    checkRadioEdit();
                }
            });
        }

        //chartJSのフルスクリーンを含めない
        function closeAllPopups(){
            blackBackground.style.display = "none";
            createPopup.style.display = "none";
            editPopup.style.display = "none";
            document.getElementById("create-form").reset();
            document.getElementById("edit-form").reset();
            checkRadioCreate();
            checkRadioEdit();
        }
        
        function checkQuantity(input, min, max){
            // console.log(event.currentTarget);
            // let input = event.currentTarget;
            console.log("received " + input + ", " + min + ", " + max)
            if(isNaN(input) || input == "") input = 1;
            //parseInt()しないとJSは型変換してくれないので比べられない
            let quantity = parseInt(input);

            if(quantity < min) input = String(min);
            if(quantity > max) input = String(max);

            return input;
        }

        function reloadOnPage(targetPage){
            document.getElementById("targetPage").value = Number(targetPage);
            document.getElementById("pageingSearch").submit();
        }

    </script>
<% } %>
</body>
</html>