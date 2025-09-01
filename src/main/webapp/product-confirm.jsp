<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="javax.servlet.http.Part" %>
<%@ page import="java.io.File" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.time.Instant" %>
<%@ page import="java.nio.file.Files" %>
<%@ page import="java.nio.file.StandardCopyOption" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String registerType = request.getParameter("registerType");

    //修正と削除の場合のパラメータ
    String productID = request.getParameter("productID");

    //追加の場合のパラメータ。enctype="multipart/form-data"の形で来るのでPartsとして設定する必要があります。
    String productName = request.getParameter("name");
    String maker = request.getParameter("maker");
    String flavor = request.getParameter("flavor");
    String type = request.getParameter("type");
    String cost = request.getParameter("cost");
    String price = request.getParameter("price");
    String instockQuantity = request.getParameter("instockQuantity");
    String alertNumber = request.getParameter("alertNumber");
    String autoOrderLimit = request.getParameter("autoOrderLimit");
    String autoOrderQuantity = request.getParameter("autoOrderQuantity");
    String imageFileName = "";
    Part imagePart = request.getPart("image");

    //削除
    String quantity;
    if(registerType.equals("add")){

        //追加の場合は今の時点で画像を登録する
        PrintWriter printWriterOut;
        printWriterOut = response.getWriter();

        //出力場所
        File uploads = new File("C:\\Users\\pipit\\IdeaProjects\\IceCreamHanbai\\src\\main\\webapp\\images");
        InputStream fileContent = imagePart.getInputStream();

        //現在時刻を取得してファイル名に設定する。
        long timestampMillis = Instant.now().toEpochMilli();    //新しいファイル名になる
        //拡張子を取得
        String fileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
        String ext = fileName.substring(fileName.lastIndexOf('.'));
        //ファイル名を設定する。
        imageFileName = timestampMillis + ext;

        //書き込む
        File image = new File(uploads, imageFileName);
        Files.copy(fileContent, image.toPath(), StandardCopyOption.REPLACE_EXISTING);
    }
    else if(registerType.equals("delete")){
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

        try {

            //オブジェクトの代入
            Class.forName(driver).newInstance();
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            sql = new StringBuffer();
            sql.append("select name, quantity, image from products ");
            sql.append("where deleteFlag = 0 and productID=");
            sql.append(productID);

            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                productName = rs.getString("name");
                quantity = rs.getString("quantity");
                imageFileName = rs.getString("image");
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
    }

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品登録確認</title>
    <link rel="stylesheet" href="css/product-confirm.css">
</head>
<body>

    <div id="everything-wrapper">

        <%
            //追加の場合
            if (registerType.equals("add")){

        %>


            <h2>商品追加の入力確認</h2>

            <div id="main-section-wrapper">

                <div id="left-section-wrapper">

                    <img class="image" src="images/<%=imageFileName%>" width="100" height="100" alt="<%=productName%>">

                </div>

                <div id="right-section-wrapper">

                    <table>
                        <tr>
                            <td class="table-left-side">商品名</td>
                            <td><%=productName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">メーカー</td>
                            <td><%=maker%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">味</td>
                            <td><%=flavor%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">種類</td>
                            <td><%=type%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">購入コスト</td>
                            <td><%=cost%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">値段</td>
                            <td><%=price%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">在庫数</td>
                            <td><%=instockQuantity%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">autoOrderLimit</td>
                            <td><%=autoOrderLimit%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">autoOrderQuantity</td>
                            <td><%=autoOrderQuantity%></td>
                        </tr>
                    </table>

                </div>

            </div>

            <div id="buttons-holder">
                <!--どこから来たのか非表示のinputでわかるはずなので「内容を修正」ボタンで正しい場所へ戻される。-->
                <!--設定変更の場合は詳細ページに戻ったら自動的に正しいポップアップを出すようにする。-->
                <form action="products.jsp" method="post">
                    <input type="hidden" name="status" value="returnFromAdd">

                    <input type="hidden" name="name" value="<%=productName%>">
                    <input type="hidden" name="maker" value="<%=maker%>">
                    <input type="hidden" name="flavor" value="<%=flavor%>">
                    <input type="hidden" name="type" value="<%=type%>">
                    <input type="hidden" name="cost" value="<%=cost%>">
                    <input type="hidden" name="price" value="<%=price%>">
                    <input type="hidden" name="instockQuantity" value="<%=instockQuantity%>">
                    <input type="hidden" name="alertNumber" value="<%=alertNumber%>">
                    <input type="hidden" name="autoOrderLimit" value="<%=autoOrderLimit%>">
                    <button class="normal-button">内容を修正する</button>
                </form>

                <form action="product-register.html" method="post">

                    <input type="hidden" name="registerType" value="<%=registerType%>">

                    <input type="hidden" name="name" value="<%=productName%>">
                    <input type="hidden" name="maker" value="<%=maker%>">
                    <input type="hidden" name="flavor" value="<%=flavor%>">
                    <input type="hidden" name="type" value="<%=type%>">
                    <input type="hidden" name="cost" value="<%=cost%>">
                    <input type="hidden" name="price" value="<%=price%>">
                    <input type="hidden" name="instockQuantity" value="<%=instockQuantity%>">
                    <input type="hidden" name="alertNumber" value="<%=alertNumber%>">
                    <input type="hidden" name="autoOrderLimit" value="<%=autoOrderLimit%>">

<%--                    <input type="hidden" name="image" value="<%=image%>">--%>
                    <!--処理による文字列を変更する。特に削除の場合は、ボタンを赤くする-->
                    <button class="normal-button">登録</button>
                </form>
            </div>

        <%
            } else if(registerType.equals("delete")){
        %>

            <h2>商品削除の確認</h2>
        <!-- 画像を表示して -->
        <!-- 商品ID + 商品名 -->

            <div id="buttons-holder">
                <!--どこから来たのか非表示のinputでわかるはずなので「内容を修正」ボタンで正しい場所へ戻される。-->
                <!--設定変更の場合は詳細ページに戻ったら自動的に正しいポップアップを出すようにする。-->
                <form action="products-details.jsp" method="post">
                    <button class="normal-button" type="button">キャンセル</button>
                </form>

                <form action="product-register.html" method="post">

                    <input type="hidden" name="registerType" value="<%=registerType%>">
                    <input type="hidden" name="productID" value="<%=productID%>">

                    <!--処理による文字列を変更する。特に削除の場合は、ボタンを赤くする-->
                    <button class="delete-button">削除</button>
                </form>
            </div>

        <%
            }
        %>





    </div>

</body>
</html>