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
import javax.servlet.RequestDispatcher;

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

    // === Endpoints (ajústalos si cambian) ===
    private static final String URL_RIEM = "https://rndcws2.mintransporte.gov.co/rest/RIEN";
    private static final String URL_CITAS = "http://www.siza.com.co/spdcitas-1.0/api/citas/";
    private static final String URL_CITAS_BARC = "http://www.siza.com.co/spdcitas-1.0/api/citas/barcazas/";
    private static final String URL_PRUEBAS = "http://192.168.10.80:26480/spdcitas/api/citas/";
    
    private JSONObject jsonEnv;
    private transient ExecutorService extrasPool;

    @Override
    public void init() throws ServletException {
        super.init();
        extrasPool = Executors.newFixedThreadPool(POOL_SIZE_EXTRAS);
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

    private String formdbConRetry(FormularioPost fp, String url, String json) {
        long backoff = BACKOFF_MS_INICIAL;
        for (int i = 0; i < MAX_REINTENTOS; i++) {
            try {
                String resp = fp.FormDB(url, json);
                if (resp != null && !resp.isEmpty()) return resp;
            } catch (Exception ignore) { }
            try { Thread.sleep(backoff); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
            backoff *= 2;
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
                Vehiculo vehiculoExtra = new Vehiculo(placa, cedula, fecha, manifiesto, remolque);
                List<Vehiculo> lista = new ArrayList<>();
                lista.add(vehiculoExtra);
                Variables variables = new Variables(sistemaEnturnamiento, identificador, Nitempresa, lista);
                FormularioCompleto formulario = new FormularioCompleto(acceso, variables);
                String json = gson.toJson(formulario);

                String resp = postConRetry(fp, URL, json);
                if (resp == null) {
                    System.out.println("❌ Error enviando extra placa=" + placa + " (sin respuesta)");
                } else {
                    System.out.println("✅ Extra enviado placa=" + placa);
                }
            } catch (Exception e) {
                System.out.println("❌ Excepción en envío de extra placa=" + placa + " -> " + e.getMessage());
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
            new Cliente("901.312.960–3", "C I CONQUERS WORLD TRADE S A S")
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
                
                boolean guardadoExitoso = false;
                try {
                    // Guardar en BD (cita carrotanque + barcaza)
                    formdbConRetry(fp, URL_CITAS, json2);
                    citaBarcazaConRetry(fp, URL_CITAS_BARC, json3);
                    
                    RequestDispatcher rd = request.getRequestDispatcher("/EnviarCorreo");
                    request.setAttribute("NombreEmpresa", empresaUsuario);
                    request.setAttribute("json", json2);
                    rd.forward(request, response);
                    
                    guardadoExitoso = true;
                } catch (Exception e) {
                    e.printStackTrace();
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Error: no se pudo guardar la cita en la base de datos.");
                    response.sendRedirect(request.getRequestURI() + "?ordenOperacion=" + OrdenOperacion + "&operacion=" + operacion);
                    return;
            }

                if (guardadoExitoso) {
                    // Solo si guarda bien en BD, se envía al ministerio
                    System.out.println("Enviando RIEN (carrotanque) y CitaBarcaza...");
                    String response1 = postConRetry(fp, URL_RIEM, json);

                    if (response1 == null) {
                        HttpSession session = request.getSession();
                        session.setAttribute("Activo", true);
                        session.setAttribute("Error", "Error: no hay conexión con el servidor (RIEN). Intente más tarde.");
                        response.sendRedirect(request.getRequestURI() + "?ordenOperacion=" + OrdenOperacion + "&operacion=" + operacion);
                        return;
                    }

                    JSONObject jsonResponse = new JSONObject(response1);
                    if (jsonResponse.has("ErrorCode") && jsonResponse.optInt("ErrorCode", 0) != 0) {
                        String msg = jsonResponse.optString("ErrorText", "Sin detalle");
                        HttpSession session = request.getSession();
                        session.setAttribute("Error", "Error: " + msg);
                        setFormSession(session, usuario, Operaciones, fecha, verificacion, Nitempresa, Cedula, placa,
                                Manifiesto, cedulasExtras, placasExtras, manifiestosExtras, nombre, nombreconductorExtras,
                                cantidadproducto, FacturaComercial, Observaciones, PrecioArticulo, Remolque, remolqueExtras,
                                PesoProducto, Barcades, producto);

                        setCookie(response, "CITACREADA", "true", 3600, "/CITASSPD");

                        redirectTiposProductos(request, response, operacion, msg);
                        return;
                    }

                    // Éxito RIEN
                    int sesionId = jsonResponse.optInt("SesionId", -1);
                    String ingresoId = jsonResponse.optString("IngresoId", "");
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Formulario Enviado Con Éxito: SesionId: " + sesionId + " IngresoId: " + ingresoId);

                    quitarOperacionTerminada(session);

                    // Enviar extras en paralelo
                    if (cedulasExtras != null && placasExtras != null && manifiestosExtras != null) {
                        for (int i = 0; i < cedulasExtras.length; i++) {
                            enviarVehiculoExtraAsync(
                                fp, gson, URL_RIEM, fechaFormateada1, sistemaEnturnamiento, identificador, Nitempresa, acceso,
                                placasExtras[i], cedulasExtras[i], manifiestosExtras[i],
                                (remolqueExtras != null && remolqueExtras.length > i) ? remolqueExtras[i] : null
                            );
                        }
                    }
                    return;
                }

            }

            // === Solo barcaza ===
            if ("Barcaza - Tanque".equals(operacion) || "Tanque - Barcaza".equals(operacion) || "Barcaza - Barcaza".equals(operacion)) {
                citaBarcazaConRetry(fp, URL_CITAS_BARC, json3);
                RequestDispatcher rd = request.getRequestDispatcher("/EnviarCorreoBarcaza");
                request.setAttribute("NombreEmpresa", empresaUsuario);
                request.setAttribute("json", json3);
                rd.forward(request, response);
                return;
            }

            // === Solo carrotanque ===
            if ("Carrotanque - Tanque".equals(operacion) || "Tanque - Carrotanque".equals(operacion)) {
                System.out.println("Enviando RIEN (solo carrotanque)");
                String response1 = postConRetry(fp, URL_RIEM, json);
                if (response1 == null) {
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Error: no hay conexión con el servidor (RIEN). Intente más tarde.");
                    response.sendRedirect(request.getRequestURI() + "?ordenOperacion=" + OrdenOperacion + "&operacion=" + operacion);
                    return;
                }

                JSONObject jsonResponse = new JSONObject(response1);
                if (jsonResponse.has("ErrorCode") && jsonResponse.optInt("ErrorCode", 0) != 0) {
                    String msg = jsonResponse.optString("ErrorText", "Sin detalle");
                    HttpSession session = request.getSession();
                    session.setAttribute("Error", "Error: " + msg);
                    setFormSession(session, usuario, Operaciones, fecha, verificacion, Nitempresa, Cedula, placa,
                            Manifiesto, cedulasExtras, placasExtras, manifiestosExtras, nombre, nombreconductorExtras,
                            cantidadproducto, FacturaComercial, Observaciones, PrecioArticulo, Remolque, remolqueExtras,
                            PesoProducto, Barcades, producto);
                    redirectTiposProductos(request, response, operacion, msg);
                    return;
                }

                int sesionId = jsonResponse.optInt("SesionId", -1);
                String ingresoId = jsonResponse.optString("IngresoId", "");
                HttpSession session = request.getSession();
                session.setAttribute("Activo", true);
                session.setAttribute("Error", "Formulario Enviado Con Éxito: SesionId: " + sesionId + " IngresoId: " + ingresoId);

                quitarOperacionTerminada(session);

                // Extras en paralelo
                if (cedulasExtras != null && placasExtras != null && manifiestosExtras != null) {
                    for (int i = 0; i < cedulasExtras.length; i++) {
                        enviarVehiculoExtraAsync(
                            fp, gson, URL_RIEM, fechaFormateada1, sistemaEnturnamiento, identificador, Nitempresa, acceso,
                            placasExtras[i], cedulasExtras[i], manifiestosExtras[i],
                            (remolqueExtras != null && remolqueExtras.length > i) ? remolqueExtras[i] : null
                        );
                    }
                }

                // Guardar en BD (carrotanque)
                formdbConRetry(fp, URL_CITAS, gson.toJson(cb));
                
                RequestDispatcher rd = request.getRequestDispatcher("/EnviarCorreo");
                request.setAttribute("NombreEmpresa", empresaUsuario);
                request.setAttribute("json", gson.toJson(cb));
                rd.forward(request, response);
                return;
            }

            // Si no matchea ninguna operación conocida:
            response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");

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
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Formulario SPD con envío resiliente y asincrónico de extras";
    }
}
