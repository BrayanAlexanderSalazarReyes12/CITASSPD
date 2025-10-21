<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>CITAS SPD</title>
    <link rel="stylesheet" href="CSS/Login.css"/>
    <link rel="stylesheet" href="CSS/Styles_modal.css"/>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        // Cuando se cargue la página, se borra todo el localStorage
        window.onload = function() {
            localStorage.clear();
        };
    </script>
</head>

<header>
    <div class="logo">
        <img src="Imagenes/sociedad_portuaria_del_dique-.png" alt="Logo"/>
    </div>
    <div class="button-container">
        <input type="submit" value="Home" onclick="window.location.href='httpsique.com/'"/>
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
    
    <script>
        // Mostrar SweetAlert2 al cargar la página
        /*
        window.onload = function() {
            Swal.fire({
                title: '📢 Actualización Importante',
                html: `
                    <p style="text-align:left">
                        A partir de ahora, el programa de citas <b>envía automáticamente un correo a lreyes@spdique.com</b> 
                        informando sobre cada cita creada, para que ella pueda proceder con su <b>aprobación</b>.
                    </p>
                    <p style="text-align:left">
                        ✅ Esta mejora garantiza un mejor control y seguimiento de las solicitudes.
                    </p>
                `,
                icon: 'info',
                confirmButtonText: 'Entendido',
                confirmButtonColor: '#003366',
                backdrop: true,
                allowOutsideClick: true
            });
        }
         */
    </script>
</body>
</html>

