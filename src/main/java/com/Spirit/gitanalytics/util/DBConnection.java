package com.Spirit.gitanalytics.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection - Singleton-ish utility để mở connection tới SQL Server.
 * Đọc config từ system properties hoặc env (mặc định localhost).
 *
 * Lưu ý: dùng jTDS hoặc mssql-jdbc tùy môi trường.
 */
public class DBConnection {

    // Mặc định dùng SQL Server authentication với spirit_user.
    // Đây là cách portable nhất - hoạt động cả khi SQL chỉ bật named pipe hoặc TCP dynamic.
    private static final boolean DEFAULT_USE_TRUSTED = false;
    private static final String DEFAULT_HOST     = "localhost";
    private static final int    DEFAULT_PORT     = 1433;
    private static final String DEFAULT_DB       = "Spirit_GitAnalytics";
    private static final String DEFAULT_USER     = "spirit_user";
    private static final String DEFAULT_PASSWORD = "Spirit@2024!";

    private static boolean useTrusted = parseBool(getOrDefault("SPIRIT_DB_TRUSTED", String.valueOf(DEFAULT_USE_TRUSTED)));
    private static String host     = getOrDefault("SPIRIT_DB_HOST", DEFAULT_HOST);
    private static int    port     = Integer.parseInt(getOrDefault("SPIRIT_DB_PORT", String.valueOf(DEFAULT_PORT)));
    private static String dbName   = getOrDefault("SPIRIT_DB_NAME", DEFAULT_DB);
    private static String user     = getOrDefault("SPIRIT_DB_USER", DEFAULT_USER);
    private static String password = getOrDefault("SPIRIT_DB_PASS", DEFAULT_PASSWORD);

    private static String getOrDefault(String key, String fallback) {
        String v = System.getProperty(key);
        if (v == null) v = System.getenv(key);
        return v != null ? v : fallback;
    }

    private static boolean parseBool(String s) {
        if (s == null) return false;
        return s.equalsIgnoreCase("true") || s.equals("1") || s.equalsIgnoreCase("yes");
    }

    /**
     * Tạo connection mới tới SQL Server qua TCP port 1433 với SQL authentication.
     * Cú pháp JDBC URL:
     *   jdbc:sqlserver://localhost:1433;databaseName=Spirit_GitAnalytics;encrypt=false;trustServerCertificate=true;
     */
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // Load driver - mssql-jdbc
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

        StringBuilder url = new StringBuilder();
        url.append("jdbc:sqlserver://").append(host).append(":").append(port).append(";");
        url.append("databaseName=").append(dbName).append(";");
        url.append("encrypt=false;trustServerCertificate=true;");
        url.append("loginTimeout=10;");

        if (useTrusted) {
            // Thêm integrated security nếu dùng trusted connection
            url.append("integratedSecurity=true;");
            return DriverManager.getConnection(url.toString());
        } else {
            return DriverManager.getConnection(url.toString(), user, password);
        }
    }

    /**
     * Đóng an toàn (null-safe).
     */
    public static void close(AutoCloseable... closeables) {
        if (closeables == null) return;
        for (AutoCloseable c : closeables) {
            if (c != null) {
                try { c.close(); } catch (Exception ignored) {}
            }
        }
    }

    // Getters cho config
    public static String getHost() { return host; }
    public static String getDbName() { return dbName; }
}
