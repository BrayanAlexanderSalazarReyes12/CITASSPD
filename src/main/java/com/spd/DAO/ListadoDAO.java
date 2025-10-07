/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.DAO;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;
import com.spd.API.FormularioPost;
import com.spd.CItasDB.ListaVehiculos;
import com.spd.ClasesJsonFormularioMinisterio.Variables;
import com.spd.ClasesJsonFormularioMinisterio.Vehiculo;
import java.util.List;
import com.spd.Model.ListadoCItas;
import com.spd.Model.ListadoCitasBar;
import com.spd.Model.ResultadoCitas;
import java.io.IOException;
import java.lang.reflect.Type;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
  /**
 *
 * @author braya
 */
public class ListadoDAO {
    //METODO LISTAR TODOS LOS CONTRATOS
    public ResultadoCitas ObtenerContratos() {
        List<ListadoCItas> listado = new ArrayList<>();
        List<ListadoCItas> listado2 = new ArrayList<>();

        String url = "http://www.siza.com.co/spdcitas-1.0/api/citas/?estado=PROGRAMADA";
        String url2 = "http://www.siza.com.co/spdcitas-1.0/api/citas/?estado=AGENDADA";

        FormularioPost fp = new FormularioPost();

        try {
            // Ejecutar llamadas HTTP en paralelo
            CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
                try {
                    return fp.ListarCitasVehiculos(url);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });

            CompletableFuture<String> future3 = CompletableFuture.supplyAsync(() -> {
                try {
                    return fp.ListarCitasVehiculos(url2);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });

            // Esperar a que todas finalicen
            CompletableFuture.allOf(future1, future3).join();

            String respuestaJson = future1.get();
            String respuestaJson2 = future3.get();

            Gson gson = new Gson();
            Type listType = new TypeToken<List<ListadoCItas>>(){}.getType();
            listado = gson.fromJson(respuestaJson, listType);

            Type listType2 = new TypeToken<List<ListadoCItas>>(){}.getType();
            listado2 = gson.fromJson(respuestaJson2, listType2);

            
        } catch (InterruptedException | ExecutionException e) {
            System.err.println("Error al obtener contratos desde API: " + e.getMessage());
            e.printStackTrace();
        }

        return new ResultadoCitas(listado, listado2);
    }

    
    public boolean InsertarCita(String jsonVariables) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            // Convertir el JSON a objeto Variables
            Gson gson = new Gson();
            Variables variables = gson.fromJson(jsonVariables, Variables.class);

            // Obtener datos necesarios
            int tipoOperacion = variables.getTipoOperacionId();
            String empresaNit = variables.getEmpresaTransportadoraNit();

            // Obtener lista de vehículos
            List<Vehiculo> vehiculos = variables.getVehiculos();
            
            // Conexión a la BD
            conn = ConexionDB.getConnection(); // tu clase de conexión

            // Consulta SQL (sólo insertamos datos solicitados)
            String sql = "INSERT INTO citas_vehiculos (placa, cedula_conductor, fecha_oferta, manifiesto, tipo_operacion, empresa_nit) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";

            ps = conn.prepareStatement(sql);

            for (Vehiculo vehiculo : vehiculos) {
                ps.setString(1, vehiculo.getVehiculoNumPlaca());
                ps.setString(2, vehiculo.getConductorCedulaCiudadania());
                ps.setString(3, vehiculo.getFechaOfertaSolicitud()); // o usa java.sql.Timestamp si es necesario
                ps.setString(4, vehiculo.getNumManifiestoCarga());
                ps.setInt(5, tipoOperacion);
                ps.setString(6, empresaNit);

                ps.executeUpdate();
            }

            return true;

        } catch (JsonSyntaxException e) {
            System.out.println("❌ Error al insertar cita: " + e.getMessage());
            return false;

        } catch (SQLException e) {
            System.out.println("❌ Error al insertar cita: " + e.getMessage());
            return false;
        } finally {
            // Cerrar recursos
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
}
