<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = 'Colegiaturas';
	

	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_NUMBER_INT);
	$IdEmpleado =(isset($_POST['IdEmpleado']) ? $_POSTS['IdEmpleado'] : '');
	$FechaInicial =(isset($_POST['FechaInicial']) ? $_POST['FechaInicial'] : '');
	$FechaFinal =(isset($_POST['FechaFinal']) ? $_POST['FechaFinal'] : '');
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
?>
<!--page specific plugin styles-->


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
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/accounting.min.js"></script>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_asignarExternosAColaborador.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
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

<div class="span12;page-header position-relative; form-horizontal">
	<div class="span12">	
		<div class="span8">
		<br>
			<div class="control-group">	
				<label class="control-label">Colaborador:</label>			
				<div class="controls">
					<input type="text" class="span3 numbersOnly" id="txt_Numemp" maxlength="8" value="<?php echo $IdEmpleado; ?>" >
					<input class="span5" type="text" id="txt_Nombre" readonly >
					<button id="btn_AyudaEmp" class="icon-question-sign bigger-180" title="" data-content="O presione F2 para búsqueda" data-placement="right" data-trigger="hover" data-rel="popover" data-original-title="Capture Número de Colaborador" 
										style=" color: light-blue; background:transparent; border: none !important;" ></button>
				</div><br>
				<label class="control-label">Puesto:</label>
				<div class="controls">
					<input type="text" class="span8" id="txt_Puesto"  readonly >      
<!--					<input type="text" class="span8" id="txt_NombrePuesto" readonly> -->
				</div><br>					
				<label class="control-label">Centro:</label>
				<div class="controls">
					<input type="text" class="span8" id="txt_Centro"  readonly >      
<!--					<input type="text" class="span8" id="txt_NombreCentro" readonly> -->
				</div><br>
				<div class="span10" align="right">
					<div class="controls">
						<button class="btn btn-small btn-primary" id="btn_Consultar">
							<i class="icon-search bigger-110"></i>Consultar
						</button>
						<button class="btn btn-small btn-success" id="btn_Otro">
							<i class="icon-refresh bigger-110"></i>Otro Colaborador
						</button>						
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="control-group">
		<div class="span7">
			<div id="gridAsignarExternos">
			<br>
				<table id="gridExternos-table"></table>
				<div id="gridExternos-pager">
				</div>
			</div>
			<div class="controls" align="right">
			<br>
				<button class="btn btn-small btn-primary" id="btn_Guardar">
				<i class="icon-save bigger-110"></i>Guardar
				</button>
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
	<input type="hidden" id="hid_idu_usuario" name="hid_idu_usuario" value="<?php echo $iEmpleado;  ?>"/>
</div>