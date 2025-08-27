<%-- 
    Document   : CitaCamionesPorFinalizar
    Created on : 21/07/2025, 11:31:55 AM
    Author     : Brayan Salazar
--%>

<%@page import="java.sql.Date"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.spd.informacionCita.CitaInfo"%>
<%@page import="com.spd.informacionCita.InformacionPesajeFinalizacionCIta"%>
<%@page import="java.util.Locale"%>
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
    <meta charset="UTF-8">
    <title>Listados citas a finalizar SPD</title>
    <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
    <link rel="stylesheet" href="../CSS/Login.css"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/2.3.2/css/dataTables.dataTables.css" />
    <script src="https://cdn.datatables.net/2.3.2/js/dataTables.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
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
        int operacion;
        String fecha_final_estado = "";
        java.sql.Timestamp fecha_pesaje_entreda_bascula = null;
        java.sql.Timestamp fecha_pesaje_salida_bascula = null;
        String peso_entrada_bascula = "";
        String peso_salida_bascula = "";
        String fechaParaInput_en_bas = "";
        String fechaParInput_sal_bas = "";
        
        List<String> placas = new ArrayList<String>();
        List<String> Cedulas = new ArrayList<String>();
        Date fechabus = null;
    %>
    <body>
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
                    }else if (rolObj != null && ((Integer) rolObj) != 5) {
                %>
                <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
                <%
                    }
                %>
                <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
                <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
                
            </div>
        </header>
        <div>
            <style>
                .content-container {
                    max-width: 1200px; /* puedes ajustarlo a 100%, 90vw, etc. */
                    margin: 0 auto;
                    padding: 20px;
                    background-color: #f4f4f4;
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
            <div class="content-container">
            <%
                String registro = request.getParameter("registro");
                String rol = request.getParameter("rol");
                ListadoDAO ldao = new ListadoDAO();

                ResultadoCitas rc = ldao.ObtenerContratos();

                List<ListadoCItas> ListadoCitas = rc.getCitasVehiculos2();

                if(rol.equals("1"))
                {
                
                if(ListadoCitas.isEmpty()){
            %>
                <h1>⚠ No hay Citas disponibles en este momento.</h1>
            <%
                } else {
            %>
                <h2>📋 Lista de citas a finalizar por registros de camiones</h2>
                <form id="formularioCitas">
                    <table id="myTable" class="display">
                        <thead>
                            <tr>
                                <th>Tipo operación</th>
                                <th>Empresa transportadora</th>
                                <th>Placa</th>
                                <th>Cédula conductor</th>
                                <th>Nombre conductor</th>
                                <th>Manifiesto</th>
                                <th>Estado</th>
                                <th>Fecha cita programada</th>
                                <% if(rolObj != null && ((Integer) rolObj) == 1) { %>
                                    <th>Cancelar</th>
                                    <th>Selecionar</th>
                                <% System.out.println(rolObj);} %>
                            </tr>
                        </thead>

                        <tbody>
                            <%
                                for(ListadoCItas listado : ListadoCitas){
                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal); // desde Java 8
                                    LocalDateTime ldt = odt.toLocalDateTime();
                                    fechabus = java.sql.Date.valueOf(ldt.toLocalDate());
                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                    DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
                                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");

                                    String fechaSinZona = ldt.format(formatter);
                                    String fechaSinZona2 = ldt.format(formatter2);
                                    
                                    if (listado.getCodCita().equals(registro)) {
                                    
                                        if ("operacion de cargue".equals(listado.getTipo_Operacion())){
                                            operacion = 1;
                                        }else {
                                            operacion = 2;
                                        }
                                        System.out.println(listado.getPlaca());
                                        List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                        if (vehiculos != null && !vehiculos.isEmpty()){
                                            for (ListaVehiculos vehiculo : vehiculos){
                                             if(vehiculo.getFechaOfertaSolicitud() != null){
                                              placas.add(vehiculo.getVehiculoNumPlaca());
                                              Cedulas.add(vehiculo.getConductorCedulaCiudadania());
                            %>
                                <tr>
                                    <td><%= listado.getTipo_Operacion() %></td>
                                    <td><%= listado.getNit_Empresa_Transportadora() %></td>
                                    <td><%= vehiculo.getVehiculoNumPlaca() %></td>
                                    <td><%= vehiculo.getConductorCedulaCiudadania() %></td>
                                    <td><%= vehiculo.getNombreConductor() %></td>
                                    <td><%= vehiculo.getNumManifiestoCarga() %></td>
                                    <td> <%= listado.getEstado() %> </td>
                                    <td><%= vehiculo.getFechaOfertaSolicitud() %></td>
                                    <%
                                        String formattedDate = "";
                                        try {
                                            String originalDate = vehiculo.getFechaOfertaSolicitud(); // Ejemplo: "Jul 25, 2025 2:21:00 PM"

                                            // Formato original
                                            DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy h:mm:ss a", Locale.ENGLISH);

                                            // Formato deseado
                                            DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd h:mm:ss a", Locale.ENGLISH);

                                            // Parsear y formatear
                                            LocalDateTime date = LocalDateTime.parse(originalDate, inputFormatter);
                                            formattedDate = date.format(outputFormatter);
                                        } catch (Exception e) {
                                            formattedDate = "Fecha inválida";
                                        }

                                        //System.out.println(formattedDate); // Salida: 2025-07-22T10:40:00
                                    %>
                                    <% if(rolObj != null && ((Integer) rolObj) == 1) { %>
                                    <td>
                                        <input type="button" 
                                        onclick="cancelarCita(
                                            '<%= listado.getCodCita() %>',
                                            '<%= listado.getNit_Empresa_Transportadora() %>',
                                            '<%= vehiculo.getVehiculoNumPlaca() %>',
                                            '<%= vehiculo.getConductorCedulaCiudadania() %>',
                                            '<%= fechaSinZona %>',
                                            '<%= operacion %>',
                                            '<%= registro %>',
                                            '<%= vehiculo.getNumManifiestoCarga() %>'
                                        )"
                                        value="🗑 Cancelar">
                                    </td>
                                    <% } %>
                                    <%
                                        fecha_final_estado = fechaSinZona;
                                    %>
                                    <td>
                                        <input type="checkbox" name="vehiculos"
                                               data-operacion="<%= listado.getTipo_Operacion() %>"
                                               data-transportadora="<%= listado.getNit_Empresa_Transportadora() %>"
                                               data-nombre="<%= vehiculo.getNombreConductor() %>"
                                               data-cedula="<%= vehiculo.getConductorCedulaCiudadania() %>"
                                               data-manifiesto="<%= vehiculo.getNumManifiestoCarga() %>"
                                               value="<%= vehiculo.getVehiculoNumPlaca() %>"
                                               data-fecha="<%= formattedDate %>"
                                               data-nombreconductor="<%= vehiculo.getNombreConductor() %>"
                                               data-formulario="<%= listado.getFmm() %>"
                                               data-rol="<%= rol %>"
                                               data-fechacreacion="<%= listado.getFecha_Creacion_Cita() %>">
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
                            value="📋 Finalizar cita a los carro tanques seleccionados">
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
                }}else{
                    if(ListadoCitas.isEmpty()){
            %>
                <h1>⚠ No hay Citas disponibles en este momento.</h1>
            <%
                } else {
            %>
                <h2>📋 Lista de citas a finalizar por registros de camiones</h2>
                <form id="formularioCitas">
                    <table id="myTable" class="display">
                        <thead>
                            <tr>
                                <th>Tipo operación</th>
                                <th>Empresa transportadora</th>
                                <th>Placa</th>
                                <th>Cédula conductor</th>
                                <th>Nombre conductor</th>
                                <th>Manifiesto</th>
                                <th>Estado</th>
                                <th>Fecha cita programada</th>
                            </tr>
                        </thead>

                        <tbody>
                            <%
                                for(ListadoCItas listado : ListadoCitas){
                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal); // desde Java 8
                                    LocalDateTime ldt = odt.toLocalDateTime();
                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                    DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
                                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");

                                    String fechaSinZona = ldt.format(formatter);
                                    String fechaSinZona2 = ldt.format(formatter2);
                                    
                                    if (listado.getCodCita().equals(registro)) {
                                        System.out.println(listado.getPlaca());
                                        List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                        if (vehiculos != null && !vehiculos.isEmpty()){
                                            for (ListaVehiculos vehiculo : vehiculos){
                                             if(vehiculo.getFechaOfertaSolicitud() != null ){
                            %>
                                <tr>
                                    <td><%= listado.getTipo_Operacion() %></td>
                                    <td><%= listado.getNit_Empresa_Transportadora() %></td>
                                    <td><%= vehiculo.getVehiculoNumPlaca() %></td>
                                    <td><%= vehiculo.getConductorCedulaCiudadania() %></td>
                                    <td><%= vehiculo.getNombreConductor() %></td>
                                    <td><%= vehiculo.getNumManifiestoCarga() %></td>
                                    <td> <%= listado.getEstado() %> </td>
                                    <td><%= vehiculo.getFechaOfertaSolicitud() %></td>
                                    <%
                                        String formattedDate = "";
                                        try {
                                            String originalDate = vehiculo.getFechaOfertaSolicitud(); // Ejemplo: "Jul 25, 2025 2:21:00 PM"

                                            // Formato original
                                            DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy h:mm:ss a", Locale.ENGLISH);

                                            // Formato deseado
                                            DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd h:mm:ss a", Locale.ENGLISH);

                                            // Parsear y formatear
                                            LocalDateTime date = LocalDateTime.parse(originalDate, inputFormatter);
                                            formattedDate = date.format(outputFormatter);
                                        } catch (Exception e) {
                                            formattedDate = "Fecha inválida";
                                        }

                                        //System.out.println(formattedDate); // Salida: 2025-07-22T10:40:00
                                    %>
                                    
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
                            value="📋 Finalizar cita a los carro tanques seleccionados">
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
                }}
            %>
            </div>
        </div>
    </body>
    
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

            if (selectedCheckboxes.length !== 1) {
                Swal.fire('⚠ Debes seleccionar solo un vehículo');
                return;
            }

            // Solo un vehículo → tomamos el primero
            const cb = selectedCheckboxes[0];
            const placa = cb.value;
            const fecha = cb.dataset.fechacreacion;
            const cedula = cb.dataset.cedula;
            
            console.log(fecha);
            
            // Consultar datos del servidor
            axios.get('../FinalizarcitaInfo', {
                params: { placa, fecha, cedula }
            })
            .then(response => {
                const info = response.data;
                console.log("Datos recibidos del servidor:", info);

                // Inicializar valores por defecto
                let fechaEntradaBas = "";
                let fechaSalidaBas = "";
                let pesoEntradaBas = "";
                let pesoSalidaBas = "";

                if (info.length > 0) {
                    const cita = info[0];
                    fechaEntradaBas = cita.fechaEntrada || "";
                    fechaSalidaBas  = cita.fechaSalida  || "";
                    pesoEntradaBas  = cita.pesoIngreso ? String(cita.pesoIngreso) : "";
                    pesoSalidaBas   = cita.pesoSalida  ? String(cita.pesoSalida)  : "";
                }
                
                // Convertir strings a objetos Date
                let fechaEntradaDATE = new Date(fechaEntradaBas);
                let fechaSalidaDATE = new Date(fechaSalidaBas);
                
                // Formatear fechaEntrada
                let fechaEntradaBas_fin = fechaEntradaDATE.getFullYear() + "-" +
                                      String(fechaEntradaDATE.getMonth() + 1).padStart(2, '0') + "-" +
                                      String(fechaEntradaDATE.getDate()).padStart(2, '0') + "T" +
                                      String(fechaEntradaDATE.getHours()).padStart(2, '0') + ":" +
                                      String(fechaEntradaDATE.getMinutes()).padStart(2, '0');

                // Formatear fechaSalida
                let fechaSalidaBas_fin = fechaSalidaDATE.getFullYear() + "-" +
                                     String(fechaSalidaDATE.getMonth() + 1).padStart(2, '0') + "-" +
                                     String(fechaSalidaDATE.getDate()).padStart(2, '0') + "T" +
                                     String(fechaSalidaDATE.getHours()).padStart(2, '0') + ":" +
                                     String(fechaSalidaDATE.getMinutes()).padStart(2, '0');

                
                // También conviertes la fecha JSP si la necesitas
                let fechaInsideRaw = "<%= fecha_final_estado %>"; 
                let fechaInside = new Date(fechaInsideRaw);
                let fechaInsideFormato = fechaInside.getFullYear() + "-" +
                                        String(fechaInside.getMonth() + 1).padStart(2, '0') + "-" +
                                        String(fechaInside.getDate()).padStart(2, '0') + "T" +
                                        String(fechaInside.getHours()).padStart(2, '0') + ":" +
                                        String(fechaInside.getMinutes()).padStart(2, '0');

                // Mostrar formulario con datos cargados
                Swal.fire({
                    title: '📋 Finalizar citas de camiones',
                    html: `
                      <div class="swal-form">
                        <div class="swal-form-group">
                          <label for="fechacitainside">Fecha de la cita creada por inside</label>
                          <input id="fechacitainside" type="datetime-local" value="`+fechaInsideFormato+`">
                        </div>

                        <div class="swal-form-group">
                          <label for="fechaCita">Fecha de entrada por báscula</label>
                          <input id="fechaCita" type="datetime-local" value="`+fechaEntradaBas_fin+`">
                        </div>

                        <div class="swal-form-group">
                          <label for="pesoentrada">Peso de entrada en toneladas</label>
                          <input id="pesoentrada" type="text" value="`+pesoEntradaBas+`">
                        </div>

                        <div class="swal-form-group">
                          <label for="fechasalida">Fecha de salida por báscula</label>
                          <input id="fechasalida" type="datetime-local" value="`+fechaSalidaBas_fin+`">
                        </div>

                        <div class="swal-form-group">
                          <label for="pesosalida">Peso de salida en toneladas</label>
                          <input id="pesosalida" type="text" value="`+pesoSalidaBas+`">
                        </div>
                      </div>
                    `,
                    confirmButtonText: 'Guardar',
                    showCancelButton: true,
                    preConfirm: () => {
                        const fecha = document.getElementById('fechaCita').value;
                        const fechasal = document.getElementById('fechasalida').value;
                        const pentrada = document.getElementById('pesoentrada').value;
                        const psalida = document.getElementById('pesosalida').value;
                        let fechacitainside = document.getElementById('fechacitainside').value;
                        
                        let fechaISO = "";
                        
                        if (fechacitainside) {
                            const fechaObj = new Date(fechacitainside);
                            if (!isNaN(fechaObj)) {
                                fechaISO = fechaObj.toISOString().replace(/\.\d{3}Z$/, "Z"); 
                                // asegura "2025-08-27T12:41:00Z"
                            }
                        }
                        
                        if (!fecha || !fechasal || !pentrada || !psalida || !fechaISO) {
                            Swal.showValidationMessage('⚠ Todos los campos son obligatorios');
                            return false;
                        }

                        return { fecha, fechasal, pentrada, psalida, fechaISO };
                    }
                }).then((result) => {
                    if (result.isConfirmed) {
                        const { fecha, pentrada, fechasal, psalida, fechaISO } = result.value;
                        let identificador = "0";
                        const seleccionados = [];

                        // Suponiendo que selectedCheckboxes es una lista de checkboxes seleccionados
                        selectedCheckboxes.forEach(cb => {
                            const operacion = cb.dataset.operacion?.toLowerCase() || "";

                            identificador = (operacion === "operacion de cargue") ? "1" : "2";

                            seleccionados.push({
                                tipoOperacionId: identificador,
                                empresaTransportadoraNit: cb.dataset.transportadora || "",
                                vehiculoNumPlaca: cb.value || cb.dataset.placa || "",
                                conductorCedulaCiudadania: cb.dataset.cedula || "",
                                fechaOfertaSolicitud: fechaISO || "",
                                numManifiestoCarga: cb.dataset.manifiesto || "",
                                nombreconductor: cb.dataset.nombreconductor || "",
                                formulario: cb.dataset.formulario || "",
                                rol: cb.dataset.rol || ""
                            });
                        });

                        const json = JSON.stringify(seleccionados, null, 2); // con formato bonito
                        const registro = '<%= registro %>';  // desde JSP

                        const params = new URLSearchParams();
                        params.append('vehiculos', json);
                        params.append('fecha', fecha);
                        params.append('pesoentrada', pentrada);
                        params.append('fechasal', fechasal);
                        params.append('psalida', psalida);
                        params.append('fechacitainside', fechacitainside);
                        params.append('registro', registro);

                        // 🔍 Imprimir todo antes de enviar
                        console.log("📌 JSON de vehículos seleccionados:", json);
                        console.log("📌 Parámetros:", Object.fromEntries(params));

                        // Mostrar en pantalla para validar
                        Swal.fire({
                            title: "Datos a enviar",
                            html: `<pre style="text-align:left;max-height:300px;overflow:auto;">`+json+`</pre>
                                   <hr>
                                   <b>Parámetros extra:</b><br>
                                   Fecha: `+fecha+`<br>
                                   Peso entrada: `+pentrada+`<br>
                                   Fecha salida: `+fechasal+`<br>
                                   Peso salida: `+psalida+`<br>
                                   Fecha cita inside: `+fechaISO+`<br>
                                   Registro: `+registro+``,
                            width: "800px",
                            showCancelButton: true,
                            confirmButtonText: "Enviar ahora",
                            cancelButtonText: "Cancelar"
                        }).then(confirm => {
                            if (confirm.isConfirmed) {
                                // Ahora sí redirigir
                                window.location.href = '../Finalizarcita?' + params.toString();
                            }
                        });
                    }
                });
            })
            .catch(error => {
                console.error("Error al obtener datos:", error);
                Swal.fire("❌ Error", "No se pudo obtener la información de la cita", "error");
            });
        }

        
        function cancelarCita(codigoCita, empresaNit, placa, cedula, fechaOferta, operacion, registro, manifiesto) {
            const causales = [
                { codigo: '11', descripcion: 'Finalización del Buque - Finalización de la carga', responsable: 'PUERTO' },
                { codigo: '12', descripcion: 'Obstáculo por movilidad en última milla', responsable: 'PUERTO' },
                { codigo: '13', descripcion: 'Problemas técnicos en la plataforma de la Terminal Portuaria', responsable: 'PUERTO' },
                { codigo: '14', descripcion: 'Problemas operativos en la terminal portuaria (daños mecánicos equipos)', responsable: 'PUERTO' },
                { codigo: '15', descripcion: 'Confirmación tardía de la cita', responsable: 'PUERTO' },
                { codigo: '16', descripcion: 'Problemas de atraque de la Motonave', responsable: 'PUERTO' },
                { codigo: '31', descripcion: 'Daño mecánico del vehículo', responsable: 'TRANSPORTADOR' },
                { codigo: '32', descripcion: 'Enfermedad del Conductor', responsable: 'TRANSPORTADOR' },
                { codigo: '33', descripcion: 'Inocuidad del vehículo o del producto transportado', responsable: 'TRANSPORTADOR' },
                { codigo: '34', descripcion: 'Error en la digitación de la información', responsable: 'TRANSPORTADOR' },
                { codigo: '51', descripcion: 'Problemas de Nacionalización o Liberación de la Carga', responsable: 'GENERADOR' },
                { codigo: '72', descripcion: 'Obstáculo por comunidad', responsable: 'ESTADO' },
                { codigo: '71', descripcion: 'Obstáculo por infraestructura en la vía', responsable: 'ESTADO' },
                { codigo: '91', descripcion: 'Situación climática - Lluvia', responsable: 'INDETERMINADO' }
                
            ];
            
            const sufijos = {
                '29': 'Puerto',
                '49': 'Transportador',
                '69': 'Generador',
                '89': 'Estado',
                '99': 'Indeterminado'
            };

            const opcionesHtml = causales.map(c => {
                const sufijo = sufijos[c.codigo] ? ' - '+ sufijos[c.codigo]+'' : '';
                return '<option value="'+c.codigo+'">'+c.codigo+' - '+c.descripcion+''+sufijo+'</option>';
            }).join('');



            Swal.fire({
                title: '🗑 Cancelar Cita',
                html: 
                    '<div class="swal2-html-container" id="swal2-html-container" style="display: flex;">'+

                    '<label for="causalSelect"><strong>Selecciona una causal de cancelación:</strong></label><br>' +
                    '<select id="causalSelect" class="swal2-select" style=" font-size: 16px; padding: 10px; border-radius: 5px;">' +
                        '<option value="">-- Selecciona una opción --</option>' +
                        opcionesHtml +
                    '</select>'+
                    '</div>',

                showCancelButton: true,
                confirmButtonText: 'Cancelar Cita',
                cancelButtonText: 'Salir',
                preConfirm: () => {
                    const causal = document.getElementById('causalSelect').value;
                    if (!causal) {
                        Swal.showValidationMessage('⚠ Debes seleccionar una causal');
                        return false;
                    }
                    return { causal };
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    const causal = result.value.causal;

                    // Construir URL con parámetros
                    const params = new URLSearchParams({
                        codigo: codigoCita,
                        causal: causal,
                        empresaTransportadoraNit: empresaNit,
                        vehiculoNumPlaca: placa,
                        conductorCedulaCiudadania: cedula,
                        fechaOfertaSolicitud: fechaOferta,
                        tipooperacion: operacion,
                        registro:registro,
                        manifiesto:manifiesto
                    });
                    console.log(params.toString());
                    window.location.href = '../CancelarCitaServlet?' + params.toString();
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
</html>
