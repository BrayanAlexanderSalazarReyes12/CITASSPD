/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.spd.ListarEmpresas;

import com.spd.API.ListarEmpresas;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Scanner;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class ListaEmpresasLogueadas {
    private static String URL = "http://www.siza.com.co/spdcitas-1.0/api/citas/empresas";
    
    public static void listaempresa(){
        try{
            List<Empresas> lista = ListarEmpresas.GET(URL);
            for (Empresas e : lista) {
                System.out.println(e.getCodNit() + " - " + e.getRazonSocial());
            }
        }catch (IOException e) {
            e.printStackTrace();
        }
    }
    
}
