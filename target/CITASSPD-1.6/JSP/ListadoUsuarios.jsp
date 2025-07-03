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
            <input type="submit" value="HOME" onclick="navegarInternamente('https://spdique.com/')"/>
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="CREAR USUARIO" onclick="navegarInternamente('CrearUsuario.jsp')"/>
                <input type="submit" value="CREAR CITA" onclick="navegarInternamente('Formulario.jsp')"/>
            <%
                }
            %>
            <input type="submit" value="LISTADOS DE CITAS" onclick="navegarInternamente('./Listados_Citas.jsp')"/>
            <input type="submit" value="CERRAR SESIÓN" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
    </header>
    <body>
        <div class="Content">
            <table id="myTable" class="display">
                <%
                    ListadoUsuarios lu = new ListadoUsuarios();
                    List<Usuario> ListadoUsuarios = lu.Obtenerusuarios();
                    if(ListadoUsuarios.isEmpty()){
                %>
                    <h1>⚠ No hay Usuarios en el momento.</h1>
                <%
                    }else{
                %>
                    <h2>📋 Lista de usuarios</h2>
                    <thead>
                        <tr>
                            <th>Usuario</th>
                            <th>Nit</th>
                            <th>Codigo usuario</th>
                            <th>Email</th>
                            <th>Rol</th>
                            <th>Estado</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                <%
                    for(Usuario listado: ListadoUsuarios){
                        String UsuarioAntiguo = (String) session.getAttribute("Usuario");
                        if(!UsuarioAntiguo.equals(listado.getUsername()))
                        {
                %>
                                <tr>
                                    <td data-label="Usuario"><%= listado.getUsername()%></td>
                                    <td data-label="Nit"><%= listado.getNit_cliente() %></td>
                                    <td data-label="Codigo Usuario"><%= listado.getCodcia_user() %></td>
                                    <td data-label="Correo"><%= listado.getEmail() %></td>
                                    <td data-label="Rol"><%= listado.getRol() %></td>
                                    <td data-label="Estado"><%= listado.getEstado() %></td>
                                    <td>
                                        <div class="Botones_tabla">
                                            <input type="button" 
                                                   onclick="window.location.href='./ActualizarUsuario.jsp?usuario=<%= listado.getUsername() %>'"
                                                   value="📋 Actualizar Usuario">
                                        </div>
                                    </td>
                                </tr>
                <%
                    }}}
                %>
                        </tbody>
            </table>
            <%
                String mensaje = (String) session.getAttribute("Error");
                Boolean Estado = (Boolean) session.getAttribute("Activo");
            %>

            <%
                if(Estado != null){
                    if(Estado){
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
                }
            %>
        </div>
    </body>
</html>
