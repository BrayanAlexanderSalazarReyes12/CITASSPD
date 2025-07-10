/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

/**
 *
 * @author braya
 */
public class Cliente {
    private String nit;
    private String empresa;

    public Cliente(String nit, String empresa) {
        this.nit = nit;
        this.empresa = empresa;
    }

    public String getNit() {
        return nit;
    }

    public String getEmpresa() {
        return empresa;
    }
}

