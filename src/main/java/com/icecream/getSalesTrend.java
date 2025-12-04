package com.icecream;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/getSalesTrend")
public class getSalesTrend extends HttpServlet {

    public getSalesTrend() {
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json; charset=UTF-8");

        String rankingType = req.getParameter("rankingType");
        String monthsInterval = req.getParameter("monthsInterval");
        String product1 = req.getParameter("product1");
        String product2 = req.getParameter("product2");
        String product3 = req.getParameter("product3");
        String product4 = req.getParameter("product4");
        String[] products = {product1, product2, product3, product4};
        boolean ignoreProducts = true;
        for (int i = 0; i < products.length; i++) {
            if(products[i] != null){
                ignoreProducts = false;
                break;
            }
        }

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
            sql.append("select products.productID, products.name, ");
            sql.append("products.purchaseCost, products.price, ");
            sql.append("DATE_FORMAT(sales.dateTime, '%Y-%m') as yearMonth, ");
            sql.append("sum(sales.quantity) as monthlySales ");
            sql.append("from sales ");
            sql.append("inner join products on sales.productID = products.productID ");
            sql.append("where sales.deleteFlag = 0 ");
            sql.append("and sales.dateTime >= DATE_SUB(curdate(), interval " + monthsInterval + " month ) ");
            sql.append("group by productID, yearMonth ");
            if(!ignoreProducts){
                sql.append("having products.productID in ( ");
                boolean passedFirst = false;
                for (int i = 0; i < products.length; i++) {
                    if(products[i] != null){
                        if(passedFirst) sql.append(", ");
                        sql.append((products[i]));
                        passedFirst = true;
                    }
                }
                sql.append(") ");
            }
            sql.append("order by yearMonth, productID ");

            rs = stmt.executeQuery(sql.toString());

            StringBuilder json = new StringBuilder("{");
            json.append("\"title\":\"").append(rankingType)
                .append("\",\"monthsInterval\":").append(monthsInterval)
                .append(",\"data\":[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{\"productID\":").append(rs.getInt("productID"))
                        .append(",\"name\":\"").append(rs.getString("name"))
                        .append("\",\"yearMonth\":\"").append(rs.getString("yearMonth"))
                        .append("\",\"monthlySales\":").append(rs.getString("monthlySales"))
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