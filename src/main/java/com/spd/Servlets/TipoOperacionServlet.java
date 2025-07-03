/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;

/**
 *
 * @author braya
 */
public class TipoOperacionServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        /*
             "Carro tanque - Barcaza",//✔
                  "Barcaza - Carro tanque", //✔
                  
                  "Carro tanque - Tanque",
                  "Tanque - Carro tanque",//✔
        */
        String[] operacionesPermitidas = {
            "Carrotanque - Barcaza",
            "Barcaza - Carrotanque",
            "Tanque - Carrotanque",
            "Carrotanque - Tanque"
        };

        

        int CantidadOperaciones = Integer.parseInt(request.getParameter("CantidadOperaciones"));
        List<String> operacionesper = new ArrayList<String>();
        List<String> Operaciones = new ArrayList<String>();
        List<String> tipoopeacionse = new ArrayList<String>();
        boolean hayOperacionValida = false;
        String ordenOperacion = null;
        String operacion = null;
        String NombreBarcaza = null;
        String tanque = null;
        String barcaza_origen = null;
        String barcaza_destino = null;
        String tipo_op = null;
        
        for (int i = 1; i <= CantidadOperaciones; i++) {
            ordenOperacion = "ordenoperacion_" + i;
            operacion = request.getParameter("operacion_" + i);
            NombreBarcaza = request.getParameter("barcaza_" + i);
            tanque = request.getParameter("tanque_" + i);
            barcaza_origen = request.getParameter("barcaza_origen_" + i);
            barcaza_destino = request.getParameter("barcaza_destino_" + i);
           
            
            //cokies
            
            // Construir el JSON
            JSONObject json = new JSONObject();
            json.put("ordenOperacion", ordenOperacion);
            json.put("operacion", operacion);
            json.put("NombreBarcaza", NombreBarcaza);
            json.put("Tanque", tanque);
            json.put("barcaza_origen", barcaza_origen);
            json.put("barcaza_destino", barcaza_destino);

             System.out.println(json);
            
            // Codificar el JSON para que sea seguro en cookies
            Gson gson = new Gson();
            String jsonfinal = gson.toJson(json);

            // Crear la cookie con el JSON
            Cookie datosCookie = new Cookie("datosBarcaza_" + i, jsonfinal);
            datosCookie.setMaxAge(60 * 60); // 1 hora
            datosCookie.setPath("/CITASSPD"); // ruta válida del contexto
            response.addCookie(datosCookie);
            
            if (Arrays.asList(operacionesPermitidas).contains(operacion)) {
                hayOperacionValida = true;
                operacionesper.add(operacion);
                
                if (operacion.equals("Barcaza - Carrotanque") || operacion.equals("Tanque - Carrotanque")) {
                    tipoopeacionse.add("operacion de cargue");
                } else if (operacion.equals("Carrotanque - Barcaza") || operacion.equals("Carrotanque - Tanque")) {
                    tipoopeacionse.add("operacion de descargue");
                }
            }
            Operaciones.add(operacion);
        }
        
        if (hayOperacionValida) {
            HttpSession session = request.getSession();
            session.setAttribute("ordenOperacion", ordenOperacion);
            session.setAttribute("operacion", operacion);
            session.setAttribute("NombreBarcaza", NombreBarcaza);
            session.setAttribute("Operacionespermitadas", operacionesper);
            session.setAttribute("TodasOperaciones", Operaciones);
            session.setAttribute("tipooperacionselect", tipoopeacionse);
            session.setAttribute("hayOperacionValida", true);
            
            //Añadir la conexion para guardar la informacion en la base de datos
            
            response.sendRedirect("JSP/OperacionesActivas.jsp");
        } else {
            HttpSession session = request.getSession();
            session.setAttribute("ordenOperacion", ordenOperacion);
            session.setAttribute("operacion", operacion);
            session.setAttribute("NombreBarcaza", NombreBarcaza);
            session.setAttribute("Operacionespermitadas", operacionesper);
            session.setAttribute("TodasOperaciones", Operaciones);
            session.setAttribute("tipooperacionselect", tipoopeacionse);
            session.setAttribute("hayOperacionValida", true);
           //Añadir la conexion para guardar la informacion en la base de datos
            
            response.sendRedirect("JSP/OperacionesActivas.jsp");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
