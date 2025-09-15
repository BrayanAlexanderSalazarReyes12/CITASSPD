/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.FinalizarCitaAut;

import static Utilidades.Utilidades.jsonEnv;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.spd.API.FormularioPost;
import com.spd.informacionCita.CitaFInal;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
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
public class CitasAutomaticas {
    
    private static String DB_URL;
    private static String DB_USER;
    private static String DB_PASSWORD;
    private static String RIEN = "1";
    private static String TERMINALPORTUARIANIT;
    private static String SISTEMAENTURNAMIENTOID;
    private static String USUARIOMINTRASPOR;
    private static String CONTRAMINTRASPOR;
    private static String IDENTIFICADOR;
    private static final DateTimeFormatter INPUT_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yy HH:mm:ss");
    private static final DateTimeFormatter OUTPUT_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
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
            TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
            SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
            USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
            CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
            
            System.out.println("✅ Variables de conexión cargadas desde json.env");
        } catch (Exception e) {
            System.err.println("❌ Error leyendo json.env desde contexto: " + e.getMessage());
        }
    }
    
    public void ejecutarAutomatico() throws SQLException, IOException{
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            // Cargar driver Oracle
            Class.forName("oracle.jdbc.driver.OracleDriver");
            
            // Conexión
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT * " +
             "FROM ( " +
             "    SELECT  " +
             "        v.COD_CITA, " +
             "        v.NIT_TRANSPORTADORA, " +
             "        v.OPERACION, " +
             "        t.PLACA,  " +
             "        vb.CEDULA,  " +
             "        t.MANIFIESTO, " +
             "        TO_CHAR(CAST(v.FECHA_CITA AS DATE), 'DD/MM/YY HH24:MI:SS') AS FECHAYHORAINSIDE, " +
             "        TO_CHAR(CAST(tb.HORA_ENTRADA AS DATE), 'DD/MM/YY HH24:MI:SS') AS HORA_ENTRADA, " +
             "        TO_CHAR(CAST(tb.HORA_SALIDA AS DATE), 'DD/MM/YY HH24:MI:SS') AS HORA_SALIDA, " +
             "        tb.PESO_INGRESO,  " +
             "        tb.PESO_SALIDA, " +
             "        ABS(TRUNC(tb.FECHA_ENTRADA) - TRUNC(v.FE_CREACION)) AS DIF_DIAS, " +
             "        ROW_NUMBER() OVER ( " +
             "            PARTITION BY v.COD_CITA, t.PLACA " +
             "            ORDER BY ABS(tb.FECHA_ENTRADA - v.FE_CREACION) ASC " +
             "        ) AS rn " +
             "    FROM SPD_CITAS v " +
             "    JOIN SPD_CITA_VEHICULOS t ON t.COD_CITA = v.COD_CITA " +
             "    JOIN VEHICULO_BASC vb ON vb.PLACA = t.PLACA " +
             "    JOIN TRAN_BASCULA tb ON vb.ID_VEHICULO = tb.VEHICULO_ID_VEHICULO " +
             "    WHERE t.ESTADO = 'ACTIVA' " +
             "      AND t.HORA_CITAS IS NOT NULL " +
             "      AND tb.HORA_SALIDA IS NOT NULL " +
             "      AND tb.FECHA_ENTRADA BETWEEN v.FE_CREACION - 2 AND v.FE_CREACION + 2 " +
             ") sub " +
             "WHERE rn = 1";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {                
                CitaFinalAuto cita = new CitaFinalAuto();
                cita.setCodcita(rs.getString("COD_CITA"));
                cita.setFECHAYHORAINSIDE(rs.getString("FECHAYHORAINSIDE"));
                cita.setNitempbascula(rs.getString("NIT_TRANSPORTADORA"));
                cita.setOPERACION(rs.getString("OPERACION"));
                cita.setVehiculoNumPlaca(rs.getString("PLACA"));
                cita.setConductorCedulaCiudadania(rs.getString("CEDULA"));
                cita.setNumManifiestoCarga(rs.getString("MANIFIESTO"));
                cita.setFechaentrada(rs.getString("HORA_ENTRADA"));
                cita.setFechasalida(rs.getString("HORA_SALIDA"));
                cita.setPesoentrada(rs.getString("PESO_INGRESO"));
                cita.setPesosalida(rs.getString("PESO_SALIDA"));
                
                procesarCita(cita);
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
    
    private Map<String, Object> buildJsonMinisterio(CitaFinalAuto cita) {
        Map<String, Object> tiemposProceso = new LinkedHashMap<>();
        tiemposProceso.put("entradaTerminal", formatFecha(cita.getFechaentrada()));
        tiemposProceso.put("pesajeEntrada", cita.getPesoentrada());
        tiemposProceso.put("basculaEntrada", "B1374");
        tiemposProceso.put("salidaTerminal", formatFecha(cita.getFechasalida()));
        tiemposProceso.put("pesajeSalida", cita.getPesosalida());
        tiemposProceso.put("basculaSalida", "B1373");

        Map<String, Object> turnoAsignado = new LinkedHashMap<>();
        turnoAsignado.put("fecha", formatFecha(cita.getFECHAYHORAINSIDE()));
        turnoAsignado.put("tiemposProceso", tiemposProceso);

        Map<String, Object> sistemaEnturnamiento = new LinkedHashMap<>();
        sistemaEnturnamiento.put("terminalPortuariaNit", TERMINALPORTUARIANIT);
        sistemaEnturnamiento.put("sistemaEnturnamientoId", SISTEMAENTURNAMIENTOID);

        Map<String, Object> variables = new LinkedHashMap<>();
        variables.put("sistemaEnturnamiento", sistemaEnturnamiento);
        
        String identificador = "operacion de cargue".equalsIgnoreCase(cita.getOPERACION()) ? "1" : "2";
        
        /*
        identificador = (operacion === "operacion de cargue") ? "1" : "2";
        */
        
        variables.put("tipoOperacionId", identificador);
        variables.put("empresaTransportadoraNit", cita.getNitempbascula());
        variables.put("vehiculoNumPlaca", cita.getVehiculoNumPlaca());
        variables.put("conductorCedulaCiudadania", cita.getConductorCedulaCiudadania());
        variables.put("fechaOfertaSolicitud", formatFecha(cita.getFECHAYHORAINSIDE()));
        variables.put("numManifiestoCarga", cita.getNumManifiestoCarga());
        variables.put("turnoAsignado", turnoAsignado);

        Map<String, Object> acceso = new LinkedHashMap<>();
        acceso.put("usuario", USUARIOMINTRASPOR);
        acceso.put("clave", CONTRAMINTRASPOR);
        acceso.put("rien", RIEN);

        Map<String, Object> finalJson = new LinkedHashMap<>();
        finalJson.put("acceso", acceso);
        finalJson.put("variables", variables);

        return finalJson;
    }
    
    
    private List<Map<String, Object>> buildJsonFinalizacion(CitaFinalAuto cita) {
        List<Map<String, Object>> listaFinal = new ArrayList<>();
        Map<String, Object> data = new HashMap<>();
        data.put("codcita", cita.getCodcita());
        data.put("placa", cita.getVehiculoNumPlaca());
        data.put("manifiesto", cita.getNumManifiestoCarga());
        listaFinal.add(data);
        return listaFinal;
    }
    
    private void procesarCita(CitaFinalAuto cita) throws IOException {
        FormularioPost fp = new FormularioPost();
        String ministerioUrl = "https://rndcws2.mintransporte.gov.co/rest/RIEN";
        String apiLocalUrl = "http://www.siza.com.co/spdcitas-1.0/api/citas/finalizacion";

        if ("operacion de descargue".equals(cita.getOPERACION()) 
            || "operacion de cargue".equals(cita.getOPERACION())) {

            String jsonMinisterio = gson.toJson(buildJsonMinisterio(cita));
            String jsonLocal = gson.toJson(buildJsonFinalizacion(cita));

            log.info(jsonLocal);

            String respMinisterio = enviarConRetry(fp, ministerioUrl, jsonMinisterio, 3);

            if (respMinisterio == null) {
                // Ministerio no respondió
                log.info("⚠️ Ministerio no respondió, guardando en API local.");
                fp.FinalizarCita(apiLocalUrl, jsonLocal);
            } else {
                try {
                    JSONObject jsonResp = new JSONObject(respMinisterio);
                    log.info(respMinisterio);

                    if (jsonResp.has("ErrorCode")) {
                        int errorCode = jsonResp.getInt("ErrorCode");
                        String errorText = jsonResp.optString("ErrorText");

                        if (errorCode != 0) {
                            log.info("❌ No se guarda en BD. Error del ministerio: " + errorText);
                        }
                    } else {
                        log.info("✅ Respuesta sin errores, guardando en local.");
                        fp.FinalizarCita(apiLocalUrl, jsonLocal);
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

        } else {
            String jsonLocal = gson.toJson(buildJsonFinalizacion(cita));
            log.info(jsonLocal);

            String respLocal = fp.FinalizarCita(apiLocalUrl, jsonLocal);
            log.info("📌 Guardado local: " + respLocal);
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
            return fecha.format(OUTPUT_FORMAT);
        } catch (Exception e) {
            return fechaOriginal; // en caso de error devuelve el original
        }
    }
    
    private static final Logger log = Logger.getLogger(CitasAutomaticas.class.getName());

}
