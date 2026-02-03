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
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.EOFException" %>
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

    String registerType = request.getParameter("registerType");

    //修正と削除の場合のパラメータ
    String productID = request.getParameter("productID");

    //追加の場合のパラメータ。enctype="multipart/form-data"の画像データも含みます。
    String productName = request.getParameter("name");  //detailsUpdateの場合ももらいます
    String maker = request.getParameter("maker");       //detailsUpdateの場合ももらいます
    String flavor = request.getParameter("flavor");     //detailsUpdateの場合ももらいます
    String type = request.getParameter("type");         //detailsUpdateの場合ももらいます
    String cost = request.getParameter("cost");         //detailsUpdateの場合ももらいます
    String price = request.getParameter("price");       //detailsUpdateの場合ももらいます
    String instockQuantity = request.getParameter("instockQuantity");   //削除の場合も使います。
    if(instockQuantity != null){
        if(instockQuantity.isEmpty()) instockQuantity = "0";
    }
    String alertNumber = request.getParameter("alertNumber");
    if(alertNumber != null){
        if(alertNumber.isEmpty()) alertNumber = "0";
    }
    String autoOrderLimit = request.getParameter("autoOrderLimit");
    String autoOrderQuantity = request.getParameter("autoOrderQuantity");
    String confirmDays = request.getParameter("confirmDays");
    String shippingDays = request.getParameter("shippingDays");
    String unitPerBox = request.getParameter("unitPerBox");
    String imageFileName = "";                          //detailsUpdateの場合も使います
    Part imagePart = null;
    if(registerType.equals("add") || registerType.equals("detailsUpdate")){
        imagePart = request.getPart("image");           //detailsUpdateの場合ももらいます
    }
    String makerName = "";
    String flavorName = "";
    String typeName = "";

    //detailsUpdate
    String existingName = "";
    String existingMaker = "";
    String existingMakerName = "";
    String existingFlavor = "";
    String existingFlavorName = "";
    String existingType = "";
    String existingTypeName = "";
    String existingCost = "";
    String existingPrice = "";
    String existingImageFileName = "";
    boolean allFieldsIdentical = true;

    //alertUpdate
    String newAlertNum = request.getParameter("alertNumber");
    String newAutoOrderLimit = request.getParameter("autoOrderLimit");
    String newAutoOrderQuantity = request.getParameter("autoOrderQuantity");
    String existingAlertNum = "";
    String existingAutoOrderLimit = "";
    String existingAutoOrderQuantity = "";

    //削除
//    String quantity;

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

    try {

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();
        sql = new StringBuffer();

        if(registerType.equals("add")){

            //表示に必要なタグ名を取得します。
            sql.append("select tagID, value from tags where deleteFlag = 0 and tagID in(");
            sql.append(maker);
            sql.append(",");
            sql.append(type);
            sql.append(",");
            sql.append(flavor);
            sql.append(")");
            rs = stmt.executeQuery(sql.toString());

            while(rs.next()){
                if(rs.getString("tagID").equals(maker)) makerName = rs.getString("value");
                else if(rs.getString("tagID").equals(flavor)) flavorName = rs.getString("value");
                else if(rs.getString("tagID").equals(type)) typeName = rs.getString("value");
            }

            //追加の場合は今の時点で画像を登録する
            PrintWriter printWriterOut;
            printWriterOut = response.getWriter();

            //出力の場所を動的に指定する
            String relativePath = "\\images";
            String absolutePath = application.getRealPath(relativePath);
            File uploads = new File(absolutePath);

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
        else if(registerType.equals("detailsUpdate")){

            if(!isAdmin) throw new Exception("管理者権限が必要です。");

            sql.append("select name, purchaseCost, price, image from products where productID = ");
            sql.append(productID);

            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                existingName = rs.getString("name");
                existingCost = rs.getString("purchaseCost");
                existingPrice = rs.getString("price");
                existingImageFileName = rs.getString("image");

                if(!existingName.equals(productName) || !existingCost.equals(cost) || !existingPrice.equals(price) || imagePart.getSize() > 0){
                    allFieldsIdentical = false;
                }
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }

            sql = new StringBuffer();
            sql.append("select tags.tagID, value, type from hastags inner join tags on hastags.tagID = tags.tagID inner join tagtypes on tags.tagTypeID = tagtypes.tagTypeID ");
            sql.append("where hastags.productID = ");
            sql.append(productID);

            rs = stmt.executeQuery(sql.toString());

            while(rs.next()){
                if(rs.getString("type").equals("メーカー")) {
                    existingMaker = rs.getString("tagID");
                    existingMakerName = rs.getString("value");
                    if(!existingMaker.equals(maker)) allFieldsIdentical = false;
                }
                else if(rs.getString("type").equals("味")) {
                    existingFlavor = rs.getString("tagID");
                    existingFlavorName = rs.getString("value");
                    if(!existingFlavor.equals(flavor)) allFieldsIdentical = false;
                }
                else if(rs.getString("type").equals("種類")) {
                    existingType = rs.getString("tagID");
                    existingTypeName = rs.getString("value");
                    if(!existingType.equals(type)) allFieldsIdentical = false;
                }
            }

            if(!allFieldsIdentical){

                //メーカー、味、種類の新しい項目の新しい名称を表示するために取得します。
                sql = new StringBuffer();
                sql.append("select tagID, value from tags where tagID in (");
                sql.append(maker);
                sql.append(",");
                sql.append(flavor);
                sql.append(",");
                sql.append(type);
                sql.append(")");

                rs = stmt.executeQuery(sql.toString());

                while(rs.next()){
                    if(rs.getString("tagID").equals(maker)) makerName = rs.getString("value");
                    else if(rs.getString("tagID").equals(flavor)) flavorName = rs.getString("value");
                    else if(rs.getString("tagID").equals(type)) typeName = rs.getString("value");
                }

                //画像がアップロードされた場合は本ページに両方表示できるようにアップロードします。
                //登録確定すれば、古い画像の削除とデータベースに新しい画像のファイル名書き込みは次のproduct-confirm.jspで行います。
                if(imagePart.getSize() > 0){
                    PrintWriter printWriterOut;
                    printWriterOut = response.getWriter();

                    //出力の場所を動的に指定する
                    String relativePath = "\\images";
                    String absolutePath = application.getRealPath(relativePath);
                    File uploads = new File(absolutePath);

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
            }

        }
        else if(registerType.equals("alertUpdate")){

            if(!isAdmin) throw new Exception("管理者権限が必要です。");

            sql.append("select name, alertNumber, autoOrderLimit, autoOrderQuantity, unitPerBox, image from products where productID = ");
            sql.append(productID);

            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                productName = rs.getString("name");
                existingAlertNum = rs.getString("alertNumber");
                existingAutoOrderLimit = rs.getString("autoOrderLimit");
                existingAutoOrderQuantity = rs.getString("autoOrderQuantity");
                unitPerBox = rs.getString("unitPerBox");
                imageFileName = rs.getString("image");
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }

        }
        else if(registerType.equals("delete")){

            if(!isAdmin) throw new Exception("管理者権限が必要です。");

            sql.append("select name, quantity, image from products ");
            sql.append("where deleteFlag = 0 and productID = ");
            sql.append(productID);

            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                productName = rs.getString("name");
                instockQuantity = rs.getString("quantity");
                imageFileName = rs.getString("image");
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }



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

                    <img class="image" src="<%=request.getContextPath()%>/images/<%=imageFileName%>" width="100" height="100" alt="<%=productName%>">

                </div>

                <div id="right-section-wrapper">

                    <table>
                        <tr>
                            <td class="table-left-side">商品名</td>
                            <td><%=productName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">メーカー</td>
                            <td><%=makerName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">味</td>
                            <td><%=flavorName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">種類</td>
                            <td><%=typeName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">購入コスト</td>
                            <td><%=cost%>円</td>
                        </tr>
                        <tr>
                            <td class="table-left-side">値段</td>
                            <td><%=price%>円</td>
                        </tr>
                        <% if(Integer.parseInt(instockQuantity) > 0){ %>
                            <tr>
                                <td class="table-left-side">在庫数</td>
                                <td><%=instockQuantity%>個</td>
                            </tr>
                        <% } %>
                        <% if(Integer.parseInt(alertNumber) > 0){ %>
                            <tr>
                                <td class="table-left-side">アラート限界</td>
                                <td><%=alertNumber%>個</td>
                            </tr>
                        <% } %>
                        <tr>
                            <td class="table-left-side">自動発注限界</td>
                            <td><%=autoOrderLimit%>個</td>
                        </tr>
                        <tr>
                            <td class="table-left-side">１箱数量</td>
                            <td><%=unitPerBox%>個</td>
                        </tr>
                        <tr>
                            <td class="table-left-side">自動発注数量</td>
                            <td id="totalQuantityPerOrder"><%=autoOrderQuantity%>箱</td>
                        </tr>
                        <tr>
                            <td class="table-left-side">発注確認日数</td>
                            <td><%=confirmDays%>日</td>
                        </tr>
                        <tr>
                            <td class="table-left-side">発注配達日数</td>
                            <td><%=shippingDays%>日</td>
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
                    <input type="hidden" name="autoOrderQuantity" value="<%=autoOrderQuantity%>">
                    <input type="hidden" name="confirmDays" value="<%=confirmDays%>">
                    <input type="hidden" name="shippingDays" value="<%=shippingDays%>">
                    <input type="hidden" name="unitPerBox" value="<%=unitPerBox%>">
                    <input type="hidden" name="imageFileName" value="<%=imageFileName%>">

                    <button class="normal-button">内容を修正する</button>
                </form>

                <form action="product-register.jsp" method="post">

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
                    <input type="hidden" name="autoOrderQuantity" value="<%=autoOrderQuantity%>">
                    <input type="hidden" name="confirmDays" value="<%=confirmDays%>">
                    <input type="hidden" name="shippingDays" value="<%=shippingDays%>">
                    <input type="hidden" name="unitPerBox" value="<%=unitPerBox%>">
                    <input type="hidden" name="imageFileName" value="<%=imageFileName%>">

                    <button class="normal-button">登録</button>
                </form>
            </div>

        <%
            //アラート・自動発注設定の変更の場合
            } else if(registerType.equals("alertUpdate")){
        %>

            <h2>商品アラート・自動発注設定変更の確認</h2>

            <div id="alertUpdate-wrapper">

                <div id="alertUpdate-top-row">
                    <img class="image" src="<%=request.getContextPath()%>/images/<%=imageFileName%>" width="90" height="90" alt="<%=productName%>">
                    <p><b><%=productName%></b></p>
                </div>

                <table>
                    <tr>
                        <th></th>
                        <th>更新前</th>
                        <th></th>
                        <th>更新後</th>
                    </tr>
                    <tr>
                        <td class="row-intro">アラート限界</td>
                        <td><%=existingAlertNum%></td>
                        <td> ⇒ </td>
                        <td><%=newAlertNum%></td>
                    </tr>
                    <tr>
                        <td class="row-intro">自動発注限界</td>
                        <td><%=existingAutoOrderLimit%></td>
                        <td> ⇒ </td>
                        <td><%=newAutoOrderLimit%></td>
                    </tr>
                    <tr>
                        <td class="row-intro">自動発注数量</td>
                        <td><%=existingAutoOrderQuantity%></td>
                        <td> ⇒ </td>
                        <td><%=newAutoOrderQuantity%></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td>合計: <%=Integer.parseInt(newAutoOrderQuantity) * (Integer.parseInt(unitPerBox))%>個</td>
                    </tr>
                </table>

                <div id="alertUpdate-buttons-holder">

                    <form action="product-details.jsp?productID=<%=productID%>" method="post">
                        <button class="normal-button">キャンセル</button>
                    </form>

                    <form action="product-register.jsp" method="post">
                        <input type="hidden" name="productID" value="<%=productID%>">
                        <input type="hidden" name="alertNumber" value="<%=newAlertNum%>">
                        <input type="hidden" name="autoOrderLimit" value="<%=newAutoOrderLimit%>">
                        <input type="hidden" name="autoOrderQuantity" value="<%=newAutoOrderQuantity%>">
                        <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">
                        <input type="hidden" name="registerType" value="alertUpdate">

                        <button class="normal-button">登録</button>
                    </form>

                </div>


            </div>


        <%
            //詳細情報の更新の場合
            } else if(registerType.equals("detailsUpdate")){
        %>

            <h2>商品詳細情報変更の確認</h2>

            <div id="update-wrapper">

                <div id="update-top-row">
                    <img class="image" src="<%=request.getContextPath()%>/images/<%=existingImageFileName%>" width="90" height="90" alt="<%=existingName%>">
                    <p><b><%=existingName%></b></p>
                </div>

                <% if(allFieldsIdentical){ %>

                    <p id="nothing-changes-warning">変更する項目がありません。</p>
                    <br>
                    <form id="update-return-form" action="product-details.jsp" method="post">
                        <input type="hidden" name="productID" value="<%=productID%>">
                        <button class="normal-button">戻る</button>
                    </form>

                <% } else { %>

                    <table>
                        <tr>
                            <th></th>
                            <th>更新前</th>
                            <th></th>
                            <th>更新後</th>
                        </tr>
                        <!-- この場合だけ変更する項目が多いため本ページで変更されない項目が表示されないようにします。変更する項目がなければ何もさせない形になります。 -->
                        <% if(imagePart.getSize() > 0){ %>
                            <tr>
                                <td class="row-intro">画像</td>
                                <td><img src="<%=request.getContextPath()%>/images/<%=existingImageFileName%>" width="50" height="50" alt="<%=existingName%>"></td>
                                <td> ⇒ </td>
                                <td><img src="<%=request.getContextPath()%>/images/<%=imageFileName%>" width="50" height="50" alt="<%=existingName%>"></td>
                            </tr>
                        <% } %>
                        <% if(!existingName.equals(productName)){ %>
                            <tr>
                                <td class="row-intro">商品名</td>
                                <td><%=existingName%></td>
                                <td> ⇒ </td>
                                <td><%=productName%></td>
                            </tr>
                        <% } %>
                        <% if(!existingMaker.equals(maker)){ %>
                            <tr>
                                <td class="row-intro">メーカー</td>
                                <td><%=existingMakerName%></td>
                                <td> ⇒ </td>
                                <td><%=makerName%></td>
                            </tr>
                        <% } %>
                        <% if(!existingFlavor.equals(flavor)){ %>
                            <tr>
                                <td class="row-intro">味</td>
                                <td><%=existingFlavorName%></td>
                                <td> ⇒ </td>
                                <td><%=flavorName%></td>
                            </tr>
                        <% } %>
                        <% if(!existingType.equals(type)){ %>
                            <tr>
                                <td class="row-intro">種類</td>
                                <td><%=existingTypeName%></td>
                                <td> ⇒ </td>
                                <td><%=typeName%></td>
                            </tr>
                        <% } %>
                        <% if(!existingCost.equals(cost)){ %>
                            <tr>
                                <td class="row-intro">購入コスト</td>
                                <td><%=existingCost%></td>
                                <td> ⇒ </td>
                                <td><%=cost%></td>
                            </tr>
                        <% } %>
                        <% if(!existingPrice.equals(price)){ %>
                            <tr>
                                <td class="row-intro">値段</td>
                                <td><%=existingPrice%></td>
                                <td> ⇒ </td>
                                <td><%=price%></td>
                            </tr>
                        <% } %>
                    </table>

                    <div id="update-buttons-holder">

                        <form action="product-details.jsp" method="post">
                            <input type="hidden" name="productID" value="<%=productID%>">
                            <% if(imagePart.getSize() > 0){ %>
                                <input type="hidden" name="deleteThisImageDueToCancel" value="<%=imageFileName%>">
                            <% } %>
                            <button class="normal-button">キャンセル</button>
                        </form>

                        <form action="product-register.jsp" method="post">
                            <input type="hidden" name="productID" value="<%=productID%>">
                            <% if(imagePart.getSize() > 0){ %>
                                <input type="hidden" name="oldImageFile" value="<%=existingImageFileName%>">
                                <input type="hidden" name="newImageFile" value="<%=imageFileName%>">
                            <% } %>
                            <% if(!productName.equals(existingName)){ %><input type="hidden" name="name" value="<%=productName%>"><%}%>
                            <% if(!maker.equals(existingMaker)){ %><input type="hidden" name="maker" value="<%=maker%>"><%}%>
                            <% if(!flavor.equals(existingFlavor)){ %><input type="hidden" name="flavor" value="<%=flavor%>"><%}%>
                            <% if(!type.equals(existingType)){ %><input type="hidden" name="type" value="<%=type%>"><%}%>
                            <% if(!cost.equals(existingCost)){ %><input type="hidden" name="cost" value="<%=cost%>"><%}%>
                            <% if(!price.equals(existingPrice)){ %><input type="hidden" name="price" value="<%=price%>"><%}%>
                            <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">
                            <input type="hidden" name="registerType" value="detailsUpdate">

                            <button class="normal-button">登録</button>
                        </form>

                    </div>

                <% } %>

            </div>

        <%
            //削除の場合
            } else if(registerType.equals("delete")){
        %>

            <h2 id="delete-h2">商品削除の確認</h2>

            <div id="delete-top-row">
                <img class="image" src="<%=request.getContextPath()%>/images/<%=imageFileName%>" width="90" height="90" alt="<%=productName%>">
                <table>
                    <tr>
                        <td><b><%=productName%></b></td>
                    </tr>
                    <tr>
                        <td>商品ID：<%for(int i = 0; i < (5 - productID.length()); i++) {%>0<%}%><%=productID%></td>
                    </tr>
                </table>
            </div>

            <% if(Integer.parseInt(instockQuantity) > 0){ %>

                <p id="quantity-warning"><span class="quantity-symbol"> ⚠ </span>在庫に <b><%=instockQuantity%>個</b> が残っています。<span class="quantity-symbol"> ⚠ </span></p>

                <div id="delete-buttons-holder">
                    <div>
                        <form action="products-details.jsp?productID=<%=productID%>" method="post">
                            <button class="normal-button">キャンセル</button>
                        </form>

                                                                        <!-- 未完成 -->
                        <form action="sales-register.jsp" method="post">
                            <input type="hidden" name="productID" value="<%=productID%>">
                            <input type="hidden" name="quantity" value="<%=instockQuantity%>">
                            <input type="hidden" name="registerType" value="sell">
                            <input type="hidden" name="previousPage" value="product-details.jsp?productID=<%=productID%>">

                            <button class="normal-button">売上を登録</button>
                        </form>
                                                                        <!-- 未完成 -->
                    </div>

                    <div>
                        <form action="product-register.jsp" method="post">

                            <input type="hidden" name="registerType" value="<%=registerType%>">
                            <input type="hidden" name="productID" value="<%=productID%>">
                            <input type="hidden" name="setQuantityToZero" value="true">

                            <button class="delete-button">在庫数をゼロに設定して削除</button>
                        </form>

                        <form action="product-register.jsp" method="post">

                            <input type="hidden" name="registerType" value="<%=registerType%>">
                            <input type="hidden" name="productID" value="<%=productID%>">

                            <button class="delete-button">このまま削除</button>
                        </form>
                    </div>
                </div>

            <% } else { %>

                <br>
                <p>削除処理を開始します。復活はデータベース管理者へ連絡ください。</p>

                <div id="buttons-holder">

                    <form action="product-details.jsp?productID=<%=productID%>" method="post">
                        <button class="normal-button">キャンセル</button>
                    </form>

                    <form action="product-register.jsp" method="post">

                        <input type="hidden" name="registerType" value="<%=registerType%>">
                        <input type="hidden" name="productID" value="<%=productID%>">

                        <button class="delete-button">削除</button>
                    </form>
                </div>

            <% } %>

        <%
            }
        %>

    </div>
    <script>
        <% if(registerType.equals("add")){ %>
            let unitsPerBox = <%=unitPerBox%>;
            let boxesToOrder = <%=autoOrderQuantity%>;
            document.getElementById("totalQuantityPerOrder").innerHTML += "　合計: " + (unitsPerBox * boxesToOrder) + "個";
        <% } %>
    </script>
</body>
</html>