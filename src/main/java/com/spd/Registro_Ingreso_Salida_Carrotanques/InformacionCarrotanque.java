/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Registro_Ingreso_Salida_Carrotanques;

/**
 *
 * @author Brayan Salazar
 */
public class InformacionCarrotanque {
    private String Codcita;
    private String Placa;
    private String EmpresaTransportadora;
    private String Estado;

    public InformacionCarrotanque() {
    }

    public InformacionCarrotanque(String Codcita, String Placa, String Estado) {
        this.Codcita = Codcita;
        this.Placa = Placa;
        this.Estado = Estado;
    }
    
    public String getCodcita() {
        return Codcita;
    }

    public void setCodcita(String Codcita) {
        this.Codcita = Codcita;
    }

    public String getPlaca() {
        return Placa;
    }

    public void setPlaca(String Placa) {
        this.Placa = Placa;
    }

    public String getEmpresaTransportadora() {
        return EmpresaTransportadora;
    }

    public void setEmpresaTransportadora(String EmpresaTransportadora) {
        this.EmpresaTransportadora = EmpresaTransportadora;
    }

    public String getEstado() {
        return Estado;
    }

    public void setEstado(String Estado) {
        this.Estado = Estado;
    }
    
    
}
