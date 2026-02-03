<?php
     header('X-Frame-Options: SAMEORIGIN');
	 header("Content-type:text/html;charset=utf-8;");
	 header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	$_POSTS = filter_input_array(INPUT_POST, FILTER_SANITIZE_NUMBER_INT);
	$_POSTSt = filter_input_array(INPUT_POST, FILTER_SANITIZE_SPECIAL_CHARS);
	$Factura =(isset($_POSTS['Factura']) ? $_POSTS['Factura'] : '0');
	$idu_escuela =(isset($_POSTSt['idu_escuela']) ? $_POSTSt['idu_escuela'] : '0');
	$rfc_escuela =(isset($_POSTSt['rfc_escuela']) ? $_POSTSt['rfsc_escuela'] : '');
	$nom_escuela =(isset($_POSTSt['nom_escuela']) ? $_POSTSt['nom_escuela'] : '');
?>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_subirFacturaElectronica.js"></script>
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
	
		<div class="row-fluid" id="div_MostrarMensaje"></div>	
		<div class="row-fluid" style="margin-bottom:10px;">
			<h4>Datos del Colaborador</h4>
		</div>
		
		<div class="control-group">
			<div class="row-fluid">
				<div class="span4">
					<input type="hidden" id="txt_Limitado" name="txt_Limitado" />
					<input type="hidden" id="txt_Bloqueado" name="txt_Bloqueado"/>
					<input type="hidden" id="txt_Empleado" name="txt_Empleado"/>					
					<input type="hidden" id="txt_Anio" name="txt_Anio" value="<?php echo date('Y'); ?>0101" />
					<!--label class="control-label" for="txt_SueldoMensual"  hidden>Sueldo Mensual:</label-->
					<div type="hidden"  class="controls">
						<input type="hidden" class="span10"  style="text-align:right;" id="txt_SueldoMensual" type="text" readonly />
					</div>
					<label class="control-label" for="txt_AcumFactPag"  >Acum. Facturas Pagadas:</label>
					<div class="controls">
						<input class="span10" id="txt_AcumFactPag" style="text-align:right;" type="text" readonly />
					</div><br>
					<label class="control-label" for="txt_TopeMensual"  >Tope Mensual:</label>
					<div class="controls">
						<input class="span10" id="txt_TopeMensual" type="text" style="text-align:right;" readonly />
					</div><br>
				</div>
				
				<div class="span4">
					<input type="hidden" id="txt_Folio">
					<label class="control-label" for="txt_TopeProp"  >Tope Anual Proporcional:</label>
					<div class="controls">
						<input class="span10" id="txt_TopeProp" type="text"  style="text-align:right;" readonly />
					</div><br>
					<label class="control-label" for="txt_TopeRest"  >Tope Proporcional Restante:</label>
					<div class="controls">
						<input class="span10" id="txt_TopeRest" style="text-align:right;" type="text" readonly />
					</div>
				</div>
				
				<!--div class="span4">
					<label class="control-label" for="txt_TopeMensual"  >Tope Mensual:</label>
					<div class="controls">
						<input class="span10" id="txt_TopeMensual" type="text" style="text-align:right;" readonly />
					</div><br>
				</div-->
			</div>
		</div>
		<hr>
		
		<div class="row-fluid">
			<div class="alert alert-block alert-success" id="div_msj">
				<!--button type="button" class="close" data-dismiss="alert">
					<i class="icon-remove"></i>
				</button-->		
				
			</div>
		</div>
		
		<div class="control-group">
			<form id="xmlupload" name="xmlupload" action="ajax/json/json_leer_Rfc_XML.php" method="POST" enctype="multipart/form-data" style="margin-bottom:0px;">
				<div class="row-fluid">
					<div class="span9">
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
							<input type="hidden" id="txt_FechaFactura" name="txt_FechaFactura" value="" />
							<input type="hidden" id="txt_Rfc_fac" name="txt_Rfc_fac" value="<?php echo $rfc_escuela; ?>" />
							<input type="hidden" id="txt_Rfc_Emp" name="txt_Rfc_Emp" />
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
			</form>

			<div class="row-fluid">
				<div class="span9">
					<label class="control-label" for="cbo_Escuela" style=" margin-bottom:16px;">Escuela:</label>
					<div class="controls">
						<select id="cbo_Escuela" style="width:100%;" tabindex="3">
							<option value='0'>SELECCIONE ESCUELA</option>
						</select>
						<!-- Importe Factura <button class="icon-edit bigger-180 btn-primary" id="btn_Cargar" type="button" data-content="Actualizar RFC de escuela" data-placement="right" data-trigger="hover" data-rel="popover"  style="background:transparent; border: none !important;"></button>-->
					</div>
				</div>
			</div>
			
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
					<label class="control-label" id="lbl_importeFac" for="txt_ImporFact" style=" margin-bottom:16px;">:</label>
					<div class="controls">
						<input id="txt_ImporFact" type="text" style="text-align:right;" readonly />
					</div>
				</div>
			</div>
			
			<div class="row-fluid">
				<div class="span5">
					<input type="hidden" id="txt_Fecha" name="txt_Fecha"  value="<?php echo date('d/m/Y'); ?>">
					<label class="control-label" id="lbl_FechaFac" for="txt_FechaCap"  ></label>
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
		
		<!-- Sección Botones -->
		<div class="row-fluid">
			<button id="btn_Agregar" role="button" class="btn btn-small btn-primary" data-toggle="modal" display="none" align="center" tabindex="4" >
				<i class="icon-plus bigger-110"></i>Agregar Beneficiario
			</button>
			<button class="btn btn-small btn-success" id="btn_Otro" tabindex="5">
				<i class=" icon-refresh smaller-200"></i>Limpiar
			</button>
		</div><br>
		
		<!-- GRID -->
		<div class="row-fluid">
			<div id="contenedor_Beneficiarios">
				<table id="grid_Beneficiarios"></table>
				<div id="grid_Beneficiarios_pager"></div>
			</div>
		</div>
		
		<!-- TOTAL -->
		<div class="row-fluid">
			<div class="pull-right">
				<label class="control-label" for="txt_Tolal">TOTAL: </label>
				<div class="controls">
					<input style="text-align:right" type="text" id="txt_Tolal" readonly />
				</div>
				
			</div>
		</div><br>
		
		<div class="row-fluid">
			<div class="span8">
				<button class="btn btn-warning btn-small" id="btn_Editar" type="button">
					<i class="icon-edit bigger-110"></i>Modificar Datos
				</button>
				<button class="btn btn-small btn-danger" id="btn_Eliminar">
					<i class="icon-trash bigger-110"></i>Eliminar
				</button>
			</div>
			<div class="span3">
				<button class="btn btn-small btn-primary pull-left" id="btn_Guardar">
					<i class="icon-save bigger-110"></i>Subir Factura
				</button>
				
			</div>
		</div>
		
	</div>
</div>

<!-- MODAL AGREGAR DETALLE -->
<div id="dlg_AgregarDetalle" class="modal hide" tabindex="-1" style="width:800px; height:500px;position:fixed" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">&times;</button>
		<h4 class="black bigger" id="tit_modal_beneficiario_eprv"><i class="icon-file-text-alt "></i>&nbsp;Agregar Beneficiario</h4>
	</div>
	<div id="modalBodyAgregarDetalle" class="modal-body" style="height:500px;">
		<div class="row" style="width:90%;">
			<!-- INICIA -->
			<div class="span12" style="margin-top:8px; margin-bottom:4px;">
				<div id="div_escuelaPri" style="text-align:center;"></div>
				<input id="txt_importe_compara" type="hidden" style="text-align:right"/>
			</div>			
			
			<div class="span12" style="margin-bottom:4px;">
				<div class="span2" style="text-align:right;">
					<label>Beneficiario:</label>
				</div>
				<div class="span4">
					<select id="cbo_Beneficiario" style="width:100%;" tabindex="101"></select>
				</div>
				<div class="span2" style="text-align:right;">
					<label>Parentesco:</label>
				</div>
				<div class="span4">
					<select id="cbo_Parentesco" disabled style="width:100%;"></select>
				</div>
				
			</div>
			
			<div class="span12" style="margin-bottom:4px;">
				<div class="span2" style="text-align:right;">
					<label class="control-label">Tipo Pago: </label>
				</div>
				<div class="span4">
					<select id="cbo_TipoPago" style="width:100%;" tabindex="102"></select>
				</div>
				
				<div class="span2" style="text-align:right;">
					<label class="control-label">Periodo: </label>
				</div>
				<div class="span4">
					<div class="contenido">
						<select id="cbo_Periodo" data-placeholder="SELECCIONE" style="width:100%;" multiple tabindex="103"></select>
					</div>
				</div>
			</div>
			
			<div class="span12" style="margin-bottom:4px;">
				<div class="span2" style="text-align:right;">
					<label>Escolaridad:</label>
				</div>
				<div class="span4">
					<select id="cbo_Escolaridad" style="width:100%;" tabindex="104"></select>
				</div>
				
				<div class="span2" style="text-align:right;">
					<label >Grado Escolar: </label>
				</div>
				<div class="span4">
					<select id="cbo_Grado" style="width:100%;" tabindex="105">
						<option value='0'>SELECCIONE</option>
					</select>
				</div>
			</div>
			
			<div class="span12" style="margin-bottom:4px;">
				<div class="span2" style="text-align:right;">
					<label class="control-label">Ciclo Escolar: </label>
				</div>
				<div class="span4">
					<select id="cbo_CicloEscolar" style="width:100%;" tabindex="106"></select>
				</div>
				
				<div class="span2" style="text-align:right;">
					<label class="control-label" for="txt_importeConcep">Importe de Concepto:</label>
				</div>
				<div class="span4">
					<input class="currency" style="text-align:right" id="txt_importeConcep" style="width:100%;" tabindex="108" maxlength="8"/>					
					<!--<select id="cbo_Importes" style="width:100%;" tabindex="7"></select>-->
				</div>
			</div>
			<!-- -->
			<div class="span12" style="margin-bottom:4px;">
				<div class="span2" style="text-align:right;">
					<label class="control-label">Carrera: </label>
				</div>
				<div class="span4">
					<select id="cbo_Carrera" style="width:100%;" tabindex="107"></select>
				</div>
				
				<div class="span6" style="text-align:right;">
				
				</div>
			</div>
			
			<div class="span12" style="margin-top:35px;">
				<div class="span9" style="text-align:center;">
					<span><i class="red"> Puede realizar combinaciones para la captura de los tipo-periodo pagos. </i></span>
				</div>
				<div class="span3">
					<button class="btn btn-small btn-primary" id="btn_AgregarB" tabindex="109">
					<i class="icon-plus bigger-110"></i>Agregar</button>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- MODAL AGREGAR ACLARACIÓN -->
<div class="modal hide" tabindex="-1" style="width: 450px; height: 300px;position:fixed;" aria-hidden="false" id="dlg_AgregarAclaracion" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">×</button>			
		<h4 class="black bigger"><i class="icon-comment "></i>&nbsp;Aclaraciones</h4>
	</div>
	<div class="modal-body">
		<div class="row-fluid ">
			<table border="0" width="280">
				<tr>
					<td align="center"><label>Motivo de Aclaración: </label></td>
				</tr>
				<tr>
					<td><select class="span12" id="cbo_Aclaracion"></select></td>
				</tr>
				<tr>	
					<td><textarea class="span8 textNumbersOnly" id="txt_MotivoAclaracion" maxlength="300" style="resize:none; width:400px; text-transform:uppercase;"></textarea></td>		
				</tr>	
				<tr>
					<td></td>
				</tr>	
				<tr>	
					<td align="right">
						<button class="btn btn-small btn-primary" id="btn_MotivoAclaracion">
						<i class="icon-save bigger-110"></i>Guardar</button>
					</td>
				</tr>
				<tr>
					<td>
						<span><i class="red">Proporcione el motivo de aclaración, por que la suma del importe de los conceptos de pago es diferente al total de la factura</i></span>
					</td>
				</tr>
			</table>
		</div>
	</div>	
</div>

<div id="dlg_AyudaEscuelas"  class="modal hide" tabindex="-1" style="width:600px; height:550px; position:fixed" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">×</button>			
		<h4 class="black bigger"><i class="icon-home "></i>&nbsp;Escuelas</h4>
	</div>
	<div class="modal-body">
		<table border="0" >
			<tr>
				<td width="90px" style="text-align:right"><label>Estado: </label></td>
				<td width="200px"><select id="cbo_Estado" style="width:100%;" tabindex="1"></select></td>
				<td width="60px" style="text-align:right"><label>Ciudad: </label></td>
				<td width="200px" >
					<div>
						<select id="cbo_Ciudad"style="width:100%;" tabindex="2"></select>
					</div>		
				</td>
			</tr>
			<tr>
				<td style="text-align:right"><label>Buscar por: </label></td>
				<td colspan="3">
					<div>
						<select id="cbo_TipoConsulta" style="width:25%;" tabindex="3">
							<option value="1"> Nombre</option>
							<option value="2"> RFC/Clave SEP</option>
						</select>
					<input type="text" class="textNumbersOnly" id="txt_NombreBusqueda" style="text-transform:uppercase;width:250px"  placeholder="Nombre ó Clave SEP " maxlength="50" tabindex="4"/>
					&nbsp; &nbsp; &nbsp; <button class="btn btn-small btn-primary" id="btn_ConsultaAyudaEscuela" type="button"> 
					<i class="icon-search bigger-110"></i> </button></div>
				</td>
			</tr>
		</table>
		<div id="gridEscuelas">
			<table id="grid_ayudaEscuelas" ></table>
			<div id="grid_ayudaEscuelas_pager" ></div>
		</div>
	</div>
	<div class="modal-footer">
		<div class="span10">
				<label><font style="text-align:center" color="black">Doble click para actualizar la escuela con el RFC de su factura...</font></label>
		</div>	
	</div>		
</div>

<div id="div_cargando" class="ui-widget-overlay ui-front" style="display: none;">
	<div class="ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix">
		<span class="ui-dialog-title" id="ui-id-2">
			<div class="widget-header widget-header-small">
				<h4 class="smaller">
					<i class="icon-coffee"></i>
						Cargando...
				</h4>
				<div id="div_load" class="progress progress-success progress-striped  active" data-percent="0%">
					<div id="div_loading" class="bar" style="width: 0%;"></div>
   				</div>
			</div>
		</span>
	</div>
</div>		