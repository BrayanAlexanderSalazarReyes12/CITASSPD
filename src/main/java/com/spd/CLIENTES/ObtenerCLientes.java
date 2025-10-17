/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.CLIENTES;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Brayan Salazar
 */
public class ObtenerCLientes extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    private final ClientesDAO cdao = new ClientesDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String nit = request.getParameter("nit");
        
        ClientesDAO.inicializarDesdeContexto(getServletContext());
        try (PrintWriter out = response.getWriter()){
            List<Clientes> ListaClientes = cdao.ObtenerClientes(nit);
            
            Gson gson = new Gson();
            String json = gson.toJson(ListaClientes);
            System.out.println(json);
            out.print(json);
            out.flush();
        }catch (Exception e){
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
