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
public class LoginPost {
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
}
