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
        
        timer = new Timer(true);
        
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                System.out.println("▶️ Ejecutando tarea automática - 06:00 AM");
                CitasCacelacionAuto job = new CitasCacelacionAuto();
                job.inicializarDesdeContexto(sce.getServletContext());
                try {
                    job.cancelarCitaauto();
                } catch (SQLException ex) {
                    Logger.getLogger(SchedulerListenerCanceCita.class.getName()).log(Level.SEVERE, null, ex);
                } catch (IOException ex) {
                    Logger.getLogger(SchedulerListenerCanceCita.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
        };
        
        Date primeraEjecucion = getProximaEjecucion(6, 0);
        long periodo = 48 * 60 * 60 * 1000;
        
        timer.scheduleAtFixedRate(task, primeraEjecucion, periodo);
        
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if(timer != null){
            timer.cancel();
        }
    }
    
    private Date getProximaEjecucion(int hora, int minuto){
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, hora);
        cal.set(Calendar.MINUTE, minuto);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        
        Date ejecucion = cal.getTime();
        if(ejecucion.before(new Date())){
            cal.add(Calendar.DAY_OF_MONTH, 1);
            ejecucion = cal.getTime();
        }
        return ejecucion;
    }
}
