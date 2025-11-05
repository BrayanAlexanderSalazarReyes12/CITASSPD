<%-- 
    Document   : Hearder.jsp
    Created on : 27/10/2025, 09:33:05 AM
    Author     : Brayan Salazar
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<header>
    <div class="logo">
        <img src="./Imagenes/sociedad_portuaria_del_dique-.png" alt="Logo"/>
    </div>

    <div class="button-container">
       <%
            Object rolObj = session.getAttribute("Rol");
            if (rolObj != null && ((Integer) rolObj) == 1 && ((Integer) rolObj) != 6 && ((Integer) rolObj) != 7) {
        %>
            <input type="submit" value="Crear Usuario" onclick="navegarInternamente('./JSP/CrearUsuario.jsp')"/>
            <input type="submit" value="Crear Barcaza" onclick="navegarInternamente('./CrearBarcaza.jsp')"/>
            <input type="submit" value="Listar Usuarios" onclick="navegarInternamente('./JSP/ListadoUsuarios.jsp')"/>
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/> 
            <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('./ListarOperaciones')"/> 
            <input type="submit" value="Reporte Carrotanques I/S" onclick="navegarInternamente('./ReporteCitasIngreSalida')"/>
            <input type="submit" value="Listar Tiempo Extra" onclick="navegarInternamente('./JSP/ListadoTiempoExtra.jsp')"/>
        <%
            } else if(rolObj != null && ((Integer) rolObj) == 2){
        %>
            <input type="submit" value="Operaciones Activas" onclick="navegarInternamente('./JSP/OperacionesActivas.jsp')">
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/>
            <input type="submit" value="Solicitud Tiempo Extra" onclick="navegarInternamente('./JSP/SolicitudTiempoExtra.jsp')" style="display:none;"/>
        <%
            } else if (rolObj != null && ((Integer) rolObj) == 7){
        %>
            <input type="submit" value="Operaciones de Hoy" onclick="navegarInternamente('./JSP/ListarOperaciones')"/> 
        <%
            } else if (rolObj != null && ((Integer) rolObj) == 8){
        %>
            <input type="submit" value="Listado de Citas" onclick="navegarInternamente('./JSP/Listados_Citas.jsp')"/> 
        <%
            }
        %>
        <input type="submit" value="Cerrar Sesión" onclick="window.location.href='./CerrarSeccion'"/>
    </div>
</header>

<style>
:root {
    --color-boton-header: #89b61f;
    --color-boton-header-hover: #7da91b;
    --color-texto: #2c3e50;
}

/* === HEADER === */
header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 20px;
    background-color: white;
    gap: 10px;
}

.logo {
    flex: 0 0 auto;
    display: flex;
    align-items: center;
}

.logo img {
    height: 120px;
    max-width: 100%;
}

/* === CONTENEDOR DE BOTONES === */
.button-container {
    display: flex;
    flex-wrap: wrap; /* 🔥 Permite salto de línea */
    justify-content: flex-end; /* Alinea los botones a la derecha */
    align-items: center;
    gap: 15px;
    flex: 1 1 auto; /* Ocupa todo el espacio restante al lado del logo */
}

/* === BOTONES === */
.button-container input[type="submit"] {
    background-color: var(--color-boton-header);
    color: white;
    border: none;
    padding: 10px 20px;
    cursor: pointer;
    font-size: 16px;
    border-radius: 5px;
    width: auto;
    font-weight: 600;
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
    white-space: nowrap; /* Evita que se corten los textos */
}

.button-container input[type="submit"]:hover {
    background-color: var(--color-boton-header-hover);
    transform: translateY(-2px);
}

/* === RESPONSIVE === */
@media screen and (max-width: 1024px) {
    .logo img {
        height: 100px;
    }

    header {
        justify-content: flex-start;
    }

    .button-container {
        justify-content: flex-end;
        gap: 10px;
    }
}

@media screen and (max-width: 768px) {
    header {
        flex-wrap: wrap; /* Permite que los botones bajen si no caben */
        flex-direction: row;
        align-items: flex-start;
    }

    .button-container {
        width: 100%;
        justify-content: flex-start;
    }

    .button-container input[type="submit"] {
        flex: 1 1 45%; /* 🔥 Ocupa casi la mitad del ancho, formando filas limpias */
        text-align: center;
        font-size: 15px;
    }

    .logo img {
        height: 90px;
    }
}

@media screen and (max-width: 480px) {
    .button-container input[type="submit"] {
        flex: 1 1 100%;
        font-size: 14px;
        padding: 8px 12px;
    }

    .logo img {
        height: 80px;
    }
}
</style>

