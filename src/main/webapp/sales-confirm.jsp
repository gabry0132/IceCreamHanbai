<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // 文字コードの指定
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    //    String staffID = session.getAttribute("staffID");
//    String staffID = session.getAttribute("staffName");
    String staffID = "00";      //仮にシステムの登録だとします
    String staffName = "システム";      //仮にシステムの登録だとします

    String registerType = request.getParameter("registerType");

    //作成の場合にもらうパラメータ
    String productID = request.getParameter("productID");
    String saleTimeSelector = request.getParameter("sale_time_selector");
    String saleTime = request.getParameter("sale_time");
    String saleQuantitiy = request.getParameter("sale_quantity");
    String productName = "";
    String productImage = "";


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
            System.out.println(saleTime);
        }
        else if(saleTimeSelector.equals("指定する")){
            //2025-10-19T22:55 の形で来ます。
            String seconds = calendar.get(Calendar.SECOND) + "";
            if(seconds.length() == 1); seconds = "0" + seconds;
            saleTime = saleTime.replace("T", " ") + ":" + seconds;
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
    <link rel="stylesheet" href="css/sales-confirm.css">
</head>
<body>
    
    <div id="everything-wrapper">

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
                <input type="hidden" name="productIDFromCreate" value="<%=productID%>">
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

    </div>

</body>
<script>console.log("<%=saleTime%>")</script>
</html>