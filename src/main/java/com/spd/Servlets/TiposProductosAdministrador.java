/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import com.spd.API.TipoPorductosGet;
import com.spd.Productos.Producto;
import java.util.ArrayList;
import javax.servlet.RequestDispatcher;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpSession;
/**
 *
 * @author braya
 */
public class TiposProductosAdministrador extends HttpServlet {
    private JSONObject jsonEnv;
    
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
        String ordenOperacionParam = request.getParameter("ordenOperacion");
        String operacionParam = request.getParameter("operacion");
        Cookie[] cookies = request.getCookies();

        String DATA = "";
        
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("DATA".equals(cookie.getName())) {
                    DATA = cookie.getValue();
                    System.out.println("Valor de la cookie DATA: " + DATA);
                    // Aquí puedes hacer lo que necesites con el valor
                    break; // Salimos del bucle porque ya encontramos la cookie
                }
            }
        } else {
            System.out.println("No hay cookies en la solicitud.");
        }
        
        String url = "http://www.siza.com.co/spdcitas-1.0/api/citas/productos/" + DATA;
        
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content); // Parsea el JSON
        
        HttpSession session = request.getSession();
        
        String operacion = (String) session.getAttribute("operacionSelec");
        
        System.out.println(operacion);
        
        Cookie cookie2 = new Cookie("ORDEN_OPERACION", ordenOperacionParam);
        cookie2.setMaxAge(3600);
        cookie2.setPath("/CITASSPD");
        response.addCookie(cookie2);
        
        String Token = jsonEnv.optString("TOKEN");
        
        try {
            TipoPorductosGet api = new TipoPorductosGet();
            
            List<Producto> productos = api.LeerProductosEmpresa(url, Token);
            request.setAttribute("productos", productos);
        } catch (IOException e) {
            e.printStackTrace();
            request.setAttribute("productos", new ArrayList<Producto>());
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("/JSP/Formulario_Administrador.jsp?operacionselec=" + operacion + "&operacion=" + operacionParam);
        dispatcher.forward(request, response);
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
