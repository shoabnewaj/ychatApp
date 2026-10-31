package ychatapp.model.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import ychatapp.model.Message;

public class MessageDAO {
    // Conversation additions
    private void ensureConversationArchiveTable(Connection con) throws Exception {
        try (Statement st = con.createStatement()) {
            st.executeUpdate("CREATE TABLE IF NOT EXISTS conversation_archives (user_name VARCHAR(100) NOT NULL, partner_name VARCHAR(100) NOT NULL, archived_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(user_name, partner_name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
    }

    public List<String> getUnreadConversationPartners(String username) {
        List<String> partners = new ArrayList<>();
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement("SELECT DISTINCT sender_id FROM messages WHERE receiver_id=? AND sender_id NOT IN ('Gemini AI', 'gemini') AND is_read=0 AND is_deleted=0")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) { while (rs.next()) partners.add(rs.getString(1)); }
        } catch (Exception e) { e.printStackTrace(); }
        return partners;
    }

    /** Count incoming messages the user has not opened yet. */
    public int getUnreadMessageCount(String username) {
        if (username == null || username.trim().isEmpty()) return 0;
        String sql = "SELECT COUNT(*) FROM messages WHERE receiver_id=? AND sender_id NOT IN ('Gemini AI', 'gemini') AND is_read=0 AND is_deleted=0";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<String> getArchivedConversationPartners(String username) {
        List<String> partners = new ArrayList<>();
        try (Connection con = getConnection()) {
            ensureConversationArchiveTable(con);
            try (PreparedStatement ps = con.prepareStatement("SELECT partner_name FROM conversation_archives WHERE user_name=?")) {
                ps.setString(1, username);
                try (ResultSet rs = ps.executeQuery()) { while (rs.next()) partners.add(rs.getString(1)); }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return partners;
    }

    public boolean setConversationArchived(String username, String partner, boolean archived) {
        if (username == null || partner == null || username.equalsIgnoreCase(partner)) return false;
        try (Connection con = getConnection()) {
            ensureConversationArchiveTable(con);
            String sql = archived ? "INSERT INTO conversation_archives(user_name,partner_name) VALUES(?,?) ON DUPLICATE KEY UPDATE archived_at=CURRENT_TIMESTAMP" : "DELETE FROM conversation_archives WHERE user_name=? AND partner_name=?";
            try (PreparedStatement ps = con.prepareStatement(sql)) { ps.setString(1, username); ps.setString(2, partner); ps.executeUpdate(); return true; }
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Message> searchChat(String u1, String u2, String query) {
        List<Message> all = getChat(u1, u2);
        if (query == null || query.isBlank()) return all;
        String needle = query.toLowerCase(java.util.Locale.ROOT);
        all.removeIf(m -> m.getMessage() == null || !m.getMessage().toLowerCase(java.util.Locale.ROOT).contains(needle));
        return all;
    }


    private Connection getConnection() throws Exception {
        return DBConnection.getConnection();
    }

    public List<Message> getChat(String u1, String u2) {
        List<Message> list = new ArrayList<>();

        try (Connection con = getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM messages WHERE (sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?) ORDER BY id ASC"
            );

            ps.setString(1, u1);
            ps.setString(2, u2);
            ps.setString(3, u2);
            ps.setString(4, u1);

            ResultSet rs = ps.executeQuery();

            while(rs.next()){
                int id = rs.getInt("id");
                String sender = rs.getString("sender_id");
                String receiver = rs.getString("receiver_id");
                String message = rs.getString("message_text");
                
                boolean isRead = false;
                try { isRead = (rs.getInt("is_read") == 1); } catch (Exception ignored) {}

                boolean isEdited = false;
                try { isEdited = (rs.getInt("is_edited") == 1); } catch (Exception ignored) {}

                boolean isDeleted = false;
                try { isDeleted = (rs.getInt("is_deleted") == 1); } catch (Exception ignored) {}

                String reaction = null;
                try { reaction = rs.getString("reaction"); } catch (Exception ignored) {}

                Integer replyToId = null;
                try { 
                    int rId = rs.getInt("reply_to_id"); 
                    if (!rs.wasNull()) replyToId = rId;
                } catch (Exception ignored) {}

                String replyToText = null;
                try { replyToText = rs.getString("reply_to_text"); } catch (Exception ignored) {}

                String timestamp = null;
                try { 
                    timestamp = rs.getString("created_at"); 
                    if (timestamp == null) timestamp = rs.getString("timestamp");
                } catch (Exception ignored) {
                    try { timestamp = rs.getString("timestamp"); } catch (Exception ignored2) {}
                }

                list.add(new Message(
                    id, sender, receiver, message, isRead, isEdited, isDeleted, reaction, replyToId, replyToText, timestamp
                ));
            }

        } catch(Exception e){
            e.printStackTrace();
        }

        return list;
    }

    public List<String> getConversationPartners(String username) {
        List<String> partners = new ArrayList<>();
        String sql = "SELECT partner FROM (" +
                "SELECT receiver_id AS partner, MAX(id) AS last_id FROM messages WHERE sender_id = ? GROUP BY receiver_id " +
                "UNION ALL " +
                "SELECT sender_id AS partner, MAX(id) AS last_id FROM messages WHERE receiver_id = ? GROUP BY sender_id" +
                ") conversations WHERE partner IS NOT NULL AND partner <> ? GROUP BY partner ORDER BY MAX(last_id) DESC";
        try (Connection con = getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String partner = rs.getString("partner");
                    if (partner != null && !partner.trim().isEmpty()) partners.add(partner);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return partners;
    }
    public int saveMessage(String s, String r, String m){
        return saveMessageWithReply(s, r, m, null, null);
    }

    public int saveMessageWithReply(String s, String r, String m, Integer replyToId, String replyToText){
        int generatedId = 0;
        try (Connection con = getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO messages(sender_id, receiver_id, message_text, is_read, is_edited, is_deleted, reply_to_id, reply_to_text) VALUES(?,?,?,0,0,0,?,?)",
                Statement.RETURN_GENERATED_KEYS
            );

            ps.setString(1, s);
            ps.setString(2, r);
            ps.setString(3, m);
            if (replyToId != null && replyToId > 0) {
                ps.setInt(4, replyToId);
            } else {
                ps.setNull(4, java.sql.Types.INTEGER);
            }
            ps.setString(5, replyToText);

            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }

        } catch(Exception e){
            e.printStackTrace();
        }
        return generatedId;
    }

    public boolean editMessage(int messageId, String sender, String newText) {
        try (Connection con = getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE messages SET message_text = ?, is_edited = 1 WHERE id = ? AND sender_id = ? AND is_deleted = 0"
            );
            ps.setString(1, newText);
            ps.setInt(2, messageId);
            ps.setString(3, sender);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteMessageForEveryone(int messageId, String sender) {
        try (Connection con = getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE messages SET is_deleted = 1, message_text = 'This message was deleted' WHERE id = ? AND sender_id = ?"
            );
            ps.setInt(1, messageId);
            ps.setString(2, sender);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateReaction(int messageId, String reaction) {
        try (Connection con = getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE messages SET reaction = ? WHERE id = ?"
            );
            ps.setString(1, reaction);
            ps.setInt(2, messageId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void markAsRead(String sender, String receiver) {
        try (Connection con = getConnection()) {

            PreparedStatement ps = con.prepareStatement(
                "UPDATE messages SET is_read = 1 WHERE sender_id = ? AND receiver_id = ? AND is_read = 0"
            );

            ps.setString(1, sender);
            ps.setString(2, receiver);
            ps.executeUpdate();

        } catch(Exception e){
            e.printStackTrace();
        }
    }
}
