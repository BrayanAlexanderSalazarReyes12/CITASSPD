<%-- 
    Document   : Operaciones_Activas
    Created on : abr 21, 2025, 10:18:51 a.m.
    Author     : braya
--%>

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

        if (cookies1 != null) {
            for (Cookie cookie : cookies1) {
                if (cookie.getName().equals("SeccionIniciada")) {
                    seccionIniciada = true;
                }
                if(cookie.getName().equals("DATA")){
                    DATA = cookie.getValue();
                }
            }
        }
        
        Boolean HayOperaciones = (Boolean) session.getAttribute("hayOperacionValida");
        
        
        
        if (HayOperaciones != null && !HayOperaciones){
            response.sendRedirect("./TipoOperaciones.jsp");
        }

        if (!seccionIniciada) {
            response.sendRedirect(request.getContextPath());
        }
    %>
    
    <header>
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
        
        <div class="logo">
            <img src="../Imagenes/sociedad_portuaria_del_dique-.png" alt="Logo"/>
        </div>
        <div class="button-container">
            <input type="submit" value="Inicio" onclick="navegarInternamente('https://spdique.com/')"/>
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="Crear Usuario" onclick="navegarInternamente('CrearUsuario.jsp')"/>
                <input type="submit" value="Listar Usuarios" onclick="navegarInternamente('ListadoUsuarios.jsp')"/>
            <%
                }else if (rolObj != null && ((Integer) rolObj) != 6){
            %>
                <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
                <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
                <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
            <%
                }
            %>
        </div>
    </header>
    
    <body>
        <%
            // Obtener mensaje de error y flag de correo enviado
            String errorMsg = (String) session.getAttribute("errorMsg"); 
            Boolean correoEnviado1 = Boolean.TRUE.equals(session.getAttribute("correoEnviado"));
        %>

        <% if (errorMsg != null) { %>
            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

            <% if (correoEnviado1) { %>
                <script>
                    Swal.fire({
                        icon: 'success',
                        text: '<%= errorMsg %>',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            <% } else { %>
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: '<%= errorMsg %>',
                        confirmButtonText: 'Aceptar'
                    });
                </script>
            <% } %>

            <% 
                // Eliminar los atributos de sesión para que no se repitan
                session.removeAttribute("errorMsg");
                session.removeAttribute("correoEnviado");
            %>
        <% } %>

        
        
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
                        List<String> operaciones = (List<String>) session.getAttribute("TodasOperaciones");
                        List<String> operacionesper = (List<String>) session.getAttribute("Operacionespermitadas");
                        List<String> Tipooperacion = (List<String>) session.getAttribute("tipooperacionselect");
                        
                        //System.out.println("opeaciones: "+ Tipooperacion);
                        
                        List<OperacionEstado> formFinalizado = new ArrayList<OperacionEstado>();
                        int i = 1;
                        int u = 0;
                        int z = 0;
                        if (operaciones == null) {
                    %>
                            <script>
                                window.location.href = '../JSP/TipoOperacion.jsp';
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
                                        formFinalizado.add(new OperacionEstado(operacion, false));
                                    } else {
                                        String ordenOp = (datos != null && datos.has("ordenOperacion")) ? datos.get("ordenOperacion").getAsString() : "";
                                        String tipoOp = (datos != null && datos.has("operacion")) ? datos.get("operacion").getAsString() : "";

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
