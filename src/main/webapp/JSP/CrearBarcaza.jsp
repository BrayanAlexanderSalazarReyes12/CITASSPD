<%-- 
    Document   : CrearBarcaza
    Created on : 31/10/2025, 09:21:37 AM
    Author     : Brayan Salazar
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
    
   // Marca que la pestaña está activa
    sessionStorage.setItem("ventanaActiva", "true");

    window.addEventListener("beforeunload", function (e) {
        const navEntry = performance.getEntriesByType("navigation")[0];

        // Evita ejecutar el beacon si es una recarga
        if (navEntry && navEntry.type === "reload") {
            console.log("Recarga detectada. No se envía beacon.");
            return;
        }
        
        if(sessionStorage.getItem("navegandoInternamente") === "true"){
            console.log("navegacion");
            return;
        }

        // Si no es recarga (es cierre de pestaña o salir del sitio)
        if (sessionStorage.getItem("ventanaActiva") === "true") {
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
        <title>CREAR BARCAZA</title>
        <link rel="stylesheet" href="../CSS/Login.css"/>
        <link rel="stylesheet" href="../CSS/Styles_modal.css"/>
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
    <% Object rolObj = session.getAttribute("Rol"); %>
    <jsp:include page="Hearder.jsp"/>
    <body>
        <div class="Contenedor">
            <div class="version">
                <h1>Crear Barcaza</h1>
            </div>
            <form name="BarcazaForm" action="../CrearBarcazaServlet" method="POST" class="Formulario">
                
                <label for="Cliente">Nombre del Cliente:</label>
                <input type="text" id="Cliente" name="CLIENTE" required />

                <label for="NIT_CLIENTE">NIT del Cliente:</label>
                <input type="text" id="NIT_CLIENTE" name="NIT_CLIENTE" required />

                <label for="Barcaza">Nombre de la Barcaza:</label>
                <input type="text" id="Barcaza" name="BARCAZA" required />

                <label for="Armador">Armador:</label>
                <input type="text" id="Armador" name="ARMADOR" required />

                <label for="Eslora">Eslora (m):</label>
                <input type="number" step="0.01" id="Eslora" name="ESLORA" required />

                <label for="Manga">Manga (m):</label>
                <input type="number" step="0.01" id="Manga" name="MANGA" required />

                <label for="Calado">Calado (m):</label>
                <input type="number" step="0.01" id="Calado" name="CALADO" required />

                <label for="Bandera">Bandera:</label>
                <input type="text" id="Bandera" name="BANDERA" required />

                <label for="CertificacionMatricula">Certificación / Matrícula:</label>
                <input type="text" id="CertificacionMatricula" name="CERTIFICACIONMATRICULA" required />

                <label for="Poliza">Póliza:</label>
                <input type="text" id="Poliza" name="POLIZA" required />

                <label for="ResolucionServicios">Resolución de Servicios:</label>
                <input type="text" id="ResolucionServicios" name="RESOLUCIONDESERVICIOS" required />

                <label for="ResolucionPuntoExportacion">Resolución como Punto de Exportación:</label>
                <input type="text" id="ResolucionPuntoExportacion" name="ROSOLUCIONCOMOPUNTOEXPORTACION" required />

                <label for="NacionalArqueo">Nacional Arqueo:</label>
                <input type="date" id="NacionalArqueo" name="NACIONALARQUEO" required />

                <label for="DotacionMinimaSeguridad">Dotación Mínima de Seguridad:</label>
                <input type="date" id="DotacionMinimaSeguridad" name="DOTACIONMINIMADESEGURIDAD" required />

                <label for="NacionalFrancoRBO">Nacional Franco RBO:</label>
                <input type="date" id="NacionalFrancoRBO" name="NACIONALDEFRANCORBO" required />

                <label for="NacionalSeguridad">Nacional Seguridad:</label>
                <input type="date" id="NacionalSeguridad" name="NACIONALSEGURIDAD" required />

                <label for="InventarioElementoEquipos">Inventario de Elementos y Equipos:</label>
                <input type="date" id="InventarioElementoEquipos" name="INVENTARIOELEMENTOYEQUIPOS" required />

                <label for="TransporteHidrocarburos">Transporte de Hidrocarburos:</label>
                <input type="date" id="TransporteHidrocarburos" name="TRANSPORTEHIDEOCARBUROS" required />

                <label for="ContaminacionHidrocarburos">Contaminación por Hidrocarburos:</label>
                <input type="date" id="ContaminacionHidrocarburos" name="CONTAMINACIONHIDEOCARBUROS" required />

                <input type="submit" value="Crear Barcaza" />
            </form>

            <%
                String mensaje = (String) session.getAttribute("Error");
                Boolean Estado = (Boolean) session.getAttribute("Activo");
                if (Estado != null && Estado) {
            %>
            <div id="deleteModal" class="modal" style="display: flex;">
                <div class="modal-content">
                    <span class="close" onclick="closeModal()">&times;</span>
                    <h2><%= mensaje %></h2>
                    <div class="modal-actions">
                        <button type="button" onclick="closeModal()" class="cancel-btn">Cerrar</button>
                    </div>
                </div>
            </div>
            <%
                    session.setAttribute("Activo", false);
                }
            %>
        </div>

        <script>
            function closeModal() {
                document.getElementById('deleteModal').style.display = 'none';
            }
        </script>
    </body>
</html>

