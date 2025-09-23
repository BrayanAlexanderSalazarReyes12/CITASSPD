/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.informacionCita;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class MaxCITA {
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    
    /**
     * Inicializa las variables de conexión desde un archivo JSON ubicado en /WEB-INF/json.env
     */
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
    
    public static String maxcita() throws  SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String cita = "";
        try{
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT MAX(COD_CITA) AS MAXCITA FROM SPD_CITAS";
            
            pstmt = conn.prepareCall(sql);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                cita = rs.getString("MAXCITA");
            }
            
        }catch (ClassNotFoundException e) {
            System.err.println("❌ No se encontró el driver JDBC: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Error SQL al obtener información de la cita: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
        
        return cita;
    }
}
