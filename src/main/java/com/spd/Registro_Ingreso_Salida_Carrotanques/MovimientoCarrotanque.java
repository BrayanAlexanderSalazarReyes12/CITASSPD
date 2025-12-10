/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Registro_Ingreso_Salida_Carrotanques;

import com.spd.FinalizarCitaAut.CitasAutomaticas;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class MovimientoCarrotanque {
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
    
    public void IngresoCarrotanque (String Codcita, String Placa, 
            String EmpresaTransportadora, String Estado) throws SQLException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "INSERT INTO SPD_MOVIMIENTOS_CARROTANQUES (COD_CITA,PLACA,EMPRESA_BAS,HORA_INGRESO,ESTADO) VALUES (?,?,?,?,?) ";
            
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, Codcita);
            pstmt.setString(2, Placa);
            pstmt.setString(3, EmpresaTransportadora);
            pstmt.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
            pstmt.setString(5, "ingresado");
            
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
    
    public void SalidaCarrotanque (String Codcita, String Placa, 
            String EmpresaTransportadora, String Estado) throws SQLException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "UPDATE SPD_MOVIMIENTOS_CARROTANQUES SET "
           + "HORA_SALIDA = ?, "
           + "ESTADO = ? "
           + "WHERE COD_CITA = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setTimestamp(1, new java.sql.Timestamp(System.currentTimeMillis())); // Hora actual
            pstmt.setString(2, "finalizado");
            pstmt.setString(3, Codcita); // Condición WHERE

            
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
    
    public List<InformacionCarrotanque> LectorMovCarrotanque() throws SQLException, IOException{
        List<InformacionCarrotanque> lista = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Consulta SQL
            String sql = "SELECT COD_CITA, PLACA, ESTADO\n" +
                        "FROM (\n" +
                        "    SELECT \n" +
                        "        COD_CITA,\n" +
                        "        PLACA,\n" +
                        "        ESTADO,\n" +
                        "        HORA_INGRESO,\n" +
                        "        ROW_NUMBER() OVER (PARTITION BY PLACA ORDER BY HORA_INGRESO DESC) AS rn\n" +
                        "    FROM SPD_MOVIMIENTOS_CARROTANQUES\n" +
                        "    WHERE TRUNC(HORA_INGRESO) BETWEEN TRUNC(SYSDATE - 1) AND TRUNC(SYSDATE)\n" +
                        ")\n" +
                        "WHERE rn = 1\n" +
                        "ORDER BY HORA_INGRESO DESC";

            pstmt = conn.prepareStatement(sql);

            rs = pstmt.executeQuery();

            // Procesar resultados
            while (rs.next()) {
                String codigoCita = rs.getString("COD_CITA");
                String placa = rs.getString("PLACA");
                String estado = rs.getString("ESTADO");

                InformacionCarrotanque mov = new InformacionCarrotanque(codigoCita, placa, estado);
                lista.add(mov);
            }

        } catch (ClassNotFoundException e) {
            log.log(Level.SEVERE, "❌ No se encontró el driver JDBC: {0}", e.getMessage());
        } catch (SQLException e) {
            log.log(Level.SEVERE, "❌ Error SQL al obtener información de la cita: {0}", e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }

        return lista;
    }
    
    private static final Logger log = Logger.getLogger(CitasAutomaticas.class.getName());
}
