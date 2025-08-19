/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.informacionCita;

/**
 *
 * @author Brayan Salazar
 */
public class CitaInfo {
    private String codCita;
    private String nmformCita;
    private String nmformBascula;
    private String numTicket;
    private java.sql.Timestamp fechaEntrada;
    private Double pesoIngreso;
    private java.sql.Timestamp fechaSalida;
    private Double pesoSalida;
    private String placa;

    // Getters y setters
    public String getCodCita() { return codCita; }
    public void setCodCita(String codCita) { this.codCita = codCita; }

    public String getNmformCita() { return nmformCita; }
    public void setNmformCita(String nmformCita) { this.nmformCita = nmformCita; }

    public String getNmformBascula() { return nmformBascula; }
    public void setNmformBascula(String nmformBascula) { this.nmformBascula = nmformBascula; }

    public String getNumTicket() { return numTicket; }
    public void setNumTicket(String numTicket) { this.numTicket = numTicket; }

    public java.sql.Timestamp getFechaEntrada() { return fechaEntrada; }
    public void setFechaEntrada(java.sql.Timestamp fechaEntrada) { this.fechaEntrada = fechaEntrada; }

    public Double getPesoIngreso() { return pesoIngreso; }
    public void setPesoIngreso(Double pesoIngreso) { this.pesoIngreso = pesoIngreso; }

    public java.sql.Timestamp getFechaSalida() { return fechaSalida; }
    public void setFechaSalida(java.sql.Timestamp fechaSalida) { this.fechaSalida = fechaSalida; }

    public Double getPesoSalida() { return pesoSalida; }
    public void setPesoSalida(Double pesoSalida) { this.pesoSalida = pesoSalida; }

    public String getPlaca() { return placa; }
    public void setPlaca(String placa) { this.placa = placa; }
}
