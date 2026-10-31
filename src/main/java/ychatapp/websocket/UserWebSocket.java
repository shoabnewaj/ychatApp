package ychatapp.websocket;
 
import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
 
import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import ychatapp.model.LiveManager;

@ServerEndpoint("/ws/user/{username}")
public class UserWebSocket {
    private static final org.slf4j.Logger logger = org.slf4j.LoggerFactory.getLogger(UserWebSocket.class);
 
    private static final ConcurrentHashMap<String, Set<Session>> clients = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, Long> lastActiveMap = new ConcurrentHashMap<>();

    public static class PendingCallInfo {
        public String caller;
        public String receiver;
        public String type = "voice";
        public long timestamp;
        public boolean answered = false;
        public boolean rejected = false;
    }
    private static final ConcurrentHashMap<String, PendingCallInfo> pendingCalls = new ConcurrentHashMap<>();

    public static void touchUser(String username) {
        if (username != null && !username.trim().isEmpty()) {
            lastActiveMap.put(username.trim().toLowerCase(), System.currentTimeMillis());
        }
    }

    public static void setOffline(String username) {
        if (username != null) {
            lastActiveMap.remove(username.trim().toLowerCase());
        }
    }

    public static PendingCallInfo getPendingCall(String username) {
        if (username == null) return null;
        String key = username.trim().toLowerCase();
        PendingCallInfo call = pendingCalls.get(key);
        if (call != null) {
            if (System.currentTimeMillis() - call.timestamp > 45000 || call.answered || call.rejected) {
                pendingCalls.remove(key);
                return null;
            }
        }
        return call;
    }

    public static void clearPendingCall(String username) {
        if (username != null) {
            pendingCalls.remove(username.trim().toLowerCase());
        }
    }
 
    @OnOpen
    public void onOpen(Session session, @PathParam("username") String encodedUsername) {
        String username = decodeUsername(encodedUsername);
        touchUser(username);
        clients.computeIfAbsent(username, k -> ConcurrentHashMap.newKeySet()).add(session);
        System.out.println("User Online: " + username + " (sessions: " + clients.get(username).size() + ")");
        broadcastOnlineUsers();

        PendingCallInfo pending = getPendingCall(username);
        if (pending != null && !pending.answered && !pending.rejected) {
            try {
                com.google.gson.JsonObject callJson = new com.google.gson.JsonObject();
                callJson.addProperty("type", pending.type);
                session.getBasicRemote().sendText("CALL_OFFER|" + pending.caller + "|" + callJson.toString());
            } catch (Exception ignored) {}
        }
    }
 
    @OnMessage
    public void onMessage(String message, Session session, @PathParam("username") String encodedSender) {
        String sender = decodeUsername(encodedSender);
        try {
            String[] parts = message.split("\\|", 3);
            if (parts.length < 2) {
                return;
            }
            String type = parts[0];
            String receiver = parts[1];
            String content = parts.length > 2 ? parts[2] : "";

            if ("PING".equalsIgnoreCase(type)) {
                try {
                    session.getBasicRemote().sendText("PONG|server");
                } catch (Exception ignored) {}
                return;
            }

            if ("CHAT".equalsIgnoreCase(type)) {
                int generatedId = 0;
                String textToSave = content;
                Integer replyToId = null;
                String replyToText = null;

                // Support JSON payload for quote replies
                if (content.startsWith("{") && content.contains("\"text\":")) {
                    try {
                        com.google.gson.JsonObject obj = com.google.gson.JsonParser.parseString(content).getAsJsonObject();
                        if (obj.has("text")) textToSave = obj.get("text").getAsString();
                        if (obj.has("replyId") && !obj.get("replyId").isJsonNull()) replyToId = obj.get("replyId").getAsInt();
                        if (obj.has("replyText") && !obj.get("replyText").isJsonNull()) replyToText = obj.get("replyText").getAsString();
                    } catch (Exception ignored) {}
                }

                // 1. Persist chat message to database
                try {
                    generatedId = new ychatapp.model.dao.MessageDAO().saveMessageWithReply(sender, receiver, textToSave, replyToId, replyToText);
                } catch (Exception ex) {
                    logger.error("Failed to persist message from {} to {}: {}", sender, receiver, ex.getMessage());
                }

                // 2. Deliver message with ID in real-time
                com.google.gson.JsonObject msgPayload = new com.google.gson.JsonObject();
                msgPayload.addProperty("id", generatedId);
                msgPayload.addProperty("sender", sender);
                msgPayload.addProperty("receiver", receiver);
                msgPayload.addProperty("message", textToSave);
                msgPayload.addProperty("isRead", false);
                msgPayload.addProperty("isEdited", false);
                msgPayload.addProperty("isDeleted", false);
                if (replyToId != null) msgPayload.addProperty("replyToId", replyToId);
                if (replyToText != null) msgPayload.addProperty("replyToText", replyToText);

                String payloadJson = msgPayload.toString();

                boolean isReceiverOnline = clients.containsKey(receiver) && !clients.get(receiver).isEmpty();
                sendMessageToUser(receiver, "CHAT|" + sender + "|" + payloadJson);
                sendMessageToUser(sender, "CHAT_ACK|" + receiver + "|" + payloadJson);

                final boolean isAiTarget = "Gemini AI".equalsIgnoreCase(receiver) || "gemini".equalsIgnoreCase(receiver);
                final boolean hasAiTag = textToSave.trim().toLowerCase().startsWith("@gemini") || textToSave.trim().toLowerCase().startsWith("@ai");

                // 3. If receiver is offline, record notification (skip for Gemini AI)
                if (!isReceiverOnline && !isAiTarget) {
                    try {
                        String preview = textToSave.length() > 30 ? textToSave.substring(0, 30) + "..." : textToSave;
                        new ychatapp.model.dao.NotificationDAO().addNotificationByUsername(receiver, sender + ": " + preview);
                    } catch (Exception ex) {
                        logger.error("Failed to record offline notification: {}", ex.getMessage());
                    }
                }

                // 4. Handle Direct AI Assistant or @gemini invocation in chat
                if (isAiTarget || hasAiTag) {
                    final String rawText = textToSave;
                    final int promptMsgId = generatedId;
                    final String chatSender = sender;
                    final String chatReceiver = receiver;

                    ychatapp.model.bo.GeminiService.runAsync(() -> {
                        try {
                            // Send typing indicator from Gemini AI
                            sendMessageToUser(chatSender, "TYPING|Gemini AI|typing");
                            if (!isAiTarget && !chatReceiver.equalsIgnoreCase(chatSender)) {
                                sendMessageToUser(chatReceiver, "TYPING|Gemini AI|typing");
                            }

                            String promptToAsk = rawText;
                            if (hasAiTag) {
                                promptToAsk = rawText.replaceFirst("(?i)^@(gemini|ai)\\s*", "").trim();
                                if (promptToAsk.isEmpty()) promptToAsk = rawText;
                            }

                            String aiReply = ychatapp.model.bo.GeminiService.generateResponse(promptToAsk);
                            if (aiReply == null || aiReply.trim().isEmpty()) {
                                aiReply = "Sorry, I couldn't generate a response. Please check your Gemini API key or try again.";
                            }

                            // Save AI response to DB
                            String targetPartner = isAiTarget ? chatSender : chatReceiver;
                            int aiId = new ychatapp.model.dao.MessageDAO().saveMessageWithReply(
                                "Gemini AI", 
                                isAiTarget ? chatSender : targetPartner, 
                                aiReply, 
                                promptMsgId > 0 ? promptMsgId : null, 
                                rawText
                            );

                            com.google.gson.JsonObject aiMsgObj = new com.google.gson.JsonObject();
                            aiMsgObj.addProperty("id", aiId);
                            aiMsgObj.addProperty("sender", "Gemini AI");
                            aiMsgObj.addProperty("receiver", targetPartner);
                            aiMsgObj.addProperty("message", aiReply);
                            aiMsgObj.addProperty("isRead", true);
                            aiMsgObj.addProperty("isEdited", false);
                            aiMsgObj.addProperty("isDeleted", false);
                            if (promptMsgId > 0) {
                                aiMsgObj.addProperty("replyToId", promptMsgId);
                                aiMsgObj.addProperty("replyToText", rawText);
                            }

                            new ychatapp.model.dao.MessageDAO().markAsRead("Gemini AI", isAiTarget ? chatSender : targetPartner);
                            String aiPayloadStr = aiMsgObj.toString();

                            // Stop typing
                            sendMessageToUser(chatSender, "TYPING|Gemini AI|stopped");
                            if (!isAiTarget && !chatReceiver.equalsIgnoreCase(chatSender)) {
                                sendMessageToUser(chatReceiver, "TYPING|Gemini AI|stopped");
                            }

                            // Deliver AI response
                            sendMessageToUser(chatSender, "CHAT|Gemini AI|" + aiPayloadStr);
                            if (!isAiTarget && !chatReceiver.equalsIgnoreCase(chatSender)) {
                                sendMessageToUser(chatReceiver, "CHAT|Gemini AI|" + aiPayloadStr);
                            }
                        } catch (Exception err) {
                            logger.error("Error in AI chat async generation: {}", err.getMessage());
                        }
                    });
                }
            } else if ("EDIT_MSG".equalsIgnoreCase(type)) {
                try {
                    com.google.gson.JsonObject obj = com.google.gson.JsonParser.parseString(content).getAsJsonObject();
                    int msgId = obj.get("id").getAsInt();
                    String newText = obj.get("text").getAsString();
                    new ychatapp.model.dao.MessageDAO().editMessage(msgId, sender, newText);
                    sendMessageToUser(receiver, "EDIT_MSG|" + sender + "|" + content);
                    sendMessageToUser(sender, "EDIT_MSG_ACK|" + receiver + "|" + content);
                } catch (Exception ex) {
                    logger.error("Failed to edit message: {}", ex.getMessage());
                }
            } else if ("DELETE_MSG".equalsIgnoreCase(type)) {
                try {
                    com.google.gson.JsonObject obj = com.google.gson.JsonParser.parseString(content).getAsJsonObject();
                    int msgId = obj.get("id").getAsInt();
                    new ychatapp.model.dao.MessageDAO().deleteMessageForEveryone(msgId, sender);
                    sendMessageToUser(receiver, "DELETE_MSG|" + sender + "|" + content);
                    sendMessageToUser(sender, "DELETE_MSG_ACK|" + receiver + "|" + content);
                } catch (Exception ex) {
                    logger.error("Failed to delete message: {}", ex.getMessage());
                }
            } else if ("REACTION".equalsIgnoreCase(type)) {
                try {
                    com.google.gson.JsonObject obj = com.google.gson.JsonParser.parseString(content).getAsJsonObject();
                    int msgId = obj.get("id").getAsInt();
                    String reaction = (obj.has("reaction") && !obj.get("reaction").isJsonNull()) ? obj.get("reaction").getAsString() : null;
                    new ychatapp.model.dao.MessageDAO().updateReaction(msgId, reaction);
                    sendMessageToUser(receiver, "REACTION|" + sender + "|" + content);
                    sendMessageToUser(sender, "REACTION_ACK|" + receiver + "|" + content);
                } catch (Exception ex) {
                    logger.error("Failed to update reaction: {}", ex.getMessage());
                }
            } else if ("TYPING".equalsIgnoreCase(type)) {
                sendMessageToUser(receiver, "TYPING|" + sender + "|" + content);
            } else if ("SEEN".equalsIgnoreCase(type)) {
                try {
                    new ychatapp.model.dao.MessageDAO().markAsRead(receiver, sender);
                } catch (Exception ex) {
                    logger.error("Failed to mark messages as read: {}", ex.getMessage());
                }
                sendMessageToUser(receiver, "SEEN|" + sender);
            } else if ("LIVE_CHAT".equalsIgnoreCase(type)) {
                LiveManager.LiveStreamInfo live = LiveManager.getStream(receiver);
                if (live != null && !live.getMutedViewers().contains(sender) && !live.getBlockedViewers().contains(sender)) broadcastToLiveStream(receiver, "LIVE_CHAT|" + receiver + "|" + sender + "|" + content);
            } else if ("LIVE_REACTION".equalsIgnoreCase(type)) {
                LiveManager.LiveStreamInfo live = LiveManager.getStream(receiver);
                if (live != null && !live.getMutedViewers().contains(sender) && !live.getBlockedViewers().contains(sender)) broadcastToLiveStream(receiver, "LIVE_REACTION|" + receiver + "|" + sender + "|" + content);
            } else if ("LIVE_MODERATE".equalsIgnoreCase(type)) {
                LiveManager.LiveStreamInfo live = LiveManager.getStream(receiver);
                if (live != null && sender.equals(receiver)) {
                    com.google.gson.JsonObject data = com.google.gson.JsonParser.parseString(content).getAsJsonObject();
                    String target = data.has("target") ? data.get("target").getAsString() : "";
                    String action = data.has("action") ? data.get("action").getAsString() : "";
                    if (live.getViewers().contains(target)) {
                        if ("mute".equals(action)) live.getMutedViewers().add(target);
                        else if ("unmute".equals(action)) live.getMutedViewers().remove(target);
                        else if ("block".equals(action)) { live.getBlockedViewers().add(target); live.getViewers().remove(target); sendMessageToUser(target, "LIVE_BLOCKED|" + receiver + "|{}"); sendMessageToUser(receiver, "LIVE_VIEWER_COUNT|" + receiver + "|" + live.getViewers().size()); }
                    }
                }
            } else if ("LIVE_JOIN_REQUEST".equalsIgnoreCase(type)) {
                LiveManager.LiveStreamInfo live = LiveManager.getStream(receiver);
                if (live != null && !sender.equals(receiver) && !live.getBlockedViewers().contains(sender)) {
                    LiveManager.addViewer(receiver, sender);
                    sendMessageToUser(receiver, "LIVE_VIEWER_COUNT|" + receiver + "|" + live.getViewers().size());
                    sendMessageToUser(receiver, "LIVE_JOIN_REQUEST|" + sender + "|" + content);
                    sendMessageToUser(sender, "LIVE_JOINED|" + receiver + "|{}");
                } else {
                    sendMessageToUser(sender, "LIVE_ENDED|" + receiver + "|{}");
                }
            } else if ("LIVE_LEAVE".equalsIgnoreCase(type)) {
                LiveManager.removeViewer(receiver, sender);
                LiveManager.LiveStreamInfo live = LiveManager.getStream(receiver);
                if (live != null) sendMessageToUser(receiver, "LIVE_VIEWER_COUNT|" + receiver + "|" + live.getViewers().size());
                sendMessageToUser(receiver, "LIVE_VIEWER_LEFT|" + sender + "|{}");
            } else if ("CALL_OFFER".equalsIgnoreCase(type)) {
                touchUser(sender);
                String callType = "voice";
                if (content != null && content.contains("\"video\"")) {
                    callType = "video";
                }
                PendingCallInfo call = new PendingCallInfo();
                call.caller = sender;
                call.receiver = receiver;
                call.type = callType;
                call.timestamp = System.currentTimeMillis();
                pendingCalls.put(receiver.trim().toLowerCase(), call);

                sendMessageToUser(receiver, "CALL_OFFER|" + sender + "|" + content);
            } else if ("CALL_ANSWER".equalsIgnoreCase(type)) {
                touchUser(sender);
                clearPendingCall(sender);
                clearPendingCall(receiver);
                sendMessageToUser(receiver, type + "|" + sender + "|" + content);
            } else if ("CALL_REJECT".equalsIgnoreCase(type) || "CALL_END".equalsIgnoreCase(type)) {
                touchUser(sender);
                clearPendingCall(sender);
                clearPendingCall(receiver);
                sendMessageToUser(receiver, type + "|" + sender + "|" + content);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
 
    @OnClose
    public void onClose(Session session, @PathParam("username") String encodedUsername) {
        String username = decodeUsername(encodedUsername);
        touchUser(username);
        Set<Session> userSessions = clients.get(username);
        if (userSessions != null) {
            userSessions.remove(session);
            if (userSessions.isEmpty()) {
                clients.remove(username);
                System.out.println("User Offline: " + username);
                
                LiveManager.endStream(username);
                for (LiveManager.LiveStreamInfo info : LiveManager.getActiveStreams()) {
                    LiveManager.removeViewer(info.getStreamerUsername(), username);
                    sendMessageToUser(info.getStreamerUsername(), "LIVE_VIEWER_COUNT|" + info.getStreamerUsername() + "|" + info.getViewers().size());
                }
                
                broadcastOnlineUsers();

            }
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable, @PathParam("username") String encodedUsername) {
        String username = decodeUsername(encodedUsername);
        touchUser(username);
        System.err.println("WebSocket Error for " + username + ": " + throwable.getMessage());
    }
 
    private String decodeUsername(String encoded) {
        try {
            return URLDecoder.decode(encoded, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return encoded;
        }
    }

    public static void sendNotification(String username, String message) {
        Set<Session> userSessions = clients.get(username);
        if (userSessions != null) {
            for (Session s : userSessions) {
                if (s.isOpen()) {
                    try {
                        s.getBasicRemote().sendText("NOTIF|" + message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    public static void sendToUser(String username, String message) {
        Set<Session> userSessions = clients.get(username);
        if (userSessions != null) {
            for (Session s : userSessions) {
                if (s.isOpen()) {
                    try { s.getBasicRemote().sendText(message); } catch (IOException e) { logger.warn("WebSocket send failed: {}", e.getMessage()); }
                }
            }
        }
    }

    private void sendMessageToUser(String username, String message) {
        Set<Session> userSessions = clients.get(username);
        if (userSessions != null) {
            for (Session s : userSessions) {
                if (s.isOpen()) {
                    try {
                        s.getBasicRemote().sendText(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    private void broadcastToLiveStream(String streamer, String message) {
        LiveManager.LiveStreamInfo stream = LiveManager.getStream(streamer);
        if (stream != null) {
            sendMessageToUser(streamer, message);
            for (String viewer : stream.getViewers()) {
                sendMessageToUser(viewer, message);
            }
        }
    }

    private void broadcastOnlineUsers() {
        long now = System.currentTimeMillis();
        java.util.Set<String> onlineUserNames = java.util.concurrent.ConcurrentHashMap.newKeySet();

        for (String u : clients.keySet()) {
            if (u != null && !u.trim().isEmpty()) {
                onlineUserNames.add(u.trim());
            }
        }
        for (java.util.Map.Entry<String, Long> entry : lastActiveMap.entrySet()) {
            if (now - entry.getValue() <= 30 * 60 * 1000L) {
                onlineUserNames.add(entry.getKey());
            }
        }

        StringBuilder sb = new StringBuilder("ONLINE_USERS|");
        int count = 0;
        for (String user : onlineUserNames) {
            if (count > 0) {
                sb.append(",");
            }
            sb.append(user);
            count++;
        }
        String listMsg = sb.toString();
        for (String user : clients.keySet()) {
            sendMessageToUser(user, listMsg);
        }
    }
}
