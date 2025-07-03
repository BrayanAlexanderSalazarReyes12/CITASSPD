/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.ClasesJsonFormularioMinisterio;

/**
 *
 * @author braya
 */
public class Vehiculo {
    private String vehiculoNumPlaca;
    private String conductorCedulaCiudadania;
    private String fechaOfertaSolicitud;
    private String numManifiestoCarga;
    private String numremolque;

    public Vehiculo(String vehiculoNumPlaca, String conductorCedulaCiudadania, String fechaOfertaSolicitud, String numManifiestoCarga, String numremolque) {
        this.vehiculoNumPlaca = vehiculoNumPlaca;
        this.conductorCedulaCiudadania = conductorCedulaCiudadania;
        this.fechaOfertaSolicitud = fechaOfertaSolicitud;
        this.numManifiestoCarga = numManifiestoCarga;
        this.numremolque = numremolque;
    }

    public String getNumremolque() {
        return numremolque;
    }

    public void setNumremolque(String numremolque) {
        this.numremolque = numremolque;
    }

    public String getVehiculoNumPlaca() {
        return vehiculoNumPlaca;
    }

    public void setVehiculoNumPlaca(String vehiculoNumPlaca) {
        this.vehiculoNumPlaca = vehiculoNumPlaca;
    }

    public String getConductorCedulaCiudadania() {
        return conductorCedulaCiudadania;
    }

    public void setConductorCedulaCiudadania(String conductorCedulaCiudadania) {
        this.conductorCedulaCiudadania = conductorCedulaCiudadania;
    }

    public String getFechaOfertaSolicitud() {
        return fechaOfertaSolicitud;
    }

    public void setFechaOfertaSolicitud(String fechaOfertaSolicitud) {
        this.fechaOfertaSolicitud = fechaOfertaSolicitud;
    }

    public String getNumManifiestoCarga() {
        return numManifiestoCarga;
    }

    public void setNumManifiestoCarga(String numManifiestoCarga) {
        this.numManifiestoCarga = numManifiestoCarga;
    }
    
    
}
