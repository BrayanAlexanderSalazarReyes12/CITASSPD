/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.citas.vehiculos;

import com.spd.FinalizarCitaAut.CitaFinalAuto;
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
public class CitasPorEmpresa {
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
    
    public List<CitaVehiculo> obtenerCitasPorEmpresa() throws SQLException, ClassNotFoundException {
        List<CitaVehiculo> listaCitas = new ArrayList<>();
        
        Class.forName("oracle.jdbc.driver.OracleDriver");
        
        String sql = "SELECT CV.*, SC.NIT_EMP_BASCULA, SC.OPERACION,\n" +
                     "    SC.TANQUE,\n" +
                     "    SC.BARCAZA," +
                     "COUNT(*) OVER(PARTITION BY SC.COD_CITA, SC.NIT_EMP_BASCULA) AS NUMERO_DE_REGISTROS " +
                     "FROM SPD_CITA_VEHICULOS CV " +
                     "JOIN SPD_CITAS SC ON CV.COD_CITA = SC.COD_CITA " +
                     "WHERE SC.ESTADO = 'AGENDADA' " +
                     "AND TRUNC(SC.FECHA_CITA) = TRUNC(SYSDATE)";

        try (
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()
        ) {
            while (rs.next()) {
                CitaVehiculo cita = new CitaVehiculo();
                cita.setPlaca(rs.getString("PLACA"));
                cita.setCedula(rs.getString("CEDULA_CONDUCTOR"));
                cita.setNombre(rs.getString("NOMBRE_CONDUCTOR"));
                cita.setManifiesto(rs.getString("MANIFIESTO"));
                cita.setCodCita(rs.getString("COD_CITA"));
                cita.setFechacita(rs.getString("HORA_CITAS")); // o FECHA_CITA si aplica
                cita.setNitempresaBas(rs.getString("NIT_EMP_BASCULA"));
                cita.setOperacion(rs.getString("OPERACION"));
                cita.setTanque(rs.getString("TANQUE"));
                cita.setBarcaza(rs.getString("BARCAZA"));
                listaCitas.add(cita);
            }
        } catch (SQLException e) {
            log.log(Level.SEVERE, "❌ Error SQL al obtener información de la cita: {0}", e.getMessage());
            throw e;
        }

        return listaCitas;
    }
    
    private static final Logger log = Logger.getLogger(CitasPorEmpresa.class.getName());
}
