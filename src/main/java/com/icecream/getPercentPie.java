package com.icecream;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/getPercentPie")
public class getPercentPie extends HttpServlet {

    public getPercentPie() {
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json; charset=UTF-8");

        String rankingType = req.getParameter("rankingType");
        String targetYear = req.getParameter("targetYear");
        String dateFrom = targetYear + "-01-01";
        String dateTo = targetYear + "-12-31 23:59:59";

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
            sql.append("select products.name, products.productID, sum(sales.quantity) as quantity, ");
            sql.append("products.purchaseCost, products.price ");
            sql.append("from sales inner join products on sales.productID = products.productID ");
            sql.append("where sales.dateTime >= '" + dateFrom + "' and sales.dateTime <='" + dateTo + "' ");
            sql.append("and sales.deleteFlag = 0 ");
            sql.append("group by products.name, products.productID ");
            sql.append("order by sales.quantity desc ");

            rs = stmt.executeQuery(sql.toString());

            StringBuilder json = new StringBuilder("{");
            json.append("\"title\":\"").append(rankingType)
                    .append("\",\"data\":[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{\"productID\":").append(rs.getInt("productID"))
                        .append(",\"name\":\"").append(rs.getString("name"))
                        .append("\",\"quantity\":").append(rs.getString("quantity"))
                        .append(",\"purchaseCost\":").append(rs.getString("purchaseCost"))
                        .append(",\"price\":").append(rs.getString("price"))
                        .append("}");
                first = false;
            }
            json.append("]}");

            res.getWriter().write(json.toString());

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("{\"error\":\"Server error\"}");
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