package com.spd.CItasDB;


/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author braya
 */
public class BarcazaCita {
    private String cliente;
    private String operacion;
    private String fechaHoraOperacion;
    private String nombreBarcaza;
    private double cantProducto;
    private String facturaRemision;
    private String archivo;
    private double precioUsd;
    private String observaciones;
    private String feEstimadaZarpe;
    private int nmformZf;
    private String barcazaDestino;

    public BarcazaCita(String cliente, String operacion, String fechaHoraOperacion, String nombreBarcaza, double cantProducto, String facturaRemision, String archivo, double precioUsd, String observaciones, String feEstimadaZarpe, int nmformZf, String barcazaDestino) {
        this.cliente = cliente;
        this.operacion = operacion;
        this.fechaHoraOperacion = fechaHoraOperacion;
        this.nombreBarcaza = nombreBarcaza;
        this.cantProducto = cantProducto;
        this.facturaRemision = facturaRemision;
        this.archivo = archivo;
        this.precioUsd = precioUsd;
        this.observaciones = observaciones;
        this.feEstimadaZarpe = feEstimadaZarpe;
        this.nmformZf = nmformZf;
        this.barcazaDestino = barcazaDestino;
    }
    
    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public String getOperacion() {
        return operacion;
    }

    public void setOperacion(String operacion) {
        this.operacion = operacion;
    }

    public String getFechaHoraOperacion() {
        return fechaHoraOperacion;
    }

    public void setFechaHoraOperacion(String fechaHoraOperacion) {
        this.fechaHoraOperacion = fechaHoraOperacion;
    }

    public String getNombreBarcaza() {
        return nombreBarcaza;
    }

    public void setNombreBarcaza(String nombreBarcaza) {
        this.nombreBarcaza = nombreBarcaza;
    }

    public double getCantProducto() {
        return cantProducto;
    }

    public void setCantProducto(double cantProducto) {
        this.cantProducto = cantProducto;
    }

    public String getFacturaRemision() {
        return facturaRemision;
    }

    public void setFacturaRemision(String facturaRemision) {
        this.facturaRemision = facturaRemision;
    }

    public String getArchivo() {
        return archivo;
    }

    public void setArchivo(String archivo) {
        this.archivo = archivo;
    }

    public double getPrecioUsd() {
        return precioUsd;
    }

    public void setPrecioUsd(double precioUsd) {
        this.precioUsd = precioUsd;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }

    public String getFeEstimadaZarpe() {
        return feEstimadaZarpe;
    }

    public void setFeEstimadaZarpe(String feEstimadaZarpe) {
        this.feEstimadaZarpe = feEstimadaZarpe;
    }

    public int getNmformZf() {
        return nmformZf;
    }

    public void setNmformZf(int nmformZf) {
        this.nmformZf = nmformZf;
    }

    public String getBarcazaDestino() {
        return barcazaDestino;
    }

    public void setBarcazaDestino(String barcazaDestino) {
        this.barcazaDestino = barcazaDestino;
    }
    
    
}
