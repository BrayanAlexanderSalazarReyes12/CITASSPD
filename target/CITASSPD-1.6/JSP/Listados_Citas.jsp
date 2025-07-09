<%-- 
    Document   : Listados_Citas
    Created on : abr 7, 2025, 9:56:47 a.m.
    Author     : braya
--%>

<%@page import="java.util.Locale"%>
<%@page import="com.spd.CItasDB.ListaVehiculos"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.Instant"%>
<%@page import="java.time.ZoneId"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.OffsetDateTime"%>
<%@page import="com.spd.Model.ListadoCitasBar"%>
<%@page import="com.spd.Model.ResultadoCitas"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.spd.Model.ListadoCItas"%>
<%@page import="com.spd.DAO.ListadoDAO"%>
<%@page import="java.util.List"%>
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

    window.addEventListener("beforeunload", function (e) {
        const navEntry = performance.getEntriesByType("navigation")[0];

        // Evita ejecutar el beacon si es una recarga
        if (navEntry && navEntry.type === "reload") {
            console.log("Recarga detectada. No se envía beacon.");
            return;
        }
        
        if(sessionStorage.getItem("navegandoInternamente") === "true"){
            console.log("navegacion");
            return;
        }

        // Si no es recarga (es cierre de pestaña o salir del sitio)
        if (sessionStorage.getItem("ventanaActiva") === "true") {
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
        <meta http-equiv="refresh" content="120">
        <title>Listados Citas SPD</title>
        <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
        <link rel="stylesheet" href="../CSS/Login.css"/>
        
        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        
        <link rel="stylesheet" href="https://cdn.datatables.net/2.3.2/css/dataTables.dataTables.css" />
  
        <script src="https://cdn.datatables.net/2.3.2/js/dataTables.js"></script>
        
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        
        <script>
            $(document).ready(function () {
                $('#myTable').DataTable({
                    scrollY: 400,
                    language: {
                        url: "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json"
                    }
                });

                $('#myTable2').DataTable({
                    scrollY: 400,
                    language: {
                        url: "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json"
                    }
                });

                $('#myTable3').DataTable({
                    scrollY: 400,
                    language: {
                        url: "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json"
                    }
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
                    nit = cookie.getValue();
                }
            }
        }

        if (!seccionIniciada) {
            response.sendRedirect(request.getContextPath());
        }
    %>

    <header>
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
            <input type="submit" Value="MOSTRAR OPERACIONES ACTIVAS" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
            <input type="submit" value="CERRAR SESIÓN" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>
    <body>
        <div class="Content">
                <%
                    ListadoDAO ldao = new ListadoDAO();
                    ResultadoCitas rc = ldao.ObtenerContratos();
                    List<ListadoCItas> ListadoCitas = rc.getCitasVehiculos();
                    List<ListadoCItas> ListadoCitas2 = rc.getCitasVehiculos2();
                    List<ListadoCitasBar> listadoCitasBars = rc.getCitasBarcazas();

                    if(ListadoCitas.isEmpty() && listadoCitasBars.isEmpty() && ListadoCitas2.isEmpty()){
                %>
                    <h1>⚠ No hay Citas disponibles en este momento.</h1>
                <%
                    } else {
                %>
                                <style>
                                   .tab-container {
                                            margin-top: 20px;
                                            border: 1px solid #ccc;
                                            border-radius: 6px;
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
                                            background-color: #e9e9e9;
                                            border: none;
                                            font-weight: bold;
                                            transition: background-color 0.3s;
                                        }

                                        .tab-button.active {
                                            background-color: #ffffff;
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

                                <div class="tab-container">
                                    <div class="tab-header">
                                        <button class="tab-button active" data-tab="camiones" onclick="mostrarTab(this)">📁 Citas Camiones</button>
                                        <%
                                            if (rolObj != null && ((Integer) rolObj) != 0) {
                                        %>
                                        <button class="tab-button" data-tab="camiones-sin-terminar" onclick="mostrarTab(this)">📁 Citas Camiones Sin Terminar</button>
                                        <button class="tab-button" data-tab="barcazas" onclick="mostrarTab(this)">📁 Citas Barcazas</button>
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
                                    <h3>📋 Lista de Citas de Camiones del día - <%= hoy %></h3>
                                    <table id="myTable" class="display">
                                        <thead>
                                            <tr>
                                                <th>PLACA</th>
                                                <th>CEDULA CONDUCTOR</th>
                                                <th>NOMBRE CONDUCTOR</th>
                                                <th>MANIFIESTO</th>
                                                <th>ESTADO</th>
                                                <th>FECHA</th>
                                                <th>FMM</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (ListadoCItas listado : ListadoCitas2) {
                                                    OffsetDateTime offsetDateTime = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                    LocalDate fechaCita = offsetDateTime.toLocalDate();
                                                    String fechaConHora = offsetDateTime.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

                                                    if (fechaCita.equals(hoy)) {
                                                        boolean mostrar = filtro == null || 
                                                            (listado.getPlaca() != null && listado.getPlaca().toLowerCase().contains(filtro)) ||
                                                            (listado.getManifiesto() != null && listado.getManifiesto().toLowerCase().contains(filtro));

                                                        if (mostrar) {
                                            %>
                                            <tr>
                                                <td><%= listado.getPlaca() %></td>
                                                <td><%= listado.getCedConductor() %></td>
                                                <td><%= listado.getNomConductor() %></td>
                                                <td><%= listado.getManifiesto() %></td>
                                                <td><%= listado.getEstado() %></td>
                                                <td><%= fechaConHora %></td>
                                                <td><%= listado.getFmm() %></td>
                                            </tr>
                                            <%
                                                        }
                                                    }

                                                    // Vehículos asociados
                                                    List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                                    if (vehiculos != null) {
                                                        for (ListaVehiculos v : vehiculos) {
                                                            String fechaStr = v.getFechaOfertaSolicitud();
                                                            if (fechaStr != null && !fechaStr.isEmpty()) {
                                                                LocalDateTime fechaVehiculo = LocalDateTime.parse(fechaStr, DateTimeFormatter.ofPattern("MMM dd, yyyy h:mm:ss a", Locale.ENGLISH));
                                                                if (fechaVehiculo.toLocalDate().equals(hoy)) {
                                                                    boolean mostrarVehiculo = filtro == null ||
                                                                        (v.getVehiculoNumPlaca() != null && v.getVehiculoNumPlaca().toLowerCase().contains(filtro)) ||
                                                                        (v.getNumManifiestoCarga() != null && v.getNumManifiestoCarga().toLowerCase().contains(filtro));

                                                                    if (mostrarVehiculo) {
                                            %>
                                            <tr>
                                                <td><%= v.getVehiculoNumPlaca() %></td>
                                                <td><%= v.getConductorCedulaCiudadania() %></td>
                                                <td><%= v.getNombreConductor() %></td>
                                                <td><%= v.getNumManifiestoCarga() %></td>
                                                <td><%= listado.getEstado() %></td>
                                                <td><%= v.getFechaOfertaSolicitud() %></td>
                                                <td><%= listado.getFmm() %></td>
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

                                    <%
                                            } else if (rol == 2) {
                                    %>
                                    <h3>📋 Lista de Citas de Camiones</h3>
                                    <table id="myTable" class="display">
                                        <thead>
                                            <tr>
                                                <th>NIT</th>
                                                <th>EMPRESA TRANSPORTADORA</th>
                                                <th>EMPRESA</th>
                                                <th>TIPO OPERACIÓN</th>
                                                <th>CANTIDAD VEHÍCULOS</th>
                                                <th>FECHA CREACIÓN</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (ListadoCItas listado : ListadoCitas) {
                                                    if (listado.getNombre_Empresa().equals(usuario)) {
                                                        OffsetDateTime odt = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                        String fechaSinZona = odt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

                                                        if (odt.toLocalDate().equals(hoy)) {
                                            %>
                                            <tr>
                                                <td><%= listado.getNit() %></td>
                                                <td><%= listado.getNit_Empresa_Transportadora() %></td>
                                                <td><%= listado.getNombre_Empresa() %></td>
                                                <td><%= listado.getTipo_Operacion() %></td>
                                                <td><%= listado.getCantidad_Vehiculos() %></td>
                                                <td><%= fechaSinZona %></td>
                                                <td>
                                                    <div class="Botones_tabla">
                                                        <input type="button" onclick="window.location.href='../JSP/Tabla_Carros_Citas.jsp?registro=<%= listado.getCodCita() %>'" value="📋 Ver">
                                                        
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                        }
                                                    }
                                                }
                                            %>
                                        </tbody>
                                    </table>

                                    <%
                                            } else {
                                    %>
                                    <h3>📋 Lista de Citas de Camiones</h3>
                                    <table id="myTable" class="display">
                                        <thead>
                                            <tr>
                                                <th>NIT</th>
                                                <th>EMPRESA TRANSPORTADORA</th>
                                                <th>EMPRESA</th>
                                                <th>TIPO OPERACIÓN</th>
                                                <th>CANTIDAD VEHÍCULOS</th>
                                                <th>FECHA CREACIÓN</th>
                                                <th>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                for (ListadoCItas listado : ListadoCitas) {
                                                    OffsetDateTime odt = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                    String fechaSinZona = odt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                                            %>
                                            <tr>
                                                <td><%= listado.getNit() %></td>
                                                <td><%= listado.getNit_Empresa_Transportadora() %></td>
                                                <td><%= listado.getNombre_Empresa() %></td>
                                                <td><%= listado.getTipo_Operacion() %></td>
                                                <td><%= listado.getCantidad_Vehiculos() %></td>
                                                <td><%= fechaSinZona %></td>
                                                <td>
                                                    <div class="Botones_tabla">
                                                        <input type="button" onclick="window.location.href='../JSP/Tabla_Carros_Citas.jsp?registro=<%= listado.getCodCita() %>'" value="📋 Ver">
                                                        <% if ((Integer)session.getAttribute("Rol") == 1) { %>
                                                        <input type="button" onclick="if(confirm('¿Cancelar esta cita?')) window.location.href='../CancelarCitaServlet?codigo=<%= listado.getCodCita() %>'" value="🗑 Cancelar">
                                                        <% } %>
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                    <%
                                            }
                                        }
                                    %>
                                </div>

                                    
                                    <div id="tab-camiones-sin-terminar" class="tab-content">
                                        <!-- Aquí irá la tabla de camiones -->
                                        <h3>📋 Lista de Citas de Camiones</h3>
                                        <table id="myTable2" class="display">
                                            <thead>
                                                <tr>
                                                    <th>NIT</th>
                                                    <th>EMPRESA TRANSPORTADORA</th>
                                                    <th>EMPRESA</th>
                                                    <th>TIPO OPERACIÓN</th>
                                                    <th>CANTIDAD VEHÍCULOS</th>
                                                    <th>FECHA CREACIÓN</th>
                                                    <th>Acciones</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                
                                                <%
                                                    if (rolObj != null && ((Integer) rolObj) == 2){
                                                 
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                if (listado.getNombre_Empresa().equals(usuario))
                                                                {
                                                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal); // desde Java 8
                                                                    LocalDateTime ldt = odt.toLocalDateTime();
                                                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                                                    String fecha = ldt.format(formatter1);
                                                                    String fechaSinZona = ldt.format(formatter);

                                                                    Date fecha_actual = new Date();
                                                                    LocalDateTime ldt1 = fecha_actual.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
                                                                    DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                                                    String fechaactual = ldt1.format(formatter2);

                                                                    System.out.println(fechaSinZona); // Resultado: 2025-04-26 10:00:00

                                                                    if (fecha.equals(fechaactual)) {

                                                %>
                                                <tr>
                                                    <td><%= listado.getNit() %></td>
                                                    <td><%= listado.getNit_Empresa_Transportadora() %></td>
                                                    <td><%= listado.getNombre_Empresa() %></td>
                                                    <td><%= listado.getTipo_Operacion() %></td>
                                                    <td><%= listado.getCantidad_Vehiculos() %></td>
                                                    <td><%= fechaSinZona %></td>
                                                    <td>
                                                        <div class="Botones_tabla">
                                                            <input type="button"
                                                                   onclick="window.location.href='../JSP/Tabla_Carros_Citas_Agendada.jsp?registro=<%= listado.getCodCita() %>'"
                                                                   value="📋 Ver">
                                                            <%
                                                                if (session.getAttribute("Rol") != null && (Integer)session.getAttribute("Rol") == 1) {
                                                            %>
                                                            <input type="button"
                                                                   onclick="if(confirm('¿Cancelar esta cita?')) window.location.href='../CancelarCitaServlet?codigo=<%= listado.getCodCita() %>'"
                                                                   value="🗑 Cancelar">
                                                            <%
                                                                }
                                                            %>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <%
                                                    }}}} else if (rolObj != null && ((Integer) rolObj) == 1){
                                                %>
                                                        <%
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal); // desde Java 8
                                                                    LocalDateTime ldt = odt.toLocalDateTime();
                                                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                                                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                                                    String fecha = ldt.format(formatter1);
                                                                    String fechaSinZona = ldt.format(formatter);

                                                                    Date fecha_actual = new Date();
                                                                    LocalDateTime ldt1 = fecha_actual.toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
                                                                    DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                                                    String fechaactual = ldt1.format(formatter2);

                                                                    System.out.println(fechaSinZona); // Resultado: 2025-04-26 10:00:00

 
                                                        %>
                                                                        <tr>
                                                                            <td><%= listado.getNit() %></td>
                                                                            <td><%= listado.getNit_Empresa_Transportadora() %></td>
                                                                            <td><%= listado.getNombre_Empresa() %></td>
                                                                            <td><%= listado.getTipo_Operacion() %></td>
                                                                            <td><%= listado.getCantidad_Vehiculos() %></td>
                                                                            <td><%= fechaSinZona %></td>
                                                                            <td>
                                                                                <div class="Botones_tabla">
                                                                                    <input type="button"
                                                                                           onclick="window.location.href='../JSP/Tabla_Carros_Citas_Agendada.jsp?registro=<%= listado.getCodCita() %>'"
                                                                                           value="📋 Ver">
                                                                                    <%
                                                                                        if (session.getAttribute("Rol") != null && (Integer)session.getAttribute("Rol") == 1) {
                                                                                    %>
                                                                                    <input type="button"
                                                                                           onclick="if(confirm('¿Cancelar esta cita?')) window.location.href='../CancelarCitaServlet?codigo=<%= listado.getCodCita() %>'"
                                                                                           value="🗑 Cancelar">
                                                                                    <%
                                                                                        }
                                                                                    %>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                   <%
                                                                       }
                                                                   %>
                                                <%
                                                    }
                                                %>
                                            </tbody>
                                        </table>
                                    </div>        
                                        
                                    <div id="tab-barcazas" class="tab-content">
                                        <!-- Aquí irá la tabla de barcazas -->
                                        <h3>🚢 Lista de Citas de Barcazas</h3>
                                        <table id="myTable3" class="display">
                                            <thead>
                                                <tr>
                                                    <th>CLIENTE</th>
                                                    <th>NOMBRE BARCZA</th>
                                                    <th>OPERACIÓN</th>
                                                    <th>CANTIDAD</th>
                                                    <th>PRECIO USD</th>
                                                    <th>FACTURA</th>
                                                    <th>DESTINO</th>
                                                    <th>FECHA CREACIÓN</th>
                                                    <th>ZARPE ESTIMADO</th>
                                                    <th>OBSERVACIONES</th>
                                                    <th>Acciones</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <%
                                                    if (rolObj != null && ((Integer) rolObj) == 1) {
                                                        for(ListadoCitasBar barcaza: listadoCitasBars){
                                                            long millis_creacion = Long.parseLong(barcaza.getFeCreacion());
                                                            long millis_zarpe = Long.parseLong(barcaza.getFeEstimadaZarpe());

                                                            ZoneId zona = ZoneId.of("America/Bogota");

                                                            LocalDateTime ldt_creacion = Instant.ofEpochMilli(millis_creacion).atZone(zona).toLocalDateTime();
                                                            LocalDateTime ldt_zarpe = Instant.ofEpochMilli(millis_zarpe).atZone(zona).toLocalDateTime();

                                                            // Formatear a string
                                                            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

                                                            String fecha_creacion_zona = ldt_creacion.format(formatter);
                                                            String fecha_zarpe_zona = ldt_zarpe.format(formatter);

                                                %>
                                                            <tr>
                                                                <td><%= barcaza.getCliente() %></td>
                                                                <td><%= barcaza.getNombreBarcaza() %></td>
                                                                <td><%= barcaza.getOperacion() %></td>
                                                                <td><%= barcaza.getCantProducto() %></td>
                                                                <td><%= barcaza.getPrecioUsd() %></td>
                                                                <td><%= barcaza.getFacturaRemision() %></td>
                                                                <td><%= barcaza.getBarcazaDestino() %></td>
                                                                <td><%= fecha_creacion_zona %></td>
                                                                <td><%= fecha_zarpe_zona %></td>
                                                                <td><%= barcaza.getObservaciones() %></td>
                                                                <td>
                                                                    <div class="Botones_tabla">
                                                                        <input type="button"
                                                                            class="btn-ver-cita"
                                                                            data-cliente="<%= barcaza.getCliente() %>"
                                                                            data-nombrebarcaza="<%= barcaza.getNombreBarcaza() %>"
                                                                            data-operacion="<%= barcaza.getOperacion() %>"
                                                                            data-cantproducto="<%= barcaza.getCantProducto() %>"
                                                                            data-precio="<%= barcaza.getPrecioUsd() %>"
                                                                            data-factura="<%= barcaza.getFacturaRemision() %>"
                                                                            data-barcazadestino="<%= barcaza.getBarcazaDestino() %>"
                                                                            data-fechacreacion="<%= fecha_creacion_zona %>"
                                                                            data-fechazarpe="<%= fecha_zarpe_zona %>"
                                                                            data-observaciones="<%= barcaza.getObservaciones() %>"
                                                                            data-codigocita="<%= barcaza.getCodigoCita() %>"
                                                                            onclick="abrirFormularioCitaMultiple(this)"
                                                                            value="📋 Ver">
                                                                        <%
                                                                            if (session.getAttribute("Rol") != null && (Integer)session.getAttribute("Rol") == 1) {
                                                                        %>
                                                                        <input type="button"
                                                                               onclick="if(confirm('¿Cancelar cita?')) window.location.href='../CancelarCitaBarcazaServlet?codigo=<%= barcaza.getCodigoCita() %>'"
                                                                               value="🗑 Cancelar">
                                                                        <%
                                                                            }
                                                                        %>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                <%
                                                    }} else if (rolObj != null && ((Integer) rolObj) != 0 ) {
                                                        for(ListadoCitasBar barcaza: listadoCitasBars){
                                                            long millis_creacion = Long.parseLong(barcaza.getFeCreacion());
                                                            long millis_zarpe = Long.parseLong(barcaza.getFeEstimadaZarpe());

                                                            ZoneId zona = ZoneId.of("America/Bogota");

                                                            LocalDateTime ldt_creacion = Instant.ofEpochMilli(millis_creacion).atZone(zona).toLocalDateTime();
                                                            LocalDateTime ldt_zarpe = Instant.ofEpochMilli(millis_zarpe).atZone(zona).toLocalDateTime();

                                                            // Formatear a string
                                                            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

                                                            String fecha_creacion_zona = ldt_creacion.format(formatter);
                                                            String fecha_zarpe_zona = ldt_zarpe.format(formatter);
                                                %>
                                                        <tr>
                                                                <td><%= barcaza.getCliente() %></td>
                                                                <td><%= barcaza.getNombreBarcaza() %></td>
                                                                <td><%= barcaza.getOperacion() %></td>
                                                                <td><%= barcaza.getCantProducto() %></td>
                                                                <td><%= barcaza.getPrecioUsd() %></td>
                                                                <td><%= barcaza.getFacturaRemision() %></td>
                                                                <td><%= barcaza.getBarcazaDestino() %></td>
                                                                <td><%= fecha_creacion_zona %></td>
                                                                <td><%= fecha_zarpe_zona %></td>
                                                                <td><%= barcaza.getObservaciones() %></td>
                                                                <td>
                                                                    <div class="Botones_tabla">
                                                                        <input type="button"
                                                                            class="btn-ver-cita"
                                                                            data-cliente="<%= barcaza.getCliente() %>"
                                                                            data-nombrebarcaza="<%= barcaza.getNombreBarcaza() %>"
                                                                            data-operacion="<%= barcaza.getOperacion() %>"
                                                                            data-cantproducto="<%= barcaza.getCantProducto() %>"
                                                                            data-precio="<%= barcaza.getPrecioUsd() %>"
                                                                            data-factura="<%= barcaza.getFacturaRemision() %>"
                                                                            data-barcazadestino="<%= barcaza.getBarcazaDestino() %>"
                                                                            data-fechacreacion="<%= fecha_creacion_zona %>"
                                                                            data-fechazarpe="<%= fecha_zarpe_zona %>"
                                                                            data-observaciones="<%= barcaza.getObservaciones() %>"
                                                                            data-codigocita="<%= barcaza.getCodigoCita() %>"
                                                                            onclick="abrirFormularioCitaMultiple(this)"
                                                                            value="📋 Ver">

                                                                        <%
                                                                            if (session.getAttribute("Rol") != null && (Integer)session.getAttribute("Rol") == 1) {
                                                                        %>
                                                                        <input type="button"
                                                                               onclick="if(confirm('¿Cancelar cita?')) window.location.href='../CancelarCitaBarcazaServlet?codigo=<%= barcaza.getCodigoCita() %>'"
                                                                               value="🗑 Cancelar">
                                                                        <%
                                                                            }
                                                                        %>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                <%
                                                    }}
                                                %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                
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
                                                window.location.href = '../AsignarCitaBarcaza?data=' + json;


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
