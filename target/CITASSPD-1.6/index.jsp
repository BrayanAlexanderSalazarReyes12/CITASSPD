<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>CITAS SPD</title>
        <link rel="stylesheet" href="CSS/Login.css"/>
        <link rel="stylesheet" href="CSS/Styles_modal.css"/>
    </head>
    <header>
        <div class="logo">
            <img src="Imagenes/sociedad_portuaria_del_dique-.png" alt="Logo"/>
        </div>
        <div class="button-container">
            <input type="submit" value="Home" onclick="window.location.href='https://spdique.com/'"/>
        </div>
    </header>
    <body>
        <div class="Contenedor">
            <div class="version">
                <h1>SOLICITUD DE CITAS - INICIAR SESIÓN</h1>
            </div>
            <form name="LoginForm" action="./Iniciar_Seccion_Servlet" method="POST" class="Formulario">
                <label for="Usuario">Nombre de usuario: </label>
                <input type="text" id="Usuario" name="Usuario" required />

                <label for="Contrasena">Contraseña: </label>
                <input type="password" id="Contrasena" name="Contrasena" required />

                <input type="submit" value="Iniciar Sesión" />
                <%
                    //<input type="button" value="Crear Usuario" />
                %>
            </form>
            <%
                Cookie[] cookies = request.getCookies();
                response.setContentType("text/html");
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        if(cookie.getName().equals("SeccionIniciada")){
                            response.sendRedirect("./JSP/TipoOperaciones.jsp"); // Redirige si la sesión está iniciada
                        }
                        if(cookie.getName().equals("ErrorConUser")){
                        %>
                           <jsp:include page='JSP/Modal.jsp'/> 
                        <%
                            cookie.setValue(""); // Vaciar el valor
                            cookie.setMaxAge(0); // Expirar inmediatamente
                            cookie.setPath("/"); // Asegurar que se elimine en todo el dominio
                            response.addCookie(cookie); // Agregar la cookie modificada a la respuesta
                        }
                    }
                }
            %>
            <div class="version">
                <h4>VERSION: 1.8</h4>
            </div>
        </div>
       
    </body>
</html>
