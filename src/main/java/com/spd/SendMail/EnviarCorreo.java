/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.SendMail;

import com.google.gson.Gson;
import com.spd.CItasDB.CantCitasProgram;
import com.spd.CItasDB.CitaBascula;
import com.spd.CItasDB.VehiculoDB;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.Properties;
import java.util.function.Supplier;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.xml.bind.DatatypeConverter;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class EnviarCorreo extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = Logger.getLogger(EnviarCorreo.class.getName());
    private static final Gson gson = new Gson();
    private JSONObject jsonEnv;

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Destinatarios
        String[] destinatarios = { "control@spdique.com" };

        // === Recuperar JSON de la cita ===
        String json = (String) request.getAttribute("json");
        String NombreEmpresa = (String) request.getAttribute("NombreEmpresa");
        if (json == null) {
            LOG.warning("No se recibió JSON en EnviarCorreo.");
            return;
        }

        // Parsear JSON a objeto
        CitaBascula cb = gson.fromJson(json, CitaBascula.class);
       
        // === Construir mensaje HTML ===
        StringBuilder mensaje = new StringBuilder();
        mensaje.append("<h3>AUTORIZACIÓN DE INGRESO</h3>");
        mensaje.append("<p><b>FECHA:</b> ").append(formatearFecha(cb.getFechaCita())).append("</p>");
        mensaje.append("<p><b>CLIENTE:</b> ").append(NombreEmpresa).append("</p>");
        mensaje.append("<p><b>OPERACIÓN:</b> ").append(cb.getOperacion()).append("</p>");
        mensaje.append("<p><b>OBSERVACIÓN:</b> ").append(cb.getObservaciones()).append("</p>");
        mensaje.append("<p><b>NIT:</b> ").append(cb.getNitTransportadora()).append("</p>");

        mensaje.append("<br><table border='1' cellpadding='5' cellspacing='0'>");
        mensaje.append("<tr><th>ITEM</th><th>PLACA</th><th>TRAILER</th><th>MANIFIESTO</th><th>CONDUCTOR</th><th>CEDULA</th><th>PRODUCTO</th><th>NIT-TRANSPORTADORA</th></tr>");

        List<VehiculoDB> vehiculos = cb.getVehiculos();
        for (int i = 0; i < vehiculos.size(); i++) {
            VehiculoDB v = vehiculos.get(i);
            mensaje.append("<tr>");
            mensaje.append("<td>").append(i + 1).append("</td>");
            mensaje.append("<td>").append(v.getVehiculoNumPlaca()).append("</td>");
            mensaje.append("<td>").append(cb.getRemolque()).append("</td>");
            mensaje.append("<td>").append(v.getNumManifiestoCarga()).append("</td>");
            mensaje.append("<td>").append(v.getNombreConductor()).append("</td>");
            mensaje.append("<td>").append(v.getConductorCedulaCiudadania()).append("</td>");
            mensaje.append("<td>").append(cb.getProducto()).append("</td>");
            mensaje.append("<td>").append(cb.getNitTransportadora()).append("</td>");
            mensaje.append("</tr>");
        }
        mensaje.append("</table>");

        // === Enviar correo ===
        try {
            String asunto = "AUTORIZACIÓN INGRESO VEHÍCULOS - " 
                    + (cb.getNitEmpBascula()!= null ? NombreEmpresa.toUpperCase() : "")
                    + " - " + formatearFecha(cb.getFechaCita());

            enviarCorreo(destinatarios, asunto, mensaje.toString());
            request.getSession().setAttribute("errorMsg", "CITA CREADA CON EXITO!!!");
            response.sendRedirect(request.getContextPath() + "/JSP/OperacionesActivas.jsp");
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Error al enviar correo", e);
        }
    }

    private void enviarCorreo(String[] destinatarios, String asunto, String contenidoHtml) {
        try {
            String path = getServletContext().getRealPath("/WEB-INF/json.env");
            String content = new String(Files.readAllBytes(Paths.get(path)));
            jsonEnv = new JSONObject(content);
            JSONObject emailConfig = jsonEnv.getJSONObject("EMAIL");
            
            String emailUser = emailConfig.getString("EMAIL_FROM");
            String emailPass = emailConfig.getString("EMAIL_PASSWORD");
            
            Properties props = new Properties();
            props.put("mail.smtp.host", emailConfig.getString("SMTP_HOST"));
            props.put("mail.smtp.port", emailConfig.getString("SMTP_PORT"));
            props.put("mail.smtp.auth", emailConfig.getString("SMTP_AUTH"));
            props.put("mail.smtp.starttls.enable", emailConfig.getString("STARTTLS_ENABLE"));
            props.put("mail.smtp.ssl.trust", emailConfig.getString("SSL_TRUST"));

            Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
                @Override
                protected javax.mail.PasswordAuthentication getPasswordAuthentication() {
                    return new javax.mail.PasswordAuthentication(emailUser,emailPass);
                }
            });

            Message message = new MimeMessage(mailSession);
            message.setFrom(new InternetAddress(emailUser));

            InternetAddress[] toAddresses = Arrays.stream(destinatarios)
                    .map(d -> {
                        try { return new InternetAddress(d); } 
                        catch (Exception e) { return null; }
                    })
                    .filter(Objects::nonNull)
                    .toArray(InternetAddress[]::new);

            message.setRecipients(Message.RecipientType.TO, toAddresses);
            message.setSubject(asunto);
            message.setContent(contenidoHtml, "text/html; charset=UTF-8");

            Transport.send(message);
            
            LOG.info("Correo enviado correctamente.");
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Error enviando correo", e);
        }
    }
    
    public static String formatearFecha(String fechaIso8601) {
        Date date = DatatypeConverter.parseDateTime(fechaIso8601).getTime();
        SimpleDateFormat formatoSalida = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        return formatoSalida.format(date);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para enviar correo de nueva cita con detalle de vehículos";
    }
    
}
