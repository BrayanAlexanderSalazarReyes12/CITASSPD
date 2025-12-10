/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.ListarEmpresas;

import com.spd.API.ListarEmpresas;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Scanner;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class ListaEmpresasLogueadas {
    private static String URL = "http://www.siza.com.co/spdcitas-1.0/api/citas/empresas";

    public static String listaempresa(String nitCookie) {
        try {
            if (nitCookie == null || nitCookie.trim().isEmpty()) {
                System.out.println("No se proporcionó un NIT válido.");
                return null;
            }

            // Quitar último dígito si quieres
            if (nitCookie.length() > 9) {
                nitCookie = nitCookie.substring(0, nitCookie.length() - 1);
            }

            final String nitFiltro = nitCookie.trim();

            List<Empresas> lista = ListarEmpresas.GET(URL);
            if (lista == null) lista = new ArrayList<>();

            Empresas mejorCoincidencia = lista.stream()
                .filter(e -> e != null && e.getCodNit() != null)
                .filter(e -> {
                    // 1. Obtener codNit y limpiar espacios
                    String codNit = e.getCodNit().trim();

                    // 2. Quitar puntos
                    codNit = codNit.replace(".", "");

                    // 3. Si contiene guion normal o largo, eliminar todo después del guion
                    if (codNit.contains("-") || codNit.contains("–")) {
                        codNit = codNit.split("[-–]")[0]; // toma la parte antes del guion
                    }

                    // 4. Normalizar nitFiltro de la misma forma
                    String nitBuscado = nitFiltro.replace(".", "").trim();
                    if (nitBuscado.contains("-") || nitBuscado.contains("–")) {
                        nitBuscado = nitBuscado.split("[-–]")[0];
                    }

                    // 5. Comparar
                    return codNit.equals(nitBuscado);
                })
                .findFirst()
                .orElse(null);


            // Retornar el NIT encontrado
            if (mejorCoincidencia != null) {
                System.out.println("Coincidencia encontrada: "
                        + mejorCoincidencia.getCodNit() + " - "
                        + mejorCoincidencia.getRazonSocial());
                return mejorCoincidencia.getCodNit(); // <--- retorna el NIT original
            } else {
                System.out.println("No se encontró coincidencia exacta.");
                return null;
            }

        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
        }

}
