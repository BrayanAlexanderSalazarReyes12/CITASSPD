<%-- 
    Document   : Formulario
    Created on : 03-abr-2025, 15:12:18
    Author     : brayan alexander salazar reyes
--%>

<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.OffsetDateTime"%>
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
    Cookie[] cookies4 = request.getCookies();
    if (cookies4 != null) {
        for (Cookie cookie : cookies4) {
            if(cookie.getName().equals("CITACREADA")){
                cookie.setMaxAge(0);
                cookie.setPath("/CITASSPD");
                response.addCookie(cookie);
            }
        }
    }
%>

<% 
    String[] cedulasExtras = (String[]) session.getAttribute("cedulasExtras");    
    String[] placasExtras = (String[]) session.getAttribute("placasExtras");
    String[] manifiestosExtras = (String[]) session.getAttribute("manifiestosExtras");
    String[] nombreconductorExtras = (String[]) session.getAttribute("nombreconductorExtras");
    String[] remolqueExtras = (String[]) session.getAttribute("remolqueExtras");
%>

<%
    String operacionSeleccionada = (String) request.getParameter("operacionselec");
    String operacion = (String) request.getParameter("operacion");
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
                        if(inner.get("NombreBarcaza") != null && !inner.get("NombreBarcaza").isJsonNull()){
                        
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
                        session.setAttribute("OPERACION", inner.get("operacion").getAsString());
                        Cookie cookie4 = new Cookie("OPERACION", inner.get("operacion").getAsString());
                        cookie4.setMaxAge(60 * 60);
                        cookie4.setPath("/CITASSPD");
                        response.addCookie(cookie4);
                        
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
    
    function mostrarCamionesExtra() {
        const seleccion = document.getElementById("Verificacion").value;
        const contenedor = document.getElementById("camionesExtras");
        const botonAgregar = document.getElementById("btnAgregarCamion");
        
        if (seleccion === "Si") {
            contenedor.style.display = "block";
            botonAgregar.style.display = "inline";
        } else {
            contenedor.innerHTML = ""; // Limpia los campos extras
            contenedor.style.display = "none";
            botonAgregar.style.display = "none";
        }
    }
    
    let indexCamion = 0;
    
    // Captura los valores del carro original al cargar la página
    let carroOriginal = {};

    function guardarDatosCarroOriginal() {
        carroOriginal = {
            cedula: document.getElementById("Cedula").value.trim(),
            placa: document.getElementById("Placa").value.trim().toUpperCase(),
            remolque: document.getElementById("Remolque").value.trim(),
            manifiesto: document.getElementById("manifiesto").value.trim()
        };
        console.log("Carro original guardado:", carroOriginal);
    }
    
    function agregarCamposCamion() {
        guardarDatosCarroOriginal();
        const contenedor = document.getElementById("camionesExtras");

        const nuevoCamion = document.createElement("div");
        nuevoCamion.classList.add("camion-extra");
        
        // Obtener los valores actuales del índice, si existen
        const cedula = cedulasExtras[indexCamion] || "";
        const placa = placasExtras[indexCamion] || "";
        const manifiesto = manifiestosExtras[indexCamion] || "";
        const nombre = nombreconductorExtras[indexCamion] || "";
        const remolque = remolqueExtras[indexCamion] || "";
        
        console.log("Insertando camión con:", cedula, placa, manifiesto, remolque);
        
        // Agrega contenido con un botón para eliminar
       
            
        nuevoCamion.innerHTML = "<div class=\"form-group\">" +
            "    <label for=\"CedulaExtra\">Cédula Conductor:</label>" +
            "    <input type=\"text\" id=\"CedulaExtra\" maxlength=\"20\" name=\"CedulaExtra\" value=\"" + cedula + "\" " +
            "           oninput=\"this.value = this.value.replace(/[^0-9]/g, '')\" required/>" +
            "</div>" +
            
            "<div class=\"form-group\">" +
            "    <label for=\"NombreConductor\">Nombre Completo Del Conductor:</label>" +
            "    <input type=\"text\" id=\"NombreConductor\" name=\"nombreExtra\" value=\"" + nombre + "\" " +
            "           oninput=\"this.value = this.value.replace(/[^a-zA-Z\\s]/g, '').replace(/(^\\s+|\\s{2,})/g, ' ').trimStart()\" required/>" +
            "</div>"+
           
            "<div class=\"form-group\">" +
            "    <label for=\"PlacaExtra\">Placa de Vehículo:</label>" +
            "    <input type=\"text\" id=\"PlacaExtra\" name=\"PlacaExtra\" value=\"" + placa + "\" " +
            "           pattern=\"[A-Z]{3,4}[0-9]{3,4}\" title=\"Formato: ABC123 o ABCD1234\" required/>" +
            "</div>" +
            
            "<div class=\"form-group\">"+
            "   <label for=\"RemolqueExtra\">Ingrese el número del remolque: </label>"+
            "   <input id=\"RemolqueExtra\" type=\"text\" name=\"RemolqueExtra\" "+
            "   value=\"" + remolque + "\" "+
            "   oninput=\"this.value = this.value.replace(/[^a-zA-Z0-9\\s]/g, '')\" "+
            "   required/>"+
            "</div>"+

            
            "<div class=\"form-group\">" +
            "    <label for=\"ManifiestoExtra\">N° Autorización manifiesto:</label>" +
            "    <input type=\"text\" id=\"ManifiestoExtra\" maxlength=\"50\" name=\"ManifiestoExtra\" value=\"" + manifiesto + "\" " +
            "           oninput=\"this.value = this.value.replace(/[^0-9]/g, '')\" required/>" +
            "</div>" +

            "<button type=\"button\" onclick=\"eliminarCamion(this)\" class=\"btnEliminarCamion\">" +
            "    🗑️ Eliminar camión" +
            "</button>";


        contenedor.appendChild(nuevoCamion);
        // Espera un momento para asegurar que los inputs estén en el DOM
        setTimeout(() => {
            const cedulaExtra = nuevoCamion.querySelector("#CedulaExtra");
            const placaExtra = nuevoCamion.querySelector("#PlacaExtra");
            const remolqueExtra = nuevoCamion.querySelector("#RemolqueExtra");
            const manifiestoExtra = nuevoCamion.querySelector("#ManifiestoExtra");

            [cedulaExtra, placaExtra, remolqueExtra, manifiestoExtra].forEach(input => {
                input.addEventListener("blur", () => {
                    const cedula = cedulaExtra.value.trim();
                    const placa = placaExtra.value.trim().toUpperCase();
                    const remolque = remolqueExtra.value.trim();
                    const manifiesto = manifiestoExtra.value.trim();

                    if (
                        cedula === carroOriginal.cedula ||
                        placa === carroOriginal.placa ||
                        remolque === carroOriginal.remolque ||
                        manifiesto === carroOriginal.manifiesto
                    ) {
                        alert("❌ No puede repetir la información del carrotanque original.");
                        input.value = "";
                    }
                });
            });
        }, 100);

        indexCamion++;
    }
    
    function eliminarCamion(boton) {
        const camionDiv = boton.parentElement;
        camionDiv.remove(); // Elimina el bloque del DOM
    }

    function desactivarBotonEnvio(form) {
        const boton = form.querySelector('#btnEnviar');
        if (boton) {
            boton.remove(); // Elimina el botón del DOM
            // Mostrar el loader
            document.getElementById('activar').style.display = 'block';
        }
        
        
        return true;
    }
    
    // Convertimos los arrays de Java a arrays de JavaScript
    let cedulasExtras = <%= cedulasExtras != null ? java.util.Arrays.toString(cedulasExtras).replace("[", "[\"").replace("]", "\"]").replace(", ", "\", \"") : "[]" %>;
    let placasExtras = <%= placasExtras != null ? java.util.Arrays.toString(placasExtras).replace("[", "[\"").replace("]", "\"]").replace(", ", "\", \"") : "[]" %>;
    let manifiestosExtras = <%= manifiestosExtras != null ? java.util.Arrays.toString(manifiestosExtras).replace("[", "[\"").replace("]", "\"]").replace(", ", "\", \"") : "[]" %>;
    let nombreconductorExtras = <%= nombreconductorExtras != null ? java.util.Arrays.toString(nombreconductorExtras).replace("[", "[\"").replace("]", "\"]").replace(", ", "\", \"") : "[]" %>;
    let remolqueExtras = <%= remolqueExtras != null ? java.util.Arrays.toString(remolqueExtras).replace("[", "[\"").replace("]", "\"]").replace(", ", "\", \"") : "[]" %>;
            
    // Ejemplo de uso
    console.log("Cédulas:", cedulasExtras);
    console.log("Placas:", placasExtras);
    console.log("Manifiestos:", manifiestosExtras);
    
    
    window.onload = function () {
        guardarDatosCarroOriginal();
        mostrarCamionesExtra();
        for(let i = 0; i< cedulasExtras.length; i++){
            agregarCamposCamion();
        }
    };
    
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
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <title>Solicitud de Citas - SPD</title>
    </head>
    
    <script>
        function getUrlParam(param) {
            const params = new URLSearchParams(window.location.search);
            return params.get(param);
        }

        window.addEventListener('DOMContentLoaded', () => {
            const error = getUrlParam("error");
            const mensaje = getUrlParam("mensaje");
            if (error === "1") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: mensaje,
                    confirmButtonText: 'Aceptar'
                });
            }
        });
    </script>

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
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='./CerrarSeccion'"/>
        </div>
    </header>

    <body>
        <div class="Contenedor">
            <h1>Formulario de Solicitud de Citas</h1>
            <form name="Formulario_Citas" action="./Formulario_SPD_Servlet" method="POST" enctype="multipart/form-data" class="formulario-citas" onsubmit="return desactivarBotonEnvio(this)">

                <div class="form-group">
                    <label for="Cliente">NIT del Cliente:</label>
                    <%
                        String nit = URLDecoder.decode((String) DATA, "UTF-8");
                        nit = nit.replace(".", "").replace("-", "").replace("–", "");
                    %>
                    <input id="Cliente" type="text" name="Cliente" value="<%= !DATA.equals("") ? nit : session.getAttribute("clienteForm") %>" readonly />
                </div>

                <div class="form-group">
                    <label for="Operaciones">Operación Asociada:</label>
                    <input id="Operaciones" type="text" name="Operaciones" value="<%= operacion %>" readonly />
                </div>

                <div class="form-group">
                    <label for="Fecha">Fecha y Hora de Ingreso al Puerto:</label>
                    <%
                        Date date = new Date();
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
                        String fechaActual = sdf.format(date);
                        String fecha_sesion = (String) session.getAttribute("fechaForm");
                        String fechaFormateada = "";
                        if (fecha_sesion != null) {
                            OffsetDateTime odt = OffsetDateTime.parse(fecha_sesion);
                            LocalDateTime ldt = odt.toLocalDateTime();
                            fechaFormateada = ldt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
                        }
                    %>
                    <input id="Fecha" type="datetime-local" name="fecha" value="<%= fecha_sesion != null ? fechaFormateada : fechaActual %>" required/>
                </div>

                <div class="form-group">
                    <label for="Verificacion">¿Desea registrar varios camiones de la misma empresa transportadora?</label>
                    <select id="Verificacion" name="Verificacion" onchange="mostrarCamionesExtra()" required>
                        <option value="" disabled <%= session.getAttribute("verificacionForm") == null ? "selected" : "" %>>Seleccione una opción</option>
                        <option value="Si" <%= "Si".equals(session.getAttribute("verificacionForm")) ? "selected" : "" %>>Sí</option>
                        <option value="No" <%= "No".equals(session.getAttribute("verificacionForm")) ? "selected" : "" %>>No</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="Nitempresa">NIT de la Empresa Transportadora:</label>
                    <input id="Nitempresa" type="text" maxlength="50" name="Nitempresa" value="<%= session.getAttribute("nitForm") != null ? session.getAttribute("nitForm") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required/>
                </div>

                <div class="form-group">
                    <label for="Cedula">Cédula del Conductor:</label>
                    <input id="Cedula" type="text" maxlength="20" name="Cedula" value="<%= session.getAttribute("cedulaForm") != null ? session.getAttribute("cedulaForm") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required/>
                </div>

                <div class="form-group">
                    <label for="NombreConductor">Nombre Completo del Conductor:</label>
                    <input id="NombreConductor" type="text" name="Nombre" value="<%= session.getAttribute("nombreconductor") != null ? session.getAttribute("nombreconductor") : "" %>" oninput="this.value = this.value.replace(/[^a-zA-Z\s]/g, '').replace(/\s+/g, ' ').trim()" required/>
                </div>

                <div class="form-group">
                    <label for="Placa">Placa del Vehículo:</label>
                    <input id="Placa" type="text" name="Placa" value="<%= session.getAttribute("placaForm") != null ? session.getAttribute("placaForm") : "" %>" pattern="[A-Z]{3,4}[0-9]{3,4}" title="Formato: ABC123 o ABCD1234" required />
                </div>

                <div class="form-group">
                    <label for="Remolque">Número del Remolque:</label>
                    <input id="Remolque" type="text" name="Remolque" value="<%= session.getAttribute("Remolque") != null ? session.getAttribute("Remolque") : "" %>" oninput="this.value = this.value.replace(/[^a-zA-Z0-9\s]/g, '')" required/>
                </div>

                <div class="form-group">
                    <label for="manifiesto">Número de Autorización del Manifiesto:</label>
                    <input id="manifiesto" type="text" maxlength="50" name="Manifiesto" value="<%= session.getAttribute("manifiestoForm") != null ? session.getAttribute("manifiestoForm") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required/>
                </div>

                <div class="form-group">
                    <label for="tipoProducto">Seleccione el Tipo de Producto:</label>
                    <%
                        String tipoProductoSeleccionado = (String) session.getAttribute("tipoproducto");
                    %>
                    <select id="tipoProducto" name="tipoProducto" required>
                        <option value="ninguna">Seleccione un producto</option>
                        <%
                            List<Producto> listaProductos = (List<Producto>) request.getAttribute("productos");
                            if (listaProductos != null) {
                                for (Producto producto : listaProductos) {
                                    String codProducto = producto.getCodProducto();
                                    String descripcion = producto.getDescripcion();
                                    String unidadMedida = producto.getUnidadMedida();
                                    boolean esSeleccionado = codProducto != null && codProducto.equals(tipoProductoSeleccionado);
                        %>
                            <option value="<%= codProducto %>" <%= esSeleccionado ? "selected" : "" %>>
                                <%= descripcion %> (<%= unidadMedida %>)
                            </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="CantidadProducto">Cantidad del Producto (en m³):</label>
                    <input id="CantidadProducto" type="text" name="CantidadProducto" value="<%= session.getAttribute("CantidadProducto") != null ? session.getAttribute("CantidadProducto") : "" %>" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1'); calcularTotal();" required/>
                </div>

                <div class="form-group">
                    <label for="PesoProducto">Peso Bruto del Producto (en KG):</label>
                    <input id="PesoProducto" type="text" name="PesoProducto" value="<%= session.getAttribute("PesoProducto") != null ? session.getAttribute("PesoProducto") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required/>
                </div>

                <div class="form-group">
                    <label for="FacturaComercial">Número de Factura Comercial o Remisión:</label>
                    <input id="FacturaComercial" type="text" name="FacturaComercial" value="<%= session.getAttribute("FacturaComercial") != null ? session.getAttribute("FacturaComercial") : "" %>" maxlength="30" oninput="this.value = this.value.replace(/[^0-9a-zA-Z]/g, '')" required/>
                </div>

                <div class="form-group">
                <label for="AdjuntoDeRemision">Adjuntar Remisión Valorizada (PDF):</label>
                <input 
                    type="file" 
                    id="AdjuntoDeRemision" 
                    name="AdjuntoDeRemision" 
                    accept="application/pdf" 
                    required 
                    onchange="validarTamañoArchivo(this)"
                />
                <small id="errorArchivo" style="color: red; display: none;">
                    El archivo supera el tamaño máximo permitido de 200 KB.
                </small>
            </div>

            <script>
            function validarTamañoArchivo(input) {
                const archivo = input.files[0];
                const maxTamaño = 200 * 1024; // 200 KB en bytes

                const mensajeError = document.getElementById("errorArchivo");

                if (archivo && archivo.size > maxTamaño) {
                    mensajeError.style.display = "block";
                    input.value = ""; // Limpia el archivo seleccionado
                } else {
                    mensajeError.style.display = "none";
                }
            }
            </script>


                <div class="form-group">
                    <label for="PrecioArticulo">Precio Unitario en USD:</label>
                    <input id="PrecioArticulo" type="text" name="PrecioArticulo" value="<%= session.getAttribute("PrecioArticulo") != null ? session.getAttribute("PrecioArticulo") : "" %>" oninput="this.value = this.value.replace(/[^0-9]/g, ''); calcularTotal();" required/>
                </div>

                <div class="form-group">
                    <label for="Observaciones">Observaciones Generales:</label>
                    <textarea id="Observaciones" name="Observaciones" rows="4" cols="50" required oninput="this.value = this.value.replace(/[^0-9a-zA-Z\s]/g, '')"><%= session.getAttribute("Observaciones") != null ? session.getAttribute("Observaciones") : session.getAttribute("operacionSeleccionada") != null ? session.getAttribute("operacionSeleccionada") : ""  %></textarea>
                </div>

                <div class="form-group">
                    <label for="totalResultado">Valor FOB Total (USD):</label>
                    <input id="totalResultado" type="text" name="totalResultado" value="" readonly />
                </div>

                <script>
                    function calcularTotal() {
                        const precio = parseFloat(document.getElementById('PrecioArticulo').value) || 0;
                        const cantidad = parseFloat(document.getElementById('CantidadProducto').value) || 0;
                        const total = precio * cantidad;
                        document.getElementById('totalResultado').value = total.toFixed(2);
                    }
                    window.addEventListener('DOMContentLoaded', calcularTotal);
                </script>

                <div class="form-group-camiones-extra">
                    <div class="camiones-container" id="camionesExtras" style="display:none;"></div>
                </div>

                <div class="submit-group">
                    <button type="button" id="btnAgregarCamion" style="display:none;" onclick="agregarCamposCamion()" class="btnAgregarCamion">+ Agregar otro camión</button>
                    <input type="submit" value="Enviar" id="btnEnviar"/>
                    <div class="loader" id="activar" style="display: none;"></div>
                </div>
            </form>
        </div>
    </body>
</html>