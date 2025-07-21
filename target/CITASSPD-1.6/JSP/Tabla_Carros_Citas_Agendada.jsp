<%-- 
    Document   : Tabla_Carros_Citas_Agendada
    Created on : jun 24, 2025, 8:03:58 a.m.
    Author     : braya
--%>

<%@page import="com.spd.CItasDB.ListaVehiculos"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.OffsetDateTime"%>
<%@page import="com.spd.Model.ListadoCItas"%>
<%@page import="java.util.List"%>
<%@page import="com.spd.Model.ResultadoCitas"%>
<%@page import="com.spd.DAO.ListadoDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listados Citas SPD</title>
    <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
    <link rel="stylesheet" href="../CSS/Login.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/2.3.2/css/dataTables.dataTables.css" />
    <script src="https://cdn.datatables.net/2.3.2/js/dataTables.js"></script>
    <script>
        $(document).ready(function () {
            $('#myTable').DataTable({
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
    boolean seccionIniciada = false;

    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if (cookie.getName().equals("SeccionIniciada")) {
                seccionIniciada = true;
            }
        }
    }

    if (!seccionIniciada) {
        response.sendRedirect(request.getContextPath());
    }
%>

<body>
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
            <input type="submit" value="LISTADOS DE CITAS" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="CERRAR SESIÓN" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>

    <div class="Content">
        <%
            String registro = request.getParameter("registro");
            ListadoDAO ldao = new ListadoDAO();
            
            ResultadoCitas rc = ldao.ObtenerContratos();
            
            List<ListadoCItas> ListadoCitas = rc.getCitasVehiculos2();

            if(ListadoCitas.isEmpty()){
        %>
            <h1>⚠ No hay Citas disponibles en este momento.</h1>
        <%
            } else {
        %>
            <h2>📋 Lista de Citas Por Registros Por Camiones</h2>
            <form id="formularioCitas">
                <table id="myTable" class="display">
                    <thead>
                        <tr>
                            <th>PLACA</th>
                            <th>CEDULA CONDUCTOR</th>
                            <th>NOMBRE CONDUCTOR</th>
                            <th>MANIFIESTO</th>
                            <th>ESTADO</th>
                            <th>FECHA</th>
                            <th>SELECCIONAR</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for(ListadoCItas listado : ListadoCitas){
                                String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal); // desde Java 8
                                LocalDateTime ldt = odt.toLocalDateTime();
                                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");

                                String fechaSinZona = ldt.format(formatter);
                                if (listado.getCodCita().equals(registro)) {
                        %>
                                        <tr style="display: none;">
                                            <td><%= listado.getPlaca() %></td>
                                            <td><%= listado.getCedConductor() %></td>
                                            <td><%= listado.getNomConductor() %></td>
                                            <td><%= listado.getManifiesto() %></td>
                                            <td>PROGRAMADA</td>
                                            <td><%= fechaSinZona %></td>
                                            <td>
                                                <input type="checkbox" name="vehiculos"
                                                       data-nombre="<%= listado.getNomConductor() %>"
                                                       data-cedula="<%= listado.getCedConductor() %>"
                                                       value="<%= listado.getPlaca() %>"
                                                       checked>
                                            </td>
                                        </tr>
                        <%
                                    List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                    if (vehiculos != null && !vehiculos.isEmpty()){
                                        for (ListaVehiculos vehiculo : vehiculos){
                                         if(vehiculo.getFechaOfertaSolicitud() == null || "null".equals(vehiculo.getFechaOfertaSolicitud())){
                                            System.out.println("className.methodName()");
                        %>
                            <tr>
                                <td><%= vehiculo.getVehiculoNumPlaca() %></td>
                                <td><%= vehiculo.getConductorCedulaCiudadania() %></td>
                                <td><%= vehiculo.getNombreConductor() %></td>
                                <td><%= vehiculo.getNumManifiestoCarga() %></td>
                                <td> PROGRAMADA </td>
                                <td><%= vehiculo.getFechaOfertaSolicitud() %></td>
                                <td>
                                    <input type="checkbox" name="vehiculos"
                                           data-nombre="<%= vehiculo.getNombreConductor() %>"
                                           data-cedula="<%= vehiculo.getConductorCedulaCiudadania() %>"
                                           value="<%= vehiculo.getVehiculoNumPlaca() %>">
                                </td>
                            </tr>
                        <%
                                        }}
                                    }
                                }
                            }
                        %>
                    </tbody>
                </table>
            </form>
            <div style="margin-top: 20px; width: auto; height: auto;" class="Botones_tabla">
                <%
                    Object rolObject1 = session.getAttribute("Rol");
                    if (rolObject1 != null && ((Integer) rolObject1) == 1)
                    {
                %>
                    <input type="button" 
                        onclick="abrirFormularioCitaMultiple()"
                        value="📋 Programar Cita a Seleccionados">
                <%
                    } else {
                %>
                    <input type="button" 
                        onclick="navegarInternamente('./Listados_Citas.jsp')"
                        value="⟵ Volver">
                <%
                    }
                %>
            </div>
        <%
            }
        %>
    </div>

    <script>
        function navegarInternamente(url) {
            sessionStorage.setItem("navegandoInternamente", "true");
            window.location.href = url;
        }

        function abrirFormularioCitaMultiple() {
            const allCheckboxes = document.querySelectorAll('input[name="vehiculos"]');
            const selectedCheckboxes = document.querySelectorAll('input[name="vehiculos"]:checked');

            if (allCheckboxes.length === 0) {
                Swal.fire('⚠ No hay vehículos disponibles para seleccionar');
                return;
            }

            if (selectedCheckboxes.length === 0) {
                Swal.fire('⚠ Debes seleccionar al menos un vehículo');
                return;
            }

            Swal.fire({
                title: '📋 Programar Cita (Múltiples)',
                html:
                    '<div style="display: flex; align-items: center; width: 100%; margin-bottom: 10px;">' +
                        '<label for="fechaCita" style="width: 150px; text-align: left;"><strong>Fecha de Cita:</strong></label>' +
                        '<input id="fechaCita" type="datetime-local" class="swal2-input" style="flex: 1;">' +
                    '</div>' +
                    '<div style="display: flex; align-items: center; width: 100%;">' +
                        '<label for="numeroformulario" style="width: 150px; text-align: left;"><strong>Número De Formulario Asignado:</strong></label>' +
                        '<input id="numeroformulario" type="text" class="swal2-input" style="flex: 1;" ' +
                        'pattern="\\d+" inputmode="numeric" oninput="this.value = this.value.replace(/\\D/g, \'\')" ' +
                        'placeholder="Solo números">' +
                    '</div>',
                confirmButtonText: 'Guardar',
                confirmButtonColor: '#28a745',
                cancelButtonText: 'Cancelar',
                showCancelButton: true,
                preConfirm: () => {
                    const fecha = document.getElementById('fechaCita').value;
                    const fmm = document.getElementById('numeroformulario').value;

                    if (!fecha) {
                        Swal.showValidationMessage('⚠ Debes seleccionar una fecha');
                        return false;
                    }
                    if (!fmm) {
                        Swal.showValidationMessage('⚠ Debes escribir el número del formulario');
                        return false;
                    }

                    return { fecha: fecha, fmm: fmm };
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    const { fecha, fmm } = result.value;
                    const seleccionados = [];

                    selectedCheckboxes.forEach(cb => {
                        seleccionados.push({
                            placa: cb.value,
                            nombre: cb.dataset.nombre,
                            cedula: cb.dataset.cedula
                        });
                    });

                    const json = encodeURIComponent(JSON.stringify(seleccionados));
                    const registro = '<%= registro %>';

                    window.location.href = '../AsignarCitaCamiones?vehiculos=' + json +
                                           '&fecha=' + encodeURIComponent(fecha + ":00-05:00") +
                                           '&fmm=' + encodeURIComponent(fmm) +
                                           '&registro=' + encodeURIComponent(registro);
                }
            });
        }

        // Cierre de pestaña o salir del sitio
        sessionStorage.setItem("ventanaActiva", "true");
        window.addEventListener("beforeunload", function (e) {
            const navEntry = performance.getEntriesByType("navigation")[0];
            if (navEntry && navEntry.type === "reload") return;
            if (sessionStorage.getItem("navegandoInternamente") === "true") return;

            if (sessionStorage.getItem("ventanaActiva") === "true") {
                sessionStorage.removeItem("ventanaActiva");
                sessionStorage.removeItem("navegandoInternamente");
                navigator.sendBeacon("../cerrarVentana", "");
            }
        });
    </script>
</body>
</html>
