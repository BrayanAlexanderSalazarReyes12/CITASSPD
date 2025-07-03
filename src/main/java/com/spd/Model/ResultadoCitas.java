/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

import java.util.List;

/**
 *
 * @author braya
 */
public class ResultadoCitas {
    private List<ListadoCItas> citasVehiculos;
    private List<ListadoCItas> citasVehiculos2;
    private List<ListadoCitasBar> citasBarcazas;

    public ResultadoCitas(List<ListadoCItas> citasVehiculos, List<ListadoCItas> citasVehiculos2, List<ListadoCitasBar> citasBarcazas) {
        this.citasVehiculos = citasVehiculos;
        this.citasVehiculos2 = citasVehiculos2;
        this.citasBarcazas = citasBarcazas;
    }
    
    public List<ListadoCItas> getCitasVehiculos2() {
        return citasVehiculos2;
    }

    public List<ListadoCItas> getCitasVehiculos() {
        return citasVehiculos;
    }

    public List<ListadoCitasBar> getCitasBarcazas() {
        return citasBarcazas;
    }
}
