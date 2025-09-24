/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.SendMail;

import com.google.gson.Gson;
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
import java.util.Map;
import java.util.Objects;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
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
public class EnviarCorreoConfirmacionCIta extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = Logger.getLogger(EnviarCorreoConfirmacionCIta.class.getName());
    private static final Gson gson = new Gson();
    private JSONObject jsonEnv;

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Destinatarios del correo
        String[] destinatarios = { "bsalazar@zofranca.com" };

        // Recuperar datos de la cita (puedes quitar si no usas JSON)
        String NombreEmpresa = (String) request.getAttribute("NombreEmpresa");
        String fecha = (String) request.getAttribute("fe_aprobacion");

        if (NombreEmpresa == null) NombreEmpresa = "N/A";
        if (fecha == null) fecha = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(new Date());

        // Recuperar lista de vehículos enviada como atributo
        List<Map<String, String>> vehiculosFinales = (List<Map<String, String>>) request.getAttribute("vehiculosFinales");

        // === Construcción del mensaje HTML ===
        StringBuilder mensaje = new StringBuilder();
        mensaje.append("<h3>AUTORIZACIÓN DE INGRESO</h3>");
        mensaje.append("<p><b>FECHA:</b> ").append(formatearFecha(fecha)).append("</p>");
        mensaje.append("<p><b>CLIENTE:</b> ").append(NombreEmpresa).append("</p>");

        mensaje.append("<br><table border='1' cellpadding='5' cellspacing='0'>");
        mensaje.append("<tr><th>ITEM</th><th>PLACA</th><th>TRAILER</th><th>MANIFIESTO</th><th>CONDUCTOR</th><th>CEDULA</th><th>PRODUCTO</th><th>NIT-TRANSPORTADORA</th></tr>");

        if (vehiculosFinales != null && !vehiculosFinales.isEmpty()) {
            for (int i = 0; i < vehiculosFinales.size(); i++) {
                Map<String, String> v = vehiculosFinales.get(i);
                mensaje.append("<tr>");
                mensaje.append("<td>").append(i + 1).append("</td>");
                mensaje.append("<td>").append(v.get("placa")).append("</td>");
                mensaje.append("<td>").append("N/A").append("</td>"); // Trailer (si no lo tienes)
                mensaje.append("<td>").append(v.get("manifiesto")).append("</td>"); // Manifiesto (si no lo tienes)
                mensaje.append("<td>").append(v.get("nom_conductor")).append("</td>");
                mensaje.append("<td>").append(v.get("cedula")).append("</td>");
                mensaje.append("<td>").append("N/A").append("</td>"); // Producto (si no lo tienes)
                mensaje.append("<td>").append("N/A").append("</td>"); // NIT transportadora (si no lo tienes)
                mensaje.append("</tr>");
            }
        } else {
            mensaje.append("<tr><td colspan='8'>No se encontraron vehículos.</td></tr>");
        }

        mensaje.append("</table>");

        // === Enviar correo ===
        try {
            String asunto = "AUTORIZACIÓN INGRESO VEHÍCULOS - " 
                    + NombreEmpresa.toUpperCase()
                    + " - " + formatearFecha(fecha);

            enviarCorreo(destinatarios, asunto, mensaje.toString());
            //request.getSession().setAttribute("errorMsg", "CITA CREADA CON ÉXITO!!!");
            response.sendRedirect(request.getContextPath() + "/JSP/Listado_Citas.jsp");
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
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(emailUser, emailPass);
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
        try {
            Date date = javax.xml.bind.DatatypeConverter.parseDateTime(fechaIso8601).getTime();
            SimpleDateFormat formatoSalida = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            return formatoSalida.format(date);
        } catch (Exception e) {
            return fechaIso8601; // En caso de error, devolver la original
        }
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
