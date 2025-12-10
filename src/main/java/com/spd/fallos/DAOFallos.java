/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.fallos;

import com.spd.FinalizarCitaAut.CitasAutomaticas;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class DAOFallos {
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
    
    public void REGISTRARFALLOS (String usuario, String Fallo, String json) throws SQLException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
             // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "INSERT INTO SPD_FALLOS_GUARDARCITA (USUARIO,FALLO,JSON) VALUES (?,?,?)";
            
            pstmt = conn.prepareCall(sql);
            pstmt.setString(1, usuario);
            pstmt.setString(2, Fallo);
            pstmt.setString(3, json);
            
            // Ejecutar inserción
            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                log.info("✅ Inserción realizada correctamente.");
            } else {
                log.warning("⚠️ No se insertaron filas.");
            }
            
        }catch (ClassNotFoundException e) {
            log.log(Level.SEVERE, "\u274c No se encontr\u00f3 el driver JDBC: {0}", e.getMessage());
        } catch (SQLException e) {
            log.log(Level.SEVERE, "\u274c Error SQL al obtener informaci\u00f3n de la cita: {0}", e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }
    
    private static final Logger log = Logger.getLogger(CitasAutomaticas.class.getName());
}
