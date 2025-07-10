<%-- 
    Document   : DescargarRemision
    Created on : jul 10, 2025, 10:14:42 a.m.
    Author     : braya
--%>

<%@page import="java.io.OutputStream"%>
<%@page import="java.util.Base64"%>

<%
    String nombre = request.getParameter("nombre");
    String base64 = request.getParameter("base64");

    if (base64 != null && nombre != null) {
        // Eliminar encabezado si lo tiene
        base64 = base64.replaceFirst("^data:application/pdf;base64,", "");

        byte[] decodedBytes = Base64.getDecoder().decode(base64);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment;filename=\"" + nombre + "\"");
        response.setContentLength(decodedBytes.length);

        OutputStream os = response.getOutputStream();
        os.write(decodedBytes);
        os.flush();
        os.close();
    } else {
        out.println("Error: archivo no disponible.");
    }
%>
