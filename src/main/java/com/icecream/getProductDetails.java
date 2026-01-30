package com.icecream;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/getProductDetails")
public class getProductDetails extends HttpServlet {

    public getProductDetails() {
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("application/json; charset=UTF-8");

        String productID = req.getParameter("productID");

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

        try {

            //オブジェクトの代入
            Class.forName(driver).newInstance();
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            sql = new StringBuffer();
            //全部求めますが要らない項目を無視します
            sql.append("select * from products where productID = " + productID);
            sql.append(" and deleteFlag = 0 ");

            rs = stmt.executeQuery(sql.toString());

            if(rs.next()){
                StringBuilder json = new StringBuilder("{");
                json.append("\"product\":{")
                        .append("\"productID\":").append(rs.getInt("productID"))
                        .append(",\"name\":\"").append(rs.getString("name"))
                        .append("\",\"purchaseCost\":").append(rs.getString("purchaseCost"))
                        .append(",\"unitPerBox\":").append(rs.getString("unitPerBox"))
                        .append(",\"confirmDays\":").append(rs.getString("confirmDays"))
                        .append(",\"shippingDays\":").append(rs.getString("shippingDays"))
                        .append(",\"image\":\"").append(rs.getString("image"))
                        .append("\"}")
                        .append("}");

                res.getWriter().write(json.toString());

            } else {
                throw new Exception("対象の商品が見つかりませんでした");
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("{\"error\":\"Server error\",\"message\":\"+" + e.toString() +"\"}");
        } finally {
            try {
                if (rs != null) rs.close();
            } catch (SQLException e) { e.printStackTrace(); }

            try {
                if (stmt != null) stmt.close();
            } catch (SQLException e) { e.printStackTrace(); }

            try {
                if (con != null) con.close();
            } catch (SQLException e) { e.printStackTrace(); }
        }

    }
}
