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
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="Crear Usuario" onclick="navegarInternamente('./JSP/CrearUsuario.jsp')"/>
                <input type="submit" value="Listar Usuarios" onclick="navegarInternamente('./JSP/ListadoUsuarios.jsp')"/>
                <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/>
                
                <input type="submit" value="Reporte Carrotanques I/S" onclick="navegarInternamente('../ReporteCitasIngreSalida')"/>
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

<%
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
        // Crear un mapa para agrupar por NIT (compatible con Java 7)
        Map<String, List<CitaVehiculo>> agrupadoPorEmpresa = new LinkedHashMap<String, List<CitaVehiculo>>();

        for (CitaVehiculo cita : listaCitas) {
            String nit = cita.getNitempresaBas();
            if (nit == null || nit.isEmpty()) continue;

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
        %>
            <button class="tab-button <%= idx == 0 ? "active" : "" %>"
                    data-nit="<%= nit %>"
                    onclick="openTab(event, 'tab<%= nit.replaceAll("[^a-zA-Z0-9]", "") %>')">
                <span class="empresa" data-nit="<%= nit %>">Cargando...</span> (NIT: <%= nit %>)
            </button>
        <%
                idx++;
            }
        %>
    </div>

    <%
        int index = 0;
        for (Map.Entry<String, List<CitaVehiculo>> entry : agrupadoPorEmpresa.entrySet()) {
            String nit = entry.getKey();
            String tableId = "myTable" + nit.replaceAll("[^a-zA-Z0-9]", "");
            List<CitaVehiculo> citasEmpresa = entry.getValue();
    %>
        <div id="tab<%= nit.replaceAll("[^a-zA-Z0-9]", "") %>" 
             class="tab-content" 
             style="<%= (index == 0) ? "display:block;" : "" %>">
             
            <h2><span class="empresa" data-nit="<%= nit %>">Cargando...</span> – NIT: <%= nit %></h2>
            
            <table id="<%= tableId %>" class="display">
                <thead>
                    <tr>
                        <th>Placa</th>
                        <th>Cédula</th>
                        <th>Nombre del Conductor</th>
                        <th>Manifiesto</th>
                        <th>Operación</th>
                        <th>Tanque</th>
                        <th>Barcaza</th>
                        <th>Código de Cita</th>
                        <th>Fecha de Cita</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        for (CitaVehiculo cita : citasEmpresa) { 
                    %>
                        <tr>
                            <td><%= cita.getPlaca() %></td>
                            <td><%= cita.getCedula() %></td>
                            <td><%= cita.getNombre() %></td>
                            <td><%= cita.getManifiesto() %></td>
                            <td>
                                <%
                                    String operacion = cita.getOperacion() != null ? cita.getOperacion().toLowerCase() : "";
                                    String descripcion = "";
                                    
                                    if ("operacion de cargue".equals(operacion)) {
                                        if (cita.getTanque() == null || cita.getTanque().isEmpty()) {
                                            descripcion = "barcaza - carrotanque";
                                        } else if (cita.getBarcaza() == null || cita.getBarcaza().isEmpty()) {
                                            descripcion = "tanque - carrotanque";
                                        }
                                    } else {
                                        if (cita.getTanque() == null || cita.getTanque().isEmpty()) {
                                            descripcion = "carrotanque - barcaza";
                                        } else if (cita.getBarcaza() == null || cita.getBarcaza().isEmpty()) {
                                            descripcion = "carrotanque - tanque";
                                        }
                                    }
                                %>
                                <%= descripcion %>
                            </td>
                            <td><%= (cita.getTanque() != null) ? cita.getTanque() : "" %></td>
                            <td><%= (cita.getBarcaza() != null) ? cita.getBarcaza() : "" %></td>
                            <td><%= cita.getCodCita() %></td>
                            <td><%= cita.getFechacita() %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <%
            index++;
        } // fin for
    %>

    <div style="margin-top:15px;">
        <input type="submit"
               onclick="navegarInternamente('./ReporteCitasDiarias')"
               value="Descargar Reporte"
               style="background-color:#89b61f;border:none;padding:5px 10px;border-radius:5px;cursor:pointer;">
    </div>
</div>

<%
    } // fin else
%>

<!-- ✅ Script dinámico para cargar nombres de empresas desde el servlet y cachearlos -->
<script>
async function cargarEmpresas() {
    const spans = document.querySelectorAll(".empresa[data-nit]");
    let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
    let nuevos = 0;

    for (const span of spans) {
        const nit = span.dataset.nit.trim();
        if (!nit) continue;

        // Usa el nombre cacheado si existe
        if (cacheClientes[nit]) {
            span.textContent = cacheClientes[nit];
            continue;
        }

        try {
            const res = await fetch('./ObtenerCLientes?nit='+encodeURIComponent(nit));
            if (!res.ok) throw new Error("Error HTTP " + res.status);
            const data = await res.json();
            let nombre = "Empresa desconocida";

            if (data && data.length > 0) nombre = data[0].Nombre || "Sin nombre";
            span.textContent = nombre;
            cacheClientes[nit] = nombre;
            nuevos++;

        } catch (err) {
            console.error("❌ Error consultando empresa:", err);
            span.textContent = "Error";
        }
    }

    // Guarda caché actualizado
    if (nuevos > 0)
        localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
}

// Cargar nombres al iniciar
document.addEventListener("DOMContentLoaded", cargarEmpresas);


</script>

</body>

</html>
