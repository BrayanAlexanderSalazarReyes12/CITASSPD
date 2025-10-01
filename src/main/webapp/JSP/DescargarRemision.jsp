<%-- 
    Document   : DescargarRemision
    Created on : jul 10, 2025, 10:14:42 a.m.
    Author     : braya
--%>

<%@ page import="java.io.*" %>
<%
    // Obtener nombre del archivo desde parámetro
    String nombre = request.getParameter("nombre");

    if (nombre != null && !nombre.trim().isEmpty()) {
        // Evitar saltos de línea y espacios extra
        nombre = nombre.replaceAll("[\\n\\r]", "").trim();

        // Ruta absoluta en el disco E:
        String ruta = "E:\\T\\SPD\\" + nombre+".pdf";
        File archivo = new File(ruta);

        if (archivo.exists() && archivo.isFile()) {
            // Preparar la respuesta HTTP para descargar PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment;filename=\"" + archivo.getName() + "\"");
            response.setContentLength((int) archivo.length());

            FileInputStream fis = null;
            OutputStream os = null;
            try {
                fis = new FileInputStream(archivo);
                os = response.getOutputStream();

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
                os.flush();
            } catch (Exception e) {
                out.println("Error leyendo archivo: " + e.getMessage());
            } finally {
                if (fis != null) try { fis.close(); } catch (Exception e) {}
                // No cerramos os, es el stream de la respuesta
            }
        } else {
            out.println("Error: archivo no encontrado en la ruta -> " + ruta + "<br>");
            out.println("Verifica que Tomcat tenga acceso a la unidad E: y al archivo.");
        }
    } else {
        out.println("Error: parámetro 'nombre' faltante o vacío.");
    }
%>
