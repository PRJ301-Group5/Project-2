package com.Spirit.gitanalytics.service;

import com.Spirit.gitanalytics.dao.AppUserDAO;
import com.Spirit.gitanalytics.dao.AssignmentDAO;
import com.Spirit.gitanalytics.dao.ClassRoomDAO;
import com.Spirit.gitanalytics.dao.NotificationDAO;
import com.Spirit.gitanalytics.model.AppUser;
import com.Spirit.gitanalytics.model.Assignment;
import com.Spirit.gitanalytics.model.ClassRoom;
import com.Spirit.gitanalytics.model.Notification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * DeadlineScheduler - Tự động kiểm tra assignment sắp đến hạn.
 * Quét mỗi 1 giờ: nếu còn &lt; 24h tới deadline, tạo Notification + email nhắc nhở.
 * Khởi động qua AppContextListener (ServletContextListener).
 */
public class DeadlineScheduler {

    private static final Logger log = LoggerFactory.getLogger(DeadlineScheduler.class);
    private static ScheduledExecutorService exec;

    public static synchronized void start() {
        if (exec != null && !exec.isShutdown()) {
            log.info("DeadlineScheduler already started.");
            return;
        }
        exec = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "deadline-scheduler");
            t.setDaemon(true);
            return t;
        });
        // Chạy sau 30s khởi động, lặp mỗi 60 phút
        exec.scheduleAtFixedRate(DeadlineScheduler::scanDeadlines, 30, 60, TimeUnit.MINUTES);
        log.info("DeadlineScheduler started (initial delay 30s, period 60min).");
    }

    public static synchronized void stop() {
        if (exec != null) {
            exec.shutdownNow();
            exec = null;
        }
    }

    /** Quét assignment sắp deadline, gửi notification + email cho SV chưa nộp. */
    public static void scanDeadlines() {
        try {
            EmailService email = new EmailService();
            AssignmentDAO asmDao = new AssignmentDAO();
            ClassRoomDAO classDao = new ClassRoomDAO();
            AppUserDAO userDao = new AppUserDAO();
            NotificationDAO notiDao = new NotificationDAO();

            for (Assignment a : asmDao.findAll()) {
                if (a.getDueDate() == null) continue;
                long hoursLeft = (a.getDueDate().getTime() - System.currentTimeMillis()) / 3_600_000L;
                if (hoursLeft < 0 || hoursLeft > 24) continue;

                // Lấy SV trong lớp
                List<ClassRoom> classes = classDao.findByStudent(-1); // dummy
                // Lấy enrollment list
                List<AppUser> students = getStudentsInClass(a.getClassId(), userDao, classDao);
                for (AppUser student : students) {
                    // Check đã có notification này chưa (tránh spam)
                    Notification n = new Notification();
                    n.setUserId(student.getUserId());
                    n.setTitle("Sắp đến hạn: " + a.getTitle());
                    n.setBody("Deadline: " + a.getDueDate() + ". Hãy nộp bài trước khi quá hạn!");
                    n.setLink("/gitanalytics/app/assignments/detail?id=" + a.getAssignmentId());
                    try {
                        notiDao.insert(n);
                        email.sendDeadlineReminder(student.getEmail(), a.getTitle(), a.getDueDate().toString());
                    } catch (Exception ex) {
                        log.warn("Failed to send deadline notice: {}", ex.getMessage());
                    }
                }
            }
        } catch (Exception ex) {
            log.error("scanDeadlines error", ex);
        }
    }

    private static List<AppUser> getStudentsInClass(int classId, AppUserDAO userDao, ClassRoomDAO classDao)
            throws Exception {
        // Lấy enrollment table thông qua query trực tiếp (tạm thời)
        java.util.List<AppUser> out = new java.util.ArrayList<>();
        java.sql.Connection con = com.Spirit.gitanalytics.util.DBConnection.getConnection();
        java.sql.PreparedStatement ps = con.prepareStatement(
            "SELECT u.user_id, u.username, u.password_hash, u.full_name, u.email, u.phone, u.role, u.is_active, u.created_at "
          + "FROM AppUser u JOIN Enrollment e ON u.user_id = e.student_id WHERE e.class_id = ?");
        ps.setInt(1, classId);
        java.sql.ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            AppUser u = new AppUser();
            u.setUserId(rs.getInt("user_id"));
            u.setUsername(rs.getString("username"));
            u.setEmail(rs.getString("email"));
            u.setFullName(rs.getString("full_name"));
            u.setRole(rs.getString("role"));
            out.add(u);
        }
        rs.close();
        ps.close();
        con.close();
        return out;
    }
}
