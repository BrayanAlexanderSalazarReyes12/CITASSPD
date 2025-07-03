/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.API;


import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import okhttp3.*;

/**
 *
 * @author braya
 */
public class Usuario_Insert {
    public static final MediaType JSON = MediaType.get("application/json");
    
    OkHttpClient client = new OkHttpClient();
    
    public String Insert (String url, String json) throws IOException{
        RequestBody body = RequestBody.create(json, JSON);
        Request request = new Request.Builder()
            .url(url)
            .post(body)
            .build();
        try (Response response = client.newCall(request).execute()){
            return response.body().string();
        }
    }
    
    public String consultar (String url, String token) throws IOException{
        Request request = new Request.Builder()
            .url(url)
            .addHeader("token", token)
            .build();
        try (Response response = client.newCall(request).execute()){
            return response.body().string();
        }
    }
    
    public String Actualizar (String url, String usuario ,String json) throws IOException{
        String urlConParametro = url + "?usuario=" + URLEncoder.encode(usuario, StandardCharsets.UTF_8.toString());
        RequestBody body = RequestBody.create(json, JSON);
        Request request = new Request.Builder()
            .url(urlConParametro)
            .put(body)
            .build();
        try (Response response = client.newCall(request).execute()){
            return response.body().string();
        }
    }
}
