/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.spd.API.LoginPost;
import com.spd.Model.Inicio_Seccion;
import com.google.gson.Gson;
import com.spd.API.Usuario_Insert;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;

import com.google.gson.reflect.TypeToken;
import com.spd.Model.Usuario;

import java.lang.reflect.Type;
import java.net.URLEncoder;
import java.util.List;
import org.json.JSONArray;

/**
 *
 * @author braya
 */
public class Iniciar_Seccion_Servlet extends HttpServlet {

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
       // Obtener los datos del formulario
String usuario = request.getParameter("Usuario");
String pass = request.getParameter("Contrasena");

// Limpiar sesión
HttpSession session = request.getSession();
session.setAttribute("hayOperacionValida", false);
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

// Guardar en sesión
session.setAttribute("Usuario", usuario);
session.setAttribute("Contrasena", pass);

// Crear JSON del objeto
Inicio_Seccion inicio = new Inicio_Seccion(usuario, pass);
Gson gson = new Gson();
String json = gson.toJson(inicio);

// Configurar respuesta
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String url = "http://www.siza.com.co/spdcitas-1.0/api/citas/login";

try {
    LoginPost login = new LoginPost();
    String response1 = login.Post(url, json);
    System.out.println("Respuesta del servidor login: " + response1);

    JSONObject jsonResponse = new JSONObject(response1);
    int status = jsonResponse.has("codigo") ? jsonResponse.getInt("codigo") : jsonResponse.optInt("error", -1);
    long tiempo = jsonResponse.optLong("time", System.currentTimeMillis());
    int rol = jsonResponse.has("rol") ? jsonResponse.getInt("rol") : jsonResponse.optInt("error", -1);
    String Data = jsonResponse.optString("data", "");
    String safeNit = URLEncoder.encode(Data, "UTF-8");

    System.out.println("Código de estado: " + Data);

    switch (status) {
        case 200:
            // Guardar en sesión
            session.setAttribute("Data", Data);

            // Cookies
            Cookie cookie2 = new Cookie("USUARIO", usuario);
            cookie2.setMaxAge(3600);
            cookie2.setPath("/CITASSPD");
            response.addCookie(cookie2);

            Cookie cookie1 = new Cookie("DATA",safeNit);
            cookie1.setMaxAge(3600);
            cookie1.setPath("/CITASSPD");
            response.addCookie(cookie1);

            Cookie cookie = new Cookie("SeccionIniciada", Long.toString(tiempo));
            cookie.setMaxAge(3600);
            cookie.setPath("/CITASSPD");
            response.addCookie(cookie);

            // Leer archivo de configuración
            String path = getServletContext().getRealPath("/WEB-INF/json.env");
            String content = new String(Files.readAllBytes(Paths.get(path)));
            JSONObject jsonEnv = new JSONObject(content);
            String TOKEN = jsonEnv.optString("TOKEN");

            System.out.println("rol: " + rol);
            
            session.setAttribute("Rol", rol);

            response.sendRedirect("JSP/TipoOperaciones.jsp");
            break;

        case 400:
            System.out.println("Error 400: Solicitud incorrecta.");
            break;
        case 401:
            System.out.println("Error 401: No autorizado.");
            Cookie cookieerror = new Cookie("ErrorConUser", "ErrorConUser");
            cookieerror.setMaxAge(5);
            response.addCookie(cookieerror);
            response.sendRedirect("index.jsp");
            break;
        case 404:
            System.out.println("Error 404: No encontrado.");
            break;
        case 500:
            System.out.println("Error 500: Error del servidor.");
            break;
        default:
            System.out.println("Respuesta inesperada: " + response1);
            break;
    }

} catch (Exception e) {
    System.out.println("Excepción en el servlet: " + e.getMessage());
    e.printStackTrace();
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
