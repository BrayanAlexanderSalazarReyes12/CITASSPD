    /*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.TiempoExtra;

import com.spd.FinalizarCitaAut.CitasAutomaticas;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.Date;
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
public class TiempoExtraDAO {
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
    
    public void REGISTROTIEMPOEXTRA(String nit_empresa, Date fechasolicitud,
            Date fechaservicio, String tipooperacion,
            String operacion, String observacion,
            String estado) throws SQLException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Consulta SQL
            String sql = "INSERT INTO SPD_TIEMPO_EXTRA (NIT_EMPRESA,FECHA_SOLICITUD,FECHA_SERVICIO,TIPO_OPERACION,OPERACION,OBSERVACION,ESTADO) VALUES "
                    + "(?,?,?,?,?,?,?)";
            
            pstmt = conn.prepareCall(sql);
            pstmt.setString(1, nit_empresa);
            pstmt.setDate(2, fechasolicitud);
            pstmt.setDate(3, fechaservicio);
            pstmt.setString(4, tipooperacion);
            pstmt.setString(5, operacion);
            pstmt.setString(6, observacion);
            pstmt.setString(7, estado);
            
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
    
    public List<TiempoExtra> ListaTiempoExtra () throws SQLException, IOException{
        List<TiempoExtra> lista = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT * FROM SPD_TIEMPO_EXTRA";
            
            pstmt = conn.prepareStatement(sql);

            rs = pstmt.executeQuery();
            
            // Procesar resultados
            while (rs.next()) {
                String nit = rs.getString("NIT_EMPRESA");
                Date fechasolicitud = rs.getDate("FECHA_SOLICITUD");
                Date fechaservicio = rs.getDate("FECHA_SERVICIO");
                String tipooperacion = rs.getString("TIPO_OPERACION");
                String Operacion = rs.getString("OPERACION");
                String observacion = rs.getString("OBSERVACION");
                String estado = rs.getString("ESTADO");
                TiempoExtra tm = new TiempoExtra(nit, fechasolicitud, fechaservicio, tipooperacion, Operacion, observacion, estado);
                lista.add(tm);
            }
        }catch (ClassNotFoundException e) {
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
    
    public void aprobacionTextrea (String usulogib, String nitempresa) throws SQLException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "UPDATE SPD_TIEMPO_EXTRA SET "
                    + "ESTADO = ? ,"
                    + " USU_APROBACION = ? "
                    + "WHERE "
                    + "NIT_EMPRESA = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "Aprobado"); // Hora actual
            pstmt.setString(2, usulogib);
            pstmt.setString(3, nitempresa); // Condición WHERE
            
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
