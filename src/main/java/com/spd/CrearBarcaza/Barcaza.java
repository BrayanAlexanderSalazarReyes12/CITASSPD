/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CrearBarcaza;

import com.spd.citas.vehiculos.CitasPorEmpresa;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.Date;
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
public class Barcaza {
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
    
    public void IngresoBarcaza (String CLIENTE, String NIT_CLIENTE, String BARCAZA, String ARMADOR,
            float ESLORA, float MANGA, float CALADO, String BANDERA, String CERTIFICACIONMATRICULA, 
            String POLIZA, String RESOLUCIONDESERVICIOS, String ROSOLUCIONCOMOPUNTOEXPORTACION, 
            Date NACIONALARQUEO, Date DOTACIONMINIMADESEGURIDAD, Date NACIONALDEFRANCORBO,
            Date NACIONALSEGURIDAD, Date INVENTARIOELEMENTOYEQUIPOS, Date TRANSPORTEHIDEOCARBUROS, 
            Date CONTAMINACIONHIDEOCARBUROS) throws SQLException, IOException{
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // 3️⃣ Crear sentencia SQL
            String sql = "INSERT INTO SPD_MAESTROBARCAZA (CLIENTE, BARCAZA, ARMADOR, ESLORA, MANGA, CALADO, BANDERA, " +
                         "CERTIFICACIONMATRICULA, POLIZA, RESOLUCIONDESERVICIOS, ROSOLUCIONCOMOPUNTOEXPORTACION, " +
                         "NACIONALARQUEO, DOTACIONMINIMADESEGURIDAD, NACIONALDEFRANCORBO, NACIONALSEGURIDAD, " +
                         "INVENTARIOELEMENTOYEQUIPOS, TRANSPORTEHIDEOCARBUROS, CONTAMINACIONHIDEOCARBUROS, NIT_CLIENTE) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            pstmt = conn.prepareStatement(sql);
            
            // 4️⃣ Asignar valores
            pstmt.setString(1, CLIENTE);
            pstmt.setString(2, BARCAZA);
            pstmt.setString(3, ARMADOR);
            pstmt.setFloat(4, ESLORA);
            pstmt.setFloat(5, MANGA);
            pstmt.setFloat(6, CALADO);
            pstmt.setString(7, BANDERA);
            pstmt.setString(8, CERTIFICACIONMATRICULA);
            pstmt.setString(9, POLIZA);
            pstmt.setString(10, RESOLUCIONDESERVICIOS);
            pstmt.setString(11, ROSOLUCIONCOMOPUNTOEXPORTACION);
            pstmt.setDate(12, NACIONALARQUEO);
            pstmt.setDate(13, DOTACIONMINIMADESEGURIDAD);
            pstmt.setDate(14, NACIONALDEFRANCORBO);
            pstmt.setDate(15, NACIONALSEGURIDAD);
            pstmt.setDate(16, INVENTARIOELEMENTOYEQUIPOS);
            pstmt.setDate(17, TRANSPORTEHIDEOCARBUROS);
            pstmt.setDate(18, CONTAMINACIONHIDEOCARBUROS);
            pstmt.setString(19, NIT_CLIENTE);
            
            // 5️⃣ Ejecutar
            int filas = pstmt.executeUpdate();
            
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
    private static final Logger log = Logger.getLogger(CitasPorEmpresa.class.getName());
}
