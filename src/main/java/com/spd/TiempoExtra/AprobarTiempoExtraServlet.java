/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.TiempoExtra;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class AprobarTiempoExtraServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String nitEmpresa = request.getParameter("nitEmpresa");
        String usulogin = request.getParameter("usulogin");

        TiempoExtraDAO dao = new TiempoExtraDAO();
        try {
            dao.aprobacionTextrea(usulogin, nitEmpresa);
            // Redirigir a una página de confirmación o recargar la misma
            response.sendRedirect("JSP/ListadoTiempoExtra.jsp?msg=aprobado");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?msg=" + e.getMessage());
        }
    }

}
