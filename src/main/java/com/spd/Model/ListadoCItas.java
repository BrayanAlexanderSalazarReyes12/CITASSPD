    /*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

import com.google.gson.annotations.SerializedName;
import com.spd.CItasDB.ListaVehiculos;
import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

/**
 *
 * @author braya
 */
public class ListadoCItas implements Serializable {
    
    private String nitEmpBascula;
    private String usuCreacion;
    private String operacion;
    private String codCita;
    private String fechaCita;
    private long feAprobacion;
    private String nitTransportadora;
    private int variosVehiculos;
    private String placa;
    private String cedConductor;
    private String nomConductor;
    private String manifiesto;
    private String estado;
    @SerializedName("nmformZf")
    private String fmm;
    private String archivo;
    private String facturaRemision;

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
    
    @SerializedName("vehiculos")
    private List<ListaVehiculos> vehiculos;

    public long getFeAprobacion() {
        return feAprobacion;
    }

    public void setFeAprobacion(long feAprobacion) {
        this.feAprobacion = feAprobacion;
    }
    
    public String getFmm() {
        return fmm;
    }

    public void setFmm(String fmm) {
        this.fmm = fmm;
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

    public String getManifiesto() {
        return manifiesto;
    }

    public void setManifiesto(String manifiesto) {
        this.manifiesto = manifiesto;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public List<ListaVehiculos> getVehiculos() {
        return vehiculos;
    }

    public void setVehiculos(List<ListaVehiculos> vehiculos) {
        this.vehiculos = vehiculos;
    }

    
    
    public String getCodCita() {
        return codCita;
    }

    public void setCodCita(String codCita) {
        this.codCita = codCita;
    }
    
    public String getNit() {
        return nitEmpBascula;
    }

    public void setNit(String Nit) {
        this.nitEmpBascula = Nit;
    }

    public String getNombre_Empresa() {
        return usuCreacion;
    }

    public void setNombre_Empresa(String nombre_Empresa) {
        this.usuCreacion = nombre_Empresa;
    }

    public String getTipo_Operacion() {
        return operacion;
    }

    public void setTipo_Operacion(String Tipo_Operacion) {
        this.operacion = Tipo_Operacion;
    }

    public String getFecha_Creacion_Cita() {
        return fechaCita;
    }

    public void setFecha_Creacion_Cita(String Fecha_Creacion_Cita) {
        this.fechaCita = Fecha_Creacion_Cita;
    }

    public String getNit_Empresa_Transportadora() {
        return nitTransportadora;
    }

    public void setNit_Empresa_Transportadora(String Nit_Empresa_Transportadora) {
        this.nitTransportadora = Nit_Empresa_Transportadora;
    }

    public int getCantidad_Vehiculos() {
        return variosVehiculos;
    }

    public void setCantidad_Vehiculos(int Cantidad_Vehiculos) {
        this.variosVehiculos = Cantidad_Vehiculos;
    }
    
    
}
