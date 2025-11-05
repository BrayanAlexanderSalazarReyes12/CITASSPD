/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.CrearBarcaza;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author Brayan Salazar
 */
public class CrearBarcazaServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Crear sesión para mensajes
            HttpSession session = request.getSession();
            
            // Obtener parámetros del formulario
            String CLIENTE = request.getParameter("CLIENTE");
            String NIT_CLIENTE = request.getParameter("NIT_CLIENTE");
            String BARCAZA = request.getParameter("BARCAZA");
            String ARMADOR = request.getParameter("ARMADOR");
            float ESLORA = Float.parseFloat(request.getParameter("ESLORA"));
            float MANGA = Float.parseFloat(request.getParameter("MANGA"));
            float CALADO = Float.parseFloat(request.getParameter("CALADO"));
            String BANDERA = request.getParameter("BANDERA");
            String CERTIFICACIONMATRICULA = request.getParameter("CERTIFICACIONMATRICULA");
            String POLIZA = request.getParameter("POLIZA");
            String RESOLUCIONDESERVICIOS = request.getParameter("RESOLUCIONDESERVICIOS");
            String ROSOLUCIONCOMOPUNTOEXPORTACION = request.getParameter("ROSOLUCIONCOMOPUNTOEXPORTACION");
            
            Date NACIONALARQUEO = java.sql.Date.valueOf(request.getParameter("NACIONALARQUEO"));
            Date DOTACIONMINIMADESEGURIDAD = java.sql.Date.valueOf(request.getParameter("DOTACIONMINIMADESEGURIDAD"));
            Date NACIONALDEFRANCORBO = java.sql.Date.valueOf(request.getParameter("NACIONALDEFRANCORBO"));
            Date NACIONALSEGURIDAD = java.sql.Date.valueOf(request.getParameter("NACIONALSEGURIDAD"));
            Date INVENTARIOELEMENTOYEQUIPOS = java.sql.Date.valueOf(request.getParameter("INVENTARIOELEMENTOYEQUIPOS"));
            Date TRANSPORTEHIDEOCARBUROS = java.sql.Date.valueOf(request.getParameter("TRANSPORTEHIDEOCARBUROS"));
            Date CONTAMINACIONHIDEOCARBUROS = java.sql.Date.valueOf(request.getParameter("CONTAMINACIONHIDEOCARBUROS"));
            
            Barcaza.inicializarDesdeContexto(request.getServletContext());
            
            Barcaza barcaza = new Barcaza();
            
            barcaza.IngresoBarcaza(CLIENTE, NIT_CLIENTE, BARCAZA, ARMADOR, ESLORA, MANGA, CALADO, BANDERA, CERTIFICACIONMATRICULA, POLIZA, RESOLUCIONDESERVICIOS, ROSOLUCIONCOMOPUNTOEXPORTACION, NACIONALARQUEO, DOTACIONMINIMADESEGURIDAD, NACIONALDEFRANCORBO, NACIONALSEGURIDAD, INVENTARIOELEMENTOYEQUIPOS, TRANSPORTEHIDEOCARBUROS, CONTAMINACIONHIDEOCARBUROS);
            
            response.sendRedirect(request.getContextPath() + "/JSP/CrearBarcaza.jsp");
        } catch (SQLException ex) {
            Logger.getLogger(CrearBarcazaServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
