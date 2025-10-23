/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.TiempoExtra;


import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class RegistrarSolicitudTiempoExtra extends HttpServlet {
    
    private static final Logger log = Logger.getLogger(RegistrarSolicitudTiempoExtra.class.getName());

    @Override
    public void init() throws ServletException {
        // Se inicializan las variables de conexión solo una vez al iniciar el servlet
        TiempoExtraDAO.inicializarDesdeContexto(getServletContext());
    }
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ParseException {
        
        
        String empresa = request.getParameter("empresa");
        String fechaSolicitudStr = request.getParameter("fechaSolicitud");
        String fechaServicioStr = request.getParameter("fechaServicio");
        java.sql.Date fechasolicitud = null;
        java.sql.Date fechaservicio = null;

        if (fechaSolicitudStr != null && !fechaSolicitudStr.isEmpty()) {
            SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
            java.util.Date parsedDate = sdf.parse(fechaSolicitudStr); // puede lanzar ParseException
            fechasolicitud = new java.sql.Date(parsedDate.getTime());
        }


        if (fechaServicioStr != null && !fechaServicioStr.isEmpty()) {
            fechaservicio = java.sql.Date.valueOf(fechaServicioStr);
        }

        StringBuilder tipooperacion = new StringBuilder();

        String tiempoExtraordinario = request.getParameter("tiempoExtraordinario");
        String aprobacionDoc = request.getParameter("aprobacionDoc");

        if (tiempoExtraordinario != null) {
            tipooperacion.append(tiempoExtraordinario);
        }

        if (aprobacionDoc != null) {
            tipooperacion.append(aprobacionDoc);
        }

        String resultado = tipooperacion.toString();

        String operacion = request.getParameter("operacion");
        String observacion = request.getParameter("observacion");

        TiempoExtraDAO tedao = new TiempoExtraDAO();

        try {
            tedao.REGISTROTIEMPOEXTRA(
                empresa,
                fechasolicitud,
                fechaservicio,
                resultado,
                operacion,
                observacion,
                "Pendiente"
            );
        } catch (SQLException e) {
            log.log(Level.SEVERE, "❌ Error SQL: {0}", e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error en la base de datos");
        } catch (Exception e) {
            log.log(Level.SEVERE, "❌ Error general: {0}", e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error general en el servidor");
        }
        response.sendRedirect(request.getContextPath() + "/JSP/SolicitudTiempoExtra.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (ParseException ex) {
            Logger.getLogger(RegistrarSolicitudTiempoExtra.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (ParseException ex) {
            Logger.getLogger(RegistrarSolicitudTiempoExtra.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet para registrar Tiempo extra";
    }

}
