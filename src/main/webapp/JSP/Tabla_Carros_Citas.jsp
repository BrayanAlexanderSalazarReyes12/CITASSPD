<%@page import="java.io.File"%>
<%@page import="com.spd.Productos.Producto"%>
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
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <script>
            $(document).ready(function () {
                $('#myTable').DataTable({
                    scrollY: 400,
                    pageLength: 50, // ← Aquí se especifica mostrar 20 registros por página
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
                            <th>
                                <label style="
                                    display: inline-flex; 
                                    align-items: center; 
                                    gap: 6px; 
                                    color: white; 
                                    font-weight: bold; 
                                    cursor: pointer;
                                ">
                                    Actualizar
                                    <input type="checkbox" id="selectAll" style="margin: 0;" />
                                </label>
                            </th>
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
                                <% System.out.println(fechaSinZona + "" + vehiculo.getFechaOfertaSolicitud()); %>
                                <td>
                                    <%
                                        // Limpiar y normalizar archivo
                                        String archivo = listado.getArchivo()
                                                .replaceAll("[\\r\\n]", "")   // quitar saltos de línea
                                                .replace("'", "\\\\'")        // escapar comillas simples
                                                .trim();

                                        // Solo nombre del archivo
                                        String nombreArchivo = new File(archivo).getName();

                                        // Normalizar extensión: si termina en .pdf.pdf lo deja en .pdf
                                        nombreArchivo = nombreArchivo.replaceAll("\\.pdf+$", "");

                                        // Nombre sin extensión
                                        String nombreSinExt = nombreArchivo.replaceAll("\\.pdf$", "");
                                    %>

                                    <input type="button" 
                                           value="Remision valorizada"
                                           onclick="descargarPDF('<%= nombreArchivo %>', '<%= listado.getArchivo().replaceAll("[\\n\\r]", "").replace("'", "\\\\'") %>')">

                                </td>
                                <% if(rolObj != null && ((Integer) rolObj) == 1) { %>
                                    <td>
                                        <input type="checkbox" name="vehiculos" class="checkItem"
                                               data-nombre="<%= vehiculo.getNombreConductor() %>"
                                               data-cedula="<%= vehiculo.getConductorCedulaCiudadania() %>"
                                               value="<%= vehiculo.getVehiculoNumPlaca() %>">
                                    </td>
                                <% }else{ %>
                                <td>
                                    <input type="button" 
                                           value="Actualizar Cita"
                                           onclick="abrirFormulario()">
                                </td>
                                <%}%>
                            </tr>
                        <%
                                        }
                                    }
                                }
                            }
                        %>
                        <script>
                            // Checkbox general
                            const selectAll = document.getElementById('selectAll');
                            const checkboxes = document.querySelectorAll('.checkItem');

                            // Al hacer clic en el checkbox general
                            selectAll.addEventListener('change', function() {
                              checkboxes.forEach(chk => chk.checked = this.checked);
                            });

                            // Si se cambia un checkbox individual, actualizar el estado del general
                            checkboxes.forEach(chk => {
                              chk.addEventListener('change', () => {
                                selectAll.checked = Array.from(checkboxes).every(item => item.checked);
                              });
                            });
                        </script>
                    </tbody>
                </table>
            </form>
                    
            <script>
                function abrirFormulario() {
                    Swal.fire({
                        title: 'Actualizar Producto',
                        width: '95%',
                        customClass: { popup: 'swal-wide' },
                        html: `
                            <style>
                                .form-grid {
                                    display: grid;
                                    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                                    gap: 15px;
                                    padding: 10px;
                                }
                                .form-field {
                                    background: #f9f9f9;
                                    padding: 10px;
                                    border-radius: 8px;
                                    box-shadow: 0 1px 3px rgba(0,0,0,0.08);
                                    display: flex;
                                    flex-direction: column;
                                }
                                .form-field label {
                                    font-weight: 600;
                                    font-size: 0.9rem;
                                    margin-bottom: 5px;
                                    color: #333;
                                }
                                .form-field input,
                                .form-field select,
                                .form-field textarea {
                                    padding: 8px;
                                    border: 1px solid #ccc;
                                    border-radius: 6px;
                                    font-size: 0.9rem;
                                    outline: none;
                                    transition: border 0.3s ease;
                                }
                                .form-field input:focus,
                                .form-field select:focus,
                                .form-field textarea:focus {
                                    border-color: #007bff;
                                }
                                #valorFOB {
                                    background-color: #e9f7ef;
                                    color: #155724;
                                    font-weight: bold;
                                }
                                textarea { resize: vertical; }
                            </style>

                            <div class="form-grid">
                                <div class="form-field">
                                    <label>Tipo de Producto:</label>
                                    <input type="text" id="tipoProducto">
                                </div>

                                <div class="form-field">
                                    <label>Cantidad del Producto (en m³):</label>
                                    <input type="number" id="cantidadProducto" step="0.01">
                                </div>

                                <div class="form-field">
                                    <label>Peso Bruto del Producto (en KG):</label>
                                    <input type="number" id="pesoBruto" step="0.01">
                                </div>

                                <div class="form-field">
                                    <label>Número de Factura Comercial o Remisión:</label>
                                    <input type="text" id="numeroFactura">
                                </div>

                                <div class="form-field">
                                    <label>Adjuntar Remisión Valorizada (PDF):</label>
                                    <input type="file" id="remisionPDF" accept="application/pdf">
                                </div>

                                <div class="form-field">
                                    <label>Precio Unitario en USD:</label>
                                    <input type="number" id="precioUnitario" step="0.01">
                                </div>

                                <div class="form-field">
                                    <label>Valor FOB Total (USD):</label>
                                    <input type="text" id="valorFOB" readonly value="0.00">
                                </div>

                                <div class="form-field" style="grid-column: 1 / -1;">
                                    <label>Observaciones Generales:</label>
                                    <textarea id="observaciones" rows="3"></textarea>
                                </div>
                            </div>
                        `,
                        focusConfirm: false,
                        showCancelButton: true,
                        confirmButtonText: '<i class="fas fa-save"></i> Guardar',
                        cancelButtonText: 'Cancelar',
                        didOpen: () => {
                            const cantidad = document.getElementById('cantidadProducto');
                            const precio = document.getElementById('precioUnitario');
                            const valorFOB = document.getElementById('valorFOB');

                            // Calcular FOB
                            function actualizarFOB() {
                                const c = parseFloat(cantidad.value) || 0;
                                const p = parseFloat(precio.value) || 0;
                                valorFOB.value = (c * p).toFixed(2);
                            }
                            cantidad.addEventListener('input', actualizarFOB);
                            precio.addEventListener('input', actualizarFOB);
                        },
                        preConfirm: () => {
                            // Validar campos vacíos
                            const campos = [
                                'tipoProducto',
                                'cantidadProducto',
                                'pesoBruto',
                                'numeroFactura',
                                'precioUnitario',
                                'observaciones'
                            ];

                            for (let id of campos) {
                                if (!document.getElementById(id).value.trim()) {
                                    Swal.showValidationMessage('Todos los campos son obligatorios');
                                    return false;
                                }
                            }

                            // Validar archivo PDF
                            const archivo = document.getElementById('remisionPDF').files[0];
                            if (!archivo) {
                                Swal.showValidationMessage('Debes adjuntar el archivo PDF');
                                return false;
                            }
                            if (archivo.size > 200 * 1024) {
                                Swal.showValidationMessage('El archivo debe pesar menos de 200 KB');
                                return false;
                            }

                            // Convertir a Base64 y devolver datos
                            return new Promise((resolve) => {
                                const reader = new FileReader();
                                reader.onload = function(e) {
                                    const base64 = e.target.result.split(',')[1];
                                    resolve({
                                        tipoProducto: document.getElementById('tipoProducto').value,
                                        cantidadProducto: document.getElementById('cantidadProducto').value,
                                        pesoBruto: document.getElementById('pesoBruto').value,
                                        numeroFactura: document.getElementById('numeroFactura').value,
                                        remisionPDF: base64,
                                        precioUnitario: document.getElementById('precioUnitario').value,
                                        observaciones: document.getElementById('observaciones').value
                                    });
                                };
                                reader.readAsDataURL(archivo);
                            });
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            console.log("Datos guardados:", result.value);
                            Swal.fire("Actualizado", "El producto se ha actualizado correctamente.", "success");
                        }
                    });
                }
            </script>

            
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
        function descargarPDF(nombre, ruta) {
            const form = document.createElement("form");
            form.method = "post";
            form.action = "DescargarRemision.jsp";
            form.target = "_blank";

            const inputNombre = document.createElement("input");
            inputNombre.type = "hidden";
            inputNombre.name = "nombre";
            inputNombre.value = nombre;

            const inputRuta = document.createElement("input");
            inputRuta.type = "hidden";
            inputRuta.name = "ruta";
            inputRuta.value = ruta;

            form.appendChild(inputNombre);
            form.appendChild(inputRuta);

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
            
            if (selectedCheckboxes.length !== allCheckboxes.length) {
                Swal.fire('⚠ Debes seleccionar todos los vehículos disponibles');
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