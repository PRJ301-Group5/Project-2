package com.Spirit.gitanalytics.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * SecurityUtil - Đơn giản hóa việc hash/verify password cho lecturer login.
 * Dùng jBCrypt (tham chiếu trong pom.xml).
 *
 * NOTE: cho demo; production nên dùng Spring Security + Argon2.
 */
public class SecurityUtil {

    public static String hashPassword(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt(10));
    }

    public static boolean verifyPassword(String plain, String hashed) {
        if (hashed == null || hashed.isEmpty()) return false;
        try {
            return BCrypt.checkpw(plain, hashed);
        } catch (Exception ex) {
            return false;
        }
    }
}
