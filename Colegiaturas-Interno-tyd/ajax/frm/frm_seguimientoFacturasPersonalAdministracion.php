<?php
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = 'Colegiaturas';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_SPECIAL_CHARS);    
	$_POSTI = filter_input_array(INPUT_POST,FILTER_SANITIZE_NUMBER_INT);
	
	$iColaborador = (isset($_POST['IdColaborador']) ? $_POSTI['IdColaborador'] : '');
	$dFechaInicial = (isset($_POST['dFechaInicial']) ? $_POSTS['dFechaInicial'] : '');
	$dFechaFinal = (isset($_POST['dFechaFinal']) ? $_POSTS['dFechaFinal'] : '');
	$iEstatus = (isset($_POST['IdEstatus']) ? $_POSTI['IdEstatus'] : '');
	$iRegion = (isset($_POST['idRegion']) ? $_POSTI['idRegion'] : '');
	$iCiudad = (isset($_POST['idCiudad']) ? $_POSTI['idCiudad'] : '');
	$iTipoNom = (isset($_POST['idTipoNom']) ? $_POSTI['idTipoNom'] : '');
	$iRegresa = (isset($_POST['iRegresa']) ? $_POSTI['iRegresa'] : '');
?>
<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->

<!-- VULNERABILIDADES -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_seguimientoFacturasPersonalAdministracion.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
		<form class="form-horizontal">
			<div class="span12 form-horizontal">
			
				<div class="span7">
					<div class="control-group">
					
						<!-- Nombre del empleado -->
						<label class="control-label" >Colaborador:</label>
						<div class="controls">
							<input id="txt_idEmpleado" class="numbersOnly" maxlength="8" class="span3" type="text" placeholder="" value="<?php echo $iColaborador; ?>" />
							<input type="text" class="span7" id="txt_nombreEmpleado" readonly />
							<button class="btn btn-info btn-small" id="btn_buscar">
								<i class="icon-search icon-on-right bigger-110"></i>
							</button>
						</div>
						<br>
						
						<div class="span5">
							<!-- Fecha Inicial -->
							<label class="control-label" for="txt_FechaInicio">Fecha Inicial:</label>
							<div class="controls">
								<div class="row-fluid input-append">
									<input type="text" id="txt_FechaInicio" class="input-small" readonly value="<?php $datestring=date('Y-m-d') . ' first day of last month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>" /> 
									<span class="add-on">
										<i class="icon-calendar"></i>
									</span>
								</div>
							</div>
							<br>
							
							<!-- Fecha Final -->
							<label class="control-label" for="txt_FechaFin">Fecha Final:</label>
							<div class="controls">
								<div class="row-fluid input-append">
									<input type="text" id="txt_FechaFin" class="input-small" readonly value="<?php echo date('d/m/Y'); ?>"/>
									<span class="add-on">
										<i class="icon-calendar"></i>
									</span>
								</div>
							</div>
							<br>
						
						</div>
						<div class="span6">		
						<br>			
							<label class="control-label" >Empresa:</label>
							<div class="controls">
								<select id="cbo_empresa" tabindex="3">
								</select>
							</div><br>
						</div>  
					</div>
				</div>
				
				<div class="span4">
					<div class="control-group">
						
						<!-- Region -->
						<label class="control-label">Región:</label>
						<div class="controls" >
							<select id="cbo_Region" ></select>
						</div>
						<br>
						
						<!-- Ciudad -->
						<label class="control-label">Ciudad:</label>
						<div class="controls" >
							<select id="cbo_Ciudad" ></select>
						</div>
						<br>
						
						<!-- Estatus -->
						<label class="control-label">Estatus:</label>
						<div class="controls" >
							<select id="cbo_Estatus"></select>
						</div>
						<br>
						
						<!--Tipo Nomina -->
						<label class="control-label">Tipo Nómina:</label>
						<div class="controls">
							<select id="cbo_TipoNomina">
								<option value="0">TODOS</option>
								<option value="1">COLABORADOR</option>
								<option value="3">DIRECTIVO</option>
							</select>
						</div>
						<br>
						
						<!-- Consultar -->
						<div class="controls">
							<button class="btn btn-small btn-primary" id="btn_Consultar">
								<i class="icon-search bigger-110"></i>Consultar
							</button>
						</div>
						
					</div>
				</div>
			</div>
			<div class="row-fluid">
				<div class="span12">
					<div class="control-group">	
						<table id="grd_Empleados"></table>
						<div id="grd_Empleados_pager"></div>
					</div>
				</div>
			</div>
		
			
		</form>
		
	<input type="hidden" id="hid_iColaborador" style="display:none;" name="hid_iColaborador" value="<?php echo $iColaborador; ?>"/>
	<input type="hidden" id="hid_region" name="hid_region" value="<?php echo $iRegion; ?>"/>
	<input type="hidden" id="hid_ciudad" name="hid_ciudad" value="<?php echo $iCiudad; ?>"/>
	<input type="hidden" id="hid_estatus" name="hid_estatus" value="<?php echo $iEstatus; ?>"/>
	<input type="hidden" id="hid_tNomina" name="hid_tNomina" value="<?php echo $iTipoNom; ?>"/>
	<input type="hidden" id="hid_FechaIni" name="hid_FechaIni" value="<?php echo $dFechaInicial; ?>"/>
	<input type="hidden" id="hid_FechaFin" name="hid_FechaFin" value="<?php echo $dFechaFinal; ?>"/>
	<input type="hidden" id="hid_regresa" name="hid_regresa" value="<?php echo $iRegresa; ?>"/>
</div>

<!-- Div Export para impresión en PDF -->
<div id="divexport">
</div>

<!-- Modal de busqueda de Empleados -->
<div id="dlg_BusquedaEmpleados" class="modal hide" style="width:950px;   height:auto; position:absolute; margin-left: -480px; margin-top: 0px;" >
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
					<input type="text" id="txt_nombusqueda" class="textOnly" style="text-transform:uppercase; width:140px" maxlength="45"/>
				</td>
				<td style="width:120px">
					<b>Apellido Paterno: </b>
				</td>
				<td>
					<input type="text" id="txt_apepatbusqueda" class="textOnly" style="text-transform:uppercase; width:140px" maxlength="45"/>
				</td>
				<td style="width:120px">
					<b>Apellido Materno: </b>
				</td>
				<td>
					<input type="text" id="txt_apematbusqueda" class="textOnly" style="text-transform:uppercase; width:140px" maxlength="45"/>
				</td>
				<td align="right">
					<button id="btn_buscarCOL" class="btn btn-small btn-primary icon-search">Buscar</button>
				</td>
			</tr>
			<tr><td colspan="7">&nbsp;</td></tr>
		</table>
		<table>
			<tr>
				<td>
					<table id="grid_colaborador"></table>
					<!--
						<div id="grid_colaborador_pager"></div>
					-->
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