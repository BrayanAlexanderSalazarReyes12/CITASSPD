/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import com.spd.API.Usuario_Insert;
import com.spd.CreacionUsuarioNit.CreacionUsuarioEmpresaTransportadora;
import com.spd.CrearUsuarioJson.CrearUsuarioClass;
import com.spd.CrearUsuarioJson.CrearUsuarioCompleto;
import com.spd.CrearUsuarioJson.UsuarioLogin;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;

/**
 *
 * @author braya
 */
public class CrearUsuarioServlet extends HttpServlet {

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
        String usuario = request.getParameter("Usuario");
        String contrasena = request.getParameter("Contrasena");
        String nitCliente = request.getParameter("NitCliente");
        String correo = request.getParameter("Email");
        String Rol = request.getParameter("TipoRol");
        //variables de entorno
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content); // Parsea el JSON
        //System.out.println(jsonEnv);
        int CODCIA_USER = jsonEnv.optInt("CODCIA_USER");
        int ROL = jsonEnv.optInt("ROL");
        int ESTADO = jsonEnv.optInt("ESTADO");
        
        //variables de session
        
        HttpSession session = request.getSession();
        
        String usuarioactual = (String) session.getAttribute("Usuario");
        String contrasenaactual = (String) session.getAttribute("Contrasena");
        
        UsuarioLogin usuarioLogin = new UsuarioLogin(usuarioactual, contrasenaactual);
        CrearUsuarioClass usuarioClass = new CrearUsuarioClass(usuario, contrasena, nitCliente, CODCIA_USER, correo, Integer.parseInt(Rol), ESTADO);
        
        CrearUsuarioCompleto usuarioCompleto = new CrearUsuarioCompleto(usuarioLogin, usuarioClass);
        
        
        //Convertir el Objeto a JSON
        Gson gson = new Gson();
        String json = gson.toJson(usuarioCompleto);
        
        //System.out.println(json);
        
        //Configurar la respuesta como JSON
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Usuario_Insert usuario_Insert = new Usuario_Insert();
        
        System.out.println(Rol);
        
        if(Rol.equals("5") || Rol.equals("6") || Rol.equals("7") || Rol.equals("8"))
        {
            try {
                CreacionUsuarioEmpresaTransportadora.inicializarDesdeContexto(getServletContext());
                CreacionUsuarioEmpresaTransportadora.insertarUsuario(usuario, contrasena, nitCliente, "401", correo, Rol, "1");
                session.setAttribute("Error", "USUARIO CREADO CON EXITO");
                session.setAttribute("Activo", true);
                response.sendRedirect("JSP/CrearUsuario.jsp");
            } catch (SQLException ex) {
                Logger.getLogger(CrearUsuarioServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
        }else{
            String url="http://www.siza.com.co/spdcitas-1.0/api/citas/usuario";

            try {
                String response1 = usuario_Insert.Insert(url, json);
                System.out.println("Respuesta del servidor: " + response1);


                if(!"".equals(response1)){
                    System.out.println("Solicitud exitosa.");
                    session.setAttribute("Error", "USUARIO CREADO CON EXITO");
                    session.setAttribute("Activo", true);
                    response.sendRedirect("JSP/CrearUsuario.jsp");
                }


            } catch (IOException e) {
                System.out.println("Error: " + e);
            }
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
