/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.TiempoExtra;

import java.sql.Date;



/**
 *
 * @author Brayan Salazar
 */
public class TiempoExtra {
    private String NIT_EMPRESA;
    private Date FECHA_SOLICITUD;
    private Date FECHA_SERVICIO;
    private String TIPO_OPERACION;
    private String OPERACION;
    private String OBSERVACION;
    private String ESTADO;
    private String USU_APROBACION;

    public TiempoExtra() {
    }

    public TiempoExtra(String NIT_EMPRESA, Date FECHA_SOLICITUD, Date FECHA_SERVICIO, String TIPO_OPERACION, String OPERACION, String OBSERVACION, String ESTADO) {
        this.NIT_EMPRESA = NIT_EMPRESA;
        this.FECHA_SOLICITUD = FECHA_SOLICITUD;
        this.FECHA_SERVICIO = FECHA_SERVICIO;
        this.TIPO_OPERACION = TIPO_OPERACION;
        this.OPERACION = OPERACION;
        this.OBSERVACION = OBSERVACION;
        this.ESTADO = ESTADO;
    }
    
    

    public String getNIT_EMPRESA() {
        return NIT_EMPRESA;
    }

    public void setNIT_EMPRESA(String NIT_EMPRESA) {
        this.NIT_EMPRESA = NIT_EMPRESA;
    }

    public Date getFECHA_SOLICITUD() {
        return FECHA_SOLICITUD;
    }

    public void setFECHA_SOLICITUD(Date FECHA_SOLICITUD) {
        this.FECHA_SOLICITUD = FECHA_SOLICITUD;
    }

    public Date getFECHA_SERVICIO() {
        return FECHA_SERVICIO;
    }

    public void setFECHA_SERVICIO(Date FECHA_SERVICIO) {
        this.FECHA_SERVICIO = FECHA_SERVICIO;
    }

    public String getTIPO_OPERACION() {
        return TIPO_OPERACION;
    }

    public void setTIPO_OPERACION(String TIPO_OPERACION) {
        this.TIPO_OPERACION = TIPO_OPERACION;
    }

    public String getOPERACION() {
        return OPERACION;
    }

    public void setOPERACION(String OPERACION) {
        this.OPERACION = OPERACION;
    }

    public String getOBSERVACION() {
        return OBSERVACION;
    }

    public void setOBSERVACION(String OBSERVACION) {
        this.OBSERVACION = OBSERVACION;
    }

    public String getESTADO() {
        return ESTADO;
    }

    public void setESTADO(String ESTADO) {
        this.ESTADO = ESTADO;
    }

    public String getUSU_APROBACION() {
        return USU_APROBACION;
    }

    public void setUSU_APROBACION(String USU_APROBACION) {
        this.USU_APROBACION = USU_APROBACION;
    }
    
    
}
