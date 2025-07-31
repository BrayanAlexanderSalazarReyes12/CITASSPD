<%-- 
    Document   : TipoOperaciones
    Created on : abr 16, 2025, 10:25:29 a.m.
    Author     : braya
--%>

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
                }
            %>
            <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>
    
    <%
        Object rolObject1 = session.getAttribute("Rol");
        if (rolObject1 != null && ((Integer) rolObject1) == 0){
    %>
    <body>
        <div class="contenedor">
            <input type="submit" value="Listado citas" onclick="navegarInternamente('./Listados_Citas.jsp')"/>
        </div>
    </body>
    <%
        } else {
    %>
            
                    <body>
                        <div class="Contenedor">
                            <h1>Tipo de operación</h1>
                            <form action="../TipoOperacionServlet" method="POST" class="formulario-SelectorTipoOpeacion">
                                <label for="CantidadOperaciones">Digite el numero de operaciones a realizar:</label>
                                <input type="number" name="CantidadOperaciones" id="CantidadOperaciones" min="1" required/>
                                <button type="button" onclick="generarSelectores()">Generar Operaciones</button>

                                <div id="contenedor-operaciones"></div>


                            </form>
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
                                
                                const tanquesPorCliente = {
                                  "cwtrade": ["TK101"],
                                  "conquers": ["TK102","TK109", "TK110"],
                                  "ocindustrial": ["TK105"],
                                  "amfuels": ["TK103", "TK104", "TK108"],
                                  "prodexport": ["TK106"],
                                  "Puma Energy": ["TK107"]
                                };

                                const operaciones = [
                                  "Carrotanque - Barcaza",//✔
                                  "Barcaza - Carrotanque", //✔
                                  "Barcaza - Tanque",
                                  "Tanque - Barcaza",
                                  "Carrotanque - Tanque",
                                  "Tanque - Carrotanque",//✔
                                  //"Tanque - Tanque", 
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
                                  //<input type="submit" value="Enviar">
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
                                      const tanques = tanquesPorCliente[cliente] || [];
                                      let options = "<option value=''>Seleccione tanque</option>";
                                      tanques.forEach(t => {
                                        options += "<option value=\"" + t + "\">" + t + "</option>";
                                      });
                                      selectTanqueOrigen.innerHTML = options;
                                      selectTanqueDestino.innerHTML = options;
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

                                    // Crear el input
                                    const selectCliente = document.createElement("input");
                                    selectCliente.type = "text"; // tipo input texto
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

                                    const tanques = tanquesPorCliente[usuario] || [];
                                    selectTanque.innerHTML = "<option value=''>Seleccione tanque</option>";
                                    tanques.forEach(t => {
                                      const option = document.createElement("option");
                                      option.value = t;
                                      option.textContent = t;
                                      selectTanque.appendChild(option);
                                    });
                                    
                                    extras.appendChild(labelCliente);
                                    extras.appendChild(selectCliente);
                                    extras.appendChild(labelTanque);
                                    extras.appendChild(selectTanque);
                                  }

                                    if (tipo === "Barcaza - Barcaza") {
                                        const labelBarcazaOrigen = document.createElement("label");
                                        labelBarcazaOrigen.innerText = "Nombre de la barcaza de origen (op #" + index + "):";

                                        const inputBarcazaOrigen = document.createElement("input");
                                        inputBarcazaOrigen.type = "text";
                                        inputBarcazaOrigen.name = "barcaza_origen_" + index;
                                        inputBarcazaOrigen.required = true;

                                        const labelBarcazaDestino = document.createElement("label");
                                        labelBarcazaDestino.innerText = "Nombre de la barcaza de destino (op #" + index + "):";

                                        const inputBarcazaDestino = document.createElement("input");
                                        inputBarcazaDestino.type = "text";
                                        inputBarcazaDestino.name = "barcaza_destino_" + index;
                                        inputBarcazaDestino.required = true;

                                        extras.appendChild(labelBarcazaOrigen);
                                        extras.appendChild(inputBarcazaOrigen);
                                        extras.appendChild(labelBarcazaDestino);
                                        extras.appendChild(inputBarcazaDestino);
                                    } else if (tipo.includes("Barcaza")) {
                                        const labelBarcaza = document.createElement("label");
                                        labelBarcaza.innerText = "Nombre de la barcaza (op #" + index + "):";

                                        const inputBarcaza = document.createElement("input");
                                        inputBarcaza.type = "text";
                                        inputBarcaza.name = "barcaza_" + index;
                                        inputBarcaza.required = true;

                                        extras.appendChild(labelBarcaza);
                                        extras.appendChild(inputBarcaza);
                                    }

                                }
                            </script>
                        </div>
                    </body>
                <%
                    }
                %>
</html>
