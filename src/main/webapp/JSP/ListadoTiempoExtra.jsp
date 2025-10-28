<%-- 
    Document   : ListadoTiempoExtra
    Created on : 22/10/2025, 08:58:07 AM
    Author     : Brayan Salazar
--%>

<%@page import="com.spd.TiempoExtra.TiempoExtra"%>
<%@page import="com.spd.TiempoExtra.TiempoExtraDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>

<%
    TiempoExtraDAO dao = new TiempoExtraDAO();
    List<TiempoExtra> lista = null;
    try {
        TiempoExtraDAO.inicializarDesdeContexto(application);
        lista = dao.ListaTiempoExtra();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<script>
    function closeModal() {
        document.getElementById("deleteModal").style.display = "none";
    }
    
    function navegarInternamente(url) {
        sessionStorage.setItem("navegandoInternamente", "true");
        window.location.href = url;
    }
    
    document.addEventListener("DOMContentLoaded", function () {
        sessionStorage.setItem("ventanaActiva", "true");
    });

    window.addEventListener("beforeunload", function (e) {
        const navEntry = performance.getEntriesByType("navigation")[0];
        if (navEntry && navEntry.type === "navigate") return;
        if (navEntry && navEntry.type === "reload") return;

        if (sessionStorage.getItem("navegandoInternamente") === "true") {
            sessionStorage.setItem("navegandoInternamente", "false");
            return;
        }

        if (sessionStorage.getItem("ventanaActiva") === "true") {
            sessionStorage.removeItem("ventanaActiva");
            sessionStorage.removeItem("navegandoInternamente");
            navigator.sendBeacon("../cerrarVentana", "");
        }
    });
</script>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta http-equiv="refresh" content="120">
        <title>Listados Tiempo Extra</title>
        <link rel="stylesheet" href="../CSS/Listado_Citas.css"/>
        <link rel="stylesheet" href="../CSS/Login.css"/>
        
        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        
        <link rel="stylesheet" href="https://cdn.datatables.net/2.3.2/css/dataTables.dataTables.css" />
  
        <script src="https://cdn.datatables.net/2.3.2/js/dataTables.js"></script>
        
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        
        <script>
            $(document).ready(function () {
                ['#myTable'].forEach(function (id) {
                    $(id).DataTable({
                        scrollY: 400,
                        pageLength: 50, // ← Aquí se especifica mostrar 20 registros por página
                        language: { url: "https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json" }
                    });
                });
            });
        </script>
    </head>
    <% Object rolObj = session.getAttribute("Rol"); %>
    <jsp:include page= "Hearder.jsp"/>
    
    <body>
        <h1>Listado de Tiempo Extra</h1>

        <<style>
/* === Tarjeta contenedora === */
.table-card {
  width: 95%;
  max-width: 1200px;
  margin: 40px auto;
  background: #ffffff;
  border-radius: 16px;
  box-shadow: 0 4px 25px rgba(0,0,0,0.1);
  padding: 25px;
  overflow-x: auto; /* ✅ Permite ver toda la tabla en pantallas pequeñas */
  transition: all 0.3s ease;
}

.table-card:hover {
  box-shadow: 0 6px 30px rgba(0,0,0,0.15);
}

/* === Título === */
.table-card h2 {
  font-family: "Segoe UI", sans-serif;
  font-weight: 600;
  color: #1a1a1a;
  margin-bottom: 20px;
  text-align: center;
  font-size: 20px;
}

/* === Tabla === */
#myTable {
  width: 100%;
  border-collapse: collapse;
  font-family: "Segoe UI", sans-serif;
  font-size: 14px;
  border-radius: 10px;
  overflow: hidden;
}

#myTable thead {
  background-color: #0056b3;
  color: #fff;
}

#myTable th, #myTable td {
  padding: 12px 16px;
  text-align: center;
  border-bottom: 1px solid #e5e5e5;
}

#myTable th {
  font-weight: 600;
}

#myTable tbody tr:nth-child(even) {
  background-color: #f9f9f9;
}

#myTable tbody tr:hover {
  background-color: #f1f6ff;
  transition: background-color 0.3s ease;
}

/* === Botón de aprobar === */
.btn-aprobar {
  background-color: #28a745;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-aprobar:hover {
  background-color: #218838;
  transform: scale(1.05);
}

.btn-aprobar:active {
  background-color: #1e7e34;
  transform: scale(0.98);
}

/* === Responsive === */
@media (max-width: 768px) {
  .table-card {
    padding: 15px;
  }
  #myTable {
    font-size: 13px;
  }
  #myTable th, #myTable td {
    padding: 10px 12px;
  }
}
</style>

    <div class="table-card">

      <table id="myTable">
        <thead>
          <tr>
            <th>NIT Empresa</th>
            <th>Fecha Solicitud</th>
            <th>Fecha Servicio</th>
            <th>Tipo Operación</th>
            <th>Operación</th>
            <th>Observación</th>
            <th>Estado</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
            <%
                // Obtener las cookies del request
                Cookie[] cookies = request.getCookies();
                String usuario = "";

                if (cookies != null) {
                    for (Cookie c : cookies) {
                        if ("USUARIO".equals(c.getName())) {
                            usuario = c.getValue();
                            break;
                        }
                    }
                }
            %>
          <%
            if (lista != null && !lista.isEmpty()) {
              for (TiempoExtra t : lista) {
          %>
          <tr data-nit="<%= t.getNIT_EMPRESA()%>">
            <td class="compania"><span class="loading">Cargando...</span></td>
            <td><%= t.getFECHA_SOLICITUD()%></td>
            <td><%= t.getFECHA_SERVICIO()%></td>
            <td>
                <%
                  // Obtener el tipo de operación
                  String tipo = t.getTIPO_OPERACION();

                  // Separar texto por mayúsculas o palabras unidas
                  if (tipo != null) {
                      tipo = tipo.replaceAll("([a-z])([A-Z])", "$1 $2"); // agrega espacio antes de mayúsculas
                      tipo = tipo.replaceAll("(?i)aprobacion", " y Aprobación"); // corrige acento si es necesario
                      tipo = tipo.replaceAll("(?i)tiempo", "Tiempo");
                      tipo = tipo.replaceAll("(?i)extraordinario", "Extraordinario");
                      tipo = tipo.replaceAll("(?i)doc", "Documentacion");
                  } else {
                      tipo = "Sin tipo";
                  }
                %>
                <%= tipo %>
            </td>

            <td><%= t.getOPERACION()%></td>
            <td><%= t.getOBSERVACION()%></td>
            <td><%= t.getESTADO() %></td>
            <%
                if (!"Aprobado".equals(t.getESTADO())) {
            %>
                <td>
                    <form action="../AprobarTiempoExtraServlet" method="post" style="display:inline;">
                        <input type="hidden" name="nitEmpresa" value="<%= t.getNIT_EMPRESA() %>"/>
                        <input type="hidden" name="usulogin" value="<%= usuario %>"/>
                        <button type="submit" class="btn-aprobar">Aprobar</button>
                    </form>
                </td>
            <%
                }else {
            %>
                  <td></td>
            <%
                }
            %>
          </tr>
          <%
              }
            }
          %>
        </tbody>
      </table>
    </div>

    <!-- ✅ Script para cargar nombres de compañías -->
    <script>
        async function cargarCompanias() {
          const filas = document.querySelectorAll("#myTable tbody tr");
          let cacheClientes = JSON.parse(localStorage.getItem("cacheClientes")) || {};
          let nuevosConsultados = 0;

          for (const fila of filas) {
            const nit = fila.dataset.nit?.trim();
            const celdaCompania = fila.querySelector(".compania");

            if (!nit) {
              celdaCompania.textContent = "Sin NIT";
              continue;
            }

            if (cacheClientes[nit]) {
              celdaCompania.textContent = cacheClientes[nit];
              continue;
            }

            try {
              const response = await fetch('../ObtenerCLientes?nit=' + encodeURIComponent(nit));
              if (!response.ok) throw new Error("Error HTTP " + response.status);
              const data = await response.json();
              let nombreEmpresa = "No encontrado";
              if (data && data.length > 0) nombreEmpresa = data[0].Nombre || "Sin nombre";
              celdaCompania.textContent = nombreEmpresa;
              cacheClientes[nit] = nombreEmpresa;
              localStorage.setItem("cacheClientes", JSON.stringify(cacheClientes));
              nuevosConsultados++;
            } catch (error) {
              console.error("❌ Error al obtener cliente:", error);
              celdaCompania.textContent = "Error";
            }
          }

          if (nuevosConsultados > 0)
            console.log(`🔄 ${nuevosConsultados} nuevos NIT(s) guardados en caché.`);
          else
            console.log("✅ Caché actualizado. Ningún NIT nuevo consultado.");
        }

        document.addEventListener("DOMContentLoaded", cargarCompanias);
    </script>

    </body>
</html>
