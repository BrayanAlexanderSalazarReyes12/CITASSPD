/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.spd.SendMail;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.spd.CItasDB.CantCitasProgram;
import com.spd.CItasDB.CitaBascula;
import com.spd.CItasDB.VehiculoDB;
import com.spd.Model.Cliente;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;
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
public class EnviarCorreo extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private static final Logger LOG = Logger.getLogger(EnviarCorreo.class.getName());
    private static final Gson gson = new Gson();
    private JSONObject jsonEnv;
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Destinatarios
        String[] destinatarios = { "bsalazar@zofranca.com", "lreyes@spdique.com" };

        // === Recuperar JSON reducido ===
        String json = (String) request.getSession().getAttribute("json");

        System.out.println(json);
        if (json == null) {
            LOG.warning("No se recibió JSON en EnviarCorreo.");
            return;
        }

        // Parsear como lista de mapas
        Type listType = new TypeToken<List<Map<String, String>>>(){}.getType();
        List<Map<String, String>> filas = gson.fromJson(json, listType);

        if (filas == null || filas.isEmpty()) {
            LOG.warning("El JSON recibido está vacío o no válido.");
            return;
        }

        // Lista de clientes (ideal mover a repositorio/DB)
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
            new Cliente("901.312.960–3", "C I CONQUERS WORLD TRADE S A S"),
            new Cliente("901826337-0", "CONQUERS ZF"),
            new Cliente("901.222.050-1", "C I FUELS AND BUNKERS COLOMBIA S A S")
        );

        // === Obtener cliente de la primera fila ===
        String nit = filas.get(0).getOrDefault("NIT", "");
        String nombreCliente = clientes.stream()
                .filter(c -> c.getNit().equals(nit))
                .map(Cliente::getEmpresa)
                .findFirst()
                .orElse("CLIENTE DESCONOCIDO");

        // === Construir mensaje HTML ===
        StringBuilder mensaje = new StringBuilder();
        mensaje.append("<h3>AUTORIZACIÓN DE INGRESO</h3>");
        mensaje.append("<p><b>Cliente:</b> ").append(nombreCliente)
               .append(" &nbsp;&nbsp; <b>NIT:</b> ").append(nit).append("</p>");

        mensaje.append("<br><table border='1' cellpadding='5' cellspacing='0'>");
        mensaje.append("<tr>")
               .append("<th>ITEM</th>")
               .append("<th>CODCITA</th>")
               .append("<th>PLACA</th>")
               .append("<th>TRAILER</th>")
               .append("<th>MANIFIESTO</th>")
               .append("<th>CONDUCTOR</th>")
               .append("<th>CEDULA</th>")
               .append("<th>PRODUCTO</th>")
               .append("<th>NIT-TRANSPORTADORA</th>")
               .append("<th>FECHA</th>")
               .append("<th>OPERACION</th>")
               .append("<th>OBSERVACION</th>")
               .append("<th>NIT</th>")
               .append("<th>CLIENTE</th>")
               .append("</tr>");

        for (int i = 0; i < filas.size(); i++) {
            Map<String, String> fila = filas.get(i);
            mensaje.append("<tr>");
            mensaje.append("<td>").append(i + 1).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("CODCITA", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("PLACA", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("TRAILER", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("MANIFIESTO", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("CONDUCTOR", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("CEDULA", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("PRODUCTO", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("NIT-TRANSPORTADORA", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("FECHA", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("OPERACION", "")).append("</td>");
            mensaje.append("<td>").append(fila.getOrDefault("OBSERVACION", "")).append("</td>");
            mensaje.append("<td>").append(nit).append("</td>");
            mensaje.append("<td>").append(nombreCliente).append("</td>");
            mensaje.append("</tr>");
        }
        mensaje.append("</table>");


        // === Enviar correo ===
        try {
            String fechaHoy = new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date());
            String asunto = "AUTORIZACIÓN INGRESO VEHÍCULOS - " + fechaHoy;

            enviarCorreo(destinatarios, asunto, mensaje.toString());
            
            // ✅ Marcar que ya se envió
            request.getSession().setAttribute("correoEnviado", true);
            request.getSession().setAttribute("errorMsg", "CITA CREADA CON ÉXITO!!!");
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
        return "Servlet para enviar correo con tabla reducida de vehículos";
    }
    
}
