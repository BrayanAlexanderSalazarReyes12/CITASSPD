<%-- 
    Document   : Modal
    Created on : 03-abr-2025, 14:22:03
    Author     : braya
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<script>
    function openModal(contratoId) {
        document.getElementById("contratoId").value = contratoId;
        document.getElementById("deleteModal").style.display = "flex";
    }
    function closeModal() {
        document.getElementById("deleteModal").style.display = "none";
        
    }
</script>

<!DOCTYPE html>
<html>
    <link rel="stylesheet" href="../CSS/Styles_modal.css"/>
    <div id="deleteModal" class="modal" style="display: flex;">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Error</h2>
            <p>Usuario o Contraseña Incorectos</p>
            <div class="modal-actions">
                <form action="../EliminarContrato" method="post">
                    <input type="hidden" name="contratoId" id="contratoId">
                    <button type="button" onclick="closeModal()" class="cancel-btn">Cerrar</button>
                </form>
            </div>
        </div>
    </div>
</html>
