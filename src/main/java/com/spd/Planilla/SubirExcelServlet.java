/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Planilla;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 1024 * 1024 * 10,  // 10MB
    maxRequestSize = 1024 * 1024 * 15 // 15MB
)
public class SubirExcelServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Part archivoExcel = request.getPart("archivoExcel");
        String empresa = request.getParameter("empresa");
        if (empresa == null) empresa = "SIN_EMPRESA";

        String sysdate = new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date());

        if (archivoExcel == null || archivoExcel.getSize() == 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("No se recibió ningún archivo");
            return;
        }

        String nombreOriginal = getFileName(archivoExcel);
        if (nombreOriginal == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("No se pudo obtener el nombre del archivo");
            return;
        }

        String extension = nombreOriginal.substring(nombreOriginal.lastIndexOf("."));
        if (!extension.equalsIgnoreCase(".xls") && !extension.equalsIgnoreCase(".xlsx")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Solo se permiten archivos Excel (.xls, .xlsx)");
            return;
        }

        String nombreArchivo = empresa + "_" + sysdate + extension;

        // Ruta principal SPDCITAS
        File carpetaPrincipal = new File("E:/T/SPDCITAS");

        // Subcarpeta SOLICITADASPORPLANILLA dentro de SPDCITAS
        File carpetaSolicitadas = new File(carpetaPrincipal, "SOLICITADASPORPLANILLA");

        // Crear carpetas si no existen
        if (!carpetaPrincipal.exists()) carpetaPrincipal.mkdirs();
        if (!carpetaSolicitadas.exists()) carpetaSolicitadas.mkdirs();

        // Crear subcarpeta del usuario dentro de SOLICITADASPORPLANILLA
        File carpetaUsuario = new File(carpetaSolicitadas, empresa);
        if (!carpetaUsuario.exists()) carpetaUsuario.mkdirs();

        // Archivo destino
        File archivoDestino = new File(carpetaUsuario, nombreArchivo);

        try (InputStream input = archivoExcel.getInputStream()) {

            Files.copy(input, archivoDestino.toPath(), StandardCopyOption.REPLACE_EXISTING);

        } catch (IOException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error al guardar el archivo: " + e.getMessage());
            return;
        }

        // Respuesta
        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write(nombreArchivo);

    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return null;

        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}