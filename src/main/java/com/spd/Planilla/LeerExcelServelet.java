/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Planilla;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.spd.API.FormularioPost;
import com.spd.CItasDB.CitaBascula;
import com.spd.CItasDB.VehiculoDB;
import com.spd.Servlets.LocalBackup;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class LeerExcelServelet extends HttpServlet {

    private static final long serialVersionUID = 1;
   
    private static final int MAX_REINTENTOS = 3;
    private static final long BACKOFF_MS_INICIAL = 5000;
    
    private List<String> placasFallidas = new ArrayList<>();
    
    private static final String URL_CITAS = "http://www.siza.com.co/spdcitas-1.0/api/citas/";
    
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String nombreArchivo = request.getParameter("archivo");
        String UsuLogin = request.getParameter("UsuLogin");
        String NitUsuLogin = request.getParameter("NitUsuLogin");
        String pdfBase64 = request.getParameter("pdfBase64");
        
        if (nombreArchivo == null || nombreArchivo.trim().isEmpty()) {
            response.getWriter().println("No se recibió el nombre del archivo.");
            return;
        }

        File uploads = new File("E:/T/SPDCITAS/SOLICITADASPORPLANILLA/"+UsuLogin);
        File file = new File(uploads, nombreArchivo);

        if (!file.exists()) {
            response.getWriter().println("El archivo no existe: " + file.getAbsolutePath());
            return;
        }

        // ----- LECTURA DEL EXCEL -----
        FileInputStream fis = new FileInputStream(file);
        Workbook workbook;

        if (nombreArchivo.toLowerCase().endsWith(".xlsx")) {
            workbook = new XSSFWorkbook(fis);
        } else {
            workbook = new HSSFWorkbook(fis);
        }

        Sheet sheet = workbook.getSheetAt(0);
        
        // -------------------------------------------
        // VALIDACIÓN DE J3 = SPDIQUE-01
        // -------------------------------------------
        Row filaTitulo = sheet.getRow(2); // Fila 3 real → índice 2

        if (filaTitulo == null) {
            response.getWriter().println("{\"error\":\"La fila 3 no existe en el archivo Excel.\"}");
            return;
        }
        
        Cell celdaJ3 = filaTitulo.getCell(9); // Columna J → índice 9
        String valorJ3 = "";

        if (celdaJ3 != null) {
            switch (celdaJ3.getCellType()) {
                case Cell.CELL_TYPE_STRING:
                    valorJ3 = celdaJ3.getStringCellValue();
                    break;
                case Cell.CELL_TYPE_NUMERIC:
                    valorJ3 = String.valueOf(celdaJ3.getNumericCellValue());
                    break;
                default:
                    valorJ3 = "";
            }
        }

        if (!"SPDIQUE-01".equalsIgnoreCase(valorJ3.trim())) {
            response.getWriter().println(
                    "{\"error\":\"El archivo Excel no es válido. La celda J3 debe contener 'SPDIQUE-01'. Valor encontrado: " 
                    + valorJ3 + "\"}"
            );
            return;
        }

        
        int inicioFila = 4; // Fila 4 real

        // Mapa NIT → CitaBascula agrupada
        Map<String, CitaBascula> citasMap = new HashMap<>();

        // ------------------------------
        // LECTURA DE FILAS DEL EXCEL
        // ------------------------------
        for (int i = inicioFila; i <= sheet.getLastRowNum(); i++) {

            Row row = sheet.getRow(i);
            if (row == null) break;

            boolean filaVacia = true;
            String[] valores = new String[15];

            for (int col = 0; col < 15; col++) {
                Cell cell = row.getCell(col);
                String valor = "";

                if (cell != null) {
                    switch (cell.getCellType()) {
                        case Cell.CELL_TYPE_STRING:
                            valor = cell.getStringCellValue();
                            break;
                        case Cell.CELL_TYPE_NUMERIC:
                            // Validar si es fecha
                            if (HSSFDateUtil.isCellDateFormatted(cell)) {
                                Date fechaTmp = cell.getDateCellValue();
                                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                                valor = sdf.format(fechaTmp);
                            } else {
                                // Es un número normal
                                valor = new BigDecimal(cell.getNumericCellValue()).toPlainString();
                            }
                            break;

                        case Cell.CELL_TYPE_BOOLEAN:
                            valor = String.valueOf(cell.getBooleanCellValue());
                            break;
                        case Cell.CELL_TYPE_FORMULA:
                            valor = cell.getCellFormula();
                            break;
                        default:
                            valor = "";
                    }
                }

                valores[col] = valor;

                if (!valor.trim().isEmpty()) {
                    filaVacia = false;
                }
            }

            if (filaVacia) break;
            
            // ------------------------------
            // MAPEO DE COLUMNAS DEL EXCEL
            // ------------------------------
            String placa = valores[0];          // Columna B
            String cedula = valores[1];         // Columna C
            String nombre = valores[2];         // Columna D
            String fecha = valores[3];          // Columna E
            String manifiesto = valores[4];     // Columna F
            String nit = valores[5];            // Columna A
            String producto = valores[6];
            String cantidadproducto = valores[7];
            String facturaremision = valores[8];
            String preciounitariodolares = valores[9];
            String observaciones = valores[10];
            String operacion = valores[11];
            String numeroremolque = valores[12];
            String barcaza = valores[13];
            String tanque = valores[14];
            
            // ------------------------------
            // AGRUPAR POR NIT
            // ------------------------------
            CitaBascula cita = citasMap.get(String.valueOf(nit));

            if (cita == null) {
                cita = new CitaBascula();
                cita.setNitEmpBascula(NitUsuLogin);
                cita.setUsuCreacion(UsuLogin);
                cita.setPlaca(placa);
                cita.setCedConductor(cedula);
                cita.setNomConductor(nombre);
                cita.setFechaCita(fecha);
                cita.setManifiesto(manifiesto);
                cita.setNmformZf(0);
                cita.setNitTransportadora(String.valueOf(nit));
                cita.setEstado("PROGRAMADA");
                cita.setVariosVehiculos(1);
                cita.setProducto(producto);
                cita.setCantProducto(Float.parseFloat(cantidadproducto));
                cita.setFacturaRemision(facturaremision);
                cita.setPrecioUsd(Double.parseDouble(preciounitariodolares));
                cita.setArchivo(pdfBase64);
                cita.setObservaciones(observaciones);
                switch (operacion) {
                    case "Barcaza - Carrotanque":
                        cita.setOperacion("operacion de cargue");
                        break;
                    case "Tanque - Carrotanque":
                        cita.setOperacion("operacion de cargue");
                        break;
                    case "Carrotanque - Barcaza":
                        cita.setOperacion("operacion de descargue");
                        break;
                    case "Carrotanque - Tanque":
                        cita.setOperacion("operacion de descargue");
                        break;
                    default:
                        cita.setOperacion("");
                }
                cita.setRemolque(numeroremolque);
                // Solo agregamos barcaza si tiene valor
                if (barcaza != null && !barcaza.trim().isEmpty()) {
                    cita.setBarcaza(barcaza);
                }
                if (tanque != null && !tanque.trim().isEmpty()) {
                    cita.setTanque(tanque);
                }
                cita.setVehiculos(new ArrayList<>());

                citasMap.put(nit, cita);
            }

            // ------------------------------
            // CREAR VEHÍCULO Y AÑADIRLO
            // ------------------------------
            VehiculoDB veh = new VehiculoDB(
                placa,
                cedula,
                nombre,
                fecha,
                manifiesto
            );

            cita.getVehiculos().add(veh);
        }

        fis.close();

        // ------------------------------
        // 2) Convertir mapa a lista
        // ------------------------------
        List<CitaBascula> listaFinal = new ArrayList<>(citasMap.values());
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        FormularioPost fp = new FormularioPost();

        // ------------------------------
        // 3) Variables para controlar éxitos y fallos
        // ------------------------------
        List<String> placasExitosas = new ArrayList<>();
        List<String> placasFallidasERROR = new ArrayList<>();
        List<String> placasFallidas = new ArrayList<>();

        // ------------------------------
        // 4) Enviar cada cita individual
        // ------------------------------
        for (int i = 0; i < listaFinal.size(); i++) {
            CitaBascula cita = listaFinal.get(i);

            // Convertir SOLO esta cita a JSON
            String jsonCita = gson.toJson(cita);

            System.out.println(jsonCita);
            
            // Llamar a la API con reintentos
            String response1 = formdbConRetry(fp, URL_CITAS, jsonCita, UsuLogin);

            if (response1 == null || response1.isEmpty()) {
                // No hubo respuesta → se guardó localmente
                System.out.println("Cita " + i + " guardada localmente → Placa: " + cita.getPlaca());
                placasFallidas.add(cita.getPlaca());
                continue;
            }

            try {
                JSONObject jsonResponse = new JSONObject(response1);

                // ==========================
                // CASO TODAS FALLIDAS
                // ==========================
                if (jsonResponse.has("vehiculos") && !jsonResponse.has("cita")) {
                    JSONArray vehiculosErrados = jsonResponse.getJSONArray("vehiculos");
                    for (int j = 0; j < vehiculosErrados.length(); j++) {
                        JSONObject item = vehiculosErrados.getJSONObject(j);
                        String placaERROR = item.getString("placa");
                        String errorText = "Error desconocido";
                        if (item.has("error")) {
                            JSONObject errObj = item.getJSONObject("error");
                            errorText = errObj.optString("ErrorText", errorText);
                        }
                        placasFallidasERROR.add(placaERROR + "|" + errorText);
                        placasFallidas.add(placaERROR);
                    }

                } else {
                    // ==========================
                    // ÉXITOS
                    // ==========================
                    if (jsonResponse.has("cita") && jsonResponse.getJSONObject("cita").has("vehiculos")) {
                        JSONArray vehiculosExitosos = jsonResponse.getJSONObject("cita").getJSONArray("vehiculos");
                        for (int j = 0; j < vehiculosExitosos.length(); j++) {
                            JSONObject item = vehiculosExitosos.getJSONObject(j);
                            String placaOk = item.getString("vehiculoNumPlaca");
                            placasExitosas.add(placaOk);
                        }
                    }

                    // ==========================
                    // FALLIDOS PARCIALES
                    // ==========================
                    if (jsonResponse.has("listaErrados")) {
                        JSONArray errados = jsonResponse.getJSONArray("listaErrados");
                        for (int j = 0; j < errados.length(); j++) {
                            JSONObject item = errados.getJSONObject(j);
                            String placaError = item.getString("placa");
                            String errorText = "Error desconocido";
                            if (item.has("error")) {
                                JSONObject errObj = item.getJSONObject("error");
                                errorText = errObj.optString("ErrorText", errorText);
                            }
                            placasFallidasERROR.add(placaError + "|" + errorText);
                            placasFallidas.add(placaError);
                        }
                    }
                }

            } catch (JSONException e) {
                System.err.println("Error procesando JSON de la cita " + i + ": " + e.getMessage());
                placasFallidas.add(cita.getPlaca());
            }
        }

        // ------------------------------
        // 5) Guardar cookies
        // ------------------------------
        // Exitosas
        if (!placasExitosas.isEmpty()) {
            Cookie cookieExitosas = new Cookie("placasExitosas", String.join(",", placasExitosas));
            cookieExitosas.setMaxAge(3600);
            cookieExitosas.setPath("/CITASSPD");
            response.addCookie(cookieExitosas);
        } else {
            Cookie clear = new Cookie("placasExitosas", "");
            clear.setMaxAge(0);
            clear.setPath("/CITASSPD");
            response.addCookie(clear);
        }

        // Fallidas
        if (!placasFallidasERROR.isEmpty()) {
            Cookie cookieFallidas = new Cookie("placasFallidas", String.join(",", placasFallidasERROR));
            cookieFallidas.setMaxAge(3600);
            cookieFallidas.setPath("/CITASSPD");
            response.addCookie(cookieFallidas);
        } else {
            Cookie clear = new Cookie("placasFallidas", "");
            clear.setMaxAge(0);
            clear.setPath("/CITASSPD");
            response.addCookie(clear);
        }

        // ------------------------------
        // 6) Redirección final
        // ------------------------------
        
    }

    // =====================================================================
    // MÉTODO: LLAMADA API + REINTENTOS + FILTRADO DE PLACAS FALLIDAS
    // =====================================================================
    private String formdbConRetry(FormularioPost fp, String url, String json, String usuario) {

        long backoff = BACKOFF_MS_INICIAL;

        try {
            // Filtrar JSON quitando los vehículos que YA fallaron antes
            com.google.gson.JsonParser parser = new com.google.gson.JsonParser();
            com.google.gson.JsonObject obj = parser.parse(json).getAsJsonObject();

            if (obj.has("vehiculos")) {

                com.google.gson.JsonArray vehiculos = obj.getAsJsonArray("vehiculos");
                com.google.gson.JsonArray vehiculosFiltrados = new com.google.gson.JsonArray();

                for (com.google.gson.JsonElement v : vehiculos) {
                    com.google.gson.JsonObject vehiculo = v.getAsJsonObject();

                    String placa = vehiculo.get("vehiculoNumPlaca").getAsString();

                    if (!placasFallidas.contains(placa)) {
                        vehiculosFiltrados.add(vehiculo);
                    }
                }

                obj.add("vehiculos", vehiculosFiltrados);
            }

            json = new com.google.gson.Gson().toJson(obj);

        } catch (Exception e) {
            System.out.println("⚠️ Error filtrando JSON: " + e.getMessage());
        }

        // ============================================
        // REINTENTOS
        // ============================================
        for (int i = 0; i < MAX_REINTENTOS; i++) {
            try {
                String resp = fp.FormDB(url, json);

                if (resp != null && !resp.isEmpty()) {
                    return resp;
                }

            } catch (Exception e) {
                System.err.println("❌ Intento " + (i + 1) + " fallido: " + e.getMessage());
            }

            if (i < MAX_REINTENTOS - 1) {
                try {
                    Thread.sleep(backoff);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
                backoff *= 2;
            }
        }

        // SI NINGÚN INTENTO FUNCIONÓ
        try {
            LocalBackup.save(json, getServletContext(), usuario, "CITA_NO_ENVIADA");
            System.out.println("📁 JSON guardado localmente para reintento futuro.");
        } catch (IOException ioe) {
            System.err.println("⛔ No se pudo guardar localmente: " + ioe.getMessage());
        }

        return null;
    }

}
