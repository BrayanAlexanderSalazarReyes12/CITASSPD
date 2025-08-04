<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.OffsetDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.ZonedDateTime"%>
<%@page import="java.time.ZoneId"%>
<%@page import="java.time.Instant"%>
<%@page import="com.spd.Model.ResultadoCitas"%>
<%@page import="com.spd.CItasDB.ListaVehiculos"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.spd.Model.ListadoCItas"%>
<%@page import="com.spd.DAO.ListadoDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Listados Citas SPD</title>
    <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
    <link rel="stylesheet" href="../CSS/Login.css"/>
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
    String fechaParaInput = "";
    String fechaSinHora = "";
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
                }
            %>
            <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>

            
    <style>
        .content-container {
            max-width: 1200px; /* puedes ajustarlo a 100%, 90vw, etc. */
            margin: 0 auto;
            margin-top: 20px;
            margin-bottom: 20px;
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
    <div class="content-container">
        <%
            String registro = request.getParameter("registro");
            ListadoDAO ldao = new ListadoDAO();
            
            ResultadoCitas rc = ldao.ObtenerContratos();
            
            List<ListadoCItas> ListadoCitas = rc.getCitasVehiculos();

            if(ListadoCitas.isEmpty()){
        %>
            <h1>⚠ No hay citas disponibles en este momento.</h1>
        <%
            } else {
        %>
        
            <h2>📋 Lista de citas por registros por camiones</h2>
            <form id="formularioCitas">
                <table id="myTable" class="display">
                    <thead>
                        <tr>
                            <th>Placa</th>
                            <th>Cedula conductor</th>
                            <th>Nombre conductor</th>
                            <th>Manifiesto</th>
                            <th>Estado</th>
                            <th>Fecha</th>
                            <th>Remision</th>
                            <th>Cancelar</th>
                            <th>Selecionar</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for(ListadoCItas listado : ListadoCitas){
                            
                                System.out.println(listado.getCodCita());
                                if (listado.getCodCita().equals(registro)) {
                                    String fechaCitaOriginal = listado.getFecha_Creacion_Cita();
                                    OffsetDateTime odt = OffsetDateTime.parse(fechaCitaOriginal); // desde Java 8
                                    LocalDateTime ldt = odt.toLocalDateTime();
                                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                                    DateTimeFormatter formatter1 = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                    
                                    String fechaSinZona = ldt.format(formatter);
                                    fechaParaInput = fechaSinZona;
                                    
                                    fechaSinHora = ldt.format(formatter1);
                                    
                                        
                                    if ("operacion de cargue".equals(listado.getTipo_Operacion())){
                                        operacion = 1;
                                    }else {
                                        operacion = 2;
                                    }
                                    
                                    List<ListaVehiculos> vehiculos = listado.getVehiculos();
                                    if (vehiculos != null && !vehiculos.isEmpty()){
                                        for (ListaVehiculos vehiculo : vehiculos){
                                        System.out.println(vehiculo.getFechaOfertaSolicitud());
                        %>
                            <tr>
                                <td><%= vehiculo.getVehiculoNumPlaca() %></td>
                                <td><%= vehiculo.getConductorCedulaCiudadania() %></td>
                                <td><%= vehiculo.getNombreConductor() %></td>
                                <td><%= vehiculo.getNumManifiestoCarga() %></td>
                                <td><%= listado.getEstado() %></td>
                                <td><%= vehiculo.getFechaOfertaSolicitud() == null ? fechaSinZona : vehiculo.getFechaOfertaSolicitud() %></td>
                                
                                <td>
                                    <input type="button" 
                                           value="Remision valorizada"
                                           onclick="descargarPDF('<%= listado.getFacturaRemision() %>.pdf', '<%= listado.getArchivo().replaceAll("\n", "").replaceAll("\r", "").replaceAll("'", "\\\\'") %>')">
                                </td>
                                <td>
                                    <input type="button" 
                                    onclick="cancelarCita(
                                        '<%= listado.getCodCita() %>',
                                        '<%= listado.getNit_Empresa_Transportadora() %>',
                                        '<%= vehiculo.getVehiculoNumPlaca() %>',
                                        '<%= vehiculo.getConductorCedulaCiudadania() %>',
                                        '<%= vehiculo.getFechaOfertaSolicitud() %>',
                                        '<%= operacion %>',
                                        '<%= registro %>',
                                        '<%= vehiculo.getNumManifiestoCarga() %>'
                                    )"
                                    value="🗑 Cancelar">
                                </td>
                                <td>
                                    <input type="checkbox" name="vehiculos"
                                           data-nombre="<%= vehiculo.getNombreConductor() %>"
                                           data-cedula="<%= vehiculo.getConductorCedulaCiudadania() %>"
                                           value="<%= vehiculo.getVehiculoNumPlaca() %>">
                                </td>
                            </tr>
                        <%
                                        }
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
                        value="📋 Programar cita a seleccionados">
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
        function navegarInternamente(url) {
            sessionStorage.setItem("navegandoInternamente", "true");
            window.location.href = url;
        }

        function abrirFormularioCitaMultiple() {
            const allCheckboxes = document.querySelectorAll('input[name="vehiculos"]');
            const selectedCheckboxes = document.querySelectorAll('input[name="vehiculos"]:checked');
            var fecha_final = "";
            if (allCheckboxes.length === 0) {
                Swal.fire('⚠ No hay vehículos disponibles para seleccionar');
                return;
            }

            if (selectedCheckboxes.length === 0) {
                Swal.fire('⚠ Debes seleccionar al menos un vehículo');
                return;
            }
            
            Swal.fire({
                title: '📋 Programar cita (múltiples)',
                html:
                    '<div style="display: flex; align-items: center; width: 100%; margin-bottom: 10px;">' +
                        '<label for="fechaCita" style="width: 150px; text-align: left;"><strong>Fecha de cita:</strong></label>' +
                        `<input id="fechaCita" type="datetime-local" class="swal2-input" style="flex: 1;" value="<%= fechaParaInput %>">` +
                    '</div>' +
                    '<div style="display: flex; align-items: center; width: 100%;">' +
                        '<label for="numeroformulario" style="width: 150px; text-align: left;"><strong>Número de formulario asignado:</strong></label>' +
                        '<input id="numeroformulario" type="text" class="swal2-input" style="flex: 1;" ' +
                        'pattern="\\d+" inputmode="numeric" oninput="this.value = this.value.replace(/\\D/g, \'\')" ' +
                        'placeholder="Solo números">' +
                    '</div>',
                confirmButtonText: 'Guardar',
                confirmButtonColor: '#28a745',
                cancelButtonText: 'Cancelar',
                showCancelButton: true,
                didOpen: () => {
                    const input = document.getElementById('fechaCita');
                    input.addEventListener('input', () => {
                        if (!input.value) return; // Si está vacío, no hacer nada

                        const partes = input.value.split('T');
                        const fecha_fija_final = "<%= fechaSinHora %>"; // Esto inyecta "2025-07-31"
                        console.log('fechaFija:', partes);
                        if (partes.length !== 2) {
                            // Formato incorrecto, restablecer a fechaFija + hora por defecto
                            const fechaFija = partes[0];
                            input.value = fechaFija+"T00:00";
                            return;
                        }

                        const [fecha, hora] = partes;
                        let fechaFija = fecha_fija_final;

                        // Validar formato hora HH:mm
                        const horaValida = /^([01]\d|2[0-3]):[0-5]\d$/.test(hora);
                        // Convertir a formato AM/PM para mostrar
                        const [hh, mm] = hora.split(':');
                        let h = parseInt(hh, 10);
                        const ampm = h >= 12 ? "PM" : "AM";
                        h = h % 12;
                        h = h === 0 ? 12 : h;

                        const horaAMPM = h+":"+mm+ampm;
                        console.log("Hora seleccionada:", horaAMPM);

                        
                        
                        console.log('fechaFija:', fechaFija, 'hora:', hora);
                        console.log('input.value antes de asignar:', fechaFija+"T"+horaAMPM);
                        
                        fecha_final = fechaFija+"T"+hora;
                        
                        console.log(fecha_final);
                        
                        if (fecha !== fechaFija) {
                            if (horaValida) {
                                
                            } else {
                                input.value = fechaFija+"T00:00";
                            }
                        }
                    });



                },
                preConfirm: () => {
                    const fecha = fecha_final;
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
                                           '&fecha=' + encodeURIComponent(fecha ) +
                                           '&fmm=' + encodeURIComponent(fmm) +
                                           '&registro=' + encodeURIComponent(registro);
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
                { codigo: '29', descripcion: 'Otros', responsable: 'PUERTO' },
                { codigo: '31', descripcion: 'Daño mecánico del vehículo', responsable: 'TRANSPORTADOR' },
                { codigo: '32', descripcion: 'Enfermedad del Conductor', responsable: 'TRANSPORTADOR' },
                { codigo: '33', descripcion: 'Inocuidad del vehículo o del producto transportado', responsable: 'TRANSPORTADOR' },
                { codigo: '34', descripcion: 'Error en la digitación de la información', responsable: 'TRANSPORTADOR' },
                { codigo: '49', descripcion: 'Otros', responsable: 'TRANSPORTADOR' },
                { codigo: '51', descripcion: 'Problemas de Nacionalización o Liberación de la Carga', responsable: 'GENERADOR' },
                { codigo: '69', descripcion: 'Otros', responsable: 'GENERADOR' },
                { codigo: '72', descripcion: 'Obstáculo por comunidad', responsable: 'ESTADO' },
                { codigo: '71', descripcion: 'Obstáculo por infraestructura en la vía', responsable: 'ESTADO' },
                { codigo: '89', descripcion: 'Otros', responsable: 'ESTADO' },
                { codigo: '91', descripcion: 'Situación climática - Lluvia', responsable: 'INDETERMINADO' },
                { codigo: '99', descripcion: 'Otros', responsable: 'INDETERMINADO' }
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
</body>
</html>
