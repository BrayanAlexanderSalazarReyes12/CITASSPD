<%-- 
    Document   : Listados_Citas
    Created on : abr 7, 2025, 9:56:47 a.m.
    Author     : braya
--%>

<%@page import="com.spd.Registro_Ingreso_Salida_Carrotanques.MovimientoCarrotanque"%>
<%@page import="com.spd.Registro_Ingreso_Salida_Carrotanques.InformacionCarrotanque"%>
<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="com.spd.CItasDB.ListaVehiculos"%>
<%@page import="java.util.*, java.text.SimpleDateFormat,
                java.time.*, java.time.format.DateTimeFormatter,
                com.spd.Model.*, com.spd.DAO.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.time.*, java.time.format.*, java.util.*" %>

<script>
    // Función personalizada para redirigir y marcar navegación interna
    function navegarInternamente(url) {
        sessionStorage.setItem("navegandoInternamente", "true");
        window.location.href = url;
    }
    
   // Marca que la pestaña está activa
    sessionStorage.setItem("ventanaActiva", "true");

    window.addEventListener("beforeunload", function () {
        const navEntry = performance.getEntriesByType("navigation")[0];
        if (navEntry?.type === "reload" || sessionStorage.getItem("navegandoInternamente") === "true") return;
        if (sessionStorage.getItem("ventanaActiva") === "true") {
            sessionStorage.clear();
            navigator.sendBeacon("./cerrarVentana", "");
        }
    });</script>

<%@ page import="org.json.JSONObject" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="refresh" content="120">
        <title>Listados Citas SPD</title>
        <link rel="stylesheet" href="./CSS/Listado_Citas.css"/>
        <link rel="stylesheet" href="./CSS/Login.css"/>
        
        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        
        <link rel="stylesheet" href="https://cdn.datatables.net/2.3.2/css/dataTables.dataTables.css" />
  
        <script src="https://cdn.datatables.net/2.3.2/js/dataTables.js"></script>
        
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <%
            String apiResponse = (String) request.getAttribute("apiResponse");
            String message = "";
            String statusCode = "";

            if (apiResponse != null && !apiResponse.isEmpty()) {
                try {
                    JSONObject jsonObj = new JSONObject(apiResponse);
                    message = jsonObj.optString("responde", "El formulario ingresado no ha sido aprobado todavía");
                    statusCode = String.valueOf(jsonObj.optInt("statusCode", 0));
                    System.out.println(apiResponse);
                } catch (Exception e) {
                    message = apiResponse; // si no es JSON válido
                }
            }
        %>
        
        <script>
            $(document).ready(function () {
                ['#myTable', '#myTable2', '#myTable3', '#myTable4'].forEach(function (id) {
                    $(id).DataTable({
                        scrollY: 400,
                        pageLength: 50, // ← Aquí se especifica mostrar 20 registros por página
                        language: { url: "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json" }
                    });
                });
            });
        </script>


    </head>
    <%
        Cookie[] cookies = request.getCookies();
        response.setContentType("text/html");
        String usuario = "";
        String nit = "";
        boolean seccionIniciada = false;

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("SeccionIniciada")) {
                    seccionIniciada = true;
                }
                if (cookie.getName().equals("USUARIO")){
                    usuario = cookie.getValue();
                }
                if (cookie.getName().equals("DATA")){
                    nit = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8.name());
                }
            }
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
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="Crear Usuario" onclick="navegarInternamente('CrearUsuario.jsp')"/>
                <input type="submit" value="Listar Usuarios" onclick="navegarInternamente('ListadoUsuarios.jsp')"/>
                <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('./ListarOperaciones')"/> 
                
                <input type="submit" value="Reporte Carrotanques I/S" onclick="navegarInternamente('./ReporteCitasIngreSalida')"/>
            <%
                } else if (rolObj != null && ((Integer) rolObj) != 5){
            %>
                <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('./JSP/OperacionesActivas.jsp')">
            <%
                }
            %>
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/>
            <% if (rolObj != null && ((Integer) rolObj) != 1) { %>
                <input type="submit" value="Solicitud Tiempo Extra" onclick="navegarInternamente('../JSP/SolicitudTiempoExtra.jsp')"/>
            <% }%>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='./CerrarSeccion'"/>
        </div>
    </header>
    <body>
        <script>
            Swal.fire({
                icon: '<%= "200".equals(statusCode) ? "success" : "error" %>',
                title: '<%= "200".equals(statusCode) ? "Cita Aprobada Exitosamente" : message %>',
                text: 'Código: <%= statusCode %>',
                confirmButtonText: 'OK'
            });
        </script>
        <div>
                <%
                    ListadoDAO ldao = new ListadoDAO();
                    MovimientoCarrotanque.inicializarDesdeContexto(request.getServletContext());
                    MovimientoCarrotanque mcdao = new MovimientoCarrotanque();
                    ResultadoCitas rc = ldao.ObtenerContratos();
                    List<ListadoCItas> ListadoCitas = rc.getCitasVehiculos();
                    List<ListadoCItas> ListadoCitas2 = rc.getCitasVehiculos2();
                    List<InformacionCarrotanque> ListadoCarrotanque = mcdao.LectorMovCarrotanque();
                    
                    if(ListadoCitas.isEmpty() && ListadoCitas2.isEmpty()){
                %>
                    <h1>⚠ No hay citas disponibles en este momento.</h1>
                <%
                    } else {
                %>              
                                <style>
                                    .content-container {
                                        max-width: 1200px; /* puedes ajustarlo a 100%, 90vw, etc. */
                                        margin: 0 auto;
                                        padding: 20px;
                                        background-color: #f5f5f5;
                                        border-radius: 8px;
                                        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
                                        overflow-x: auto;
                                    }

                                    /* Responsive ajustes */
                                    @media (max-width: 768px) {
                                        .content-container {
                                            padding: 15px;
                                        }
                                    }

                                    @media (max-width: 480px) {
                                        .content-container {
                                            padding: 10px;
                                        }
                                    }
                                </style>
                                <style>
                                   .tab-container {
                                            margin-top: 20px;
                                            border: 1px solid #ccc;
                                            border-radius: 6px;
                                            background-color: #ffffff;
                                        }

                                        .tab-header {
                                            display: flex;
                                            background-color: #f1f1f1;
                                            border-bottom: 1px solid #ccc;
                                        }

                                        .tab-button {
                                            flex: 1;
                                            padding: 10px;
                                            cursor: pointer;
                                            text-align: center;
                                            border: none;
                                            font-weight: bold;
                                            transition: background-color 0.3s;
                                        }

                                        .tab-button.active {
                                            background-color: #007bff;
                                            color: white;
                                            border-bottom: 3px solid #007bff;
                                        }

                                        .tab-content {
                                            display: none;
                                            padding: 15px;
                                        }

                                        .tab-content.active {
                                            display: block;
                                        }

                                        /* Tablets (≤ 768px) */
                                        @media (max-width: 768px) {
                                            .tab-header {
                                                flex-direction: column;
                                            }

                                            .tab-button {
                                                text-align: left;
                                                padding: 12px 16px;
                                                border-bottom: 1px solid #ccc;
                                                border-right: none;
                                            }

                                            .tab-button.active {
                                                border-left: 4px solid #007bff;
                                                border-bottom: none;
                                            }

                                            .tab-content {
                                                padding: 12px;
                                                font-size: 15px;
                                            }
                                        }

                                        /* Mobile phones (≤ 480px) */
                                        @media (max-width: 480px) {
                                            .tab-container {
                                                margin-top: 10px;
                                                border-radius: 4px;
                                            }

                                            .tab-button {
                                                font-size: 14px;
                                                padding: 10px 12px;
                                            }

                                            .tab-content {
                                                padding: 10px;
                                                font-size: 14px;
                                            }
                                        }

                                        

                                    
                                </style>
                                <div class="content-container">
                                <div class="tab-container">
                                    <div class="tab-header">
                                        <%
                                            if (rolObj != null && ((Integer) rolObj) != 5 || ((Integer) rolObj) == 8) {
                                        %>
                                            <button class="tab-button active" data-tab="camiones" onclick="mostrarTab(this)">📁 Citas camiones</button>
                                        <%
                                            }if (rolObj != null && ((Integer) rolObj) != 0 && ((Integer) rolObj) != 2 && ((Integer) rolObj) != 5 && ((Integer) rolObj) != 8) {
                                        %>
                                            <button class="tab-button" data-tab="camiones-por-finalizar" onclick="mostrarTab(this)">📁 Citas camiones por finalizar</button>
                                            <button class="tab-button" data-tab="barcazas" onclick="mostrarTab(this)">📁 Citas barcazas</button>
                                        <%
                                            }else if (rolObj != null && ((Integer) rolObj) == 2 ){
                                        %>
                                            <button class="tab-button" data-tab="camiones-por-finalizar" onclick="mostrarTab(this)">📁 Citas camiones aprobadas</button>
                                            <button class="tab-button" data-tab="barcazas" onclick="mostrarTab(this)">📁 Citas barcazas</button>
                                        <%
                                            }else if (rolObj != null && ((Integer) rolObj) == 5 ) { 
                                        %>
                                            <button class="tab-button" data-tab="camiones-por-finalizar" onclick="mostrarTab(this)">📁 Citas camiones aprobadas</button>
                                        <%
                                            }
                                        %>
                                    </div>
                                    <div id="tab-camiones" class="tab-content active">
                                     

                                    <%
                                        String filtro = request.getParameter("filtro");
                                        filtro = (filtro != null && !filtro.trim().isEmpty()) ? filtro.trim().toLowerCase() : null;
                                        LocalDate hoy = LocalDate.now(ZoneId.systemDefault());

                                        if (rolObj != null) {
                                            int rol = (Integer) rolObj;

                                            if (rol == 0) {
                                    %>
                                    <h3>📋 Lista de citas de camiones del día - <%= hoy %></h3>
                                    <table id="myTable" class="display">
                                        <thead>
                                            <tr>
                                                <th>CODCITA</th>
                                                <th>Placa</th>
                                                <th>Cedula conductor</th>
                                                <th>Nombre conductor</th>
                                                <th>Manifiesto</th>
                                                <th>Compañía</th>
                                                <th>Fecha</th>
                                                <th>Ingreso Carrotanque</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                            for (ListadoCItas listado : ListadoCitas2) {
                                                List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                                if (vehiculos != null) {
                                                    for (ListaVehiculos v : vehiculos) {
                                                        String fechaStr = v.getFechaOfertaSolicitud();
                                                        if (fechaStr != null && !fechaStr.isEmpty()) {

                                                            java.text.SimpleDateFormat sdfEntrada = new java.text.SimpleDateFormat("MMM d, yyyy h:mm:ss a", java.util.Locale.ENGLISH);
                                                            java.text.SimpleDateFormat sdfSalida = new java.text.SimpleDateFormat("yyyy/MM/dd HH:mm");
                                                            java.util.Date fechaVehiculo = null;
                                                            try {
                                                                fechaVehiculo = sdfEntrada.parse(fechaStr);
                                                            } catch (Exception e) {
                                                                e.printStackTrace();
                                                            }

                                                            if (fechaVehiculo != null) {
                                                                boolean mostrarVehiculo = filtro == null ||
                                                                    (v.getVehiculoNumPlaca() != null && v.getVehiculoNumPlaca().toLowerCase().contains(filtro)) ||
                                                                    (v.getNumManifiestoCarga() != null && v.getNumManifiestoCarga().toLowerCase().contains(filtro));

                                                                if (mostrarVehiculo) {
                                                                    // Estado del carrotanque
                                                                    String estado = "pendiente"; 
                                                                    if (ListadoCarrotanque != null && !ListadoCarrotanque.isEmpty()) {
                                                                        for (InformacionCarrotanque lc : ListadoCarrotanque) {
                                                                            if (lc.getPlaca().equalsIgnoreCase(v.getVehiculoNumPlaca())) {
                                                                                estado = lc.getEstado() != null ? lc.getEstado() : "ingresado";
                                                                                break;
                                                                            }
                                                                        }
                                                                    }

                                                                    String color = "";
                                                                    String textoBoton = "";
                                                                    String accion = "";

                                                                    if ("ingresado".equalsIgnoreCase(estado)) {
                                                                        color = "background-color: orange;";
                                                                        textoBoton = "FINALIZAR";
                                                                        accion = "RegistrarSalida(this)";
                                                                    } else if ("finalizado".equalsIgnoreCase(estado)) {
                                                                        color = "background-color: #007bff; color: white;";
                                                                        textoBoton = "FINALIZADO";
                                                                        accion = "Finalizado(this)";
                                                                    } else {
                                                                        color = "background-color: #89b61f;";
                                                                        textoBoton = "INGRESAR";
                                                                        accion = "RegistrarIngreso(this)";
                                                                    }

                                                                    String fechaFormateada = sdfSalida.format(fechaVehiculo);
                                            %>
                                            <tr data-nit="<%= listado.getNit() %>">
                                                <td><%= listado.getCodCita() %></td>
                                                <td><%= v.getVehiculoNumPlaca() %></td>
                                                <td><%= v.getConductorCedulaCiudadania() %></td>
                                                <td><%= v.getNombreConductor() %></td>
                                                <td><%= v.getNumManifiestoCarga() %></td>
                                                <td class="compania">Cargando...</td>
                                                <td><%= fechaFormateada %></td>
                                                <td>
                                                    <input type="submit"
                                                           onclick="<%= accion %>"
                                                           value="<%= textoBoton %>"
                                                           style="<%= color %> border:none; padding:5px 10px; border-radius:5px; cursor:pointer;">
                                                </td>
                                            </tr>
                                            <%
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            %>
                                        </tbody>
                                    </table>

                                    <!-- ✅ Script para manejar caché local de compañías -->
                                    <script>
                                        async function cargarCompanias() {
                                            const filas = document.querySelectorAll("#myTable tbody tr");

                                            // 🧠 Leer cache de localStorage (si no existe, crear vacío)
                                            let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                            let nuevosConsultados = 0; // contador para saber cuántos se consultan nuevos

                                            for (const fila of filas) {
                                                const nit = fila.dataset.nit?.trim();
                                                const celdaCompania = fila.querySelector(".compania");

                                                if (!nit) {
                                                    celdaCompania.textContent = "Sin NIT";
                                                    continue;
                                                }

                                                // ✅ Si ya está guardado en cache, usarlo directamente
                                                if (cacheClientes[nit]) {
                                                    celdaCompania.textContent = cacheClientes[nit];
                                                    continue;
                                                }

                                                // 🚀 Si no está en cache, consultar al servlet
                                                try {
                                                    const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                    if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                    const data = await response.json();
                                                    let nombreEmpresa = "No encontrado";

                                                    if (data && data.length > 0) {
                                                        nombreEmpresa = data[0].Nombre || "Sin nombre";
                                                    }

                                                    // Mostrar y guardar en cache
                                                    celdaCompania.textContent = nombreEmpresa;
                                                    cacheClientes[nit] = nombreEmpresa;
                                                    localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));

                                                    nuevosConsultados++;
                                                } catch (error) {
                                                    console.error("❌ Error al obtener cliente:", error);
                                                    celdaCompania.textContent = "Error";
                                                }
                                            }

                                            if (nuevosConsultados > 0) {
                                                console.log(`🔄 Se consultaron ${nuevosConsultados} nuevos NIT(s) y se guardaron en caché.`);
                                            } else {
                                                console.log("✅ Todos los NIT ya estaban en caché. No se consultó nada nuevo.");
                                            }
                                        }

                                        // 🧹 Limpieza manual del caché (opcional)
                                        function limpiarCacheClientes() {
                                            localStorage.removeItem("cacheClientes");
                                            console.log("🧹 Caché de clientes eliminado manualmente.");
                                        }

                                        // 🚀 Ejecutar al cargar la página
                                        document.addEventListener("DOMContentLoaded", cargarCompanias);
                                </script>
                                            <script>
                                                function RegistrarIngreso(boton) {
                                                    // Obtener la fila <tr> donde está el botón
                                                    const fila = boton.closest("tr");
                                                    const celdas = fila.getElementsByTagName("td");

                                                    // Extraer los datos de la fila (ajusta los índices si cambias el orden de columnas)
                                                    const CodCita = celdas[0].textContent.trim();
                                                    const placa = celdas[1].textContent.trim();
                                                    const cedula = celdas[2].textContent.trim();
                                                    const conductor = celdas[3].textContent.trim();
                                                    const manifiesto = celdas[4].textContent.trim();
                                                    const empresa = celdas[5].textContent.trim();
                                                    const fecha = celdas[6].textContent.trim();

                                                    // Puedes usar "manifiesto" o "cedula" como código de cita, según tu diseño
                                                    const codCita = CodCita;

                                                    // Armar los parámetros
                                                    const data = {
                                                        accion: "ingreso",
                                                        codCita: codCita,
                                                        placa: placa,
                                                        empresa: empresa,
                                                        estado: "ingresado"
                                                    };

                                                    // Convertir a formato x-www-form-urlencoded
                                                    const formData = new URLSearchParams();
                                                    for (const key in data) {
                                                        formData.append(key, data[key]);
                                                    }

                                                    // Enviar al servlet
                                                    fetch("./ServeletMovientoCarrotanque", {
                                                        method: "POST",
                                                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                                                        body: formData.toString()
                                                    })
                                                    .then(res => res.text())
                                                    .then(resp => {
                                                        location.reload();
                                                    })
                                                    .catch(err => {
                                                        console.error("❌ Error:", err);
                                                        alert("Error al registrar el ingreso");
                                                    });
                                                }
                                                function RegistrarSalida(boton) {
                                                    // Obtener la fila <tr> donde está el botón
                                                    const fila = boton.closest("tr");
                                                    const celdas = fila.getElementsByTagName("td");

                                                    // Extraer los datos de la fila (ajusta los índices si cambias el orden de columnas)
                                                    const CodCita = celdas[0].textContent.trim();
                                                    const placa = celdas[1].textContent.trim();
                                                    const cedula = celdas[2].textContent.trim();
                                                    const conductor = celdas[3].textContent.trim();
                                                    const manifiesto = celdas[4].textContent.trim();
                                                    const empresa = celdas[5].textContent.trim();
                                                    const fecha = celdas[6].textContent.trim();

                                                    // Puedes usar "manifiesto" o "cedula" como código de cita, según tu diseño
                                                    const codCita = CodCita;

                                                    // Armar los parámetros
                                                    const data = {
                                                        accion: "salida",
                                                        codCita: codCita,
                                                        placa: placa,
                                                        empresa: empresa,
                                                        estado: "ingresado"
                                                    };

                                                    // Convertir a formato x-www-form-urlencoded
                                                    const formData = new URLSearchParams();
                                                    for (const key in data) {
                                                        formData.append(key, data[key]);
                                                    }

                                                    // Enviar al servlet
                                                    fetch("./ServeletMovientoCarrotanque", {
                                                        method: "POST",
                                                        headers: { "Content-Type": "application/x-www-form-urlencoded" },
                                                        body: formData.toString()
                                                    })
                                                    .then(res => res.text())
                                                    .then(resp => {
                                                        location.reload();
                                                    })
                                                    .catch(err => {
                                                        console.error("❌ Error:", err);
                                                        alert("Error al registrar el ingreso");
                                                    });
                                                }
                                            </script>
                                    <%
                                            }else if(rol == 8){ 
                                    %>
                                            <h3>📋 Lista de citas de camiones del día - <%= hoy %></h3>
                                            <table id="tablaFMM" class="display">
                                                <thead>
                                                    <tr>
                                                        <th>Placa</th>
                                                        <th>Cedula conductor</th>
                                                        <th>Nombre conductor</th>
                                                        <th>Manifiesto</th>
                                                        <th>Compañia</th>
                                                        <th>Fecha</th>
                                                        <th>Fmm</th>
                                                        <th>Copiar FMM</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%
                                                    for (ListadoCItas listado : ListadoCitas2) {

                                                        List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                                        if (vehiculos != null) {
                                                            for (ListaVehiculos v : vehiculos) {
                                                                String fechaStr = v.getFechaOfertaSolicitud();
                                                                if (fechaStr != null && !fechaStr.isEmpty()) {
                                                                    java.time.LocalDateTime fechaVehiculo = java.time.LocalDateTime.parse(
                                                                        fechaStr,
                                                                        java.time.format.DateTimeFormatter.ofPattern("MMM d, yyyy h:mm:ss a", java.util.Locale.ENGLISH)
                                                                    );

                                                                    String fechaFormateada = fechaVehiculo.format(
                                                                        java.time.format.DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm")
                                                                    );

                                                                    boolean mostrarVehiculo = filtro == null ||
                                                                        (v.getVehiculoNumPlaca() != null && v.getVehiculoNumPlaca().toLowerCase().contains(filtro)) ||
                                                                        (v.getNumManifiestoCarga() != null && v.getNumManifiestoCarga().toLowerCase().contains(filtro));

                                                                    if (mostrarVehiculo) {
                                                    %>
                                                    <tr data-nit="<%= listado.getNit() %>">
                                                        <td><%= v.getVehiculoNumPlaca() %></td>
                                                        <td><%= v.getConductorCedulaCiudadania() %></td>
                                                        <td><%= v.getNombreConductor() %></td>
                                                        <td><%= v.getNumManifiestoCarga() %></td>
                                                        <td class="compania">Cargando...</td>
                                                        <td><%= fechaFormateada %></td>
                                                        <td id="<%= listado.getFmm() %>"><%= listado.getFmm() %></td>
                                                        <td><button onclick="copiarTexto('<%= listado.getFmm() %>')">📋</button></td>
                                                    </tr>
                                                    <%
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    %>
                                                </tbody>
                                            </table>

                                            <!-- ✅ Script para cargar compañías con caché local -->
                                            <script>
                                            async function cargarCompaniasFMM() {
                                                const filas = document.querySelectorAll("#tablaFMM tbody tr");
                                                let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                                let nuevosConsultados = 0;

                                                for (const fila of filas) {
                                                    const nit = fila.dataset.nit?.trim();
                                                    const celdaCompania = fila.querySelector(".compania");

                                                    if (!nit) {
                                                        celdaCompania.textContent = "Sin NIT";
                                                        continue;
                                                    }

                                                    // ✅ Si ya está guardado en cache, usarlo directamente
                                                    if (cacheClientes[nit]) {
                                                        celdaCompania.textContent = cacheClientes[nit];
                                                        continue;
                                                    }

                                                    // 🚀 Si no está en cache, consultar al servlet
                                                    try {
                                                        const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                        if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                        const data = await response.json();
                                                        let nombreEmpresa = "No encontrado";

                                                        if (data && data.length > 0) {
                                                            nombreEmpresa = data[0].empresa || "Sin nombre";
                                                        }

                                                        celdaCompania.textContent = nombreEmpresa;

                                                        // Guardar en caché
                                                        cacheClientes[nit] = nombreEmpresa;
                                                        localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
                                                        nuevosConsultados++;

                                                    } catch (error) {
                                                        console.error("❌ Error al obtener cliente:", error);
                                                        celdaCompania.textContent = "Error";
                                                    }
                                                }

                                                if (nuevosConsultados > 0) {
                                                    console.log(`🔄 Tabla FMM: se consultaron ${nuevosConsultados} nuevos NIT(s).`);
                                                } else {
                                                    console.log("✅ Tabla FMM: todos los NIT ya estaban en caché.");
                                                }
                                            }

                                            // 🧹 Limpiar cache manualmente
                                            function limpiarCacheClientes() {
                                                localStorage.removeItem("cacheClientes");
                                                console.log("🧹 Caché de clientes eliminado manualmente.");
                                            }

                                            // 🚀 Ejecutar al cargar la página
                                            document.addEventListener("DOMContentLoaded", cargarCompaniasFMM);
                                            </script>

                                    <script>
                                        function copiarTexto(idElemento) {
                                            const texto = document.getElementById(idElemento).innerText;
                                            console.log(texto);
                                            navigator.clipboard.writeText(texto).then(() => {
                                                Swal.fire({
                                                    icon: 'success',
                                                    title: 'Copiado',
                                                    text: "'" + texto + "' se copió al portapapeles",
                                                    confirmButtonText: 'Aceptar'
                                                });
                                            }).catch(err => {
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Error',
                                                    text: 'No se pudo copiar al portapapeles',
                                                    confirmButtonText: 'Aceptar'
                                                });
                                            });
                                        }
                                    </script>
                                    <%
                                            }else if (rol == 2) {
                                    %>
                                    <h3>📋 Lista de citas de camiones</h3>
                                    <table id="myTable" class="display">
                                        <thead>
                                            <tr>
                                                <th>CODCITA</th>
                                                <th>Empresa</th>
                                                <th>Tipo operación</th>
                                                <th>Cantidad vehiculos</th>
                                                <th>Fecha creación</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (ListadoCItas listado : ListadoCitas) {
                                                    String nit_final = nit.replaceAll("[^0-9]", "");

                                                    String empresaUsuario = null;

                                                    System.out.println(listado.getVehiculos().size());
                                                    System.out.println(listado.getNit() + " " + nit_final);

                                                    if (listado.getNit().equals(nit_final)) {
                                                        OffsetDateTime odt = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                        String fechaSinZona = odt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                                            %>
                                            <tr data-nit="<%= listado.getNit() %>">
                                                <td><%= listado.getCodCita() %></td>
                                                <!-- Aquí se reemplazará dinámicamente el nombre de la empresa -->
                                                <td class="empresa">Cargando...</td>
                                                <td><%= listado.getTipo_Operacion() %></td>
                                                <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                <td><%= fechaSinZona %></td>
                                                <td>
                                                    <div class="Botones_tabla">
                                                        <input type="button" onclick="window.location.href='./JSP/Tabla_Carros_Citas.jsp?registro=<%= listado.getCodCita() %>'" value="📋 Ver">
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                    }
                                                }
                                            %>
                                        </tbody>
                                    </table>

                                    <!-- ✅ Script que obtiene el nombre de la empresa desde el servlet usando fetch -->
                                    <script>
                                    async function cargarEmpresas() {
                                        const filas = document.querySelectorAll("#myTable tbody tr");
                                        let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                        let nuevos = 0;

                                        for (const fila of filas) {
                                            const nit = fila.dataset.nit?.trim();
                                            const celda = fila.querySelector(".empresa");

                                            if (!nit) {
                                                celda.textContent = "Sin NIT";
                                                continue;
                                            }

                                            // Si ya está en caché, úsalo directamente
                                            if (cacheClientes[nit]) {
                                                celda.textContent = cacheClientes[nit];
                                                continue;
                                            }

                                            // Si no está en caché, consultarlo desde el servlet
                                            try {
                                                const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                const data = await response.json();
                                                let empresa = "No encontrado";

                                                if (data && data.length > 0) {
                                                    empresa = data[0].Nombre || "Sin nombre";
                                                }

                                                celda.textContent = empresa;
                                                cacheClientes[nit] = empresa;
                                                localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
                                                nuevos++;
                                            } catch (err) {
                                                console.error("Error al obtener empresa:", err);
                                                celda.textContent = "Error";
                                            }
                                        }

                                        if (nuevos > 0)
                                            console.log(`🔄 Se consultaron ${nuevos} nuevos NIT.`);
                                        else
                                            console.log("✅ Todos los NIT ya estaban en caché.");
                                    }

                                    // Ejecutar al cargar la página
                                    document.addEventListener("DOMContentLoaded", cargarEmpresas);

                                    </script>
                                    <%
                                            } else {
                                    %>
                                    <h3>📋 Lista de citas de camiones</h3>
                                    <table id="myTable" class="display">
                                        <thead>
                                            <tr>
                                                <th>CODCITA</th>
                                                <th>Empresa</th>
                                                <th>Tipo operación</th>
                                                <th>Cantidad vehiculos</th>
                                                <th>Fecha creación</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (ListadoCItas listado : ListadoCitas) {
                                                    String fechaCreacion = listado.getFecha_Creacion_Cita();
                                                    if (fechaCreacion != null && !fechaCreacion.isEmpty()) {
                                                        OffsetDateTime odt = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                        String fechaSinZona = odt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                                            %>
                                            <!-- 🔹 Aquí añadimos el data-nit para usarlo desde JavaScript -->
                                            <tr data-nit="<%= listado.getNit() %>">
                                                <td><%= listado.getCodCita() %></td>
                                                <!-- 👇 Esta celda será reemplazada dinámicamente con el nombre real -->
                                                <td class="empresa">Cargando...</td>
                                                <td><%= listado.getTipo_Operacion() %></td>
                                                <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                <td><%= fechaSinZona %></td>
                                                <td>
                                                    <div class="Botones_tabla">
                                                        <input type="button"
                                                               onclick="window.location.href='./JSP/Tabla_Carros_Citas.jsp?registro=<%= listado.getCodCita() %>'"
                                                               value="📋 Ver">
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                    }
                                                }
                                            %>
                                        </tbody>
                                    </table>

                                    <!-- ✅ Script para cargar nombres de empresa desde el servlet y guardar en cache -->
                                    <script>
                                    async function cargarEmpresas() {
                                        const filas = document.querySelectorAll("#myTable tbody tr");
                                        let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                        let nuevosConsultados = 0;

                                        for (const fila of filas) {
                                            const nit = fila.dataset.nit?.trim();
                                            const celda = fila.querySelector(".empresa");

                                            if (!nit) {
                                                celda.textContent = "Sin NIT";
                                                continue;
                                            }

                                            // Si ya está cacheado, úsalo
                                            if (cacheClientes[nit]) {
                                                celda.textContent = cacheClientes[nit];
                                                continue;
                                            }

                                            // Consultar desde el servlet si no está en caché
                                            try {
                                                const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                const data = await response.json();
                                                let nombreEmpresa = "No encontrado";

                                                if (data && data.length > 0) {
                                                    nombreEmpresa = data[0].Nombre || "Sin nombre";
                                                }

                                                celda.textContent = nombreEmpresa;

                                                // Guardar en localStorage
                                                cacheClientes[nit] = nombreEmpresa;
                                                localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
                                                nuevosConsultados++;

                                            } catch (error) {
                                                console.error("❌ Error al obtener empresa:", error);
                                                celda.textContent = "Error";
                                            }
                                        }

                                        if (nuevosConsultados > 0)
                                            console.log(`🔄 Se consultaron ${nuevosConsultados} nuevos NIT.`);
                                        else
                                            console.log("✅ Todos los NIT ya estaban en caché.");
                                    }

                                    // 🚀 Ejecutar cuando cargue la página
                                    document.addEventListener("DOMContentLoaded", cargarEmpresas);

                                    </script>

                                    <%
                                            }
                                        }
                                    %>
                                </div>        
                                    <% if (rolObj != null && ((Integer) rolObj) != 2 && ((Integer) rolObj) != 5)
                                    {
                                    %>
                                        <div id="tab-camiones-por-finalizar" class="tab-content">
                                            <!-- Aquí irá la tabla de camiones -->
                                            <h3>📋 Lista de citas de camiones por finalizar</h3>
                                            <table id="myTable4" class="display">
                                                <thead>
                                                    <tr>
                                                        <th>CODCITA</th>
                                                        <th>Empresa</th>
                                                        <th>Tipo operación</th>
                                                        <th>Cantidad vehiculos</th>
                                                        <th>Fecha creación</th>
                                                        <th>Acciones</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%
                                                        if (rolObj != null && ((Integer) rolObj) == 2){
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                String nit_final = nit.replace("-", "");
                                                                System.out.println(listado.getNit() + " " + nit_final);

                                                                if (listado.getNit().equals(nit_final)) {
                                                                
                                                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal);
                                                                    LocalDateTime ldt = odt.toLocalDateTime();
                                                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                                                    String fecha = ldt.format(formatter1);
                                                                    String fechaSinZona = ldt.format(formatter);

                                                                    Date fecha_actual = new Date();
                                                                    LocalDateTime ldt1 = fecha_actual.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
                                                                    DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                                                    String fechaactual = ldt1.format(formatter2);

                                                                    if (fecha.equals(fechaactual)) {
                                                    %>
                                                    <!-- 🔹 Añadido: data-nit y clase empresa -->
                                                    <tr data-nit="<%= listado.getNit() %>">
                                                        <td><%= listado.getCodCita() %></td>
                                                        <td class="empresa">Cargando...</td>
                                                        <td><%= listado.getTipo_Operacion() %></td>
                                                        <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                        <td><%= fechaSinZona %></td>
                                                        <td>
                                                            <div class="Botones_tabla">
                                                                <input type="button"
                                                                       onclick="window.location.href='./JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                       value="📋 Ver">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                                    }
                                                                }
                                                            }
                                                        } else if (rolObj != null && ((Integer) rolObj) == 1) {
                                                            for(ListadoCItas listado: ListadoCitas2){

                                                                String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal);
                                                                LocalDateTime ldt = odt.toLocalDateTime();
                                                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                String fechaSinZona = ldt.format(formatter);
                                                    %>
                                                    <tr data-nit="<%= listado.getNit() %>">
                                                        <td><%= listado.getCodCita() %></td>
                                                        <td class="empresa">Cargando...</td>
                                                        <td><%= listado.getTipo_Operacion() %></td>
                                                        <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                        <td><%= fechaSinZona %></td>
                                                        <td>
                                                            <div class="Botones_tabla">
                                                                <input type="button"
                                                                       onclick="window.location.href='./JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                       value="📋 Ver">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                            }
                                                        }
                                                    %>
                                                </tbody>
                                            </table>

                                            <!-- ✅ Script universal (idéntico al de las otras tablas) -->
                                            <script>
                                            async function cargarEmpresas() {
                                                const filas = document.querySelectorAll("#myTable4 tbody tr");
                                                let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                                let nuevosConsultados = 0;

                                                for (const fila of filas) {
                                                    const nit = fila.dataset.nit?.trim();
                                                    const celda = fila.querySelector(".empresa");

                                                    if (!nit) {
                                                        celda.textContent = "Sin NIT";
                                                        continue;
                                                    }

                                                    if (cacheClientes[nit]) {
                                                        celda.textContent = cacheClientes[nit];
                                                        continue;
                                                    }

                                                    try {
                                                        const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                        if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                        const data = await response.json();
                                                        let nombreEmpresa = "No encontrado";

                                                        if (data && data.length > 0) {
                                                            nombreEmpresa = data[0].Nombre || "Sin nombre";
                                                        }

                                                        celda.textContent = nombreEmpresa;

                                                        cacheClientes[nit] = nombreEmpresa;
                                                        localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
                                                        nuevosConsultados++;

                                                    } catch (error) {
                                                        console.error("❌ Error al obtener empresa:", error);
                                                        celda.textContent = "Error";
                                                    }
                                                }

                                                if (nuevosConsultados > 0)
                                                    console.log(`🔄 Se consultaron ${nuevosConsultados} nuevos NIT.`);
                                                else
                                                    console.log("✅ Todos los NIT ya estaban en caché.");
                                            }

                                            document.addEventListener("DOMContentLoaded", cargarEmpresas);
                                            </script>

                                    <%
                                        }else if (rolObj != null && ((Integer) rolObj) != 5){
                                    %>
                                        <div id="tab-camiones-por-finalizar" class="tab-content">
                                            <!-- Aquí irá la tabla de camiones -->
                                            <h3>📋 Lista de citas de camiones Aprobados</h3>
                                            <table id="myTable4" class="display">
                                                <thead>
                                                    <tr>
                                                        <th>CODCITA</th>
                                                        <th>Empresa</th>
                                                        <th>Tipo operación</th>
                                                        <th>Cantidad vehiculos</th>
                                                        <th>Fecha creación</th>
                                                        <th>Acciones</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <%
                                                        if (rolObj != null && ((Integer) rolObj) == 2) {
                                                            for (ListadoCItas listado : ListadoCitas2) {
                                                                String nit_final = nit.replaceAll("[^0-9]", "");

                                                                if (listado.getNit().equals(nit_final)) {
                                                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal);
                                                                    LocalDateTime ldt = odt.toLocalDateTime();
                                                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                    String fechaSinZona = ldt.format(formatter);
                                                    %>
                                                    <!-- 🔹 data-nit agregado -->
                                                    <tr data-nit="<%= listado.getNit() %>">
                                                        <td><%= listado.getCodCita() %></td>
                                                        <td class="empresa">Cargando...</td>
                                                        <td><%= listado.getTipo_Operacion() %></td>
                                                        <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                        <td><%= fechaSinZona %></td>
                                                        <td>
                                                            <div class="Botones_tabla">
                                                                <input type="button"
                                                                       onclick="window.location.href='./JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                       value="📋 Ver">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                                }
                                                            }
                                                        } else if (rolObj != null && ((Integer) rolObj) == 1) {
                                                            for (ListadoCItas listado : ListadoCitas2) {

                                                                String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal);
                                                                LocalDateTime ldt = odt.toLocalDateTime();
                                                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                String fechaSinZona = ldt.format(formatter);
                                                    %>
                                                    <!-- 🔹 data-nit agregado -->
                                                    <tr data-nit="<%= listado.getNit() %>">
                                                        <td><%= listado.getCodCita() %></td>
                                                        <td class="empresa">Cargando...</td>
                                                        <td><%= listado.getTipo_Operacion() %></td>
                                                        <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                        <td><%= fechaSinZona %></td>
                                                        <td>
                                                            <div class="Botones_tabla">
                                                                <input type="button"
                                                                       onclick="window.location.href='./JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                       value="📋 Ver">
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <%
                                                            }
                                                        }
                                                    %>
                                                </tbody>
                                            </table>

                                            <!-- ✅ Script dinámico (carga nombres desde servlet y guarda en caché local) -->
                                            <script>
                                            async function cargarEmpresas() {
                                                const filas = document.querySelectorAll("#myTable4 tbody tr");
                                                let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                                let nuevosConsultados = 0;

                                                for (const fila of filas) {
                                                    const nit = fila.dataset.nit?.trim();
                                                    const celda = fila.querySelector(".empresa");

                                                    if (!nit) {
                                                        celda.textContent = "Sin NIT";
                                                        continue;
                                                    }

                                                    if (cacheClientes[nit]) {
                                                        celda.textContent = cacheClientes[nit];
                                                        continue;
                                                    }

                                                    try {
                                                        const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                        if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                        const data = await response.json();
                                                        let nombreEmpresa = "No encontrado";

                                                        if (data && data.length > 0) {
                                                            nombreEmpresa = data[0].Nombre || "Sin nombre";
                                                        }

                                                        celda.textContent = nombreEmpresa;
                                                        cacheClientes[nit] = nombreEmpresa;
                                                        localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
                                                        nuevosConsultados++;

                                                    } catch (error) {
                                                        console.error("❌ Error al obtener empresa:", error);
                                                        celda.textContent = "Error";
                                                    }
                                                }

                                                if (nuevosConsultados > 0)
                                                    console.log(`🔄 Se consultaron ${nuevosConsultados} nuevos NIT.`);
                                                else
                                                    console.log("✅ Todos los NIT ya estaban en caché.");
                                            }

                                            // Ejecutar al cargar y refrescar cada minuto
                                            document.addEventListener("DOMContentLoaded", cargarEmpresas);
                                            </script>

                                    <%
                                        }else{
                                    %>
                                        <div id="tab-camiones-por-finalizar" class="tab-content">
                                            <!-- Aquí irá la tabla de camiones -->
                                            <h3>📋 Lista de citas de camiones aprobados empresa transportadora</h3>
                                            <table id="myTable4" class="display">
                                                <thead>
                                                    <tr>
                                                        <th>CODCITA</th>
                                                        <th>Empresa</th>
                                                        <th>Tipo operación</th>
                                                        <th>Cantidad vehiculos</th>
                                                        <th>Fecha creación</th>
                                                        <th>Acciones</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                <%
                                                    if (rolObj != null && ((Integer) rolObj) == 5) {
                                                        for (ListadoCItas listado : ListadoCitas2) {
                                                            String nit_final = nit.replace("-", "");

                                                            if (listado.getNit_Empresa_Transportadora().equals(nit_final)
                                                                    && listado.getEstado().equals("AGENDADA")) {

                                                                String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal);
                                                                LocalDateTime ldt = odt.toLocalDateTime();
                                                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                String fechaSinZona = ldt.format(formatter);
                                                %>
                                                <!-- 🔹 data-nit agregado -->
                                                <tr data-nit="<%= listado.getNit() %>">
                                                    <td><%= listado.getCodCita() %></td>
                                                    <td class="empresa">Cargando...</td>
                                                    <td><%= listado.getTipo_Operacion() %></td>
                                                    <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                    <td><%= fechaSinZona %></td>
                                                    <td>
                                                        <div class="Botones_tabla">
                                                            <input type="button"
                                                                   onclick="window.location.href='./JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                   value="📋 Ver">
                                                        </div>
                                                    </td>
                                                </tr>
                                                <%
                                                            }
                                                        }
                                                    } else if (rolObj != null && ((Integer) rolObj) == 1) {
                                                        for (ListadoCItas listado : ListadoCitas2) {
                                                           
                                                            String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                            OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal);
                                                            LocalDateTime ldt = odt.toLocalDateTime();
                                                            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                            String fechaSinZona = ldt.format(formatter);
                                                %>
                                                <tr data-nit="<%= listado.getNit() %>">
                                                    <td><%= listado.getCodCita() %></td>
                                                    <td class="empresa">Cargando...</td>
                                                    <td><%= listado.getTipo_Operacion() %></td>
                                                    <td><%= listado.getVehiculos() != null ? listado.getVehiculos().size() : 0 %></td>
                                                    <td><%= fechaSinZona %></td>
                                                    <td>
                                                        <div class="Botones_tabla">
                                                            <input type="button"
                                                                   onclick="window.location.href='./JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                   value="📋 Ver">
                                                        </div>
                                                    </td>
                                                </tr>
                                                <%
                                                        }
                                                    }
                                                %>
                                                </tbody>
                                            </table>

                                            <!-- ✅ Script dinámico para cargar los nombres desde el servlet y cachear -->
                                            <script>
                                            async function cargarEmpresas() {
                                                const filas = document.querySelectorAll("#myTable4 tbody tr");
                                                let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
                                                let nuevosConsultados = 0;

                                                for (const fila of filas) {
                                                    const nit = fila.dataset.nit?.trim();
                                                    const celda = fila.querySelector(".empresa");

                                                    if (!nit) {
                                                        celda.textContent = "Sin NIT";
                                                        continue;
                                                    }

                                                    // 🔹 Si ya está cacheado, usar directamente
                                                    if (cacheClientes[nit]) {
                                                        celda.textContent = cacheClientes[nit];
                                                        continue;
                                                    }

                                                    // 🔹 Consultar al servlet
                                                    try {
                                                        const response = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
                                                        if (!response.ok) throw new Error("Error HTTP " + response.status);

                                                        const data = await response.json();
                                                        let nombreEmpresa = "No encontrado";

                                                        if (data && data.length > 0) {
                                                            nombreEmpresa = data[0].empresa || "Sin nombre";
                                                        }

                                                        celda.textContent = nombreEmpresa;
                                                        cacheClientes[nit] = nombreEmpresa;
                                                        localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
                                                        nuevosConsultados++;

                                                    } catch (error) {
                                                        console.error("❌ Error al obtener empresa:", error);
                                                        celda.textContent = "Error";
                                                    }
                                                }

                                                if (nuevosConsultados > 0)
                                                    console.log(`🔄 Se consultaron ${nuevosConsultados} nuevos NIT.`);
                                                else
                                                    console.log("✅ Todos los NIT ya estaban en caché.");
                                            }

                                            // Ejecutar al cargar y recargar cada minuto
                                            document.addEventListener("DOMContentLoaded", cargarEmpresas);
                                            </script>

                                    <%
                                        }
                                    %>
                                    </div>         
                                            
                                    <div id="tab-barcazas" class="tab-content">
                                        <jsp:include page="/JSP/MapaBarcazas.jsp" />
                                    </div>
                                </div>
                                </div> 
                                    <script>
                                        function descargarPDF(nombre, base64) {
                                            const form = document.createElement("form");
                                            form.method = "post";
                                            form.action = "DescargarRemision.jsp";
                                            form.target = "_blank";

                                            const input1 = document.createElement("input");
                                            input1.type = "hidden";
                                            input1.name = "nombre";
                                            input1.value = nombre;

                                            const input2 = document.createElement("input");
                                            input2.type = "hidden";
                                            input2.name = "base64";
                                            input2.value = base64;

                                            const accion = document.createElement("input");
                                            accion.type = "hidden";
                                            accion.name = "accion";
                                            accion.value = "descargar";

                                            form.appendChild(input1);
                                            form.appendChild(input2);
                                            form.appendChild(accion);

                                            document.body.appendChild(form);
                                            form.submit();
                                            document.body.removeChild(form);
                                        }
                                </script>
                                
                                <script>
                                    function abrirFormularioCitaMultiple(btn) {
                                        // Extraer datos del botón
                                        const barcaza = {
                                            cliente: btn.dataset.cliente,
                                            nombreBarcaza: btn.dataset.nombrebarcaza,
                                            operacion: btn.dataset.operacion,
                                            cantProducto: btn.dataset.cantproducto,
                                            precioUsd: btn.dataset.precio,
                                            facturaRemision: btn.dataset.factura,
                                            barcazaDestino: btn.dataset.barcazadestino,
                                            fechaCreacion: btn.dataset.fechacreacion,
                                            fechaZarpe: btn.dataset.fechazarpe,
                                            observaciones: btn.dataset.observaciones,
                                            codigoCita: btn.dataset.codigocita
                                        };

                                        Swal.fire({
                                            title: '📋 Programar Cita Barcaza',
                                            html:
                                                '<div style="display: flex; align-items: center; width: 100%;">' +
                                                    '<label for="fechaCita" style="width: 150px; text-align: left;"><strong>Fecha de Cita:</strong></label>' +
                                                    '<input id="fechaCita" type="datetime-local" class="swal2-input" style="flex: 1;">' +
                                                '</div>',
                                            confirmButtonText: 'Guardar',
                                            confirmButtonColor: '#28a745',
                                            cancelButtonText: 'Cancelar',
                                            showCancelButton: true,
                                            preConfirm: () => {
                                                const fecha = document.getElementById('fechaCita').value;
                                                if (!fecha) {
                                                    Swal.showValidationMessage('⚠ Debes seleccionar una fecha');
                                                    return false;
                                                }
                                                return fecha;
                                            }
                                        }).then((result) => {
                                            if (result.isConfirmed) {
                                                const fechaSeleccionada = result.value;

                                                // Agregar la fecha de cita al objeto barcaza
                                                barcaza.fechaCita = fechaSeleccionada;

                                                // Aquí puedes hacer lo que necesites, por ejemplo enviar a otro servlet:
                                                const json = encodeURIComponent(JSON.stringify(barcaza));
                                                window.location.href = './AsignarCitaBarcaza?data=' + json;


                                                // O usar fetch/AJAX si deseas enviar sin recargar
                                            }
                                        });
                                    }

                                </script>
                                
                                <script>
                                    function mostrarTab(button) {
                                      // Desactivar todos los botones y contenidos
                                      document.querySelectorAll(".tab-button").forEach(btn => btn.classList.remove("active"));
                                      document.querySelectorAll(".tab-content").forEach(tab => tab.classList.remove("active"));

                                      // Activar el botón seleccionado
                                      button.classList.add("active");

                                      // Mostrar contenido asociado
                                      const tabId = button.getAttribute("data-tab");
                                      const tabContent = document.getElementById("tab-" + tabId);
                                      if (tabContent) {
                                        tabContent.classList.add("active");
                                      }
                                    }
                                    // Inicializar pestaña activa
                                    window.onload = function () {
                                      const defaultButton = document.querySelector(".tab-button.active") || document.querySelector(".tab-button");
                                      if (defaultButton) {
                                        defaultButton.click();
                                      }
                                    };
                                </script>


                <%
                    }
                %>
        </div>
    </body>
</html>