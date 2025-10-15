/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.API;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.spd.ListarEmpresas.Empresas;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.List;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 *
 * @author Brayan Salazar
 */
public class ListarEmpresas {
    public static final MediaType JSON = MediaType.get("application/json");
    
    public static OkHttpClient client = new OkHttpClient();
    
    // Método GET para traer la lista de empresas
    public static List<Empresas> GET(String url) throws IOException {
        
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        Request request = new Request.Builder()
                .url(url)
                .addHeader("Token", token)
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Error en la solicitud: " + response);
            }

            // Convertir el cuerpo JSON a lista de Empresas
            String json = response.body().string();

            Gson gson = new Gson();
            Type listType = new TypeToken<List<Empresas>>() {}.getType();
            return gson.fromJson(json, listType);
        }
    }
}
