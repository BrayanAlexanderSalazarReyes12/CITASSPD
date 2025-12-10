/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CreadorCitaJSON;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class SincronizadorCitas {
    private static final String URL_CITAS = "http://www.siza.com.co/spdcitas-1.0/api/citas/";
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    
    public static void inicializarDesdeContexto(ServletContext context) {
        try {
            InputStream is = context.getResourceAsStream("/WEB-INF/json.env");
           
            if (is == null) {
                throw new RuntimeException("Archivo json.env no encontrado en /WEB-INF");
            }

            Scanner scanner = new Scanner(is, "UTF-8").useDelimiter("\\A");
            String content = scanner.hasNext() ? scanner.next() : "";
            scanner.close();

            JSONObject jsonEnv = new JSONObject(content);
            DB_URL = jsonEnv.optString("DB_URL");
            DB_USER = jsonEnv.optString("DB_USER");
            DB_PASSWORD = jsonEnv.optString("DB_PASSWORD");
            
            System.out.println("✅ Variables de conexión cargadas desde json.env");
        } catch (Exception e) {
            System.err.println("❌ Error leyendo json.env desde contexto: " + e.getMessage());
        }
    }
    
    // ******************************
    //   SE EJECUTA CADA 1 MINUTO
    // ******************************
    public static void ejecutar(ServletContext context) {
        try {
            String path = context.getRealPath("/data_pendiente/");
            File directory = new File(path);

            if (!directory.exists()) directory.mkdirs();

            File[] archivos = directory.listFiles((dir, name) -> name.endsWith(".json"));

            // No hay archivos → NO hace nada
            if (archivos == null || archivos.length == 0) {
                System.out.println("[SINCRONIZADOR] No hay archivos pendientes");
                return;
            }

            System.out.println("[SINCRONIZADOR] Archivos encontrados: " + archivos.length);

            for (File archivo : archivos) {
                procesarArchivo(archivo);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Procesar cada archivo JSON
    private static void procesarArchivo(File archivo) throws Exception {

        String nombre = archivo.getName();  // ejemplo: cita_Juan1234.json

        // Extraer usuario y codcita
        String sinExt = nombre.replace("cita_", "").replace(".json", "");
        String usuario = sinExt.replaceAll("[0-9]+$", "");
        String codcita = sinExt.substring(usuario.length());

        // 1. Revisar si existe en la BD
        if (codCitaExiste(codcita)) {
            System.out.println("[SINCRONIZADOR] CODCITA " + codcita + " YA existe → eliminando respaldo.");
            archivo.delete();
            return;
        }

        // 2. Leer JSON del archivo
        String json = leerArchivo(archivo);

        // 3. Enviar a API
        String respuesta = enviarPOST(URL_CITAS, json);

        System.out.println("[SINCRONIZADOR] Respuesta API: " + respuesta);

        // 4. Si fue exitosa → borrar archivo
        if (respuesta != null && !respuesta.isEmpty()) {
            archivo.delete();
            System.out.println("[SINCRONIZADOR] Sincronización ok → archivo eliminado");
        }
    }

    // Verificar si CODCITA ya existe
    private static boolean codCitaExiste(String cod) {

        String sql = "SELECT COUNT(*) FROM SPD_CITAS WHERE COD_CITA = ?";

        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión + PreparedStatement + ResultSet con try-with-resources
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, cod);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1) > 0;  // Ya existe en la BD
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace(); // Puedes reemplazarlo con logger
        }

        return false; // No existe o error
    }


    private static String leerArchivo(File archivo) throws IOException {
        return new String(java.nio.file.Files.readAllBytes(archivo.toPath()), StandardCharsets.UTF_8);
    }

    private static String enviarPOST(String url, String json) throws IOException {

        java.net.HttpURLConnection conn =
                (java.net.HttpURLConnection) new java.net.URL(url).openConnection();

        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");

        // Enviar JSON
        try (OutputStream os = conn.getOutputStream()) {
            os.write(json.getBytes("UTF-8"));
        }

        // Leer respuesta
        InputStream is = conn.getResponseCode() >= 400 ?
                conn.getErrorStream() : conn.getInputStream();

        return inputStreamToString(is);
    }
    
    private static String inputStreamToString(InputStream is) throws IOException {
        ByteArrayOutputStream result = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int length;

        while ((length = is.read(buffer)) != -1) {
            result.write(buffer, 0, length);
        }

        return result.toString("UTF-8");
    }

}
