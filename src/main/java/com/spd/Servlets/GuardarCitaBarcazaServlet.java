/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class GuardarCitaBarcazaServlet extends HttpServlet {

   private static final String FILE_PATH = "/WEB-INF/barcazamapa.json"; 
   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        ServletContext context = getServletContext();
        InputStream is = context.getResourceAsStream("/WEB-INF/barcazamapa.json");

        if (is != null) {
            String json = inputStreamToString(is);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("{\"error\": \"Archivo no encontrado\"}");
        }
    }

   
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        ServletContext context = getServletContext();

        try {
            // Leer el JSON recibido
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            JSONObject nuevaCita = new JSONObject(sb.toString());

            // Ruta real del archivo (para escribir)
            String realPath = context.getRealPath(FILE_PATH);
            File file = new File(realPath);

            JSONArray citas;

            // Leer archivo existente con getResourceAsStream
            try (InputStream is = context.getResourceAsStream(FILE_PATH)) {
                if (is != null) {
                    BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8));
                    StringBuilder contentBuilder = new StringBuilder();
                    
                    while ((line = reader.readLine()) != null) {
                        contentBuilder.append(line);
                    }
                    String content = contentBuilder.toString().trim();
                    citas = content.isEmpty() ? new JSONArray() : new JSONArray(content);
                } else {
                    citas = new JSONArray();
                }
            }

            // Agregar nueva cita
            citas.put(nuevaCita);

            // Guardar nuevamente en archivo
            Files.write(file.toPath(), citas.toString(2).getBytes(StandardCharsets.UTF_8));

            // Respuesta
            JSONObject resp = new JSONObject();
            resp.put("status", "success");
            resp.put("message", "Cita guardada en json.env");
            out.print(resp.toString());

        } catch (Exception e) {
            e.printStackTrace();
            JSONObject resp = new JSONObject();
            resp.put("status", "error");
            resp.put("message", e.getMessage());
            out.print(resp.toString());
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        ServletContext context = getServletContext();

        try {
            // Leer JSON recibido
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            JSONObject nuevaCita = new JSONObject(sb.toString());

            // Obtener ruta del archivo
            String realPath = context.getRealPath(FILE_PATH);
            File file = new File(realPath);

            JSONArray citas;

            // Leer archivo existente
            try (InputStream is = context.getResourceAsStream(FILE_PATH)) {
                if (is != null) {
                    try (BufferedReader reader = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
                        StringBuilder contentBuilder = new StringBuilder();
                        while ((line = reader.readLine()) != null) {
                            contentBuilder.append(line);
                        }
                        String content = contentBuilder.toString().trim();
                        citas = content.isEmpty() ? new JSONArray() : new JSONArray(content);
                    }
                } else {
                    citas = new JSONArray();
                }
            }

            // Validar que venga el ID
            if (!nuevaCita.has("id")) {
                throw new Exception("Falta el campo 'id' en la cita.");
            }

            int idNueva = nuevaCita.getInt("id");
            
            System.out.println(idNueva);
            
            boolean encontrada = false;

            // Buscar la cita existente y actualizar solo campos específicos
            for (int i = 0; i < citas.length(); i++) {
                JSONObject citaExistente = citas.getJSONObject(i);

                if (citaExistente.has("id") && citaExistente.getInt("id") == idNueva) {
                    // ✅ Solo actualizar los campos necesarios
                    if (nuevaCita.has("citaZarpe")) {
                        citaExistente.put("citaZarpe", nuevaCita.getJSONObject("citaZarpe"));
                    }
                    if (nuevaCita.has("estado")) {
                        citaExistente.put("estado", nuevaCita.getString("estado"));
                    }

                    // Guardar los cambios
                    citas.put(i, citaExistente);
                    encontrada = true;
                    break;
                }
            }


            if (!encontrada) {
                throw new Exception("No se encontró ninguna cita con id: " + idNueva);
            }

            // Asegurar que la carpeta exista
            File parentDir = file.getParentFile();
            if (parentDir != null && !parentDir.exists()) {
                parentDir.mkdirs();
            }

            // Guardar JSON actualizado
            Files.write(file.toPath(), citas.toString(2).getBytes(StandardCharsets.UTF_8));

            // Respuesta
            JSONObject resp = new JSONObject();
            resp.put("status", "success");
            resp.put("message", "Cita actualizada correctamente");
            out.print(resp.toString());

        } catch (Exception e) {
            e.printStackTrace();
            JSONObject resp = new JSONObject();
            resp.put("status", "error");
            resp.put("message", e.getMessage());
            out.print(resp.toString());
        }
    }


    
    private String inputStreamToString(InputStream is) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

}
