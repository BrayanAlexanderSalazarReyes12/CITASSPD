/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.reportes;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import org.json.JSONObject;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 *
 * @author Brayan Salazar
 */
public class ReporteCarrotanques {
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
    
    public void reporte(String fechainical, String fechafinal) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = "SELECT \n" +
                    "    SCV.PLACA,\n" +
                    "    SCV.CEDULA_CONDUCTOR,\n" +
                    "    SCV.NOMBRE_CONDUCTOR,\n" +
                    "    SCV.COD_CITA,\n" +
                    "    SCV.HORA_CITAS,\n" +
                    "    SCV.USU_FINALIZACION,\n" +
                    "    SCV.FE_FINALIZACION,\n" +
                    "    SC.NIT_EMP_BASCULA,\n" +
                    "    SC.FE_CREACION,\n" +
                    "    SC.USU_CREACION,\n" +
                    "    SC.FECHA_CITA,\n" +
                    "    SC.NMFORM_ZF,\n" +
                    "    SC.FE_APROBACION,\n" +
                    "    SC.USU_APROBACION,\n" +
                    "    SC.OBSERVACIONES,\n" +
                    "    SC.OPERACION,\n" +
                    "    SC.BARCAZA,\n" +
                    "    SC.TANQUE,\n" +
                    "    VB.EMP_TRANSPORTADORA,\n" +
                    "    TB.NUM_TICKETE,\n" +
                    "    TB.HORA_ENTRADA,\n" +
                    "    TB.HORA_SALIDA,\n" +
                    "    TB.NMFORM_ZF AS FMM_TRANSBASCULA,\n" +
                    "    TB.CONTENEDOR,\n" +
                    "    TB.PESO_INGRESO,\n" +
                    "    TB.PESO_SALIDA,\n" +
                    "    TB.PESO_NETO,\n" +
                    "    TB.OBSERVACION,\n" +
                    "    TB.TIPO_MOV,\n" +
                    "    TB.ARTICULO,\n" +
                    "    TB.CLIENTE,\n" +
                    "    TB.ORIGEN,\n" +
                    "    TB.DESTINO,\n" +
                    "    TB.TIPO_REG\n" +
                    "FROM SPD_CITA_VEHICULOS SCV\n" +
                    "JOIN SPD_CITAS SC \n" +
                    "  ON SCV.COD_CITA = SC.COD_CITA\n" +
                    "JOIN VEHICULO_BASC VB \n" +
                    "  ON VB.PLACA = SCV.PLACA\n" +
                    "LEFT JOIN (\n" +
                    "    SELECT \n" +
                    "        TB.*,\n" +
                    "        ROW_NUMBER() OVER (\n" +
                    "            PARTITION BY TB.VEHICULO_ID_VEHICULO \n" +
                    "            ORDER BY TB.FECHA_ENTRADA\n" +
                    "        ) AS rn\n" +
                    "    FROM TRAN_BASCULA TB\n" +
                    ") TB \n" +
                    "  ON TB.VEHICULO_ID_VEHICULO = VB.ID_VEHICULO\n" +
                    "  AND TB.rn = 1\n" +
                    "WHERE \n" +
                    "    SC.FE_CREACION BETWEEN TO_DATE(?, 'YYYY-MM-DD') \n" +
                    "                       AND TO_DATE(?, 'YYYY-MM-DD')\n" +
                    "    AND SCV.ESTADO IN ('FINALIZADO', 'FINALIZADA')\n" +
                    "ORDER BY SC.COD_CITA;";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fechainical);
            pstmt.setString(2, fechafinal);
            rs = pstmt.executeQuery();

            // Crear libro de Excel
            Workbook workbook = new XSSFWorkbook();
            Sheet sheet = workbook.createSheet("Reporte Citas");

            // Estilo de encabezados
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            // Escribir cabeceras dinámicamente
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            Row headerRow = sheet.createRow(0);
            for (int i = 1; i <= columnCount; i++) {
                Cell cell = headerRow.createCell(i - 1);
                cell.setCellValue(metaData.getColumnLabel(i));
                cell.setCellStyle(headerStyle);
            }

            // Escribir filas con los datos
            int rowNum = 1;
            while (rs.next()) {
                Row row = sheet.createRow(rowNum++);
                for (int i = 1; i <= columnCount; i++) {
                    String value = rs.getString(i);
                    row.createCell(i - 1).setCellValue(value != null ? value : "");
                }

                // También imprimir en consola
                for (int i = 1; i <= columnCount; i++) {
                    System.out.print(metaData.getColumnLabel(i) + ": " + rs.getString(i) + " | ");
                }
                System.out.println();
            }

            // Ajustar el tamaño de las columnas
            for (int i = 0; i < columnCount; i++) {
                sheet.autoSizeColumn(i);
            }

            // Guardar el archivo Excel
            String fileName = "ReporteCitas_" + fechainical + "_a_" + fechafinal + ".xlsx";
            try (FileOutputStream fileOut = new FileOutputStream(fileName)) {
                workbook.write(fileOut);
            }
            workbook.close();

            System.out.println("✅ Reporte generado en: " + fileName);

        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ReporteCarrotanques.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception e) {
            Logger.getLogger(ReporteCarrotanques.class.getName()).log(Level.SEVERE, "Error generando Excel", e);
        } finally {
            // Cerrar recursos
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
            if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
        }
    }
}
