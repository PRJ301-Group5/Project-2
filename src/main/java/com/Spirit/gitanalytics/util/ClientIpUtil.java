package com.Spirit.gitanalytics.util;

import javax.servlet.http.HttpServletRequest;

/**
 * ClientIpUtil - Lấy IP thật của client, xử lý trường hợp đi qua proxy.
 */
public final class ClientIpUtil {

    private ClientIpUtil() {}

    /**
     * Lấy IP client.
     * Ưu tiên X-Forwarded-For (khi đi qua reverse proxy như nginx / IIS ARR),
     * sau đó tới X-Real-IP, cuối cùng là remoteAddr của servlet container.
     */
    public static String getClientIp(HttpServletRequest req) {
        if (req == null) return null;

        String forwarded = req.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isEmpty() && !"unknown".equalsIgnoreCase(forwarded)) {
            // X-Forwarded-For có thể là "client, proxy1, proxy2" -> lấy phần đầu
            int comma = forwarded.indexOf(',');
            String ip = (comma > 0 ? forwarded.substring(0, comma) : forwarded).trim();
            if (!ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                return truncate(ip);
            }
        }

        String realIp = req.getHeader("X-Real-IP");
        if (realIp != null && !realIp.isEmpty() && !"unknown".equalsIgnoreCase(realIp)) {
            return truncate(realIp.trim());
        }

        String remote = req.getRemoteAddr();
        return (remote == null || remote.isEmpty()) ? null : truncate(remote);
    }

    /** User agent rút gọn, giới hạn 500 ký tự cho khớp cột DB. */
    public static String getUserAgent(HttpServletRequest req) {
        if (req == null) return null;
        String ua = req.getHeader("User-Agent");
        if (ua == null) return null;
        ua = ua.replaceAll("[\\r\\n\\t]", " ").trim();
        return ua.length() > 500 ? ua.substring(0, 500) : ua;
    }

    /** IP chuẩn IPv6 có thể dài 39 ký tự, cột VARCHAR(45) đủ chứa. */
    private static String truncate(String ip) {
        return ip.length() > 45 ? ip.substring(0, 45) : ip;
    }
}
