/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import com.spd.API.Usuario_Insert;
import com.spd.CrearUsuarioJson.ActualizarUsuarioClass;
import com.spd.CrearUsuarioJson.ActualizarUsuarioCompleto;
import com.spd.CrearUsuarioJson.UsuarioLogin;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author braya
 */
public class ActualizarUsuarioServlet extends HttpServlet {

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
        String usuario = request.getParameter("Usuario");
        String contrasena = request.getParameter("Contrasena");
        String nitCliente = request.getParameter("NitCliente");
        String correo = request.getParameter("Email");
        String codcia_user = request.getParameter("Codigo");
        String ROL = request.getParameter("Rol");
        String ESTADO = request.getParameter("Estado");
        
        //variables finales
        int RolFinal = 0;
        int EstadoFinal = 0;
        
        if("Administrador".equals(ROL)){
            RolFinal = 1;
        }else if("Usuario".equals(ROL)){
            RolFinal = 2;
        }else{
            RolFinal = 2;
        }
        
        if("Activo".equals(ESTADO)){
            EstadoFinal = 0;
        }else{
            EstadoFinal = 1;
        }
        
        
        //variables de session
        
        HttpSession session = request.getSession();
        
        String usuarioactual = (String) session.getAttribute("Usuario");
        String contrasenaactual = (String) session.getAttribute("Contrasena");
        
        UsuarioLogin usuarioLogin = new UsuarioLogin(usuarioactual, contrasenaactual);
        ActualizarUsuarioClass usuarioClass = new ActualizarUsuarioClass(usuario, contrasena, nitCliente, codcia_user, correo, RolFinal, EstadoFinal);
        
        ActualizarUsuarioCompleto usuarioCompleto = new ActualizarUsuarioCompleto(usuarioLogin, usuarioClass);
        
        //Convertir el Objeto a JSON
        Gson gson = new Gson();
        String json = gson.toJson(usuarioCompleto);
        
        //Configurar la respuesta como JSON
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        //antiguo usuario
        String usuarioantiguo = (String) session.getAttribute("UsuarioAntiguo");
        
        
        String url = "http://www.siza.com.co/spdcitas-1.0/api/citas/usuario";
        
        Usuario_Insert usuario_Insert = new Usuario_Insert();
        String Respuesta = usuario_Insert.Actualizar(url,usuarioantiguo,json);
        
        System.out.println("Respuesta del servidor: " + Respuesta);    
        
        
        if("Usuario Actualizado Correctamente".equals(Respuesta)){
            System.out.println("Solicitud exitosa.");
            session.setAttribute("Error", "USUARIO ACTUALIZADO CON EXITO");
            session.setAttribute("Activo", true);
            response.sendRedirect("JSP/ListadoUsuarios.jsp");
        }
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
