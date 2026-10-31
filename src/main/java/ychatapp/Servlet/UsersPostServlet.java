package ychatapp.Servlet;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import ychatapp.model.beans.UsersBeans;
import ychatapp.model.beans.UsersPost;
import ychatapp.model.dao.AdDAO;
import ychatapp.model.dao.PollDAO;
import ychatapp.model.dao.PostDAO;
import ychatapp.model.dao.StoryDAO;

@WebServlet({"/UsersPostServlet", "/main.jsp", "/main", "/home"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UsersPostServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        PostDAO dao = new PostDAO();
        List<UsersPost> postList = new ArrayList<>();
        List<UsersPost> reelsList = new ArrayList<>();
        
        String filterTag = req.getParameter("tag");
        List<UsersPost> allPosts;
        if (filterTag != null && !filterTag.trim().isEmpty()) {
            filterTag = filterTag.trim().replace("#", "");
            allPosts = dao.getPostsByHashtag(filterTag);
            req.setAttribute("filterTag", filterTag);
        } else {
            allPosts = dao.getAllposts();
        }
        
        HttpSession session = req.getSession(false);
        UsersBeans ub = (session != null)
                ? (UsersBeans) session.getAttribute("ub")
                : null;
        if (ub == null) {
            res.sendRedirect("UsersLoginServlet");
            return;
        }

        new ychatapp.model.dao.HiddenContentDAO().filterHiddenContent(allPosts, ub.getId());
        String feedSort = req.getParameter("sort");
        if ("popular".equalsIgnoreCase(feedSort)) {
            allPosts.sort(java.util.Comparator.comparingInt((UsersPost p) -> p.getLikeCount() + p.getLoveCount() + p.getCareCount() + p.getHahaCount() + p.getWowCount() + p.getCommentCount() + p.getShareCount()).reversed().thenComparing(java.util.Comparator.comparingInt(UsersPost::getId).reversed()));
            req.setAttribute("feedSort", "popular");
        } else {
            allPosts.sort(java.util.Comparator.comparingInt(UsersPost::getId).reversed());
            req.setAttribute("feedSort", "recent");
        }
        ychatapp.model.dao.UsersDAO usersDAO = new ychatapp.model.dao.UsersDAO();
        req.setAttribute("friendList", usersDAO.getFriends(ub.getId()));
        req.setAttribute("suggestedFriends", usersDAO.getSuggestedUsers(ub.getId(), 6));

        PollDAO pollDAO = new PollDAO();
        for (UsersPost post : allPosts) {
            String q = pollDAO.getPollQuestion(post.getId());
            if (q != null) {
                post.setPollQuestion(q);
                List<ychatapp.model.beans.PollOption> pollOptions = pollDAO.getPollOptions(post.getId(), ub.getId());
                if (!pollOptions.isEmpty()) post.setPollOptions(pollOptions);
            }
            if ("REEL".equalsIgnoreCase(post.getPost_type())) {
                reelsList.add(post);
            } else {
                postList.add(post);
            }
        }

        req.setAttribute("postList", postList);
        req.setAttribute("reelsList", reelsList);
        req.setAttribute("storyList", new StoryDAO().getActiveStories(ub.getId()));
        req.setAttribute("sponsoredAd", new AdDAO().getRandomAd());
        req.setAttribute("trendingTags", dao.getTrendingHashtags());
        
        req.getRequestDispatcher("/WEB-INF/jsp/main.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        UsersBeans ub = (session != null)
                ? (UsersBeans) session.getAttribute("ub")
                : null;

        // 🔐 LOGIN CHECK
        if (ub == null) {
            res.sendRedirect("UsersLoginServlet");
            return;
        }

        PostDAO dao = new PostDAO();
        String action = req.getParameter("action");

        // 🔄 HANDLE SHARE OR REPOST POST
        if ("SHARE".equalsIgnoreCase(action) || "REPOST".equalsIgnoreCase(action)) {
            String postIdStr = req.getParameter("postId");
            if (postIdStr != null) {
                int postId = Integer.parseInt(postIdStr);
                UsersPost originalPost = dao.getPostById(postId);
                
                if (originalPost != null) {
                    String commentary = req.getParameter("commentary");
                    if (commentary == null) commentary = req.getParameter("quoteText");
                    if ("REPOST".equalsIgnoreCase(action) || (commentary != null && !commentary.trim().isEmpty())) {
                        dao.repost(ub.getId(), postId, commentary);
                    } else {
                        dao.sharePost(ub.getId(), originalPost.getContent(), originalPost.getName(), originalPost.getFile_name(), "shared", postId);
                    }
                }
            }
        }
        // 🗑️ HANDLE DELETE POST
        else if ("DELETE".equalsIgnoreCase(action)) {
            String postIdStr = req.getParameter("postId");
            boolean success = false;
            if (postIdStr != null) {
                int postId = Integer.parseInt(postIdStr);
                success = dao.deletePost(postId, ub.getId());
            }
            if ("true".equals(req.getParameter("ajax"))) {
                res.setContentType("application/json");
                res.setCharacterEncoding("UTF-8");
                res.getWriter().write("{\"success\": " + success + "}");
                return;
            }
        } 
        // 📝 HANDLE NEW POST
        else {
            String content = req.getParameter("content");
            String feeling = req.getParameter("feeling");

            String postType = req.getParameter("type");
            if (postType == null || postType.isEmpty()) {
                postType = "original";
            }

            String fileName = null;

            try {
                Part part = req.getPart("media");

                if (part != null && part.getSize() > 0) {
                    String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();

                    if (submittedFileName != null && !submittedFileName.isEmpty()) {
                        fileName = System.currentTimeMillis() + "_" + submittedFileName;

                        String uploadPath = getServletContext().getRealPath("/img");
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) {
                            uploadDir.mkdirs();
                        }

                        part.write(uploadPath + File.separator + fileName);
                        
                        if(submittedFileName.toLowerCase().endsWith(".mp4") || submittedFileName.toLowerCase().endsWith(".webm")) {
                            postType = "video";
                        } else {
                            postType = "image";
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            String scheduledAt = req.getParameter("scheduledAt");
            if (scheduledAt != null && scheduledAt.isBlank()) scheduledAt = null;
            int newPostId = dao.addPost(ub.getId(), content, fileName, postType, feeling, scheduledAt);
            boolean success = newPostId > 0;
            String pollQuestion = req.getParameter("pollQuestion");
            String[] submittedOptions = req.getParameterValues("pollOption");
            if (success && pollQuestion != null && !pollQuestion.trim().isEmpty()) {
                List<String> cleanOptions = new ArrayList<>();
                if (submittedOptions != null) for (String option : submittedOptions) if (option != null && !option.trim().isEmpty()) cleanOptions.add(option.trim());
                if (cleanOptions.size() < 2 || cleanOptions.size() > 6 || !new PollDAO().savePoll(newPostId, pollQuestion, cleanOptions)) {
                    dao.deletePost(newPostId, ub.getId()); success = false;
                }
            }
            if (success && scheduledAt == null) ychatapp.websocket.PostRealtime.publish(ub.getId(), newPostId, "POST_CREATED", ub.getName());
            
            if ("true".equals(req.getParameter("ajax"))) {
                res.setContentType("application/json");
                res.setCharacterEncoding("UTF-8");
                res.getWriter().write("{\"success\": " + success + "}");
                return;
            }
        }

        res.sendRedirect("UsersPostServlet");
    }
}