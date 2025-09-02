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
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
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
    
    public static List<CitaInfo> InformacionPesosFinalizacionCita(
        String placa, 
        String cedula, 
        Date fechaInicio) throws SQLException {

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<CitaInfo> listaCitas = new ArrayList<>();

        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Consulta fija con selección de la primera fila según FECHA_ENTRADA
            String sql = "SELECT * FROM (" +
                         "    SELECT v.ID_VEHICULO, " +
                         "           v.PLACA, " +
                         "           v.CEDULA, " +
                         "           t.NMFORM_ZF, " +
                         "           t.HORA_ENTRADA, " +
                         "           t.HORA_SALIDA, " +
                         "           t.PESO_INGRESO, " +
                         "           t.PESO_SALIDA " +
                         "    FROM VEHICULO_BASC v " +
                         "    JOIN TRAN_BASCULA t " +
                         "      ON v.ID_VEHICULO = t.VEHICULO_ID_VEHICULO " +
                         "    WHERE v.PLACA = ? " +
                         "      AND v.CEDULA = ? " +
                         "      AND t.FECHA_ENTRADA BETWEEN ? AND SYSDATE " +
                         "    ORDER BY t.FECHA_ENTRADA ASC" +
                         ") WHERE ROWNUM = 1";


            pstmt = conn.prepareStatement(sql);

            // Asignar parámetros
            pstmt.setString(1, placa);
            pstmt.setString(2, cedula);
            pstmt.setDate(3, new java.sql.Date(fechaInicio.getTime())); // Fecha inicio

            rs = pstmt.executeQuery();

            while (rs.next()) {
                CitaInfo citaInfo = new CitaInfo();
                citaInfo.setPlaca(rs.getString("PLACA"));
                citaInfo.setNmformBascula(rs.getString("NMFORM_ZF"));
                citaInfo.setFechaEntrada(rs.getTimestamp("HORA_ENTRADA"));
                citaInfo.setFechaSalida(rs.getTimestamp("HORA_SALIDA"));
                citaInfo.setPesoIngreso(rs.getDouble("PESO_INGRESO"));
                citaInfo.setPesoSalida(rs.getDouble("PESO_SALIDA"));

                listaCitas.add(citaInfo);
            }

        } catch (ClassNotFoundException e) {
            System.err.println("❌ No se encontró el driver JDBC: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Error SQL al obtener información de la cita: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }

        return listaCitas;
    }

}

