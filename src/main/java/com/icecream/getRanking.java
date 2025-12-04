package com.icecream;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.Calendar;

@WebServlet("/getRanking")
public class getRanking extends HttpServlet {

    public getRanking() {
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json; charset=UTF-8");

        String rankingType = req.getParameter("rankingType");

        String yearFrom = req.getParameter("yearFrom");
        String yearTo = req.getParameter("yearTo");
        String monthFrom = req.getParameter("monthFrom");
        String monthTo = req.getParameter("monthTo");
        String dayFrom = req.getParameter("dayFrom");
        String dayTo = req.getParameter("dayTo");

        if(yearFrom != null && yearTo == null){
            yearTo = yearFrom;
        }
        if(yearFrom != null && monthFrom == null){  //年Top
            monthFrom = "1";
            monthTo = "12";
            dayFrom = "1";
            dayTo = "31";
        }else if(monthFrom != null && monthTo == null){ //期間Top
            monthTo = monthFrom;
            dayFrom = "1";
            dayTo = getLastDayOfMonth(yearTo, monthTo);
        }

        //全体的 TOP / WORST の場合は貰いますが、それ以外は10にする
        String rankingItemLimit = req.getParameter("rankingItemLimit");
        if(rankingItemLimit == null)  rankingItemLimit = "10";
        boolean worstFlag = false;
        if(req.getParameter("worstFlag") != null){
            worstFlag = Boolean.parseBoolean(req.getParameter("worstFlag"));
        }

        //先にグラフのタイトルを設定
        String graphTitle = "";
        if(rankingItemLimit.equals("unlimited")) graphTitle = rankingType;
        else graphTitle = rankingType + rankingItemLimit;

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
            sql.append("select A.productID, A.name, sum(A.quantity) as totalSales from ( ");
            sql.append("select products.productID, products.name, sales.quantity from sales ");
            sql.append("inner join products on sales.productID = products.productID ");
            sql.append("where sales.deleteFlag = 0 ");
            if(yearFrom != null) sql.append("and sales.dateTime >= '"+ yearFrom + "-" + monthFrom + "-" + dayFrom + "' ");
            if(yearTo != null) sql.append("and sales.dateTime <= '"+ yearTo + "-" + monthTo + "-" + dayTo + " 23:59:59' "); //最後の1分までチェックします
            sql.append(") as A ");
            sql.append("group by A.productID ");
            sql.append("order by totalSales ");
            if(!worstFlag) sql.append("desc ");
            if(!rankingItemLimit.equals("unlimited")) sql.append("limit " + rankingItemLimit);

            rs = stmt.executeQuery(sql.toString());

            StringBuilder json = new StringBuilder("{");
            json.append("\"title\":\"").append(graphTitle).append("\",\"data\":[");
            boolean first = true;

            while (rs.next()) {
                if (!first) json.append(",");
                    json.append("{\"productID\":").append(rs.getInt("productID"))
                        .append(",\"name\":\"").append(rs.getString("name"))
                        .append("\",\"totalSales\":").append(rs.getString("totalSales"))
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

    private String getLastDayOfMonth(String yearTo, String monthTo) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, Integer.parseInt(yearTo));
        calendar.set(Calendar.MONTH, Integer.parseInt(monthTo) - 1);
        calendar.set(Calendar.DAY_OF_MONTH, 1);
        calendar.add(Calendar.MONTH, 1);
        calendar.add(Calendar.DATE, -1);
        return "" + calendar.get(Calendar.DAY_OF_MONTH);
    }
}