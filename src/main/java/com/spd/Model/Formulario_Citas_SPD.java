/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 *
 * @author braya
 */
public class Formulario_Citas_SPD {
    private String usuario = "";
    private String operacion = "";
    private String fechaActual = "";
    private long cedula;
    private String placaCarro = "";
    private String numeroManifiesto = "";
    private String nitEmpresaTransportadora = "";

    // Constructor vacío
    public Formulario_Citas_SPD() {
        this.fechaActual = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(new Date());
    }

    // Constructor completo
    public Formulario_Citas_SPD(String usuario, String operacion, String fechaActual, long cedula, String placaCarro, String numeroManifiesto, String nitEmpresaTransportadora) {
        this.usuario = usuario;
        this.operacion = operacion;
        this.fechaActual = fechaActual;
        this.cedula = cedula;
        this.placaCarro = placaCarro;
        this.numeroManifiesto = numeroManifiesto;
        this.nitEmpresaTransportadora = nitEmpresaTransportadora;
    }

    // Getters y setters
    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getOperacion() {
        return operacion;
    }

    public void setOperacion(String operacion) {
        this.operacion = operacion;
    }

    public String getFechaActual() {
        return fechaActual;
    }

    public void setFechaActual(String fechaActual) {
        this.fechaActual = fechaActual;
    }

    public long getCedula() {
        return cedula;
    }

    public void setCedula(long cedula) {
        this.cedula = cedula;
    }

    public String getPlacaCarro() {
        return placaCarro;
    }

    public void setPlacaCarro(String placaCarro) {
        this.placaCarro = placaCarro;
    }

    public String getNumeroManifiesto() {
        return numeroManifiesto;
    }

    public void setNumeroManifiesto(String numeroManifiesto) {
        this.numeroManifiesto = numeroManifiesto;
    }

    public String getNitEmpresaTransportadora() {
        return nitEmpresaTransportadora;
    }

    public void setNitEmpresaTransportadora(String nitEmpresaTransportadora) {
        this.nitEmpresaTransportadora = nitEmpresaTransportadora;
    }

    @Override
    public String toString() {
        return "Formulario_Citas_SPD{" +
                "usuario='" + usuario + '\'' +
                ", operacion='" + operacion + '\'' +
                ", fechaActual='" + fechaActual + '\'' +
                ", cedula=" + cedula +
                ", placaCarro='" + placaCarro + '\'' +
                ", numeroManifiesto='" + numeroManifiesto + '\'' +
                ", nitEmpresaTransportadora='" + nitEmpresaTransportadora + '\'' +
                '}';
    }
}
