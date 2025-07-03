/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

import com.spd.ClasesJsonFormularioMinisterio.Vehiculo;
import java.util.List;


/**
 *
 * @author braya
 */
public class FormularioCompletoSPDCARROTANQUE {
    private String cliente;
    private String operaciones;
    private String FechaIngreso;
    private String nitempresa;
    private List<Vehiculo> vehiculos;
    private String manifiesto;
    private String tipoproducto;
    private String cantidad;
    private String facturacomer;
    private String facturacomerpdf;
    private String precio;
    private String observaciones;    

    public FormularioCompletoSPDCARROTANQUE(String cliente, String operaciones, String FechaIngreso, String nitempresa, List<Vehiculo> vehiculos, String manifiesto, String tipoproducto, String cantidad, String facturacomer, String facturacomerpdf, String precio, String observaciones) {
        this.cliente = cliente;
        this.operaciones = operaciones;
        this.FechaIngreso = FechaIngreso;
        this.nitempresa = nitempresa;
        this.vehiculos = vehiculos;
        this.manifiesto = manifiesto;
        this.tipoproducto = tipoproducto;
        this.cantidad = cantidad;
        this.facturacomer = facturacomer;
        this.facturacomerpdf = facturacomerpdf;
        this.precio = precio;
        this.observaciones = observaciones;
    }
    
    
    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public String getOperaciones() {
        return operaciones;
    }

    public void setOperaciones(String operaciones) {
        this.operaciones = operaciones;
    }

    public String getFechaIngreso() {
        return FechaIngreso;
    }

    public void setFechaIngreso(String FechaIngreso) {
        this.FechaIngreso = FechaIngreso;
    }

    public String getNitempresa() {
        return nitempresa;
    }

    public void setNitempresa(String nitempresa) {
        this.nitempresa = nitempresa;
    }

    public List<Vehiculo> getVehiculos() {
        return vehiculos;
    }

    public void setVehiculos(List<Vehiculo> vehiculos) {
        this.vehiculos = vehiculos;
    }

    public String getManifiesto() {
        return manifiesto;
    }

    public void setManifiesto(String manifiesto) {
        this.manifiesto = manifiesto;
    }

    public String getTipoproducto() {
        return tipoproducto;
    }

    public void setTipoproducto(String tipoproducto) {
        this.tipoproducto = tipoproducto;
    }

    public String getCantidad() {
        return cantidad;
    }

    public void setCantidad(String cantidad) {
        this.cantidad = cantidad;
    }

    public String getFacturacomer() {
        return facturacomer;
    }

    public void setFacturacomer(String facturacomer) {
        this.facturacomer = facturacomer;
    }

    public String getFacturacomerpdf() {
        return facturacomerpdf;
    }

    public void setFacturacomerpdf(String facturacomerpdf) {
        this.facturacomerpdf = facturacomerpdf;
    }

    public String getPrecio() {
        return precio;
    }

    public void setPrecio(String precio) {
        this.precio = precio;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    
}
