/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CreacionUsuarioNit;

import java.io.InputStream;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Scanner;
import java.util.UUID;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 * Clase para crear usuarios de empresas transportadoras.
 * Lee variables de conexión desde json.env y realiza inserciones en Oracle DB.
 * 
 * @author Brayan
 */
public class CreacionUsuarioEmpresaTransportadora {

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

    /**
     * Inserta un nuevo usuario en la tabla LOGIN_ALTERNO
     */
    public static void insertarUsuario(String username, String password, String nitclient,
                                       String codcia_user, String email, String rol,
                                       String estado) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // Carga del driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Consulta SQL
            String sql = "INSERT INTO LOGIN_ALTERNO (ID_LOGIN, USERNAME, PASSWORD, NIT_CLIENTE, CODCIA_USER, EMAIL, ROL, ESTADO, FECREACION) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, UUID.randomUUID().toString());
            pstmt.setString(2, username);
            pstmt.setString(3, password);
            pstmt.setString(4, nitclient);
            pstmt.setString(5, codcia_user);
            pstmt.setString(6, email);
            pstmt.setInt(7, Integer.parseInt(rol));
            pstmt.setInt(8, Integer.parseInt(estado));

            LocalDate today = LocalDate.now(); // Solo fecha sin hora
            pstmt.setDate(9, java.sql.Date.valueOf(today));


            int filas = pstmt.executeUpdate();
            if (filas > 0) {
                System.out.println("✅ Usuario insertado exitosamente.");
            } else {
                System.out.println("⚠️ No se pudo insertar el usuario.");
            }

        } catch (ClassNotFoundException e) {
            System.err.println("❌ No se encontró el driver JDBC: " + e.getMessage());
        } catch (SQLException e) {
            System.err.println("❌ Error SQL al insertar usuario: " + e.getMessage());
            throw e;
        } finally {
            // Cierre de recursos
            if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }
}