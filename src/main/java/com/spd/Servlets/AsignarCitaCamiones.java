/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.spd.API.FormularioPost;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author braya
 */
public class AsignarCitaCamiones extends HttpServlet {

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
                // Parámetros desde URL
                String vehiculosJsonEncoded = request.getParameter("vehiculos");
                String fecha = request.getParameter("fecha");         // Ej: "2025-06-24T08:46:00-05:00"
                String registro = request.getParameter("registro");   // Ej: "CTA000000000001"
                String fmm = request.getParameter("fmm");

                // Decodificar el JSON
                String vehiculosJson = URLDecoder.decode(vehiculosJsonEncoded, StandardCharsets.UTF_8.name());

                // Parsear JSON a lista de mapas
                Gson gson = new Gson();
                Type listType = new TypeToken<List<Map<String, String>>>() {}.getType();
                List<Map<String, String>> vehiculos = gson.fromJson(vehiculosJson, listType);

                // Construir lista de objetos completos
                List<Map<String, String>> listaFinal = new ArrayList<>();

                for (Map<String, String> vehiculo : vehiculos) {
                    Map<String, String> data = new HashMap<>();
                    data.put("codigo", registro);
                    data.put("estado", "Asignado");
                    data.put("cedula", vehiculo.get("cedula"));
                    data.put("fe_aprobacion", fecha);
                    data.put("nom_conductor", vehiculo.get("nombre"));
                    data.put("placa", vehiculo.get("placa"));
                    data.put("nmform_zf", fmm);
                    listaFinal.add(data);
                }

                // Convertir lista a JSON array
                String json = gson.toJson(listaFinal);
                
                // Enviar a API
                FormularioPost fp = new FormularioPost();
                String apiUrl = "http://www.siza.com.co/spdcitas-1.0/api/citas/aprobacion";

                try {
                    
                    String apiResponse = fp.ActualizarCitacamionesbarcaza(apiUrl, json);
                    System.out.println("Respuesta API: " + apiResponse);

                    response.sendRedirect(request.getContextPath() + "/JSP/Listados_Citas.jsp");
                    
                    /* Responder al navegador
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");

                    PrintWriter out = response.getWriter();
                    out.print(apiResponse);
                    out.flush();
                    */
                } catch (IOException e) {
                    System.err.println("Error al llamar API: " + e.getMessage());

                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");

                    PrintWriter out = response.getWriter();
                    Map<String, String> error = new HashMap<>();
                    error.put("error", e.getMessage());
                    out.print(gson.toJson(error));
                    out.flush();
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
