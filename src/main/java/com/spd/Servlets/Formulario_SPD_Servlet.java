/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.Servlets;

import com.spd.API.FormularioPost;
import com.spd.ClasesJsonFormularioMinisterio.Acceso;
import com.spd.ClasesJsonFormularioMinisterio.FormularioCompleto;
import com.google.gson.Gson;
import com.spd.CItasDB.BarcazaCita;
import com.spd.CItasDB.CitaBascula;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.spd.ClasesJsonFormularioMinisterio.SistemaEnturnamiento;
import com.spd.ClasesJsonFormularioMinisterio.Variables;
import com.spd.ClasesJsonFormularioMinisterio.Vehiculo;
import com.spd.Model.FormularioCompletoSPDCARROTANQUE;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import org.json.JSONObject;
import com.spd.CItasDB.VehiculoDB;
import com.spd.Model.Cliente;

import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.util.Arrays;
import java.util.Base64;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Cookie;
import javax.servlet.http.Part;

/**
 *
 * @author braya
 */

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB en memoria antes de guardar a disco
    maxFileSize = 1024 * 1024 * 5,       // Máximo 5 MB por archivo
    maxRequestSize = 1024 * 1024 * 10    // Máximo 10 MB por toda la solicitud
)
public class Formulario_SPD_Servlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private JSONObject jsonEnv;

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
        //Obtener datos del formulario
        String usuario = request.getParameter("Cliente");
        
        String nombreUsuario = null;
        
        Cookie[] cookies = request.getCookies();
        
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("DATA".equals(cookie.getName())) {
                    nombreUsuario = cookie.getValue();
                    break;
                }
            }
        }

        // Lista de clientes (puedes mover esto a una clase utilitaria o a base de datos)
        List<Cliente> clientes = Arrays.asList(
            new Cliente("900328914-0", "C I CARIBBEAN BUNKERS S A S"),
            new Cliente("900614423-2", "ATLANTIC MARINE FUELS S A S C I"),
            new Cliente("806005826-3", "CODIS COLOMBIANA DE DISTRIBUCIONES Y SERVICIOS C I S A"),
            new Cliente("901312960-3", "C I CONQUERS WORLD TRADE S A S (CWT)"),
            new Cliente("901222050-1", "C I FUELS AND BUNKERS COLOMBIA S A S"),
            new Cliente("802024011-4", "C I INTERNATIONAL FUELS S A S"),
            new Cliente("901123549-8", "COMERCIALIZADORA INTERNACIONAL OCTANO INDUSTRIAL SAS"),
            new Cliente("806005346-1", "OPERACIONES TECNICAS MARINAS S A S"),
            new Cliente("819001667-8", "PETROLEOS DEL MILENIO S A S"),
            new Cliente("900992281-3", "C I PRODEXPORT DE COLOMBIA S A S"),
            new Cliente("890405769-3", "SOCIEDAD COLOMBIANA DE SERVICIOS PORTUARIOS S A SERVIPORT S A"),
            new Cliente("901.312.960–3", "C I CONQUERS WORLD TRADE S A S")
        );

        String empresaUsuario = null;

        // Buscar la empresa asociada al NIT
        for (Cliente cliente : clientes) {
            if (cliente.getNit().equals(nombreUsuario)) {
                empresaUsuario = cliente.getEmpresa();
                break;
            }
        }
        
        String Operaciones = request.getParameter("Operaciones");
        String OrdenOperacion = request.getParameter("ordenOperacion");
        
        int identificador = 0;
        if("operacion de cargue".equals(Operaciones)){
            identificador = 1;
        }else{
            identificador = 2;
        }
        
        String fecha = request.getParameter("fecha")+":00-05:00";
        String Cedula = request.getParameter("Cedula");
        String placa = request.getParameter("Placa");
        String Manifiesto = request.getParameter("Manifiesto");
        String Nitempresa = request.getParameter("Nitempresa");
        String verificacion = request.getParameter("Verificacion");
        String nombre = request.getParameter("Nombre");
        String cantidadproducto = request.getParameter("CantidadProducto");
        String FacturaComercial = request.getParameter("FacturaComercial");
        String Observaciones = request.getParameter("Observaciones");
        String PrecioArticulo = request.getParameter("PrecioArticulo");
        String Remolque = request.getParameter("Remolque");
        String TipoProducto = request.getParameter("tipoProducto");
        String PesoProducto = request.getParameter("PesoProducto");
        String Barcades = request.getParameter("Barcades");
        String producto = request.getParameter("tipoProducto");
                
        // Vehículos adicionales
        String[] cedulasExtras = request.getParameterValues("CedulaExtra");
        String[] placasExtras = request.getParameterValues("PlacaExtra");
        String[] manifiestosExtras = request.getParameterValues("ManifiestoExtra");
        String[] nombreconductorExtras = request.getParameterValues("nombreExtra");
        String[] remolqueExtras = request.getParameterValues("RemolqueExtra");
        
        if (cedulasExtras != null && placasExtras != null && manifiestosExtras != null) {
            for (int i = 0; i < cedulasExtras.length; i++) {
                JSONObject camionExtra = new JSONObject();
                camionExtra.put("cedulaConductor", cedulasExtras[i]);
                camionExtra.put("placa", placasExtras[i]);
                camionExtra.put("numeroManifiesto", manifiestosExtras[i]);
                camionExtra.put("nombreconductorExtras", nombreconductorExtras[i]);
                camionExtra.put("remolqueExtras", remolqueExtras[i]);
            }
        }
        
        //variables de entorno
        String path = getServletContext().getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content); // Parsea el JSON
        //System.out.println(jsonEnv);
        String RIEN = jsonEnv.optString("RIEN");
        String TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
        String SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
        String USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
        String CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
        
        // Construcción de lista de vehículos
        List<Vehiculo> vehiculos = new ArrayList<Vehiculo>();
        List<VehiculoDB> vehiculosDB = new ArrayList<VehiculoDB>();

        // Vehículo principal
        Vehiculo vehiculoPrincipal = new Vehiculo(placa, Cedula, fecha, Manifiesto, Remolque);
        vehiculos.add(vehiculoPrincipal);

        // Vehículos adicionales
        if (cedulasExtras != null && placasExtras != null && manifiestosExtras != null) {
            for (int i = 0; i < cedulasExtras.length; i++) {
                Vehiculo vehiculoExtra = new Vehiculo(placasExtras[i], cedulasExtras[i], fecha, manifiestosExtras[i], remolqueExtras[i]);
                VehiculoDB vdb = new VehiculoDB(placasExtras[i], cedulasExtras[i], nombreconductorExtras[i], fecha, manifiestosExtras[i]);
                vehiculos.add(vehiculoExtra);
                vehiculosDB.add(vdb);
            }
        }

        // Construcción de objetos finales
        Acceso acceso = new Acceso(USUARIOMINTRASPOR, CONTRAMINTRASPOR, RIEN);
        SistemaEnturnamiento sistemaEnturnamiento = new SistemaEnturnamiento(TERMINALPORTUARIANIT, SISTEMAENTURNAMIENTOID);
        Variables variables = new Variables(sistemaEnturnamiento, identificador, Nitempresa, vehiculos);
        FormularioCompleto formulario = new FormularioCompleto(acceso, variables);      
        
        Part archivoPDF = request.getPart("AdjuntoDeRemision");
        String facturacomerpdf = null;
        
        if (archivoPDF != null && archivoPDF.getSize() > 0) {
            try (InputStream is = archivoPDF.getInputStream();
                 ByteArrayOutputStream buffer = new ByteArrayOutputStream()) {

                byte[] data = new byte[1024];
                int bytesRead;
                while ((bytesRead = is.read(data, 0, data.length)) != -1) {
                    buffer.write(data, 0, bytesRead);
                }

                byte[] bytes = buffer.toByteArray();
                System.out.println(data.length);
                facturacomerpdf = Base64.getEncoder().encodeToString(bytes);
                System.out.println(facturacomerpdf.length());
            }
        }
        
        FormularioCompletoSPDCARROTANQUE fcspdcarrotanque = new FormularioCompletoSPDCARROTANQUE(usuario, Operaciones, fecha, Nitempresa, vehiculos, Manifiesto, TipoProducto, cantidadproducto, FacturaComercial, facturacomerpdf, PrecioArticulo, Observaciones);
        
        String nombreBarcaza = null;
        String nombreTanque = null;
        String operacion = null;
        Cookie[] cookies1 = request.getCookies();
        
        if (cookies1 != null) {
            for (Cookie cookie : cookies1) {
                if ("OPERACION".equals(cookie.getName())){
                    operacion = cookie.getValue();
                }
                if ("NOMBRE_DE_BARCAZA".equals(cookie.getName())) {
                    nombreBarcaza = cookie.getValue();
                }
                 if ("NOMBRE_TANQUE".equals(cookie.getName())) {
                    nombreTanque = cookie.getValue();
                }
            }
        }

        if (nombreBarcaza != null) {
            System.out.println("Nombre de la barcaza desde cookie: " + nombreBarcaza + "operacion: " + operacion + "tanque: " + nombreTanque);
        } else {
            System.out.println("La cookie NOMBRE_DE_BARCAZA no fue encontrada.");
        }
        
        BarcazaCita bc = new BarcazaCita(
                usuario,
                operacion,
                fecha,
                nombreBarcaza,
                producto,
                Double.parseDouble(cantidadproducto),
                FacturaComercial,
                facturacomerpdf,
                Double.parseDouble(PrecioArticulo),
                Observaciones,
                fecha,
                0,
                Barcades
        );
        
        CitaBascula cb = new CitaBascula(
                usuario,
                empresaUsuario,
                placa,Cedula,
                nombre,
                fecha,
                Manifiesto,
                0,
                Nitempresa,
                "PROGRAMADA",
                vehiculos.size(),
                TipoProducto,
                Integer.parseInt(cantidadproducto),
                FacturaComercial,
                Double.parseDouble(PrecioArticulo),
                facturacomerpdf,
                Observaciones,
                Operaciones,
                Remolque,
                nombreBarcaza,
                nombreTanque,
                vehiculosDB
        );
        
        //Convertir el Objeto a JSON
        Gson gson = new Gson();
        String json = gson.toJson(formulario);
        String json1 = gson.toJson(fcspdcarrotanque);
        String json2 = gson.toJson(cb);
        String json3 = gson.toJson(bc);
        
        //Configurar la respuesta como JSON
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        FormularioPost fp = new FormularioPost();
        String URL1 = "http://www.siza.com.co/spdcitas-1.0/api/citas/";
        String URL2 = "http://www.siza.com.co/spdcitas-1.0/api/citas/barcazas/";
        
        /*
            1. Programada
            2. Agendada
            3. 
            4. 
        */
        
        String URL = "https://rndcws2.mintransporte.gov.co/rest/RIEN";
        
        try {

            String response3 = ""; // Carro tanque
            String response4 = ""; // Barcaza

            // Operaciones que requieren ambos
            if (operacion.equals("Carrotanque - Barcaza") || operacion.equals("Barcaza - Carrotanque")) {
                
                System.out.println("Enviando datos a FormDB (Carro tanque)");
                
                System.out.println("Enviando datos a CitaBarcaza (Barcaza)");
                
                
                String response1 = fp.Post(URL, json);
                //System.out.println("Respuesta del servidor: " + response1);
                if (response1 != null && !response1.isEmpty()) {
                    JSONObject jsonResponse = new JSONObject(response1);

                    if (jsonResponse.has("ErrorCode")) {
                        int errorCode = jsonResponse.getInt("ErrorCode");

                        if (errorCode != 0) {
                            // Manejo del error
                            System.out.println("❌ Error detectado: " + jsonResponse.optString("ErrorText", "Sin detalle"));
                            //aqui tiene que estar los valores que le entrar al modal

                            //variable de seccion
                            HttpSession session = request.getSession();
                            session.setAttribute("Error", "Error: " + jsonResponse.optString("ErrorText", "Sin detalle"));
                            session.setAttribute("Activo", true);

                            session.setAttribute("clienteForm", usuario);
                            session.setAttribute("operacionesForm", Operaciones);
                            session.setAttribute("fechaForm", fecha);
                            session.setAttribute("verificacionForm", verificacion);
                            session.setAttribute("nitForm", Nitempresa);
                            session.setAttribute("cedulaForm", Cedula);
                            session.setAttribute("placaForm", placa);
                            session.setAttribute("manifiestoForm", Manifiesto);
                            session.setAttribute("cedulasExtras", cedulasExtras);
                            session.setAttribute("placasExtras", placasExtras);
                            session.setAttribute("manifiestosExtras", manifiestosExtras);
                            session.setAttribute("nombreconductor", nombre);
                            session.setAttribute("nombreconductorExtras", nombreconductorExtras);
                            session.setAttribute("CantidadProducto", cantidadproducto);
                            session.setAttribute("FacturaComercial", FacturaComercial);
                            session.setAttribute("Observaciones", Observaciones);
                            session.setAttribute("PrecioArticulo", PrecioArticulo);
                            session.setAttribute("Remolque", Remolque);
                            session.setAttribute("remolqueExtras", remolqueExtras);
                            session.setAttribute("PesoProducto", PesoProducto);
                            session.setAttribute("Barcades", Barcades);
                            
                            String OPERACION = "";
        
                            if (cookies != null) {
                                for (Cookie cookie : cookies) {
                                    if ("ORDEN_OPERACION".equals(cookie.getName())) {
                                        OPERACION = cookie.getValue();
                                        System.out.println("Valor de la cookie DATA: " + OPERACION);
                                        // Aquí puedes hacer lo que necesites con el valor
                                        break; // Salimos del bucle porque ya encontramos la cookie
                                    }
                                }
                            } else {
                                System.out.println("No hay cookies en la solicitud.");
                            }
                            
                            response.sendRedirect(request.getContextPath()+"/TiposProductos"+"?ordenOperacion="+OPERACION+"&operacion="+operacion+"&error=1"+"&mensaje="+jsonResponse.optString("ErrorText", "Sin detalle"));
                            
                            Cookie cookie = new Cookie("CITACREADA", "true");
                            cookie.setMaxAge(3600);
                            cookie.setPath("/CITASSPD");
                            response.addCookie(cookie);
                            
                            return;
                        } else {
                            System.out.println("✅ Todo correcto.");
                        }
                    } else {
                        int sesionId = jsonResponse.getInt("SesionId");
                        String ingresoId = jsonResponse.optString("IngresoId", "");

                        System.out.println("✅ Inicio de sesión exitoso. SesionId: " + sesionId + ", IngresoId: " + ingresoId);
                        HttpSession session = request.getSession();
                        session.setAttribute("Activo", true);
                        session.setAttribute("Error", "Formulario Enviado Con Exito: SesionId: " + sesionId + " IngresoId: " + ingresoId);

                        String operacionTerminada = (String) session.getAttribute("operacionSeleccionada");
                        List<String> operacionesPermitidas = (List<String>) session.getAttribute("Operacionespermitadas");

                        if (operacionesPermitidas != null && operacionTerminada != null) {
                            operacionesPermitidas.remove(operacionTerminada); // Marcar como finalizada
                            session.setAttribute("Operacionespermitadas", operacionesPermitidas);
                        }

                        //System.out.println(operacionTerminada);
                        //System.out.println(operacionesPermitidas);

                        //response.sendRedirect("../JSP/OperacionesActivas.jsp");

                        if (operacionesPermitidas != null && operacionTerminada != null) {
                            operacionesPermitidas.remove(operacionTerminada); // Marcar como finalizada
                            session.setAttribute("Operacionespermitadas", operacionesPermitidas);
                        }

                        response3 = fp.FormDB(URL1, json2);
                        response4 = fp.CitaBarcaza(URL2, json3);
                        
                        
                        //guardar formulario base de datos

                        //incluir el REM al momento de guardar la factuca comercial en la base de datos por ejemplo REM + FacturaComercial

                        //ListadoDAO list = new ListadoDAO();

                        //String json1 = gson.toJson(variables);

                        //list.InsertarCita(json1);

                        // Recargar la página
                        response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");// Esto recarga la página actual
                    }
                } else {
                    System.out.println("⚠️ Respuesta vacía.");
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Error: en este momento no se puede establecer conexión con el servidor. Por favor, intente más tarde.");
                    response.sendRedirect(request.getRequestURI()+"?ordenOperacion="+OrdenOperacion+"&operacion="+operacion); // También recarga si está vacía
                    return;
                }
            }

            // Solo barcaza
            else if (operacion.equals("Barcaza - Tanque") || operacion.equals("Tanque - Barcaza") || operacion.equals("Barcaza - Barcaza")) {
                response4 = fp.CitaBarcaza(URL2, json3);
                response.sendRedirect(request.getContextPath() + "/JSP/Listados_Citas.jsp");
                System.out.println("Enviando datos a CitaBarcaza (Solo Barcaza)");
            }

            // Solo carro tanque
            else if (operacion.equals("Carrotanque - Tanque") || operacion.equals("Tanque - Carrotanque")) {
                
                System.out.println("Enviando datos a FormDB (Solo Carro tanque)");
                
                String response1 = fp.Post(URL, json);
                //System.out.println("Respuesta del servidor: " + response1);
                if (response1 != null && !response1.isEmpty()) {
                    JSONObject jsonResponse = new JSONObject(response1);

                    if (jsonResponse.has("ErrorCode")) {
                        int errorCode = jsonResponse.getInt("ErrorCode");

                        if (errorCode != 0) {
                            // Manejo del error
                            System.out.println("❌ Error detectado: " + jsonResponse.optString("ErrorText", "Sin detalle"));
                            //aqui tiene que estar los valores que le entrar al modal

                            //variable de seccion
                            HttpSession session = request.getSession();
                            session.setAttribute("Error", "Error: " + jsonResponse.optString("ErrorText", "Sin detalle"));
                            session.setAttribute("Activo", true);

                            session.setAttribute("clienteForm", usuario);
                            session.setAttribute("operacionesForm", Operaciones);
                            session.setAttribute("fechaForm", fecha);
                            session.setAttribute("verificacionForm", verificacion);
                            session.setAttribute("nitForm", Nitempresa);
                            session.setAttribute("cedulaForm", Cedula);
                            session.setAttribute("placaForm", placa);
                            session.setAttribute("manifiestoForm", Manifiesto);
                            session.setAttribute("cedulasExtras", cedulasExtras);
                            session.setAttribute("placasExtras", placasExtras);
                            session.setAttribute("manifiestosExtras", manifiestosExtras);
                            session.setAttribute("nombreconductor", nombre);
                            session.setAttribute("nombreconductorExtras", nombreconductorExtras);
                            session.setAttribute("CantidadProducto", cantidadproducto);
                            session.setAttribute("FacturaComercial", FacturaComercial);
                            session.setAttribute("Observaciones", Observaciones);
                            session.setAttribute("PrecioArticulo", PrecioArticulo);
                            session.setAttribute("Remolque", Remolque);
                            session.setAttribute("remolqueExtras", remolqueExtras);
                            session.setAttribute("PesoProducto", PesoProducto);
                            session.setAttribute("Barcades", Barcades);
                            
                            String OPERACION = "";
        
                            if (cookies != null) {
                                for (Cookie cookie : cookies) {
                                    if ("ORDEN_OPERACION".equals(cookie.getName())) {
                                        OPERACION = cookie.getValue();
                                        System.out.println("Valor de la cookie DATA: " + OPERACION);
                                        // Aquí puedes hacer lo que necesites con el valor
                                        break; // Salimos del bucle porque ya encontramos la cookie
                                    }
                                }
                            } else {
                                System.out.println("No hay cookies en la solicitud.");
                            }
                            
                            response.sendRedirect(request.getContextPath()+"/TiposProductos"+"?ordenOperacion="+OPERACION+"&operacion="+operacion+"&error=1"+"&mensaje="+jsonResponse.optString("ErrorText", "Sin detalle")); // También recarga si está vacía
                            return;
                        } else {
                            System.out.println("✅ Todo correcto.");
                        }
                    } else {
                        int sesionId = jsonResponse.getInt("SesionId");
                        String ingresoId = jsonResponse.optString("IngresoId", "");

                        System.out.println("✅ Inicio de sesión exitoso. SesionId: " + sesionId + ", IngresoId: " + ingresoId);
                        HttpSession session = request.getSession();
                        session.setAttribute("Activo", true);
                        session.setAttribute("Error", "Formulario Enviado Con Exito: SesionId: " + sesionId + " IngresoId: " + ingresoId);

                        String operacionTerminada = (String) session.getAttribute("operacionSeleccionada");
                        List<String> operacionesPermitidas = (List<String>) session.getAttribute("Operacionespermitadas");

                        if (operacionesPermitidas != null && operacionTerminada != null) {
                            operacionesPermitidas.remove(operacionTerminada); // Marcar como finalizada
                            session.setAttribute("Operacionespermitadas", operacionesPermitidas);
                        }

                        //System.out.println(operacionTerminada);
                        //System.out.println(operacionesPermitidas);

                        //response.sendRedirect("../JSP/OperacionesActivas.jsp");

                        if (operacionesPermitidas != null && operacionTerminada != null) {
                            operacionesPermitidas.remove(operacionTerminada); // Marcar como finalizada
                            session.setAttribute("Operacionespermitadas", operacionesPermitidas);
                        }

                        response3 = fp.FormDB(URL1, json2);
                        
                        //guardar formulario base de datos

                        //incluir el REM al momento de guardar la factuca comercial en la base de datos por ejemplo REM + FacturaComercial

                        //ListadoDAO list = new ListadoDAO();

                        //String json1 = gson.toJson(variables);

                        //list.InsertarCita(json1);

                        // Recargar la página
                        response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");// Esto recarga la página actual
                    }
                } else {
                    System.out.println("⚠️ Respuesta vacía.");
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Error: en este momento no se puede establecer conexión con el servidor. Por favor, intente más tarde.");
                    response.sendRedirect(request.getRequestURI()+"?ordenOperacion="+OrdenOperacion+"&operacion="+operacion); // También recarga si está vacía
                    return;
                }
            }
            
            /*String response1 = fp.Post(URL, json);
            //System.out.println("Respuesta del servidor: " + response1);
            if (response1 != null && !response1.isEmpty()) {
                JSONObject jsonResponse = new JSONObject(response1);

                if (jsonResponse.has("ErrorCode")) {
                    int errorCode = jsonResponse.getInt("ErrorCode");

                    if (errorCode != 0) {
                        // Manejo del error
                        System.out.println("❌ Error detectado: " + jsonResponse.optString("ErrorText", "Sin detalle"));
                        //aqui tiene que estar los valores que le entrar al modal
                        
                        //variable de seccion
                        HttpSession session = request.getSession();
                        session.setAttribute("Error", "Error: " + jsonResponse.optString("ErrorText", "Sin detalle"));
                        session.setAttribute("Activo", true);
                        
                        session.setAttribute("clienteForm", usuario);
                        session.setAttribute("operacionesForm", Operaciones);
                        session.setAttribute("fechaForm", fecha);
                        session.setAttribute("verificacionForm", verificacion);
                        session.setAttribute("nitForm", Nitempresa);
                        session.setAttribute("cedulaForm", Cedula);
                        session.setAttribute("placaForm", placa);
                        session.setAttribute("manifiestoForm", Manifiesto);
                        session.setAttribute("cedulasExtras", cedulasExtras);
                        session.setAttribute("placasExtras", placasExtras);
                        session.setAttribute("manifiestosExtras", manifiestosExtras);
                        session.setAttribute("nombreconductor", nombre);
                        session.setAttribute("nombreconductorExtras", nombreconductorExtras);
                        session.setAttribute("CantidadProducto", cantidadproducto);
                        session.setAttribute("FacturaComercial", FacturaComercial);
                        session.setAttribute("Observaciones", Observaciones);
                        session.setAttribute("PrecioArticulo", PrecioArticulo);
                        session.setAttribute("Remolque", Remolque);
                        session.setAttribute("remolqueExtras", remolqueExtras);
                        session.setAttribute("PesoProducto", PesoProducto);
                        session.setAttribute("Barcades", Barcades);
                        response.sendRedirect(request.getContextPath() + "/JSP/Formulario.jsp");// Esto recarga la página actual 
                        
                        return;
                    } else {
                        System.out.println("✅ Todo correcto.");
                    }
                } else {
                    int sesionId = jsonResponse.getInt("SesionId");
                    String ingresoId = jsonResponse.optString("IngresoId", "");
                    
                    System.out.println("✅ Inicio de sesión exitoso. SesionId: " + sesionId + ", IngresoId: " + ingresoId);
                    HttpSession session = request.getSession();
                    session.setAttribute("Activo", true);
                    session.setAttribute("Error", "Formulario Enviado Con Exito: SesionId: " + sesionId + " IngresoId: " + ingresoId);
                    
                    String operacionTerminada = (String) session.getAttribute("operacionSeleccionada");
                    List<String> operacionesPermitidas = (List<String>) session.getAttribute("Operacionespermitadas");

                    if (operacionesPermitidas != null && operacionTerminada != null) {
                        operacionesPermitidas.remove(operacionTerminada); // Marcar como finalizada
                        session.setAttribute("Operacionespermitadas", operacionesPermitidas);
                    }

                    //System.out.println(operacionTerminada);
                    //System.out.println(operacionesPermitidas);

                    //response.sendRedirect("../JSP/OperacionesActivas.jsp");

                    if (operacionesPermitidas != null && operacionTerminada != null) {
                        operacionesPermitidas.remove(operacionTerminada); // Marcar como finalizada
                        session.setAttribute("Operacionespermitadas", operacionesPermitidas);
                    }
                    
                    
                    //guardar formulario base de datos
                    
                    //incluir el REM al momento de guardar la factuca comercial en la base de datos por ejemplo REM + FacturaComercial
                    
                    //ListadoDAO list = new ListadoDAO();
                    
                    //String json1 = gson.toJson(variables);
                    
                    //list.InsertarCita(json1);
                    
                    // Recargar la página
                    response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");// Esto recarga la página actual
                }
            } else {
                System.out.println("⚠️ Respuesta vacía.");
                HttpSession session = request.getSession();
                session.setAttribute("Activo", true);
                session.setAttribute("Error", "Error: en este momento no se puede establecer conexión con el servidor. Por favor, intente más tarde.");
                response.sendRedirect(request.getRequestURI()); // También recarga si está vacía
                return;
            }*/
            
        } catch (IOException e) {
            response.sendRedirect(request.getRequestURI()); // También recarga si está vacía
            System.out.println("Error1: " + e);
        }
        //guardar formulario base de datos
                    
                  //  ListadoDAO list = new ListadoDAO();
                    
                    //String json1 = gson.toJson(variables);
                    
                   // list.InsertarCita(json1);
                   
        
        // Mostrar resultado
        PrintWriter out = response.getWriter();
        out.print(json3);
        out.flush();
        
        
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
