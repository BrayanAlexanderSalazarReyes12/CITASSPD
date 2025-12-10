/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import com.spd.informacionCita.CitaInfo;
import com.spd.informacionCita.InformacionPesajeFinalizacionCIta;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class FinalizarcitaInfo extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String placa = request.getParameter("placa");
            String fecha = request.getParameter("fecha");
            String soloFecha = fecha.split("T")[0]; // "2025-08-23"
            String cedula = request.getParameter("cedula");
            String codcita = request.getParameter("codcita");

            if (placa == null || fecha == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Faltan parámetros obligatorios.");
                return;
            }

            // Validación de fecha segura
            Date fecha_fin;
            try {
                fecha_fin = Date.valueOf(soloFecha);
            } catch (IllegalArgumentException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Formato de fecha inválido (esperado yyyy-MM-dd)." + fecha);
                return;
            }

            // Inicializar contexto antes de consultar
            InformacionPesajeFinalizacionCIta.inicializarDesdeContexto(getServletContext());

            List<CitaInfo> info = InformacionPesajeFinalizacionCIta.InformacionPesosFinalizacionCita(placa, cedula, fecha_fin, codcita);

            Gson gson = new Gson();
            String json = gson.toJson(info);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8"); // importante
            response.getWriter().write(json);

        } catch (SQLException ex) {
            Logger.getLogger(FinalizarcitaInfo.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error en base de datos");
        } catch (Exception ex) {
            Logger.getLogger(FinalizarcitaInfo.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error inesperado");
        }

    }

}
