<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    // データベース接続情報
    String USER = "root";
    String PASSWORD = "root";
    String URL = "jdbc:mysql://localhost/icehanbaikanri";
    String DRIVER = "com.mysql.jdbc.Driver";

    // エラーメッセージ格納用
    String ERMSG = null;

    // 結果格納用リスト
    ArrayList<HashMap<String, String>> list = new ArrayList<>();

    try {
        // JDBCドライバのロード
        Class.forName(DRIVER);

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
                list.add(map);
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

            <form action="sales.html" method="post" id="search-form">
                
                <div id="search-params-container">

                    <div id="pulldown-menus-container">
                        
                        <select name="product" id="product-Search">
                            <option hidden disabled selected value>商品を選択</option>
                            <option value="1">0001 ガリガリ君</option>
                            <option value="2">0002 </option>
                            <option value="3">0003 </option>
                            <option value="4">0004 </option>
                            <option value="5">0005 </option>
                        </select>

                        <select name="staff" id="staff-Search">
                            <option hidden disabled selected value>販売の人事</option>
                            <option value="1">ヨウさん</option>
                            <option value="2">ガブさん</option>
                            <option value="3">かくくん</option>
                            <option value="4">ゆうがくん</option>
                            <option value="5">田中さん</option>
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
            <form action="main.html" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

        <div id="sales-holder">
<%
            for(int i=0; i<list.size(); i++){
%>
                <div class="sale-box">
                    <div class="sale-image-txt-holder">
                        <!--?product=xxx&previousPage=sales.jspを追加する。-->
                        <a href="product-details.jsp" class="image-wrapper-anchor">
                            <img class="sale-image" src="images/ice1.png" width="100" height="100" alt="ice1">
                        </a>
                        <p class="sale-text"><%= list.get(i).get("productName") %>が <%= list.get(i).get("dateTime") %>に <%= list.get(i).get("quantity") %>個 販売されました。(<%= list.get(i).get("staffName") %>より)</p>
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
%>

        </div>

        <div class="back-button-holder">
            <form action="main.html" method="post">
                <button class="normal-button">戻る</button>
            </form>
        </div>

        <!--本来は複数のaタグにするか、スパンのテキストに応じてJavaScriptで検索開始-->
        <div id="page-selector-wrapper">
            <a href="sales.html">
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
                    <img src="images/ice1.png" class="sale-image" alt="ice1" width="120" height="120">
                    <select name="product" id="product">
                        <!--動的に画像を変更する-->
                        <option hidden disabled selected value>商品を選択</option>
                        <option value="1">0001 ガリガリ君</option>
                        <option value="2">0002 </option>
                        <option value="3">0003 </option>
                        <option value="4">0004 </option>
                        <option value="5">0005 </option>
                    </select>
                </div>
    
                <div id="create-middle-section">
                    <table>
                        <tr>
                            <td class="table-left-side">販売日時</td>
                            <td>
                                <div class="sale-time-setting">
                                    <div class="sale-time-button-holder">
                                        <input type="radio" onclick="checkRadioCreate()" name="sale-time-create" id="now-time-create" value="今現在" checked>今現在
                                        <input type="radio" onclick="checkRadioCreate()" name="sale-time-create" id="adjust-time-create" value="指定する">指定する
                                    </div>
                                    <input type="datetime-local" name="sale-time-textbox" class="sale-time-textbox">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>販売担当</td>
                            <td><input type="text" class="sale-staff" id="sale-staff-create" value="入合憂政" disabled></td>
                        </tr>
                        <tr>
                            <td>販売個数</td>
                            <!--売上データ作成のポップアップだけは、販売個数のmaxを対象の商品の在庫数に設定する。-->
                            <!--画像を変換する時点で、販売個数をチェックする。1以上あれば普通の動きで必ず個数を1に設定する。ゼロだったら登録させないように-->
                            <!--JavaでもらうデータをJSに渡す必要がある。-->
                            <td><input type="number" class="sale-quantity-input" id="sale-quantity-create" min="1" max="999" value="1"></td>
                        </tr>
                    </table>
                </div>
    
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
                        <option value="1">0001 ガリガリ君</option>
                        <option value="2">0002 </option>
                        <option value="3">0003 </option>
                        <option value="4">0004 </option>
                        <option value="5">0005 </option>
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
        
        saleQuantities.forEach(saleQuantity => {
            saleQuantity.addEventListener("input", checkQuantity);
        });

        blackBackground.addEventListener("click", closeAllPopups);

        function checkRadioCreate(){
            if(document.getElementById("now-time-create").checked){
                inputBoxes[0].style.display = "none";
                inputBoxes[0].value = "";
            }else if(document.getElementById("adjust-time-create").checked){
                inputBoxes[0].style.display = "flex";
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
        
        function checkQuantity(event){
            // console.log(event.currentTarget);
            let input = event.currentTarget;
            if(isNaN(input.value) || input.value == "") input.value = 1;
            //parseInt()しないとJSは型変換してくれないので比べられない
            let quantity = parseInt(input.value);
            let min = parseInt(input.min);
            let max = parseInt(input.max);

            if(quantity < min)input.value = String(min);
            if(quantity > max)input.value = String(max);
        }
    </script>
    
</body>
</html>