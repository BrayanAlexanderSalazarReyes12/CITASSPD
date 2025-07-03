/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Utilidades;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import javax.servlet.ServletContext;
import org.json.JSONObject;

/**
 *
 * @author braya
 */
public class Utilidades {
   public static JSONObject jsonEnv;
   public static String RIEN;
   public static String TERMINALPORTUARIANIT;
   public static String SISTEMAENTURNAMIENTOID;
   public static String USUARIOMINTRASPOR;
   public static String CONTRAMINTRASPOR;
   public static String TOKEN;
   
    public static void variables_entornos_json (ServletContext context) throws IOException {
        //variables de entorno
        String path = context.getRealPath("/WEB-INF/json.env");
        String content = new String(Files.readAllBytes(Paths.get(path)));
        jsonEnv = new JSONObject(content); // Parsea el JSON
        //System.out.println(jsonEnv);
        RIEN = jsonEnv.optString("RIEN");
        TERMINALPORTUARIANIT = jsonEnv.optString("TERMINALPORTUARIANIT");
        SISTEMAENTURNAMIENTOID = jsonEnv.optString("SISTEMAENTURNAMIENTOID");
        USUARIOMINTRASPOR = jsonEnv.optString("USUARIOMINTRASPOR");
        CONTRAMINTRASPOR = jsonEnv.optString("CONTRAMINTRASPOR");
        TOKEN = jsonEnv.getString("TOKEN");
    }
}
