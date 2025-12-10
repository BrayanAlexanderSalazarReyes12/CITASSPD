/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Planilla;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class DescargarPlanillaCreacionCita extends HttpServlet {

    private static final String NOMBRE_ARCHIVO = "PLANILLA CITAS.xlsx";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        descargarArchivo(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        descargarArchivo(request, response);
    }

    private void descargarArchivo(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Ruta REAL dentro del servidor
        String ruta = getServletContext().getRealPath("/PlanillaCreacionCita/" + NOMBRE_ARCHIVO);

        File archivo = new File(ruta);

        if (!archivo.exists()) {
            response.setContentType("text/plain");
            response.getWriter().println("ERROR: No se encontró el archivo en: " + ruta);
            return;
        }

        // Configurar la respuesta para descarga
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + NOMBRE_ARCHIVO + "\"");
        response.setContentLength((int) archivo.length());

        // Enviar archivo byte a byte
        FileInputStream fis = new FileInputStream(archivo);
        OutputStream os = response.getOutputStream();

        byte[] buffer = new byte[4096];
        int bytesRead;

        while ((bytesRead = fis.read(buffer)) != -1) {
            os.write(buffer, 0, bytesRead);
        }

        fis.close();
        os.flush();
        os.close();
    }

    @Override
    public String getServletInfo() {
        return "Servlet para descargar la planilla de creación de citas";
    }

}
