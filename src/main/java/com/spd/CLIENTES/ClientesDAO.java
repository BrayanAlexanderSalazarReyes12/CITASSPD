/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CLIENTES;

import com.spd.citas.vehiculos.CitasPorEmpresa;
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
public class ClientesDAO {
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
    
    public List<Clientes> ObtenerClientes(String Nit) throws SQLException, ClassNotFoundException{
        List<Clientes> ListaCLientes = new ArrayList<>();
        
        Class.forName("oracle.jdbc.driver.OracleDriver");
        
        try{
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT * FROM SPD_CLIENTES WHERE NIT = ?";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, Nit);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {                
                Clientes cl = new Clientes();
                cl.setNIT(rs.getString("NIT"));
                cl.setNombre(rs.getString("NOMBRE_CLIENTE"));
                ListaCLientes.add(cl);
            }
            
        }catch (SQLException e) {
            log.log(Level.SEVERE, "❌ Error SQL al obtener información de la cita: {0}", e.getMessage());
            throw e;
        }
        return ListaCLientes;
    }
    
    private static final Logger log = Logger.getLogger(CitasPorEmpresa.class.getName());
}
