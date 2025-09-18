/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.SendMail;

import com.google.gson.Gson;
import com.spd.CItasDB.BarcazaCita;
import com.spd.CItasDB.VehiculoDB;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.DatatypeConverter;
import org.json.JSONObject;

/**
 *
 * @author Brayan Salazar
 */
public class EnviarCorreoBarcaza extends HttpServlet {

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
        BarcazaCita bc = gson.fromJson(json, BarcazaCita.class);
       
        // === Construir mensaje HTML ===
        StringBuilder mensaje = new StringBuilder();
        mensaje.append("<h3>AUTORIZACIÓN DE INGRESO</h3>");
        mensaje.append("<p><b>FECHA:</b> ").append(formatearFecha(bc.getFechaHoraOperacion())).append("</p>");
        mensaje.append("<p><b>CLIENTE:</b> ").append(NombreEmpresa).append("</p>");
        mensaje.append("<p><b>OPERACIÓN:</b> ").append(bc.getOperacion()).append("</p>");
        mensaje.append("<p><b>OBSERVACIÓN:</b> ").append(bc.getObservaciones()).append("</p>");

        mensaje.append("<br><table border='1' cellpadding='5' cellspacing='0'>");
        mensaje.append("<tr><th>ITEM</th><th>NOMBRE BARCAZA</th><th>NOMBRE BARCAZA DESTINO</th><th>OPERACION</th><th>PRODUCTO</th><th>CANTODAD PRODUCTO</th><th>OBSERVACIONES</th></tr>");

        mensaje.append("<tr>");
        mensaje.append("<td>").append(1).append("</td>");
        mensaje.append("<td>").append(bc.getNombreBarcaza()).append("</td>");
        mensaje.append("<td>").append(bc.getBarcazaDestino()).append("</td>");
        mensaje.append("<td>").append(bc.getOperacion()).append("</td>");
        mensaje.append("<td>").append(bc.getProducto()).append("</td>");
        mensaje.append("<td>").append(bc.getCantProducto()).append("</td>");
        mensaje.append("<td>").append(bc.getObservaciones()).append("</td>");
        mensaje.append("</tr>");
        mensaje.append("</table>");

        // === Enviar correo ===
        try {
            String asunto = "AUTORIZACIÓN INGRESO VEHÍCULOS - " 
                    + (bc.getCliente()!= null ? NombreEmpresa.toUpperCase() : "")
                    + " - " + formatearFecha(bc.getFechaHoraOperacion());

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
