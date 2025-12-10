<%-- 
    Document   : TipoOperaciones
    Created on : abr 16, 2025, 10:25:29 a.m.
    Author     : braya
--%>

<%@page import="org.json.JSONObject"%>
<%@page import="com.spd.CargarBarcazas.CargarBarcazas"%>
<%@page import="org.json.JSONArray"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script>
    function closeModal() {
        document.getElementById("deleteModal").style.display = "none";
    }
    
    // Función personalizada para redirigir y marcar navegación interna
    function navegarInternamente(url) {
        sessionStorage.setItem("navegandoInternamente", "true");
        window.location.href = url;
    }
    
    // Cuando el DOM esté completamente cargado
    document.addEventListener("DOMContentLoaded", function () {
        const navEntry = performance.getEntriesByType("navigation")[0];
        sessionStorage.setItem("ventanaActiva", "true");
    });

    // Evento que se dispara antes de recargar o cerrar la pestaña
    window.addEventListener("beforeunload", function (e) {
        const navEntry = performance.getEntriesByType("navigation")[0];

        // Detecta si la página se abrió por primera vez (ej. desde un response.sendRedirect)
        if (navEntry && navEntry.type === "navigate") {
            console.log("Página cargada por primera vez (posiblemente desde un sendRedirect)");
            return;
        }
        
        // Evita ejecutar el beacon si es una recarga
        if (navEntry && navEntry.type === "reload") {
            console.log("Recarga detectada. No se envía beacon.");
            return;
        }

        // Si es navegación interna (dentro del sistema)
        if (sessionStorage.getItem("navegandoInternamente") === "true") {
            console.log("Navegación interna detectada. No se envía beacon.");
            sessionStorage.setItem("navegandoInternamente", "false");
            return;
        }

        // Si se cierra la pestaña o se sale del sistema
        if (sessionStorage.getItem("ventanaActiva") === "true") {
            console.log("Cierre de pestaña o salida del sistema detectado. Se envía beacon.");
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
        <title>Tipos de Operaciones</title>
        <link rel="stylesheet" href="../CSS/Formulario.css"/>
        <link rel="stylesheet" href="../CSS/Login.css"/>
        <link rel="stylesheet" href="../CSS/TipoOperacion.css"/>
        <link rel="stylesheet" href="../CSS/Styles_modal.css"/>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </head>
    
    <%
        Cookie[] cookies = request.getCookies();
        response.setContentType("text/html");

        boolean seccionIniciada = false;
        String DATA = "";

        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("SeccionIniciada")) {
                    seccionIniciada = true;
                }
                if(cookie.getName().equals("DATA")){
                    DATA = cookie.getValue();
                }
            }
        }

        if (!seccionIniciada) {
            response.sendRedirect(request.getContextPath());
        }
        Object rolObj = session.getAttribute("Rol");
    %>
    
    <jsp:include page= "Hearder.jsp"/>
    
    <%
        Object rolObject1 = session.getAttribute("Rol");
        if(rolObject1 == null) {
            // 🔹 Eliminar todas las cookies
            Cookie[] cookies3 = request.getCookies();
            if (cookies3 != null) {
                for (Cookie cookie : cookies3) {
                    cookie.setMaxAge(0); // caduca inmediatamente
                    cookie.setPath("/CITASSPD"); // asegúrate de aplicar al contexto raíz
                    response.addCookie(cookie);
                }
            }

            // 🔹 Invalidar la sesión completa también
            session.invalidate();
        
            response.sendRedirect(request.getContextPath());
            return;
        }
        if (rolObject1 != null && ((Integer) rolObject1) == 0 || ((Integer) rolObject1) == 5 || ((Integer) rolObject1) == 8){
    %>
    <body>
        <div class="contenedor">
            <input type="submit" value="Listado citas" onclick="navegarInternamente('./Listados_Citas.jsp')"/>
        </div>
    </body>
    <%
        } else if (rolObject1 != null && (((Integer) rolObject1) != 6 && ((Integer) rolObject1) != 7 && ((Integer) rolObject1) != 8 )){
    %>
            <script>
                function plantilla(e) {
                    Swal.fire({
                        title: '¿Cómo deseas subir las operaciones?',
                        text: 'Puedes utilizar la plantilla Excel generada por el sistema o continuar llenando manualmente.',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonText: 'Subir por Excel',
                        cancelButtonText: 'Seguir manual',
                        reverseButtons: true
                    }).then((result) => {

                        if (result.isConfirmed) {

                            Swal.fire({
                                title: 'Descargando plantilla...',
                                text: 'La plantilla Excel será descargada.',
                                icon: 'info'
                            }).then(() => {
                                // marcar que se creó la plantilla usando localStorage
                                localStorage.setItem('creacion_plantilla', true);
                                
                                window.location.href = '../DescargarPlanillaCreacionCita';
                                // luego de descargar, redireccionar a TipoOperaciones
                                setTimeout(() => {
                                    window.location.href = './OperacionesActivasPlanilla.jsp?planilla=' + localStorage.getItem('creacion_plantilla');
                                }, 1000); // espera 1 segundo para asegurar que se complete la descarga
                            });

                        } else if (result.dismiss === Swal.DismissReason.cancel) {
                            // Si se presiona "Seguir manual"
                            if (e) e.target.submit();
                        }

                    });
                }

                </script>
            <body>
                <div class="Contenedor">
                    <h1>Tipo de operación</h1>
                    <form id="formOperaciones" action="../TipoOperacionServlet" method="POST" class="formulario-SelectorTipoOpeacion">
                        <label for="CantidadOperaciones">Digite el número de operaciones a realizar:</label>
                        <input type="number" name="CantidadOperaciones" id="CantidadOperaciones" min="1" required/>
                        <button type="button" onclick="generarSelectores()">Generar Operaciones</button>
                        <%
                            if (DATA.equals("9018263370") || DATA.equals("9013129603"))
                            {
                        %>
                                <button type="button" onclick="plantilla()">Descargar Planilla de Citas</button>
                        <%
                            }
                        %>
                        <div id="contenedor-operaciones"></div>
                    </form>

                    <script>
                      document.getElementById("formOperaciones").addEventListener("keydown", function(event) {
                        if (event.key === "Enter") {
                          event.preventDefault();
                        }
                      });
                    </script>

                    <%
                        CargarBarcazas.inicializarDesdeContexto(application);
                        JSONArray barcazas = new JSONArray();
                        JSONArray nombresBarcazas = new JSONArray(); // solo nombres

                        try {
                            barcazas = new CargarBarcazas().carguebarcaza();
                            for (int i = 0; i < barcazas.length(); i++) {
                                JSONObject b = barcazas.getJSONObject(i);
                                if (b.has("BARCAZA")) {
                                    nombresBarcazas.put(b.getString("BARCAZA"));
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>

                    <script>
                        const cookies = document.cookie;
                        function getCookie(nombre) {
                            const cookies = document.cookie.split(';');
                            for (let cookie of cookies) {
                              const [key, value] = cookie.trim().split('=');
                              if (key === nombre) {
                                return decodeURIComponent(value);
                              }
                            }
                            return null;
                        }

                        const usuario = getCookie("USUARIO");
                        console.log("Cookie 'USUARIO':", usuario);

                        const operaciones = [
                          "Carrotanque - Barcaza",
                          "Barcaza - Carrotanque",
                          "Barcaza - Tanque",
                          "Tanque - Barcaza",
                          "Carrotanque - Tanque",
                          "Tanque - Carrotanque",
                          "Barcaza - Barcaza"
                        ];

                        function generarSelectores() {
                          const cantidad = parseInt(document.getElementById("CantidadOperaciones").value);
                          const contenedor = document.getElementById("contenedor-operaciones");
                          contenedor.innerHTML = "";

                          if (!cantidad || cantidad <= 0) {
                            alert("Por favor ingrese un número válido.");
                            return;
                          }

                          const enviar = document.createElement("input");
                          enviar.type = "submit";
                          enviar.value = "Enviar";
                          enviar.style.marginBottom = "10px";

                          for (let i = 1; i <= cantidad; i++) {
                            const div = document.createElement("div");
                            div.className = "operacion-container";

                            const labelOperacion = document.createElement("label");
                            labelOperacion.innerText = "Tipo de operación #" + i;

                            const selectOperacion = document.createElement("select");
                            selectOperacion.name = "operacion_" + i;
                            selectOperacion.required = true;
                            selectOperacion.dataset.index = i;

                            let optionsHTML = "<option value=''>Seleccione</option>";
                            operaciones.forEach(op => {
                              optionsHTML += "<option value=\"" + op + "\">" + op + "</option>";
                            });
                            selectOperacion.innerHTML = optionsHTML;

                            selectOperacion.addEventListener("change", function (e) {
                              mostrarCamposExtras(e.target.value, i);
                            });

                            const extras = document.createElement("div");
                            extras.id = "extras_" + i;
                            extras.className = "extras";

                            div.appendChild(labelOperacion);
                            div.appendChild(selectOperacion);
                            div.appendChild(extras);
                            contenedor.appendChild(div);
                          }
                          contenedor.appendChild(enviar);
                        }

                        function mostrarCamposExtras(tipo, index) {
                          const extras = document.getElementById("extras_" + index);
                          extras.innerHTML = "";

                          if (tipo === "Tanque - Tanque") {
                            const labelCliente = document.createElement("label");
                            labelCliente.innerText = "Cliente asociado (op #" + index + "):";

                            const selectCliente = document.createElement("select");
                            selectCliente.name = "cliente_" + index;
                            selectCliente.required = true;

                            const labelTanqueOrigen = document.createElement("label");
                            labelTanqueOrigen.innerText = "Tanque actual (origen):";

                            const selectTanqueOrigen = document.createElement("select");
                            selectTanqueOrigen.name = "tanque_origen_" + index;
                            selectTanqueOrigen.required = true;

                            const labelTanqueDestino = document.createElement("label");
                            labelTanqueDestino.innerText = "Tanque destino:";

                            const selectTanqueDestino = document.createElement("select");
                            selectTanqueDestino.name = "tanque_destino_" + index;
                            selectTanqueDestino.required = true;

                            const actualizarTanques = (cliente) => {
                                if (!cliente) return;

                                fetch('/ObtenerTanques?usuario="'+cliente+'"')
                                    .then(response => response.json())
                                    .then(data => {
                                        let options = "<option value=''>Seleccione tanque</option>";
                                        data.forEach(t => {
                                            options += "<option value=\"" + t.tanques + "\">" + t.tanque + "</option>";
                                        });
                                        selectTanqueOrigen.innerHTML = options;
                                        selectTanqueDestino.innerHTML = options;
                                })
                                .catch(error => console.error("Error cargando tanques:", error));
                            };

                            actualizarTanques(usuario);

                            extras.appendChild(labelCliente);
                            extras.appendChild(selectCliente);
                            extras.appendChild(labelTanqueOrigen);
                            extras.appendChild(selectTanqueOrigen);
                            extras.appendChild(labelTanqueDestino);
                            extras.appendChild(selectTanqueDestino);
                          }

                          else if (tipo.includes("Tanque")) {
                            const labelCliente = document.createElement("label");
                            labelCliente.innerText = "Cliente asociado (op #" + index + "):";

                            const selectCliente = document.createElement("input");
                            selectCliente.type = "text";
                            selectCliente.name = "cliente_" + index;
                            selectCliente.required = true;
                            selectCliente.value = usuario;
                            selectCliente.readOnly = true;

                            const labelTanque = document.createElement("label");
                            labelTanque.innerText = "Tanque asignado (op #" + index + "):";

                            const selectTanque = document.createElement("select");
                            selectTanque.name = "tanque_" + index;
                            selectTanque.id = "tanque_" + index;
                            selectTanque.required = true;
                            selectTanque.innerHTML = "<option value=''>Seleccione tanque</option>";

                            const actualizarTanques = (cliente) => {
                                if (!cliente) return;

                                fetch('../ObtenerTanques?usuario='+cliente)
                                    .then(response => response.json())
                                    .then(data => {
                                        let options = "<option value=''>Seleccione tanque</option>";
                                        data.forEach(t => {
                                            options += "<option value=\"" + t.Tanque + "\">" + t.Tanque + "</option>";
                                        });
                                        selectTanque.innerHTML = options;
                                })
                                .catch(error => console.error("Error cargando tanques:", error));
                            };

                            actualizarTanques(usuario);

                            extras.appendChild(labelCliente);
                            extras.appendChild(selectCliente);
                            extras.appendChild(labelTanque);
                            extras.appendChild(selectTanque);
                          }

                            var nombresBarcazas = <%= nombresBarcazas.toString() %>;
                            nombresBarcazas.push("Roma 304", "Omega one", "Alpha uno", "MANFU I", "Remolcador - Doña Clary", "Roma 101");

                            if (tipo === "Barcaza - Barcaza") {
                                const labelBarcazaOrigen = document.createElement("label");
                                labelBarcazaOrigen.innerText = "Nombre de la barcaza de origen (op #" + index + "):";

                                const selectBarcazaOrigen = document.createElement("select");
                                selectBarcazaOrigen.name = "barcaza_origen_" + index;
                                selectBarcazaOrigen.required = true;

                                const optionDefaultOrigen = document.createElement("option");
                                optionDefaultOrigen.value = "";
                                optionDefaultOrigen.text = "Seleccione una barcaza";
                                optionDefaultOrigen.disabled = true;
                                optionDefaultOrigen.selected = true;
                                selectBarcazaOrigen.appendChild(optionDefaultOrigen);

                                nombresBarcazas.forEach(nombre => {
                                    const option = document.createElement("option");
                                    option.value = nombre;
                                    option.text = nombre;
                                    selectBarcazaOrigen.appendChild(option);
                                });

                                const labelBarcazaDestino = document.createElement("label");
                                labelBarcazaDestino.innerText = "Nombre de la barcaza de destino (op #" + index + "):";

                                const selectBarcazaDestino = document.createElement("select");
                                selectBarcazaDestino.name = "barcaza_destino_" + index;
                                selectBarcazaDestino.required = true;

                                const optionDefaultDestino = document.createElement("option");
                                optionDefaultDestino.value = "";
                                optionDefaultDestino.text = "Seleccione una barcaza";
                                optionDefaultDestino.disabled = true;
                                optionDefaultDestino.selected = true;
                                selectBarcazaDestino.appendChild(optionDefaultDestino);

                                nombresBarcazas.forEach(nombre => {
                                    const option = document.createElement("option");
                                    option.value = nombre;
                                    option.text = nombre;
                                    selectBarcazaDestino.appendChild(option);
                                });

                                extras.appendChild(labelBarcazaOrigen);
                                extras.appendChild(selectBarcazaOrigen);
                                extras.appendChild(labelBarcazaDestino);
                                extras.appendChild(selectBarcazaDestino);

                            } else if (tipo.includes("Barcaza")) {
                                const labelBarcaza = document.createElement("label");
                                labelBarcaza.innerText = "Nombre de la barcaza (op #" + index + "):";

                                const selectBarcaza = document.createElement("select");
                                selectBarcaza.name = "barcaza_" + index;
                                selectBarcaza.required = true;

                                const optionDefault = document.createElement("option");
                                optionDefault.value = "";
                                optionDefault.text = "Seleccione una barcaza";
                                optionDefault.disabled = true;
                                optionDefault.selected = true;
                                selectBarcaza.appendChild(optionDefault);

                                nombresBarcazas.forEach(nombre => {
                                    const option = document.createElement("option");
                                    option.value = nombre;
                                    option.text = nombre;
                                    selectBarcaza.appendChild(option);
                                });

                                extras.appendChild(labelBarcaza);
                                extras.appendChild(selectBarcaza);
                            }
                        }
                    </script>
                </div>
            </body>


                <%
                    }else if (((Integer) rolObj) != 7 && ((Integer) rolObj) != 8){
                %>

                    <body>
                        <div class="contenedor">
                            <input type="submit" value="Reporte De Barcazas Entrada Y Salida" onclick="reporteBarcazas()"/>
                            <input type="submit" value="Reporte De Carrotanques Entrada Y Salida" onclick="reporteCarrotanques()"/>
                        </div>

                        <script>
                            function reporteCarrotanques() {
                                Swal.fire({
                                    title: '📅 Seleccionar Rango de Fechas',
                                    html: `
                                        <div style="display:flex; flex-direction:column; gap:15px; text-align:left;">
                                            <div>
                                                <label style="font-weight:bold; font-size:14px;">Fecha Inicial:</label>
                                                <input type="date" id="fechaInicial" class="swal2-input" 
                                                    style="width:100%; padding:10px; font-size:14px;">
                                            </div>
                                            <div>
                                                <label style="font-weight:bold; font-size:14px;">Fecha Final:</label>
                                                <input type="date" id="fechaFinal" class="swal2-input" 
                                                    style="width:100%; padding:10px; font-size:14px;">
                                            </div>
                                        </div>
                                    `,
                                    confirmButtonText: '📥 Descargar Reporte',
                                    confirmButtonColor: '#6C63FF',
                                    showCancelButton: true,
                                    cancelButtonText: 'Cancelar',
                                    cancelButtonColor: '#d33',
                                    focusConfirm: false,
                                    preConfirm: () => {
                                        const fechaInicial = document.getElementById('fechaInicial').value;
                                        const fechaFinal = document.getElementById('fechaFinal').value;

                                        if (!fechaInicial || !fechaFinal) {
                                            Swal.showValidationMessage('⚠️ Ambas fechas son requeridas');
                                            return false;
                                        }

                                        if (fechaFinal < fechaInicial) {
                                            Swal.showValidationMessage('⚠️ La fecha final no puede ser menor que la inicial');
                                            return false;
                                        }

                                        return { fechaInicial, fechaFinal };
                                    }
                                }).then((result) => {
                                    if (result.isConfirmed) {
                                        const { fechaInicial, fechaFinal } = result.value;

                                        // Mostrar loader
                                        Swal.fire({
                                            title: '⏳ Generando reporte...',
                                            text: 'Por favor espera unos segundos',
                                            allowOutsideClick: false,
                                            didOpen: () => {
                                                Swal.showLoading();
                                            }
                                        });

                                        // Simula un retraso antes de redirigir (opcional)
                                        setTimeout(() => {
                                            window.location.href = '/CITASSPD/reportecarrotanquesservelet?fechainicial=' 
                                                + fechaInicial + '&fechafinal=' + fechaFinal;
                                        }, 1000);
                                    }
                                });
                            }

                            function reporteBarcazas() {
                                Swal.fire('🚧 Funcionalidad aún no implementada');
                            }
                        </script>


                    </body>
                <%
                    }else {
                %>
                        <body>
                        
                        <div class="contenedor">
                            <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('../ListarOperaciones')"/>
                        </div>

                    </body>
                <%
                    }
                %>
</html>
