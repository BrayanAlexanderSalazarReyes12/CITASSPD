/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.informacionCita;

/**
 *
 * @author Brayan Salazar
 */
public class CitaFInal {
    String tipoOperacionId;
    String empresaTransportadoraNit;
    String vehiculoNumPlaca;
    String conductorCedulaCiudadania;
    String fechaOfertaSolicitud;
    String numManifiestoCarga;
    String nombreconductor;
    String formulario;
    String rol;
    String fechaentrada;
    String fechasalida;
    String pesoentrada;
    String pesosalida;
    String registro;
    
    public CitaFInal(String tipoOperacionId, String empresaTransportadoraNit, String vehiculoNumPlaca, String conductorCedulaCiudadania, String fechaOfertaSolicitud, String numManifiestoCarga, String nombreconductor, String formulario, String rol, String fechaentrada, String fechasalida, String pesoentrada, String pesosalida, String registro) {
        this.tipoOperacionId = tipoOperacionId;
        this.empresaTransportadoraNit = empresaTransportadoraNit;
        this.vehiculoNumPlaca = vehiculoNumPlaca;
        this.conductorCedulaCiudadania = conductorCedulaCiudadania;
        this.fechaOfertaSolicitud = fechaOfertaSolicitud;
        this.numManifiestoCarga = numManifiestoCarga;
        this.nombreconductor = nombreconductor;
        this.formulario = formulario;
        this.rol = rol;
        this.fechaentrada = fechaentrada;
        this.fechasalida = fechasalida;
        this.pesoentrada = pesoentrada;
        this.pesosalida = pesosalida;
        this.registro = registro;
    }

    public String getTipoOperacionId() {
        return tipoOperacionId;
    }

    public void setTipoOperacionId(String tipoOperacionId) {
        this.tipoOperacionId = tipoOperacionId;
    }

    public String getEmpresaTransportadoraNit() {
        return empresaTransportadoraNit;
    }

    public void setEmpresaTransportadoraNit(String empresaTransportadoraNit) {
        this.empresaTransportadoraNit = empresaTransportadoraNit;
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

    public String getNombreconductor() {
        return nombreconductor;
    }

    public void setNombreconductor(String nombreconductor) {
        this.nombreconductor = nombreconductor;
    }

    public String getFormulario() {
        return formulario;
    }

    public void setFormulario(String formulario) {
        this.formulario = formulario;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getFechaentrada() {
        return fechaentrada;
    }

    public void setFechaentrada(String fechaentrada) {
        this.fechaentrada = fechaentrada;
    }

    public String getFechasalida() {
        return fechasalida;
    }

    public void setFechasalida(String fechasalida) {
        this.fechasalida = fechasalida;
    }

    public String getPesoentrada() {
        return pesoentrada;
    }

    public void setPesoentrada(String pesoentrada) {
        this.pesoentrada = pesoentrada;
    }

    public String getPesosalida() {
        return pesosalida;
    }

    public void setPesosalida(String pesosalida) {
        this.pesosalida = pesosalida;
    }
    
    public String Gettregistro(){
        return registro;
    }
    
    public void Setregistro(String registro) {
        this.registro = registro;
    }
    
}
