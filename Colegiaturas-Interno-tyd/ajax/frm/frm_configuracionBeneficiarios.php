<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');

	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_SPECIAL_CHARS);

	$Factura =(isset($_POST['Factura']) ? $_POSTS['Factura'] : '0');
	$idu_escuela =(isset($_POST['idu_escuela']) ? $_POSTS['idu_escuela'] : '0');
	$rfc_escuela =(isset($_POST['rfc_escuela']) ? $_POSTS['rfc_escuela'] : '');
	$nom_escuela =(isset($_POST['nom_escuela']) ? $_POSTS['nom_escuela'] : '');	
?>
<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->			
<!--page specific plugin scripts-->
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/jquery-ui-1.10.3.full.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ui.jqgrid.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-responsive.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-skins.min.css" />

<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_configuracionBeneficiarios.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
	#dlg_AyudaEscuelas .modal-body {
		max-height: 500px;
		overflow-y: auto;
		padding: 15px;
		position: relative;
	}
</style>
<style type="text/css">
	.chosen-container-multi .chosen-choices{
		overflow-y: auto;
		height: 110px !important;
	}
	.modal-body{
		max-height: 500px;
		overflow-y: auto;
	}
	.modal-dialog{
		overflow-y: initial !important
	}
</style>

<div class="page-content">
	<div class="form-horizontal">		
		<div class="row-fluid">
			<div class="span8">
				
				<!-- Ocultos -->
				<div class="control-group">
					<input id="txt_idColaborador" type="hidden" style="text-align:left;" readonly />
					<input type="hidden" id="txt_Limitado" name="txt_Limitado" />
					<input type="hidden" id="txt_Bloqueado" name="txt_Bloqueado"/>
					<input type="hidden" id="txt_Empleado" name="txt_Empleado"/>					
					<input type="hidden" id="txt_Anio" name="txt_Anio" value="<?php echo date('Y'); ?>0101" />							
					<input type="hidden" id="txt_SueldoMensual" readonly />							
					<input type="hidden" id="txt_AcumFactPag" readonly />						
					<input type="hidden" id="txt_TopeProp" readonly />							
					<input type="hidden" id="txt_TopeRest" readonly />							
					<input type="hidden" id="txt_TopeMensual" readonly />	
					<input type="hidden" id="txt_NomEscuela" readonly />
					<input type="hidden" id="txt_idconfig" readonly />
					<input type="hidden" id="txt_clv_ben" readonly />
					<input type="hidden" id="txt_tipo_ben" readonly />
					
				</div>							
				
				<!-- Beneficiario 
				<div class="control-group">					
					<label class="control-label" >Beneficiario:</label>		
					<div class="controls">
						<select id="cbo_Beneficiario">
						</select>
					</div><br>								
				</div>-->
				
				<!-- Beneficiario -->
				<div class="row-fluid">					
					<div class="span7">
						<label class="control-label" for="cbo_Escuela" style=" margin-bottom:16px;" >Beneficiario:</label>
						<div class="controls" style="position: relative; ">
							<select id="cbo_Beneficiario" style="width:100%;" 
								<!--<option value='0'>SELECCIONE</option>-->
							</select>							
						</div>							
					</div>						
				</div>	
				<!-- XML -->
				<div class="control-group">
					<form id="xmlupload" name="xmlupload" action="ajax/json/json_leer_Rfc_XML.php" method="POST" enctype="multipart/form-data" style="margin-bottom:0px;">
						<div class="row-fluid">
							<div class="span9">
								
								<label class="control-label" for="fileXml" id="nom_xml" style="position: relative; top: 15px;" >XML:</label>
								<!--<span style="position: relative; top: -10px;"></span>-->
								<div class="controls" id="div_xml" style="position: relative; top: 15px;">
									<input type="hidden" id="session_name1" name="session_name1" value="" />
									<input type="hidden" id="hidden_MotivoAclaracion" name="hidden_MotivoAclaracion" value="" />
									<input type="hidden" id="txt_EditarFactura" name="txt_EditarFactura" value="<?php echo $Factura; ?>" />
									<input type="hidden" id="txt_EditarIduEscuela" name="txt_EditarIduEscuela" value="<?php echo $idu_escuela; ?>" />
									<input type="hidden" id="txt_EditarRfcEscuela" name="txt_EditarRfcEscuela" value="<?php echo $rfc_escuela; ?>" />
									<input type="hidden" id="txt_EditarNombreEscuela" name="txt_EditarNombreEscuela" value="<?php echo $nom_escuela; ?>" />
									<input type="hidden" id="txt_ifactura" name="txt_ifactura" value="" />
									<input type="hidden" id="txt_tipo_comprobante" name="txt_tipo_comprobante"/>
									<input type="hidden" id="txt_beneficiario_ext" name="txt_beneficiario_ext"/>
									<input type="hidden" id="txt_FechaFactura" name="txt_FechaFactura" value="" />
									<input type="hidden" id="txt_Rfc_fac" name="txt_Rfc_fac" value="<?php echo $rfc_escuela; ?>" />
									<input type="hidden" id="txt_Rfc_Emp" name="txt_Rfc_Emp" />	
									<input type="hidden" id="txt_iOpcion" name="txt_iOpcion" />
									<input type="file" id="fileXml" name="fileXml" tabindex="1" />
								</div>
							</div>
						</div>								
					</form>						
				</div>	
				<!-- RFC  for="txt_RFC"-->
				<div class="row-fluid">
					<div class="span6">
						<label class="control-label"  style=" margin-bottom:16px; top: -25px;">RFC:</label>
						<div class="controls">
							<input class="span12" id="txt_RFC" type="text" readonly />
						</div>						
					</div>
					<div class="span2">
						<div class="controls">
							<button class="btn btn-small btn-primary pull-center" id="btn_AgregarEscuela">Agregar</button>
						</div>						
					</div>
				</div>
				<!-- Escuela -->
				<div class="row-fluid">					
					<div class="span9">
						<label class="control-label" for="cbo_Escuela" style=" margin-bottom:16px;">Escuela:</label>
						<div class="controls">
							<select id="cbo_Escuela" style="width:100%;" tabindex="3">
								<option value='0'>SELECCIONE </option>
							</select>							
						</div>							
					</div>						
				</div>	
				<!-- Escolaridad -->
				<div class="row-fluid">
					<div class="span9">
						<label class="control-label" for="cbo_Escolaridad" style=" margin-bottom:16px;">Escolaridad:</label>
						<div class="controls">
							<select id="cbo_Escolaridad" style="width:100%;" tabindex="3">
								<option value='0'>SELECCIONE </option>
							</select>								
						</div>
					</div>
				</div>
				<!-- Carrera -->
				<div class="row-fluid">
					<div class="span9">
						<label class="control-label" for="cbo_Carrera" style=" margin-bottom:16px;">Carrera:</label>
						<div class="controls">
							<select id="cbo_Carrera" style="width:100%;" tabindex="3" class="chosen-select" data-placeholder="">
								<option value='0'>SELECCIONE </option>
							</select>								
						</div>
					</div>
				</div>
				<!-- Ciclo Escolar -->
				<div class="row-fluid">
					<div class="span9">
						<label class="control-label" for="cbo_CicloEscolar" style=" margin-bottom:16px;">Ciclo Escolar:</label>
						<div class="controls">
							<select id="cbo_CicloEscolar" style="width:100%;" tabindex="3">
								<!--option value='0'>SELECCIONE </option-->
							</select>
							<!--<input type="text" id="txt_escuela" name="txt_escuela" />-->
						</div>
					</div>					
				</div>
				<!-- Grado Escolar -->
				<div class="row-fluid">
					<div class="span9">
						<label class="control-label" for="cbo_Grado" style=" margin-bottom:16px;">Grado Escolar:</label>
						<div class="controls">
							<select id="cbo_Grado" style="width:100%;" tabindex="3">
								<option value='0'>SELECCIONE </option>
							</select>							
							<!--<input type="text" id="txt_escuela" name="txt_escuela" />-->
						</div>
					</div>
				</div>					
			</div>
		</div><br>
		
		<!-- CIERRE DIV 
		<div align="right">-->
		
		<div class="span12" id="cnt_botones" >
			<div class="span6">
			</div>
			<div class="span6">
				<button class="btn btn-small btn-primary pull-center" id="btn_Nuevo"><i class="icon-file bigger-110" ></i>Nuevo</button>&nbsp;&nbsp;&nbsp;
				<button class="btn btn-small btn-primary pull-center" id="btn_GuardarEstudio"><i class="icon-save bigger-110" ></i>Guardar</button><br><br>
			</div>
		</div>
		
		<!--
		<div class="row-fluid">
			<div class="span5">
				<div class="controls">
					<button class="btn btn-small btn-primary pull-center" id="btn_Nuevo"><i class="icon-file bigger-110" > Nuevo</i></button><br><br>					
				</div>				
			</div>
			<div class="span2">
				<div class="controls">					
					<button class="btn btn-small btn-primary pull-center" id="btn_GuardarEstudio"><i class="icon-save bigger-110" > Guardar</i></button><br><br>
				</div>
			</div>
		</div>
		-->
		
		<!-- Grid -->
		<div class="row-fluid">
			<div class="span12">
				<div class="control-group">
					
					<div id="contenedor_EstudiosBeneficiarios">
						<table id="gd_EstudiosBeneficiarios"></table>
						<div id="gd_EstudiosBeneficiarios_pager"></div>
					</div>
				</div>	
			</div>			
		</div>	
	<!-- CIERRE DIV FORM-->
	</div>		
</div>

<!-- MODAL AGREGAR ESCUELAS-->
<!--div id="dlg_AgregarEscuelas"  class="modal hide" style="width:800px; height:750px; position:fixed" data-backdrop="static"-->
<div id="dlg_AgregarEscuelas"  class="modal hide" tabindex="-1" style="width:35%; left:50%; vertical-align:middle" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">×</button>			
		<h4 class="black bigger"><i class="icon-home "></i>&nbsp; Agregar Escuelas</h4>
	</div>
	<br>
	<div class="modal-dialog modal-dialog-centered" role="document">
		<div class="modal-body">
			<div class="modal-content; form-horizontal">
				<div class="row-fluid">
					<div class="span12">		
						<div class="control-group">						
							<label class="control-label" >Estado:</label>								
							<div class="controls">						
								<select id="cbo_Estado_Agregar" class="chosen-select"  data-placeholder="SELECCIONE" tabindex="1001">
									<option value="0">SELECCIONE</option>
								</select>  
							</div>		
						</div>
						
						<div class="control-group">						
							<label class="control-label" >Municipio:</label>								
							<div class="controls">						
								<select id="cbo_Ciudad_Agregar" class="chosen-select"  data-placeholder="SELECCIONE" tabindex="1002">
									<option value="0">SELECCIONE</option>
								</select>  
							</div>	
						</div>

						<div class="control-group">						
							<label class="control-label" >Localidad:</label>								
							<div class="controls">						
								<select id="cbo_Localidad_Agregar" class="chosen-select"  data-placeholder="SELECCIONE" tabindex="1003">
									<option value="0">SELECCIONE</option>
								</select>  
							</div>	
						</div>

						<div class="control-group">						
							<label class="control-label" >Nombre Escuela:</label>								
							<div class="controls">
								<input id="txt_nombre_escuela" type="text" style="text-transform:uppercase" maxlength="90" tabindex="1004" />
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >RFC Escuela:</label>								
							<div class="controls">
								<input id="txt_rfc_escuela" type="text" style="text-transform:uppercase" maxlength="13" readonly tabindex="1005" />								
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >Razón Social:</label>								
							<div class="controls">
								<input id="txt_razon_social" type="text" style="text-transform:uppercase" maxlength="140" tabindex="1006" />								
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >Clave SEP:</label>								
							<div class="controls">
								<input id="txt_clave_sep" type="text" style="text-transform:uppercase"  maxlength="20" tabindex="1007" />								
							</div>
						</div>
						
						<div class="control-group">						
							<label class="control-label" >Escolaridad:</label>								
							<div class="controls">						
								<select id="cbo_Escolaridad_Agregar" class="chosen-select"  data-placeholder="SELECCIONE" tabindex="1008">
									<option value="0">SELECCIONE</option>
								</select>  
							</div>	
						</div>					

						<div class="control-group">						
							<label class="control-label" >Teléfono:</label>								
							<div class="controls">
								<input id="txt_telefono" class="numbersOnly" type="text" style="text-align:left;" maxlength="14" placeholder="(???) ???-????" tabindex="1009" />
								<span class="help-inline" id="hlp_telefono"></span>
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >Correo:</label>								
							<div class="controls">
								<input id="txt_email_contacto" type="text" style="text-transform:uppercase" maxlength="45" tabindex="1010" /> <!--style="text-align:left;"-->
								<span class="help-inline" id="hlp_correo"></span>
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >Contacto:</label>								
							<div class="controls">
								<input id="txt_contacto" type="text" style="text-transform:uppercase" maxlength="45" tabindex="1011" /> <!--style="text-align:left;"-->  
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >Área Contacto:</label>								
							<div class="controls">
								<input id="txt_area" type="text" style="text-transform:uppercase" maxlength="45" tabindex="1012" /> <!--style="text-align:left;"-->  
							</div>
						</div>

						<div class="control-group">						
							<label class="control-label" >Extensión Contacto:</label>								
							<div class="controls">
								<input id="txt_extension" type="text" style="text-transform:uppercase" class="numbersOnly" maxlength="10" tabindex="1013" /> <!--style="text-align:left;"-->  
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="modal-footer">
		<div class="span12" >
			<div class="span6">
				<!--<button class="btn btn-small btn-primary pull-rigth" id="btn_GuardarEscuela"><i class="icon-plus bigger-110"></i>Agregar</button>-->
			</div>			
			
			<div class="span4" align="right">
				<button class="btn btn-small btn-primary pull-rigth" id="btn_GuardarEscuela" tabindex="1013"><i class="icon-plus bigger-110"></i>Agregar</button>
			</div>				
		</div>
	</div>
</div>

<!-- MODAL AGREGAR ESCOLARIDAD-->
<div id="dlg_AgregarEscolaridad"  class="modal hide" style="width:520px; height:200px; position:fixed" data-keyboard="false" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">×</button>			
		<h4 class="black bigger"><i class="icon-home "></i>&nbsp; Agregar Escolaridad</h4>
	</div>
	<br>
	<table border="0" >
		<tr>
			<div class="form-horizontal">		
				<div class="row-fluid">
				
					<div class="span4">						
						<div class="control-group">						
							<label class="control-label" >Escolaridad:</label>								
							<div class="controls">						
								<div style="float: left">
									<span style="position: relative; top: 0px;"></span>
									<select id="cbo_Agrega_Escolaridad"  data-placeholder="SELECCIONE" tabindex="1"> <!--class="chosen-select" -->
										<option value="0">SELECCIONE</option>
									</select>  
								</div>						
							</div>								
						</div>
						
						<!-- Carrera 
						<div class="row-fluid">
							<div class="span9">
								<label class="control-label" for="cbo_Carrera" style=" margin-bottom:16px;">Carrera:</label>
								<div class="controls">
									<select id="cbo_Carrera" style="width:100%;" tabindex="3" class="chosen-select" data-placeholder="">
										<option value='0'>SELECCIONE </option>
									</select>								
								</div>
							</div>
						</div>
						-->	
						<!--
						<div class="control-group">						
							<label class="control-label" >Carrera:</label>								
							<div class="controls">						
								<div style="float: left">
									<span style="width:100%; position: relative; top: 0px;"></span>
									<select id="cbo_Agrega_Carrera"  data-placeholder="SELECCIONE" tabindex="2"> 
										<option value="0">SELECCIONE</option>
									</select>  
								</div>						
							</div>								
						</div>
						-->
					</div>
					
					
				</div>
			</div>
		</tr>			
	</table>
	
	<table border="0">			
		<div class="span12" >
			<div class="span6">
				<!--<button class="btn btn-small btn-primary pull-rigth" id="btn_GuardarEscuela"><i class="icon-plus bigger-110"></i>Agregar</button>-->
			</div>			
			
			<div class="span4" align="right">
				<button class="btn btn-small btn-primary pull-rigth" id="btn_GuardarEscolaridad"><i class="icon-plus bigger-110"></i>Agregar</button>
			</div>				
		</div>	
	</table>
</div>

