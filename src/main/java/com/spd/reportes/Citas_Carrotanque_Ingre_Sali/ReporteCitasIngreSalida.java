/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.reportes.Citas_Carrotanque_Ingre_Sali;

import com.spd.reportes.CitasActuales.ReporteClass;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class ReporteCitasIngreSalida extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1️⃣ Obtener la ruta real del reporte dentro del WAR
            String rutaReporte = getServletContext().getRealPath("/Reportes/Reportes_Carrotanques_Ent_Salida.jrxml");

            // 2️⃣ Llamar al generador (versión que exporta Excel)
            ReporteCarrotanquesIngreSalClass.inicializarDesdeContexto(getServletContext());
            ReporteCarrotanquesIngreSalClass reporte = new ReporteCarrotanquesIngreSalClass();
            File archivo = reporte.generarReporteExcel(rutaReporte); // 👈 usa el método para Excel

            // 3️⃣ Enviar XLSX al navegador
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"Reporte_Carrotanques_Con_Hora_Ingreso_Y_Salida.xlsx\"");

            try (FileInputStream in = new FileInputStream(archivo);
                 OutputStream out = response.getOutputStream()) {

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }

            archivo.delete(); // limpia el archivo temporal
        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<h3>Error generando reporte: " + e.getMessage() + "</h3>");
            }
        }
    }


    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

}
