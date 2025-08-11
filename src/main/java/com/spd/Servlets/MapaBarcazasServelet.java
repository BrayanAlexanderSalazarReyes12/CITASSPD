package com.spd.Servlets;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.nio.file.*;
import org.json.*;

/**
 *
 * @author Brayan Salazar
 */
@WebServlet("/MapaBarcazaServelet")
public class MapaBarcazasServelet extends HttpServlet {

        private static final String DATA_FILE = "/WEB-INF/data/posiciones.json";

        @Override
        protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
            String realPath = getServletContext().getRealPath(DATA_FILE);
            File file = new File(realPath);
            String json = file.exists() ? new String(Files.readAllBytes(file.toPath())) : "[]";

            response.setContentType("application/json");
            response.getWriter().write(json);
        }

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
            String body = request.getReader().lines().reduce("", (acc, line) -> acc + line);
            String realPath = getServletContext().getRealPath(DATA_FILE);
            Files.write(Paths.get(realPath), body.getBytes(), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
            response.getWriter().write("{\"status\":\"ok\"}");
        }

}
