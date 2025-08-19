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
import java.sql.Timestamp;
import java.util.Scanner;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class InformacionPesajeFinalizacionCIta {
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
    
    public static CitaInfo InformacionPeosFinalizacionCIta(String CODCITA) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        CitaInfo citaInfo = null;
        
        try {
            // Carga del driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Consulta SQL
            String sql = "SELECT " +
                    "    a.COD_CITA, " +
                    "    a.NMFORM_ZF AS NMFORM_CITA, " +
                    "    b.NMFORM_ZF AS NMFORM_BASCULA, " +
                    "    b.NUM_TICKETE, " +
                    "    b.HORA_ENTRADA, " +
                    "    b.PESO_INGRESO, " +
                    "    b.HORA_SALIDA, " +
                    "    b.PESO_SALIDA, " +
                    "    c.PLACA " +
                    "FROM SPD_CITAS a " +
                    "INNER JOIN SPD_CITA_VEHICULOS d ON a.COD_CITA = d.COD_CITA " +
                    "INNER JOIN VEHICULO_BASC c ON d.PLACA = c.PLACA " +
                    "INNER JOIN TRAN_BASCULA b ON a.NMFORM_ZF = b.NMFORM_ZF " +
                    "   AND c.ID_VEHICULO = b.VEHICULO_ID_VEHICULO " +
                    "WHERE a.COD_CITA = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, CODCITA);

            rs = pstmt.executeQuery();

            while (rs.next()) {
                if (rs.next()) {
                    citaInfo = new CitaInfo();
                    citaInfo.setCodCita(rs.getString("COD_CITA"));
                    citaInfo.setNmformCita(rs.getString("NMFORM_CITA"));
                    citaInfo.setNmformBascula(rs.getString("NMFORM_BASCULA"));
                    citaInfo.setNumTicket(rs.getString("NUM_TICKETE"));
                    citaInfo.setFechaEntrada(rs.getTimestamp("HORA_ENTRADA"));
                    citaInfo.setPesoIngreso(rs.getDouble("PESO_INGRESO"));
                    citaInfo.setFechaSalida(rs.getTimestamp("HORA_SALIDA"));
                    citaInfo.setPesoSalida(rs.getDouble("PESO_SALIDA"));
                    citaInfo.setPlaca(rs.getString("PLACA"));
                }
            }

        } catch (ClassNotFoundException e) {
            System.err.println("❌ No se encontró el driver JDBC: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Error SQL al obtener información de la cita: " + e.getMessage());
            throw e;
        } finally {
            // Cierre de recursos
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
        
        return citaInfo;
    }

}
