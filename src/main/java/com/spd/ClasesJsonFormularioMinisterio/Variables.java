/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.ClasesJsonFormularioMinisterio;

import java.util.List;

/**
 *
 * @author braya
 */
public class Variables {
    private SistemaEnturnamiento sistemaEnturnamiento;
    private int tipoOperacionId;
    private String empresaTransportadoraNit;
    private List<Vehiculo> vehiculos;

    public Variables(SistemaEnturnamiento sistemaEnturnamiento, int tipoOperacionId, String empresaTransportadoraNit, List<Vehiculo> vehiculos) {
        this.sistemaEnturnamiento = sistemaEnturnamiento;
        this.tipoOperacionId = tipoOperacionId;
        this.empresaTransportadoraNit = empresaTransportadoraNit;
        this.vehiculos = vehiculos;
    }

    public SistemaEnturnamiento getSistemaEnturnamiento() {
        return sistemaEnturnamiento;
    }

    public void setSistemaEnturnamiento(SistemaEnturnamiento sistemaEnturnamiento) {
        this.sistemaEnturnamiento = sistemaEnturnamiento;
    }

    public int getTipoOperacionId() {
        return tipoOperacionId;
    }

    public void setTipoOperacionId(int tipoOperacionId) {
        this.tipoOperacionId = tipoOperacionId;
    }

    public String getEmpresaTransportadoraNit() {
        return empresaTransportadoraNit;
    }

    public void setEmpresaTransportadoraNit(String empresaTransportadoraNit) {
        this.empresaTransportadoraNit = empresaTransportadoraNit;
    }

    public List<Vehiculo> getVehiculos() {
        return vehiculos;
    }

    public void setVehiculos(List<Vehiculo> vehiculos) {
        this.vehiculos = vehiculos;
    }
    
    
}
