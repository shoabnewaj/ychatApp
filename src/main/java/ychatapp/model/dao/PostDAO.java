package ychatapp.model.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import ychatapp.model.beans.PollOption;
import ychatapp.model.beans.UsersPost;

public class PostDAO {
    private static volatile boolean featureSchemaReady = false;
    private static synchronized void ensureFeatureSchema(Connection c) {
        if (featureSchemaReady) return;
        try (java.sql.Statement st = c.createStatement()) {
            try { st.executeUpdate("ALTER TABLE posts ADD COLUMN scheduled_at DATETIME NULL"); } catch (Exception ignored) {}
            try { st.executeUpdate("ALTER TABLE posts ADD COLUMN publish_status VARCHAR(20) NOT NULL DEFAULT 'PUBLISHED'"); } catch (Exception ignored) {}
            st.executeUpdate("CREATE TABLE IF NOT EXISTS post_views (post_id INT NOT NULL, user_id INT NOT NULL, view_date DATE NOT NULL, viewed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY(post_id,user_id,view_date), INDEX idx_post_views_post(post_id))");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS post_drafts (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, content TEXT, feeling VARCHAR(80), updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, INDEX idx_post_drafts_user(user_id))");
            featureSchemaReady = true;
        } catch (Exception e) { System.err.println("Could not initialize post features: " + e.getMessage()); }
    }
    public List<String> getTodayPostViewers(int postId, int ownerId) {
        List<String> names = new ArrayList<>();
        String sql = "SELECT u.name FROM post_views pv JOIN posts p ON p.id=pv.post_id JOIN users u ON u.id=pv.user_id WHERE p.id=? AND p.user_id=? AND pv.view_date=CURRENT_DATE GROUP BY u.id,u.name ORDER BY MAX(pv.viewed_at) DESC";
        try (Connection c=getConnection(); PreparedStatement ps=c.prepareStatement(sql)) {
            ensureFeatureSchema(c); ps.setInt(1,postId); ps.setInt(2,ownerId);
            try (ResultSet rs=ps.executeQuery()) { while(rs.next()) names.add(rs.getString(1)); }
        } catch(Exception e) { System.err.println("Could not load post viewers: " + e.getMessage()); }
        return names;
    }

    public boolean recordPostView(int postId, int viewerId) {
        if(postId<=0||viewerId<=0)return false;
        try(Connection c=getConnection()){ensureFeatureSchema(c);try(PreparedStatement p=c.prepareStatement("INSERT IGNORE INTO post_views(post_id,user_id,view_date) SELECT id,?,CURRENT_DATE FROM posts WHERE id=? AND user_id<>? AND publish_status='PUBLISHED' AND (scheduled_at IS NULL OR scheduled_at<=NOW())")){p.setInt(1,viewerId);p.setInt(2,postId);p.setInt(3,viewerId);p.executeUpdate();return true;}}catch(Exception e){System.err.println("Could not record post view: "+e.getMessage());return false;}
    }

    public void recordFeedViews(int userId, List<UsersPost> posts) {
        if (userId <= 0 || posts == null || posts.isEmpty()) return;
        try (Connection c = getConnection()) {
            ensureFeatureSchema(c);
            try (PreparedStatement ps = c.prepareStatement("INSERT IGNORE INTO post_views(post_id,user_id,view_date) SELECT ?,?,CURRENT_DATE")) {
                for (UsersPost p : posts) { if (p.getUserId() == userId) continue; ps.setInt(1,p.getId()); ps.setInt(2,userId); ps.addBatch(); }
                ps.executeBatch();
            }
        } catch (Exception e) { System.err.println("Could not record feed views: " + e.getMessage()); }
    }


    private Connection getConnection() throws Exception {
        return DBConnection.getConnection();
    }

    // ================= ADD POST (Feeling 爬ｸ爬ｹ 爬・ｦｪ爬｡爰・ｦ・爬歩ｦｰ爬ｾ 爬ｹ爰游ｧ・ｦ巵ｧ・ =================
    public int addPost(int userId, String content, String fileName, String postType, String feeling) {
        return addPost(userId, content, fileName, postType, feeling, null);
    }

    public int addPost(int userId, String content, String fileName, String postType, String feeling, String scheduledAt) {
        String sql = scheduledAt == null || scheduledAt.isBlank() ? "INSERT INTO posts(user_id, content, file_name, post_type, feeling) VALUES (?, ?, ?, ?, ?)" : "INSERT INTO posts(user_id, content, file_name, post_type, feeling, scheduled_at, publish_status) VALUES (?, ?, ?, ?, ?, ?, 'SCHEDULED')";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.setString(3, fileName);
            ps.setString(4, postType);
            ps.setString(5, feeling);
            if (scheduledAt != null && !scheduledAt.isBlank()) ps.setTimestamp(6, java.sql.Timestamp.valueOf(scheduledAt.replace('T',' ') + (scheduledAt.length()==16 ? ":00" : "")));
            ps.executeUpdate();
            try (ResultSet gk = ps.getGeneratedKeys()) {
                if (gk.next()) return gk.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void publishDuePosts() {
        try (Connection c = getConnection()) {
            ensureFeatureSchema(c);
            try (java.sql.Statement st = c.createStatement()) {
                st.executeUpdate("UPDATE posts SET publish_status='PUBLISHED' WHERE publish_status='SCHEDULED' AND scheduled_at <= NOW()");
            }
        } catch (Exception e) { System.err.println("Could not publish scheduled posts: " + e.getMessage()); }
    }

    // ================= GET ALL POSTS (Optimized - Single Connection, No N+1) =================
    public List<UsersPost> getAllposts() {
        publishDuePosts();
        List<UsersPost> list = new ArrayList<>();

        String sql =
            "SELECT p.id AS posts_id, u.name, u.is_verified, p.user_id AS users_id, p.content, p.file_name, p.post_type, p.feeling, p.original_post_id, " +
            "       u.profile_pic, p.created_at, p.share_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LIKE'     THEN pi.user_id END) AS like_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LOVE'     THEN pi.user_id END) AS love_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='CARE'     THEN pi.user_id END) AS care_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='HAHA'     THEN pi.user_id END) AS haha_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='WOW'      THEN pi.user_id END) AS wow_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='SAD'      THEN pi.user_id END) AS sad_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='ANGRY'    THEN pi.user_id END) AS angry_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='DISLIKES' THEN pi.user_id END) AS dislike_count, " +
            "       COUNT(DISTINCT c.id) AS comment_count, COUNT(DISTINCT pv.user_id, pv.view_date) AS view_count " +
            "FROM posts p " +
            "JOIN users u ON p.user_id = u.id " +
            "LEFT JOIN post_interactions pi ON pi.post_id = p.id " +
            "LEFT JOIN comments c ON c.post_id = p.id " +
            "LEFT JOIN post_views pv ON pv.post_id = p.id " +
            "WHERE p.publish_status = 'PUBLISHED' AND (p.scheduled_at IS NULL OR p.scheduled_at <= NOW()) " +
            "GROUP BY p.id, u.name, u.is_verified, p.user_id, p.content, p.file_name, p.post_type, p.feeling, p.original_post_id, u.profile_pic, p.created_at, p.share_count " +
            "ORDER BY p.id DESC LIMIT 40";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            CommentDAO commentDAO = new CommentDAO();
            PollDAO pollDAO = new PollDAO();
            while (rs.next()) {
                UsersPost post = new UsersPost(
                        rs.getInt("posts_id"),
                        rs.getString("name"),
                        rs.getInt("users_id"),
                        rs.getString("content"),
                        rs.getString("file_name"),
                        rs.getString("post_type"),
                        rs.getString("feeling")
                );
                post.setProfile_pic(rs.getString("profile_pic"));
                try { post.setIs_verified(rs.getBoolean("is_verified")); } catch (Exception ignored) {}

                post.setTime(rs.getString("created_at"));

                post.setLikeCount(rs.getInt("like_count"));
                post.setLoveCount(rs.getInt("love_count"));
                post.setCareCount(rs.getInt("care_count"));
                post.setHahaCount(rs.getInt("haha_count"));
                post.setWowCount(rs.getInt("wow_count"));
                post.setSadCount(rs.getInt("sad_count"));
                post.setAngryCount(rs.getInt("angry_count"));
                post.setDislikes(rs.getInt("dislike_count"));
                post.setCommentCount(rs.getInt("comment_count"));
                post.setShareCount(rs.getInt("share_count"));
                post.setViewCount(rs.getInt("view_count"));

                int origId = rs.getInt("original_post_id");
                post.setOriginalPostId(origId);
                if (origId > 0) {
                    post.setOriginalPost(getPostById(origId));
                }

                post.setComments(commentDAO.getCommentsByPostIdInternal(conn, post.getId()));

                // Load poll options (userId=0 竊・no user-voted check needed at feed level)
                List<PollOption> pollOptions = pollDAO.getPollOptions(post.getId(), 0);
                if (!pollOptions.isEmpty()) {
                    post.setPollOptions(pollOptions);
                }

                list.add(post);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================= GET VIDEO POSTS =================
    public List<UsersPost> getVideoPosts() {
        List<UsersPost> list = new ArrayList<>();

        String sql =
            "SELECT p.id AS posts_id, u.name, u.is_verified, p.user_id AS users_id, p.content, p.file_name, p.post_type, p.feeling, " +
            "       u.profile_pic, p.created_at, p.share_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LIKE'     THEN pi.user_id END) AS like_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LOVE'     THEN pi.user_id END) AS love_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='CARE'     THEN pi.user_id END) AS care_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='HAHA'     THEN pi.user_id END) AS haha_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='WOW'      THEN pi.user_id END) AS wow_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='SAD'      THEN pi.user_id END) AS sad_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='ANGRY'    THEN pi.user_id END) AS angry_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='DISLIKES' THEN pi.user_id END) AS dislike_count, " +
            "       COUNT(DISTINCT c.id) AS comment_count " +
            "FROM posts p " +
            "JOIN users u ON p.user_id = u.id " +
            "LEFT JOIN post_interactions pi ON pi.post_id = p.id " +
            "LEFT JOIN comments c ON c.post_id = p.id " +
            "WHERE p.post_type = 'video' " +
            "GROUP BY p.id, u.name, u.is_verified, p.user_id, p.content, p.file_name, p.post_type, p.feeling, u.profile_pic, p.created_at, p.share_count " +
            "ORDER BY p.id DESC LIMIT 40";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            CommentDAO commentDAO = new CommentDAO();
            PollDAO pollDAO = new PollDAO();
            while (rs.next()) {
                UsersPost post = new UsersPost(
                        rs.getInt("posts_id"),
                        rs.getString("name"),
                        rs.getInt("users_id"),
                        rs.getString("content"),
                        rs.getString("file_name"),
                        rs.getString("post_type"),
                        rs.getString("feeling")
                );
                post.setProfile_pic(rs.getString("profile_pic"));
                try { post.setIs_verified(rs.getBoolean("is_verified")); } catch (Exception ignored) {}
                post.setTime(rs.getString("created_at"));

                post.setLikeCount(rs.getInt("like_count"));
                post.setLoveCount(rs.getInt("love_count"));
                post.setCareCount(rs.getInt("care_count"));
                post.setHahaCount(rs.getInt("haha_count"));
                post.setWowCount(rs.getInt("wow_count"));
                post.setSadCount(rs.getInt("sad_count"));
                post.setAngryCount(rs.getInt("angry_count"));
                post.setDislikes(rs.getInt("dislike_count"));
                post.setCommentCount(rs.getInt("comment_count"));
                post.setShareCount(rs.getInt("share_count"));

                int origId = rs.getInt("original_post_id");
                post.setOriginalPostId(origId);
                if (origId > 0) {
                    post.setOriginalPost(getPostById(origId));
                }

                post.setComments(commentDAO.getCommentsByPostIdInternal(conn, post.getId()));

                // Load poll options (userId=0 竊・no user-voted check needed at feed level)
                List<PollOption> pollOptions = pollDAO.getPollOptions(post.getId(), 0);
                if (!pollOptions.isEmpty()) {
                    post.setPollOptions(pollOptions);
                }

                list.add(post);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

        // ================= GET POSTS BY USER =================
    public List<UsersPost> getPostsByUserId(int userId) {
        List<UsersPost> list = new ArrayList<>();
        // প্রোফাইল পেজে ইউজারের নিজের সব পোস্ট (অরিজিনাল এবং শেয়ার করা) পাওয়ার জন্য ডিরেক্ট টেবিল কুয়েরি করা হচ্ছে
        String sql = "SELECT p.id as posts_id, u.name, p.user_id, p.content, p.file_name, p.post_type, p.feeling, u.profile_pic, p.created_at, p.share_count " +
                     "FROM posts p " +
                     "JOIN users u ON p.user_id = u.id " +
                     "WHERE p.user_id = ? " +
                     "ORDER BY p.id DESC LIMIT 40";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                CommentDAO commentDAO = new CommentDAO();
                while (rs.next()) {
                    UsersPost post = new UsersPost(
                            rs.getInt("posts_id"),
                            rs.getString("name"),
                            rs.getInt("user_id"),
                            rs.getString("content"),
                            rs.getString("file_name"),
                            rs.getString("post_type"),
                            rs.getString("feeling")
                    );
                    post.setProfile_pic(rs.getString("profile_pic"));
                    try { post.setIs_verified(rs.getBoolean("is_verified")); } catch (Exception ignored) {}
                    post.setTime(rs.getString("created_at"));
                    
                    // 爬ｰ爬ｿ爰游ｧ財ｦｯ爬ｾ爬歩ｦｶ爬ｨ 爬歩ｦｾ爬霞ｦｨ爰財ｦ・爬ｸ爰・ｦ・爬歩ｦｰ爬ｾ (爬・ｦｪ爰財ｦ游ｦｿ爬ｮ爬ｾ爬・ｦ憫ｦ｡)
                    post.setLikeCount(getInteractionCountInternal(conn, post.getId(), "LIKE"));
                    post.setLoveCount(getInteractionCountInternal(conn, post.getId(), "LOVE"));
                    post.setHahaCount(getInteractionCountInternal(conn, post.getId(), "HAHA"));
                    post.setAngryCount(getInteractionCountInternal(conn, post.getId(), "ANGRY"));
                    post.setCareCount(getInteractionCountInternal(conn, post.getId(), "CARE"));
                    post.setWowCount(getInteractionCountInternal(conn, post.getId(), "WOW"));
                    post.setSadCount(getInteractionCountInternal(conn, post.getId(), "SAD"));
                    post.setDislikes(getInteractionCountInternal(conn, post.getId(), "DISLIKES"));

                    post.setCommentCount(commentDAO.getCommentCountInternal(conn, post.getId()));
                    post.setShareCount(rs.getInt("share_count"));
                    
                    // 📝 Fetch comments for this post using the same connection
                    post.setComments(commentDAO.getCommentsByPostIdInternal(conn, post.getId()));

                    list.add(post);
                }
            }
        } catch (Exception e) {
            System.err.println("Error in getPostsByUserId: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // কানেকশন পাস করে কাউন্ট আনার জন্য ইন্টারনাল মেথড (পারফরম্যান্স ফিক্স)
    private int getInteractionCountInternal(Connection conn, int postId, String type) {
        String sql = "SELECT COUNT(*) FROM post_interactions WHERE post_id=? AND type=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setString(2, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    // ================= GET SINGLE POST =================
    public UsersPost getPostById(int postId) {
        String sql = "SELECT p.*, u.name, u.profile_pic, u.is_verified FROM posts p JOIN users u ON p.user_id = u.id WHERE p.id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                UsersPost post = new UsersPost(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getInt("user_id"),
                        rs.getString("content"),
                        rs.getString("file_name"),
                        rs.getString("post_type"),
                        rs.getString("feeling")
                );
                post.setProfile_pic(rs.getString("profile_pic"));
                try { post.setIs_verified(rs.getBoolean("is_verified")); } catch (Exception ignored) {}
                post.setTime(rs.getString("created_at"));
                
                // 爬ｰ爬ｿ爰游ｧ財ｦｯ爬ｾ爬歩ｦｶ爬ｨ 爬歩ｦｾ爬霞ｦｨ爰財ｦ・爬ｸ爰・ｦ・爬歩ｦｰ爬ｾ (AJAX 爬鐘ｦｰ 爬憫ｦｨ爰財ｦｯ 爬憫ｦｰ爰≒ｦｰ爬ｿ)
                post.setLikeCount(getInteractionCount(post.getId(), "LIKE"));
                post.setLoveCount(getInteractionCount(post.getId(), "LOVE"));
                post.setHahaCount(getInteractionCount(post.getId(), "HAHA"));
                post.setAngryCount(getInteractionCount(post.getId(), "ANGRY"));
                post.setCareCount(getInteractionCount(post.getId(), "CARE"));
                post.setWowCount(getInteractionCount(post.getId(), "WOW"));
                post.setSadCount(getInteractionCount(post.getId(), "SAD"));
                post.setDislikes(getInteractionCount(post.getId(), "DISLIKES"));
                
                post.setCommentCount(new CommentDAO().getCommentCount(post.getId()));
                post.setShareCount(rs.getInt("share_count"));
                try {
                    post.setOriginalPostId(rs.getInt("original_post_id"));
                } catch (Exception ignore) {}
                
                return post;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ================= SHARE POST (Media & Feeling সহ) =================
    public boolean sharePost(int userId, String content, String ownerName, String fileName, String postType) {
        return sharePost(userId, content, ownerName, fileName, postType, 0);
    }

    public boolean sharePost(int userId, String content, String ownerName, String fileName, String postType, int originalPostId) {
        String newContent = (ownerName != null && !ownerName.isEmpty()) ? "Shared from " + ownerName + ": " + content : content;
        String insertSql = "INSERT INTO posts(user_id, content, file_name, post_type, feeling, original_post_id) VALUES (?, ?, ?, ?, ?, ?)";
        String updateSql = "UPDATE posts SET share_count = share_count + 1 WHERE id = ?";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql);
                 PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psInsert.setInt(1, userId);
                psInsert.setString(2, newContent);
                psInsert.setString(3, fileName);
                psInsert.setString(4, postType != null ? postType : "shared");
                psInsert.setString(5, null); 
                psInsert.setInt(6, originalPostId);
                psInsert.executeUpdate();

                if (originalPostId > 0) {
                    psUpdate.setInt(1, originalPostId);
                    psUpdate.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================= REPOST / QUOTE POST =================
    public boolean repost(int userId, int originalPostId, String commentary) {
        String insertSql = "INSERT INTO posts(user_id, content, file_name, post_type, feeling, original_post_id) VALUES (?, ?, ?, ?, ?, ?)";
        String updateSql = "UPDATE posts SET share_count = share_count + 1 WHERE id = ?";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql);
                 PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psInsert.setInt(1, userId);
                psInsert.setString(2, (commentary != null && !commentary.trim().isEmpty()) ? commentary.trim() : "");
                psInsert.setString(3, null);
                psInsert.setString(4, "repost");
                psInsert.setString(5, null);
                psInsert.setInt(6, originalPostId);
                psInsert.executeUpdate();

                if (originalPostId > 0) {
                    psUpdate.setInt(1, originalPostId);
                    psUpdate.executeUpdate();
                }

                conn.commit();
                return true;
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================= TRENDING HASHTAGS (#) =================
    public List<ychatapp.model.beans.TrendingTopic> getTrendingHashtags() {
        java.util.Map<String, Integer> tagCounts = new java.util.LinkedHashMap<>();
        String sql = "SELECT content FROM posts WHERE content LIKE '%#%' ORDER BY id DESC LIMIT 200";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("#([\\p{L}\\p{N}_]+)");
            while (rs.next()) {
                String content = rs.getString("content");
                if (content != null) {
                    java.util.regex.Matcher matcher = pattern.matcher(content);
                    java.util.Set<String> seenInThisPost = new java.util.HashSet<>();
                    while (matcher.find()) {
                        String tag = matcher.group(1);
                        if (seenInThisPost.add(tag.toLowerCase())) {
                            tagCounts.put(tag, tagCounts.getOrDefault(tag, 0) + 1);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<ychatapp.model.beans.TrendingTopic> result = new ArrayList<>();
        tagCounts.entrySet().stream()
            .sorted((a, b) -> b.getValue().compareTo(a.getValue()))
            .limit(8)
            .forEach(e -> result.add(new ychatapp.model.beans.TrendingTopic(e.getKey(), e.getValue())));

        if (result.isEmpty()) {
            result.add(new ychatapp.model.beans.TrendingTopic("YChatApp", 12));
            result.add(new ychatapp.model.beans.TrendingTopic("Community", 9));
            result.add(new ychatapp.model.beans.TrendingTopic("TechNews", 7));
            result.add(new ychatapp.model.beans.TrendingTopic("Bangladesh", 5));
            result.add(new ychatapp.model.beans.TrendingTopic("SocialFeed", 4));
        }

        return result;
    }

    // ================= GET POSTS BY HASHTAG =================
    public List<UsersPost> getPostsByHashtag(String tag) {
        List<UsersPost> list = new ArrayList<>();
        String sql =
            "SELECT p.id AS posts_id, u.name, u.is_verified, p.user_id AS users_id, p.content, p.file_name, p.post_type, p.feeling, p.original_post_id, " +
            "       u.profile_pic, p.created_at, p.share_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LIKE'     THEN pi.user_id END) AS like_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LOVE'     THEN pi.user_id END) AS love_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='CARE'     THEN pi.user_id END) AS care_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='HAHA'     THEN pi.user_id END) AS haha_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='WOW'      THEN pi.user_id END) AS wow_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='SAD'      THEN pi.user_id END) AS sad_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='ANGRY'    THEN pi.user_id END) AS angry_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='DISLIKES' THEN pi.user_id END) AS dislike_count, " +
            "       COUNT(DISTINCT c.id) AS comment_count " +
            "FROM posts p " +
            "JOIN users u ON p.user_id = u.id " +
            "LEFT JOIN post_interactions pi ON pi.post_id = p.id " +
            "LEFT JOIN comments c ON c.post_id = p.id " +
            "WHERE p.content LIKE ? " +
            "GROUP BY p.id, u.name, u.is_verified, p.user_id, p.content, p.file_name, p.post_type, p.feeling, p.original_post_id, u.profile_pic, p.created_at, p.share_count " +
            "ORDER BY p.id DESC LIMIT 40";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%#" + tag + "%");
            try (ResultSet rs = ps.executeQuery()) {
                CommentDAO commentDAO = new CommentDAO();
                PollDAO pollDAO = new PollDAO();
                while (rs.next()) {
                    UsersPost post = new UsersPost(
                            rs.getInt("posts_id"),
                            rs.getString("name"),
                            rs.getInt("users_id"),
                            rs.getString("content"),
                            rs.getString("file_name"),
                            rs.getString("post_type"),
                            rs.getString("feeling")
                    );
                    post.setProfile_pic(rs.getString("profile_pic"));
                    try { post.setIs_verified(rs.getBoolean("is_verified")); } catch (Exception ignored) {}
                    post.setTime(rs.getString("created_at"));

                    post.setLikeCount(rs.getInt("like_count"));
                    post.setLoveCount(rs.getInt("love_count"));
                    post.setCareCount(rs.getInt("care_count"));
                    post.setHahaCount(rs.getInt("haha_count"));
                    post.setWowCount(rs.getInt("wow_count"));
                    post.setSadCount(rs.getInt("sad_count"));
                    post.setAngryCount(rs.getInt("angry_count"));
                    post.setDislikes(rs.getInt("dislike_count"));
                    post.setCommentCount(rs.getInt("comment_count"));
                    post.setShareCount(rs.getInt("share_count"));

                    int origId = rs.getInt("original_post_id");
                    post.setOriginalPostId(origId);
                    if (origId > 0) {
                        post.setOriginalPost(getPostById(origId));
                    }

                    post.setComments(commentDAO.getCommentsByPostIdInternal(conn, post.getId()));

                    List<PollOption> pollOptions = pollDAO.getPollOptions(post.getId(), 0);
                    if (!pollOptions.isEmpty()) {
                        post.setPollOptions(pollOptions);
                    }

                    list.add(post);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================= LIKE / REACTION =================
    public void handleInteraction(int postId, int userId, String type) {
        String normalizedType = type.toUpperCase();
        if (normalizedType.equals("DISLIKE")) {
            normalizedType = "DISLIKES";
        }
        try (Connection conn = getConnection()) {
            // Check existing reaction
            String currentType = null;
            PreparedStatement psCheck = conn.prepareStatement("SELECT type FROM post_interactions WHERE post_id=? AND user_id=?");
            psCheck.setInt(1, postId);
            psCheck.setInt(2, userId);
            ResultSet rsCheck = psCheck.executeQuery();
            if (rsCheck.next()) {
                currentType = rsCheck.getString("type");
            }
            rsCheck.close();
            psCheck.close();

            // আগে যদি কোনো রিঅ্যাকশন থাকে তা ডিলিট করা (Toggle logic)
            PreparedStatement ps1 = conn.prepareStatement(
                    "DELETE FROM post_interactions WHERE post_id=? AND user_id=?");
            ps1.setInt(1, postId);
            ps1.setInt(2, userId);
            ps1.executeUpdate();
            ps1.close();

            // নতুন রিঅ্যাকশন ইনসার্ট করা (যদি আগেরটার সমান না হয়)
            if (currentType == null || !normalizedType.equals(currentType)) {
                PreparedStatement ps2 = conn.prepareStatement(
                        "INSERT INTO post_interactions(post_id, user_id, type) VALUES(?,?,?)");
                ps2.setInt(1, postId);
                ps2.setInt(2, userId);
                ps2.setString(3, normalizedType);
                ps2.executeUpdate();
                ps2.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ================= COUNT REACTIONS =================
    public int getInteractionCount(int postId, String type) {
        String sql = "SELECT COUNT(*) FROM post_interactions WHERE post_id=? AND type=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setString(2, type);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    public void addComment(int postId, int userId, String text, String fileName) {
        // Database column names: post_id, user_id, comment_text, file_name
        String sql = "INSERT INTO comments(post_id, user_id, comment_text, file_name) VALUES(?,?,?,?)";
        
        try (Connection conn = getConnection(); // Ekhane 'con' define kora holo
             PreparedStatement ps = conn.prepareStatement(sql)) { // Ekhon 'con' kaj korbe
            
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.setString(3, text);
            ps.setString(4, fileName);
            
            ps.executeUpdate();
        } catch (Exception e) {
            System.out.println("Comment Upload Error: " + e.getMessage());
            e.printStackTrace();
        }
    }



    // ================= GET COMMENTS =================
    // কমেন্ট এখন স্ট্রিং এর বদলে অবজেক্ট হিসেবে নিলে ভালো, তবে আপনার আগের কোড বজায় রাখা হয়েছে
    public List<String> getCommentsByPostId(int postId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT comment_text FROM comments WHERE post_id=? ORDER BY id DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("comment_text"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public List<UsersPost> searchPosts(String query) {
        List<UsersPost> list = new ArrayList<>();
        String sql = "SELECT * FROM user_posts_view WHERE content LIKE ? ORDER BY posts_id DESC LIMIT 20";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + query + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                UsersPost post = new UsersPost(
                        rs.getInt("posts_id"),
                        rs.getString("name"),
                        rs.getInt("users_id"),
                        rs.getString("content"),
                        rs.getString("file_name"),
                        rs.getString("post_type"),
                        rs.getString("feeling")
                );
                post.setProfile_pic(rs.getString("profile_pic"));
                post.setTime(rs.getString("created_at"));
                list.add(post);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean deletePost(int postId, int ownerId) {
        String verifyOwner = "SELECT user_id FROM posts WHERE id = ? FOR UPDATE";
        String delInteractions = "DELETE FROM post_interactions WHERE post_id = ?";
        String delComments = "DELETE FROM comments WHERE post_id = ?";
        String delPost = "DELETE FROM posts WHERE id = ? AND user_id = ?";
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement owner = conn.prepareStatement(verifyOwner)) {
                owner.setInt(1, postId);
                try (ResultSet rs = owner.executeQuery()) {
                    if (!rs.next() || rs.getInt(1) != ownerId) {
                        conn.rollback();
                        return false;
                    }
                }
            }
            try (PreparedStatement ps1 = conn.prepareStatement(delInteractions);
                 PreparedStatement ps2 = conn.prepareStatement(delComments);
                 PreparedStatement ps3 = conn.prepareStatement(delPost)) {
                ps1.setInt(1, postId);
                ps1.executeUpdate();
                ps2.setInt(1, postId);
                ps2.executeUpdate();
                ps3.setInt(1, postId);
                ps3.setInt(2, ownerId);
                boolean success = ps3.executeUpdate() > 0;
                conn.commit();
                return success;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    // ================= SAVE POST =================
    public boolean savePost(int userId, int postId) {
        String sql = "INSERT IGNORE INTO saved_posts (user_id, post_id) VALUES (?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, postId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================= UNSAVE POST =================
    public boolean unsavePost(int userId, int postId) {
        String sql = "DELETE FROM saved_posts WHERE user_id = ? AND post_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, postId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================= IS POST SAVED =================
    public boolean isPostSaved(int userId, int postId) {
        String sql = "SELECT 1 FROM saved_posts WHERE user_id = ? AND post_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, postId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ================= GET SAVED POSTS =================
    public List<UsersPost> getSavedPosts(int userId) {
        List<UsersPost> list = new ArrayList<>();
        String sql =
            "SELECT p.id AS posts_id, u.name, p.user_id AS users_id, p.content, p.file_name, p.post_type, p.feeling, " +
            "       u.profile_pic, p.created_at, p.share_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LIKE'     THEN pi.user_id END) AS like_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LOVE'     THEN pi.user_id END) AS love_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='CARE'     THEN pi.user_id END) AS care_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='HAHA'     THEN pi.user_id END) AS haha_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='WOW'      THEN pi.user_id END) AS wow_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='SAD'      THEN pi.user_id END) AS sad_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='ANGRY'    THEN pi.user_id END) AS angry_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='DISLIKES'  THEN pi.user_id END) AS dislike_count " +
            "FROM saved_posts sp " +
            "JOIN posts p ON sp.post_id = p.id " +
            "JOIN users u ON p.user_id = u.id " +
            "LEFT JOIN post_interactions pi ON p.id = pi.post_id " +
            "WHERE sp.user_id = ? " +
            "GROUP BY p.id, u.name, p.user_id, p.content, p.file_name, p.post_type, p.feeling, u.profile_pic, p.created_at, p.share_count, sp.saved_at " +
            "ORDER BY sp.saved_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UsersPost up = new UsersPost();
                    up.setId(rs.getInt("posts_id"));
                    up.setName(rs.getString("name"));
                    up.setUserId(rs.getInt("users_id"));
                    up.setContent(rs.getString("content"));
                    up.setFile_name(rs.getString("file_name"));
                    up.setPost_type(rs.getString("post_type"));
                    up.setFeeling(rs.getString("feeling"));
                    up.setProfile_pic(rs.getString("profile_pic"));
                    up.setTime(rs.getString("created_at"));
                    up.setShareCount(rs.getInt("share_count"));

                    up.setLikeCount(rs.getInt("like_count"));
                    up.setLoveCount(rs.getInt("love_count"));
                    up.setCareCount(rs.getInt("care_count"));
                    up.setHahaCount(rs.getInt("haha_count"));
                    up.setWowCount(rs.getInt("wow_count"));
                    up.setSadCount(rs.getInt("sad_count"));
                    up.setAngryCount(rs.getInt("angry_count"));
                    up.setDislikes(rs.getInt("dislike_count"));

                    list.add(up);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ================= GET MEMORIES POSTS =================
    public List<UsersPost> getMemoriesPosts(int userId) {
        List<UsersPost> list = new ArrayList<>();
        String sql =
            "SELECT p.id AS posts_id, u.name, p.user_id AS users_id, p.content, p.file_name, p.post_type, p.feeling, " +
            "       u.profile_pic, p.created_at, p.share_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LIKE'     THEN pi.user_id END) AS like_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='LOVE'     THEN pi.user_id END) AS love_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='CARE'     THEN pi.user_id END) AS care_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='HAHA'     THEN pi.user_id END) AS haha_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='WOW'      THEN pi.user_id END) AS wow_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='SAD'      THEN pi.user_id END) AS sad_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='ANGRY'    THEN pi.user_id END) AS angry_count, " +
            "       COUNT(DISTINCT CASE WHEN pi.type='DISLIKES'  THEN pi.user_id END) AS dislike_count " +
            "FROM posts p " +
            "JOIN users u ON p.user_id = u.id " +
            "LEFT JOIN post_interactions pi ON p.id = pi.post_id " +
            "WHERE p.user_id = ? " +
            "GROUP BY p.id, u.name, p.user_id, p.content, p.file_name, p.post_type, p.feeling, u.profile_pic, p.created_at, p.share_count " +
            "ORDER BY p.created_at ASC " +
            "LIMIT 10";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UsersPost up = new UsersPost();
                    up.setId(rs.getInt("posts_id"));
                    up.setName(rs.getString("name"));
                    up.setUserId(rs.getInt("users_id"));
                    up.setContent(rs.getString("content"));
                    up.setFile_name(rs.getString("file_name"));
                    up.setPost_type(rs.getString("post_type"));
                    up.setFeeling(rs.getString("feeling"));
                    up.setProfile_pic(rs.getString("profile_pic"));
                    up.setTime(rs.getString("created_at"));
                    up.setShareCount(rs.getInt("share_count"));

                    up.setLikeCount(rs.getInt("like_count"));
                    up.setLoveCount(rs.getInt("love_count"));
                    up.setCareCount(rs.getInt("care_count"));
                    up.setHahaCount(rs.getInt("haha_count"));
                    up.setWowCount(rs.getInt("wow_count"));
                    up.setSadCount(rs.getInt("sad_count"));
                    up.setAngryCount(rs.getInt("angry_count"));
                    up.setDislikes(rs.getInt("dislike_count"));

                    list.add(up);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}