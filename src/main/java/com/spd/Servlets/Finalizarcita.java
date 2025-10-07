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
import com.spd.informacionCita.CitaFInal;
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
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
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
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    private String getCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) return c.getValue();
        }
        return null;
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        FormularioPost fp = new FormularioPost();
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content);

        String RIEN = "1";
        String TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
        String SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
        String USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
        String CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
        String USLOGIN = getCookie(request, "USUARIO");

        response.setContentType("application/json;charset=UTF-8");

        try {
            String datosJson = request.getParameter("DATOS");
            Type listType = new TypeToken<List<CitaFInal>>() {}.getType();
            List<CitaFInal> citas = gson.fromJson(datosJson, listType);

            // 🔹 Procesar cada cita de manera secuencial (una por una)
            for (CitaFInal cita : citas) {
                procesarCita(cita, fp, TERMINALPORTUARIANIT, SISTEMAENTURNAMIENTOID,
                        USUARIOMINTRASPOR, CONTRAMINTRASPOR, RIEN, USLOGIN, request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try {
                response.sendRedirect(request.getContextPath() + "/JSP/Listados_Citas.jsp");
            } catch (Exception ignored) {}
        }
    }

    private void procesarCita(CitaFInal cita,
                              FormularioPost fp,
                              String TERMINALPORTUARIANIT,
                              String SISTEMAENTURNAMIENTOID,
                              String USUARIOMINTRASPOR,
                              String CONTRAMINTRASPOR,
                              String RIEN,
                              String USLOGIN,
                              HttpServletRequest request,
                              HttpServletResponse response) {

        String ministerioUrl = "https://rndcws2.mintransporte.gov.co/rest/RIEN";
        String apiLocalUrl = "http://www.siza.com.co/spdcitas-1.0/api/citas/finalizacion";

        try {
            // 🔹 Construir JSON Ministerio
            String jsonMinisterio = gson.toJson(buildJsonMinisterio(cita,
                    TERMINALPORTUARIANIT, SISTEMAENTURNAMIENTOID,
                    USUARIOMINTRASPOR, CONTRAMINTRASPOR, RIEN));

            // 🔹 Construir JSON Local
            String jsonLocal = gson.toJson(buildJsonFinalizacion(cita,USLOGIN));

            System.out.println("➡️ Enviando cita placa: " + cita.getVehiculoNumPlaca());

            // 🔹 Enviar con reintentos
            String respMinisterio = enviarConRetry(fp, ministerioUrl, jsonMinisterio, 3);

            if (respMinisterio == null) {
                System.out.println("⚠️ Ministerio no respondió, guardando solo en API local.");
                registrarLocal(fp, apiLocalUrl, jsonLocal, cita, request, response);
            } else {
                JSONObject jsonResp = new JSONObject(respMinisterio);
                if (jsonResp.has("ErrorCode") && jsonResp.getInt("ErrorCode") != 0) {
                    System.out.println("❌ Error Ministerio: " + jsonResp.optString("ErrorText"));
                    registrarLocal(fp, apiLocalUrl, jsonLocal, cita, request, response);
                } else {
                    System.out.println("✅ Ministerio OK para placa: " + cita.getVehiculoNumPlaca());
                    registrarLocal(fp, apiLocalUrl, jsonLocal, cita, request, response);
                }
            }

            // 🔹 Delay aleatorio entre envíos (500 – 1500 ms)
            Thread.sleep(500 + new Random().nextInt(1000));

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Map<String, Object> buildJsonMinisterio(CitaFInal cita,
                                                    String TERMINALPORTUARIANIT,
                                                    String SISTEMAENTURNAMIENTOID,
                                                    String USUARIOMINTRASPOR,
                                                    String CONTRAMINTRASPOR,
                                                    String RIEN) {
        Map<String, Object> tiemposProceso = new LinkedHashMap<>();
        tiemposProceso.put("entradaTerminal", cita.getFechaentrada());
        tiemposProceso.put("pesajeEntrada", cita.getPesoentrada());
        tiemposProceso.put("basculaEntrada", "B1374");
        tiemposProceso.put("salidaTerminal", cita.getFechasalida());
        tiemposProceso.put("pesajeSalida", cita.getPesosalida());
        tiemposProceso.put("basculaSalida", "B1373");

        Map<String, Object> turnoAsignado = new LinkedHashMap<>();
        turnoAsignado.put("fecha", cita.getFechaOfertaSolicitud());
        turnoAsignado.put("tiemposProceso", tiemposProceso);

        Map<String, Object> sistemaEnturnamiento = new LinkedHashMap<>();
        sistemaEnturnamiento.put("terminalPortuariaNit", TERMINALPORTUARIANIT);
        sistemaEnturnamiento.put("sistemaEnturnamientoId", SISTEMAENTURNAMIENTOID);

        Map<String, Object> variables = new LinkedHashMap<>();
        variables.put("sistemaEnturnamiento", sistemaEnturnamiento);
        variables.put("tipoOperacionId", cita.getTipoOperacionId());
        variables.put("empresaTransportadoraNit", cita.getEmpresaTransportadoraNit());
        variables.put("vehiculoNumPlaca", cita.getVehiculoNumPlaca());
        variables.put("conductorCedulaCiudadania", cita.getConductorCedulaCiudadania());
        variables.put("fechaOfertaSolicitud", cita.getFechaOfertaSolicitud());
        variables.put("numManifiestoCarga", cita.getNumManifiestoCarga());
        variables.put("turnoAsignado", turnoAsignado);

        Map<String, Object> acceso = new LinkedHashMap<>();
        acceso.put("usuario", USUARIOMINTRASPOR);
        acceso.put("clave", CONTRAMINTRASPOR);
        acceso.put("rien", RIEN);

        Map<String, Object> finalJson = new LinkedHashMap<>();
        finalJson.put("acceso", acceso);
        finalJson.put("variables", variables);

        return finalJson;
    }

    private List<Map<String, Object>> buildJsonFinalizacion(CitaFInal cita, String USLOGIN) {
        List<Map<String, Object>> listaFinal = new ArrayList<>();
        Map<String, Object> data = new HashMap<>();
        data.put("codcita", cita.Gettregistro());
        data.put("placa", cita.getVehiculoNumPlaca());
        data.put("manifiesto", cita.getNumManifiestoCarga());
        data.put("usuMovimiento",USLOGIN);
        listaFinal.add(data);
        return listaFinal;
    }

    private void registrarLocal(FormularioPost fp, String apiUrl, String jsonLocal,
                                CitaFInal cita, HttpServletRequest request, HttpServletResponse response) {
        try {
            String res = fp.FinalizarCita(apiUrl, jsonLocal);
            System.out.println(res);
            String registro = cita.Gettregistro();
            Map<String, String> vehiculosMap = new HashMap<>();
            vehiculosMap.put("rol", "Transportador");

            response.sendRedirect(request.getContextPath() +
                    "/JSP/CitaCamionesPorFinalizar.jsp?registro=" + registro +
                    "&rol=" + vehiculosMap.get("rol"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Envia con reintentos exponenciales para evitar baneo
     */
    private String enviarConRetry(FormularioPost fp, String url, String json, int maxIntentos) {
        int intentos = 0;
        while (intentos < maxIntentos) {
            try {
                String resp = fp.Post(url, json);
                if (resp != null && !resp.isEmpty()) {
                    return resp;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            intentos++;
            try {
                // Espera exponencial: 2s, 4s, 8s...
                long delay = (long) Math.pow(2, intentos) * 1000;
                System.out.println("⏳ Reintentando en " + delay + " ms...");
                Thread.sleep(delay);
            } catch (InterruptedException ignored) {}
        }
        return null;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Finaliza una cita y reporta a RNDC y API interna (con throttling y retries)";
    }    

}
