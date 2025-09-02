<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import ="java.util.Random"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.sun.jmx.snmp.SnmpUnknownAccContrModelException" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    //削除・修正・追加の確認画面と操作完了提示画面を分けるためのflag
    String registerType = request.getParameter("registerType");

    //修正・削除の場合のパラメータ
    String staffID = request.getParameter("staffID");
    //修正から取得のデータ
    String changed_staff_name = request.getParameter("name");
    String changed_staff_password = request.getParameter("password");
    String changed_staff_tel = request.getParameter("tel");
    String changed_staff_address = request.getParameter("address");


    //追加の場合のパラメータ
    String name = request.getParameter("name");
    String tel = request.getParameter("tel");
    String address = request.getParameter("address");
    String workStartDate = request.getParameter("workStartDate");


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

    try{	//ロードに失敗したときのための例外処理

        //オブジェクトの代入
        Class.forName(driver).newInstance();
        con = DriverManager.getConnection(url, user, password);
        stmt = con.createStatement();
        sql = new StringBuffer();

        if(registerType.equals("add")) {

            int addedRows = 0;
            //追加の時ランタイムIDとpassword機能
            //まずA-Z,a-z,0-9のASCII codeを加減してArray[]のsizeを決める
            int password_totalSize = ('Z'-'A'+1)+('z'-'a'+1)+('9'-'0'+1);
            int id_totalSize = ('9'-'0'+1);
            //A-Z,a-z,0-9全部入るArray[]の生成
            char[] PasswordCharArray = new char[password_totalSize];
            char[] IdCharArray = new char[id_totalSize];
            int index = 0;
            int ID_index = 0;
            //追加CharArray[]中にA-Zを入る
            for (char put ='A'; put <='Z'; put++){
                PasswordCharArray[index++] = put;
            }
            //追加CharArray[]中にa-zを入る
            for (char put ='a'; put <='z'; put++){
                PasswordCharArray[index++] = put;
            }
            //追加CharArray[]中に0-9を入る
            for (char put ='0'; put <='9'; put++){
                PasswordCharArray[index++] = put;
                IdCharArray[ID_index++] = put;
            }
            //それで、PasswordCharArrayはA-Z,a-z,0-9の文字入った
            //IdCharArrayは0-9の文字入った
            //次はパスワードと社員ID(6桁の数字)を生成する と重複排除
            boolean repeated = true;
            while (repeated) {
                password= "";
                for (int i = 0; i < 7; i++) {
                    int randomun = (int) (Math.random() * password_totalSize);
                    password += PasswordCharArray[randomun];
                }
                sql.setLength(0);
                // => sql = new StringBuffer();
                sql.append("select count(password) as same from staff ");
                sql.append("where password = '");
                sql.append(password);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());
                if (rs.next()) {
                    int count = rs.getInt("same");
                    if (count == 0) {
                        repeated = false;
                    }
                }
            }
            repeated = true;
            while (repeated) {
                staffID = "";
                int randomun = 0 ;
                randomun = 1+(int)(Math.random() * (id_totalSize-1));
                staffID+= IdCharArray[randomun];
                for (int i = 0; i < 5; i++) {
                    randomun =(int) (Math.random() * id_totalSize);
                    staffID += IdCharArray[randomun];
                }
                sql.setLength(0);
                sql.append("select count(staffID) as same from staff ");
                sql.append("where staffID = '");
                sql.append(staffID);
                sql.append("'");
                rs = stmt.executeQuery(sql.toString());
                if (rs.next()) {
                    int count = rs.getInt("same");
                    if (count == 0) {
                        repeated = false;
                    }
                }
            }

            sql = new StringBuffer();
            //SQLステートメントの作成と発行
            sql.append("insert into staff (staffID, password, name, tel, address, workStartDate, ");
            sql.append("recordTimestamp from staff ");
            sql.append(" values( ");
            sql.append("'" + staffID + "', ");
            sql.append("' " + password + "', ");
            sql.append("'" + name + "', ");
            sql.append("'" + tel + "', ");
            sql.append("'" + address + "', ");
            sql.append("'" + workStartDate + "', ");
            sql.append(" ) ");
            //System.out.println(sql.toString());
            addedRows = stmt.executeUpdate(sql.toString());

            //取得したデータを繰り返し処理を表示する
            if (addedRows == 0) {
                ermsg = new StringBuffer();
                ermsg.append("人事の追加が失敗しました。");
            }

        } else if (registerType.equals("change")) {
            int changedRows = 0;
            sql.append("update name set ");
            sql.append(changed_staff_name);
            sql.append (", password set ");
            sql.append(changed_staff_password);
            sql.append(", tel set " );
            sql.append(changed_staff_tel);
            sql.append(", address set ");
            sql.append(changed_staff_address);
            sql.append("  where staffID= ");
            sql.append(staffID);
            //System.out.println(sql.toString());
            changedRows = stmt.executeUpdate(sql.toString());
            //取得したデータを繰り返し処理を表示する
            if (changedRows == 0) {
                ermsg = new StringBuffer();
                ermsg.append("人事の修正が失敗しました。");
            }

        } else if (registerType.equals("delete")) {
            int updatedRows = 0;
            sql.append("update staff set deleteFlag = 1 where staffID= ");
            sql.append(staffID);
            //System.out.println(sql.toString());
            updatedRows = stmt.executeUpdate(sql.toString());
            //取得したデータを繰り返し処理を表示する
            if (updatedRows == 0) {
                ermsg = new StringBuffer();
                ermsg.append("人事の削除が失敗しました。");
            }
        }

    }catch(ClassNotFoundException e){
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
    <link rel="stylesheet" type="text/css" href="css/staff-register.css">			
    <title>人事管理</title>
</head>
<body>
<%      if(registerType.equals("add")){                      %>
        <h1>人事の追加が正常に完了しました。</h1>
        <form action="staff.jsp" method="post">
            <button id="btn">人事画面へ戻る</button>
        </form>
<%          } else if(registerType.equals("delete")){       %>
        <h1>人事の削除が正常に完了しました。</h1>
        <form action="staff.jsp" method="post">
            <button id="btn">人事画面へ戻る</button>
        </form>
<%          } else if(registerType.equals("change")){       %>
        <h1>人事の変更が正常に完了しました。</h1>
        <form action="staff.jsp" method="post">
            <button id="btn">人事画面へ戻る</button>
        </form>
<%      }                                                  %>
</body>
</html>
