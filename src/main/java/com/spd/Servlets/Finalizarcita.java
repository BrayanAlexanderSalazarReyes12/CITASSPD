/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;
import com.spd.API.FormularioPost;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class Finalizarcita extends HttpServlet {
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
        String fecha = request.getParameter("fecha");
        String pesoentrada = request.getParameter("pesoentrada");
        String fechasal = request.getParameter("fechasal");
        String psalida = request.getParameter("psalida");
        String fechainside = request.getParameter("fechacitainside");
        String registro = request.getParameter("registro");
        String formulario = request.getParameter("formulario");
        System.out.println(fechainside);
        FormularioPost fp = new FormularioPost();
        //variables de entorno
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content); // Parsea el JSON
        //System.out.println(jsonEnv);
        String RIEN = "1";
        String TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
        String SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
        String USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
        String CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
        
        response.setContentType("application/json;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            // Obtener parámetro JSON URL-encoded
            String vehiculosJsonEncoded = request.getParameter("vehiculos");

            if (vehiculosJsonEncoded == null || vehiculosJsonEncoded.trim().isEmpty()) {
                out.println("{\"error\": \"El parámetro 'vehiculos' no puede ser nulo o vacío\"}");
                return;
            }

            // Decodificar la cadena URL-encoded para obtener JSON válido
            String vehiculosJsonDecoded = URLDecoder.decode(vehiculosJsonEncoded, "UTF-8");

            Gson gson = new Gson();

            // Tipo para lista de mapas (array JSON)
            Type type = new TypeToken<List<Map<String, Object>>>() {}.getType();
            List<Map<String, Object>> vehiculosList;

            try {
                vehiculosList = gson.fromJson(vehiculosJsonDecoded, type);
            } catch (JsonSyntaxException e) {
                out.println("{\"error\": \"Formato de JSON inválido en el parámetro 'vehiculos'\"}");
                return;
            }

            if (vehiculosList.isEmpty()) {
                out.println("{\"error\": \"La lista de vehículos está vacía\"}");
                return;
            }

            // Tomamos el primer objeto para variables (ajusta si necesitas procesar todos)
            Map<String, Object> vehiculosMap = vehiculosList.get(0);

            // Construcción de objetos para la respuesta JSON
            Map<String, Object> acceso = new LinkedHashMap<>();
            acceso.put("usuario", USUARIOMINTRASPOR);
            acceso.put("clave", CONTRAMINTRASPOR);
            acceso.put("rien", RIEN);

            Map<String, Object> sistemaEnturnamiento = new LinkedHashMap<>();
            sistemaEnturnamiento.put("terminalPortuariaNit", TERMINALPORTUARIANIT);
            sistemaEnturnamiento.put("sistemaEnturnamientoId", SISTEMAENTURNAMIENTOID);

            Map<String, Object> tiemposProceso = new LinkedHashMap<>();
            tiemposProceso.put("entradaTerminal", fecha);
            tiemposProceso.put("pesajeEntrada", pesoentrada);
            tiemposProceso.put("salidaTerminal", fechasal);
            tiemposProceso.put("pesajeSalida", psalida);
            
            Map<String, Object> turnoAsignado = new LinkedHashMap<>();
            turnoAsignado.put("fecha", vehiculosMap.get("fechaOfertaSolicitud"));
            turnoAsignado.put("tiemposProceso", tiemposProceso);
            
            Map<String, Object> variables = new LinkedHashMap<>();
            variables.put("sistemaEnturnamiento", sistemaEnturnamiento);
            variables.put("tipoOperacionId", vehiculosMap.get("tipoOperacionId"));
            variables.put("empresaTransportadoraNit", vehiculosMap.get("empresaTransportadoraNit"));
            variables.put("vehiculoNumPlaca", vehiculosMap.get("vehiculoNumPlaca"));
            variables.put("conductorCedulaCiudadania", vehiculosMap.get("conductorCedulaCiudadania"));
            variables.put("fechaOfertaSolicitud", fechainside);
            variables.put("numManifiestoCarga", vehiculosMap.get("numManifiestoCarga"));
            variables.put("turnoAsignado", turnoAsignado);
            
            Map<String, Object> finalJson = new LinkedHashMap<>();
            finalJson.put("acceso", acceso);
            finalJson.put("variables", variables);

            // Construir lista de objetos completos
            List<Map<String, Object>> listaFinal = new ArrayList<>();
            System.out.println(fecha);
            Map<String, Object> data = new HashMap<>();
            data.put("codcita", registro);
            data.put("placa", vehiculosMap.get("vehiculoNumPlaca"));
            data.put("manifiesto", vehiculosMap.get("numManifiestoCarga"));
            listaFinal.add(data);
            
            
            Gson gsonPretty = new GsonBuilder().setPrettyPrinting().create();
            String jsonResponse = gsonPretty.toJson(finalJson);
            String jsonResponse1 = gsonPretty.toJson(listaFinal);
            
            String url = "https://rndcws2.mintransporte.gov.co/rest/RIEN";
            
            String apiUrl1 = "http://www.siza.com.co/spdcitas-1.0/api/citas/finalizacion";
            
            
            String response1 = fp.Post(url, jsonResponse);
            
            if(response1 != null && !response1.isEmpty()){
                JSONObject jsonresponse = new JSONObject(response1);
                
                if(jsonresponse.has("ErrorCode")){
                    int errorCode = jsonresponse.getInt("ErrorCode");
                    
                    if (errorCode != 0) {
                        
                        // Manejo del error
                        System.out.println("❌ Error detectado: " + jsonresponse.optString("ErrorText", "Sin detalle"));
                        //aqui tiene que estar los valores que le entrar al modal
                        
                        //variable de seccion
                        HttpSession session = request.getSession();
                        session.setAttribute("Error", "Error: " + jsonresponse.optString("ErrorText", "Sin detalle"));
                        session.setAttribute("Activo", true);
                        
                        String response2 = fp.Post(apiUrl1, jsonResponse1);
                        
                        response.sendRedirect(request.getContextPath() + "/JSP/Listados_Citas.jsp");// Esto recarga la página actual 
                        
                        return;
                        
                    }else{
                        System.out.println("✅ Todo correcto.");
                    }
                }else {
                    System.out.println("⚠️ Respuesta vacía.");
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Error: en este momento no se puede establecer conexión con el servidor. Por favor, intente más tarde.");
                    response.sendRedirect(request.getRequestURI()); // También recarga si está vacía
                    return;
                }
            }
            
            //out.println(jsonResponse);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try {
                response.getWriter().println("{\"error\": \"Ocurrió un error procesando la solicitud\"}");
            } catch (Exception ignored) {}
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
