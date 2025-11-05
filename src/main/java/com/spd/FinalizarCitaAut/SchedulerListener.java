/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/ServletListener.java to edit this template
 */
package com.spd.FinalizarCitaAut;

import java.io.IOException;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Web application lifecycle listener.
 *
 * @author Brayan Salazar
 */
public class SchedulerListener implements ServletContextListener {
    
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("🕒 Iniciando SchedulerListener...");

        // Creamos un pool con 2 hilos para ejecutar las tareas
        scheduler = Executors.newScheduledThreadPool(2);

        // Programamos las tareas
        programarTareaDiaria(sce, 23, 0); // 11:00 PM
        programarTareaDiaria(sce, 8, 0);  // 8:00 AM
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("🛑 Deteniendo SchedulerListener...");
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
    }

    /**
     * Programa una tarea que se ejecuta diariamente a una hora específica.
     */
    private void programarTareaDiaria(ServletContextEvent sce, int hora, int minuto) {
        long delayInicial = calcularDelay(hora, minuto);
        long periodo = TimeUnit.DAYS.toSeconds(1); // cada 24 horas

        scheduler.scheduleAtFixedRate(() -> ejecutarJob(sce, hora, minuto),
                delayInicial, periodo, TimeUnit.SECONDS);

        System.out.printf("🗓️ Tarea programada para las %02d:%02d (inicia en %d segundos)%n",
                hora, minuto, delayInicial);
    }

    /**
     * Ejecuta el proceso automático.
     */
    private void ejecutarJob(ServletContextEvent sce, int hora, int minuto) {
        System.out.printf("▶️ Ejecutando tarea automática - %02d:%02d%n", hora, minuto);
        CitasAutomaticas job = new CitasAutomaticas();
        job.inicializarDesdeContexto(sce.getServletContext());
        try {
            job.ejecutarAutomatico();
        } catch (SQLException | IOException ex) {
            Logger.getLogger(SchedulerListener.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception ex) {
            // Captura general para evitar que el scheduler se detenga
            Logger.getLogger(SchedulerListener.class.getName())
                    .log(Level.SEVERE, "Error inesperado en tarea automática", ex);
        }
    }

    /**
     * Calcula el delay (en segundos) hasta la próxima ejecución.
     */
    private long calcularDelay(int hora, int minuto) {
        LocalDateTime ahora = LocalDateTime.now();
        LocalDateTime proximaEjecucion = ahora.withHour(hora).withMinute(minuto).withSecond(0).withNano(0);

        if (proximaEjecucion.isBefore(ahora)) {
            proximaEjecucion = proximaEjecucion.plusDays(1);
        }

        Duration duracion = Duration.between(ahora, proximaEjecucion);
        return duracion.getSeconds();
    }
}
