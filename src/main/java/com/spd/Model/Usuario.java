/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.Model;

/**
 *
 * @author braya
 */
public class Usuario {
    private String username;
    private String nit_cliente;
    private String codcia_user;
    private String email;
    private int rol;
    private int estado;

    // Getters
    public String getUsername() { return username; }
    public String getNit_cliente() { return nit_cliente; }
    public String getCodcia_user() { return codcia_user; }
    public String getEmail() { return email; }
    public int getRol() { return rol; }
    public int getEstado() { return estado; }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setNit_cliente(String nit_cliente) {
        this.nit_cliente = nit_cliente;
    }

    public void setCodcia_user(String codcia_user) {
        this.codcia_user = codcia_user;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setRol(int rol) {
        this.rol = rol;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }

    public Usuario(String username, String nit_cliente, String codcia_user, String email, int rol, int estado) {
        this.username = username;
        this.nit_cliente = nit_cliente;
        this.codcia_user = codcia_user;
        this.email = email;
        this.rol = rol;
        this.estado = estado;
    }
    
    
}
