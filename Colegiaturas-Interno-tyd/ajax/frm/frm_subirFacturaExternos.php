<?php
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = 'Colegiaturas';

	$_POSTS = filter_input_array(INPUT_POST, FILTER_SANITIZE_SPECIAL_CHARS); //para gets y post
	
	$Factura =(isset($_POST['Factura']) ? $_POSTS['Factura'] : '0');
	$idu_escuela =(isset($_POST['idu_escuela']) ? $_POSTS['idu_escuela'] : '0');
	$rfc_escuela =(isset($_POST['rfc_escuela']) ? $_POSTS['rfc_escuela'] : '');
	$nom_escuela =(isset($_POST['nom_escuela']) ? $_POSTS['nom_escuela'] : '');
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$iEmpresa = isset($_SESSION[$Session]["USUARIO"]['num_empresa'])?$_SESSION[$Session]['USUARIO']['num_empresa']:'';
?>
<script type="text/javascript" src="files/js/utils.js"></script>
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/chosen.css" />
<!--	<script type="text/javascript" src="files/js/frm_subirFacturasElectronicaEscuelaPrivada.js"></script> -->
<script type="text/javascript" src="files/js/frm_subirFacturaExternos.js"></script> 
<script type="text/" src="files/js/utils.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
	
	.chosen-container.chosen-container-single {
		width: 219px !important;
	}
	
	#dlg_AgregarDetalle {
		overflow-x: hidden;
		overflow-y: hidden;
	}
	
	#dlg_AyudaEscuelas .modal-body {
		max-height: 500px;
		overflow-y: auto;
		padding: 15px;
		position: relative;
	}
</style>

<div class="page-content">

	<div class="form-horizontal">
		<br>
		<br>
		<div class="control-group">
		<input type="hidden" id="txt_Folio">
			<form id="xmlupload" name="xmlupload" action="ajax/json/json_leer_Rfc_XML.php" method="POST" enctype="multipart/form-data" style="margin-bottom:0px;">
				<div class="row-fluid">
					<div class="span9">
					<input type="hidden" id="txt_clvUso" name="txt_clvUso" value="" />
					<input type="hidden" id="txt_FolioRelacionado" name="txt_FolioRelacionado" value="" />
						<label class="control-label" for="fileXml" id="nom_xml"  >XML:</label>
						<div class="controls" id="div_xml">
							<input type="hidden" id="session_name1" name="session_name1" value="" />
							<input type="hidden" id="hidden_MotivoAclaracion" name="hidden_MotivoAclaracion" value="" />
							<input type="hidden" id="txt_EditarFactura" name="txt_EditarFactura" value="<?php echo $Factura; ?>" />
							<input type="hidden" id="txt_EditarIduEscuela" name="txt_EditarIduEscuela" value="<?php echo $idu_escuela; ?>" />
							<input type="hidden" id="txt_EditarRfcEscuela" name="txt_EditarRfcEscuela" value="<?php echo $rfc_escuela; ?>" />
							<input type="hidden" id="txt_EditarNombreEscuela" name="txt_EditarNombreEscuela" value="<?php echo $nom_escuela; ?>" />
							<input type="hidden" id="txt_ifactura" name="txt_ifactura" value="" />
							<input type="hidden" id="txt_tipo_comprobante" name="txt_tipo_comprobante"/>
							<input type="hidden" id="txt_beneficiario_ext" name="txt_beneficiario_ext"/>
							<input type="hidden" id="txt_tipoXml" name="txt_tipoXml" value="" />
							<input type="hidden" id="txt_FechaFactura" name="txt_FechaFactura" value="" />
							<input type="hidden" id="txt_Rfc_fac" name="txt_Rfc_fac" value="<?php echo $rfc_escuela; ?>" />
							<input type="hidden" id="txt_Rfc_Emp" name="txt_Rfc_Emp" />
							<input type="hidden" id="txt_externo" name="txt_externo" />
							
							<input type="file" id="fileXml" name="fileXml" tabindex="1" />
						</div>
					</div>
				</div>
				<div class="row-fluid">
					<div class="span9">
						<label class="control-label" for="filePdf" id="nom_pdf"  >PDF:</label>
						<div class="controls" id='div_pdf'>
							<input type="file" id="filePdf" name="filePdf" tabindex="2"/>
						</div>
					</div>
				</div>	
				<div class="control-group">	
					<label class="control-label">Beneficiario:</label>
					<div class="controls">
						<div style="float: left">
							<select id="cbo_Beneficiario" tabindex="3" style="width:500px">
							<option value="0">SELECCIONE</option>
							</select>
						</div>					
					</div>
				</div>
			
			</form>
<hr>			
			<div class="row-fluid">
				<div class="span5">
					<label class="control-label" for="txt_RFC" style=" margin-bottom:16px;">RFC:</label>
					<div class="controls">
						<input class="span12" id="txt_RFC" type="text" readonly />
					</div>
				</div>
			</div>
			
			<div class="row-fluid">
				<div class="span5">
					<label class="control-label" for="txt_ImporFact" style=" margin-bottom:16px;">Importe Factura:</label>
					<div class="controls">
						<input id="txt_ImporFact" type="text" style="text-align:right;" readonly />
					</div>
				</div>
			</div>
			
			<div class="row-fluid">
				<div class="span5">
					<input type="hidden" id="txt_Fecha" name="txt_Fecha"  value="<?php echo date('d/m/Y'); ?>">
					<label class="control-label" for="txt_FechaCap"  >Fecha Factura:</label>
					<div class="controls">
						<div class="row-fluid input-append">
							<input type="text" id="txt_FechaCap" class="input-small" readonly  />
							<span class="add-on">
								<i class="icon-calendar"></i>
							</span>
						</div>
					</div>
					
				</div>
			</div>
			
		</div>
		<hr>
		
		<!-- Secci�n Botones -->
		<div class="row-fluid">
			<div class="span12">
				<button class="btn btn-small btn-primary pull-right" id="btn_Guardar">
					<i class="icon-save bigger-110"></i>Guardar
				</button>				
				
			</div>
		</div>
		
	</div>
	<input type="hidden" id="hid_idu_usuario" name="hid_idu_usuario" value="<?php echo $iEmpleado;  ?>"/>
	<input type="hidden" id="hid_idu_empresa" name="hid_idu_empresa" value="<?php echo $iEmpresa;  ?>"/>
</div>