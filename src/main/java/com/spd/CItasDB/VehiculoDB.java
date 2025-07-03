/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CItasDB;

/**
 *
 * @author braya
 */
public class VehiculoDB {
    private String vehiculoNumPlaca;
    private String conductorCedulaCiudadania;
    private String nombreConductor;
    private String fechaOfertaSolicitud;
    private String numManifiestoCarga;

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

    public String getNombreConductor() {
        return nombreConductor;
    }

    public void setNombreConductor(String nombreConductor) {
        this.nombreConductor = nombreConductor;
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

    public VehiculoDB(String vehiculoNumPlaca, String conductorCedulaCiudadania, String nombreConductor, String fechaOfertaSolicitud, String numManifiestoCarga) {
        this.vehiculoNumPlaca = vehiculoNumPlaca;
        this.conductorCedulaCiudadania = conductorCedulaCiudadania;
        this.nombreConductor = nombreConductor;
        this.fechaOfertaSolicitud = fechaOfertaSolicitud;
        this.numManifiestoCarga = numManifiestoCarga;
    }
    
    
}
