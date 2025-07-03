/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

/**
 *
 * @author braya
 */
public class OperacionEstado {
    private String nombre;
    private boolean finalizada;

    public OperacionEstado(String nombre, boolean finalizada) {
        this.nombre = nombre;
        this.finalizada = finalizada;
    }

    public String getNombre() {
        return nombre;
    }

    public boolean isFinalizada() {
        return finalizada;
    }
}
