/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.DAO;

import Utilidades.Utilidades;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.spd.API.Usuario_Insert;
import com.spd.Model.Usuario;
import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author braya
 */
public class ListadoUsuarios {
    public List<Usuario> Obtenerusuarios() throws IOException {
        List<Usuario> list = new ArrayList<>();
        String url1 = "http://www.siza.com.co/spdcitas-1.0/api/citas/usuario";
     
        String token = "f470b475-f094-411c-a274-7c17e62b6c41";
        
        Usuario_Insert usuario_Insert = new Usuario_Insert();
        String json1 = usuario_Insert.consultar(url1, token);
        
        // Indicamos que es una lista de Usuario
        Type listType = new TypeToken<List<Usuario>>(){}.getType();
        
        //Convertir el Objeto a JSON
        Gson gson = new Gson();
        
        // Convertimos el JSON a lista
        List<Usuario> usuarios = gson.fromJson(json1, listType);
        
        list.addAll(usuarios);
                
        System.out.println(list);
        return list;
    }
}
