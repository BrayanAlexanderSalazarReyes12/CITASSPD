/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author braya
 */
public class Usuarios_Tanques {
    // Mapa de tanques por cliente predefinido
    private final Map<String, List<String>> tanquesPorCliente;

    // Mapa que guarda los tanques asignados a los usuarios que han iniciado sesión
    private final Map<String, List<String>> tanquesPorUsuario;

    public Usuarios_Tanques() {
        tanquesPorCliente = new HashMap<>();
        tanquesPorUsuario = new HashMap<>();

        // Inicializamos los tanques por cliente
        tanquesPorCliente.put("cwtrade", Arrays.asList("TK101"));
        tanquesPorCliente.put("conquers", Arrays.asList("TK102", "TK109", "TK110"));
        tanquesPorCliente.put("ocindustrial", Arrays.asList("TK105"));
        tanquesPorCliente.put("amfuels", Arrays.asList("TK103", "TK104", "TK108"));
        tanquesPorCliente.put("prodexport", Arrays.asList("TK106"));
        tanquesPorCliente.put("Puma Energy", Arrays.asList("TK107"));
    }
    
    /**
     * Devuelve los tanques asignados a un usuario.
     */
    public List<String> obtenerTanquesDeUsuario(String usuario) {
        return tanquesPorUsuario.getOrDefault(usuario, new ArrayList<>());
    }

    /**
     * Devuelve todos los tanques por cliente.
     */
    public Map<String, List<String>> obtenerTanquesPorCliente() {
        return tanquesPorCliente;
    }

    /**
     * Verifica si un usuario tiene tanques asignados.
     */
    public boolean usuarioTieneTanques(String usuario) {
        return tanquesPorUsuario.containsKey(usuario);
    }
}
