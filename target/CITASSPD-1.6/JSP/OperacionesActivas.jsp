<%-- 
    Document   : Operaciones_Activas
    Created on : abr 21, 2025, 10:18:51 a.m.
    Author     : braya
--%>

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
            <input type="submit" value="HOME" onclick="navegarInternamente('https://spdique.com/')"/>
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="CREAR USUARIO" onclick="navegarInternamente('CrearUsuario.jsp')"/>
                <input type="submit" value="LISTAR USUARIOS" onclick="navegarInternamente('ListadoUsuarios.jsp')"/>
            <%
                }
            %>
            <input type="submit" value="LISTADOS DE CITAS" onclick="navegarInternamente('./Listados_Citas.jsp')"/>
            <input type="submit" value="CERRAR SESIÓN" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>
    
    <body>
        <div class="contenedor">
            <table border="1">
                <thead>
                    <tr>
                        <th>Tipo De Operaciones</th>
                        <th>Agendar citas solo para Carro Tanques</th>
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
                                %>
                                        <input 
                                            type="button" 
                                            value="Agendar Cita" 
                                            onclick="window.location.href='../TiposProductos?ordenOperacion=<%= ordenOp %>&operacion=<%= Tipooperacion.get(u) %>'"
                                        />
                                <%
                                        formFinalizado.add(new OperacionEstado(operacion, false));
                                    } else {
                                        String ordenOp = (datos != null && datos.has("ordenOperacion")) ? datos.get("ordenOperacion").getAsString() : "";
                                        String tipoOp = (datos != null && datos.has("operacion")) ? datos.get("operacion").getAsString() : "";

                                        if ("Barcaza - Barcaza".equals(tipoOp)) {
                                %>
                                            <input 
                                                type="button" 
                                                value="Agendar Cita" 
                                                onclick="window.location.href='../TipoProductosBarcaza?ordenOperacion=<%= ordenOp %>'"
                                            />
                                <%
                                        } else {
                                %>
                                            <input 
                                                type="button" 
                                                value="Agendar Cita" 
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
