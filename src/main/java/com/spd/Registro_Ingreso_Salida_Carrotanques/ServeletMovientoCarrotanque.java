/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Registro_Ingreso_Salida_Carrotanques;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
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
public class ServeletMovientoCarrotanque extends HttpServlet {

   
    private static final Logger log = Logger.getLogger(ServeletMovientoCarrotanque.class.getName());

    @Override
    public void init() throws ServletException {
        // Se inicializan las variables de conexión solo una vez al iniciar el servlet
        MovimientoCarrotanque.inicializarDesdeContexto(getServletContext());
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion"); // puede ser "ingreso" o "salida"
        String codCita = request.getParameter("codCita");
        String placa = request.getParameter("placa");
        String empresa = request.getParameter("empresa");
        String estado = request.getParameter("estado");

        MovimientoCarrotanque movimiento = new MovimientoCarrotanque();

        try {
            if ("ingreso".equalsIgnoreCase(accion)) {
                movimiento.IngresoCarrotanque(codCita, placa, empresa, estado);
                //response.getWriter().println("✅ Ingreso registrado correctamente");
            } else if ("salida".equalsIgnoreCase(accion)) {
                movimiento.SalidaCarrotanque(codCita, placa, empresa, estado);
                response.getWriter().println("✅ Salida registrada correctamente");
            } else {
                response.getWriter().println("⚠️ Acción no reconocida: " + accion);
            }
        } catch (SQLException e) {
            log.log(Level.SEVERE, "❌ Error SQL: {0}", e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error en la base de datos");
        } catch (Exception e) {
            log.log(Level.SEVERE, "❌ Error general: {0}", e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error general en el servidor");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para registrar ingreso y salida de carrotanques";
    }
}
