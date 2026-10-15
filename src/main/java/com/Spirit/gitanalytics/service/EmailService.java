package com.Spirit.gitanalytics.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Random;

/**
 * EmailService - Mô phỏng gửi email.
 * Trong production sẽ dùng JavaMailSender + SMTP Gmail.
 * Hiện tại chỉ ghi log ra console + trả về OTP để hiển thị demo.
 */
public class EmailService {

    private static final Logger log = LoggerFactory.getLogger(EmailService.class);
    private static final Random RNG = new Random();

    /** Sinh mã OTP 6 số. */
    public String generateOtp() {
        return String.format("%06d", RNG.nextInt(1_000_000));
    }

    /**
     * Gửi OTP tới target (email hoặc phone).
     * Mô phỏng: ghi log + trả về mã để controller hiển thị.
     * Production: dùng JavaMailSender.send(...)
     */
    public String sendOtp(String target, String purpose) {
        String code = generateOtp();
        log.info("[EMAIL] To={} | Purpose={} | Code={}", target, purpose, code);
        System.out.println(">>> [EmailService] OTP sent -> " + target + " | " + purpose + " | code=" + code);
        return code;
    }

    /** Gửi thông báo deadline. */
    public void sendDeadlineReminder(String email, String assignmentTitle, String dueDate) {
        log.info("[EMAIL-DEADLINE] To={} | Assignment={} | Due={}", email, assignmentTitle, dueDate);
        System.out.println(">>> [EmailService] Deadline reminder -> " + email
                + " | " + assignmentTitle + " | due " + dueDate);
    }

    /** Gửi thông báo đã chấm điểm. */
    public void sendGradeNotice(String email, String assignmentTitle, double score) {
        log.info("[EMAIL-GRADE] To={} | Assignment={} | Score={}", email, assignmentTitle, score);
        System.out.println(">>> [EmailService] Grade notice -> " + email
                + " | " + assignmentTitle + " | score=" + score);
    }
}
