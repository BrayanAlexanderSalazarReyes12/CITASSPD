/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CancelarCitaAut;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.spd.API.FormularioPost;
import com.spd.FinalizarCitaAut.CitasAutomaticas;
import com.spd.Operaciones.Operaciones;
import com.spd.Operaciones.TipoOperacion;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class CitasCacelacionAuto {
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    private static String RIEN = "1";
    private static String TERMINALPORTUARIANIT;
    private static String SISTEMAENTURNAMIENTOID;
    private static String USUARIOMINTRASPOR;
    private static String CONTRAMINTRASPOR;
    static String IDENTIFICADOR;
    private static final DateTimeFormatter INPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter OUTPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
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
            TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
            SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
            USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
            CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
            
            System.out.println("✅ Variables de conexión cargadas desde json.env");
        } catch (Exception e) {
            System.err.println("❌ Error leyendo json.env desde contexto: " + e.getMessage());
        }
    }
    
    public void cancelarCitaauto() throws SQLException, IOException{
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try{
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT\n" +
                        "    sc.COD_CITA,\n" +
                        "    sc.NIT_TRANSPORTADORA,\n" +
                        "    sc.OPERACION,\n" +
                        "    scv.PLACA,\n" +
                        "    scv.CEDULA_CONDUCTOR,\n" +
                        "    scv.MANIFIESTO,\n" +
                        "    TRUNC(sc.FECHA_CITA) AS FECHA_CITA,\n" +
                        "    TO_CHAR(sc.FECHA_CITA, 'YYYY-MM-DD HH24:MI:SS') AS FECHAYHORA_CITA\n" +
                        "FROM SPD_CITAS sc\n" +
                        "JOIN SPD_CITA_VEHICULOS scv\n" +
                        "    ON scv.COD_CITA = sc.COD_CITA\n" +
                        "JOIN VEHICULO_BASC vb\n" +
                        "    ON vb.PLACA = scv.PLACA\n" +
                        "    AND vb.CEDULA = scv.CEDULA_CONDUCTOR\n" +
                        "LEFT JOIN TRAN_BASCULA tb\n" +
                        "    ON tb.VEHICULO_ID_VEHICULO = vb.ID_VEHICULO\n" +
                        "    AND TRUNC(tb.FECHA_ENTRADA) = TRUNC(sc.FECHA_CITA) -- 👈 aquí está la clave\n" +
                        "WHERE \n" +
                        "    TRUNC(sc.FECHA_CITA) = TRUNC(SYSDATE -1)\n" +
                        "    AND tb.VEHICULO_ID_VEHICULO IS NULL  -- 👈 el vehículo no tiene registro ese día\n" +
                        "    AND sc.ESTADO = 'AGENDADA' OR sc.ESTADO = 'AGENDADO'\n" +
                        "    AND scv.ESTADO = 'ACTIVA'\n" +
                        "ORDER BY sc.COD_CITA;";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                CitaCanceAuto cita = new CitaCanceAuto();
                cita.setCodCita(rs.getString("COD_CITA"));
                cita.setNitTransportadora(rs.getString("NIT_TRANSPORTADORA"));
                cita.setOperacion(rs.getString("OPERACION"));
                cita.setPlaca(rs.getString("PLACA"));
                cita.setCedulaConductor(rs.getString("CEDULA_CONDUCTOR"));
                cita.setManifiesto(rs.getString("MANIFIESTO"));
                cita.setFechaCita(rs.getString("FECHAYHORA_CITA"));
                
                procesarcita(cita);
            }   
            
            rs.close();
            pstmt.close();
            
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
    
    private Map<String, Object> buildJsonMinisterio(CitaCanceAuto cita){
        
        Map<String, Object> acceso = new LinkedHashMap<>();
        acceso.put("usuario", USUARIOMINTRASPOR);
        acceso.put("clave", CONTRAMINTRASPOR);
        acceso.put("rien", "3");

        Map<String, Object> sistemaEnturnamiento = new LinkedHashMap<>();
        sistemaEnturnamiento.put("terminalPortuariaNit", TERMINALPORTUARIANIT);
        sistemaEnturnamiento.put("sistemaEnturnamientoId", SISTEMAENTURNAMIENTOID);
        
        Map<String, Object> variables = new LinkedHashMap<>();
        variables.put("sistemaEnturnamiento", sistemaEnturnamiento);
        
        Operaciones dao = new Operaciones();
        
        try {
            List<TipoOperacion> operaciones = dao.LectorOpeaciones(DB_URL, DB_USER, DB_PASSWORD);
            
            for (TipoOperacion op : operaciones) {
                if (op.getOPERACION().equalsIgnoreCase(cita.getOperacion())) {
                    System.out.println("✅ Coincidencia encontrada:");
                    System.out.println("Operación: " + op.getOPERACION());
                    System.out.println("Tipo: " + op.getTIPO_OPERACION());
                    variables.put("tipoOperacionId", op.getTIPO_OPERACION());
                }
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(CitasCacelacionAuto.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(CitasCacelacionAuto.class.getName()).log(Level.SEVERE, null, ex);
        }

        variables.put("empresaTransportadoraNit", cita.getNitTransportadora());
        variables.put("vehiculoNumPlaca", cita.getPlaca());
        variables.put("conductorCedulaCiudadania", cita.getCedulaConductor());
        variables.put("fechaOfertaSolicitud", formatFecha(cita.getFechaCita()));
        variables.put("quien", "P");
        variables.put("causalid", "15");
        variables.put("descripcion", obtenerDescripcionPorCodigo("15"));
        
        Map<String, Object> finalJson = new LinkedHashMap<>();
        finalJson.put("acceso", acceso);
        finalJson.put("variables", variables);
        
        return finalJson;
    }
    
    private List<Map<String, Object>> buildJsonCancelacion (CitaCanceAuto cita) {
        List<Map<String, Object>> cancelacion = new ArrayList<>();
        Map<String, Object> cancelacioncita = new LinkedHashMap<>();
        cancelacioncita.put("codcita", cita.getCodCita());
        cancelacioncita.put("placa", cita.getPlaca());
        cancelacioncita.put("manifiesto", cita.getManifiesto());
        cancelacioncita.put("usuMovimiento","sistemas");
        cancelacion.add(cancelacioncita);
        return cancelacion;
    }
    
    private void procesarcita(CitaCanceAuto cita) throws IOException {
        FormularioPost fp = new FormularioPost();
        String url = "http://www.siza.com.co/spdcitas-1.0/api/citas/cancelacion";
            
        String APIPRUEBA = "http://192.168.10.80:26480/spdcitas/api/citas/cancelacion";
        
        String url1 = "https://rndcws2.mintransporte.gov.co/rest/RIEN";
        
        if ("operacion de descargue".equals(cita.getOperacion()) 
            || "operacion de cargue".equals(cita.getOperacion())
            || "Carrotanque - Barcaza".equals(cita.getOperacion())
            || "Barcaza - Carrotanque".equals(cita.getOperacion())
            || "Carrotanque - Tanque".equals(cita.getOperacion())
            || "Tanque - Carrotanque".equals(cita.getOperacion())) {
            
            String jsonMinisterio = gson.toJson(buildJsonMinisterio(cita));
            String jsonLocal = gson.toJson(buildJsonCancelacion(cita));
            
            String respMinisterio = enviarConRetry(fp, url1, jsonMinisterio, 3);

            if (respMinisterio == null) {
                // Ministerio no respondió
                log.info("⚠️ Ministerio no respondió, guardando en API local.");
                fp.EliminarCita(url, jsonLocal);
            } else {
                try {
                    JSONObject jsonResp = new JSONObject(respMinisterio);
                    log.info(respMinisterio);
                    
                    if (jsonResp.has("ErrorCode")) {
                        int errorCode = jsonResp.getInt("ErrorCode");
                        String errorText = jsonResp.optString("ErrorText");

                        if (errorCode != 0) {
                            log.info("❌ No se guarda en BD. Error del ministerio: " + errorText);
                            cancelacionCitaDB(cita, respMinisterio);
                            String respuesta  = fp.EliminarCita(url, jsonLocal);
                            log.info(respuesta);
                        }
                    } else {
                        log.info("✅ Respuesta sin errores, guardando en local.");
                        cancelacionCitaDB(cita, respMinisterio);
                        fp.EliminarCita(url, jsonLocal);
                    }
                } catch (Exception e) {
                    log.log(Level.SEVERE, "⚠️ Error parseando respuesta del ministerio: " + respMinisterio, e);
                }
            }
            
            try {
                Thread.sleep(500 + new Random().nextInt(1000));
            } catch (InterruptedException ex) {
                Logger.getLogger(CitasAutomaticas.class.getName()).log(Level.SEVERE, null, ex);
                Thread.currentThread().interrupt(); // buena práctica
            }
        }else {
            String jsonLocal = gson.toJson(buildJsonCancelacion(cita));
            log.info(jsonLocal);

            String respLocal = fp.EliminarCita(url, jsonLocal);
            log.info("📌 Guardado local: " + respLocal);
        }    
    }
    
    private void cancelacionCitaDB(CitaCanceAuto cita, String respuestainside) throws SQLException, IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Consulta SQL para insertar datos
            String sql = "INSERT INTO SPD_CANCELACION_CITA (COD_CITA, RESPUESTA_INSIDE, FECHA_HORA) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            
            // Asignación de valores a los parámetros
            pstmt.setString(1, cita.getCodCita()); // Suponiendo que codCita es un String
            pstmt.setString(2, respuestainside); // Suponiendo que respuestaInside es un String
            pstmt.setTimestamp(3, new java.sql.Timestamp(System.currentTimeMillis())); // Fecha y hora actuales
            
            // Ejecutar inserción
            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                log.info("✅ Inserción realizada correctamente.");
            } else {
                log.warning("⚠️ No se insertaron filas.");
            }
        
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
    
    /**
     * Envia con reintentos exponenciales para evitar baneo
     */
    private String enviarConRetry(FormularioPost fp, String url, String json, int maxIntentos) {
        int intentos = 0;
        while (intentos < maxIntentos) {
            try {
                String resp = fp.Post(url, json);
                if (resp != null && !resp.isEmpty()) {
                    return resp;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            intentos++;
            try {
                // Espera exponencial: 2s, 4s, 8s...
                long delay = (long) Math.pow(2, intentos) * 1000;
                log.info("⏳ Reintentando en " + delay + " ms...");
                Thread.sleep(delay);
            } catch (InterruptedException ignored) {}
        }
        return null;
    }
    
    private String formatFecha(String fechaOriginal) {
        try {
            LocalDateTime fecha = LocalDateTime.parse(fechaOriginal, INPUT_FORMAT);
            
            // Convertir a UTC (OffsetDateTime con offset 0)
            OffsetDateTime utcDateTime = fecha.atOffset(ZoneOffset.UTC);
            
            return OUTPUT_FORMAT.format(utcDateTime);
        } catch (Exception e) {
            return fechaOriginal; // en caso de error devuelve el original
        }
    }
    
    private static String obtenerDescripcionPorCodigo(String codigo) {
        switch (codigo) {
            case "15": return "Confirmación tardía de la cita";
            // Puedes completar según tu mapa original
            default: return "Causal desconocida";
        }
    }
    
    private static final Logger log = Logger.getLogger(CitasAutomaticas.class.getName());
}
