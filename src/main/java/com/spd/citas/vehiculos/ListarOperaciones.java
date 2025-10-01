/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.citas.vehiculos;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
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
public class ListarOperaciones extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        CitasPorEmpresa dao = new CitasPorEmpresa();
        try {
            dao.inicializarDesdeContexto(getServletContext());
            List<CitaVehiculo> citas = dao.obtenerCitasPorEmpresa();
            request.setAttribute("listaCitas", citas);
            request.getRequestDispatcher("/JSP/citasPorEmpresa.jsp").forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Error al consultar las citas", e);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ListarOperaciones.class.getName()).log(Level.SEVERE, null, ex);
        }
    }


}
