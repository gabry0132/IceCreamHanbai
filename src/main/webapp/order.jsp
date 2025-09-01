<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.ArrayList"%>
<%
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
        sql.append("select ");

        rs = stmt.executeQuery(sql.toString());



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

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">

    <title>発注</title>

    <link rel="stylesheet" type="text/css" href="css/order.css">

  </head>

  <body>

    <div>

      <h1>発注管理</h1>
      <div id="next">
          <button id="btn-add">発注を<br>開始する</button>
      </div>

        <div>

            <div>

                <form action="order.jsp" method="post">

                    <div id="pulldown-menus">

                        <select>
                            <option hidden disabled selected>商品を選択</option>
                            <option value="">a</option>
                            <option value="">b</option>
                            <option value="">c</option>
                            <option value="">d</option>
                            <option value="">e</option>
                        </select>
                        <input type="date">から
                        <br>
                        <select>
                         <option hidden disabled selected>発注実行者を選択</option>
                          <option value="">A</option>
                          <option value="">B</option>
                          <option value="">C</option>
                          <option value="">D</option>
                          <option value="">E</option>
                        </select>
                        <input type="date">まで
                        <button class="submit">この条件で検索</button>

                    </div>

                </form>

            </div>

            <div id="back">
              <form action="main.html" method="post">
                <button id="back">戻る</button>
              </form>
            </div>

        </div>

        <div>
          <dl>

            <table class="order">
              <tr>
                <td class="photo">
                  <img src="images/ice1.png" width="90" height="90" alt="ice1">
                </td>
                <td>
                  <p class="status">板チョコアイスが9月24日に30個発注された(○○より)</p>
                </td>
                <td class="status">発注確認中<br><button id="stop">発注停止</button></td>
              </tr>
            </table>



            <table class="order">
              <tr>
                <td class="photo">
                  <img src="images/ice3.jpg" width="90" height="90" alt="ice1">
                </td>
                <td>
                  <p class="status">じゃがいも　もなかが7月29日に30個発注された(自動発注より)</p>
                </td>
                <td class="status">配達中</td>
              </tr>
            </table>

            <table class="order">
              <tr>
                <td class="photo">
                  <img src="images/ice4.jpg" width="90" height="90" alt="ice1">
                </td>
                <td>
                  <p class="status">Häagen-Dazs 　バニラチョコレートマカデミアが7月3日に30個発注された(○○より)</p>
                </td>
                <td class="status">配達中</td>
              </tr>
            </table>

            <table class="order">
              <tr>
                <td class="photo">
                  <img src="images/ice5.jpg" width="90" height="90" alt="ice1">
                </td>
                <td>
                  <p class="status">PARM (chocolate)が6月15日に25個発注された(自動発注より)</p>
                </td>
                <td class="status">入荷済み</td>
              </tr>
            </table>

            <table class="order">
              <tr>
                <td class="photo">
                  <img src="images/ice6.jpg" width="90" height="90" alt="ice1">
                </td>
                <td>
                  <p class="status">午後の紅茶フローズンティーラテが5月25日に40個発注された(○○より)</p>
                </td>
                <td class="status">入荷済み</td>
              </tr>
            </table>
          </dl>
        </div>

    </div>




    <!-- ポップアップ表示が使うバナー -->
    <div id="obfuscation-banner">

    </div>

    <!-- 商品追加ポップアップ -->
    <div id="add-product-popup">

        <form action="order-details.html" method="post">

            <div id="add-top-row">

                <h2>発注開始</h2>
                <p class="closure">✖</p>

            </div>

            <div id="add-main-section">

                <div id="add-image-section">

                    <img src="images/ice12.jpg" width="90" height="90">
                    <select>
                      <option>商品a</option>
                      <option>商品b</option>
                      <option>商品c</option>
                      <option>商品d</option>
                      <option>商品e</option>
                    </select>

                </div>

                <div id="add-tables-wrapper">

                    <table class="add-table">
                        <tr>
                            <td class="add-table-left-side">発注個数</td>
                            <td><input type="text" name="name" id="name"></td>
                        </tr>
                        <tr>
                            <td class="table-left-side">発注確認時間</td>
                            <td>1日</td>
                        </tr>
                        <tr>
                            <td>出荷確認時間</td>
                            <td>1日</td>
                        </tr>
                        <tr>
                            <td>届く予定日</td>
                            <td>2日後の日付</td>
                        </tr>
                    </table>

                </div>

            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="add">

            <div id="add-buttons-holder">
                <button type="button" class="normal-button" id="btn-add-cancel">キャンセル</button>
                <button class="normal-button" type="submit">発注開始</button>
            </div>

        </form>

    </div>



    <!-- 発注キャンセルポップアップ -->
    <div id="cancel-popup">

        <form action="order-register.html" method="post">

            <div id="add-top-row">

                <h2>発注キャンセル</h2>
                <p class="closure">✖</p>

            </div>

            <div id="add-main-section">

                <div id="add-image-section">

                    <img src="images/ice12.jpg" width="90" height="90">

                </div>

                <div id="add-tables-wrapper">

                    <table class="add-table">
                        <tr>
                            <td>発注日時</td>
                            <td>9月30日</td>
                        </tr>
                        <tr>
                            <td>発注実行者</td>
                            <td>人事名</td>
                        </tr>
                        <tr>
                            <td>発注個数</td>
                            <td>個数</td>
                        </tr>
                    </table>

                </div>

            </div>

            <!-- 登録を個別するための非表示項目 -->
            <input type="hidden" name="registerType" value="add">

              <p>発注を停止しますか？</p>
            <div id="add-buttons-holder">
                <button type="button" class="normal-button" id="btn-stop-cancel">キャンセル</button>
                <button class="normal-button" type="submit">発注停止</button>
            </div>

        </form>

    </div>



    <script>
        //ポップアップに使う変数取得
        let addPopup = document.getElementById("add-product-popup");
        let cancelPopup = document.getElementById("cancel-popup");
        let obfuscationBanner = document.getElementById("obfuscation-banner");
        let body = document.getElementsByTagName("body")[0];

        //イベントリスナーの設定
        document.getElementById("btn-add").addEventListener("click", openAddPopup);
        document.getElementById("stop").addEventListener("click", openStopPopup);
        let stops = document.getElementsByClassName("stop");
        let closures = document.getElementsByClassName("closure");
        document.getElementById("btn-add-cancel").addEventListener("click", closeAllPopups);
        document.getElementById("btn-stop-cancel").addEventListener("click", closeAllPopups);
        obfuscationBanner.addEventListener("click", closeAllPopups);
        let productHolders = document.getElementsByClassName("product-container");
        for (let i = 0; i < productHolders.length; i++) {
            productHolders[i].addEventListener("click", () => window.open("index.html", "_self"));
        }
        for (let i = 0; i < closures.length; i++) {
            closures[i].addEventListener("click", closeAllPopups);
        }
        for (let i = 0; i < stops.length; i++) {
            stops[i].addEventListener("click", closeAllPopups);
        }

        //追加ポップアップの表示
        function openAddPopup(){
            addPopup.style.display = "flex";
            obfuscationBanner.style.display = "flex";
        }
        function openStopPopup(){
            cancelPopup.style.display = "flex";
            obfuscationBanner.style.display = "flex";
        }

        //追加ポップアップの非表示
        function closeAllPopups(){
            addPopup.style.display = "none";
            cancelPopup.style.display = "none";
            obfuscationBanner.style.display = "none";
        }



    </script>

  </body>

</html>

