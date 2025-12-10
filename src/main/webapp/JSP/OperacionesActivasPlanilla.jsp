<%-- 
    Document   : Operaciones_Activas
    Created on : abr 21, 2025, 10:18:51 a.m.
    Author     : braya
--%>

<%@page import="java.util.Arrays"%>
<%@page import="com.google.gson.JsonPrimitive"%>
<%@page import="com.google.gson.JsonSyntaxException"%>
<%@page import="com.google.gson.JsonArray"%>
<%@page import="com.google.gson.JsonParser"%>
<%@page import="com.google.gson.JsonElement"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Map"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.spd.Model.OperacionEstado"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    Cookie[] cookies3 = request.getCookies();
    int cantidad = 0;
    String estadocita = "";
    if (cookies3 != null) {
        for (Cookie cookie : cookies3) {
            if(cookie.getName().equals("NOMBRE_DE_BARCAZA")){
                System.out.println(cookie.getValue());
                cookie.setMaxAge(0); // Expirar inmediatamente
                cookie.setPath("/CITASSPD"); // <- ¡esto es clave!
                response.addCookie(cookie); // Agregar la cookie modificada a la respuesta
            }
            if(cookie.getName().equals("NOMBRE_TANQUE")){
                cookie.setMaxAge(0);
                cookie.setPath("/CITASSPD"); // <- ¡esto es clave!
                response.addCookie(cookie);
            }
            if(cookie.getName().equals("OPERACION")){
                cookie.setMaxAge(0);
                cookie.setPath("/CITASSPD"); // <- ¡esto es clave!
                response.addCookie(cookie);
            }
            if(cookie.getName().equals("CITACREADA")){
                estadocita = cookie.getValue();
                cookie.setMaxAge(0);
                cookie.setPath("/CITASSPD");
                response.addCookie(cookie);
            }
        }
    }
%>

<%
    Gson gson = new Gson();
    Cookie[] cookies = request.getCookies();
    Map<Integer, JsonObject> datosBarcazasMap = new HashMap<Integer, JsonObject>();

    
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            String name = cookie.getName();
            if (name.startsWith("datosBarcaza_")) {
                int index = Integer.parseInt(name.substring("datosBarcaza_".length()));
                cantidad = Integer.parseInt(name.substring("datosBarcaza_".length()));
                String jsonStr = URLDecoder.decode(cookie.getValue(), "UTF-8");
                // Convertimos a JsonObject para acceder a "map"
                JsonObject outer = gson.fromJson(jsonStr, JsonObject.class);
                JsonObject inner = outer.getAsJsonObject("map");
                datosBarcazasMap.put(index, inner);
            }
        }
    }
%>

<script>
    
    function closeModal() {
        document.getElementById("deleteModal").style.display = "none";
    }
    
    // Función personalizada para redirigir y marcar navegación interna
    function navegarInternamente(url) {
        sessionStorage.setItem("navegandoInternamente", "true");
        window.location.href = url;
    }
    
    
    // Cuando el DOM esté completamente cargado
    document.addEventListener("DOMContentLoaded", function () {
        sessionStorage.setItem("ventanaActiva", "true");
    });

    // Evento que se dispara antes de recargar o cerrar la pestaña
    window.addEventListener("beforeunload", function (e) {
        const navEntry = performance.getEntriesByType("navigation")[0];

        // Detecta si la página se abrió por primera vez (ej. desde un response.sendRedirect)
        if (navEntry && navEntry.type === "navigate") {
            console.log("Página cargada por primera vez (posiblemente desde un sendRedirect)");
            return;
        }
        
        // Evita ejecutar el beacon si es una recarga
        if (navEntry && navEntry.type === "reload") {
            console.log("Recarga detectada. No se envía beacon.");
            return;
        }

        // Si es navegación interna (dentro del sistema)
        if (sessionStorage.getItem("navegandoInternamente") === "true") {
            console.log("Navegación interna detectada. No se envía beacon.");
            sessionStorage.setItem("navegandoInternamente", "false");
            return;
        }

        // Si se cierra la pestaña o se sale del sistema
        if (sessionStorage.getItem("ventanaActiva") === "true") {
            console.log("Cierre de pestaña o salida del sistema detectado. Se envía beacon.");
            sessionStorage.removeItem("ventanaActiva");
            sessionStorage.removeItem("navegandoInternamente");
            navigator.sendBeacon("../cerrarVentana", "");
        }
    });
    
</script>


<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="stylesheet" href="../CSS/Login.css"/>
        <link rel="stylesheet" href="../CSS/Formulario.css"/>
        <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <title>Opeaciones Activas</title>
    </head>
    
    <%
        Cookie[] cookies1 = request.getCookies();
        response.setContentType("text/html");

        boolean seccionIniciada = false;
        String DATA = "";
        String USUARIO = "";
        
        if (cookies1 != null) {
            for (Cookie cookie : cookies1) {
                if ("SeccionIniciada".equals(cookie.getName())) {
                    seccionIniciada = true;
                } else if ("DATA".equals(cookie.getName())) {
                    DATA = cookie.getValue();
                }else if ("USUARIO".equals(cookie.getName())){
                    USUARIO = cookie.getValue();
                }
                if (seccionIniciada && !DATA.isEmpty()) break;
            }
        }

        String planilla = request.getParameter("planilla");
        Boolean planillaval = planilla != null ? Boolean.parseBoolean(planilla) : null;

        
        if (Boolean.FALSE.equals(planillaval)) {
            response.sendRedirect("./TipoOperaciones.jsp");
            return;
        }

        if (!seccionIniciada) {
            response.sendRedirect(request.getContextPath());
            return;
        }

        Object rolObj = session.getAttribute("Rol");
    %>

    <jsp:include page= "Hearder.jsp"/>
    <script>
            function getCookie(name) {
                const value = "; " + document.cookie;
                const parts = value.split("; " + name + "=");
                if (parts.length === 2) return parts.pop().split(";").shift();
            }

            const estadocita = getCookie("CITACREADA");

            console.log("estadocita:", estadocita);

            if (estadocita === "true") {
                Swal.fire({
                    title: '¡Éxito!',
                    text: 'La cita se creó correctamente.',
                    icon: 'success',
                    confirmButtonText: 'Aceptar'
                });
            }
        </script>
    
    
    <body>
        <%
            // Obtener mensaje de error y flag de correo enviado
            String errorMsg = (String) session.getAttribute("errorMsg"); 
            Boolean correoEnviado1 = Boolean.TRUE.equals(session.getAttribute("correoEnviado"));
        %>
        
        <script>
            <% 
                // ===============================
                // LEER PLACAS FALLIDAS (formato: placa|error)
                // ===============================
                String placasFallidasStr = null;
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if ("placasFallidas".equals(cookie.getName())) {
                            placasFallidasStr = cookie.getValue();
                            break;
                        }
                    }
                }

                List<String> placasFallidas = new ArrayList<String>();
                if (placasFallidasStr != null && !placasFallidasStr.isEmpty()) {
                    placasFallidas = Arrays.asList(placasFallidasStr.split(","));
                }

                // ===============================
                // LEER PLACAS EXITOSAS
                // ===============================
                String placasExitosasStr = null;
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if ("placasExitosas".equals(cookie.getName())) {
                            placasExitosasStr = cookie.getValue();
                            break;
                        }
                    }
                }

                List<String> placasExitosas = new ArrayList<String>();
                if (placasExitosasStr != null && !placasExitosasStr.isEmpty()) {
                    placasExitosas = Arrays.asList(placasExitosasStr.split(","));
                }

                boolean hayFallidas = !placasFallidas.isEmpty();
                boolean hayExitosas = !placasExitosas.isEmpty();
            %>

            <% if (hayFallidas || hayExitosas) { %>
                let htmlContenido = "";

                // ===============================
                // PLACAS EXITOSAS
                // ===============================
                <% if (hayExitosas) { %>
                    htmlContenido += "<h3 style='color:green;'>Placas enviadas correctamente:</h3><ul>";
                    <% for (String placa : placasExitosas) { %>
                        htmlContenido += "<li><%= placa %></li>";
                    <% } %>
                    htmlContenido += "</ul><br>";
                <% } %>

                // ===============================
                // PLACAS FALLIDAS CON ERROR
                // ===============================
                <% if (hayFallidas) { %>
                    htmlContenido += "<h3 style='color:red;'>Placas que no fueron enviadas:</h3><ul>";
                    <% for (String data : placasFallidas) { 
                        String[] partes = data.split("\\|", 2);
                        String placa = partes[0];
                        String error = partes.length > 1 ? partes[1] : "Error desconocido";
                    %>
                        htmlContenido += "<li><b><%= placa %></b> - <span style='color:gray;'><%= error %></span></li>";
                    <% } %>
                    htmlContenido += "</ul>";
                <% } %>

                Swal.fire({
                    icon: "<%= hayFallidas ? "warning" : "success" %>",
                    title: "Resultado del envío",
                    html: htmlContenido,
                    confirmButtonText: "OK"
                });

            <% } else { %>
                Swal.fire({
                    icon: "success",
                    title: "Operación realizada correctamente",
                    text: "No hubo placas para mostrar.",
                    confirmButtonText: "OK"
                });
            <% } %>
        </script>
        <div class="contenedor">
            <table border="1">
                <thead>
                    <tr>
                        <th>Tipo de operaciones</th>
                        <th>Agendar citas solo para carrotanques</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<String> operaciones = null;
                        List<String> operacionesper = (List<String>) session.getAttribute("Operacionespermitadas");
                        List<String> Tipooperacion = (List<String>) session.getAttribute("tipooperacionselect");
                        
                        //System.out.println("opeaciones: "+ Tipooperacion);
                        
                        List<OperacionEstado> formFinalizado = new ArrayList<OperacionEstado>();
                        int i = 1;
                        int u = 0;
                        int z = 0;
                        if (operaciones == null) {
                    %>
                            <td>PLANILLA AGENDAMIENTO CITAS</td>
                            <td>
                                <input 
                                    type="button" 
                                    value="Subir archivo" 
                                    onclick="subirExcel('<%= request.getContextPath() %>/SubirExcelServlet')" 
                                />
                            </td>
                            
                            <!-- PASAR DATA A JAVASCRIPT -->
                            <script>
                                const USUARIO = "<%= USUARIO %>";
                                const DATA = "<%= DATA %>";// <- Esta es tu empresa desde la cookie
                            </script>
                            
                            <script>
                                async function subirExcel(urlSubida) {
                                    
                                    const { value: pdfFile } = await Swal.fire({
                                        title: 'Sube la remisión en PDF (máx 200 KB)',
                                        input: 'file',
                                        inputAttributes: { accept: 'application/pdf' },
                                        showCancelButton: true,
                                        confirmButtonText: 'Aceptar',
                                        preConfirm: (file) => {

                                            if (!file) {
                                                Swal.showValidationMessage("Debes seleccionar un PDF");
                                                return false;
                                            }

                                            // Validar tamaño
                                            const maxBytes = 200 * 1024;
                                            if (file.size > maxBytes) {
                                                Swal.showValidationMessage(
                                                    "El PDF supera los 200 KB. Tamaño actual: " + (file.size/1024).toFixed(2) + " KB"
                                                );
                                                return false;
                                            }

                                            return file;
                                        }
                                    });
                                    

                                    if (!pdfFile) return;

                                    const pdfBase64 = await convertirArchivoBase64(pdfFile);

                                    
                                    await Swal.fire({
                                        icon: "success",
                                        title: "PDF cargado",
                                        text: "La remisión fue cargada correctamente",
                                        timer: 1500,
                                        showConfirmButton: false
                                    });
                                    
                                    const { value: file } = await Swal.fire({
                                        title: 'Selecciona un archivo Excel',
                                        input: 'file',
                                        inputAttributes: { accept: '.xlsx,.xls' },
                                        showCancelButton: true,
                                        cancelButtonText: 'Cancelar',
                                        confirmButtonText: 'Subir',
                                        showLoaderOnConfirm: true,
                                        allowOutsideClick: () => !Swal.isLoading(),
                                        preConfirm: (file) => {

                                            // 1️⃣ Archivo no seleccionado
                                            if (!file) {
                                                Swal.showValidationMessage("Debe seleccionar un archivo.");
                                                return false; // 🔥 mantiene el botón
                                            }

                                            // 2️⃣ Archivo vacío
                                            if (file.size === 0) {
                                                Swal.showValidationMessage("El archivo está vacío.");
                                                return false;
                                            }

                                            // 3️⃣ Extensión válida
                                            const ext = file.name.split('.').pop().toLowerCase();
                                            const extensionesValidas = ["xlsx", "xls"];

                                            if (!extensionesValidas.includes(ext)) {
                                                Swal.showValidationMessage("Solo se permiten archivos Excel (.xlsx o .xls)");
                                                return false; // 🔥 mantiene el botón
                                            }

                                            // 4️⃣ Tamaño máximo 1MB
                                            const maxBytes = 1 * 1024 * 1024;
                                            if (file.size > maxBytes) {
                                                Swal.showValidationMessage(
                                                    "El archivo supera 1MB. Tamaño:" + (file.size / 1024).toFixed(2) + "KB"
                                                );
                                                return false; // 🔥 mantiene botón visible
                                            }

                                            // Si todo está OK → SweetAlert permite continuar
                                            return file;
                                        }
                                    });

                                    if (!file) return;

                                    // --------------------------------------
                                    // YA PASÓ LAS VALIDACIONES → SUBIR EXCEL
                                    // --------------------------------------

                                    try {

                                        const formData = new FormData();
                                        formData.append("archivoExcel", file);
                                        formData.append("empresa", USUARIO);
                                        formData.append("pdfBase64", pdfBase64);

                                        const responseSubida = await fetch(urlSubida, {
                                            method: "POST",
                                            body: formData
                                        });

                                        const nombreArchivo = await responseSubida.text();

                                        Swal.fire({
                                            title: "Procesando archivo...",
                                            text: "Por favor espera",
                                            allowOutsideClick: false,
                                            didOpen: () => Swal.showLoading()
                                        });

                                        const responseLectura = await fetch("../LeerExcelServelet", {
                                            method: "POST",
                                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                            body:
                                                "archivo=" + encodeURIComponent(nombreArchivo) +
                                                "&UsuLogin=" + encodeURIComponent(USUARIO) +
                                                "&NitUsuLogin=" + encodeURIComponent(DATA) +
                                                "&pdfBase64=" + encodeURIComponent(pdfBase64)
                                        });

                                        const datos = await responseLectura.text();
                                        
                                        let respuestaJSON = null;
                                        try {
                                            respuestaJSON = JSON.parse(datos);
                                        } catch (e) {
                                            // No es JSON, lo tratamos como respuesta normal
                                        }
                                        
                                        Swal.close();
                                        
                                        // SI EL SERVLET MANDÓ {"error": "..."} → MOSTRAR ERROR
                                        if (respuestaJSON && respuestaJSON.error) {

                                            Swal.fire({
                                                title: "Error en el archivo Excel",
                                                text: respuestaJSON.error,
                                                icon: "error",
                                                width: "80%",
                                                confirmButtonText: "Aceptar"
                                            });

                                            return; // NO CONTINÚA
                                        }

                                        Swal.fire({
                                            title: "Datos del Excel",
                                            text: "La remisión fue cargada correctamente",
                                            width: '80%',
                                            scrollbarPadding: false,
                                            icon: 'success',
                                            confirmButtonText: 'Aceptar'
                                        }).then((result) => {
                                            if (result.isConfirmed) {
                                                // Redirigir a otra página
                                                window.location.href = '<%= request.getContextPath() %>/JSP/OperacionesActivasPlanilla.jsp?planilla=true';

                                                // O si quieres solo recargar la página actual:
                                                // location.reload();
                                            }
                                        });


                                    } catch (error) {
                                        Swal.fire({ icon: "error", title: "Error", text: error.message });
                                    }
                                }
                                
                                // ------------------------------------------------------------
                                // UTILIDAD: PDF → Base64
                                // ------------------------------------------------------------
                                function convertirArchivoBase64(file) {
                                    return new Promise((resolve, reject) => {
                                        const reader = new FileReader();
                                        reader.onload = () => resolve(reader.result.split(",")[1]);
                                        reader.onerror = reject;
                                        reader.readAsDataURL(file);
                                    });
                                }
                                
                                </script>

                    <%
                        } else {
                            for (String operacion : operaciones) {
                                JsonObject datos = datosBarcazasMap.get(i);
                    %>
                        <tr>
                            <td><%= datos != null && datos.has("operacion") ? datos.get("operacion").getAsString() : "N/A" %></td>
                            <td>
                                <%
                                    session.setAttribute("operacionSelec", operacion);
                                    if (operacionesper != null && operacionesper.contains(operacion)) {
                                        String ordenOp = (datos != null && datos.has("ordenOperacion")) ? datos.get("ordenOperacion").getAsString() : "";
                                        String estadoOP = (datos != null && datos.has("estado")) ? datos.get("estado").getAsString() : "";
                                        
                                        if (!DATA.equals("8060126542"))
                                        {
                                            if (estadoOP.equals("Activa")) {
                                %>
                                                <input 
                                                    type="button" 
                                                    value="Agendar cita" 
                                                    onclick="window.location.href='../TiposProductos?ordenOperacion=<%= ordenOp %>&operacion=<%= Tipooperacion.get(u) %>'"
                                                />
                                <%
                                            }else {
                                %>
                                                <input 
                                                    type="button"
                                                    value="Listo para enviar"
                                                    disabled
                                                /> 
                                <%
                                                z++; 
                                            }
                                        } else {
                                            if (estadoOP.equals("Activa")) {
                                %>
                                                <input 
                                                    type="button" 
                                                    value="Agendar cita" 
                                                    onclick="window.location.href='../TiposProductosAdministrador?ordenOperacion=<%= ordenOp %>&operacion=<%= Tipooperacion.get(u) %>'"
                                                />
                                <%
                                            }else {
                                %>
                                                <input 
                                                    type="button"
                                                    value="Listo para enviar"
                                                    disabled
                                                />
                                <%              
                                                z++; 
                                            }
                                        }
                                        formFinalizado.add(new OperacionEstado(operacion, false));
                                    } else {
                                        String ordenOp = (datos != null && datos.has("ordenOperacion")) ? datos.get("ordenOperacion").getAsString() : "";
                                        String tipoOp = (datos != null && datos.has("operacion")) ? datos.get("operacion").getAsString() : "";
                                        if (!DATA.equals("8060126542"))
                                        {
                                            if ("Barcaza - Barcaza".equals(tipoOp)) {
                                %>
                                                <input 
                                                    type="button" 
                                                    value="Agendar cita" 
                                                    onclick="window.location.href='../TipoProductosBarcaza?ordenOperacion=<%= ordenOp %>'"
                                                />
                                <%
                                            } else {
                                %>
                                                <input 
                                                    type="button" 
                                                    value="Agendar cita" 
                                                    onclick="window.location.href='../TipoProductosBarcaza?ordenOperacion=<%= ordenOp %>'"
                                                />
                                <%
                                            }
                                        }else {
                                            if ("Barcaza - Barcaza".equals(tipoOp)) {
                                %>
                                                <input 
                                                    type="button" 
                                                    value="Agendar cita" 
                                                    onclick="window.location.href='../TipoProductosBarcazaAdministrador?ordenOperacion=<%= ordenOp %>'"
                                                />
                                <%
                                            } else{
                                %>
                                                <input 
                                                    type="button" 
                                                    value="Agendar cita" 
                                                    onclick="window.location.href='../TipoProductosBarcazaAdministrador?ordenOperacion=<%= ordenOp %>'"
                                                />
                                <%
                                            }
                                        }
                                    }
                                %>
                            </td>
                        </tr>
                    <%
                                i++;
                                u++;
                            } // fin for
                            Boolean correoEnviado = (Boolean) session.getAttribute("correoEnviado");
                            if (z == u) {
                                JsonParser parser = new JsonParser();
                                JsonArray tablaReducida = new JsonArray();

                                for (int w = 1; w <= z; w++) {
                                    String data = (String) session.getAttribute("EnviarCorreo_ordenoperacion_" + w);
                                    String cita = (String) session.getAttribute("EnviarCita_ordenoperacion_" + w);
                                    if (data != null && data.trim().length() > 0) {
                                        try {
                                            JsonElement outer = parser.parse(data);
                                            if (outer.isJsonPrimitive() && outer.getAsJsonPrimitive().isString()) {
                                                outer = parser.parse(outer.getAsString());
                                            }

                                            if (outer.isJsonObject()) {
                                                JsonObject obj = outer.getAsJsonObject();

                                                // Campos superiores
                                                String trailer = obj.has("remolque") ? obj.get("remolque").getAsString() : "";
                                                String producto = obj.has("producto") ? obj.get("producto").getAsString() : "";
                                                String nitTransportadora = obj.has("nitTransportadora") ? obj.get("nitTransportadora").getAsString() : "";
                                                String operacion = obj.has("operacion") ? obj.get("operacion").getAsString() : "";
                                                String observacion = obj.has("observaciones") ? obj.get("observaciones").getAsString() : "";
                                                String fechaCita = obj.has("fechaCita") ? obj.get("fechaCita").getAsString() : "";

                                                // 🔹 Convertir fecha ISO a dd/MM/yyyy HH:mm
                                                String fechaFormateada = "";
                                                try {
                                                    java.text.SimpleDateFormat iso = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                                                    java.text.SimpleDateFormat target = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
                                                    fechaFormateada = target.format(iso.parse(fechaCita.substring(0,19)));
                                                } catch (Exception e) {
                                                    fechaFormateada = fechaCita; // si falla, dejar original
                                                }

                                                // 🔹 Valores fijos que mencionaste
                                                String nit = DATA;

                                                // recorrer vehiculos
                                                if (obj.has("vehiculos") && obj.get("vehiculos").isJsonArray()) {
                                                    JsonArray vehiculos = obj.get("vehiculos").getAsJsonArray();
                                                    for (JsonElement v : vehiculos) {
                                                        if (v.isJsonObject()) {
                                                            JsonObject vehiculo = v.getAsJsonObject();

                                                            JsonObject fila = new JsonObject();
                                                            fila.addProperty("PLACA", vehiculo.has("vehiculoNumPlaca") ? vehiculo.get("vehiculoNumPlaca").getAsString() : "");
                                                            fila.addProperty("TRAILER", trailer);
                                                            fila.addProperty("MANIFIESTO", vehiculo.has("numManifiestoCarga") ? vehiculo.get("numManifiestoCarga").getAsString() : "");
                                                            fila.addProperty("CONDUCTOR", vehiculo.has("nombreConductor") ? vehiculo.get("nombreConductor").getAsString() : "");
                                                            fila.addProperty("CEDULA", vehiculo.has("conductorCedulaCiudadania") ? vehiculo.get("conductorCedulaCiudadania").getAsString() : "");
                                                            fila.addProperty("PRODUCTO", producto);
                                                            fila.addProperty("NIT-TRANSPORTADORA", nitTransportadora);

                                                            // Nuevos campos
                                                            fila.addProperty("FECHA", fechaFormateada);
                                                            fila.addProperty("OPERACION", operacion);
                                                            fila.addProperty("OBSERVACION", observacion);
                                                            fila.addProperty("NIT", nit);
                                                            fila.addProperty("CODCITA", cita);
                                                            tablaReducida.add(fila);
                                                        }
                                                    }
                                                }
                                            }
                                        } catch (JsonSyntaxException ex) {
                                            System.out.println("⚠️ Error parseando JSON en índice " + w + ": " + ex.getMessage());
                                        }
                                    }
                                    session.removeAttribute("EnviarCorreo_ordenoperacion_" + w);
                                }

                                if (tablaReducida.size() > 0) {
                                    String jsonFinal = gson.toJson(tablaReducida);
                                    System.out.println("✅ JSON Final Reducido:");
                                    System.out.println(jsonFinal);

                                    // Recupera el último JSON enviado
                                    String ultimoJsonEnviado = (String) session.getAttribute("ultimoJsonEnviado");

                                    // Solo enviar si cambió
                                    if (ultimoJsonEnviado == null || !ultimoJsonEnviado.equals(jsonFinal)) {
                                        session.setAttribute("json", jsonFinal);
                                        session.setAttribute("ultimoJsonEnviado", jsonFinal); // guardamos este como enviado

                                        response.sendRedirect(request.getContextPath() + "/EnviarCorreo");
                                    } else {
                                        System.out.println("⚠️ No hay cambios en la tabla reducida, no se envía correo.");
                                    }
                                } else {
                                    System.out.println("⚠️ No se generó JSON final reducido porque no había datos válidos.");
                                }

                            }
                            
                        } // fin else
                    %>
                    <tr>
                        <td colspan="3">
                            <button onclick="navegarInternamente('./TipoOperaciones.jsp')">⟵ Volver</button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </body>

</html>
