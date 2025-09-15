/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CItasDB;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.Scanner;
import javax.servlet.ServletContext;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class ListaCitasBarcaza {
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
    
    public JSONArray filtroBarcaza() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        JSONArray resultado = new JSONArray();

        try {
            // Carga del driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = 
                            "SELECT " +
                            "    BARCAZA, " +
                            "    ESLORA, " +
                            "    MANGA " +
                            "FROM SPD_MAESTROBARCAZA";


            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                JSONObject obj = new JSONObject();
                obj.put("BARCAZA", rs.getString("BARCAZA"));
                obj.put("ESLORA", rs.getBigDecimal("ESLORA"));
                obj.put("MANGA", rs.getBigDecimal("MANGA"));

                resultado.put(obj);
            }

        } catch (ClassNotFoundException e) {
            System.err.println("❌ No se encontró el driver JDBC: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Error SQL: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }

        return resultado;
    }

}
