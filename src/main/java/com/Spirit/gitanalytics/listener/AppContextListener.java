package com.Spirit.gitanalytics.listener;

import com.Spirit.gitanalytics.service.DeadlineScheduler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * AppContextListener - Khởi động / dừng các background service khi web app start/stop.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    private static final Logger log = LoggerFactory.getLogger(AppContextListener.class);

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        log.info(">>> Spirit app starting...");
        DeadlineScheduler.start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        log.info(">>> Spirit app stopping...");
        DeadlineScheduler.stop();
    }
}
