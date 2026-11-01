package ychatapp.Servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import ychatapp.model.beans.UsersBeans;
import ychatapp.model.dao.DBConnection;

@WebServlet("/PushSubscriptionServlet")
public class PushSubscriptionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.setContentType("application/json;charset=UTF-8");
        HttpSession session = req.getSession(false);
        UsersBeans ub = (session != null) ? (UsersBeans) session.getAttribute("ub") : null;
        if (ub == null) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.getWriter().write("{\"error\":\"Not logged in\"}");
            return;
        }

        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }

        try {
            JsonObject json = JsonParser.parseString(sb.toString()).getAsJsonObject();
            String endpoint = json.has("endpoint") ? json.get("endpoint").getAsString() : "";
            JsonObject keys = json.has("keys") ? json.getAsJsonObject("keys") : null;
            String p256dh = (keys != null && keys.has("p256dh")) ? keys.get("p256dh").getAsString() : "";
            String auth = (keys != null && keys.has("auth")) ? keys.get("auth").getAsString() : "";

            if (endpoint.isEmpty() || p256dh.isEmpty() || auth.isEmpty()) {
                res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                res.getWriter().write("{\"error\":\"Invalid subscription data\"}");
                return;
            }

            String sql = "INSERT INTO push_subscriptions (username, endpoint, p256dh, auth) " +
                         "VALUES (?, ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE p256dh = VALUES(p256dh), auth = VALUES(auth), updated_at = CURRENT_TIMESTAMP";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, ub.getName());
                ps.setString(2, endpoint);
                ps.setString(3, p256dh);
                ps.setString(4, auth);
                ps.executeUpdate();
            }

            res.getWriter().write("{\"success\":true}");
        } catch (Exception e) {
            e.printStackTrace();
            res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            res.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}