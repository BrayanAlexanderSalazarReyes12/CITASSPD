/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CItasDB;

import java.util.List;

/**
 *
 * @author braya
 */
public class CitaBascula {
    private String nitEmpBascula;
    private String usuCreacion;
    private String placa;
    private String cedConductor;
    private String nomConductor;
    private String fechaCita;
    private String manifiesto;
    private int nmformZf;
    private String nitTransportadora;
    private String estado;
    private int variosVehiculos;
    private String producto;
    private int cantProducto;
    private String facturaRemision;
    private double precioUsd;
    private String archivo;
    private String observaciones;
    private String operacion;
    private String remolque;
    private String barcaza;
    private String tanque;
    private List<VehiculoDB> vehiculos;

    public CitaBascula() {
    }
    
    public CitaBascula(String nitEmpBascula, String usuCreacion, String placa, String cedConductor, String nomConductor, String fechaCita, String manifiesto, int nmformZf, String nitTransportadora, String estado, int variosVehiculos, String producto, int cantProducto, String facturaRemision, double precioUsd, String archivo, String observaciones, String operacion, String remolque, String barcaza, String tanque, List<VehiculoDB> vehiculos) {
        this.nitEmpBascula = nitEmpBascula;
        this.usuCreacion = usuCreacion;
        this.placa = placa;
        this.cedConductor = cedConductor;
        this.nomConductor = nomConductor;
        this.fechaCita = fechaCita;
        this.manifiesto = manifiesto;
        this.nmformZf = nmformZf;
        this.nitTransportadora = nitTransportadora;
        this.estado = estado;
        this.variosVehiculos = variosVehiculos;
        this.producto = producto;
        this.cantProducto = cantProducto;
        this.facturaRemision = facturaRemision;
        this.precioUsd = precioUsd;
        this.archivo = archivo;
        this.observaciones = observaciones;
        this.operacion = operacion;
        this.remolque = remolque;
        this.barcaza = barcaza;
        this.tanque = tanque;
        this.vehiculos = vehiculos;
    }
    
    
    public String getTanque() {
        return tanque;
    }

    public void setTanque(String tanque) {
        this.tanque = tanque;
    }
    
    public String getNitEmpBascula() {
        return nitEmpBascula;
    }

    public void setNitEmpBascula(String nitEmpBascula) {
        this.nitEmpBascula = nitEmpBascula;
    }

    public String getUsuCreacion() {
        return usuCreacion;
    }

    public void setUsuCreacion(String usuCreacion) {
        this.usuCreacion = usuCreacion;
    }

    public String getPlaca() {
        return placa;
    }

    public void setPlaca(String placa) {
        this.placa = placa;
    }

    public String getCedConductor() {
        return cedConductor;
    }

    public void setCedConductor(String cedConductor) {
        this.cedConductor = cedConductor;
    }

    public String getNomConductor() {
        return nomConductor;
    }

    public void setNomConductor(String nomConductor) {
        this.nomConductor = nomConductor;
    }

    public String getFechaCita() {
        return fechaCita;
    }

    public void setFechaCita(String fechaCita) {
        this.fechaCita = fechaCita;
    }

    public String getManifiesto() {
        return manifiesto;
    }

    public void setManifiesto(String manifiesto) {
        this.manifiesto = manifiesto;
    }

    public int getNmformZf() {
        return nmformZf;
    }

    public void setNmformZf(int nmformZf) {
        this.nmformZf = nmformZf;
    }

    public String getNitTransportadora() {
        return nitTransportadora;
    }

    public void setNitTransportadora(String nitTransportadora) {
        this.nitTransportadora = nitTransportadora;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public int getVariosVehiculos() {
        return variosVehiculos;
    }

    public void setVariosVehiculos(int variosVehiculos) {
        this.variosVehiculos = variosVehiculos;
    }

    public String getProducto() {
        return producto;
    }

    public void setProducto(String producto) {
        this.producto = producto;
    }

    public int getCantProducto() {
        return cantProducto;
    }

    public void setCantProducto(int cantProducto) {
        this.cantProducto = cantProducto;
    }

    public String getFacturaRemision() {
        return facturaRemision;
    }

    public void setFacturaRemision(String facturaRemision) {
        this.facturaRemision = facturaRemision;
    }

    public double getPrecioUsd() {
        return precioUsd;
    }

    public void setPrecioUsd(double precioUsd) {
        this.precioUsd = precioUsd;
    }

    public String getArchivo() {
        return archivo;
    }

    public void setArchivo(String archivo) {
        this.archivo = archivo;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getOperacion() {
        return operacion;
    }

    public void setOperacion(String operacion) {
        this.operacion = operacion;
    }

    public String getRemolque() {
        return remolque;
    }

    public void setRemolque(String remolque) {
        this.remolque = remolque;
    }

    public String getBarcaza() {
        return barcaza;
    }

    public void setBarcaza(String barcaza) {
        this.barcaza = barcaza;
    }

    public List<VehiculoDB> getVehiculos() {
        return vehiculos;
    }

    public void setVehiculos(List<VehiculoDB> vehiculos) {
        this.vehiculos = vehiculos;
    }
}
