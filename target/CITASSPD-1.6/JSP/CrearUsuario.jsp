<%-- 
    Document   : CrearUsuario
    Created on : abr 15, 2025, 9:18:37 a.m.
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
        <title>CREAR USUARIO</title>
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
            <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('../ListarOperaciones')"/> 
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>
    <body>
        <div class="Contenedor">
            <div class="version">
                <h1>Crear usuario</h1>
            </div>
            <form name="LoginForm" action="../CrearUsuarioServlet" method="POST" class="Formulario">
                <label for="Usuario">Nombre de usuario:</label>
                <input type="text" id="Usuario" name="Usuario" oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '')" required />

                <label for="Contrasena">Contraseña:</label>
                <input type="password" id="Contrasena" name="Contrasena" required />

                <label for="NitCliente">Nit cliente:</label>
                <input type="text" id="NitCliente" name="NitCliente" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required/>

                <label for="Email">Correo:</label>
                <input type="email" id="Email" name="Email" required />

                <label for="TipoRol">Rol:</label>
                <select id="TipoRol" name="TipoRol" required>
                    <option value="1">Administrador</option>
                    <option value="2">Operador</option>
                    <option value="0">Portería</option>
                    <option value="4" disabled>Consultor</option>
                    <option value="5">Consultor Transportadora </option>
                    <option value="6">Consultor De Reportes</option>
                </select>

                <input type="submit" value="Crear usuario" />
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
                        <form action="../EliminarContrato" method="post">
                            <input type="hidden" name="contratoId" id="contratoId" />
                            <button type="button" onclick="closeModal()" class="cancel-btn">Cerrar</button>
                        </form>
                    </div>
                </div>
            </div>
            <%
                    session.setAttribute("Activo", false);
                }
            %>
        </div>
    </body>
</html>
