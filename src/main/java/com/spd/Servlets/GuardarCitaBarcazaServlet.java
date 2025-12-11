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
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Scanner;
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
   
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    
    @Override
    public void init() throws ServletException {
        inicializarDesdeContexto(getServletContext());
    }

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
   
   
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONArray lista = new JSONArray();

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = "SELECT ID, BARCAZA, ESLORA, MANGA, POSINICIAL, POSFINAL, FEARRIBO, FEZARPE, ESTADO "
                       + "FROM SPD_POSICIONAMIENTO_BARCAZA "
                       + "WHERE ESTADO <> 'FINALIZADO'";

            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {

                JSONObject obj = new JSONObject();

                obj.put("id", rs.getString("ID"));
                obj.put("barcaza", rs.getString("BARCAZA"));
                obj.put("estado", rs.getString("ESTADO"));

                // ----- POSICIÓN -----
                JSONObject pos = new JSONObject();
                pos.put("inicio", rs.getInt("POSINICIAL"));
                pos.put("fin", rs.getInt("POSFINAL"));
                obj.put("posicion", pos);

                // ----- CITA ARRIBO -----
                Timestamp fArribo = rs.getTimestamp("FEARRIBO");
                JSONObject citaArribo = new JSONObject();
                if (fArribo != null) {
                    String[] partes = fArribo.toString().split(" ");
                    citaArribo.put("fecha", partes[0]);              // yyyy-MM-dd
                    citaArribo.put("hora", partes[1].substring(0,5)); // HH:mm
                } else {
                    citaArribo.put("fecha", JSONObject.NULL);
                    citaArribo.put("hora", JSONObject.NULL);
                }
                obj.put("citaArribo", citaArribo);

                // ----- CITA ZARPE -----
                Timestamp fZarpe = rs.getTimestamp("FEZARPE");
                JSONObject citaZarpe = new JSONObject();
                if (fZarpe != null) {
                    String[] partes = fZarpe.toString().split(" ");
                    citaZarpe.put("fecha", partes[0]);
                    citaZarpe.put("hora", partes[1].substring(0,5));
                } else {
                    citaZarpe.put("fecha", JSONObject.NULL);
                    citaZarpe.put("hora", JSONObject.NULL);
                }
                obj.put("citaZarpe", citaZarpe);

                lista.put(obj);
            }

            response.getWriter().write(lista.toString());

        } catch (Exception e) {

            e.printStackTrace();
            response.getWriter().write(
                new JSONObject().put("error", "Error al consultar BD: " + e.getMessage()).toString()
            );

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
   
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            // Leer JSON del body
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);

            JSONObject json = new JSONObject(sb.toString());

            // Datos principales
            String id = String.valueOf(json.getInt("id"));
            String barcaza = json.getString("barcaza");
            double eslora = json.getDouble("eslora");
            double manga = json.getDouble("manga");

            // Posiciones
            JSONObject pos = json.getJSONObject("posicion");
            int posInicial = pos.getInt("inicio");
            int posFinal = pos.getInt("fin");

            // FECHA ARRIBO
            Timestamp fechaArriboTS = null;
            JSONObject arribo = json.getJSONObject("citaArribo");

            if (arribo.has("fecha") && arribo.has("hora") &&
                !arribo.getString("fecha").isEmpty() &&
                !arribo.getString("hora").isEmpty()) {

                String f = arribo.getString("fecha"); // yyyy-MM-dd
                String h = arribo.getString("hora");  // HH:mm

                fechaArriboTS = Timestamp.valueOf(f + " " + h + ":00");
            }

            // FECHA ZARPE (puede venir vacío {})
            Timestamp fechaZarpeTS = null;

            if (json.has("citaZarpe")) {
                JSONObject zarpe = json.getJSONObject("citaZarpe");

                if (zarpe.has("fecha") && zarpe.has("hora") &&
                    !zarpe.getString("fecha").isEmpty() &&
                    !zarpe.getString("hora").isEmpty()) {

                    fechaZarpeTS = Timestamp.valueOf(
                        zarpe.getString("fecha") + " " + zarpe.getString("hora") + ":00"
                    );
                }
            }

            String estado = json.getString("estado");

            // ------------------ INSERT BD --------------------
            Connection conn = null;
            PreparedStatement pstmt = null;

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                String sql = "INSERT INTO SPD_POSICIONAMIENTO_BARCAZA "
                           + "(ID, BARCAZA, ESLORA, MANGA, POSINICIAL, POSFINAL, FEARRIBO, FEZARPE, ESTADO) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

                pstmt = conn.prepareStatement(sql);

                pstmt.setString(1, id);
                pstmt.setString(2, barcaza);
                pstmt.setDouble(3, eslora);
                pstmt.setDouble(4, manga);
                pstmt.setInt(5, posInicial);
                pstmt.setInt(6, posFinal);
                pstmt.setTimestamp(7, fechaArriboTS);
                pstmt.setTimestamp(8, fechaZarpeTS);
                pstmt.setString(9, estado);
                

                int insert = pstmt.executeUpdate();

                out.print(new JSONObject()
                    .put("success", true)
                    .put("message", "Cita guardada correctamente (" + insert + " fila).")
                );

            } catch (Exception e) {
                out.print(new JSONObject()
                    .put("success", false)
                    .put("message", "Error BD: " + e.getMessage() + "pstmt: " + pstmt)
                );
            } finally {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }

        } catch (Exception e) {
            out.print(new JSONObject()
                .put("success", false)
                .put("message", "Error procesando JSON: " + e.getMessage())
            );
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // ------------------ LEER JSON DE LA PETICIÓN ------------------
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                sb.append(line);
            }
            JSONObject json = new JSONObject(sb.toString());

            // Validar ID
            if (!json.has("id")) {
                throw new Exception("Falta el campo 'id'.");
            }

            String id = json.get("id").toString();
            String estado = json.optString("estado", null);

            // ------------------ PROCESAR FECHA ZARPE ------------------
            Timestamp fechaZarpeSQL = null;

            if (json.has("citaZarpe")) {
                JSONObject cz = json.getJSONObject("citaZarpe");
                if (cz.has("fecha") && cz.has("hora")) {
                    String fecha = cz.optString("fecha", "").trim();
                    String hora = cz.optString("hora", "").trim();

                    if (!fecha.isEmpty() && !hora.isEmpty()) {
                        fechaZarpeSQL = Timestamp.valueOf(fecha + " " + hora + ":00");
                    }
                }
            }

            // ------------------ ACTUALIZACIÓN EN LA BASE DE DATOS ------------------
            Connection conn = null;
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = "UPDATE SPD_POSICIONAMIENTO_BARCAZA "
                       + "SET FEZARPE = ?, ESTADO = ? "
                       + "WHERE ID = ?";

            PreparedStatement pstmt = conn.prepareStatement(sql);

            if (fechaZarpeSQL != null) {
                pstmt.setTimestamp(1, fechaZarpeSQL);
            } else {
                pstmt.setNull(1, java.sql.Types.TIMESTAMP);
            }

            pstmt.setString(2, estado);
            pstmt.setString(3, id);

            int rows = pstmt.executeUpdate();

            pstmt.close();
            conn.close();

            if (rows == 0) {
                throw new Exception("No se encontró la barcaza con id: " + id);
            }

            // ------------------ ACTUALIZACIÓN DEL ARCHIVO JSON ------------------
            ServletContext context = getServletContext();
            File file = new File(context.getRealPath("/WEB-INF/barcazamapa.json"));

            String contenidoJson = new String(Files.readAllBytes(file.toPath()));
            JSONArray arr = new JSONArray(contenidoJson);

            // buscar por ID
            for (int i = 0; i < arr.length(); i++) {
                JSONObject registro = arr.getJSONObject(i);

                if (registro.get("id").toString().equals(id)) {

                    // Guardar fecha de zarpe
                    if (fechaZarpeSQL != null) {
                        JSONObject cz = new JSONObject();
                        cz.put("fecha", json.getJSONObject("citaZarpe").getString("fecha"));
                        cz.put("hora", json.getJSONObject("citaZarpe").getString("hora"));
                        registro.put("citaZarpe", cz);
                    }

                    // Actualizar estado
                    registro.put("estado", estado);

                    // Si finaliza → eliminar posición
                    if ("Finalizado".equalsIgnoreCase(estado)) {
                        registro.remove("posicion");
                    }

                    break;
                }
            }

            // Guardar archivo JSON actualizado
            Files.write(file.toPath(), arr.toString(4).getBytes());

            // ------------------ RESPUESTA OK ------------------
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
