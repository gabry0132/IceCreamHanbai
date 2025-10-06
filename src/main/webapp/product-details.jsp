<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.EOFException" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.File" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String productID = request.getParameter("productID");
    String previousPage = request.getParameter("previousPage");
    if(previousPage == null) previousPage = "products.jsp"; //検索条件を無視する？

    //商品詳細更新する際に画像をアップロードしましたが途中でキャンセルした場合、これで正しく削除できます。
    String imageToDelete = request.getParameter("deleteThisImageDueToCancel");

    Connection con = null;
    Statement stmt = null;
    StringBuffer sql = null;
    ResultSet rs = null;

    String user = "root";
    String password = "root";
    String url = "jdbc:mysql://localhost/icehanbaikanri";
    String driver = "com.mysql.jdbc.Driver";

    //本ページに使う変数
    String productName = "";
    String cost = "";
    String price = "";
    String instockQuantity = "";
    String alertNumber = "";
    String autoOrderLimit = "";
    String autoOrderQuantity = "";
    String confirmDays = "";
    String shippingDays = "";
    String unitPerBox = "";
    String imageFileName = "";
    String maker = "";
    String makerName = "";
    String flavor = "";
    String flavorName = "";
    String type = "";
    String typeName = "";

    int zeroesToPad = 0;
    boolean showAlert = false;
    boolean stopAutoOrder = false;

    //確認メッセージ
    StringBuffer ermsg = null;

    HashMap<String,String> tag = null;
    ArrayList<HashMap<String,String>> tags = new ArrayList<>();

    try {
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //古い画像を削除する必要があればここで行います。
        if(imageToDelete != null){
            String relativePath = "\\images";
            String targetUrl = application.getRealPath(relativePath);
            File file = new File(targetUrl + "\\" + imageToDelete);
            if(!file.delete()){
                System.out.println("Error deleting file");
            }
        }

        sql = new StringBuffer();
        sql.append("select * from products where productID = ");
        sql.append(productID);
        sql.append(" and deleteFlag = 0");

        rs = stmt.executeQuery(sql.toString());

        if (rs.next()) {

            productName =  rs.getString("name");
            cost = rs.getString("purchaseCost");
            price = rs.getString("price");
            instockQuantity = rs.getString("quantity");
            alertNumber = rs.getString("alertNumber");
            autoOrderLimit = rs.getString("autoOrderLimit");
            autoOrderQuantity = rs.getString("autoOrderQuantity");
            confirmDays = rs.getString("confirmDays");
            shippingDays = rs.getString("shippingDays");
            unitPerBox = rs.getString("unitPerBox");
            imageFileName = rs.getString("image");
            if(rs.getInt("stopAutoOrder") != 0) stopAutoOrder = true;

        } else {
            throw new Exception("商品のデータがありません。");
        }

        //タグ情報も取得します。
        sql = new StringBuffer();
        sql.append("select tags.tagID, value, type from hastags inner join tags on hastags.tagID = tags.tagID inner join tagtypes on tags.tagtypeID = tagtypes.tagtypeID where productID = ");
        sql.append(productID);
        sql.append(" and hastags.deleteFlag = 0");
        rs = stmt.executeQuery(sql.toString());

        while(rs.next()){
            if(rs.getString("type").equals("メーカー")) {
                maker = rs.getString("tagID");
                makerName = rs.getString("value");
            }
            if(rs.getString("type").equals("味")) {
                flavor = rs.getString("tagID");
                flavorName = rs.getString("value");
            }
            if(rs.getString("type").equals("種類")) {
                type = rs.getString("tagID");
                typeName = rs.getString("value");
            }
        }

        //アラートを表示すべきかどうかここで判断
        if(Integer.parseInt(instockQuantity) <= Integer.parseInt(alertNumber)) showAlert = true;
        zeroesToPad = 5 - productID.length();

        //全体的にタグとタグタイプを取得します。
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
    <title>商品詳細</title>
    <link rel="stylesheet" href="css/product-details.css">
</head>
<body>


    <div id="everything-wrapper">

        <!--商品名の長さが予測できないのでタイトルに入れないほうがいい-->
        <h1>商品詳細データ</h1>

        <div id="main-section-wrapper">

            <div id="image-container">
                <img class="image" src="<%=request.getContextPath()%>/images/<%=imageFileName%>" width="200" height="200" alt="<%=productName%>">
            </div>

            <div id="data-table-wrapper">
                <table id="data-table">
                    <tr>
                        <td>商品名</td>
                        <td><%=productName%></td>
                    </tr>
                    <tr>
                        <td>商品ID</td>
                        <td><%for (int i = 0; i < zeroesToPad; i++) {%>0<%}%><%=productID%></td>
                    </tr>
                    <tr>
                        <td>メーカー</td>
                        <td><%=makerName%></td>
                    </tr>
                    <tr>
                        <td>味</td>
                        <td><%=flavorName%></td>
                    </tr>
                    <tr>
                        <td>種類</td>
                        <td><%=typeName%></td>
                    </tr>
                    <tr>
                        <td>購入コスト</td>
                        <td><%=cost%>円</td>
                    </tr>
                    <tr>
                        <td>販売値段</td>
                        <td><%=price%>円</td>
                    </tr>
                    <tr>
                        <td>在庫数</td>
                        <td><%=instockQuantity%>個<%if(showAlert){%><span class="alert-span">  ⚠</span><%}%></td>
                    </tr>
                    <tr <% if(stopAutoOrder){%> class="autoOrderStoppedRow"<%}%>>
                        <td>アラート限界</td>
                        <td><%=alertNumber%>個</td>
                    </tr>
                    <tr <% if(stopAutoOrder){%> class="autoOrderStoppedRow"<%}%>>
                        <td>自動発注限界</td>
                        <td><%=autoOrderLimit%>個</td>
                    </tr>
                    <tr <% if(stopAutoOrder){%> class="autoOrderStoppedRow"<%}%>>
                        <td>自動発注数量</td>
                        <td id="total-order-quantity"><%=autoOrderQuantity%>箱</td>
                    </tr>
                    <tr>
                        <td>1箱個数</td>
                        <td><%=unitPerBox%>個</td>
                    </tr>
                    <tr>
                        <td>発注確認日数</td>
                        <td><%=confirmDays%>日</td>
                    </tr>
                    <tr>
                        <td>発注配達日数</td>
                        <td><%=shippingDays%>日</td>
                    </tr>
                </table>
            </div>

            <div id="right-buttons-container">
                <!--作成ポップアップを開いて、自動的にこの商品を選択する。-->
                <form action="sales.jsp" method="post" class="button-wrapper-form">
                    <input type="hidden" name="productID" value="<%=productID%>">
                    <input type="hidden" name="status" value="createSaleOpen">
                    <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">
                    <button class="normal-button">売上データを<br>作成する</button>
                </form>

                <!--発注開始のポップアップを開いて、自動的にこの商品を選択する。-->
                <form action="orders.html" method="post" class="button-wrapper-form">
                    <input type="hidden" name="productID" value="<%=productID%>">
                    <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">
                    <button class="normal-button<%if(showAlert){%> pulse<%}%>">発注を<br>開始する</button>
                </form>

                <% if(stopAutoOrder){ %>

                    <div id="auto-order-stopped-div">
                        <p id="auto-order-stopped-warning">この商品のアラート・自動的発注機能が停止中です。</p>
                    </div>

                <% } %>

            </div>

        </div>

        <div id="additional-controls-wrapper">
            <!--自動的に検索条件を入れて、それで検索する-->
            <form action="sales.jsp" method="post" class="button-wrapper-form">
                <input type="hidden" name="productID" value="<%=productID%>">
                <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">
                <button class="normal-button">売上データ<br>確認</button>
            </form>

            <button class="normal-button" id="btn-alertUpdate">アラート・自動発注<br>設定変更</button>
    
            <button class="normal-button" id="btn-update-details">商品情報<br>変更</button>

            <button class="delete-button" id="btn-delete">商品削除</button>
            
        </div>
        
        <!-- 非表示削除フォーム -->
        <form id="delete-form" action="product-confirm.jsp" method="post">
            <input type="hidden" name="productID" value="<%=productID%>">
            <input type="hidden" name="registerType" value="delete">
        </form>

        <div id="bottom-buttons-container">
            <form action="<%=previousPage%>" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

    </div>
    
    <!-- ポップアップ表示が使うバナー -->
    <div id="obfuscation-banner">
        
    </div>

    <!-- アラート・自動発注設定変更のポップアップ -->
    <div id="alertUpdate-settings-popup">

        <form action="product-confirm.jsp" method="post">

            <div id="alertUpdate-top-row">

                <h2>アラート・<br>自動発注設定変更</h2>
                <p class="closure">✖</p>

            </div>

            <div id="alertUpdate-main-section">
                <table>
                    <tr>
                        <td id="table-left-side">商品名</td>
                        <td class="alertUpdate-alignRight-td"><%=productName%></td>
                    </tr>
                    <tr>
                        <td>商品ID</td>
                        <td class="alertUpdate-alignRight-td"><%for (int i = 0; i < zeroesToPad; i++) {%>0<%}%><%=productID%></td>
                    </tr>
                    <tr>
                        <td>在庫数</td>
                        <td class="alertUpdate-alignRight-td"><%=instockQuantity%>個</td>
                    </tr>
                </table>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text">アラート限界</p>
                    <div class="alertUpdate-quantityInput-holder">
                        <input class="alertUpdate-input" type="number" name="alertNumber" id="alertNumber" min="0" max="999" value="<%=alertNumber%>" <%if(stopAutoOrder){%>disabled<%}%>>
                        <p class="popup-text">個</p>
                    </div>
                </div>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text">自動発注限界</p>
                    <div class="alertUpdate-quantityInput-holder">
                        <input class="alertUpdate-input" type="number" name="autoOrderLimit" id="autoOrderLimit" min="1" max="999" value="<%=autoOrderLimit%>" <%if(stopAutoOrder){%>disabled<%}%>>
                        <p class="popup-text">個</p>
                    </div>
                </div>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text">自動発注数量</p>
                    <div class="alertUpdate-quantityInput-holder">
                        <input class="alertUpdate-input" type="number" name="autoOrderQuantity" id="autoOrderQuantity" min="1" max="999" value="<%=autoOrderQuantity%>" <%if(stopAutoOrder){%>disabled<%}%>>
                        <p class="popup-text">箱</p>
                    </div>
                </div>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text" id="alertUpdate-total-purchase">合計: <span id="alertUpdate-total-purchase-span"></span>個</p>
                </div>
                
            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="alertUpdate">
            <input type="hidden" name="productID" value="<%=productID%>">

            <div id="alertUpdate-bottom">
                <button type="button" class="normal-button" id="order-toggle-button">自動発注<br><%if(stopAutoOrder){%>有<%}else{%>無<%}%>効化する</button>
                <div id="bottomMost-buttons-holder">
                    <button type="button" class="normal-button cancelButton">キャンセル</button>
                    <button type="submit" class="normal-button"<%if(stopAutoOrder){%> disabled<%}%>>登録</button>
                </div>
            </div>

        </form>

        <!-- 登録を個別するための非表示フォーム -->
        <form id="auto-order-toggle-form" action="product-register.jsp" method="post">
            <input type="hidden" name="registerType" value="toggleAutoOrder">
            <input type="hidden" name="productID" value="<%=productID%>">
            <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">
        </form>

    </div>

    <!-- 商品情報変更のポップアップ -->
    <div id="update-settings-popup">

        <form action="product-confirm.jsp" method="post" enctype="multipart/form-data">

            <div id="update-top-row">

                <h2>商品情報情報変更</h2>
                <p class="closure">✖</p>

            </div>

            <div id="update-main-section">

                <div id="update-left-side">

                    <img class="image" src="<%=request.getContextPath()%>/images/<%=imageFileName%>" width="100" height="100" alt="<%=productName%>">
                    <p class="popup-text">現在の画像</p>
                    <input type="file" name="image" id="image">
                    <p class="hint">＊画像編集する場合だけ<br>ファイルを選択してください</p>

                </div>

                <div id="update-right-side">

                    <div class="update-field-wrapper">
                        <p class="popup-text">商品名</p>
                        <input type="text" name="name" id="name" size="20" value="<%=productName%>">
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">メーカー</p>
                        <select name="maker" id="maker" required>
                            <% for(int i = 0; i < tags.size(); i++) { %>
                                <% if(tags.get(i).get("tagType").equals("メーカー")){ %>
                                    <option value="<%=tags.get(i).get("tagID")%>"<%if(tags.get(i).get("tagID").equals(maker)){%> selected<%}%>><%=tags.get(i).get("value")%></option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">味</p>
                        <select name="flavor" id="flavor" required>
                            <% for(int i = 0; i < tags.size(); i++) { %>
                                <% if(tags.get(i).get("tagType").equals("味")){ %>
                                    <option value="<%=tags.get(i).get("tagID")%>"<%if(tags.get(i).get("tagID").equals(flavor)){%> selected<%}%>><%=tags.get(i).get("value")%></option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">種類</p>
                        <select name="type" id="type" required>
                            <% for(int i = 0; i < tags.size(); i++) { %>
                                <% if(tags.get(i).get("tagType").equals("種類")){ %>
                                    <option value="<%=tags.get(i).get("tagID")%>"<%if(tags.get(i).get("tagID").equals(type)){%> selected<%}%>><%=tags.get(i).get("value")%></option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">購入コスト</p>
                        <div id="update-cost-holder">
                            <input type="text" name="cost" id="cost" size="10" value="<%=cost%>">
                            <p class="popup-text">円</p>
                        </div>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">値段</p>
                        <div id="update-price-holder">
                            <input type="text" name="price" id="price" size="10" value="<%=price%>">
                            <p class="popup-text">円</p>
                        </div>
                    </div>
                    
                </div>

            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="detailsUpdate">
            <input type="hidden" name="productID" value="<%=productID%>">

            <div id="update-bottom">
                <button type="button" class="normal-button cancelButton">キャンセル</button>
                <button type="submit" class="normal-button">登録</button>
            </div>

        </form>

    </div>

    <script>
        //要素取得
        let updateDetailsPopup = document.getElementById("update-settings-popup");
        let updateAlertPopup = document.getElementById("alertUpdate-settings-popup");
        let obfuscationBanner = document.getElementById("obfuscation-banner");
        let closureElements = document.getElementsByClassName("closure");
        let cancelButtons = document.getElementsByClassName("cancelButton");

        //発注の際に合計何個注文されるかここで計算と表示します。
        let unitsPerBox = <%=unitPerBox%>;
        let boxesPerOrder = <%=autoOrderQuantity%>;
        document.getElementById("total-order-quantity").innerHTML += "　合計: " + (unitsPerBox * boxesPerOrder) + "個";
        //更新フォームの同じ項目
        let updatedBoxesPerOrder = document.getElementById("autoOrderQuantity").value;
        document.getElementById("alertUpdate-total-purchase-span").innerHTML = unitsPerBox * updatedBoxesPerOrder;


        //イベントリスナーの設定
        document.getElementById("btn-update-details").addEventListener("click", openUpdateDetailsPopup); 
        document.getElementById("btn-alertUpdate").addEventListener("click", openAlertUpdatePopup);
        document.getElementById("btn-delete").addEventListener("click", () => {
                document.getElementById("delete-form").submit();
        });
        document.getElementById("order-toggle-button").addEventListener("click", () => {
            let confirmText = "<%if(stopAutoOrder){%>アラートと自動発注を有効化します。よろしいですか。<%}else{%>自動発注を無効化します。現在のアラート機能と自動発注機能がなくなります。よろしいですか。<%}%>";
            if(confirm(confirmText)) {
                document.getElementById("auto-order-toggle-form").submit();
            }
        });
        document.getElementById("autoOrderQuantity").addEventListener("input", () => {
            updatedBoxesPerOrder = document.getElementById("autoOrderQuantity").value;
            document.getElementById("alertUpdate-total-purchase-span").innerHTML = unitsPerBox * updatedBoxesPerOrder;
        });
        //アラート・自動発注設定フォーム内のinputタグの入力範囲チェック
        Array.from(document.getElementsByClassName("alertUpdate-input")).forEach(element => {
                function validate(){
                    let min = Number(element.getAttribute("min"));
                    let max = Number(element.getAttribute("max"));
                    if (Number(element.value) < min) element.value = min;
                    if (Number(element.value) > max) element.value = max;
                }
                ["input", "focus", "blur"].forEach(event => element.addEventListener(event, validate));
        });

        obfuscationBanner.addEventListener("click",removePopups);
        for (let i = 0; i < closureElements.length; i++) {
            closureElements[i].addEventListener("click",removePopups);
        }
        for (let i = 0; i < cancelButtons.length; i++) {
            cancelButtons[i].addEventListener("click",removePopups);
        }
   
        //関数
        function openAlertUpdatePopup(){
            updateAlertPopup.style.display = "flex";
            obfuscationBanner.style.display = "flex";
        }
        function openUpdateDetailsPopup(){
            updateDetailsPopup.style.display = "flex";
            obfuscationBanner.style.display = "flex";
        }

        function removePopups(){
            updateAlertPopup.style.display = "none";
            obfuscationBanner.style.display = "none";
            updateDetailsPopup.style.display = "none";
        }
    </script>
</body>
</html>