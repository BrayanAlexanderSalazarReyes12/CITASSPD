<%-- 
    Document   : CitaCamionesPorFinalizar
    Created on : 21/07/2025, 11:31:55 AM
    Author     : Brayan Salazar
--%>

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
                                               data-rol="<%= rol %>">
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
    
    <%
        InformacionPesajeFinalizacionCIta.inicializarDesdeContexto(application);
        String codcita = request.getParameter("registro");
        System.out.println("codcita:"+ codcita);
        if(codcita != null && !codcita.isEmpty()){
            CitaInfo info = InformacionPesajeFinalizacionCIta.InformacionPeosFinalizacionCIta(codcita);
            
            if (info != null) {
                fecha_pesaje_entreda_bascula = (info.getFechaEntrada() != null) ? info.getFechaEntrada() : null;
                fecha_pesaje_salida_bascula  = (info.getFechaSalida()  != null) ? info.getFechaSalida()  : null;
                peso_entrada_bascula         = (info.getPesoIngreso() != null) ? Double.toString(info.getPesoIngreso()) : "";
                peso_salida_bascula          = (info.getPesoSalida()  != null) ? Double.toString(info.getPesoSalida())  : "";
                
                LocalDateTime fecha_en_bas = fecha_pesaje_entreda_bascula.toLocalDateTime();

                LocalDateTime fecha_sal_bas = fecha_pesaje_salida_bascula.toLocalDateTime();

                DateTimeFormatter salida = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                fechaParaInput_en_bas = fecha_en_bas.format(salida);
                fechaParInput_sal_bas = fecha_sal_bas.format(salida);
            } else {
                // Si no existe info, inicializamos vacío
                fecha_pesaje_entreda_bascula = null;
                fecha_pesaje_salida_bascula  = null;
                peso_entrada_bascula         = "";
                peso_salida_bascula          = "";
            }
            
        } else {
            out.println("⚠️ No se recibió el código de la cita.");
        }
    %>
    
    <%
        System.out.println(fechaParaInput_en_bas + " " + fecha_pesaje_salida_bascula + " " + peso_entrada_bascula +" "+ peso_salida_bascula);
    %>
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
            
            console.log("<%= fecha_final_estado %>");
            
            // Convertir fecha JSP al formato de datetime-local
            let fechaInsideRaw = "<%= fecha_final_estado %>"; // "2025-08-11 6:00:00 PM"

            // Crear objeto Date
            let fechaInside = new Date(fechaInsideRaw);

            // Formatear a YYYY-MM-DDTHH:MM (24 horas)
            let anio = fechaInside.getFullYear();
            let mes = String(fechaInside.getMonth() + 1).padStart(2, '0');
            let dia = String(fechaInside.getDate()).padStart(2, '0');
            let horas = String(fechaInside.getHours()).padStart(2, '0');
            let minutos = String(fechaInside.getMinutes()).padStart(2, '0');
            let fechaInsideFormato = anio+'-'+mes+'-'+dia+'T'+horas+':'+minutos;
            let fechaParaInput_en_bas = "<%= fechaParaInput_en_bas %>";
            let pesoentradabas = "<%= peso_entrada_bascula %>";
            let fechaParaInput_sal_bas = "<%= fechaParInput_sal_bas %>";
            let pesosalidabas= "<%= peso_salida_bascula %>";
            console.log("Fecha formateada para input:", fechaInsideFormato);
            
            Swal.fire({
                title: '📋 Finalizar citas de camiones',
                html: `
                    <style>
                      .swal-form {
                        display: grid;
                        grid-template-columns: 1fr;
                        gap: 12px;
                        width: 100%;
                      }
                      .swal-form-group {
                        display: flex;
                        flex-direction: column;
                      }
                      .swal-form-group label {
                        font-weight: bold;
                        margin-bottom: 4px;
                        font-size: 14px;
                        text-align: left;
                      }
                      .swal-form-group input {
                        padding: 8px;
                        border: 1px solid #ccc;
                        border-radius: 6px;
                        width: 100%;
                      }
                      @media (min-width: 768px) {
                        .swal-form-group {
                          flex-direction: row;
                          align-items: center;
                        }
                        .swal-form-group label {
                          flex: 0 0 220px;
                          margin-bottom: 0;
                        }
                        .swal-form-group input {
                          flex: 1;
                        }
                      }
                    </style>

                    <div class="swal-form">
                      <div class="swal-form-group">
                        <label for="fechacitainside">Fecha de la cita creada por inside</label>
                        <input id="fechacitainside" type="datetime-local" 
                               value="` + fechaInsideFormato + `" >
                      </div>

                      <div class="swal-form-group">
                        <label for="fechaCita">Fecha de entrada por báscula</label>
                        <input id="fechaCita" type="datetime-local"
                                value="` + fechaParaInput_en_bas +`">
                      </div>

                      <div class="swal-form-group">
                        <label for="pesoentrada">Peso de entrada en toneladas</label>
                        <input id="pesoentrada" type="text" 
                               pattern="\d+" inputmode="numeric"
                               oninput="this.value = this.value.replace(/\D/g, '').split('.')[0]"
                               placeholder="Solo números"
                               value="` + (pesoentradabas.includes('.') ? pesoentradabas.split('.')[0] : pesoentradabas) + `">
                      </div>


                      <div class="swal-form-group">
                        <label for="fechasalida">Fecha de salida por báscula</label>
                        <input id="fechasalida" type="datetime-local"
                                value="` + fechaParaInput_sal_bas +`">
                      </div>

                      <div class="swal-form-group">
                        <label for="pesosalida">Peso de salida en toneladas</label>
                        <input id="pesosalida" type="text" 
                               pattern="\\d+" inputmode="numeric"
                               oninput="this.value = this.value.replace(/\\D/g, '')"
                               placeholder="Solo números"
                               value="` + (pesosalidabas.includes('.') ? pesosalidabas.split('.')[0] : pesosalidabas) + `">
                      </div>
                    </div>
                  `,
                confirmButtonText: 'Guardar',
                confirmButtonColor: '#28a745',
                cancelButtonText: 'Cancelar',
                showCancelButton: true,
                preConfirm: () => {
                    const fecha = document.getElementById('fechaCita').value;
                    const fechasal = document.getElementById('fechasalida').value;
                    const pentrada = document.getElementById('pesoentrada').value;
                    const psalida = document.getElementById('pesosalida').value;
                    let fechacitainside = document.getElementById('fechacitainside').value;
                    // Asegurarte de que incluya los segundos
                    if (!fechacitainside.includes(':') || fechacitainside.length === 16) {
                      // El valor tiene solo HH:MM → agregar ":00"
                      fechacitainside += ':00';
                    }
                    console.log('Fecha capturada:', fechacitainside);
                    if (!fecha) {
                        Swal.showValidationMessage('⚠ Debes seleccionar una fecha');
                        return false;
                    }
                    if (!fechasal) {
                        Swal.showValidationMessage('⚠ Debes seleccionar una fecha');
                        return false;
                    }
                    if (!pentrada) {
                        Swal.showValidationMessage('⚠ Debes escribir el peso de entrada del camión');
                        return false;
                    }
                    if (!psalida){
                        Swal.showValidationMessage('⚠ Debes escribir el peso de salida del camión');
                        return false;
                    }
                    if(!fechacitainside) {
                        Swal.showValidationMessage('⚠ Debes escribir la fecha de la cita del INSIDE');
                    }

                    return { fecha: fecha, pentrada: pentrada, fechasal:fechasal, psalida:psalida, fechacitainside:fechacitainside };
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    const { fecha, pentrada, fechasal, psalida, fechacitainside } = result.value;
                    let identificador = "0";
                    const seleccionados = [];

                    // Suponiendo que selectedCheckboxes es una lista de checkboxes seleccionados
                    selectedCheckboxes.forEach(cb => {
                        const operacion = cb.dataset.operacion?.toLowerCase() || "";

                        identificador = (operacion === "operacion de cargue") ? "1" : "2";

                        seleccionados.push({
                            tipoOperacionId: identificador,
                            empresaTransportadoraNit: cb.dataset.transportadora || "",
                            vehiculoNumPlaca: cb.value || cb.dataset.placa || "", // fallback si value no tiene la placa
                            conductorCedulaCiudadania: cb.dataset.cedula || "",
                            fechaOfertaSolicitud: cb.dataset.fecha || "",
                            numManifiestoCarga: cb.dataset.manifiesto || "",
                            nombreconductor: cb.dataset.nombreconductor || "",
                            formulario: cb.dataset.formulario || "",
                            rol: cb.dataset.rol || ""
                        });
                    });

                    const json = encodeURIComponent(JSON.stringify(seleccionados));
                    const registro = '<%= registro %>';  // Asegúrate de usarlo si es necesario

                    const params = new URLSearchParams();
                    params.append('vehiculos', json);
                    params.append('fecha', fecha);
                    params.append('pesoentrada', pentrada);
                    params.append('fechasal', fechasal);
                    params.append('psalida', psalida);
                    params.append('fechacitainside', fechacitainside);
                    params.append('registro', registro);

                    window.location.href = '../Finalizarcita?' + params.toString();

                }
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
