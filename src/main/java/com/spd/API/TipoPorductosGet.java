/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.API;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.spd.Productos.Producto;
import java.io.IOException;
import java.util.List;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

/**
 *
 * @author braya
 */
public class TipoPorductosGet {
    public List<Producto> LeerProductosEmpresa(String url, String token) throws IOException {
        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(url)
                .addHeader("Token", token) // Cambia a "Token" si tu API lo requiere así
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("Error en la solicitud: " + response);
            }

            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(response.body().string(), new TypeReference<List<Producto>>() {});
        }
    }
}
