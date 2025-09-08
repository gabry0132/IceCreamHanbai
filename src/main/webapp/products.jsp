<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%@ page import="java.io.File" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

//    String logout = request.getParameter("logout");
//    if(logout != null){
//        session.removeAttribute("userID");
//    }
//    String userID = (String) session.getAttribute("userID");
//
//    if(userID != null){
//        response.sendRedirect("main.jsp");
//    }

    String status = request.getParameter("status");
    //内容修正の場合は画像を削除する？
    String productName = request.getParameter("name");
    String maker = request.getParameter("maker");
    String flavor = request.getParameter("flavor");
    String type = request.getParameter("type");
    String cost = request.getParameter("cost");
    String price = request.getParameter("price");
    String instockQuantity = request.getParameter("instockQuantity");
    if(instockQuantity == null || instockQuantity.equals("0")) instockQuantity = "";
    String alertNumber = request.getParameter("alertNumber");
    if(alertNumber == null || alertNumber.equals("0")) alertNumber = "";
    String autoOrderLimit = request.getParameter("autoOrderLimit");
    String autoOrderQuantity = request.getParameter("autoOrderQuantity");
    String imageFileName = request.getParameter("imageFileName");

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

    HashMap<String,String> product = null;
    ArrayList<HashMap<String,String>> productsList = new ArrayList<>();

    try {

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //「商品追加」処理をキャンセルして本画面に戻った場合は途中でアップロードされた画像の削除を行う
        if(!imageFileName.isEmpty()){
            //出力場所を取得する
            String relativePath = "\\images";
            String targetUrl = application.getRealPath(relativePath);
            File file = new File(targetUrl + "\\" + imageFileName);
            if(!file.delete()){
                System.out.println("Error deleting file");
            }

        }

        sql = new StringBuffer();
        sql.append("select productID, name, quantity, alertNumber image from products ");
        sql.append("where deleteFlag = 0");

        rs = stmt.executeQuery(sql.toString());

        while(rs.next()){
            product = new HashMap<String,String>();
            product.put("productID", rs.getString("productID"));
            product.put("name", rs.getString("name"));
            product.put("quantity", rs.getString("purchaseCost"));
            product.put("image", rs.getString("image"));
            product.put("alertNumber", rs.getString("alertNumber"));

            productsList.add(product);
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
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品</title>
    <link rel="stylesheet" href="css/products.css">
</head>
<body>

    <div id="everything-wrapper">

        <h1>商品一覧</h1>

        <div id="top-area-container">

            <div id="search-params-container">

                <form action="products.html" method="post" id="search-form">
                    
                    <div id="search-params-outerWrapper">
                        <div id="text-boxes-container">
                            
                            <p class="search-param-intro">商品名</p>
                            <input type="text" class="search-param-textfield" name="searchName" id="searchName" size="10">
                            
                            <p class="search-param-intro">商品ID</p>
                            <input type="text" class="search-param-textfield" name="searchId" id="searchId" size="10">
                            
                        </div>
                        
                        <div id="pulldown-menus-container">
                            
                            <select name="searchMaker" id="searchMaker">
                                <option hidden disabled selected value>メーカー</option>
                                <option value="akagi">akagi</option>
                                <option value="morinaga">morinaga</option>
                                <option value="meiji">meiji</option>
                                <option value="glico">glico</option>
                                <option value="lotte">lotte</option>
                            </select>
                            
                            <select name="searchFlavor" id="searchFlavor">
                                <option hidden disabled selected value>味</option>
                                <option value="vanilla">vanilla</option>
                                <option value="strawberry">strawberry</option>
                                <option value="chocolate">chocolate</option>
                                <option value="lemon">lemon</option>
                            </select>    
                            
                            <select name="searchType" id="searchType">
                                <option hidden disabled selected value>種類</option>
                                <option value="bar">bar</option>
                                <option value="cone">cone</option>
                                <option value="sando">sando</option>
                                <option value="cup">cup</option>
                            </select>
                            
                        </div>
                    </div>


                    <div id="search-buttons-holder">
                        <button class="submit">この条件で検索</button>
                        <button class="normal-button" type="reset">条件をクリア</button>
                    </div>
                    
                </form>

            </div>

            <div id="page-controls-holder">

                <button class="normal-button" id="btn-add">商品追加</button>
                <form action="main.html" method="post">
                    <button class="normal-button">戻る</button>
                </form>

            </div>

        </div>

        <% if(productsList.isEmpty()){ %>

            <h4>商品データがありません。</h4>

        <% } else { %>

            <div id="all-products-container">

                <!--商品箱の幅が固定だから長い商品名がカットされる。分かるようにdiv全体にtitleを付けます。ほーばーすると表示される-->
                <% for (int i = 0; i < productsList.size(); i++) { %>

                    <%
                        boolean showAlert = false;
                        if(Integer.parseInt(productsList.get(i).get("quantity")) < Integer.parseInt(productsList.get(i).get("alertNumber"))){
                            showAlert = true;
                        }
                    %>

                    <div class="product-container<% if(showAlert){ %> showAlert<% } %>" title="<%= productsList.get(i).get("name") %>">
                        <table class="product-table">
                            <tr>
                                <td class="product-image-holder" rowspan="4">
                                    <img src="images/<%= productsList.get(i).get("image") %>" width="90" height="90" alt="<%= productsList.get(i).get("name") %>">
                                </td>
                                <td class="product-ID-holder">ID: <%=productsList.get(i).get("productID")%></td> <!--本来は直接出力、今はJSで-->
                            </tr>
                            <tr>
                                <td class="product-name-holder"><%= productsList.get(i).get("name")%></td>
                            </tr>
                            <tr>
                                <td class="instock-intro-holder">在庫数<%if(showAlert){ %> ⚠<% } %></td>
                            </tr>
                            <tr>
                                <td class="instock-quantity-holder"><%= productsList.get(i).get("quantity") %>個</td>
                            </tr>
                        </table>
                    </div>

                <% } %>

            </div>

        <% } %>


        <div id="bottom-buttons-container">
            <form action="main.html" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

    </div>

    <!-- ポップアップ表示が使うバナー -->
    <div id="obfuscation-banner">
        
    </div>

    <!-- 商品追加ポップアップ -->
    <div id="add-product-popup">

        <form action="product-confirm.jsp" method="post" enctype="multipart/form-data">

            <div id="add-top-row">
                
                <h2>商品追加</h2>
                <p class="closure">✖</p>
                
            </div>
            
            <div id="add-main-section">

                <div id="add-image-section">

                    <!-- ファイルサイズは WEB-INF/web.xml に設定しています。 -->
                    <input type="file" name="image" id="image" accept=".jpg, .png" required>
                    <p class="hint">＊画像の写真を<br>アップロードしてください</p>

                </div>

                <div id="add-tables-wrapper">
    
                    <table class="add-table">
                        <tr>
                            <td class="add-table-left-side">商品名</td>
                            <td><input type="text" name="name" id="name" required></td>
                        </tr>
                        <tr>
                            <td>メーカー</td>
                            <td>
                                <select name="maker" id="maker" required>
                                    <option hidden disabled selected value>メーカー</option>
                                    <option value="1">akagi</option>
                                    <option value="2">morinaga</option>
                                    <option value="3">meiji</option>
                                    <option value="4">glico</option>
                                    <option value="5">lotte</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>味</td>
                            <td>
                                <select name="flavor" id="flavor" required>
                                    <option hidden disabled selected value>味</option>
                                    <option value="1">vanilla</option>
                                    <option value="2">strawberry</option>
                                    <option value="3">chocolate</option>
                                    <option value="lemon">lemon</option>
                                </select>  
                            </td>
                        </tr>
                        <tr>
                            <td>種類</td>
                            <td>
                                <select name="type" id="type" required>
                                    <option hidden disabled selected value>種類</option>
                                    <option value="bar">bar</option>
                                    <option value="cone">cone</option>
                                    <option value="sando">sando</option>
                                    <option value="cup">cup</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td>購入コスト</td>
                            <td><input type="text" name="cost" id="cost" required></td>
                            <td>円</td>
                        </tr>
                        <tr>
                            <td>販売値段</td>
                            <td><input type="text" name="price" id="price" required></td>
                            <td>円</td>
                        </tr>
                    </table>

                    <table class="add-table">
                        <tr>
                            <td class="table-left-side">在庫数</td>
                            <td><input type="number" name="instockQuantity" id="instockQuantity" min="0" max="999"></td>
                            <td>個<span class="optional-parameter-wrapper">（任意）</span></td>
                        </tr>
                        <tr>
                            <td>アラート限界</td>
                            <td><input type="number" name="alertNumber" id="alertNumber" min="0" max="999"></td>
                            <td>個<span class="optional-parameter-wrapper">（任意）</span></td>
                        </tr>
                        <tr>
                            <td>自動発注限界</td>
                            <td><input type="number" name="autoOrderLimit" id="autoOrderLimit" min="0" max="999" required></td>
                            <td>個</td>
                        </tr>
                        <tr>
                            <td>自動発注個数</td>
                            <td><input type="number" name="autoOrderQuantity" id="autoOrderQuantity" min="0" max="999" required></td>
                            <td>個</td>
                        </tr>
                    </table>

                </div>
                
            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="add">

            <div id="add-buttons-holder">
                <button type="button" class="normal-button" id="btn-add-cancel">キャンセル</button>
                <button class="normal-button" type="reset">クリア</button>
                <button class="normal-button" type="submit">追加</button>
            </div>
                
        </form>
            
    </div>
        
    <script>
        //ポップアップに使う変数取得
        let addPopup = document.getElementById("add-product-popup");
        let obfuscationBanner = document.getElementById("obfuscation-banner");
        let body = document.getElementsByTagName("body")[0];

        //IDの動的設定。本来はJavaにする
        let idHolders = document.getElementsByClassName("product-ID-holder");
        for (let i = 0; i < idHolders.length; i++) {
            idHolders[i].textContent += String(i).padStart(4, '0');
        }

        //最初からポップアップを表示すべきかどうか判断
        let showAddPopup = "<%=status%>";
        if(showAddPopup == "returnFromAdd"){
            console.log("must open popup");
            //フォーム内の値を設定する。
            document.getElementById("name").value="<%=productName%>"
            let makerSelectChildren = Array.from(document.getElementById("maker").children);
            makerSelectChildren.forEach(option => {
                if(option.value == "<%=maker%>"){
                    option.selected = true;
                }
            });
            let flavorSelectChildren = Array.from(document.getElementById("flavor").children);
            flavorSelectChildren.forEach(option => {
                if(option.value == "<%=flavor%>"){
                    option.selected = true;
                }
            });
            let typeSelectChildren = Array.from(document.getElementById("type").children);
            typeSelectChildren.forEach(option => {
                if(option.value == "<%=type%>"){
                    option.selected = true;
                }
            });
            document.getElementById("cost").value="<%=cost%>";
            document.getElementById("price").value="<%=price%>";
            document.getElementById("instockQuantity").value="<%=instockQuantity%>";
            document.getElementById("alertNumber").value="<%=alertNumber%>";
            document.getElementById("autoOrderLimit").value="<%=autoOrderLimit%>";
            document.getElementById("autoOrderQuantity").value="<%=autoOrderQuantity%>";

            //ポップアップを表示する
            openAddPopup();
        }

        //イベントリスナーの設定
        document.getElementById("btn-add").addEventListener("click", openAddPopup);
        document.getElementsByClassName("closure")[0].addEventListener("click", closeAllPopups);
        document.getElementById("btn-add-cancel").addEventListener("click", closeAllPopups);
        obfuscationBanner.addEventListener("click", closeAllPopups);
        let productHolders = document.getElementsByClassName("product-container");
        for (let i = 0; i < productHolders.length; i++) {
            productHolders[i].addEventListener("click", () => window.open("product-details.html", "_self"));
        }

        //追加ポップアップの表示
        function openAddPopup(){
            addPopup.style.display = "flex";
            obfuscationBanner.style.display = "flex";
            //後ろのページのスクロールを一時停止する。スクロールバーがなくなるのでやらない？
            body.classList.add("stop-scrolling");
        }

        //追加ポップアップの非表示
        function closeAllPopups(){
            addPopup.style.display = "none";
            obfuscationBanner.style.display = "none";
            //後ろのページのスクロール設定を元に戻す
            body.classList.remove("stop-scrolling");
        }

        //アラートの表示。本来はJavaにする。今回はただ10個以下ならアラートだとします。
        let stockHolders = document.getElementsByClassName("instock-quantity-holder");
        let stockIntroHolders = document.getElementsByClassName("instock-intro-holder");
        for (let i = 0; i < stockHolders.length; i++) {
            let quantity = stockHolders[i].textContent.substring(0, stockHolders[i].textContent.length - 1);
            if(quantity < 10) {
                let warning = document.createElement("span");
                warning.innerHTML = " ⚠"; 
                stockIntroHolders[i].appendChild(warning);   
                productHolders[i].style.border = "2px solid orangered";  
            }         
        }

        //商品名の長さチェック
        let nameHolders = document.getElementsByClassName("product-name-holder");
        for (let i = 0; i < nameHolders.length; i++) {
            const element = nameHolders[i];
            let name = element.textContent;
            let resolvedName = "";
            //直接name.lengthをチェックすると半角英数字が早めにカットされるので一文字ずつ確認します。
            let width = 0;
            for (let c = 0; c < name.length; c++) {
                if(isFullWidth(name.charAt(c))){
                    width += 2;
                } else {
                    width++;
                }
                if(width <= 23){
                    resolvedName += name.charAt(c);
                } else {
                    resolvedName += "...";
                    element.textContent = resolvedName;
                    break;
                }
            }
        }

        function isFullWidth(char) {
            const code = char.charCodeAt(0);
            // Common full-width ranges
            if (
                (code >= 0x190 && code <= 0x11FF) || // Hangul Jamo
                (code >= 0x2E80 && code <= 0x303F) || // CJK Radicals Supplement, Kangxi Radicals, Ideographic Description Characters, CJK Symbols and Punctuation, Hiragana, Katakana, Bopomofo, Hangul Compatibility Jamo
                (code >= 0x3040 && code <= 0x309F) || // Hiragana
                (code >= 0x30A0 && code <= 0x30FF) || // Katakana
                (code >= 0x3130 && code <= 0x318F) || // Hangul Compatibility Jamo
                (code >= 0x31F0 && code <= 0x31FF) || // Katakana Phonetic Extensions
                (code >= 0x3200 && code <= 0x32FF) || // Enclosed CJK Letters and Months
                (code >= 0x3300 && code <= 0x33FF) || // CJK Compatibility
                (code >= 0x4E00 && code <= 0x9FFF) || // CJK Unified Ideographs (Common Kanji/Hanzi)
                (code >= 0xA990 && code <= 0xA97F) || // Hangul Jamo Extended-A
                (code >= 0xAC00 && code <= 0xD7AF) || // Hangul Syllables
                (code >= 0xF900 && code <= 0xFAFF) || // CJK Compatibility Ideographs
                (code >= 0xFE30 && code <= 0xFE4F) || // CJK Compatibility Forms
                (code >= 0xFF00 && code <= 0xFFEF)    // Halfwidth and Fullwidth Forms
            ) {
                return true;
            }
            return false;
        }

    </script>
</body>
</html>