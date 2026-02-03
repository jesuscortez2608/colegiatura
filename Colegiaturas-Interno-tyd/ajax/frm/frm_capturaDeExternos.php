<?php
    
	header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	$_POSTS = filter_input_array(INPUT_POST, FILTER_SANITIZE_NUMBER_INT);
	//$IdEmpleado =(isset($_POST['IdEmpleado']) ? $_POST['IdEmpleado'] : '');
	$IdEmpleado =(isset($_POSTS['IdEmpleado']) ? $_POSTS['IdEmpleado'] : '');
	//$NomEmp = (isset($_POST['NomEmp']) ? $_POST['NomEmp'] : '');
	$NomEmp = (isset($_POSTS['NomEmp']) ? $_POSTS['NomEmp'] : '');
	
?>
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/jquery-ui-1.10.3.full.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ui.jqgrid.css" />
<!--ace styles-->
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-responsive.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-skins.min.css" />
<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->			
<!--page specific plugin scripts-->
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<script type="text/javascript" src="<!--url-->src/com/coppel/utils/jquery.form.js"></script>
<script type="text/javascript" src="files/js/utils.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/frm_capturaDeExternos.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
	b{
       font-size: 14px;
	   font-weight: normal;
	   align: rigth;
    }
</style>
<div class="page-content">
	<div id="tabs" class="span9">
		<ul>
			<li><a href="#porNumero" style="font-size: 14px;">
					<i></i><b> Número Colaborador</b>
				</a>
			</li>
			<li>
				<a href="#porNombre" style="font-size: 14px;">
					<i></i><b>Nombre Colaborador</b>
				</a>
			</li>
		</ul>
		<div id="porNumero">
			<div class="form-horizontal">
				<div class="control-group">
					<label class="control-label">Número:</label>			
					<div class="controls">
						<input type="text" class="span3 numbersOnly" id="txt_Numemp" maxlength="8" tabindex="1" value="<?php echo $IdEmpleado; ?>" />
						<input class="span6" type="text" id="txt_Nombre" readonly />
						<button id="btn_AyudaEmp" class="icon-question-sign bigger-180" title="" data-content="O presione F2 para búsqueda" data-placement="right" data-trigger="hover" data-rel="popover" data-original-title="Capture Número de Colaborador" 
						style=" color: light-blue; background:transparent; border: none !important;" ></button>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Descuento:</label>
					<div class="controls">
						<select id="cbo_DescuentoNum" class="span2" tabindex="2"></select>
					</div>
				</div>
				<div class="controls">
					<button class="btn btn-small btn-primary" id="btn_GuardarNum" tabindex="3">
						<i class="icon-save bigger-110"></i>Guardar
					</button>				
				</div>
			</div>
		</div>
		<div id="porNombre">
			<div class="form-horizontal">
				<div class="control-group">
					<label class="control-label">Nombre:</label>			
					<div class="controls">
						<input type="text" class="span7 textOnly" id="txt_NomEmp" maxlength="60" style="text-transform:uppercase" tabindex="1" value="<?php echo $NomEmp; ?>" />
						<!--
						<button class="btn btn-small btn-primary" id="btn_Buscar">
							<i class="icon-search bigger-110"></i>
						</button>
						-->
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Descuento:</label>
					<div class="controls">
						<select id="cbo_DescuentoNom" class="span2" tabindex="2"></select>
					</div>
				</div>
				<div class="controls">
					<button class="btn btn-small btn-primary" id="btn_GuardarNom" tabindex="3">
						<i class="icon-save bigger-110"></i>Guardar
					</button>				
				</div>				
			</div>
		</div>
		<!--
		<div class="span12">
			<div class="span11" align="right">
				<div class="controls">
					<button class="btn btn-small btn-primary" id="btn_Guardar">
						<i class="icon-save bigger-110"></i>Guardar
					</button>				
				</div>
			</div>
		</div>	
		-->
	</div>
	<div class="control-group">
		<div class="span9">
			<div id="gridCapturaExternos">
				<table id="gridExternos-table"></table>
				<div id="gridExternos-pager"></div>
			</div>
		</div>	
	</div>
</div>
<div id="dlg_BusquedaEmpleados" class="modal hide" tabindex="-1" style="width:955px; height:auto; position:fixed; margin-left: -480px; margin-top: 0px;" data-backdrop="static">		
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consulta de Colaborador</h4>
	</div>
	<div class="modal-body">
		<table cellpadding="7">
			<br>
			<tr>
				<td style="width:70px">
					<b>Nombre: </b>
				</td>
				<td>
					<input type="txt"  class="textOnly" id="txt_NombreEBusqueda" style="text-transform:uppercase; width:140px" maxlength="30" tabindex="1000">
				</td>
				<td style="width:120px">
					<b>Apellido Paterno: </b>
				</td>
				<td>
					<input type="txt" class="textOnly" id="txt_apepatbusqueda" style="text-transform:uppercase; width:140px" maxlength="30" tabindex="1001">
				</td>
				<td style="width:123px">
					<b>Apellido Materno: </b>
				</td>
				<td>
					<input type="txt" class="textOnly" id="txt_apematbusqueda" style="text-transform:uppercase; width:140px" maxlength="30" tabindex="1002">
				</td>
				<td align="right">
					<button class="btn btn-primary btn-small" id="btn_buscarCOL" tabindex="1003"><i class="icon-search"></i></button>
				</td>
			</tr>
			<tr><td colspan="7">&nbsp;</td></tr>
		</table>
		<table>
			<tr >
				<td>
					<table id="grid_colaborador"></table>
					<div id="grid_colaborador_pager"></div>
				</td>
			</tr>
		</table>
	</div>
	<div class="modal-footer">
		<div align="center">
			<label><font color="black">Doble click para seleccionar...</font></label>

		</div>
	</div>	
</div>