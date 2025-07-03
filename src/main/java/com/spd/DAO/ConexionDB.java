/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.DAO;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;


/**
 *
 * @author braya
 */
public class ConexionDB {
    private static final String URL = "jdbc:mysql://localhost:3306/gestioncontratosdb";
    private static final String USER = "admin_contratos";
    private static final String PASS = "admin_contratos";
    private static Connection conexion = null;
    
    public static Connection getConnection(){
        try{
            if(conexion == null || conexion.isClosed()){
                Class.forName("com.mysql.cj.jdbc.Driver");
                conexion = DriverManager.getConnection(URL, USER, PASS);
                System.out.println("Conexion exitosa");
            }
        }catch (ClassNotFoundException e){
            System.err.println("Error no se encontro el driver de MYSQL");
        }catch (SQLException e){
            System.err.println("Error a la conexion a la base de datos");
        }
        return conexion;
    }
    
    // Método para cerrar la conexión
    public static void cerrarConexion() {
        try {
            if (conexion != null && !conexion.isClosed()) {
                conexion.close();
                System.out.println("Conexion cerrada.");
            }
        } catch (SQLException e) {
            System.err.println("Error al cerrar la conexión.");
            e.printStackTrace();
        }
    }
}
