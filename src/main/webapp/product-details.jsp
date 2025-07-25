<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    //いろいろ

    String productID = request.getParameter("productID");
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
                <img class="image" src="images/ice7.jpg" width="200" height="200" alt="ice7">
            </div>

            <div id="data-table-wrapper">
                <table id="data-table">
                    <tr>
                        <td>商品名</td>
                        <td>ガリガリ君</td>
                    </tr>
                    <tr>
                        <td>商品ID</td>
                        <td class="product-ID-holder">17</td>
                    </tr>
                    <tr>
                        <td>メーカー</td>
                        <td>akagi</td>
                    </tr>
                    <tr>
                        <td>種類</td>
                        <td>バー</td>
                    </tr>
                    <tr>
                        <td>味</td>
                        <td>九州みかん</td>
                    </tr>
                    <tr>
                        <td>購入コスト</td>
                        <td>30円</td>
                    </tr>
                    <tr>
                        <td>販売値段</td>
                        <td>80円</td>
                    </tr>
                    <tr>
                        <td>在庫数</td>
                        <td>25</td>
                    </tr>
                    <tr>
                        <td>アラート限界</td>
                        <td>15</td>
                    </tr>
                    <tr>
                        <td>自動発注限界</td>
                        <td>10</td>
                    </tr>
                    <tr>
                        <td>自動発注個数</td>
                        <td>20</td>
                    </tr>
                </table>
            </div>

            <div id="right-buttons-container">
                <!--作成ポップアップを開いて、自動的にこの商品を選択する。-->
                <form action="sales.html" method="post" class="button-wrapper-form">
                    <input type="hidden" name="productID" value="">
                    <input type="hidden" name="previousPage" value="product-details.jsp?productID=12345">
                    <button class="normal-button">売上データを<br>作成する</button>
                </form>

                <!--発注開始のポップアップを開いて、自動的にこの商品を選択する。-->
                <form action="orders.html" method="post" class="button-wrapper-form">
                    <input type="hidden" name="productID" value="">
                    <input type="hidden" name="previousPage" value="product-details.jsp?productID=12345">
                    <button class="normal-button">発注を<br>開始する</button>
                </form>
            </div>

        </div>

        <div id="additional-controls-wrapper">
            <!--自動的に検索条件を入れて、それで検索する-->
            <form action="sales.html" method="post" class="button-wrapper-form">
                <input type="hidden" name="productID" value="">
                <input type="hidden" name="previousPage" value="product-details.jsp?productID=12345">
                <button class="normal-button">売上データ<br>確認</button>
            </form>

            <button class="normal-button" id="btn-alertUpdate">アラート・自動発注<br>設定変更</button>
    
            <button class="normal-button" id="btn-update-details">商品情報<br>変更</button>

            <button class="delete-button" id="btn-delete">商品削除</button>
            
        </div>
        
        <!-- 非表示削除フォーム -->
        <form id="delete-form" action="product-confirm.html" method="post">
            <input type="hidden" name="productID" value="<%=productID%>">
            <input type="hidden" name="registerType" value="delete">
        </form>

        <div id="bottom-buttons-container">
            <form action="products.jsp" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

    </div>
    
    <!-- ポップアップ表示が使うバナー -->
    <div id="obfuscation-banner">
        
    </div>

    <!-- アラート・自動発注設定変更のポップアップ -->
    <div id="alertUpdate-settings-popup">

        <form action="product-confirm.html" method="post">

            <div id="alertUpdate-top-row">

                <h2>アラート・<br>自動発注設定変更</h2>
                <p class="closure">✖</p>

            </div>

            <div id="alertUpdate-main-section">
                <table>
                    <tr>
                        <td id="table-left-side">商品名</td>
                        <td>ガリガリ君</td>
                    </tr>
                    <tr>
                        <td>商品ID</td>
                        <td class="product-ID-holder">17</td>
                    </tr>
                    <tr>
                        <td>在庫数</td>
                        <td>25</td>
                    </tr>
                </table>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text">アラート限界</p>
                    <div class="alertUpdate-quantityInput-holder">
                        <input type="number" name="alertNumber" id="alertNumber" min="0" max="999" value="15">
                        <p class="popup-text">個</p>
                    </div>
                </div>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text">自動発注限界</p>
                    <div class="alertUpdate-quantityInput-holder">
                        <input type="number" name="autoOrderLimit" id="autoOrderLimit" min="0" max="999" value="15">
                        <p class="popup-text">個</p>
                    </div>
                </div>
                <div class="alertUpdate-field-wrapper">
                    <p class="popup-text">自動発注個数</p>
                    <div class="alertUpdate-quantityInput-holder">
                        <input type="number" name="autoOrderQuantity" id="autoOrderQuantity" min="0" max="999" value="15">
                        <p class="popup-text">個</p>
                    </div>
                </div>
                

            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="alertUpdate">

            <div id="alertUpdate-bottom">
                <button type="button" class="normal-button" id="order-toggle-button">自動発注<br>無効化する</button>
                <div id="bottomMost-buttons-holder">
                    <button type="button" class="normal-button cancelButton">キャンセル</button>
                    <button type="submit" class="normal-button">登録</button>
                </div>
            </div>

        </form>

        <!-- 登録を個別するための非表示フォーム -->
        <form id="auto-order-toggle-form" action="product-register.html" method="post">
            <input type="hidden" name="registerType" value="toggleAutoOrder">
            <input type="hidden" name="productID" value="17">
        </form>

    </div>

    <!-- 商品情報変更のポップアップ -->
    <div id="update-settings-popup">

        <form action="product-confirm.html" method="post">

            <div id="update-top-row">

                <h2>商品情報情報変更</h2>
                <p class="closure">✖</p>

            </div>

            <div id="update-main-section">

                <div id="update-left-side">

                    <img class="image" src="images/ice7.jpg" width="100" height="100" alt="ice7">
                    <p class="popup-text">現在の画像</p>
                    <input type="file" name="image" id="image">
                    <p class="hint">＊画像編集する場合だけ<br>ファイルを選択してください</p>

                </div>

                <div id="update-right-side">

                    <div class="update-field-wrapper">
                        <p class="popup-text">商品名</p>
                        <input type="text" name="name" id="name" size="20" value="ガリガリ君">
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">メーカー</p>
                        <select name="maker" id="maker">
                            <option value="akagi" selected>akagi</option>
                            <option value="morinaga">morinaga</option>
                            <option value="meiji">meiji</option>
                            <option value="glico">glico</option>
                            <option value="lotte">lotte</option>
                        </select>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">味</p>
                        <select name="flavor" id="flavor">
                            <option value="vanilla">vanilla</option>
                            <option value="strawberry">strawberry</option>
                            <option value="chocolate">chocolate</option>
                            <option value="lemon" selected>lemon</option>
                        </select>    
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">種類</p>
                        <select name="type" id="type">
                            <option value="bar" selected>bar</option>
                            <option value="cone">cone</option>
                            <option value="sando">sando</option>
                            <option value="cup">cup</option>
                        </select>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">購入コスト</p>
                        <div id="update-cost-holder">
                            <input type="text" name="cost" id="cost" size="10" value="30">
                            <p class="popup-text">円</p>
                        </div>
                    </div>
                    <div class="update-field-wrapper">
                        <p class="popup-text">値段</p>
                        <div id="update-price-holder">
                            <input type="text" name="price" id="price" size="10" value="80">
                            <p class="popup-text">円</p>
                        </div>
                    </div>
                    
                </div>

            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="detailsUpdate">

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

        //商品IDの表示変更（本来はJavaで）
        let idHolders = document.getElementsByClassName("product-ID-holder");
        for (let i = 0; i < idHolders.length; i++) {
            idHolders[i].textContent = idHolders[i].textContent.padStart(4, '0');
        }

        //イベントリスナーの設定
        document.getElementById("btn-update-details").addEventListener("click", openUpdateDetailsPopup); 
        document.getElementById("btn-alertUpdate").addEventListener("click", openAlertUpdatePopup)
        document.getElementById("btn-delete").addEventListener("click", () => {
            if(confirm("回復には愛すくりーむまでのご連絡が必要となります。削除処理を開始しますか。")){
                document.getElementById("delete-form").submit();
            }
        })
        document.getElementById("order-toggle-button").addEventListener("click", () => {
            if(confirm("自動発注を無効化します。現在の「自動発注限界」がなくなります。よろしいですか。")) {
                document.getElementById("auto-order-toggle-form").submit();
            }
        })

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