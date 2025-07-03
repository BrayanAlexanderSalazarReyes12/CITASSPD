/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpSession;
/**
 *
 * @author braya
 */
public class CerrarSeccion extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Cookie[] cookies = request.getCookies();
        response.setContentType("text/html");
        HttpSession session = request.getSession();
        session.setAttribute("clienteForm", null);
        session.setAttribute("operacionesForm", null);
        session.setAttribute("fechaForm", null);
        session.setAttribute("verificacionForm", null);
        session.setAttribute("nitForm", null);
        session.setAttribute("cedulaForm", null);
        session.setAttribute("placaForm", null);
        session.setAttribute("manifiestoForm", null);
        session.setAttribute("cedulasExtras", null);
        session.setAttribute("placasExtras", null);
        session.setAttribute("manifiestosExtras", null);
        session.setAttribute("nombreconductor", null);
        session.setAttribute("nombreconductorExtras", null);
        session.setAttribute("CantidadProducto", null);
        session.setAttribute("FacturaComercial", null);
        session.setAttribute("Observaciones", null);
        session.setAttribute("PrecioArticulo", null);
        session.setAttribute("Remolque", null);
        session.setAttribute("remolqueExtras", null);
        
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if(cookie.getName().equals("SeccionIniciada")){
                    System.out.println(cookie.getValue());
                    cookie.setMaxAge(0); // Expirar inmediatamente
                    cookie.setPath("/CITASSPD"); // <- ¡esto es clave!
                    response.addCookie(cookie); // Agregar la cookie modificada a la respuesta
                }
                if(cookie.getName().equals("DATA")){
                    cookie.setMaxAge(0);
                    cookie.setPath("/CITASSPD"); // <- ¡esto es clave!
                    response.addCookie(cookie);
                }
            }
        }
        
        response.sendRedirect(request.getContextPath());
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
