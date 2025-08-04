<%-- 
    Document   : ListadoUsuarios
    Created on : abr 15, 2025, 1:50:38 p.m.
    Author     : braya
--%>

<%@page import="com.spd.Model.Usuario"%>
<%@page import="com.spd.DAO.ListadoUsuarios"%>
<%@page import="java.util.List"%>
<%@page import="java.util.List"%>
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

<%
    String rol_conversion = "";
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Listado de usuarios</title>
        <link rel="stylesheet" href="../CSS/Login.css"/>
        <link rel="stylesheet" href="../CSS/Formulario.css"/>
        <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
        <link rel="stylesheet" href="../CSS/Styles_modal.css"/>
        
        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        
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
    <body>
        <div class="content-container">
            <table id="myTable" class="display">
                <%
                    ListadoUsuarios lu = new ListadoUsuarios();
                    List<Usuario> listadoUsuarios = lu.Obtenerusuarios();
                    String usuarioActual = (String) session.getAttribute("Usuario");
                    if (listadoUsuarios.isEmpty()) {
                %>
                    <h1>⚠ No hay usuarios en el momento.</h1>
                <%
                    } else {
                %>
                    <h2>📋 Lista de usuarios</h2>
                    <thead>
                        <tr>
                            <th>Usuario</th>
                            <th>NIT</th>
                            <th>Código usuario</th>
                            <th>Email</th>
                            <th>Rol</th>
                            <th>Estado</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                <%
                        for (Usuario usuario : listadoUsuarios) {
                            if (!usuarioActual.equals(usuario.getUsername())) {
                %>
                        <tr>
                            <td data-label="Usuario"><%= usuario.getUsername() %></td>
                            <td data-label="NIT"><%= usuario.getNit_cliente() %></td>
                            <td data-label="Código usuario"><%= usuario.getCodcia_user() %></td>
                            <td data-label="Correo"><%= usuario.getEmail() %></td>
                            <td data-label="Rol">
                                <%= usuario.getRol() == 2 ? "Operador" : (usuario.getRol() == 1 ? "Administrador" : (usuario.getRol() == 0 ? "Porteria":"Consultor transportadora")) %>
                            </td>
                            <td data-label="Estado"><%= usuario.getEstado() == 0 ? "Activo" : "Inactivo" %></td>
                            <td>
                                <div class="Botones_tabla">
                                    <input type="button" 
                                           onclick="window.location.href='./ActualizarUsuario.jsp?usuario=<%= usuario.getUsername() %>'" 
                                           value="📋 Actualizar usuario">
                                </div>
                            </td>
                        </tr>
                <%
                            }
                        }
                    }
                %>
                    </tbody>
            </table>

            <%
                String mensaje = (String) session.getAttribute("Error");
                Boolean estado = (Boolean) session.getAttribute("Activo");
                if (estado != null && estado) {
            %>
                <div id="deleteModal" class="modal" style="display: flex;">
                    <div class="modal-content">
                        <span class="close" onclick="closeModal()">&times;</span>
                        <h2><%= mensaje %></h2>
                        <div class="modal-actions">
                            <form action="../EliminarContrato" method="post">
                                <input type="hidden" name="contratoId" id="contratoId">
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
