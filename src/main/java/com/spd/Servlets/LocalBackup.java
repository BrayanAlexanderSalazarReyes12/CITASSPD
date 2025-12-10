/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Servlets;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import javax.servlet.ServletContext;

/**
 *
 * @author Brayan Salazar
 */
public class LocalBackup {
    /**
     * Guarda un JSON en la carpeta "data_pendiente" dentro de la aplicación web.
     *
     * @param json      El contenido JSON a guardar.
     * @param context   El ServletContext de la aplicación.
     * @param Usuario   El Nombre del usuario
     * @param CODCITA   El Codico de creacion de la cita
     * @throws IOException Si ocurre un error al escribir el archivo.
     */
    
    public static void save(String json, ServletContext context, String Usuario, String CODCITA) throws IOException {
        // Obtener la ruta física dentro de la carpeta web
        String path = context.getRealPath("/data_pendiente/");

        // Crear directorio si no existe
        File directory = new File(path);
        if (!directory.exists()) {
            directory.mkdirs();
        }

        // Crear nombre de archivo único
        String nombre = "cita_" + Usuario + CODCITA + ".json";
        File file = new File(directory, nombre);

        // Guardar el JSON
        try (FileWriter fw = new FileWriter(file)) {
            fw.write(json);
        }
    }
}
