<%-- 
    Document   : DescargarRemision
    Created on : jul 10, 2025, 10:14:42 a.m.
    Author     : braya
--%>

<%@page import="java.io.OutputStream"%>
<%@page import="java.util.Base64"%>
<%@page import="java.io.*" %>

<%
    String nombre = request.getParameter("nombre");
    String ruta = request.getParameter("ruta");

    if (ruta != null && nombre != null) {
        File archivo = new File(ruta);

        if (archivo.exists() && archivo.isFile()) {
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment;filename=\"" + nombre + "\"");
            response.setContentLength((int) archivo.length());

            FileInputStream fis = new FileInputStream(archivo);
            OutputStream os = response.getOutputStream();

            byte[] buffer = new byte[4096];
            int bytesRead;

            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }

            fis.close();
            os.flush();
            os.close();
        } else {
            out.println("Error: archivo no encontrado en la ruta especificada.");
        }
    } else {
        out.println("Error: parámetros 'nombre' o 'ruta' faltantes.");
    }
%>
