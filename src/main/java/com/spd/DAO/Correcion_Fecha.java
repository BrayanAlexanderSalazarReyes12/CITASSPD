/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.DAO;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;

/**
 *
 * @author Brayan Salazar
 */
public class Correcion_Fecha {
    public static String ajustarFechaISO(String fechaEntrada) {
        // Detectar formato de entrada sin segundos: 2025-08-21T23:34
        DateTimeFormatter entrada = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        LocalDateTime fecha = LocalDateTime.parse(fechaEntrada, entrada);

        // Convertir a UTC (añadir Z)
        OffsetDateTime fechaUTC = fecha.atOffset(ZoneOffset.UTC);

        // Formato ISO con Z
        DateTimeFormatter salida = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss'Z'");
        return fechaUTC.format(salida);
    }
}
