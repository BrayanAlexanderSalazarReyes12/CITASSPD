/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.informacionCita;

/**
 *
 * @author Brayan Salazar
 */
public class EstadoCIta {
    String PLACA;
    String ESTADO;
    String CODCITA;

    public EstadoCIta() {
    }
    
    public EstadoCIta(String PLACA, String ESTADO, String CODCITA) {
        this.PLACA = PLACA;
        this.ESTADO = ESTADO;
        this.CODCITA = CODCITA;
    }

    public String getPLACA() {
        return PLACA;
    }

    public void setPLACA(String PLACA) {
        this.PLACA = PLACA;
    }

    public String getESTADO() {
        return ESTADO;
    }

    public void setESTADO(String ESTADO) {
        this.ESTADO = ESTADO;
    }

    public String getCODCITA() {
        return CODCITA;
    }

    public void setCODCITA(String CODCITA) {
        this.CODCITA = CODCITA;
    }
    
    
}
