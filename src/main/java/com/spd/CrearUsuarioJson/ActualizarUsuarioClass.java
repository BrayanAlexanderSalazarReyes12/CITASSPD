/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.CrearUsuarioJson;

/**
 *
 * @author braya
 */
public class ActualizarUsuarioClass {
    private String username;
    private String password;
    private String nit_cliente;
    private String codcia_user;
    private String email;
    private int rol;
    private int estado;

    public ActualizarUsuarioClass(String username, String password, String nit_cliente, String codcia_user, String email, int rol, int estado) {
        this.username = username;
        this.password = password;
        this.nit_cliente = nit_cliente;
        this.codcia_user = codcia_user;
        this.email = email;
        this.rol = rol;
        this.estado = estado;
    }

    
}
