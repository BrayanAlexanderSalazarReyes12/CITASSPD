/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Tanques;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.ServerException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class ObtenerTanques extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    private final Tanques_DB tanquesdb = new Tanques_DB();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServerException, IOException{
        response.setContentType("application/json;charset=UTF-8");
        String usuario = request.getParameter("usuario");
        
        Tanques_DB.inicializarDesdeContexto(getServletContext());
        try (PrintWriter out = response.getWriter()){
            List<Tanques> listaTanques = tanquesdb.ObtenerTanques(usuario);
            
            Gson gson = new Gson();
            String json = gson.toJson(listaTanques);
            out.print(json);
            out.flush();
        }catch (Exception e){
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
