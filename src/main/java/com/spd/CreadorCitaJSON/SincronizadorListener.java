/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/ServletListener.java to edit this template
 */
package com.spd.CreadorCitaJSON;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/**
 * Web application lifecycle listener.
 *
 * @author Brayan Salazar
 */
@WebListener()
public class SincronizadorListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // iniciar tarea cada minuto
        scheduler.scheduleAtFixedRate(
                () -> SincronizadorCitas.ejecutar(sce.getServletContext()),
                0,
                1,
                TimeUnit.MINUTES
        );

        System.out.println("[SINCRONIZADOR] Iniciado y ejecutándose cada 1 minuto");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) scheduler.shutdownNow();
    }
}
