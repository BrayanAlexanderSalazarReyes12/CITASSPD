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
    .barcaza p { margin: 0; font-size: 12px; }
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
    .celda.ocupada { background: rgba(200, 0, 0, 0.4) !important; }
    .celda.finalizada { background: red !important; }
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
    boolean esAdmin = rolObj != null && ((Integer) rolObj) == 1;

    ListaCitasBarcaza.inicializarDesdeContexto(application);
    JSONArray barcaza = new JSONArray();
    try {
        barcaza = new ListaCitasBarcaza().filtroBarcaza();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<div id="mapa-barcazas">
    <!-- Siempre existe el panel, pero solo visible si es admin -->
    <div id="panel-barcazas" style="<%= esAdmin ? "" : "display:none;" %>"></div>

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

<script>
    var barcazaslist = <%= barcaza.toString() %>;
    var esAdmin = <%= esAdmin ? "true" : "false" %>;

    let dataBarcazas = [];
    const panel = document.getElementById('panel-barcazas');
    const celdas = document.querySelectorAll('.celda');
    let barcazaArrastrada = null;
    let origenBarcaza = null;

    // Cargar citas desde el servlet y construir dataBarcazas
    fetch("../GuardarCitaBarcazaServlet", { method: "GET" })
        .then(res => {
            if (!res.ok) throw new Error(`Error HTTP: ${res.status}`);
            return res.json();
        })
        .then(citas => {
            dataBarcazas = barcazaslist.map((item, index) => {
                const citaData = citas.find(c =>
                    c.barcaza?.toLowerCase?.().trim() === item.BARCAZA?.toLowerCase?.().trim() &&
                    c.estado?.toLowerCase?.().trim() !== "finalizado"
                );

                // --- CORRECCIÓN: manejo correcto de inicio = 0 ---
                let posicion = null;
                if (citaData && citaData.posicion && (citaData.posicion.inicio !== undefined && citaData.posicion.inicio !== null)) {
                    const inicioNum = Number(citaData.posicion.inicio);
                    if (!Number.isNaN(inicioNum)) {
                        posicion = inicioNum / 5; // ahora inicio=0 => posicion = 0
                    }
                }

                return {
                    id: index + 1,
                    nombre: item.BARCAZA,
                    manga: Number(item.MANGA),
                    eslora: Number(item.ESLORA),
                    // tu JSON usa "citaArribo" en los ejemplos; lo cubrimos
                    fechaCita: citaData?.citaArribo?.fecha || citaData?.cita?.fecha || null,
                    horaCita: citaData?.citaArribo?.hora || citaData?.cita?.hora || null,
                    posicion
                };
            });

            cargarPanel();
        })
        .catch(err => console.error("❌ Error al cargar las citas:", err));


    function crearElementoBarcaza(b) {
        const div = document.createElement('div');
        div.classList.add('barcaza');
        if (esAdmin) div.setAttribute('draggable', 'true');
        div.dataset.id = b.id;
        div.dataset.manga = b.manga;
        div.dataset.eslora = b.eslora;
        div.innerHTML =
            '<p>' + b.nombre + '</p>' +
            '<p>Manga: ' + b.manga + '</p>' +
            '<p>Eslora: ' + b.eslora + '</p>' +
            (b.posicion !== null && esAdmin ? '<button class="finalizar-btn">Finalizar</button>' : '');

        if (esAdmin) {
            // Drag & Drop
            div.addEventListener('dragstart', () => {
                barcazaArrastrada = div;
                origenBarcaza = div.parentElement;
            });

            // 🔹 Botón Finalizar
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
                        let posInicial = parseInt(div.parentElement.dataset.pos, 10);
                        let celdasNecesarias = Math.ceil(b.manga / 5);

                        // Liberar celdas y marcarlas como finalizadas
                        for (let i = 0; i < celdasNecesarias; i++) {
                            celdas[posInicial + i].classList.remove('ocupada');
                            celdas[posInicial + i].classList.add('finalizada');
                            delete celdas[posInicial + i].dataset.ocupado;
                            let numInicio = (posInicial + i) * 5;
                            let numFin = (posInicial + i + 1) * 5;
                            celdas[posInicial + i].innerHTML = numInicio + "-" + numFin + "m";
                        }

                        // Reset posición en el objeto barcaza
                        b.posicion = null;
                        div.remove();

                        // JSON para guardar finalización
                        
                        const jsonCita = {
                            id: b.id,
                            citaZarpe: {
                                fecha: zarpeValues.fechaZ,
                                hora: zarpeValues.horaZ
                            },
                            estado: "Finalizado"
                        };
                        
                        console.log(jsonCita)
                        
                        fetch("../GuardarCitaBarcazaServlet", {
                            method: "PUT",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify(jsonCita)
                        })
                            .then(res => res.json())
                            .then(resp => {
                                Swal.fire("✅ Guardado", resp.message, "success");
                            })
                            .catch(err => {
                                Swal.fire("❌ Error", "No se pudo guardar la cita", "error");
                                console.error(err);
                            });
                    }
                });
            }
        }

        return div;
    }


    function cargarPanel() {
        if (panel) panel.innerHTML = "";
        if (!celdas || celdas.length === 0) return;

        dataBarcazas.forEach(b => {
            // NOTA: usamos "b.posicion !== null && b.posicion !== undefined" para aceptar 0
            if (b.posicion !== null && b.posicion !== undefined) {
                const pos = parseInt(b.posicion, 10);
                const celdasNecesarias = Math.ceil(Number(b.manga) / 5);

                for (let i = 0; i < celdasNecesarias; i++) {
                    const idx = pos + i;
                    if (!celdas[idx]) continue; // protección si se pasa del total de celdas
                    celdas[idx].dataset.ocupado = "true";
                    celdas[idx].classList.add('ocupada');
                    celdas[idx].innerHTML = "";
                }
                if (celdas[pos]) celdas[pos].appendChild(crearElementoBarcaza(b));
            } else if (esAdmin && panel) {
                panel.appendChild(crearElementoBarcaza(b));
            }
        });
    }

    // Drag & drop — solo para admins
    if (esAdmin) {
        celdas.forEach(celda => {
            celda.addEventListener('dragover', e => e.preventDefault());

            celda.addEventListener('drop', async e => {
                e.preventDefault();
                if (!barcazaArrastrada) return;

                let id = parseInt(barcazaArrastrada.dataset.id, 10);
                let barcazaData = dataBarcazas.find(b => b.id === id);
                let celdasNecesarias = Math.ceil(Number(barcazaData.manga) / 5);
                let posInicial = parseInt(celda.dataset.pos, 10);

                // validaciones de espacio
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

                // liberar celdas anteriores si tenía posición
                if (barcazaData.posicion !== null && barcazaData.posicion !== undefined) {
                    let posAnterior = parseInt(barcazaData.posicion, 10);
                    let celdasAnterior = Math.ceil(Number(barcazaData.manga) / 5);
                    for (let i = 0; i < celdasAnterior; i++) {
                        const idx = posAnterior + i;
                        if (!celdas[idx]) continue;
                        delete celdas[idx].dataset.ocupado;
                        celdas[idx].classList.remove('ocupada');
                        let numInicio = (idx) * 5;
                        let numFin = (idx + 1) * 5;
                        celdas[idx].innerHTML = numInicio + "-" + numFin + " m";
                    }
                }

                // Si no tenía cita: pedir fecha/hora y POST
                if (barcazaData.posicion === null || barcazaData.posicion === undefined) {
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

                    const jsonCita = {
                        id: barcazaData.id,
                        barcaza: barcazaData.nombre,
                        manga: barcazaData.manga,
                        eslora: barcazaData.eslora,
                        citaArribo: {
                            fecha: barcazaData.fechaCita,
                            hora: barcazaData.horaCita
                        },
                        citaZarpe:{
                        },
                        posicion: {
                            inicio: posInicial * 5,
                            fin: (posInicial + celdasNecesarias) * 5
                        },
                        estado: "Programada"
                    };

                    fetch("../GuardarCitaBarcazaServlet", {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify(jsonCita)
                    })
                        .then(res => res.json())
                        .then(resp => Swal.fire("✅ Guardado", resp.message, "success"))
                        .catch(err => {
                            Swal.fire("❌ Error", "No se pudo guardar la cita", "error");
                            console.error(err);
                        });
                }

                // marcar nuevas celdas ocupadas
                barcazaData.posicion = posInicial;
                for (let i = 0; i < celdasNecesarias; i++) {
                    const idx = posInicial + i;
                    if (!celdas[idx]) continue;
                    celdas[idx].dataset.ocupado = "true";
                    celdas[idx].classList.add('ocupada');
                    celdas[idx].innerHTML = "";
                }

                celdas[posInicial].appendChild(crearElementoBarcaza(barcazaData));

                barcazaArrastrada = null;
                origenBarcaza = null;
                cargarPanel();
            });
        });
    }
</script>