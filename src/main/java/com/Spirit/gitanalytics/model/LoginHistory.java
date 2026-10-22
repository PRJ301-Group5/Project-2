package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * LoginHistory - Ghi lại mỗi lần đăng nhập (thành công hoặc thất bại).
 *
 * Map tới bảng dbo.LoginHistory.
 *
 * Lưu ý: user_id có thể NULL khi username không tồn tại trong hệ thống
 * (đăng nhập thất bại) - khi đó username vẫn được lưu để phục vụ audit.
 */
public class LoginHistory {
    private int loginId;
    private Integer userId;         // null nếu username không tồn tại
    private String username;
    private Timestamp loginAt;
    private String ipAddress;
    private String userAgent;
    private String loginStatus;     // SUCCESS / FAILED
    private String failureReason;

    public LoginHistory() {}

    public int getLoginId() { return loginId; }
    public void setLoginId(int loginId) { this.loginId = loginId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public Timestamp getLoginAt() { return loginAt; }
    public void setLoginAt(Timestamp loginAt) { this.loginAt = loginAt; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }

    public String getLoginStatus() { return loginStatus; }
    public void setLoginStatus(String loginStatus) { this.loginStatus = loginStatus; }

    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

    public boolean isSuccess() { return "SUCCESS".equals(loginStatus); }

    /** Rút gọn user agent cho hiển thị: "Chrome 120 / Windows 10". */
    public String getBrowserLabel() {
        if (userAgent == null || userAgent.isEmpty()) return "Unknown";
        String ua = userAgent;
        String browser = "Unknown";
        if (ua.contains("Edg/"))      browser = "Edge";
        else if (ua.contains("OPR/")) browser = "Opera";
        else if (ua.contains("Chrome/")) browser = "Chrome";
        else if (ua.contains("Firefox/")) browser = "Firefox";
        else if (ua.contains("Safari/"))  browser = "Safari";

        String os = "Unknown";
        if (ua.contains("Windows NT 10"))     os = "Windows 10/11";
        else if (ua.contains("Windows"))      os = "Windows";
        else if (ua.contains("Mac OS X"))     os = "macOS";
        else if (ua.contains("Android"))      os = "Android";
        else if (ua.contains("iPhone") || ua.contains("iPad")) os = "iOS";
        else if (ua.contains("Linux"))        os = "Linux";

        return browser + " / " + os;
    }

    /** Định dạng IP gọn gàng (IPv6 rút gọn). */
    public String getIpLabel() {
        if (ipAddress == null || ipAddress.isEmpty()) return "-";
        if (ipAddress.contains(":") && ipAddress.length() > 20) {
            return ipAddress.substring(0, 17) + "...";
        }
        return ipAddress;
    }
}
