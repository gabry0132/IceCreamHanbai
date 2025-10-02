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
    String unitPerBox = request.getParameter("unitPerBox");
    String imageFileName = request.getParameter("imageFileName");

    //画像データの保存場所を指定する。
//    String absolutePath = application.getRealPath("\\images");

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
    HashMap<String,String> tag = null;
    ArrayList<HashMap<String,String>> productsList = new ArrayList<>();
    ArrayList<HashMap<String,String>> tags = new ArrayList<>();

    try {

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //「商品追加」処理をキャンセルして本画面に戻った場合は途中でアップロードされた画像の削除を行う
        if(imageFileName != null){
            //出力場所を取得する
            String relativePath = "\\images";
            String targetUrl = application.getRealPath(relativePath);
            File file = new File(targetUrl + "\\" + imageFileName);
            if(!file.delete()){
                System.out.println("Error deleting file");
            }
        }

        //タグとタグタイプを取得します。
        sql = new StringBuffer();
        sql.append("select tags.tagID, tags.value, tags.tagTypeID, t.type from tags inner join icehanbaikanri.tagtypes t on tags.tagTypeID = t.tagTypeID where tags.deleteFlag = 0");
        rs = stmt.executeQuery(sql.toString());

        while(rs.next()){

            tag = new HashMap<>();
            tag.put("tagID", rs.getString("tagID"));
            tag.put("value", rs.getString("value"));
            tag.put("tagTypeID", rs.getString("tagTypeID"));
            tag.put("tagType", rs.getString("type"));
            tags.add(tag);

        }

        sql = new StringBuffer();
        sql.append("select productID, name, quantity, alertNumber, image from products ");
        sql.append("where deleteFlag = 0");

        rs = stmt.executeQuery(sql.toString());

        while(rs.next()){
            product = new HashMap<String,String>();
            product.put("productID", rs.getString("productID"));
            product.put("name", rs.getString("name"));
            product.put("quantity", rs.getString("quantity"));
            product.put("alertNumber", rs.getString("alertNumber"));
            product.put("image", rs.getString("image"));

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

                <form action="products.jsp" method="post" id="search-form">
                    
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
                                <% for(int i = 0; i < tags.size(); i++) { %>
                                    <% if(tags.get(i).get("tagType").equals("メーカー")){ %>
                                        <option value="<%=tags.get(i).get("tagID")%>"><%=tags.get(i).get("value")%></option>
                                    <% } %>
                                <% } %>
                            </select>

                            <select name="searchFlavor" id="searchFlavor">
                                <option hidden disabled selected value>味</option>
                                <% for(int i = 0; i < tags.size(); i++) { %>
                                    <% if(tags.get(i).get("tagType").equals("味")){ %>
                                        <option value="<%=tags.get(i).get("tagID")%>"><%=tags.get(i).get("value")%></option>
                                    <% } %>
                                <% } %>
                            </select>    
                            
                            <select name="searchType" id="searchType">
                                <option hidden disabled selected value>種類</option>
                                <% for(int i = 0; i < tags.size(); i++) { %>
                                    <% if(tags.get(i).get("tagType").equals("種類")){ %>
                                        <option value="<%=tags.get(i).get("tagID")%>"><%=tags.get(i).get("value")%></option>
                                    <% } %>
                                <% } %>
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
                <form action="main.jsp" method="post">
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

                    <div class="product-container<% if(showAlert){ %> showAlert<% } %>" title="<%= productsList.get(i).get("name") %>" onclick="window.open('product-details.jsp?productID=<%=productsList.get(i).get("productID")%>', '_self')">
                        <table class="product-table">
                            <tr>
                                <td class="product-image-holder" rowspan="4">
                                    <img src="<%=request.getContextPath()%>/images/<%=productsList.get(i).get("image")%>" width="90" height="90" alt="<%= productsList.get(i).get("name") %>">
                                </td>
                                <!-- IDを5桁表示にします。 -->
                                <% int zeroesToPad = 5 - productsList.get(i).get("productID").length(); %>
                                <td class="product-ID-holder">ID: <% for (int j = 0; j < zeroesToPad; j++) { %>0<% } %><%=productsList.get(i).get("productID")%></td>
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
            <form action="main.jsp" method="post">
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

                    <div id="add-top-tables-wrapper">
    
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
                                        <% for(int i = 0; i < tags.size(); i++) { %>
                                            <% if(tags.get(i).get("tagType").equals("メーカー")){ %>
                                                <option value="<%=tags.get(i).get("tagID")%>"><%=tags.get(i).get("value")%></option>
                                            <% } %>
                                        <% } %>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td>味</td>
                                <td>
                                    <select name="flavor" id="flavor" required>
                                        <option hidden disabled selected value>味</option>
                                        <% for(int i = 0; i < tags.size(); i++) { %>
                                            <% if(tags.get(i).get("tagType").equals("味")){ %>
                                                <option value="<%=tags.get(i).get("tagID")%>"><%=tags.get(i).get("value")%></option>
                                            <% } %>
                                        <% } %>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td>種類</td>
                                <td>
                                    <select name="type" id="type" required>
                                        <option hidden disabled selected value>種類</option>
                                        <% for(int i = 0; i < tags.size(); i++) { %>
                                            <% if(tags.get(i).get("tagType").equals("種類")){ %>
                                                <option value="<%=tags.get(i).get("tagID")%>"><%=tags.get(i).get("value")%></option>
                                            <% } %>
                                        <% } %>
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
                                <td>個<span class="optional-parameter-wrapper">（任意、個数）</span></td>
                            </tr>
                            <tr>
                                <td>自動発注限界</td>
                                <td><input type="number" name="autoOrderLimit" id="autoOrderLimit" min="0" max="999" required></td>
                                <td>個<span class="optional-parameter-wrapper">（個数）</span></td>
                            </tr>
                            <tr>
                                <td>自動発注数量</td>
                                <td><input type="number" name="autoOrderQuantity" id="autoOrderQuantity" min="0" max="999" required></td>
                                <td>箱<span class="optional-parameter-wrapper">（箱数）</span></td>
                            </tr>
                        </table>

                    </div>

                    <div id="add-bottom-tables-wrapper">
                        <table class="add-table">
                            <tr>
                                <td>１箱数量</td>
                                <td><input type="number" name="unitPerBox" id="unitPerBox" min="0" max="999" required></td>
                                <td>個</td>
                            </tr>
                        </table>

                        <table class="add-table">
                            <tr>
                                <td>発注確認日数</td>
                                <td><input type="number" name="confirmDays" id="confirmDays" min="0" max="999" required></td>
                                <td>日</td>
                            </tr>
                        </table>

                        <table class="add-table">
                            <tr>
                                <td>発注配達日数</td>
                                <td><input type="number" name="shippingDays" id="shippingDays" min="0" max="999" required></td>
                                <td>日</td>
                            </tr>
                        </table>
                    </div>

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

        //最初からポップアップを表示すべきかどうか判断
        let showAddPopup = "<%=status%>";
        if(showAddPopup == "returnFromAdd"){
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
            document.getElementById("unitPerBox").value="<%=unitPerBox%>";

            //ポップアップを表示する
            openAddPopup();
        }

        //イベントリスナーの設定
        document.getElementById("btn-add").addEventListener("click", openAddPopup);
        document.getElementsByClassName("closure")[0].addEventListener("click", closeAllPopups);
        document.getElementById("btn-add-cancel").addEventListener("click", closeAllPopups);
        obfuscationBanner.addEventListener("click", closeAllPopups);
        let productHolders = document.getElementsByClassName("product-container");

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