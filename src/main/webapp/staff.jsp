<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    //セッション管理
    String staffID = (String) session.getAttribute("staffID");
    if(staffID == null){
        response.sendRedirect("index.jsp");
        return;
    }
    String staffName = (String) session.getAttribute("staffName");
    boolean isAdmin = session.getAttribute("isAdmin") == null ? false : (boolean) session.getAttribute("isAdmin");
    if(!isAdmin){
        response.sendRedirect("error.jsp?errorMsg=" + URLEncoder.encode("管理者権限が必要です。", "UTF-8"));
        return;
    }

    //検索条件
    String receivedName = request.getParameter("searchName");
    if(receivedName != null){
        if(receivedName.isEmpty()) receivedName = null;
    }
    String receivedID = request.getParameter("searchID");
    if(receivedID != null){
        if(receivedID.isEmpty()) receivedID = null;
    }
    String includeQuit = request.getParameter("includeQuit");

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
        sql.append("where deleteFlag = 0 ");
        if(receivedName != null) sql.append(" and name like '%" + receivedName + "%' ");
        if(receivedID != null) sql.append(" and staffID = '" + receivedID + "' ");
        if(includeQuit == null) sql.append("  and quitFlag = 0 ");
        else sql.append(" order by adminFlag desc ");
        rs = stmt.executeQuery(sql.toString());

        while(rs.next()){
            //人事一覧のstaff-List
            staff = new HashMap<String,String>();
            staff.put("staffID", rs.getString("staffID"));
            staff.put("name", rs.getString("name"));
            staff.put("password", rs.getString("password"));
            staff.put("tel", rs.getString("tel"));
            staff.put("address", rs.getString("address"));
            staff.put("workStartDate", rs.getString("workStartDate"));
            staff.put("quitFlag", rs.getString("quitFlag"));
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
<% if(ermsg != null){ %>

    <h2>エラーが発生しました。</h2>
    <p><%=ermsg%></p>

<% } else { %>

    <h1>人事管理</h1>
    <div id="header">
        <div id="text-box">
            <form action="staff.jsp" method="post">
                <label>人事名</label>
                <input type="text" name="searchName" <%if(receivedName != null){%>value="<%=receivedName%>"<%}%> size="20">
                <label>人事ID</label>
                <input type="text" name="searchID" <%if(receivedID != null){%>value="<%=receivedID%>"<%}%> size="10">
                <button type="reset" class="normal-button">クリア</button>
                <button type="submit" class="submit" id="searchBtn">検索</button>
                <br>
                <input type="checkbox" name="includeQuit" id="includeQuit-checkbox" <%if(includeQuit != null){%> checked <%}%>>
                <label>退職者を含む</label>
            </form>
        </div>
        <div id="button-box">
            <button id="btn-add" onclick="add_open()">新規登録</button>
        </div>
    </div>

    <div id="staff-main-container">
<%     if(staffList.isEmpty()){ %>
            <div>
                <p>データがありません。</p>
            </div>
<%      }else {                  %>
<%            for (int i = 0; i<staffList.size(); i++){  %>
                <div class="staff-box<%if(staffList.get(i).get("quitFlag").equals("1")){%> quit<%}%>" onclick="check_open('<%=staffList.get(i).get("staffID")%>')">
                    <p class="staff-id"><%=staffList.get(i).get("staffID") %></p>
                    <p class="staff-name"><%=staffList.get(i).get("name") %></p>
                </div>
<%             }                 %>
<%        }                      %>

    </div>

    <div class="back-button-holder">
        <form action="main.jsp" method="post">
            <button class="normal-button">戻る</button>
        </form>
    </div>

    <div id="obfuscation-banner">
        
    </div>
    
    <!--人事登録のpopup  -->
    <form action="staff-confirm.jsp" method="post">
        <div id="staff_add_popup"  class="popup">
            <div class="popup_header">
                <h2>人事登録</h2>
                <span class="close">✖</span>
            </div>
            <div class="popup_body">
                <div class="form_row">
                    <label for="name">名前</label>
                    <input type="text" id="name" name="name">
                </div>

                <div class="form_row">
                    <label for="tel">電話番号</label>
                    <input type="text" id="tel" name="tel">
                </div>

                <div class="form_row">
                    <label for="address">住所</label>
                    <input type="text" id="address" name="address">
                </div>

                <div class="form_row">
                    <label for="workStartDate">入店日付</label>
                    <input type="date" id="workStartDate" name="workStartDate">
                </div>
            </div>
            <div class="popup_footer">
                <button class="cancel-popup normal-button">キャンセル</button>
                <input type="hidden" name="registerType" value="add">
                <button class="normal-button">登録</button>
            </div>
        </div>
    </form>

    <!--社員情報のpopup  -->
    <div id="staff_check_popup"  class="popup">
        <div class="popup_header">
            <h2>社員情報</h2>
            <span class="close">✖</span>
        </div>
        <table>
            <tr>
                <th class="table-left-side">名前</th>
                <td id="check_name"></td>
            </tr>
            <tr>
                <th>人事ID</th>
                <td id="check_id"></td>
            </tr>
            <tr>
                <th>パスワード</th>
                <td id="check_password"></td>
            </tr>
            <tr>
                <th>電話番号</th>
                <td id="check_tel"></td>
            </tr>
            <tr>
                <th>住所</th>
                <td class="longer-table-text" id="check_address"></td>
            </tr>
            <tr>
                <th>入店日付</th>
                <td id="check_workStartDate"></td>
            </tr>
        </table>

        <div class="popup_footer_flex_column">
            <!--ポップアップ開いた時点でstaffIDの値を設定する。-->
            <button id="open-change-button" class="normal-button">個人情報修正</button>

            <div id="serious-buttons-holder">

                <form action="staff-confirm.jsp" method="post">
                    <input type="hidden" name="registerType" value="quit">
                    <input type="hidden" name="quit_name" id="staffName-toQuit">
                    <input type="hidden" name="quit_staffID" id="staffID-toQuit">
                    <button class="delete-button">退職確定</button>
                </form>

                <form action="staff-confirm.jsp" method="post">
                    <input type="hidden" name="registerType" value="delete">
                    <input type="hidden" name="delete_name" id="staffName-toDelete">
                    <input type="hidden" name="delete_staffID" id="staffID-toDelete">
                    <button class="delete-button">アカウント削除</button>
                </form>

            </div>

        </div>
    </div>

    <!--個人情報修正  -->
    <div id="staff_change_popup"  class="popup">
        <div class="popup_header">
            <h2>個人情報修正</h2>
            <span class="close">✖</span>
        </div>
        <form action="staff-confirm.jsp" method="post">
            <div class="popup_body">

                <div class="form_row">
                    <label for="name_change">名前</label>
                    <input type="text" name="name_change" id="name_change">
                </div>

                <div class="form_row">
                    <label for="staffID">人事ID</label>
                    <input type="text" name="staffID" id="staffID" disabled>
                </div>

                <div class="form_row">
                    <label for="password_change">パスワード</label>
                    <input type="text" name="password_change" id="password_change">
                </div>

                <div class="form_row">
                    <label for="phone_change">電話番号</label>
                    <input type="text" name="phone_change" id="phone_change">
                </div>

                <div class="form_row">
                    <label for="address_change">住所</label>
                    <input type="text" name="address_change" id="address_change">
                </div>

                <div class="form_row">
                    <label for="startDate_change">入店日付</label>
                    <input type="text" name="startDate_change" id="startDate_change" disabled>
                </div>

            </div>

            <div class="popup_footer">
                <button class="normal-button cancel-popup" type="button" onclick="close_all_popups()">キャンセル</button>

                <input type="hidden" name="registerType" value="change">
                <input type="hidden" name="change_staffID" id="staffID-hidden">

                <button class="submit">修正</button>
            </div>

        </form>
    </div>
    <script>
        //ポップアップに使う変数取得
        let obfuscationBanner = document.getElementById("obfuscation-banner");
        obfuscationBanner.addEventListener("click", close_all_popups);
        let body = document.getElementsByTagName("body")[0];
        let allClosures = Array.from(document.getElementsByClassName("close"));
        allClosures.forEach(closure => {
            closure.addEventListener("click", close_all_popups);
        });
        let allCancels = Array.from(document.getElementsByClassName("cancel-popup"));
        allCancels.forEach(cancel => {
            cancel.addEventListener("click", close_all_popups);
        });

        //staffのデータをJSに渡す
        let staffList = [];
        <% for(int i = 0; i < staffList.size(); i++) { %>
            staffList.push({
                'staffID':"<%=staffList.get(i).get("staffID")%>",
                'name':"<%=staffList.get(i).get("name")%>",
                'password':"<%=staffList.get(i).get("password")%>",
                'tel':"<%=staffList.get(i).get("tel")%>",
                'address':"<%=staffList.get(i).get("address")%>",
                'workStartDate':"<%=staffList.get(i).get("workStartDate")%>",
                'quitFlag':"<%=staffList.get(i).get("quitFlag")%>"
            });
        <%  } %>

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
        function check_open(staffID){
            staffList.forEach(staffMember => {
                if(staffMember.staffID === staffID){
                    document.getElementById("check_name").innerHTML = staffMember.name;
                    document.getElementById("staffName-toDelete").value = staffMember.name;
                    document.getElementById("staffName-toQuit").value = staffMember.name;
                    document.getElementById("check_id").innerHTML = staffMember.staffID;
                    document.getElementById("staffID-toDelete").value = staffMember.staffID;
                    document.getElementById("staffID-toQuit").value = staffMember.staffID;
                    document.getElementById("check_password").innerHTML = staffMember.password;
                    document.getElementById("check_tel").innerHTML = staffMember.tel;
                    document.getElementById("check_address").innerHTML = staffMember.address;
                    document.getElementById("check_workStartDate").innerHTML = staffMember.workStartDate;
                    console.log(staffMember.quitFlag)
                    if(staffMember.quitFlag === "1"){
                        document.getElementById("serious-buttons-holder").style.display = "none";
                        console.log("removed")
                    } else {
                        document.getElementById("serious-buttons-holder").style.display = "flex";
                        console.log("didn't remove")
                    }
                }
            });
            document.getElementById("open-change-button").addEventListener("click", () => change_open(staffID));
            document.getElementById("staff_check_popup").classList.add("active");
            obfuscationBanner.style.display = "flex";
            document.body.classList.add("stop-scrolling");

        }

        //個人情報修正
        function change_open(staffID){
            staffList.forEach(staffMember => {
                if(staffMember.staffID === staffID){
                    document.getElementById("name_change").value = staffMember.name;
                    document.getElementById("staffID").value = staffMember.staffID;
                    document.getElementById("staffID-hidden").value = staffMember.staffID;
                    document.getElementById("password_change").value = staffMember.password;
                    document.getElementById("phone_change").value = staffMember.tel;
                    document.getElementById("address_change").value = staffMember.address;
                    document.getElementById("startDate_change").value = staffMember.workStartDate;
                }
            });
            document.getElementById("staff_change_popup").classList.add("active");
            obfuscationBanner.style.display = "flex";
            document.body.classList.add("stop-scrolling");
        }

    </script>

<% } %>
</body>
</html>
