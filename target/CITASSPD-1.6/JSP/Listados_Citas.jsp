<%-- 
    Document   : Listados_Citas
    Created on : abr 7, 2025, 9:56:47 a.m.
    Author     : braya
--%>

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
            navigator.sendBeacon("../cerrarVentana", "");
        }
    });</script>

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
                ['#myTable', '#myTable2', '#myTable3', '#myTable4'].forEach(function (id) {
        $(id).DataTable({
            scrollY: 400,
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
                } else if (rolObj != null && ((Integer) rolObj) != 5){
            %>
                <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
            <%
                }
            %>
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>
    <body>
        <div>
                <%
                    ListadoDAO ldao = new ListadoDAO();
                    ResultadoCitas rc = ldao.ObtenerContratos();
                    List<ListadoCItas> ListadoCitas = rc.getCitasVehiculos();
                    List<ListadoCItas> ListadoCitas2 = rc.getCitasVehiculos2();
                    List<ListadoCitasBar> listadoCitasBars = rc.getCitasBarcazas();
                    
                    if(ListadoCitas.isEmpty() && listadoCitasBars.isEmpty() && ListadoCitas2.isEmpty()){
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
                                            if (rolObj != null && ((Integer) rolObj) != 5) {
                                        %>
                                            <button class="tab-button active" data-tab="camiones" onclick="mostrarTab(this)">📁 Citas camiones</button>
                                        <%
                                            }if (rolObj != null && ((Integer) rolObj) != 0 && ((Integer) rolObj) != 2 && ((Integer) rolObj) != 5) {
                                        %>
                                            <button class="tab-button" data-tab="camiones-por-finalizar" onclick="mostrarTab(this)">📁 Citas camiones por finalizar</button>
                                            <button class="tab-button" data-tab="barcazas" onclick="mostrarTab(this)">📁 Citas barcazas</button>
                                        <%
                                            }else if (rolObj != null && ((Integer) rolObj) == 2 ){
                                        %>
                                            <button class="tab-button" data-tab="camiones-por-finalizar" onclick="mostrarTab(this)">📁 Citas camiones aprobadas</button>
                                            <button class="tab-button" data-tab="barcazas" onclick="mostrarTab(this)">📁 Citas barcazas</button>
                                        <%
                                            }else if (rolObj != null && ((Integer) rolObj) == 5) { 
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
                                                    
                                                    String nit_final = nit.replaceAll("[^0-9]", "");
                                                    
                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                    List<Cliente> clientes = Arrays.asList(
                                                        new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                        new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                        new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                        new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                        new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                        new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                        new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                        new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                        new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                        new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                        new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                        new Cliente("9018263370", "CONQUERS ZF")
                                                    );
                                                    
                                                    String empresaUsuario = null;

                                                    // Buscar la empresa asociada al NIT
                                                    for (Cliente cliente : clientes) {
                                                        if (cliente.getNit().equals(listado.getNit())) {
                                                            empresaUsuario = cliente.getEmpresa();
                                                            break;
                                                        }
                                                    }
                                                    System.out.println("empresa: " + empresaUsuario);
                                                    
                                                    System.out.println(listado.getNit() + " " + nit_final);
                                                
                                                    // Convertir a OffsetDateTime (zona UTC, puedes cambiar el offset si deseas)
                                                    OffsetDateTime offsetDateTime = Instant.ofEpochMilli(listado.getFeAprobacion()).atOffset(ZoneOffset.UTC);

                                                    // Obtener LocalDate
                                                    LocalDate fechaCita = offsetDateTime.toLocalDate();

                                                    // Formatear con fecha y hora
                                                    String fechaConHora = offsetDateTime.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

                                                    if (fechaCita.equals(hoy)) {
                                                        boolean mostrar = filtro == null || 
                                                            (listado.getPlaca() != null && listado.getPlaca().toLowerCase().contains(filtro)) ||
                                                            (listado.getManifiesto() != null && listado.getManifiesto().toLowerCase().contains(filtro));

                                                        if (mostrar) {
                                            %>
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
                                                                // Formatear sin la T
                                                                String fechaFormateada = fechaVehiculo.format(DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm"));
                                                                System.out.println(fechaFormateada);
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
                                                <td><%= empresaUsuario %></td>
                                                <td><%= fechaFormateada %></td>
                                                <td id="<%= listado.getFmm() %>">
                                                    <%= listado.getFmm() %>
                                                </td>
                                                <td><button onclick="copiarTexto('<%= listado.getFmm() %>')">📋</button></td>
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
                                            } else if (rol == 2) {
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
                                                    
                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                    List<Cliente> clientes = Arrays.asList(
                                                        new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                        new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                        new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                        new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                        new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                        new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                        new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                        new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                        new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                        new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                        new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                        new Cliente("9018263370", "CONQUERS ZF")
                                                    );
                                                    
                                                    String empresaUsuario = null;

                                                    // Buscar la empresa asociada al NIT
                                                    for (Cliente cliente : clientes) {
                                                        if (cliente.getNit().equals(listado.getNit())) {
                                                            empresaUsuario = cliente.getEmpresa();
                                                            break;
                                                        }
                                                    }
                                                    System.out.println("empresa: " + empresaUsuario);
                                                    
                                                    System.out.println(listado.getNit() + " " + nit_final);
                                                    if (listado.getNit().equals(nit_final)) {
                                                        OffsetDateTime odt = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                        String fechaSinZona = odt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                                                        
                                            %>
                                            <tr>
                                                <td><%= listado.getCodCita() %></td>
                                                <td><%= empresaUsuario %></td>
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
                                            %>
                                        </tbody>
                                    </table>

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
                                                
                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                    List<Cliente> clientes = Arrays.asList(
                                                        new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                        new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                        new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                        new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                        new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                        new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                        new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                        new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                        new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                        new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                        new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                        new Cliente("9018263370", "CONQUERS ZF")
                                                    );
                                                    
                                                    String empresaUsuario = null;

                                                    // Buscar la empresa asociada al NIT
                                                    for (Cliente cliente : clientes) {
                                                        if (cliente.getNit().equals(listado.getNit())) {
                                                            empresaUsuario = cliente.getEmpresa();
                                                            break;
                                                        }
                                                    }
                                                    String fechaCreacion = listado.getFecha_Creacion_Cita();
                                                    if (fechaCreacion != null && !fechaCreacion.isEmpty()) {
                                                        OffsetDateTime odt = OffsetDateTime.parse(listado.getFecha_Creacion_Cita());
                                                        String fechaSinZona = odt.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
                                                    
                                                    
                                            %>
                                            <tr>
                                                <td><%= listado.getCodCita() %></td>
                                                <td><%= empresaUsuario %></td>
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
                                                }}
                                            %>
                                        </tbody>
                                    </table>
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
                                                                if (listado.getNit().equals(nit_final))
                                                                {
                                                                
                                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                                    List<Cliente> clientes = Arrays.asList(
                                                                        new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                                        new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                                        new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                                        new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                                        new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                                        new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                                        new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                                        new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                                        new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                                        new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                                        new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                                        new Cliente("9018263370", "CONQUERS ZF")
                                                                    );

                                                                    String empresaUsuario = null;

                                                                    // Buscar la empresa asociada al NIT
                                                                    for (Cliente cliente : clientes) {
                                                                        if (cliente.getNit().equals(listado.getNit())) {
                                                                            empresaUsuario = cliente.getEmpresa();
                                                                            break;
                                                                        }
                                                                    }
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
                                                                    
                                                                    if (fecha.equals(fechaactual)) {

                                                %>
                                                <tr>
                                                    <td><%= listado.getCodCita() %></td>
                                                    <td><%= empresaUsuario %></td>
                                                    <td><%= listado.getTipo_Operacion() %></td>
                                                    <td><%= listado.getCantidad_Vehiculos() %></td>
                                                    <td><%= fechaSinZona %></td>
                                                    <td>
                                                        <div class="Botones_tabla">
                                                            <input type="button"
                                                                   onclick="window.location.href='../JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                   value="📋 Ver">
                                                        </div>
                                                    </td>
                                                </tr>
                                                <%
                                                    }}}} else if (rolObj != null && ((Integer) rolObj) == 1){
                                                %>
                                                        <%
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                    
                                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                                    List<Cliente> clientes = Arrays.asList(
                                                                        new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                                        new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                                        new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                                        new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                                        new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                                        new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                                        new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                                        new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                                        new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                                        new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                                        new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                                        new Cliente("9018263370", "CONQUERS ZF")
                                                                    );

                                                                    String empresaUsuario = null;

                                                                    // Buscar la empresa asociada al NIT
                                                                    for (Cliente cliente : clientes) {
                                                                        if (cliente.getNit().equals(listado.getNit())) {
                                                                            empresaUsuario = cliente.getEmpresa();
                                                                            break;
                                                                        }
                                                                    }
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
                                                                            <td><%= listado.getCodCita() %></td>
                                                                            <td><%= empresaUsuario %></td>
                                                                            <td><%= listado.getTipo_Operacion() %></td>
                                                                            <td><%= listado.getCantidad_Vehiculos() %></td>
                                                                            <td><%= fechaSinZona %></td>
                                                                            <td>
                                                                                <div class="Botones_tabla">
                                                                                    <input type="button"
                                                                                           onclick="window.location.href='../JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                                           value="📋 Ver">
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
                                                    if (rolObj != null && ((Integer) rolObj) == 2){
                                                 
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                String nit_final = nit.replaceAll("[^0-9]", "");
                                                                // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                                   List<Cliente> clientes = Arrays.asList(
                                                                       new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                                       new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                                       new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                                       new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                                       new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                                       new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                                       new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                                       new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                                       new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                                       new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                                       new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                                       new Cliente("9018263370", "CONQUERS ZF")
                                                                   );

                                                                   String empresaUsuario = null;

                                                                   // Buscar la empresa asociada al NIT
                                                                   for (Cliente cliente : clientes) {
                                                                       if (cliente.getNit().equals(listado.getNit())) {
                                                                           empresaUsuario = cliente.getEmpresa();
                                                                           break;
                                                                       }
                                                                   }
                                                                if (listado.getNit().equals(nit_final))
                                                                {
                                                                    
                                                                    System.out.println(listado.getNit() + " " + nit_final);
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
                                                                    

                                                %>
                                                <tr>
                                                    <td><%= listado.getCodCita() %></td>
                                                    <td><%= empresaUsuario %></td>
                                                    <td><%= listado.getTipo_Operacion() %></td>
                                                    <td><%= listado.getCantidad_Vehiculos() %></td>
                                                    <td><%= fechaSinZona %></td>
                                                    <td>
                                                        <div class="Botones_tabla">
                                                            <input type="button"
                                                                   onclick="window.location.href='../JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                   value="📋 Ver">
                                                        </div>
                                                    </td>
                                                </tr>
                                                <%
                                                    }}} else if (rolObj != null && ((Integer) rolObj) == 1){
                                                %>
                                                        <%
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                                   List<Cliente> clientes = Arrays.asList(
                                                                       new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                                       new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                                       new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                                       new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                                       new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                                       new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                                       new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                                       new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                                       new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                                       new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                                       new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                                       new Cliente("9018263370", "CONQUERS ZF")
                                                                   );

                                                                   String empresaUsuario = null;

                                                                   // Buscar la empresa asociada al NIT
                                                                   for (Cliente cliente : clientes) {
                                                                       if (cliente.getNit().equals(listado.getNit())) {
                                                                           empresaUsuario = cliente.getEmpresa();
                                                                           break;
                                                                       }
                                                                   }
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
                                                                            <td><%= empresaUsuario %></td>
                                                                            <td><%= listado.getTipo_Operacion() %></td>
                                                                            <td><%= listado.getCantidad_Vehiculos() %></td>
                                                                            <td><%= fechaSinZona %></td>
                                                                            <td>
                                                                                <div class="Botones_tabla">
                                                                                    <input type="button"
                                                                                           onclick="window.location.href='../JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                                           value="📋 Ver">
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
                                                    if (rolObj != null && ((Integer) rolObj) == 5){
                                                 
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                String nit_final = nit.replace("-", "");
                                                                // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                                   List<Cliente> clientes = Arrays.asList(
                                                                       new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                                       new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                                       new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                                       new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                                       new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                                       new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                                       new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                                       new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                                       new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                                       new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                                       new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                                       new Cliente("9018263370", "CONQUERS ZF")
                                                                   );

                                                                   String empresaUsuario = null;

                                                                   // Buscar la empresa asociada al NIT
                                                                   for (Cliente cliente : clientes) {
                                                                       if (cliente.getNit().equals(listado.getNit())) {
                                                                           empresaUsuario = cliente.getEmpresa();
                                                                           break;
                                                                       }
                                                                   }
                                                                System.out.println(listado.getNit_Empresa_Transportadora() + " " + nit_final);
                                                                if (listado.getNit_Empresa_Transportadora().equals(nit_final) && listado.getEstado().equals("AGENDADA"))
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
                                                                    
                                                                    

                                                %>
                                                <tr>
                                                    <td><%= listado.getCodCita() %></td>
                                                    <td><%= empresaUsuario %></td>
                                                    <td><%= listado.getTipo_Operacion() %></td>
                                                    <td><%= listado.getCantidad_Vehiculos() %></td>
                                                    <td><%= fechaSinZona %></td>
                                                    <td>
                                                        <div class="Botones_tabla">
                                                            <input type="button"
                                                                   onclick="window.location.href='../JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                   value="📋 Ver">
                                                        </div>
                                                    </td>
                                                </tr>
                                                <%
                                                    }}} else if (rolObj != null && ((Integer) rolObj) == 1){
                                                %>
                                                        <%
                                                            for(ListadoCItas listado: ListadoCitas2){
                                                                    // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
                                                                   List<Cliente> clientes = Arrays.asList(
                                                                       new Cliente("9003289140", "C I CARIBBEAN BUNKERS S A S"),
                                                                       new Cliente("9006144232", "ATLANTIC MARINE FUELS S A S C I"),
                                                                       new Cliente("8060058263", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
                                                                       new Cliente("9013129603", "C I CONQUERS WORLD TRADE S A S (CWT)"),
                                                                       new Cliente("9012220501", "C I FUELS AND BUNKERS COLOMBIA S A S"),
                                                                       new Cliente("8020240114", "C I INTERNATIONAL FUELS S A S"),
                                                                       new Cliente("9011235498", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
                                                                       new Cliente("8060053461", "OPERACIONES TECNICAS MARINAS S A S"),
                                                                       new Cliente("8190016678", "PETROLEOS DEL MILENIO S A S"),
                                                                       new Cliente("9009922813", "C I PRODEXPORT DE COLOMBIA S A S"),
                                                                       new Cliente("8904057693", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
                                                                       new Cliente("9018263370", "CONQUERS ZF")
                                                                   );

                                                                   String empresaUsuario = null;

                                                                   // Buscar la empresa asociada al NIT
                                                                   for (Cliente cliente : clientes) {
                                                                       if (cliente.getNit().equals(listado.getNit())) {
                                                                           empresaUsuario = cliente.getEmpresa();
                                                                           break;
                                                                       }
                                                                   }
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
                                                                            <td><%= empresaUsuario %></td>
                                                                            <td><%= listado.getTipo_Operacion() %></td>
                                                                            <td><%= listado.getCantidad_Vehiculos() %></td>
                                                                            <td><%= fechaSinZona %></td>
                                                                            <td>
                                                                                <div class="Botones_tabla">
                                                                                    <input type="button"
                                                                                           onclick="window.location.href='../JSP/CitaCamionesPorFinalizar.jsp?registro=<%= listado.getCodCita() %>&rol=<%= ((Integer) rolObj) %>'"
                                                                                           value="📋 Ver">
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