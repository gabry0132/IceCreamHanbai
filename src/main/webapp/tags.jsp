<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String tag = request.getParameter("tag");
    String tagTypeID = request.getParameter("tagTypeID");
    String tagToDeleteID = request.getParameter("tagToDelete");

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
    HashMap<String,String> map;
    HashMap<String,String> typeMap;
    ArrayList<HashMap<String,String>> tags = new ArrayList<>();
    ArrayList<HashMap<String,String>> tagtypes = new ArrayList<>();
    //追加と削除のチェックに使う
    int updatedRows = 0;
    boolean alreadyExisting = false;

    try {
        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        //新しいタグを登録する場合
        if(tag != null){
            //同じタグタイプで同じ名前の複数タグを作成させないため、取得してチェックする
            sql = new StringBuffer();
            sql.append("select value from tags where tagTypeId = ");
            sql.append(tagTypeID);
            sql.append(" and deleteFlag = 0");

            rs = stmt.executeQuery(sql.toString());
            ArrayList<String> names = new ArrayList<>();
            while(rs.next()){
                names.add(rs.getString("value"));
            }

            if(names.contains(tag)){
                alreadyExisting = true;
            } else {
                sql = new StringBuffer();
                sql.append("insert into tags(tagTypeID, value) values (");
                sql.append(tagTypeID);
                sql.append(", '");
                sql.append(tag);
                sql.append("')");
    //            System.out.println(sql.toString());

                updatedRows += stmt.executeUpdate(sql.toString());

                if(updatedRows == 0){
                    ermsg = new StringBuffer();
                    ermsg.append("追加が失敗しました。");
                }
            }
        }

        //削除の場合は
        if(tagToDeleteID != null){
            sql = new StringBuffer();
            sql.append("update tags set deleteFlag = 1 where tagID = ");
            sql.append(tagToDeleteID);

            updatedRows += stmt.executeUpdate(sql.toString());

            if(updatedRows == 0){
                ermsg = new StringBuffer();
                ermsg.append("削除が失敗しました。");
            }
        }


        sql = new StringBuffer();
        sql.append("select tagID, value, type, tagtypes.tagTypeID from tags inner join tagtypes on tags.tagtypeID = tagtypes.tagtypeID where tags.deleteFlag=0");

        rs = stmt.executeQuery(sql.toString());
        while (rs.next()){
            map = new HashMap<>();
            map.put("tagID", rs.getString("tagID"));
            map.put("value", rs.getString("value"));
            map.put("type", rs.getString("type"));
            boolean newType = true;
            for (int i = 0; i < tagtypes.size(); i++) {
                if(tagtypes.get(i).get("type").equals(rs.getString("type"))){
                    newType = false;
                }
            }
            if(newType){
                typeMap = new HashMap<>();
                typeMap.put("tagTypeID", rs.getString("tagTypeID"));
                typeMap.put("type", rs.getString("type"));
                tagtypes.add(typeMap);
            }

            tags.add(map);
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
    <title>タグ管理画面</title>
         <link rel="stylesheet" type="text/css" href="css/tag.css">

</head>
<body>
    <h1>
        タグ管理
    </h1>

    <% if(ermsg != null){ %>

        <h4>エラーが発生しました</h4>
        <p><%=ermsg%></p>

    <% } else { %>


    <div id="search-box">
        <input type="text" class="search-input" id="search-input" placeholder="検索">
    </div>

    <div id="all-tag-types-holder">

        <% if(tags.size() == 0){ %>

            <h4>タグがありません。</h4>

        <% } else { %>

            <%
                for (int i = 0; i < tagtypes.size(); i++) {
            %>

                <div class="type-holder">
                    <p class="type-intro"><%=tagtypes.get(i).get("type")%></p>
                    <div class="types-button-holder">
                        <div class="tag-container">
                            <%
                                for (int j = 0; j < tags.size(); j++) {
                                    if(tags.get(j).get("type").equals(tagtypes.get(i).get("type"))){
                            %>

                                <form action="tags.jsp" method="post" name="<%=tags.get(j).get("tagID")%>">
                                    <input type="hidden" name="tagToDelete" value="<%=tags.get(j).get("tagID")%>">
                                    <button class="tag" type="button" onclick= "startDelete('<%=tags.get(j).get("tagID")%>','<%=tagtypes.get(i).get("type")%>')"><span class="tag-text"><%=tags.get(j).get("value")%></span><span class="tag-close">✕</span></button>
                                </form>


                            <%
                                    }
                                }
                            %>
                        </div>
                        <div class="add-button-holder">
                            <button type="button" class="add-button normal-button" onclick="openPopup('<%=tagtypes.get(i).get("type")%>','<%=tagtypes.get(i).get("tagTypeID")%>')">＋追加</button>
                        </div>
                    </div>
                </div>

            <%
                }
            %>

        <% } %>

    </div>

    <div id="modoru-holder">
        <form action="main.html" method="post">
            <button id="modoru" class="normal-button">戻る</button>
        </form>
    </div>

    <div id="black-background" onclick="closePopup()">

    </div>

    <div id="add-popup">
        <form action="tags.jsp" method="post" id="add-form">

            <div id="add-top">
                <h3>タグを追加する</h3>
            </div>
            
            <div id="add-center">
                <input type="text" name="tag" id="tag-search" required>
            </div>

            <input type="hidden" name="tagTypeID" id="tagTypeIDHolder" value="">

            <div id="add-bottom">
                <button type="button" onclick="closePopup()">キャンセル</button>
                <button type="submit">追加</button>
            </div>

        </form>
    </div>

    <script>
        //追加処理ですでに存在する項目だったらこの時点で知らせる。
        let alreadyExists = <%=alreadyExisting%>;
        if(alreadyExists) alert("既に存在します。");

        let tags = Array.from(document.getElementsByClassName("tag-text"));
        let tagBoxes = Array.from(document.getElementsByClassName("tag"));
        let searchBox = document.getElementById("search-input");
        searchBox.addEventListener("input", applySearch);

        function applySearch(){
            console.log(searchBox.value);
            if (searchBox.value == "" || searchBox.value == undefined) return;
            for (let i = 0; i < tags.length; i++) {
                console.log("we in here");
                const tagText = tags[i];
                if(tagText.innerHTML.includes(searchBox.value)){
                    tagBoxes[i].style.display = "flex";
                } else {
                    tagBoxes[i].style.display = "none";

                }
            }
        }

        function startDelete(tagID, tagType){
            form = document.getElementsByName(tagID)[0];
            if(confirm(tagType + "を削除します。よろしいですか。")){
                form.submit();
            }
        }

        function openPopup(type, tagTypeID){
            let popupTitle = document.getElementsByTagName("h3")[0];
            popupTitle.innerHTML = type + "を追加する";
            document.getElementById("tagTypeIDHolder").value = tagTypeID;
            document.getElementById("black-background").style.display = "flex";
            document.getElementById("add-popup").style.display = "flex";
        }
        
        function closePopup(){
            document.getElementById("black-background").style.display = "none";
            document.getElementById("add-popup").style.display = "none";

        }

    </script>

    <% } %>

</body>
</html>