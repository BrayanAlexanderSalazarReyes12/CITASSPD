/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import java.io.*;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import org.json.JSONObject;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.spd.API.FormularioPost;
import com.spd.CItasDB.BarcazaCita;
import com.spd.CItasDB.CitaBascula;
import com.spd.CItasDB.VehiculoDB;
import com.spd.ClasesJsonFormularioMinisterio.Acceso;
import com.spd.ClasesJsonFormularioMinisterio.FormularioCompleto;
import com.spd.ClasesJsonFormularioMinisterio.SistemaEnturnamiento;
import com.spd.ClasesJsonFormularioMinisterio.Variables;
import com.spd.ClasesJsonFormularioMinisterio.Vehiculo;
import com.spd.DAO.Correcion_Fecha;
import com.spd.Model.Cliente;
import com.spd.Model.FormularioCompletoSPDCARROTANQUE;
import com.spd.SendMail.EnviarCorreo;
import com.spd.fallos.DAOFallos;
import com.spd.informacionCita.MaxCITA;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.RequestDispatcher;
import org.json.JSONArray;
import org.json.JSONException;

// IMPORTANTE: ajusta los imports de tus clases de dominio:
/// import com.spd.API.FormularioPost;
/// import com.spd.ClasesJsonFormularioMinisterio.*; // Acceso, SistemaEnturnamiento, Variables, Vehiculo, FormularioCompleto
/// import com.spd.CItasDB.*; // BarcazaCita, CitaBascula, VehiculoDB

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB
    maxFileSize = 1024 * 1024 * 5,        // 5 MB
    maxRequestSize = 1024 * 1024 * 10     // 10 MB
)
public class Formulario_SPD_Servlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // === Config de resiliencia ===
    private static final int MAX_REINTENTOS = 3;
    private static final long BACKOFF_MS_INICIAL = 800; // 0.8s
    private static final int POOL_SIZE_EXTRAS = 5;

    // === Endpoints ===
    private static final String URL_RIEM = "";//https://rndcws2.mintransporte.gov.co/rest/RIEN
    private static final String URL_CITAS = "http://www.siza.com.co/spdcitas-1.0/api/citas/";
    private static final String URL_CITAS_BARC = "http://www.siza.com.co/spdcitas-1.0/api/citas/barcazas/";
    private static final String URL_PRUEBAS = "http://192.168.10.80:26480/spdcitas/api/citas/";
    
    private JSONObject jsonEnv;
    
    private transient ExecutorService extrasPool = Executors.newFixedThreadPool(POOL_SIZE_EXTRAS);

    // 👉 Lista segura para guardar fallas (no interrumpe otros hilos)
    private final List<String> placasFallidas = new CopyOnWriteArrayList<>();
    
    private String nuevaCita = "";

    @Override
    public void init() throws ServletException {
        super.init();
        extrasPool = Executors.newFixedThreadPool(POOL_SIZE_EXTRAS);
        DAOFallos.inicializarDesdeContexto(getServletContext());
    }

    @Override
    public void destroy() {
        if (extrasPool != null) extrasPool.shutdown();
        super.destroy();
    }

    // ===== Utilidades =====

    private boolean isMultipart(HttpServletRequest request) {
        String ct = request.getContentType();
        return ct != null && ct.toLowerCase().startsWith("multipart/");
    }

    private String getCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (name.equals(c.getName())) return c.getValue();
        }
        return null;
    }

    private void setCookie(HttpServletResponse response, String name, String value, int maxAge, String path) {
        Cookie c = new Cookie(name, value);
        c.setMaxAge(maxAge);
        if (path != null) c.setPath(path);
        response.addCookie(c);
    }

    private void setFormSession(HttpSession session,
                                String usuario, String Operaciones, String fecha, String verificacion,
                                String Nitempresa, String Cedula, String placa, String Manifiesto,
                                String[] cedulasExtras, String[] placasExtras, String[] manifiestosExtras,
                                String nombre, String[] nombreconductorExtras,
                                String cantidadproducto, String FacturaComercial, String Observaciones,
                                String PrecioArticulo, String Remolque, String[] remolqueExtras,
                                String PesoProducto, String Barcades, String producto) {
        session.setAttribute("Error", session.getAttribute("Error")); // se mantiene si ya existe
        session.setAttribute("Activo", true);

        session.setAttribute("clienteForm", usuario);
        session.setAttribute("operacionesForm", Operaciones);
        session.setAttribute("fechaForm", fecha);
        session.setAttribute("verificacionForm", verificacion);
        session.setAttribute("nitForm", Nitempresa);
        session.setAttribute("cedulaForm", Cedula);
        session.setAttribute("placaForm", placa);
        session.setAttribute("manifiestoForm", Manifiesto);
        session.setAttribute("cedulasExtras", cedulasExtras);
        session.setAttribute("placasExtras", placasExtras);
        session.setAttribute("manifiestosExtras", manifiestosExtras);
        session.setAttribute("nombreconductor", nombre);
        session.setAttribute("nombreconductorExtras", nombreconductorExtras);
        session.setAttribute("CantidadProducto", cantidadproducto);
        session.setAttribute("FacturaComercial", FacturaComercial);
        session.setAttribute("Observaciones", Observaciones);
        session.setAttribute("PrecioArticulo", PrecioArticulo);
        session.setAttribute("Remolque", Remolque);
        session.setAttribute("remolqueExtras", remolqueExtras);
        session.setAttribute("PesoProducto", PesoProducto);
        session.setAttribute("Barcades", Barcades);
        session.setAttribute("tipoproducto", producto);
    }

    private String postConRetry(FormularioPost fp, String url, String json) {
        long backoff = BACKOFF_MS_INICIAL;
        for (int i = 0; i < MAX_REINTENTOS; i++) {
            try {
                String resp = fp.Post(url, json);
                if (resp != null && !resp.isEmpty()) return resp;
            } catch (Exception ignore) { }
            try { Thread.sleep(backoff); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
            backoff *= 2;
        }
        return null;
    }

    private String formdbConRetry(FormularioPost fp, String url, String json, String usuario) {

        long backoff = BACKOFF_MS_INICIAL;
        DAOFallos daoFallos = new DAOFallos();

        try {
            // ========== FILTRAR JSON (parte original tuya) ==========
            com.google.gson.JsonParser parser = new com.google.gson.JsonParser();
            com.google.gson.JsonObject obj = parser.parse(json).getAsJsonObject();

            if (obj.has("vehiculos")) {
                com.google.gson.JsonArray vehiculos = obj.getAsJsonArray("vehiculos");
                com.google.gson.JsonArray vehiculosFiltrados = new com.google.gson.JsonArray();

                for (com.google.gson.JsonElement v : vehiculos) {
                    com.google.gson.JsonObject vehiculo = v.getAsJsonObject();
                    String placa = vehiculo.get("vehiculoNumPlaca").getAsString();

                    if (!placasFallidas.contains(placa)) {
                        vehiculosFiltrados.add(vehiculo);
                    }
                }
                obj.add("vehiculos", vehiculosFiltrados);
            }

            json = new com.google.gson.Gson().toJson(obj);

        } catch (Exception e) {
            System.out.println("⚠️ Error filtrando JSON: " + e.getMessage());
        }

        // ========== REINTENTOS ==========
        for (int i = 0; i < MAX_REINTENTOS; i++) {
            try {
                String resp = fp.FormDB(url, json);

                if (resp != null && !resp.isEmpty()) {
                    return resp; // ÉXITO
                }

            } catch (Exception e) {
                System.err.println("❌ Intento " + (i + 1) + " fallido: " + e.getMessage());
            }

            // esperar antes del siguiente reintento
            if (i < MAX_REINTENTOS - 1) {
                try {
                    Thread.sleep(backoff);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
                backoff *= 2;
            }
        }

        // ========== SI TODOS LOS INTENTOS FALLAN → GUARDAR LOCAL ==========
        try {
            LocalBackup.save(json, getServletContext(), usuario, nuevaCita);
            System.out.println("📁 JSON guardado localmente para reintento futuro.");
        } catch (IOException ioe) {
            System.err.println("⛔ ERROR: No se pudo guardar el JSON localmente: " + ioe.getMessage());
        }

        return null;
    }



    private String citaBarcazaConRetry(FormularioPost fp, String url, String json) {
        long backoff = BACKOFF_MS_INICIAL;
        for (int i = 0; i < MAX_REINTENTOS; i++) {
            try {
                String resp = fp.CitaBarcaza(url, json);
                if (resp != null && !resp.isEmpty()) return resp;
            } catch (Exception ignore) { }
            try { Thread.sleep(backoff); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
            backoff *= 2;
        }
        return null;
    }

    private void quitarOperacionTerminada(HttpSession session) {
        String operacionTerminada = (String) session.getAttribute("operacionSeleccionada");
        @SuppressWarnings("unchecked")
        List<String> operacionesPermitidas = (List<String>) session.getAttribute("Operacionespermitadas");
        if (operacionesPermitidas != null && operacionTerminada != null) {
            operacionesPermitidas.remove(operacionTerminada);
            session.setAttribute("Operacionespermitadas", operacionesPermitidas);
        }
    }

    private void redirectTiposProductos(HttpServletRequest request, HttpServletResponse response,
                                        String operacion, String mensaje) throws IOException {
        String orden = getCookie(request, "ORDEN_OPERACION");
        String msj = URLEncoder.encode(mensaje == null ? "" : mensaje, "UTF-8");
        response.sendRedirect(request.getContextPath() + "/TiposProductos"
                + "?ordenOperacion=" + (orden == null ? "" : orden)
                + "&operacion=" + (operacion == null ? "" : operacion)
                + "&error=1"
                + "&mensaje=" + msj);
    }

    private String base64Archivo(Part archivoPDF) throws IOException {
        if (archivoPDF == null || archivoPDF.getSize() == 0) return null;
        try (InputStream is = archivoPDF.getInputStream();
             ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {
            byte[] data = new byte[4096];
            int bytesRead;
            while ((bytesRead = is.read(data)) != -1) {
                buffer.write(data, 0, bytesRead);
            }
            return Base64.getEncoder().encodeToString(buffer.toByteArray());
        }
    }

    private String ajustarFechaISO(String fechamini) {
        if (fechamini == null || fechamini.trim().isEmpty() || "null".equalsIgnoreCase(fechamini.trim())) return "";
        try {
            OffsetDateTime fechaUtc = OffsetDateTime.parse(fechamini, DateTimeFormatter.ISO_OFFSET_DATE_TIME);
            return fechaUtc.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME); // conserva Z
        } catch (DateTimeParseException e) {
            System.out.println("Error al parsear fecha: " + e.getMessage());
            return "";
        }
    }

    private void enviarVehiculoExtraAsync(FormularioPost fp, Gson gson, String URL,
                                      String fecha, SistemaEnturnamiento sistemaEnturnamiento,
                                      int identificador, String Nitempresa, Acceso acceso,
                                      String placa, String cedula, String manifiesto, String remolque) {

        extrasPool.submit(() -> {
            try {
                // Construir el objeto JSON del formulario
                Vehiculo vehiculoExtra = new Vehiculo(placa, cedula, fecha, manifiesto, remolque);
                List<Vehiculo> lista = new ArrayList<>();
                lista.add(vehiculoExtra);
                Variables variables = new Variables(sistemaEnturnamiento, identificador, Nitempresa, lista);
                FormularioCompleto formulario = new FormularioCompleto(acceso, variables);
                String json = gson.toJson(formulario);

                // Enviar POST con reintentos
                String resp = postConRetry(fp, URL, json);

                // Caso sin respuesta
                if (resp == null) {
                    System.out.println("❌ Error enviando extra placa=" + placa + " (sin respuesta del servidor)");
                    placasFallidas.add(placa);
                    return;
                }

                // Intentar interpretar la respuesta JSON
                try {
                    org.json.JSONObject jsonResp = new org.json.JSONObject(resp);

                    if (jsonResp.has("ErrorCode")) {
                        int errorCode = jsonResp.optInt("ErrorCode", 0);
                        String errorText = jsonResp.optString("ErrorText", "Error desconocido");
                        System.out.println("❌ Error enviando extra placa=" + placa +
                                           " -> Código: " + errorCode + " | " + errorText);
                        placasFallidas.add(placa);

                    } else if (jsonResp.has("SesionId")) {
                        long sesionId = jsonResp.optLong("SesionId", -1);
                        String ingresoId = jsonResp.optString("IngresoId", "");
                        System.out.println("✅ Extra enviado correctamente. Placa=" + placa +
                                           " | SesionId=" + sesionId + " | IngresoId=" + ingresoId);

                    } else {
                        System.out.println("⚠️ Respuesta desconocida del servidor para placa=" + placa + ": " + resp);
                        placasFallidas.add(placa);
                    }

                } catch (Exception parseEx) {
                    System.out.println("⚠️ Respuesta no es JSON válido para placa=" + placa + ": " + resp);
                    placasFallidas.add(placa);
                }

            } catch (Exception e) {
                System.out.println("❌ Excepción en envío de extra placa=" + placa + " -> " + e.getMessage());
                placasFallidas.add(placa);
            }
        });
    }




    // ====== Flujo principal ======
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");

        // 1) Verifica multipart
        if (!isMultipart(request)) {
            request.getSession().setAttribute("errorMsg", "Debe adjuntar un archivo PDF válido.");
            response.sendRedirect("JSP/OperacionesActivas.jsp");
            return;
        }

        // 2) Datos de usuario/cookies
        String usuario = request.getParameter("Cliente");
        String nombreUsuario = getCookie(request, "DATA");
        String USLOGIN = getCookie(request, "USUARIO");

        // Lista de clientes (ideal mover a repositorio/DB)
        List<Cliente> clientes = Arrays.asList(
            new Cliente("900328914-0", "C I CARIBBEAN BUNKERS S A S"),
            new Cliente("900614423-2", "ATLANTIC MARINE FUELS S A S C I"),
            new Cliente("806005826-3", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
            new Cliente("901312960-3", "C I CONQUERS WORLD TRADE S A S (CWT)"),
            new Cliente("901222050-1", "C I FUELS AND BUNKERS COLOMBIA S A S"),
            new Cliente("802024011-4", "C I INTERNATIONAL FUELS S A S"),
            new Cliente("901123549-8", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
            new Cliente("806005346-1", "OPERACIONES TECNICAS MARINAS S A S"),
            new Cliente("819001667-8", "PETROLEOS DEL MILENIO S A S"),
            new Cliente("900992281-3", "C I PRODEXPORT DE COLOMBIA S A S"),
            new Cliente("890405769-3", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
            new Cliente("901.312.960–3", "C I CONQUERS WORLD TRADE S A S"),
            new Cliente("901826337-0", "CONQUERS ZF")
        );

        String empresaUsuario = null;
        for (Cliente c : clientes) {
            if (c.getNit().equals(nombreUsuario)) {
                empresaUsuario = c.getEmpresa();
                break;
            }
        }

        // 3) Form inputs
        String Operaciones = request.getParameter("Operaciones");
        String OrdenOperacion = request.getParameter("ordenOperacion");

        int identificador = "operacion de cargue".equals(Operaciones) ? 1 : 2;

        String fecha = request.getParameter("fecha") + ":00-05:00";
        String fechamini = request.getParameter("fecha");
        String fechaFormateada1 = Correcion_Fecha.ajustarFechaISO(fechamini);

        String Cedula = request.getParameter("Cedula");
        String placa = request.getParameter("Placa");
        String Manifiesto = request.getParameter("Manifiesto");
        String Nitempresa = request.getParameter("Nitempresa");
        String verificacion = request.getParameter("Verificacion");
        String nombre = request.getParameter("Nombre");
        String cantidadproducto = request.getParameter("CantidadProducto");
        String FacturaComercial = request.getParameter("FacturaComercial");
        String Observaciones = request.getParameter("Observaciones");
        String PrecioArticulo = request.getParameter("PrecioArticulo");
        String Remolque = request.getParameter("Remolque");
        String TipoProducto = request.getParameter("tipoProducto");
        String PesoProducto = request.getParameter("PesoProducto");
        String Barcades = request.getParameter("Barcades");
        String producto = request.getParameter("tipoProducto");

        String[] cedulasExtras = request.getParameterValues("CedulaExtra");
        String[] placasExtras = request.getParameterValues("PlacaExtra");
        String[] manifiestosExtras = request.getParameterValues("ManifiestoExtra");
        String[] nombreconductorExtras = request.getParameterValues("nombreExtra");
        String[] remolqueExtras = request.getParameterValues("RemolqueExtra");

        // 4) Variables de entorno (json.env)
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content);
        String RIEN = jsonEnv.optString("RIEN");
        String TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
        String SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
        String USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
        String CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");

        // 5) Construcción de objetos
        List<Vehiculo> vehiculos = new ArrayList<>();
        List<VehiculoDB> vehiculosDB = new ArrayList<>();

        Vehiculo vehiculoPrincipal = new Vehiculo(placa, Cedula, fechaFormateada1, Manifiesto, Remolque);
        vehiculos.add(vehiculoPrincipal);

        if (cedulasExtras != null && placasExtras != null && manifiestosExtras != null) {
            for (int i = 0; i < cedulasExtras.length; i++) {
                VehiculoDB vdb = new VehiculoDB(placasExtras[i], cedulasExtras[i], nombreconductorExtras[i], fecha, manifiestosExtras[i]);
                vehiculosDB.add(vdb);
            }
        }

        Acceso acceso = new Acceso(USUARIOMINTRASPOR, CONTRAMINTRASPOR, RIEN);
        SistemaEnturnamiento sistemaEnturnamiento = new SistemaEnturnamiento(TERMINALPORTUARIANIT, SISTEMAENTURNAMIENTOID);
        Variables variables = new Variables(sistemaEnturnamiento, identificador, Nitempresa, vehiculos);
        FormularioCompleto formulario = new FormularioCompleto(acceso, variables);

        Part archivoPDF = request.getPart("AdjuntoDeRemision");
        String facturacomerpdf = base64Archivo(archivoPDF);

        FormularioCompletoSPDCARROTANQUE fcspdcarrotanque = new FormularioCompletoSPDCARROTANQUE(
                usuario, Operaciones, fecha, Nitempresa, vehiculos, Manifiesto, TipoProducto, cantidadproducto,
                FacturaComercial, facturacomerpdf, PrecioArticulo, Observaciones
        );

        String nombreBarcaza = getCookie(request, "NOMBRE_DE_BARCAZA");
        String nombreTanque = getCookie(request, "NOMBRE_TANQUE");
        String operacion = getCookie(request, "OPERACION");
        if (nombreBarcaza != null) {
            System.out.println("Nombre barcaza: " + nombreBarcaza + " | operacion: " + operacion + " | tanque: " + nombreTanque);
        } else {
            System.out.println("Cookie NOMBRE_DE_BARCAZA no encontrada.");
        }

        BarcazaCita bc = new BarcazaCita(
                usuario,
                operacion,
                fecha,
                nombreBarcaza,
                producto,
                Double.parseDouble(cantidadproducto),
                FacturaComercial,
                facturacomerpdf,
                Double.parseDouble(PrecioArticulo),
                Observaciones,
                fecha,
                0,
                Barcades
        );
        
        CitaBascula cb;
        if (cedulasExtras != null && placasExtras != null && manifiestosExtras != null) {
            VehiculoDB vdb2 = new VehiculoDB(placa, Cedula, nombre, fecha, Manifiesto);
            vehiculosDB.add(vdb2);
            cb = new CitaBascula(
                usuario, USLOGIN, placa, Cedula, nombre, fecha, Manifiesto, 0, Nitempresa,
                "PROGRAMADA", vehiculos.size(), TipoProducto, Float.parseFloat(cantidadproducto),
                FacturaComercial, Double.parseDouble(PrecioArticulo), facturacomerpdf, Observaciones,
                Operaciones, Remolque, nombreBarcaza, nombreTanque, vehiculosDB
            );
        } else {
            List<VehiculoDB> vehiculosDB1 = new ArrayList<>();
            VehiculoDB vdb1 = new VehiculoDB(placa, Cedula, nombre, fecha, Manifiesto);
            vehiculosDB1.add(vdb1);
            cb = new CitaBascula(
                usuario, USLOGIN, placa, Cedula, nombre, fecha, Manifiesto, 0, Nitempresa,
                "PROGRAMADA", vehiculos.size(), TipoProducto, Float.parseFloat(cantidadproducto),
                FacturaComercial, Double.parseDouble(PrecioArticulo), facturacomerpdf, Observaciones,
                Operaciones, Remolque, nombreBarcaza, nombreTanque, vehiculosDB1
            );
        }

        Gson gson = new Gson();
        String json = gson.toJson(formulario);
        String json1 = gson.toJson(fcspdcarrotanque);
        String json2 = gson.toJson(cb);
        String json3 = gson.toJson(bc);

        FormularioPost fp = new FormularioPost();

        try {
            // === Operaciones combinadas ===
            if ("Carrotanque - Barcaza".equals(operacion) || "Barcaza - Carrotanque".equals(operacion)) {
                System.out.println("Guardando cita carrotanque y barcaza en BD...");
                
                // 🔹 Convertir a String (NO necesitamos codificar si usamos sesión)
                String jsonStr = gson.toJson(json2);

                System.out.println(json2);
                
                String orden = getCookie(request, "ORDEN_OPERACION");
                
                System.out.println(orden);
                
                MaxCITA.inicializarDesdeContexto(getServletContext());
                
                // 🔹 Guardar en variable de sesión
                HttpSession session = request.getSession();
                session.setAttribute("EnviarCorreo_"+orden, jsonStr);
                
                try {
                    String cita = MaxCITA.maxcita(); // Supongamos que devuelve "CTA000000000365"

                    // Extraer la parte numérica (los últimos dígitos)
                    String numeroStr = cita.substring(3); // "000000000365"
                    int numero = Integer.parseInt(numeroStr); // 365

                    // Sumar 1
                    numero++;

                    // Formatear con ceros a la izquierda (misma longitud que original)
                    String nuevoNumeroStr = String.format("%012d", numero); // "000000000366"

                    // Armar la nueva cita
                    nuevaCita = "CTA" + nuevoNumeroStr;

                    // Guardar en la sesión
                    session.setAttribute("EnviarCita_"+orden, nuevaCita);

                } catch (SQLException ex) {
                    Logger.getLogger(Formulario_SPD_Servlet.class.getName()).log(Level.SEVERE, null, ex);
                }
                
                boolean guardadoExitoso = false;
                try {
                    // Solo si guarda bien en BD, se envía al ministerio
                    System.out.println("Enviando RIEN (carrotanque) y CitaBarcaza...");
                    
                    // Llamada al servicio
                    String response1 = formdbConRetry(fp, URL_CITAS, json2, usuario);

                    // Parsear JSON
                    JSONObject jsonResponse = new JSONObject(response1);

                    // Listas para guardar placas
                    List<String> placasExitosas = new ArrayList<>();
                    List<String> placasFallidasERROR = new ArrayList<>();

                    // ==========================
                    // Detectar si es status 412 (todas fallidas)
                    // ==========================
                    boolean todasFallidas = false;

                    // Si viene "vehiculos" y no hay "cita", asumimos 412
                    if (jsonResponse.has("vehiculos") && !jsonResponse.has("cita")) {
                        todasFallidas = true;
                    }

                    // ==========================
                    // Procesar placas fallidas
                    // ==========================
                    if (todasFallidas) {
                        JSONArray vehiculosErrados = jsonResponse.getJSONArray("vehiculos");
                        for (int i = 0; i < vehiculosErrados.length(); i++) {
                            JSONObject item = vehiculosErrados.getJSONObject(i);
                            String placaERROR = item.getString("placa");
                            String errorText = "Error desconocido";
                            if (item.has("error")) {
                                JSONObject errObj = item.getJSONObject("error");
                                errorText = errObj.optString("ErrorText", errorText);
                            }
                            placasFallidasERROR.add(placaERROR + "|" + errorText);
                        }
                    } else {
                        // Caso mixto
                        // placas exitosas
                        if (jsonResponse.has("cita")) {
                            JSONObject cita = jsonResponse.getJSONObject("cita");
                            if (cita.has("vehiculos")) {
                                JSONArray vehiculosExitosos = cita.getJSONArray("vehiculos");
                                for (int i = 0; i < vehiculosExitosos.length(); i++) {
                                    JSONObject item = vehiculosExitosos.getJSONObject(i);
                                    placasExitosas.add(item.getString("vehiculoNumPlaca"));
                                }
                            }
                        }

                        // placas fallidas
                        if (jsonResponse.has("listaErrados")) {
                            JSONArray errados = jsonResponse.getJSONArray("listaErrados");
                            for (int i = 0; i < errados.length(); i++) {
                                JSONObject item = errados.getJSONObject(i);
                                String placaError = item.getString("placa");
                                String errorText = "Error desconocido";
                                if (item.has("error")) {
                                    JSONObject errObj = item.getJSONObject("error");
                                    errorText = errObj.optString("ErrorText", errorText);
                                }
                                placasFallidasERROR.add(placaError + "|" + errorText);
                            }
                        }
                    }

                    // ==========================
                    // Guardar cookies de placas exitosas
                    // ==========================
                    if (!placasExitosas.isEmpty()) {
                        Cookie cookieExitosas = new Cookie("placasExitosas", String.join(",", placasExitosas));
                        cookieExitosas.setMaxAge(3600);
                        cookieExitosas.setPath("/CITASSPD");
                        response.addCookie(cookieExitosas);
                    } else {
                        Cookie clear = new Cookie("placasExitosas", "");
                        clear.setMaxAge(0);
                        clear.setPath("/CITASSPD");
                        response.addCookie(clear);
                    }

                    // ==========================
                    // Guardar cookies de placas fallidas
                    // ==========================
                    if (!placasFallidasERROR.isEmpty()) {
                        Cookie cookieFallidas = new Cookie("placasFallidas", String.join(",", placasFallidasERROR));
                        cookieFallidas.setMaxAge(3600);
                        cookieFallidas.setPath("/CITASSPD");
                        response.addCookie(cookieFallidas);
                    } else {
                        Cookie clear = new Cookie("placasFallidas", "");
                        clear.setMaxAge(0);
                        clear.setPath("/CITASSPD");
                        response.addCookie(clear);
                    }

                    // ==========================
                    // Redirigir al JSP
                    // ==========================
                    response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");

                    
                } catch (Exception e) {
                    e.printStackTrace();
                    session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Error: no se pudo guardar la cita en la base de datos.");
                    response.sendRedirect(request.getRequestURI() + "?ordenOperacion=" + OrdenOperacion + "&operacion=" + operacion);
                    return;
                }

            }

            // === Solo barcaza ===
            if ("Barcaza - Tanque".equals(operacion) || "Tanque - Barcaza".equals(operacion) || "Barcaza - Barcaza".equals(operacion)) {
                // 🔹 Convertir a String (NO necesitamos codificar si usamos sesión)
                String jsonStr = gson.toJson(json3);

                // 🔹 Guardar en variable de sesión
                HttpSession session = request.getSession();
                session.setAttribute("EnviarCorreo", jsonStr);

                // 🔹 Para mostrar el contenido después (ejemplo en JSP o Servlet)
                String data = (String) session.getAttribute("EnviarCorreo");
                if (data != null) {
                    System.out.println("Contenido de la variable de sesión EnviarCorreo:<br>");
                    System.out.println(data);
                } else {
                    System.out.println("No hay datos en la sesión.");
                }
                
                citaBarcazaConRetry(fp, URL_CITAS_BARC, json3);
                
                response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");
                return;
            }

            // === Solo carrotanque ===
            if ("Carrotanque - Tanque".equals(operacion) || "Tanque - Carrotanque".equals(operacion)) {
                System.out.println("Enviando RIEN (solo carrotanque)");
                
                // Llamada al servicio
                    String response1 = formdbConRetry(fp, URL_CITAS, json2, usuario);

                    // Parsear JSON
                    JSONObject jsonResponse = new JSONObject(response1);

                    // Listas para guardar placas
                    List<String> placasExitosas = new ArrayList<>();
                    List<String> placasFallidasERROR = new ArrayList<>();

                    // ==========================
                    // Detectar si es status 412 (todas fallidas)
                    // ==========================
                    boolean todasFallidas = false;

                    // Si viene "vehiculos" y no hay "cita", asumimos 412
                    if (jsonResponse.has("vehiculos") && !jsonResponse.has("cita")) {
                        todasFallidas = true;
                    }

                    // ==========================
                    // Procesar placas fallidas
                    // ==========================
                    if (todasFallidas) {
                        JSONArray vehiculosErrados = jsonResponse.getJSONArray("vehiculos");
                        for (int i = 0; i < vehiculosErrados.length(); i++) {
                            JSONObject item = vehiculosErrados.getJSONObject(i);
                            String placaERROR = item.getString("placa");
                            String errorText = "Error desconocido";
                            if (item.has("error")) {
                                JSONObject errObj = item.getJSONObject("error");
                                errorText = errObj.optString("ErrorText", errorText);
                            }
                            placasFallidasERROR.add(placaERROR + "|" + errorText);
                        }
                    } else {
                        // Caso mixto
                        // placas exitosas
                        if (jsonResponse.has("cita")) {
                            JSONObject cita = jsonResponse.getJSONObject("cita");
                            if (cita.has("vehiculos")) {
                                JSONArray vehiculosExitosos = cita.getJSONArray("vehiculos");
                                for (int i = 0; i < vehiculosExitosos.length(); i++) {
                                    JSONObject item = vehiculosExitosos.getJSONObject(i);
                                    placasExitosas.add(item.getString("vehiculoNumPlaca"));
                                }
                            }
                        }

                        // placas fallidas
                        if (jsonResponse.has("listaErrados")) {
                            JSONArray errados = jsonResponse.getJSONArray("listaErrados");
                            for (int i = 0; i < errados.length(); i++) {
                                JSONObject item = errados.getJSONObject(i);
                                String placaError = item.getString("placa");
                                String errorText = "Error desconocido";
                                if (item.has("error")) {
                                    JSONObject errObj = item.getJSONObject("error");
                                    errorText = errObj.optString("ErrorText", errorText);
                                }
                                placasFallidasERROR.add(placaError + "|" + errorText);
                            }
                        }
                    }

                    // ==========================
                    // Guardar cookies de placas exitosas
                    // ==========================
                    if (!placasExitosas.isEmpty()) {
                        Cookie cookieExitosas = new Cookie("placasExitosas", String.join(",", placasExitosas));
                        cookieExitosas.setMaxAge(3600);
                        cookieExitosas.setPath("/CITASSPD");
                        response.addCookie(cookieExitosas);
                    } else {
                        Cookie clear = new Cookie("placasExitosas", "");
                        clear.setMaxAge(0);
                        clear.setPath("/CITASSPD");
                        response.addCookie(clear);
                    }

                    // ==========================
                    // Guardar cookies de placas fallidas
                    // ==========================
                    if (!placasFallidasERROR.isEmpty()) {
                        Cookie cookieFallidas = new Cookie("placasFallidas", String.join(",", placasFallidasERROR));
                        cookieFallidas.setMaxAge(3600);
                        cookieFallidas.setPath("/CITASSPD");
                        response.addCookie(cookieFallidas);
                    } else {
                        Cookie clear = new Cookie("placasFallidas", "");
                        clear.setMaxAge(0);
                        clear.setPath("/CITASSPD");
                        response.addCookie(clear);
                    }

                    // ==========================
                    // Redirigir al JSP
                    // ==========================
                    response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");

                    
            }
        } catch (IOException e) {
            // Redirige a la misma URL en caso de I/O durante el flujo
            response.sendRedirect(request.getRequestURI());
            System.out.println("Error I/O: " + e);
        }
        // Importante: NO escribir al response aquí si ya se hizo sendRedirect antes.
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String ordenOperacion = request.getParameter("ordenOperacion");
        Gson gson = new Gson();
        Cookie[] cookies = request.getCookies();

        if (ordenOperacion != null && cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().startsWith("datosBarcaza_")) {
                    String jsonStr = URLDecoder.decode(cookie.getValue(), "UTF-8");

                    JsonObject outer = gson.fromJson(jsonStr, JsonObject.class);
                    JsonObject inner = outer.getAsJsonObject("map");

                    if (inner != null && inner.has("ordenOperacion")) {
                        if (ordenOperacion.equals(inner.get("ordenOperacion").getAsString())) {
                            // Actualizar estado solo en envío de formulario
                            inner.addProperty("estado", "Programada");

                            String nuevoJson = gson.toJson(outer);
                            Cookie cookieActualizada = new Cookie(cookie.getName(), URLEncoder.encode(nuevoJson, "UTF-8"));
                            cookieActualizada.setMaxAge(60 * 60);
                            cookieActualizada.setPath("/CITASSPD");
                            response.addCookie(cookieActualizada);

                            // Guardar datos en sesión o BD
                            request.getSession().setAttribute("BARCAZA", inner.get("NombreBarcaza").getAsString());
                            request.getSession().setAttribute("OPERACION", inner.get("operacion").getAsString());

                            System.out.println("Barcaza actualizada en envío de formulario: " + inner);
                        }
                    }
                }
            }
        }
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Formulario SPD con envío resiliente y asincrónico de extras";
    }
}
