/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.API;
import java.io.IOException;
import okhttp3.*;

/**
 *
 * @author braya
 */
public class FormularioPost {
    public static final MediaType JSON = MediaType.get("application/json");
    
    OkHttpClient client = new OkHttpClient();
    
    public String Post(String url, String json) throws IOException{
        RequestBody body = RequestBody.create(json, JSON);
        Request request = new Request.Builder()
            .url(url)
            .post(body)
            .build();
        try (Response response = client.newCall(request).execute()){
            return response.body().string();
        }
    }
    
    public String EliminarCita (String url, String json) throws IOException {
        RequestBody body = RequestBody.create(json, JSON);
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        Request request = new Request.Builder()
                .url(url)
                .addHeader("Token", token)
                .put(body)
                .build();
        try (Response response = client.newCall(request).execute()) {
            return response.body() != null ? json : "";
        }
    }
    
    public String ActualizarCitacamionesbarcaza (String url, String json) throws IOException{
        RequestBody body = RequestBody.create(json, JSON);

        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        
        System.out.println(json);
        
        Request request = new Request.Builder()
                .url(url)
                .addHeader("Token", token)
                .put(body)
                .build();

        try (Response response = client.newCall(request).execute()) {
            

            return response.body() != null ? json : "";
        }
    }
    
    public String FormDB (String url, String json) throws IOException{
        RequestBody body = RequestBody.create(json, JSON);
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        Request request = new Request.Builder()
            .url(url)
            .addHeader("Token", token)
            .post(body)
            .build();
        try (Response response = client.newCall(request).execute()){
            String responseBody = response.body().string();
            int code = response.code();

            System.out.println("Código HTTP: " + code);
            System.out.println("Respuesta: " + responseBody);

            // Aquí tú decides qué hacer si es 500 pero sabes que sí guardó
            if (code == 500) {
                // El servidor devolvió 500 pero el guardado fue exitoso (por lógica tuya)
                return "Guardado exitosamente (aunque servidor devolvió 500)";
            }
            return responseBody;
        }
    }
    
    public String CitaBarcaza (String url, String json) throws IOException {
        RequestBody body = RequestBody.create(json, JSON);
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        Request request = new Request.Builder()
                .url(url)
                .addHeader("Token", token)
                .post(body)
                .build();
        try (Response response = client.newCall(request).execute()){
            return response.body().string();
        }
    }
    
    
    // Ejemplo adicional: método GET
    public String ListarCitasVehiculos(String url) throws IOException {
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";

        Request request = new Request.Builder()
            .url(url)
            .addHeader("Token", token)
            .get()
            .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Unexpected code " + response);
            }
            return response.body().string();
        }
    }
    
    public String FinalizarCita (String url, String json) throws IOException {
        RequestBody body = RequestBody.create(json, JSON);
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        Request request = new Request.Builder()
                .url(url)
                .addHeader("Token", token)
                .put(body)
                .build();
        try (Response response = client.newCall(request).execute()) {
            return response.body() != null ? json : "";
        }
    }
}
