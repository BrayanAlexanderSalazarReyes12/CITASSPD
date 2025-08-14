<%-- 
    Document   : Mapa
    Created on : jul 28, 2025, 3:32:19 p.m.
    Author     : braya
--%>

<%@page import="org.json.JSONArray"%>
<%@page import="com.spd.CItasDB.ListaCitasBarcaza"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Mapa de Barcazas con Zona Gris</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            display: flex;
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            height: 100vh;
            overflow: hidden;
        }

        #panel-barcazas {
            flex: 0 0 250px;
            background: #ddd;
            padding: 10px;
            overflow-y: auto;
            border-right: 2px solid #aaa;
        }

        .barcaza {
            background: #1e90ff;
            color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            margin-bottom: 10px;
            border-radius: 5px;
            cursor: grab;
            padding: 5px;
        }

        .barcaza p {
            margin: 0;
            font-size: 12px;
        }

        #contenedor-muelle {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
            background: #87cefa;
        }

        #mapa {
            margin-top: 50px;
            display: grid;
            grid-template-columns: repeat(10, 100px);
            grid-template-rows: repeat(3, 60px); /* 6 filas */
            gap: 2px;
            padding: 10px;
            background: #87cefa;
        }

        .celda {
            background: rgba(255, 255, 255, 0.5);
            border: 1px dashed #aaa;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .celda.ocupada {
            background: rgba(200, 0, 0, 0.4) !important;
        }

        #zona-gris {
            flex-grow: 1;
            background: #ccc;
            border-top: 3px solid #888;
        }

        /* Tooltip */
        .tooltip {
            position: absolute;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            padding: 5px 10px;
            font-size: 12px;
            border-radius: 4px;
            pointer-events: none;
            display: none;
            z-index: 1000;
        }
    </style>
</head>
<body>

<div id="panel-barcazas"></div>

<div id="contenedor-muelle">
    <div id="mapa">
        <% for (int i = 0; i < 30; i++) { %>
            <div class="celda" data-pos="<%=i%>"></div>
        <% } %>
    </div>
    <div id="zona-gris"></div>
</div>

<div id="tooltip" class="tooltip"></div>

<%
    ListaCitasBarcaza.inicializarDesdeContexto(application);
    JSONArray barcaza = new JSONArray();
    try {
        barcaza = new ListaCitasBarcaza().filtroBarcaza();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>


<script>
    var barcazaslist = <%= barcaza.toString() %>; 
    
    const dataBarcazas = barcazaslist.map((item, index) => ({
        id: index + 1,
        nombre: item.BARCAZA,
        manga: item.MANGA,
        eslora: item.ESLORA,
        fechaCita: null,
        horaCita: null
    }));

    console.log(dataBarcazas);
    
    const panel = document.getElementById('panel-barcazas');
    const celdas = document.querySelectorAll('.celda');
    const tooltip = document.getElementById('tooltip');
    let barcazaArrastrada = null;
    let origenBarcaza = null;

    function cargarPanel() {
        panel.innerHTML = "";
        dataBarcazas.forEach(b => {
            if (!b.posicion) {
                const div = document.createElement('div');
                div.classList.add('barcaza');
                div.setAttribute('draggable', 'true');
                div.dataset.id = b.id;
                div.dataset.manga = b.manga;
                div.dataset.eslora = b.eslora;
                div.innerHTML =
                    '<p>' + b.nombre + '</p>' +
                    '<p>Manga: ' + b.manga + '</p>' +
                    '<p>Eslora: ' + b.eslora + '</p>';

                div.addEventListener('dragstart', () => {
                    barcazaArrastrada = div.cloneNode(true);
                    origenBarcaza = div;
                });

                panel.appendChild(div);
            }
        });
    }

    cargarPanel();

    celdas.forEach(celda => {
        celda.addEventListener('dragover', e => e.preventDefault());

        celda.addEventListener('drop', async e => {
            e.preventDefault();
            if (!barcazaArrastrada) return;

            let id = parseInt(barcazaArrastrada.dataset.id);
            let barcazaData = dataBarcazas.find(b => b.id === id);

            let celdasNecesarias = Math.ceil(barcazaData.eslora / 5);
            let posInicial = parseInt(celda.dataset.pos);

            if (posInicial + celdasNecesarias > celdas.length) {
                Swal.fire('Error', 'No hay espacio suficiente para esta eslora.', 'error');
                return;
            }

            for (let i = 0; i < celdasNecesarias; i++) {
                if (celdas[posInicial + i].dataset.ocupado === "true") {
                    Swal.fire('Error', 'Espacio ocupado en la posición ' + (posInicial + i), 'error');
                    return;
                }
            }

            // SweetAlert2 para ingresar fecha y hora
            const { value: formValues } = await Swal.fire({
                title: 'Asignar cita',
                html:
                    '<label>Fecha:</label>' +
                    '<input type="date" id="fecha" class="swal2-input">' +
                    '<br>'+
                    '<label>Hora:</label>' +
                    '<input type="time" id="hora" class="swal2-input">',
                focusConfirm: false,
                preConfirm: () => {
                    const fecha = document.getElementById('fecha').value;
                    const hora = document.getElementById('hora').value;
                    if (!fecha || !hora) {
                        Swal.showValidationMessage('Debe ingresar fecha y hora');
                        return false;
                    }
                    return { fecha, hora };
                }
            });

            if (!formValues) return;

            barcazaData.fechaCita = formValues.fecha;
            barcazaData.horaCita = formValues.hora;
            barcazaData.posicion = posInicial;

            for (let i = 0; i < celdasNecesarias; i++) {
                celdas[posInicial + i].dataset.ocupado = "true";
                celdas[posInicial + i].classList.add('ocupada');
            }

            barcazaArrastrada.style.width = (celdasNecesarias * 100 + (celdasNecesarias - 1) * 2) + "px";
            barcazaArrastrada.style.height = "50px";
            barcazaArrastrada.style.cursor = "default";

            // Tooltip
            barcazaArrastrada.addEventListener('mouseenter', () => {
                tooltip.innerHTML =
                    '<b>' + barcazaData.nombre + '</b><br>' +
                    'Manga: ' + barcazaData.manga + '<br>' +
                    'Eslora: ' + barcazaData.eslora + '<br>' +
                    'Fecha cita: ' + barcazaData.fechaCita + '<br>' +
                    'Hora cita: ' + barcazaData.horaCita;
                tooltip.style.display = 'block';
            });

            barcazaArrastrada.addEventListener('mouseleave', () => {
                tooltip.style.display = 'none';
            });

            celda.appendChild(barcazaArrastrada);

            if (origenBarcaza && origenBarcaza.parentNode) {
                origenBarcaza.remove();
            }

            barcazaArrastrada = null;
            origenBarcaza = null;
        });
    });

    document.addEventListener('mousemove', (e) => {
        tooltip.style.left = e.pageX + 10 + 'px';
        tooltip.style.top = e.pageY + 10 + 'px';
    });
</script>

</body>
</html>