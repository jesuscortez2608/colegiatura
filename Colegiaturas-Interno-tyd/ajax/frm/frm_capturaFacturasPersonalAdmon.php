<?php
   header('X-Frame-Options: SAMEORIGIN');
   header("Content-type:text/html;charset=utf-8;");
   header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_capturaFacturasPersonalAdmon.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }	
	
	.chosen-container.chosen-container-single {
		width: 219px !important;
	}
	
	div.itemdiv.dialogdiv::before {
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		background-color: #ffffff;
		border-color: #ffffff;
		border-image: none;
		border-style: none;
		border-width: 0 0px;
		bottom: 0;
		content: "";
		display: none;
		left: 19px;
		max-width: 1px;
		position: absolute;
		top: 0;
		width: 1px;
	}
	
	.itemdiv.dialogdiv > .body {
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		border-color: #dde4ed;
		border-image: none;
		border-style: solid;
		border-width: 1px 1px 1px 2px;
		margin-right: 1px;
		padding: 3px 7px 7px;
		left: -40px;
		width: 95%;
	}
</style>


<div class="page-content">
	<div class="row-fluid">
		<div class="form-horizontal">
<!-- DATOS COLABORADOR -->
			<div class="span12;page-header position-relative" style="background-color:#307ECC;color:#FFFFFF">
				<h4>Datos del Colaborador</h4>
			</div>
			<div class="span12 form-horizontal">
				<div class="span8">
					<div class="control-group">	
					<br>
						<label class="control-label" for="form-input-readonly">Colaborador:</label>			
						<div class="controls">	
							 <form class="form-search">
								<input type="text" class="span3 numbersOnly" id="txt_NumEmp"  maxlength="10">
								<input class="span6"   type="text" id="txt_NomEmp" readonly >
							</form> 
						</div>
						
						<label class="control-label" for="form-input-readonly">Centro:</label>
						<div class="controls">
							<form class="form-search">
								<input type="text" class="span3" id="txt_Centro"  readonly >      
								<input type="text" class="span6" id="txt_NombreCentro" readonly>
							</form> 
						</div>
						
						<div class="control-group row-fluid">	
							<label class="control-label" for="form-input-readonly">Fecha Ingreso:</label>
							<div class="controls">	   
								<input type="text" class="span3" id="txt_fechaIngreso" readonly>
							</div>											
						</div>
					</div>
				</div>
			</div>
<!-- SUELDO -->			
			<div class="span12">
				<div class="span4">
					<div class="control-group row-fluid">	
						<label class="control-label" for="form-input-readonly">Sueldo Mensual:</label>
						<div class="controls">	   
							<input type="text" class="span12" id="txt_SueldoMensual" readonly>
						</div><br>
						<label class="control-label" for="form-input-readonly">Acum. Facturas Pagadas:</label>
						 <div class="controls">
							<input type="text" class="span12" id="txt_AcumFactPagadas" readonly>
						 </div>
						
					</div>	
				</div>
				<div class="span4">
					<div class="control-group">	
						<label class="control-label" for="form-input-readonly">Tope Anual:</label>
						<div class="controls">	
							<input type="text" class="span12" id="txt_TopeAnual" readonly >  <!-- style="text-align:right;" -->
						</div><br>
						<label class="control-label" for="form-input-readonly">Tope Proporcional Restante:</label>
						 <div class="controls">
							<input type="text" class="span12" id="txt_TopePropRestante" readonly>
						 </div>
					</div>	
				</div>				
				<div class="span4">
					<div class="control-group">	
						<label class="control-label" for="form-input-readonly">Tope Mensual:</label>
						 <div class="controls">
							<input type="text" class="span10" id="txt_TopeMensual" readonly >
						 </div><br>
						<label class="control-label" for="form-input-readonly">Ruta de Pago:</label>
						 <div class="controls">
							<input type="text" class="span10" id="txt_RutaPago" readonly style="text-align:right;">
						 </div>
					</div>	
				</div>
			</div>
		</div>
	</div>
<!-- FACTURA -->
	<div class="row-fluid">
		<div class="span12 form-horizontal">
			<div class="span12;page-header position-relative" style="background-color:#307ECC;color:#FFFFFF">
			<h4>Factura</h4>
			</div>
			<div class="span12 form-horizontal">	
				<div class="span4">
					<div class="control-group">
					<br>
						<form id="xmlupload" name="xmlupload" action="ajax/json/json_leer_Rfc_XML.php" method="POST" enctype="multipart/form-data" style="margin-bottom:0px;">
							<input type="hidden" id="txt_FechaFactura" name="txt_FechaFactura" value="" />
							<input type="hidden" id="txt_Rfc_fac" name="txt_Rfc_fac" value="<?php echo $rfc_escuela; ?>" />
							<input type="hidden" id="txt_idu_empleado" name="txt_idu_empleado" value="" />
							<input type="hidden" id="txt_Empresa" name="txt_Empresa" value="" /> <!-- Utilizar en caso que se pida que se guarde el numero de empresa del empleado-->
							<input type="hidden" id="txt_idu_Centro" name="txt_idu_Centro" value="" />
							<input type="hidden" id="txt_ifactura" name="txt_ifactura" value="" />
							<input type="hidden" id="hidden_MotivoAclaracion" name="hidden_MotivoAclaracion" value="" />
							
							
							<label class="control-label" for="filePdf" id="nom_pdf" >PDF:</label>
							<div class="controls" id='div_pdf'>
								<input type="file" id="filePdf" name="filePdf" tabindex="2"/>
							</div><br>
							<input type="hidden" id="txt_filePdf" name="txt_filePdf"/>
						</form>
						<label class="control-label" for="form-input-readonly" >Folio Factura:</label>
						<div class="controls">
							<input type="text" class="span12" id="txt_FolioFactura" style="text-transform:uppercase;"> 
						</div><br>
						<label class="control-label"  for="form-input-readonly">Importe:</label>
						<div class="controls">	
							<input type="text" class="span12"  id="txt_Importe" >  <!-- se quita la clase 'numbersOnly' -->
							<!-- class="span12" -->
						</div><br>
						<!--
						<label class="control-label" for="txt_Fecha">Fecha:</label>
						<div class="controls">
							<div class="row-fluid input-append">
								<input type="text" id="txt_Fecha" class="input-small"/>
								<span class="add-on">
									<i class="icon-calendar"></i>
								</span>
							</div>
						</div>-->
						<label class="control-label" for="txt_Fecha">Fecha Factura:</label>
						<div class="controls">
							<div class="row-fluid input-append">
								<input type="text" id="txt_Fecha" class="input-small" readonly />
								<span class="add-on">
									<i class="icon-calendar"></i>
								</span>
							</div>
						</div><br>
					</div>
				</div>
			</div>				
		</div>
	</div>
<!-- BECADO Y ESTUDIOS -->	
	<div class="row-fluid">
		<div class="span12 form-horizontal">
			<div class="span12;page-header position-relative" style="background-color:#307ECC;color:#FFFFFF">
			<h4>Becado y Estudios</h4>
			</div>
			<div class="span12 form-horizontal">	
				<div class="span4">
				<br>
					<label class="control-label">Beneficiario:</label>
					<div class="controls">
						<select id="cbo_Beneficiario">
						</select>
					</div><br>
					<label class="control-label">Parentesco:</label>
					<!--<div class="controls">
						<input type="text" class="span12" id="txt_parentesco" readonly style="text-align:right;"> 
					</div><br>-->
					<div class="controls">
						<select id="cbo_Parentesco">
						</select>
					</div><br>
					<label class="control-label">Tipo Periodo Pago:</label>
					<div class="controls">
						<select id="cbo_TipoPago">
						</select>
					</div><br>
					<label class="control-label">Periodo:</label>
					<div class="controls">
						<select id="cbo_Periodo"  multiple style="width:100%" data-placeholder="SELECCIONE">
						</select>
					</div>
				</div>
				<div class="span6">
				<br>
					<label class="control-label">Escuela:</label>
					<div class="controls">
						<select id="cbo_escuelaLinea">
						</select>
						<input type="hidden" class="span12" id="txt_RFC" readonly style="text-align:right;"> 
					</div><br>
					<label class="control-label">Escolaridad:</label>
					<div class="controls">
						<select id="cbo_Escolaridad">
						</select>
					</div><br>
					<label class="control-label">Grado Escolar:</label>
					<div class="controls">
						<select id="cbo_Grado">
						</select>
					</div><br>
					<label class="control-label">Ciclo Escolar:</label>
					<div class="controls">
						<select id="cbo_CicloEscolar">
						</select>
					</div>
					<br>
				</div>
			</div>
<!-- BOTON GUARDAR -->
		<div class="span12 form-horizontal">
			<div class="span7 form-horizontal">
				
			</div>
			<div class="span5 form-horizontal">
				<button id="btn_guardar" class="btn btn-primary btn-small" ><i class="icon-save bigger-110"></i> Guardar</button>
				<!--<button id="btn_Prueba" class="btn btn-primary btn-small" ><i class="icon-File bigger-110"></i> Prueba</button>-->
			</div>
		</div>
	</div> 
</div> 
