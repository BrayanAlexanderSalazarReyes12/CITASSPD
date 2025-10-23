<%-- 
    Document   : SolicitudTiempoExtra
    Created on : 21/10/2025, 10:55:15 AM
    Author     : Brayan Salazar
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script>
    function closeModal() {
        document.getElementById("deleteModal").style.display = "none";
    }
    
    function navegarInternamente(url) {
        sessionStorage.setItem("navegandoInternamente", "true");
        window.location.href = url;
    }
    
    document.addEventListener("DOMContentLoaded", function () {
        sessionStorage.setItem("ventanaActiva", "true");
    });

    window.addEventListener("beforeunload", function (e) {
        const navEntry = performance.getEntriesByType("navigation")[0];

        if (navEntry && navEntry.type === "navigate") {
            return;
        }
        
        if (navEntry && navEntry.type === "reload") {
            return;
        }

        if (sessionStorage.getItem("navegandoInternamente") === "true") {
            sessionStorage.setItem("navegandoInternamente", "false");
            return;
        }

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
    <title>Solicitud Tiempo Extra</title>
    <link rel="stylesheet" href="../CSS/Formulario.css"/>
    <link rel="stylesheet" href="../CSS/Login.css"/>
    <link rel="stylesheet" href="../CSS/TipoOperacion.css"/>
    <link rel="stylesheet" href="../CSS/Styles_modal.css"/>
    <style>
        /* Aquí solo estilos para centrar y tarjeta del formulario */
        body {
            background-color: #f0f2f5;
            margin: 0;
            font-family: Arial, sans-serif;
        }
        .main-content {
            display: flex;
            justify-content: center;
            align-items: center;
            height: calc(100vh - 80px); /* Suponiendo header ocupa unos 80px */
            padding: 20px;
        }
        .contenedor-formulario {
            background-color: white;
            padding: 30px 40px;
            border-radius: 15px;
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
            width: 450px;
        }
        .contenedor-formulario h2 {
            margin-bottom: 20px;
            color: #333;
        }
        .contenedor-formulario table {
            width: 100%;
            border-spacing: 10px 12px;
        }
        .contenedor-formulario label {
            font-weight: 600;
            color: #444;
            vertical-align: middle;
        }
        .contenedor-formulario input[type="text"],
        .contenedor-formulario input[type="date"],
        .contenedor-formulario select,
        .contenedor-formulario textarea {
            width: 100%;
            padding: 8px 10px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
            font-size: 14px;
            resize: vertical;
        }
        .contenedor-formulario input[type="checkbox"] {
            transform: scale(1.2);
            margin-left: 8px;
            vertical-align: middle;
        }
        .botones {
            margin-top: 25px;
            display: flex;
            gap: 10px;
        }
        .botones input[type="submit"] {
            flex: 1;
            background-color: #8cbf26;
            border: none;
            color: white;
            padding: 12px 0;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .botones input[type="submit"]:hover {
            background-color: #7aae21;
        }
        .botones input[type="reset"] {
            flex: 1;
            background-color: #f2f2f2;
            border: 1px solid #ccc;
            color: #555;
            padding: 12px 0;
            border-radius: 8px;
            cursor: pointer;
        }
        .botones input[type="reset"]:hover {
            background-color: #e6e6e6;
        }
    </style>
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
       <%
            Object rolObj = session.getAttribute("Rol");
            if (rolObj != null && ((Integer) rolObj) == 1 && ((Integer) rolObj) != 6 && ((Integer) rolObj) != 7) {
        %>
            <input type="submit" value="Crear Usuario" onclick="navegarInternamente('CrearUsuario.jsp')"/>
            <input type="submit" value="Listar Usuarios" onclick="navegarInternamente('ListadoUsuarios.jsp')"/>
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/> 
            <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('../ListarOperaciones')"/> 
            <input type="submit" value="Reporte Carrotanques I/S" onclick="navegarInternamente('../ReporteCitasIngreSalida')"/>
        <%
            }else if(rolObj != null && ((Integer) rolObj) == 2){
        %>
            <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('../JSP/OperacionesActivas.jsp')">
        <%
            }else if (rolObj != null && ((Integer) rolObj) == 7){
        %>
            <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('../ListarOperaciones')"/> 
        <%
            }else if (rolObj != null && ((Integer) rolObj) == 8){
        %>
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/> 
        <%
            }
        %>
        <input type="submit" value="Listado de Citas" onclick="navegarInternamente('../JSP/Listados_Citas.jsp')"/> 
        <input type="submit" value="Cerrar Sesión" onclick="window.location.href='../CerrarSeccion'"/>
    </div>
</header>

<%
    Object rolObject1 = session.getAttribute("Rol");
    if(rolObject1 == null) {
        Cookie[] cookies3 = request.getCookies();
        if (cookies3 != null) {
            for (Cookie cookie : cookies3) {
                cookie.setMaxAge(0);
                cookie.setPath("/CITASSPD");
                response.addCookie(cookie);
            }
        }
        session.invalidate();
        response.sendRedirect(request.getContextPath());
        return;
    }
%>

<body>
    <div class="main-content">
        <div class="contenedor-formulario">
            <h2>Solicitud Tiempo Extra</h2>
            <%
                String nitEmpresa = "";
                Cookie[] cookies4 = request.getCookies();
                if (cookies != null) {
                    for (javax.servlet.http.Cookie cookie : cookies4) {
                        if ("DATA".equals(cookie.getName())) {
                            nitEmpresa = cookie.getValue();
                            break;
                        }
                    }
                }
            %>

            <form action="../RegistrarSolicitudTiempoExtra" method="post">
                <table>
                    <tr>
                        <td><label for="fechaSolicitud">Fecha Solicitud</label></td>
                        <td><input type="text" id="fechaSolicitud" name="fechaSolicitud" 
                                   value="<%= new java.text.SimpleDateFormat("MM/dd/yyyy").format(new java.util.Date()) %>" 
                                   readonly></td>

                        <td><label for="fechaServicio">Fecha Servicio</label></td>
                        <td><input type="date" id="fechaServicio" name="fechaServicio" required></td>
                    </tr>

                    <tr>
                        <td><label for="tipoOperacion">Tipo de Operación</label></td>
                        <td>
                            <input type="checkbox" id="tiempoExtraordinario" name="tiempoExtraordinario" value="tiempoExtraordinario">
                            <label for="tiempoExtraordinario">Tiempo Extraordinario</label>
                        </td>

                        <td><label for="aprobacionDoc">Aprobación de Documento</label></td>
                        <td>
                            <input type="checkbox" id="aprobacionDoc" name="aprobacionDoc" value="aprobacionDoc">
                        </td>
                    </tr>

                    <tr>
                        <td><label for="operacion">Operación</label></td>
                        <td colspan="3">
                            <select id="operacion" name="operacion" required>
                                <option value="">[Seleccione]</option>
                                <option value="Ingreso">Ingreso</option>
                                <option value="Salida">Salida</option>
                            </select>
                        </td>
                    </tr>

                    <tr>
                        <td><label for="observacion">Observación</label></td>
                        <td colspan="3">
                            <textarea id="observacion" name="observacion" rows="4" cols="60"></textarea>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="3">
                            <input type="hidden" name="empresa" value="<%= nitEmpresa %>">
                        </td>
                    </tr>
                </table>

                <div class="botones">
                    <input type="submit" value="Guardar">
                    <input type="reset" value="Limpiar">
                </div>
            </form>

        </div>
    </div>
</body>
</html>

