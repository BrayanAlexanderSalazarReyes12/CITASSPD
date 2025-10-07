/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Operaciones;

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
public class Operaciones {
    
    public List<TipoOperacion> LectorOpeaciones(String DB_URL, String DB_USER, String DB_PASSWORD) throws SQLException, IOException {
        List<TipoOperacion> listaOperaciones = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try{
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT * FROM SPD_MAESTRO_OPERACIONES";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                TipoOperacion to = new TipoOperacion();
                to.setOPERACION(rs.getString("OPERACION"));
                to.setTIPO_OPERACION(rs.getInt("TIPO_OPERACION"));
                listaOperaciones.add(to);
            }
            
            rs.close();
            pstmt.close();
            
            return listaOperaciones;
            
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
        return listaOperaciones;
    }
    
    private static final Logger log = Logger.getLogger(CitasAutomaticas.class.getName());
}
