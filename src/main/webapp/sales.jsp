<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

//    String staffID = session.getAttribute("staffID");
//    String staffID = session.getAttribute("staffName");
    String staffID = "00";      //仮にシステムの登録だとします
    String staffName = "システム";      //仮にシステムの登録だとします

    //売上データ作成から戻った時にもらうパラメータ
    String productIDFromCreate = request.getParameter("productIDFromCreate"); //対象商品のIDです
    String saleTimeSelector = request.getParameter("sale_time_selector");
//    String saleTime = request.getParameter("sale_time");          //戻っても自動設定させません
    String saleQuantity = request.getParameter("saleQuantity");
    boolean returnFromCreate = (productIDFromCreate != null);

    // データベース接続情報
    String USER = "root";
    String PASSWORD = "root";
    String URL = "jdbc:mysql://localhost/icehanbaikanri";
    String DRIVER = "com.mysql.jdbc.Driver";

    // エラーメッセージ格納用
    String ERMSG = null;

    // 結果格納用リスト
    ArrayList<HashMap<String, String>> salesList = new ArrayList<>();
    ArrayList<HashMap<String, String>> staffList = new ArrayList<>();
    ArrayList<HashMap<String, String>> productsList = new ArrayList<>();

    try {
        // JDBCドライバのロード
        Class.forName(DRIVER);

        //-----売上一覧-----
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT p.name AS productName, s.dateTime, s.quantity, st.staffID, st.name AS staffName FROM Products p JOIN Sales s ON p.productID = s.productID JOIN Staff st ON s.staffID = st.staffID;")
        ) {

            // データ抽出
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("productName", rs.getString("productName"));
                map.put("dateTime", rs.getString("dateTime"));
                map.put("quantity", rs.getString("quantity"));
                map.put("staffID", rs.getString("staffID"));
                map.put("staffName", rs.getString("staffName"));

                // リストに追加
                salesList.add(map);
            }
        }

        //-----スタッフ一覧-----
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("select staffID, name from staff;")
        ) {

            // データ抽出
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("staffID", rs.getString("staffID"));
                map.put("name", rs.getString("name"));

                // リストに追加
                staffList.add(map);
            }
        }

        //-----商品一覧-----
        try (Connection con = DriverManager.getConnection(URL, USER, PASSWORD);
             Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery("select productID, name, quantity, image from products;")
        ) {

            // データ抽出
            while (rs.next()) {
                HashMap<String, String> map = new HashMap<>();
                map.put("productID", rs.getString("productID"));
                map.put("name", rs.getString("name"));
                map.put("image", rs.getString("image"));
                map.put("quantity", rs.getString("quantity"));

                // リストに追加
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
    <div id="everything-wrapper">
        
        <div id="top-text-holder">
            <h1>売上データ一覧</h1>
            <span>管理者モード</span>
        </div>

        <div id="top-area-container">

            <form action="sales.jsp" method="post" id="search-form">
                
                <div id="search-params-container">

                    <div id="pulldown-menus-container">
                        
                        <select name="product" id="product-Search">
                            <option hidden disabled selected value>商品を選択</option>
<%
                            for(int i=0; i < productsList.size(); i++){
%>
                            <option value="<%= productsList.get(i).get("productID") %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
<%
                            }
%>
                        </select>

                        <select name="staff" id="staff-Search">
                            <option hidden disabled selected value>販売の人事</option>
<%
                            for(int i=0; i<staffList.size(); i++){
%>
                            <option value="<%= staffList.get(i).get("staffID") %>"><%= staffList.get(i).get("staffID") %> <%= staffList.get(i).get("name") %></option>
<%
                            }
%>
                        </select>
                        
                    </div>
                    
                    <div id="dates-menus-container">
                        
                        <div class="date-row-wrapper">
                            <input type="date" name="date-start" id="searchStartDate">
                            <p>から</p>
                        </div>
                        <div class="date-row-wrapper">
                            <input type="date" name="date-end" id="searchEndDate">
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
            <form action="main.jsp" method="post">
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
                            <!--?product=xxx&previousPage=sales.jspを追加する。-->
                            <a href="product-details.jsp" class="image-wrapper-anchor">
                                <img class="sale-image" src="images/ice1.png" width="100" height="100" alt="ice1">
                            </a>
                            <p class="sale-text"><%= salesList.get(i).get("productName") %>が <%= salesList.get(i).get("dateTime") %>に <%= salesList.get(i).get("quantity") %>個 販売されました。(<%= salesList.get(i).get("staffName") %>より)</p>
                        </div>
                        <div class="sale-button-box">
                            <button type="button" class="edit-button" onclick="openEditPopup()">修正</button>
                            <form action="sales-confirm.jsp" method="post" class="deleteForm">
                                <input type="hidden" name="status" value="delete">
                                <input type="hidden" name="saleID" value="">
                                <button type="submit" class="delete-button">削除</button>
                            </form>
                        </div>
                    </div>
<%
                }
            } else {
%>

                <h4>データが見つかりませんでした。</h4>

            <% } %>

        </div>

        <div class="back-button-holder">
            <form action="main.jsp" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

        <!--本来は複数のaタグにするか、スパンのテキストに応じてJavaScriptで検索開始-->
        <div id="page-selector-wrapper">
            <a href="sales.jsp">
                <p id="page-selector">1　<span>2</span></p>
            </a>
        </div>

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
                    <img class="image" id="add-image" src="<%=request.getContextPath()%>/images/<%=productsList.get(0).get("image")%>" width="200" height="200" alt="<%=productsList.get(0).get("name")%>">
                    <select name="productID" id="product">
                        <!--動的に画像を変更する-->
<%--                        <option hidden disabled selected value>商品を選択</option>--%>
<%
                            for(int i=0; i<productsList.size(); i++){
%>
                                <option value="<%= productsList.get(i).get("productID") %>" <% if(returnFromCreate){ %><% if(productIDFromCreate.equals(productsList.get(i).get("productID"))){%> selected <% } } %>><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
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
                                    <input type="datetime-local" name="sale_time" id="sale-time-input" class="sale-time-textbox">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>販売担当</td>
                            <td><input type="text" class="sale-staff" name="sale_staff" id="<%=staffID%>" value="<%=staffName%>" disabled></td>
                        </tr>
                        <tr>
                            <td>販売個数</td>
                            <!--売上データ作成のポップアップだけは、販売個数のmaxを対象の商品の在庫数に設定する。-->
                            <!--画像を変換する時点で、販売個数をチェックする。1以上あれば普通の動きで必ず個数を1に設定する。ゼロだったら登録させないように-->
                            <!--JavaでもらうデータをJSに渡す必要がある。-->
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
                    <img src="images/ice1.png" class="sale-image" alt="ice1" width="120" height="120">
                    <select name="product" id="product-edit">
                        <option hidden disabled selected value>商品を選択</option>
                        <%
                            for(int i=0; i<productsList.size(); i++){
                        %>
                        <option value="<%= i+1 %>"><%= productsList.get(i).get("productID") %> <%= productsList.get(i).get("name") %></option>
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
                                        <input type="radio" onclick="checkRadioEdit()" name="sale-time-edit" id="now-time-edit" value="今現在" checked>今現在
                                        <input type="radio" onclick="checkRadioEdit()" name="sale-time-edit" id="adjust-time-edit" value="指定する">指定する
                                    </div>
                                    <input type="datetime-local" name="sale-time-textbox" class="sale-time-textbox">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>販売担当</td>
                            <td><input type="text" class="sale-staff" id="sale-staff-edit" value="入合憂政"></td>
                        </tr>
                        <tr>
                            <td>販売個数</td>
                            <td><input type="number" class="sale-quantity-input" id="sale-quantity-edit" min="1" max="999" value="1"></td>
                        </tr>
                    </table>
                </div>
    
                <div id="edit-buttons-holder">
                    <button type="button" class="normal-button" onclick="closeAllPopups()">キャンセル</button>
                    <button type="submit" class="normal-button">修正</button>
                </div>
    
            </div>
        </div>
    </form>

    <script>
        document.getElementById('now-time-create').checked = true;
        document.getElementById('now-time-edit').checked = true;
        let inputBoxes = document.getElementsByClassName("sale-time-textbox");
        let blackBackground = document.getElementById("black-background");
        let createPopup = document.getElementById("create-popup");
        let editPopup = document.getElementById("edit-popup");
        let saleQuantities = Array.from(document.getElementsByClassName("sale-quantity-input"))

        //商品データをJSに渡します
        let products = [];
        <% for(int i = 0; i < productsList.size(); i++) { %>
            products.push({
                "productID": "<%=productsList.get(i).get("productID")%>",
                "image": "<%=productsList.get(i).get("image")%>",
                "quantity": "<%=productsList.get(i).get("quantity")%>"
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
                inputBoxes[1].value = "";
            }else if(document.getElementById("adjust-time-edit").checked){
                inputBoxes[1].style.display = "flex";
            }
        }

        function openAddPopup(){
            blackBackground.style.display = "flex";
            createPopup.style.display = "flex";
        }
        
        function openEditPopup(){
            blackBackground.style.display = "flex";
            editPopup.style.display = "flex";
        }

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
    </script>
    
</body>
</html>