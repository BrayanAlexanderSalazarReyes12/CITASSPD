/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/ServletListener.java to edit this template
 */
package com.spd.CancelarCitaAut;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

/**
 * Web application lifecycle listener.
 *
 * @author Brayan Salazar
 */
public class SchedulerListenerCanceCita implements ServletContextListener {

    private Timer timer;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Se crea el Timer en modo daemon (no bloquea la app al cerrar)
        timer = new Timer(true);

        // ---- TAREA DIARIA A LAS 06:00 AM ----
        TimerTask tarea6am = new TimerTask() {
            @Override
            public void run() {
                System.out.println("▶️ Ejecutando tarea automática - 06:00 AM");
                ejecutarCancelacion(sce);
            }
        };

        // ---- TAREA DIARIA A LA 01:00 AM ----
        TimerTask tarea1am = new TimerTask() {
            @Override
            public void run() {
                System.out.println("▶️ Ejecutando tarea automática - 01:00 AM");
                ejecutarCancelacion2(sce);
            }
        };

        // Obtener las próximas ejecuciones
        Date proxima6am = getProximaEjecucion(6, 0);
        Date proxima1am = getProximaEjecucion(1, 0);

        // Repetir cada 24 horas (un día)
        long unDia = 24 * 60 * 60 * 1000;

        // Programar ambas tareas
        timer.scheduleAtFixedRate(tarea6am, proxima6am, unDia);
        timer.scheduleAtFixedRate(tarea1am, proxima1am, unDia);

        System.out.println("✅ Scheduler iniciado: tareas diarias a las 06:00 AM y 01:00 AM");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            System.out.println("🛑 Scheduler detenido.");
        }
    }

    /**
     * Calcula la siguiente ejecución para la hora y minuto indicados.
     * Si la hora ya pasó hoy, programa para mañana.
     */
    private Date getProximaEjecucion(int hora, int minuto) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, hora);
        cal.set(Calendar.MINUTE, minuto);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);

        Date ejecucion = cal.getTime();
        // Si la hora ya pasó hoy, se agenda para el día siguiente
        if (ejecucion.before(new Date())) {
            cal.add(Calendar.DAY_OF_MONTH, 1);
            ejecucion = cal.getTime();
        }

        return ejecucion;
    }

    /**
     * Ejecuta la lógica de cancelación automática.
     */
    private void ejecutarCancelacion(ServletContextEvent sce) {
        CitasCacelacionAuto job = new CitasCacelacionAuto();
        job.inicializarDesdeContexto(sce.getServletContext());
        try {
            job.cancelarCitaauto();
        } catch (SQLException | IOException ex) {
            Logger.getLogger(SchedulerListenerCanceCita.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    private void ejecutarCancelacion2(ServletContextEvent sce) {
        CitasCacelacionAuto job = new CitasCacelacionAuto();
        job.inicializarDesdeContexto(sce.getServletContext());
        try {
            job.cancelarCitaauto2();
        } catch (SQLException | IOException ex) {
            Logger.getLogger(SchedulerListenerCanceCita.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
