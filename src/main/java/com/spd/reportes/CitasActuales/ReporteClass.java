/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.reportes.CitasActuales;

import java.io.File;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Scanner;
import javax.servlet.ServletContext;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.view.JasperViewer;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class ReporteClass {
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
    
    public File generarReporte(String rutaReporte) throws SQLException, JRException {
        Connection conn = null;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Compilar y llenar el reporte
            JasperReport jasperReport = JasperCompileManager.compileReport(rutaReporte);
            Map<String, Object> parametros = new HashMap<>();
            parametros.put("FECHA", java.time.LocalDate.now());

            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parametros, conn);

            // Exportar a PDF
            File archivoPDF = File.createTempFile("Reporte_Citas_Hoy_", ".pdf");
            JasperExportManager.exportReportToPdfFile(jasperPrint, archivoPDF.getAbsolutePath());

            return archivoPDF;
        } catch (Exception e) {
            e.printStackTrace();
            throw new SQLException("Error generando el reporte: " + e.getMessage());
        } finally {
            if (conn != null) conn.close();
        }
    }

}
