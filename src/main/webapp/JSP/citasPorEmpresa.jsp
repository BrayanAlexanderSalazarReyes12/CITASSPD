<%-- 
    Document   : citasPorEmpresa
    Created on : 30/09/2025, 11:50:36 AM
    Author     : Brayan Salazar
--%>

<%@page import="java.nio.charset.StandardCharsets"%>
<%@page import="java.net.URLDecoder"%>
<%@page import="java.util.*"%>
<%@page import="com.spd.citas.vehiculos.CitaVehiculo"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

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
    <meta charset="UTF-8">
    <title>Citas por Empresa</title>
    
    <link rel="stylesheet" href="./CSS/Listado_Citas.css"/>
    <link rel="stylesheet" href="./CSS/Login.css"/>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <!-- DataTables -->
    <link rel="stylesheet" href="https://cdn.datatables.net/2.3.2/css/dataTables.dataTables.css" />
    <script src="https://cdn.datatables.net/2.3.2/js/dataTables.js"></script>

    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
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
    </style>

    <script>
        function openTab(evt, tabId) {
            var i, tabcontent, tabbuttons;

            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
            }

            tabbuttons = document.getElementsByClassName("tab-button");
            for (i = 0; i < tabbuttons.length; i++) {
                tabbuttons[i].className = tabbuttons[i].className.replace(" active", "");
            }

            document.getElementById(tabId).style.display = "block";
            evt.currentTarget.className += " active";
        }

        $(document).ready(function () {
            // Inicializar DataTables en cada tabla
            $('table[id^="myTable"]').each(function () {
                $(this).DataTable({
                    scrollY: 400,
                    pageLength: 50,
                    language: {
                        url: "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json"
                    }
                });
            });

            // Mostrar la primera pestaña
            var firstTab = document.querySelector(".tab-button");
            if (firstTab) {
                firstTab.click();
            }
        });
    </script>
</head>

<%
        Cookie[] cookies = request.getCookies();
        response.setContentType("text/html");
        String usuario = "";
        String DATA = "";
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
                    DATA = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8.name());
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
            <input type="submit" value="Inicio" onclick="navegarInternamente('https://spdique.com/')"/>
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="Crear Usuario" onclick="navegarInternamente('./JSP/CrearUsuario.jsp')"/>
                <input type="submit" value="Listar Usuarios" onclick="navegarInternamente('./JSP/ListadoUsuarios.jsp')"/>
                <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/>
            <%
                } else if (rolObj != null && ((Integer) rolObj) != 5 && ((Integer) rolObj) != 7){
            %>
                <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('./JSP/OperacionesActivas.jsp')">
            <%
                }
            %>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='./CerrarSeccion'"/>
        </div>
    </header>

<body>

<h1>Listado de Citas por Empresa</h1>

<%! 
    // Clase Cliente simple
    public static class Cliente {
        private String nit;
        private String nombre;

        public Cliente(String nit, String nombre) {
            this.nit = nit;
            this.nombre = nombre;
        }

        public String getNit() { return nit; }
        public String getNombre() { return nombre; }
    }

    // Buscar nombre de cliente por NIT
    public String getNombreCliente(String nit, List<Cliente> clientes) {
        for (Cliente c : clientes) {
            if (c.getNit().equals(nit)) {
                return c.getNombre();
            }
        }
        return "Empresa Desconocida";
    }
%>

<%
    // Lista de clientes (ideal mover a repositorio/DB)
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
        new Cliente("901.312.9603", "C I CONQUERS WORLD TRADE S A S"),
        new Cliente("9018263370", "CONQUERS ZF")
    );

    List<CitaVehiculo> listaCitas = (List<CitaVehiculo>) request.getAttribute("listaCitas");

    if (listaCitas == null || listaCitas.isEmpty()) {
%>
    <script>
        Swal.fire({
            icon: 'info',
            title: 'Sin datos',
            text: 'No hay citas registradas para hoy.'
        });
    </script>
<%
    } else {
        // Agrupar por NIT
        Map<String, List<CitaVehiculo>> agrupadoPorEmpresa = new LinkedHashMap<String, List<CitaVehiculo>>();
        for (CitaVehiculo cita : listaCitas) {
            String nit = cita.getNitempresaBas();
            List<CitaVehiculo> lista = agrupadoPorEmpresa.get(nit);
            if (lista == null) {
                lista = new ArrayList<CitaVehiculo>();
                agrupadoPorEmpresa.put(nit, lista);
            }
            lista.add(cita);
        }
%>

<div class="tab-container">
    <div class="tab-header">
        <%
            int idx = 0;
            for (Map.Entry<String, List<CitaVehiculo>> entry : agrupadoPorEmpresa.entrySet()) {
                String nit = entry.getKey();
                String nombreEmpresa = getNombreCliente(nit, clientes);
        %>
            <button class="tab-button <%= idx == 0 ? "active" : "" %>"
                    onclick="openTab(event, 'tab<%= nit.replaceAll("[^a-zA-Z0-9]", "") %>')">
                <%= nombreEmpresa %> (NIT: <%= nit %>)
            </button>
        <%
                idx++;
            }
        %>
    </div>

    <%
        for (Map.Entry<String, List<CitaVehiculo>> entry : agrupadoPorEmpresa.entrySet()) {
            String nit = entry.getKey();
            String nombreEmpresa = getNombreCliente(nit, clientes);
            String tableId = "myTable" + nit.replaceAll("[^a-zA-Z0-9]", "");
            List<CitaVehiculo> citasEmpresa = entry.getValue();
    %>
        <div id="tab<%= nit.replaceAll("[^a-zA-Z0-9]", "") %>" class="tab-content">
            <h2><%= nombreEmpresa %> – NIT: <%= nit %></h2>
            <table id="<%= tableId %>" class="display">
                <thead>
                    <tr>
                        <th>Placa</th>
                        <th>Cédula</th>
                        <th>Nombre del Conductor</th>
                        <th>Manifiesto</th>
                        <th>Código de Cita</th>
                        <th>Fecha de Cita</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (CitaVehiculo cita : citasEmpresa) { %>
                        <tr>
                            <td><%= cita.getPlaca() %></td>
                            <td><%= cita.getCedula() %></td>
                            <td><%= cita.getNombre() %></td>
                            <td><%= cita.getManifiesto() %></td>
                            <td><%= cita.getCodCita() %></td>
                            <td><%= cita.getFechacita() %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <%
        }
    %>
</div>
<%
    } // Fin else
%>

</body>
</html>
