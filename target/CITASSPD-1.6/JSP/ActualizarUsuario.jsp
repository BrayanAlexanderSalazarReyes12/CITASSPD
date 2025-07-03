<%-- 
    Document   : ActualizarUsuario
    Created on : abr 15, 2025, 2:34:48 p.m.
    Author     : braya
--%>

<%@page import="org.json.JSONObject"%>
<%@page import="java.nio.file.Paths"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.lang.reflect.Type"%>
<%@page import="com.google.gson.reflect.TypeToken"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.spd.API.Usuario_Insert"%>
<%@page import="com.spd.Model.Usuario"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    
    String usuario = request.getParameter("usuario");
    String CodigoUsuario = "";
    String correo = "";
    int Rol = 0;
    int Estado = 0;
    String nit = "";
            
    //variables de entorno
    String path = getServletContext().getRealPath("/WEB-INF/json.env");
    String content = new String(Files.readAllBytes(Paths.get(path)));
    JSONObject jsonEnv = new JSONObject(content); // Parsea el JSON
    //System.out.println(jsonEnv);
    String TOKEN = jsonEnv.optString("TOKEN");
    
    String url1 = "http://www.siza.com.co/spdcitas-1.0/api/citas/usuario";
    String token = TOKEN;

    Usuario_Insert usuario_Insert = new Usuario_Insert();
    String json1 = usuario_Insert.consultar(url1, token);

    // Indicamos que es una lista de Usuario
    Type listType = new TypeToken<List<Usuario>>(){}.getType();

    //Convertir el Objeto a JSON
    Gson gson = new Gson();

    // Convertimos el JSON a lista
    List<Usuario> usuarios = gson.fromJson(json1, listType);
    
    session.setAttribute("UsuarioAntiguo", usuario);
    
    // Recorremos la lista
    for (Usuario u : usuarios) {
        if(u.getUsername().equals(usuario)){
            CodigoUsuario = u.getCodcia_user();
            correo = u.getEmail();
            Rol = u.getRol();
            Estado = u.getEstado();
            nit = u.getNit_cliente();
        }
    }

%>

<script>
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
        <title>Actualizar Usuario</title>
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
            <input type="submit" value="HOME" onclick="navegarInternamente('https://spdique.com/')"/>
           <%
                Object rolObj = session.getAttribute("Rol");
                if (rolObj != null && ((Integer) rolObj) == 1) {
            %>
                <input type="submit" value="CREAR USUARIO" onclick="navegarInternamente('CrearUsuario.jsp')"/>
                <input type="submit" value="LISTAR USUARIOS" onclick="navegarInternamente('ListadoUsuarios.jsp')"/>
            <%
                }
            %>
            <input type="submit" value="LISTADOS DE CITAS" onclick="navegarInternamente('./Listados_Citas.jsp')"/>
            <input type="submit" value="CERRAR SESIÓN" onclick="window.location.href='../CerrarSeccion'"/>
        </div>
   </header>
    <body>
        <div class="Contenedor">
            <div class="version">
                <h1>ACTUALIZAR USUARIO</h1>
            </div>
            <form name="LoginForm" action="../ActualizarUsuarioServlet" method="POST" class="Formulario">
                <label for="Usuario">Nombre de usuario: </label>
                <input type="text" id="Usuario" name="Usuario" value="<%= usuario %>" oninput="this.value = this.value.replace(/[^a-zA-Z0-9]/g, '')" required />
                
                <label for="Contrasena">Contraseña</label>
                <input type="text" id="Contrasena" name="Contrasena" required/>
                
                <label for="Codigo">Codigo Usuario</label>
                <input type="text" id="Codigo" name="Codigo" value="<%= CodigoUsuario %>" required />
                
                <label for="NitCliente">Nit cliente</label>
                <input type="text" id="NitCliente" name="NitCliente"  value="<%= nit %>" oninput="this.value = this.value.replace(/[^0-9]/g, '')" required/>
                
                <label for="Email">Correro</label>
                <input type="email" id="Email" name="Email" value="<%= correo %>" required>
                
                <label for="Rol">Rol (Administrador - Usuario)</label>
                <% 
                    String RolText = "";
                    if(Rol == 1){
                        RolText = "Administrador";
                    }else{
                        RolText = "Usuario";
                    }
                %>
                
                <input type="text" name="Rol" value="<%= RolText %>" required/>
                
                <label for="Estado">Estado (Activo - Inactivo)</label>
                
                <%
                    String EstadoTexto = "";
                    if(Estado == 0){
                        EstadoTexto = "Activo";
                    }else{
                        EstadoTexto = "Inactivo";
                    }
                %>
                
                <input type="text" name="Estado" value="<%= EstadoTexto %>" required/>
                <input type="submit" value="Actualizar Usuario" />
                
            </form>
            
        </div>
    </body>
</html>
