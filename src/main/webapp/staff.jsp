<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%
//    request.setCharacterEncoding("UTF-8");
//    response.setCharacterEncoding("UTF-8");

//    String logout = request.getParameter("logout");
//    if(logout != null){
//        session.removeAttribute("userID");
//    }
//    String userID = (String) session.getAttribute("userID");
//
//    if(userID != null){
//        response.sendRedirect("main.jsp");
//    }

    //String status = request.getParameter("status");
    //String productName = request.getParameter("name");

    //データベースに接続するために使用する変数宣言
    Connection con = null;
    Statement stmt = null;
    StringBuffer sql = null;
    ResultSet rs = null;

    //ローカルのMySqlに接続する設定
    String user = "root";
    String password = "root";
    String url = "jdbc:mysql://localhost/minishopping_site";
    String driver = "com.mysql.jdbc.Driver";

    //確認メッセージ
    StringBuffer ermsg = null;

    HashMap<String,String> staff = null;
    ArrayList<HashMap<String,String>> staffList = new ArrayList<>();

    try {

    //オブジェクトの代入
    Class.forName(driver).newInstance();
    con = DriverManager.getConnection(url, user, password);
    stmt = con.createStatement();

    sql = new StringBuffer();
    sql.append("select staffID, password, name, tel, address, workStartDate, ");
    sql.append("recordTimestamp, adminFlag, quitFlag, deleteFlag from staff ");
    sql.append("where deleteFlag = 0");

    rs = stmt.executeQuery(sql.toString());

    while(rs.next()){
        //修正のためまずデータ取得する
        staff = new HashMap<String,String>();
        staff.put("staffID", rs.getString("staffID"));
        staff.put("name", rs.getString("name"));
        staff.put("password", rs.getString("password"));
        staff.put("tel", rs.getString("tel"));
        staff.put("address", rs.getString("address"));
        staff.put("workStartDate", rs.getString("workStartDate"));

        staffList.add(staff);
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta HTTP-EQUIV="content-type" CONTENT="text/html;charset=UTF-8">
    <link rel="stylesheet" type="text/css" href="css/staff.css">			
    <title>人事管理</title>
</head>
<body>
    <h1>人事管理</h1>
    <div id="header">
        <div id="text-box">
            <form action="staff.jsp" method="post">
                <label>人事ID</label>
                <input type="text" name="staffID" value="" size="10">
                <label>人事名</label>
                <input type="text" name="staffName" value="" size="20">
                <button type="reset" class="normal-button">クリア</button>
                <button type="submit" class="submit" id="searchBtn">検索</button>			
            </form>
        </div>
        <div id="button-box">
            <button id="btn-add" onclick="add_open()">登録</button>
        </div>
    </div>

    <div id="staff-main-container">
<%     if(staffList.isEmpty()){ %>
            <div>
                <p>データがありません。</p>
            </div>
<%      }else {                  %>
<%            for (int i = 0; i<staffList.size(); i++){  %>
                <div class="staff-box">
                    <p class="staff-id"><%=staffList.get(i).get("staffID") %></p>
                    <p class="staff-name"><%=staffList.get(i).get("name") %></p>
                </div>
<%             }                 %>
<%        }                      %>

    </div>

    <div class="back-button-holder">
        <form action="main.html" method="post">
            <button class="normal-button">戻る</button>
        </form>
    </div>

    <div id="obfuscation-banner">
        
    </div>
    
    <!--人事登録のpopup  -->
    <div id="staff_add_popup"  class="popup">
        <div class="popup_header">
            <h2>人事登録</h2>
            <span class="close">✖</span>
        </div>
        <div class="popup_body">
            <div class="form_row">
                <label for="staff_name">名前</label>
                <input type="text" id="staff_name">
            </div>

            <div class="form_row">
                <label for="staff_phone">電話番号</label>
                <input type="text" id="staff_phone">
            </div>
            
            <div class="form_row">
                <label for="staff_address">住所</label>
                <input type="text" id="staff_address">
            </div>

            <div class="form_row">
                <label for="staff_comeday">入店日付</label>
                <input type="datetime-local" id="staff_comeday">
            </div>
        </div>
        <div class="popup_footer">
            <button class="cancel-popup normal-button">キャンセル</button>
            <form action="staff-confirm.html" method="post">
                <button class="normal-button">登録</button>
            </form>
        </div>
    </div>  

    <!--社員情報のpopup  -->
    <div id="staff_check_popup"  class="popup">
        <div class="popup_header">
            <h2>社員情報</h2>
            <span class="close">✖</span>
        </div>
    
        <table>
            <tr>
                <th class="table-left-side">名前</th>
                <td>伊藤 太郎</td>
            </tr>
            <tr>
                <th>人事ID</th>
                <td>123456</td>
            </tr>
            <tr>
                <th>パスワード</th>
                <td>A12b34C</td>
            </tr>
            <tr>
                <th>電話番号</th>
                <td>12-4321-2222</td>
            </tr>
            <tr>
                <th>住所</th>
                <td class="longer-table-text">静岡県浜松市</td>
            </tr>
            <tr>
                <th>入店日付</th>
                <td>2023/02/11</td>
            </tr>
        </table>
        
        <div class="popup_footer">
            <button onclick="change_open()" class="normal-button">個人情報修正</button>
            <!--ポップアップ開いた時点でstaffIDの値を設定する。-->
            <form action="staff-confirm.html" method="post">
                <input type="hidden" name="status" value="delete">
                <input type="hidden" name="staffID" value="">
            </form>

            <form action="staff-confirm.html" method="post">
                <input type="hidden" name="status" value="delete">
                <input type="hidden" name="staffID" value="">
                <button class="delete-button">アカウント削除</button>
            </form>
        </div>
    </div>


    <!--個人情報修正  -->
    <div id="staff_change_popup"  class="popup">
        <div class="popup_header">
            <h2>個人情報修正</h2>
            <span class="close">✖</span>
        </div>
        <form action="staff-confirm.html" method="post">

            <div class="popup_body">

                <div class="form_row">
                    <label for="name_change">名前</label>
                    <input type="text" name="name" id="name_change" value="伊藤 太郎">
                </div>
                
                <div class="form_row">
                    <label for="id_change">人事ID</label>
                    <input type="text" name="id" id="id_change" value="123456" disabled>
                </div>
        
                <div class="form_row">
                    <label for="password_change">パスワード</label>
                    <input type="text" name="password" id="password_change" value="A12b34C">
                </div>
        
                <div class="form_row">
                    <label for="phone_change">電話番号</label>
                    <input type="text" name="tel" id="phone_change" value="12-4321-2222">
                </div>
                
                <div class="form_row">
                    <label for="address_change">住所</label>
                    <input type="text" name="address" id="address_change" value="静岡県清水">
                </div>

                <div class="form_row">
                    <label for="startDate_change">入店日付</label>
                    <input type="text" name="startDate" id="startDate_change" value="静岡県清水" disabled>
                </div>

            </div>

            <div class="popup_footer">
                <button class="normal-button cancel-popup" type="button">キャンセル</button>
                <button class="submit">修正</button>
            </div>

        </form>
    </div>
    <script>
        //ポップアップに使う変数取得
        let obfuscationBanner = document.getElementById("obfuscation-banner");
        obfuscationBanner.addEventListener("click", close_all_popups);
        let body = document.getElementsByTagName("body")[0];
        let staffBoxes = Array.from(document.getElementsByClassName("staff-box"));
        staffBoxes.forEach(staffBox => {
            staffBox.addEventListener("click", check_open);
        });
        let allClosures = Array.from(document.getElementsByClassName("close"));
        allClosures.forEach(closure => {
            closure.addEventListener("click", close_all_popups);
        });
        let allCancels = Array.from(document.getElementsByClassName("cancel-popup"));
        allCancels.forEach(cancel => {
            cancel.addEventListener("click", close_all_popups);
        });

        function close_all_popups(){    
            document.getElementById("staff_add_popup").classList.remove("active");
            document.getElementById("staff_check_popup").classList.remove("active");
            document.getElementById("staff_change_popup").classList.remove("active");
            obfuscationBanner.style.display = "none";
            body.classList.remove("stop-scrolling");
        }

        //人事登録
        function add_open(){ 
            document.getElementById("staff_add_popup").classList.add("active");
            obfuscationBanner.style.display = "flex";
            document.body.classList.add("stop-scrolling");
        }

        //個人情報確認
        function check_open(){
            document.getElementById("staff_check_popup").classList.add("active");
            obfuscationBanner.style.display = "flex";
            document.body.classList.add("stop-scrolling");
        
        }

        //個人情報修正
        function change_open(){
            document.getElementById("staff_change_popup").classList.add("active");
            obfuscationBanner.style.display = "flex";
            document.body.classList.add("stop-scrolling");
        }

    </script>

</body>
</html>
