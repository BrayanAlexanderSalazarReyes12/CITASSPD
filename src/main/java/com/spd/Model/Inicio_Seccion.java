/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

/**
 *
 * @author braya
 */
public class Inicio_Seccion {
     private String username;
    private String password;

    //Constructor vacio
    public Inicio_Seccion() {
    }

    public Inicio_Seccion(String nombre, String pass) {
        this.username = nombre;
        this.password = pass;
    }

    public String getNombre() {
        return username;
    }

    public void setNombre(String nombre) {
        this.username = nombre;
    }

    public String getPass() {
        return password;
    }

    public void setPass(String pass) {
        this.password = pass;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("username= ").append(username);
        sb.append(", password= ").append(password);
        sb.append("}");
        return sb.toString();
    }
}
