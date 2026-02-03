<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 文字コードの指定
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

    //作成の場合にもらうパラメータ
    String productID = request.getParameter("productID");                   //修正・削除の場合ももらいます
    String saleTimeSelector = request.getParameter("sale_time_selector");
    String saleTime = request.getParameter("sale_time");                    //修正の場合ももらいます
    String saleQuantitiy = request.getParameter("sale_quantity");           //修正の場合ももらいます
    String productName = "";
    String productImage = "";

    //修正の場合のパラメータ
    String saleID = request.getParameter("saleID");                         //削除の場合ももらいます
    String editStaffID = request.getParameter("sale-staff-edit");
    String editStaffName = "";

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
    Calendar calendar = Calendar.getInstance();

    if(saleTimeSelector != null){
        if(saleTimeSelector.equals("今現在")) {
            saleTime += calendar.get(Calendar.YEAR);
            saleTime += "-";
            saleTime += calendar.get(Calendar.MONTH) + 1;
            saleTime += "-";
            saleTime += calendar.get(Calendar.DAY_OF_MONTH);
            saleTime += " ";
            int hour = calendar.get(Calendar.HOUR);
            if(calendar.get(Calendar.AM_PM) == Calendar.PM) hour += 12;
            if(hour < 10) saleTime += "0";
            saleTime += hour;
            saleTime += ":";
            if(calendar.get(Calendar.MINUTE) < 10) saleTime += "0";
            saleTime += calendar.get(Calendar.MINUTE);
            saleTime += ":";
            if(calendar.get(Calendar.SECOND) < 10) saleTime += "0";
            saleTime += calendar.get(Calendar.SECOND);
        }
        else if(saleTimeSelector.equals("指定する")){
            //2025-10-19T22:55:11 の形で来ます。

            saleTime = saleTime.replace("T", " ");
        }
    }

    try {
        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();

        sql = new StringBuffer();
        sql.append("select name, image from products ");
        sql.append("where productID = ");
        sql.append(productID);

        rs = stmt.executeQuery(sql.toString());

        if (rs.next()) {

            productName = rs.getString("name");
            productImage = rs.getString("image");

        } else {
            throw new Exception("対象の商品が見つかりませんでした。");
        }

        if(registerType.equals("edit")){

            if(!isAdmin) throw new Exception("管理者権限が必要。");

            sql = new StringBuffer();
            sql.append("select name from staff ");
            sql.append("where staffID = ");
            sql.append(staffID);
            rs = stmt.executeQuery(sql.toString());

            if (rs.next()) {
                editStaffName = rs.getString("name");
            } else {
                throw new Exception("対象の商品が見つかりませんでした。");
            }
        }else if(registerType.equals("delete")){

            if(!isAdmin) throw new Exception("管理者権限が必要。");

            sql = new StringBuffer();
            sql.append("select quantity from sales where salesID = ");
            sql.append(saleID);
            rs = stmt.executeQuery(sql.toString());

            if (rs.next()) {
                saleQuantitiy = rs.getString("quantity");
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
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品登録確認</title>
    <link rel="stylesheet" href="css/sales-order-confirm.css">
</head>
<body>

<% if(ermsg != null){ %>

    <h4>エラーが発生しました。</h4>
    <p><%=ermsg%></p>

<% } else { %>

    <div id="everything-wrapper">

        <% if(registerType.equals("create")){ %>

            <h2>売上データ追加内容確認</h2>

            <div id="main-section-wrapper">

                <div id="left-section-wrapper">
                    <img class="image" id="add-image" src="<%=request.getContextPath()%>/images/<%=productImage%>" width="100" height="100" alt="<%=productName%>">
                </div>

                <div id="right-section-wrapper">
                    <table>
                        <tr>
                            <td class="table-left-side"><%=productID%></td>
                            <td><%=productName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">販売日時</td>
                            <td><%=saleTime%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">販売担当</td>
                            <td><%=staffName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">販売個数</td>
                            <td><%=saleQuantitiy%></td>
                        </tr>
                    </table>

                </div>

            </div>

            <div id="buttons-holder">
                <!--どこから来たのか非表示のinputでわかるはずなので「内容を修正」ボタンで正しい場所へ戻される。-->
                <!--設定変更の場合は詳細ページに戻ったら自動的に正しいポップアップを出すようにする。-->
                <form action="sales.jsp" method="post">
                    <input type="hidden" name="productIDCancelledCreate" value="<%=productID%>">
                    <input type="hidden" name="sale_time_selector" value="<%=saleTimeSelector%>">
                    <input type="hidden" name="saleQuantity" value="<%=saleQuantitiy%>">
                    <button class="normal-button">内容を修正する</button>
                </form>
                <form action="sales-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="<%=registerType%>">
                    <input type="hidden" name="productID" value="<%=productID%>">
                    <input type="hidden" name="saleTime" value="<%=saleTime%>">
                    <input type="hidden" name="saleQuantity" value="<%=saleQuantitiy%>">

                    <button class="normal-button">登録</button>
                </form>
            </div>

        <% } else if (registerType.equals("edit")){ %>

            <h2>売上データ修正内容確認</h2>

            <div id="main-section-wrapper">

                <div id="left-section-wrapper">
                    <img class="image" id="add-image" src="<%=request.getContextPath()%>/images/<%=productImage%>" width="100" height="100" alt="<%=productName%>">
                </div>

                <div id="right-section-wrapper">
                    <table>
                        <tr>
                            <td class="table-left-side"><%=productID%></td>
                            <td><%=productName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">販売日時</td>
                            <td><%=saleTime%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">販売担当</td>
                            <td><%=editStaffName%></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">販売個数</td>
                            <td><%=saleQuantitiy%></td>
                        </tr>
                    </table>

                </div>

            </div>

            <div id="buttons-holder">
                <form action="sales.jsp" method="post">
                    <button class="normal-button">内容を修正する</button>
                </form>
                <form action="sales-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="<%=registerType%>">
                    <input type="hidden" name="saleID" value="<%=saleID%>">
                    <input type="hidden" name="productID" value="<%=productID%>">
                    <input type="hidden" name="editStaffID" value="<%=editStaffID%>">
                    <input type="hidden" name="saleTime" value="<%=saleTime%>">
                    <input type="hidden" name="saleQuantity" value="<%=saleQuantitiy%>">

                    <button class="normal-button">登録</button>
                </form>
            </div>


        <% } else if (registerType.equals("delete")) { %>

            <h2>売上データ削除確認</h2>

            <div id="main-section-wrapper">

                <div id="left-section-wrapper">
                    <img class="image" id="add-image" src="<%=request.getContextPath()%>/images/<%=productImage%>" width="100" height="100" alt="<%=productName%>">
                    <p id="delete-text"><%=productName%> の売上データ (売上ID: <%=saleID%>)を削除します。<br>対象の<b><%=saleQuantitiy%>個</b>を在庫に戻しますか？</p>
                </div>

            </div>

            <div id="buttons-holder">
                <form action="sales.jsp" method="post">
                    <button class="normal-button">中止</button>
                </form>
                <form action="sales-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="<%=registerType%>">
                    <input type="hidden" name="saleID" value="<%=saleID%>">
                    <input type="hidden" name="returnQuantity" value="true">

                    <button class="delete-button"><%=saleQuantitiy%>個を戻して削除</button>
                </form>
                <form action="sales-register.jsp" method="post">
                    <input type="hidden" name="registerType" value="<%=registerType%>">
                    <input type="hidden" name="saleID" value="<%=saleID%>">

                    <button class="delete-button">このまま削除</button>
                </form>
            </div>


        <% } %>

    </div>

<% } %>

</body>
</html>