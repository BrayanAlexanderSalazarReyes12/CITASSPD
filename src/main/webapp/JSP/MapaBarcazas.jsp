<%-- 
    Document   : Mapa
    Created on : jul 28, 2025, 3:32:19 p.m.
    Author     : braya
--%>

<%@page import="org.json.JSONArray"%>
<%@page import="com.spd.CItasDB.ListaCitasBarcaza"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        #mapa-barcazas {
            display: flex;
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            height: 100vh;
            overflow: hidden;
        }
        #panel-barcazas {
            flex: 0 0 115px;
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
            grid-template-rows: repeat(3, 60px);
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
        .celda.finalizada {
            background: red !important;
        }
        #zona-gris {
            flex-grow: 1;
            background: #ccc;
            border-top: 3px solid #888;
        }
        .finalizar-btn {
            background: #ff4d4d;
            border: none;
            color: white;
            padding: 3px 8px;
            margin-top: 3px;
            font-size: 11px;
            cursor: pointer;
            border-radius: 4px;
        }
    </style>
    

    <%
        Object rolObj = session.getAttribute("Rol");
        if (rolObj != null && ((Integer) rolObj) == 1) {
    %>
        <div id="mapa-barcazas" >

            <div id="panel-barcazas"></div>

            <div id="contenedor-muelle">
                <div id="mapa">
                    <% 
                        for (int i = 0; i < 30; i++) { 
                            int inicio = i * 5;
                            int fin = (i + 1) * 5;
                    %>
                        <div class="celda" data-pos="<%=i%>"><%= inicio %>-<%= fin %> m</div>
                    <% } %>
                </div>
                <div id="zona-gris"></div>
            </div>

        </div>
   <%
       }else {
   %> 
   
        <div id="mapa-barcazas" >

            <div id="contenedor-muelle">
                <div id="mapa">
                    <% 
                        for (int i = 0; i < 30; i++) { 
                            int inicio = i * 5;
                            int fin = (i + 1) * 5;
                    %>
                        <div class="celda" data-pos="<%=i%>"><%= inicio %>-<%= fin %> m</div>
                    <% } %>
                </div>
                <div id="zona-gris"></div>
            </div>

        </div>
    <%
        }
    %>
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
        horaCita: null,
        posicion: null
    }));

    const panel = document.getElementById('panel-barcazas');
    const celdas = document.querySelectorAll('.celda');
    let barcazaArrastrada = null;
    let origenBarcaza = null;

    function crearElementoBarcaza(b) {
        const div = document.createElement('div');
        div.classList.add('barcaza');
        div.setAttribute('draggable', 'true');
        div.dataset.id = b.id;
        div.dataset.manga = b.manga;
        div.dataset.eslora = b.eslora;
        div.innerHTML =
        '<p>' + b.nombre + '</p>' +
        '<p>Manga: ' + b.manga + '</p>' +
        '<p>Eslora: ' + b.eslora + '</p>' +
        (b.posicion !== null ? '<button class="finalizar-btn">Finalizar</button>' : '');


        div.addEventListener('dragstart', () => {
            barcazaArrastrada = div;
            origenBarcaza = div.parentElement;
        });

        const btnFinalizar = div.querySelector('.finalizar-btn');
        if (btnFinalizar) {
            btnFinalizar.addEventListener('click', async () => {
                const { value: zarpeValues } = await Swal.fire({
                    title: 'Finalizar operación',
                    html:
                        '<label>Fecha zarpe:</label>' +
                        '<input type="date" id="fechaZ" class="swal2-input">' +
                        '<br>' +
                        '<label>Hora zarpe:</label>' +
                        '<input type="time" id="horaZ" class="swal2-input">',
                    preConfirm: () => {
                        const fechaZ = document.getElementById('fechaZ').value;
                        const horaZ = document.getElementById('horaZ').value;
                        if (!fechaZ || !horaZ) {
                            Swal.showValidationMessage('Debe ingresar fecha y hora de zarpe');
                            return false;
                        }
                        return { fechaZ, horaZ };
                    }
                });

                if (zarpeValues) {
                    let posInicial = parseInt(div.parentElement.dataset.pos);
                    let celdasNecesarias = Math.ceil(b.manga / 5);
                    for (let i = 0; i < celdasNecesarias; i++) {
                        celdas[posInicial + i].classList.remove('ocupada');
                        celdas[posInicial + i].classList.add('finalizada');
                        delete celdas[posInicial + i].dataset.ocupado;
                    }
                    b.posicion = null;
                    div.remove();
                    Swal.fire('Finalizado', 'Operación cerrada con éxito', 'success');
                }
            });
        }
        return div;
    }

    function cargarPanel() {
        panel.innerHTML = "";
        dataBarcazas.forEach(b => {
            panel.appendChild(crearElementoBarcaza(b));
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
        let celdasNecesarias = Math.ceil(barcazaData.manga / 5);
        let posInicial = parseInt(celda.dataset.pos);

        if (posInicial + celdasNecesarias > celdas.length) {
            Swal.fire('Error', 'No hay espacio suficiente para esta manga.', 'error');
            return;
        }
        for (let i = 0; i < celdasNecesarias; i++) {
            if (celdas[posInicial + i].dataset.ocupado === "true" && origenBarcaza !== celdas[posInicial + i]) {
                Swal.fire('Error', 'Espacio ocupado en la posición ' + (posInicial + i), 'error');
                return;
            }
        }

        
        // 🔹 LIMPIAR CELDAS ANTERIORES (QUITAR RASTRO Y DEVOLVER NÚMEROS)
        if (barcazaData.posicion !== null) {
            let posAnterior = barcazaData.posicion;
            let celdasAnterior = Math.ceil(barcazaData.manga / 5);
            for (let i = 0; i < celdasAnterior; i++) {
                delete celdas[posAnterior + i].dataset.ocupado;
                celdas[posAnterior + i].classList.remove('ocupada');

                // Restaurar el texto original según el índice de la celda
                let numInicio = (posAnterior + i) * 5;
                let numFin = (posAnterior + i + 1) * 5;
                celdas[posAnterior + i].innerHTML = numInicio+"-"+numFin+"m";
            }
        }


        if (barcazaData.posicion === null) {
            const { value: formValues } = await Swal.fire({
                title: 'Asignar cita',
                html:
                    '<label>Fecha:</label>' +
                    '<input type="date" id="fecha" class="swal2-input">' +
                    '<br>' +
                    '<label>Hora:</label>' +
                    '<input type="time" id="hora" class="swal2-input">',
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
        }

        barcazaData.posicion = posInicial;
        for (let i = 0; i < celdasNecesarias; i++) {
            celdas[posInicial + i].dataset.ocupado = "true";
            celdas[posInicial + i].classList.add('ocupada');
            celdas[posInicial + i].innerHTML = ""; // Limpiar antes de poner nueva barcaza
        }

        celda.appendChild(crearElementoBarcaza(barcazaData));

        barcazaArrastrada = null;
        origenBarcaza = null;
        cargarPanel();
    });

    });
</script>
