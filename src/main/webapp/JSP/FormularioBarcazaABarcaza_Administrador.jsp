<%-- 
    Document   : FormularioBarcazaABarcaza
    Created on : jun 5, 2025, 2:05:33 p.m.
    Author     : braya
--%>

<%@page import="java.net.URLDecoder"%>
<%@page import="com.google.gson.JsonObject"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.spd.Productos.Producto"%>
<%@page import="com.spd.API.TipoPorductosGet"%>
<%@page import="java.util.List"%>
<%@page import="com.spd.Model.Usuario"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>



<%
    String operacionSeleccionada = (String) request.getParameter("operacionselec");
%>

<%
    String ordenOperacion = request.getParameter("ordenOperacion");
    System.out.println("ordenOperacion: " + ordenOperacion);
    Gson gson = new Gson();
    Cookie[] cookies1 = request.getCookies();
    Map<Integer, JsonObject> datosBarcazasMap = new HashMap<Integer, JsonObject>();

    if (ordenOperacion != null && cookies1 != null) {
        for (Cookie cookie : cookies1) {
            String name = cookie.getName();
            if (name.startsWith("datosBarcaza_")) {
                int index = Integer.parseInt(name.substring("datosBarcaza_".length()));
                String jsonStr = URLDecoder.decode(cookie.getValue(), "UTF-8");

                // Convertimos a JsonObject para acceder a "map"
                JsonObject outer = gson.fromJson(jsonStr, JsonObject.class);
                JsonObject inner = outer.getAsJsonObject("map");

                if (inner.has("ordenOperacion")) {
                    String valor = inner.get("ordenOperacion").getAsString();
                    if (ordenOperacion.equals(valor)) {
                        datosBarcazasMap.put(index, inner);
                        if (inner.get("barcaza_origen")!= null && !inner.get("barcaza_origen").isJsonNull() && inner.get("barcaza_destino") != null && !inner.get("barcaza_destino").isJsonNull()){
                            
                            session.setAttribute("BARCAZA_ORIGEN", inner.get("barcaza_origen").getAsString()); // Guardamos la barcaza coincidente en sesión
                            Cookie cookie2 = new Cookie("BARCAZA_ORIGEN", inner.get("barcaza_origen").getAsString());
                            cookie2.setMaxAge(60 * 60);
                            cookie2.setPath("/CITASSPD"); // <- ¡esto es clave!
                            response.addCookie(cookie2);
                            
                            Cookie cookie3 = new Cookie("BARCAZA_DESTINO", inner.get("barcaza_destino").getAsString());
                            cookie3.setMaxAge(60 * 60);
                            cookie3.setPath("/CITASSPD");
                            response.addCookie(cookie3);
                            
                        }
                        else if(inner.get("NombreBarcaza") != null && !inner.get("NombreBarcaza").isJsonNull() && inner.get("Tanque") != null && !inner.get("Tanque").isJsonNull()){
                            
                            session.setAttribute("BARCAZA", inner.get("NombreBarcaza").getAsString()); // Guardamos la barcaza coincidente en sesión
                            Cookie cookie2 = new Cookie("NOMBRE_DE_BARCAZA", inner.get("NombreBarcaza").getAsString());
                            cookie2.setMaxAge(60 * 60);
                            cookie2.setPath("/CITASSPD"); // <- ¡esto es clave!
                            response.addCookie(cookie2);
                            
                            Cookie cookie3 = new Cookie("NOMBRE_TANQUE", inner.get("Tanque").getAsString());
                            cookie3.setMaxAge(60 * 60);
                            cookie3.setPath("/CITASSPD");
                            response.addCookie(cookie3);
                            
                        } else if(inner.get("NombreBarcaza") != null && !inner.get("NombreBarcaza").isJsonNull()){
                        
                            session.setAttribute("BARCAZA", inner.get("NombreBarcaza").getAsString()); // Guardamos la barcaza coincidente en sesión
                            Cookie cookie2 = new Cookie("NOMBRE_DE_BARCAZA", inner.get("NombreBarcaza").getAsString());
                            cookie2.setMaxAge(60 * 60);
                            cookie2.setPath("/CITASSPD"); // <- ¡esto es clave!
                            response.addCookie(cookie2);
                        } else {
                            Cookie cookie3 = new Cookie("NOMBRE_TANQUE", inner.get("Tanque").getAsString());
                            cookie3.setMaxAge(60 * 60);
                            cookie3.setPath("/CITASSPD");
                            response.addCookie(cookie3);
                        }
                        System.out.println("Barcaza guardada en sesión: " + inner);
                    }
                }
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
        <link rel="stylesheet" href="./CSS/Login.css"/>
        <link rel="stylesheet" href="./CSS/Formulario.css"/>
        <link rel="stylesheet" href="./CSS/Styles_modal.css"/>
        <title>Citas-SPD</title>
    </head>
    <%
        Cookie[] cookies = request.getCookies();
        response.setContentType("text/html");

        boolean seccionIniciada = false;
        String DATA = "";

        if (cookies != null) {
            for (Cookie cookie : cookies) {
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
        <div class="logo">
            <img src="./Imagenes/sociedad_portuaria_del_dique-.png" alt="Logo"/>
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
                }
            %>
            <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('./JSP/OperacionesActivas.jsp')">
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="Solicitud Tiempo Extra" onclick="navegarInternamente('../JSP/SolicitudTiempoExtra.jsp')"/>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='./CerrarSeccion'"/>
        </div>
    </header>
    <body>
    <div class="Contenedor">
        <h1>Solicitud de citas</h1>

        <form name="Formulario_Citas" action="./Formulario_SPD_Servlet" method="POST" enctype="multipart/form-data" class="formulario-citas" onsubmit="return desactivarBotonEnvio(this)">

            <div class="form-group">
                <label for="Cliente">Cliente:</label>
                <input id="Cliente" type="text" name="Cliente" value="<%= DATA != "" ? DATA : session.getAttribute("clienteForm") %>" readonly />
            </div>

            <div class="form-group">
                <label for="Operaciones">Operaciones:</label>
                <select name="Operaciones" required>
                    <option value="" disabled <%= session.getAttribute("operacionesForm") == null ? "selected" : "" %>>Seleccione un valor</option>
                    <option value="operacion de cargue" <%= "operacion de cargue".equals(session.getAttribute("operacionesForm")) ? "selected" : "" %>>Operación de cargue</option>
                    <option value="operacion de descargue" <%= "operacion de descargue".equals(session.getAttribute("operacionesForm")) ? "selected" : "" %>>Operación de descargue</option>
                </select>
            </div>

            <div class="form-group">
                <label for="Fecha">Fecha y hora de ingreso:</label>
                <input id="Fecha" type="datetime-local" name="fecha"
                       value="<%= session.getAttribute("fechaForm") != null ? session.getAttribute("fechaForm") : "" %>" />
            </div>

            <div class="form-group">
                <label for="Barcades">Barcaza destino:</label>
                <input id="Barcades" type="text" name="Barcades" value="<%= session.getAttribute("Barcades") != null ? session.getAttribute("Barcades") : "" %>" oninput="this.value = this.value.replace(/[^0-9A-Za-z]/g, '')" required />
            </div>

            <div class="form-group">
                <label for="tipoProducto">Tipo de producto:</label>
                <select id="tipoProducto" name="tipoProducto" required>
                    <option value="ninguna">Seleccione un producto</option>
                    <%
                        List<Producto> listaProductos = (List<Producto>) request.getAttribute("productos");
                        if (listaProductos != null) {
                            for (Producto producto : listaProductos) {
                    %>
                        <option value="<%= producto.getCodProducto() %>">
                            <%= producto.getDescripcion() %> (<%= producto.getUnidadMedida() %>)
                        </option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>

            <div class="form-group">
                <label for="CantidadProducto">Cantidad de producto en metros cúbicos:</label>
                <input id="CantidadProducto" type="text" name="CantidadProducto" value="<%= session.getAttribute("CantidadProducto") != null ? session.getAttribute("CantidadProducto") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required />
            </div>

            <div class="form-group">
                <label for="PesoProducto">Peso bruto en kg:</label>
                <input id="PesoProducto" type="text" name="PesoProducto" value="<%= session.getAttribute("PesoProducto") != null ? session.getAttribute("PesoProducto") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required />
            </div>

            <div class="form-group">
                <label for="FacturaComercial">Factura comercial o remisión:</label>
                <input id="FacturaComercial" type="text" name="FacturaComercial" value="<%= session.getAttribute("FacturaComercial") != null ? session.getAttribute("FacturaComercial") : "" %>" maxlength="30" oninput="this.value = this.value.replace(/[^0-9a-zA-Z]/g, '')" required />
            </div>

            <div class="form-group">
                <label for="AdjuntoDeRemision">Adjunto remisión valorizada (PDF):</label>
                <input type="file" id="AdjuntoDeRemision" name="AdjuntoDeRemision" accept="application/pdf" required />
            </div>

            <div class="form-group">
                <label for="PrecioArticulo">Precio unitario en dólares:</label>
                <input id="PrecioArticulo" type="text" name="PrecioArticulo" value="<%= session.getAttribute("PrecioArticulo") != null ? session.getAttribute("PrecioArticulo") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required />
            </div>

            <div class="form-group">
                <label for="Observaciones">Observaciones:</label>
                <textarea id="Observaciones" name="Observaciones" rows="4" cols="50" required oninput="this.value = this.value.replace(/[^0-9a-zA-Z\s]/g, '')"><%= session.getAttribute("Observaciones") != null ? session.getAttribute("Observaciones") : session.getAttribute("operacionSeleccionada") != null ? session.getAttribute("operacionSeleccionada") : ""  %></textarea>
            </div>

            <div class="submit-group">
                <button type="button" id="btnAgregarCamion" style="display:none;" onclick="agregarCamposCamion()" class="btnAgregarCamion">+ Agregar otro camión</button>
                <input type="submit" value="Enviar" id="btnEnviar" />
            </div>
        </form>

        <%
            String mensaje = (String) session.getAttribute("Error");
            Boolean Estado = (Boolean) session.getAttribute("Activo");
            if (Estado != null && Estado) {
        %>
        <div id="deleteModal" class="modal" style="display: flex;">
            <div class="modal-content">
                <span class="close" onclick="closeModal()">&times;</span>
                <h2><%= mensaje %></h2>
                <div class="modal-actions">
                    <form action="../EliminarContrato" method="post">
                        <input type="hidden" name="contratoId" id="contratoId" />
                        <button type="button" onclick="closeModal()" class="cancel-btn">Cerrar</button>
                    </form>
                </div>
            </div>
        </div>
        <%
                session.setAttribute("Activo", false);
            }
        %>
    </div>
</body>


</html>