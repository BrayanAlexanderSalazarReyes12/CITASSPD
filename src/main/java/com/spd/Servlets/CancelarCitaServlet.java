/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONObject;

/**
 *
 * @author braya
 */
public class CancelarCitaServlet extends HttpServlet {
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
        
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content); // Parsea el JSON
        //System.out.println(jsonEnv);
        String RIEN = jsonEnv.optString("RIEN");
        String TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
        String SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
        String USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
        String CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
        
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {

            // Parámetros de entrada
            String codigo = request.getParameter("codigo");
            String causalid = request.getParameter("causal");
            String empresaNit = request.getParameter("empresaTransportadoraNit");
            String placa = request.getParameter("vehiculoNumPlaca");
            String cedula = request.getParameter("conductorCedulaCiudadania");
            String fechaIso = request.getParameter("fechaOfertaSolicitud"); // Ej: "2025-07-01T13:56:00-05:00"
            String fechaFormateada = null;
            if (fechaIso != null && !fechaIso.isEmpty()) {
                // Parsear fecha con zona horaria
                OffsetDateTime offsetDateTime = OffsetDateTime.parse(fechaIso);

                // Convertir a LocalDateTime (sin zona horaria)
                LocalDateTime fechaSinZona = offsetDateTime.toLocalDateTime();

                // Formatear como "yyyy-MM-dd'T'HH:mm:ss"
                fechaFormateada = fechaSinZona.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);

                System.out.println("Fecha formateada: " + fechaFormateada);
                // Resultado: "2025-07-01T13:56:00"
            } else {
                System.out.println("Parámetro 'fechaOfertaSolicitud' no proporcionado.");
            }
            String operacion = request.getParameter("tipooperacion");
            // Valores fijos o simulados (ajústalos según tu sistema)
            String usuario = USUARIOMINTRASPOR;
            String clave = CONTRAMINTRASPOR;
            String rien = "3";
            String terminalPortuariaNit = TERMINALPORTUARIANIT;
            String sistemaEnturnamientoId = SISTEMAENTURNAMIENTOID;
            String tipoOperacionId = operacion;
            String quien = obtenerResponsablePorCodigo(causalid);
            String descripcion = obtenerDescripcionPorCodigo(causalid);

             // Construcción del JSON con LinkedHashMap para preservar el orden
            Map<String, Object> acceso = new LinkedHashMap<>();
            acceso.put("usuario", usuario);
            acceso.put("clave", clave);
            acceso.put("rien", rien);

            Map<String, Object> sistemaEnturnamiento = new LinkedHashMap<>();
            sistemaEnturnamiento.put("terminalPortuariaNit", terminalPortuariaNit);
            sistemaEnturnamiento.put("sistemaEnturnamientoId", sistemaEnturnamientoId);

            Map<String, Object> variables = new LinkedHashMap<>();
            variables.put("sistemaEnturnamiento", sistemaEnturnamiento);
            variables.put("tipoOperacionId", tipoOperacionId);
            variables.put("empresaTransportadoraNit", empresaNit);
            variables.put("vehiculoNumPlaca", placa);
            variables.put("conductorCedulaCiudadania", cedula);
            variables.put("fechaOfertaSolicitud", fechaFormateada);
            variables.put("quien", quien);
            variables.put("causalid", causalid);
            variables.put("descripcion", descripcion);

            Map<String, Object> finalJson = new LinkedHashMap<>();
            finalJson.put("acceso", acceso);
            finalJson.put("variables", variables);

            // Convertir a JSON con Gson
            Gson gson = new GsonBuilder().setPrettyPrinting().create();
            String json = gson.toJson(finalJson);

            // Imprimir o enviar el JSON
            out.println(json);


            // Aquí podrías enviarlo a otro servicio con HttpClient o guardar en BD

        }
    }
    
    private String obtenerDescripcionPorCodigo(String codigo) {
        switch (codigo) {
            case "11": return "Finalización del Buque";
            case "12": return "Obstáculo por Movilidad en última Milla";
            case "13": return "Problemas técnicos en la plataforma";
            case "14": return "Problemas Operativos en la terminal";
            case "15": return "Confirmación tardía de la cita";
            case "16": return "Problemas de atraque de la Motonave";
            case "29": return "Otros (Puerto)";
            case "31": return "Daño mecánico del vehículo";
            case "32": return "Enfermedad del Conductor";
            case "33": return "Inocuidad del vehículo o del producto";
            case "34": return "Error en la digitación de la información";
            case "49": return "Otros (Transportador)";
            case "51": return "Problemas de Nacionalización o Liberación";
            case "69": return "Otros (Generador)";
            case "71": return "Problemas de Infraestructura en la Vía";
            case "72": return "Problemas ocasionados por la comunidad";
            case "89": return "Otros (Estado)";
            case "91": return "Situación climática - Lluvia";
            case "99": return "Otros (Indeterminado)";
            default: return "Causal desconocida";
        }
    }
    
    private String obtenerResponsablePorCodigo(String codigo) {
        switch (codigo) {
            case "11":
            case "12":
            case "13":
            case "14":
            case "15":
            case "16":
            case "29":
                return "PUERTO";

            case "31":
            case "32":
            case "33":
            case "34":
            case "49":
                return "TRANSPORTADOR";

            case "51":
            case "69":
                return "GENERADOR";

            case "71":
            case "72":
            case "89":
                return "ESTADO";

            case "91":
            case "99":
                return "INDETERMINADO";

            default:
                return "RESPONSABLE DESCONOCIDO";
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
