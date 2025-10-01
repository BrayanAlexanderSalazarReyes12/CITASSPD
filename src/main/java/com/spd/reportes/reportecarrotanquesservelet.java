/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.reportes;

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
public class reportecarrotanquesservelet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fechainicial = request.getParameter("fechainicial");
        String fechafinal = request.getParameter("fechafinal");

        if (fechainicial == null || fechafinal == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Debe enviar las fechas inicial y final.");
            return;
        }

        // Inicializa las variables de conexión desde el contexto
        ReporteCarrotanques.inicializarDesdeContexto(getServletContext());

        ReporteCarrotanques reporte = new ReporteCarrotanques();
        File archivoGenerado;

        try {
            // Este método debe devolver el archivo generado
            archivoGenerado = reporte.reporte(fechainicial, fechafinal); // <-- Aquí hay cambio

            if (!archivoGenerado.exists()) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "El archivo no fue generado.");
                return;
            }

            // Configura headers para forzar descarga
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + archivoGenerado.getName() + "\"");

            // Envía el archivo al navegador
            try (FileInputStream fis = new FileInputStream(archivoGenerado);
                 OutputStream os = response.getOutputStream()) {

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
            }

            // Opcional: eliminar archivo temporal
            archivoGenerado.delete();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generando el reporte.");
        }
    }

}
