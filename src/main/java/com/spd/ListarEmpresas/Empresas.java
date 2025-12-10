/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.ListarEmpresas;

import com.google.gson.annotations.SerializedName;

/**
 *
 * @author Brayan Salazar
 */
public class Empresas {
    @SerializedName("codciaUser")
    private String CodciaUser;
    @SerializedName("codnit")
    private String CodNit;
    @SerializedName("razonSocial")
    private String RazonSocial;

    public Empresas() {
    }

    public String getCodciaUser() {
        return CodciaUser;
    }

    public void setCodciaUser(String CodciaUser) {
        this.CodciaUser = CodciaUser;
    }

    public String getCodNit() {
        return CodNit;
    }

    public void setCodNit(String CodNit) {
        this.CodNit = CodNit;
    }

    public String getRazonSocial() {
        return RazonSocial;
    }

    public void setRazonSocial(String RazonSocial) {
        this.RazonSocial = RazonSocial;
    }
}
