<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>
<!-- VULNERABILIDADES -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>
<!-- VULNERABILIDADES -->

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_bitacoraMovimientosColegiaturas.js"></script>
<style type="text/css" media="screen">
	th.ui-th-column div {
		white-space: normal !important;
		height: auto !important;
		padding: 2px;
	}
</style>

<!--div class="page-content" style="overflow-x: hidden;overflow-y: hidden;"-->
<div class="span12; page-content; form-horizontal" style="overflow-x: hidden;overflow-y: hidden;>
<!--div class="page-content"-->
	<!--div class="row-fluid"-->
	<br>
	<div class="span11">
		<div class="span6">
			<!-- Fecha Inicial -->
			<div class="control-group">
				<label class="control-label" for="txt_FechaInicio">Fecha Inicial:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaInicio" class="input-small" readonly value="<?php $datestring=date('Y-m-d') . ' first day of last month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>">
						<span class="add-on">
						<i class="icon-calendar"></i>
					</span>
					</div>
				</div>
			</div>
			<div class="control-group">
				<!-- Fecha Final -->
				<label class="control-label" for="txt_FechaFin">Fecha Final:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" readonly value="<?php echo date('d/m/Y'); ?>" />
						<span class="add-on">
						<i class="icon-calendar"></i>
					</span>
					</div>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label" for="txt_numEmpleado">Colaborador:</label>
				<div class="controls">
					<input id="txt_numEmpleado" class="span4 numbersOnly" type="text" maxlength="8">
						<input class="span7" type="text" id="txt_Nombre" readonly>
						<button class="btn btn-info btn-small" onclick="return false;" id="btn_buscar">
							<i class="icon-search icon-on-right bigger-110"></i>
						</button>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Tipo Movimiento:</label>
				<div class="controls">
					<select id="cbo_tipoMovimiento" class="span7"></select>
				</div>
			</div>
		</div>
		<div class="span6" id="filtros">
			<div class="control-group">
				<label class="control-label">Región:</label>
				<div class="controls ">
					<select class="span10" id="cbo_region"></select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Ciudad:</label>
				<div class="controls ">
					<select class="span10" id="cbo_ciudad">
						<option value='0'>TODAS</option>
					</select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Centro:</label>
				<div class="controls">
					<input type="hidden" id="txt_CentroF">
					<form class="form-search">
						<input type="text" class="span9" id="txt_NombreCentroF" readonly>
						<button class="btn btn-info btn-small" onclick="return false;" id="btn_ayudaCentro">
							<i class="icon-search icon-on-right bigger-110"></i>
						</button>
					</form>
				</div>
			</div>
		</div>
		<div class="span11" align="right">
			<div class="controls">
				<button class="btn btn-primary btn-small" id="btn_Consultar">
					<i class="icon-search bigger-110"></i>Consultar
				</button>
				<button class="btn btn-success btn-small" id="btn_Limpiar">
					<i class="icon-refresh bigger-110"></i>Limpiar
				</button>
			</div>
			<br>
		</div>
		<div class="span12">
			<div class="control-group">
				<table id="gridBitacoraColegiaturas-table"></table>
				<div id="gridBitacoraColegiaturas-pager"></div>
			</div>
		</div>
	</div>
</div>
	<!--/div-->
	<!-- Modal de busqueda de Empleados -->
	<div id="dlg_BusquedaEmpleados" class="modal hide" tabindex="-1" style="width:950px;   height:auto; position:top; margin-left: -480px; margin-top: 0px;" data-backdrop="static">
		<div class="modal-header widget-header">
			<button type="button" class="close" data-dismiss="modal">&times;</button>
			<h4 class="black bigger"><i class="icon-file-text-alt "></i>&nbsp;Consulta de Colaborador</h4>
		</div>
		<div class="modal-body">
			<table cellpadding="7">
				<br>
				<tr>
					<td style="width:70px">
						<b>Nombre: </b>
					</td>
					<td>
						<input type="txt" id="txt_NombreBusqueda" class="textOnly" style="text-transform:uppercase; width:140px" maxlength="45" />
					</td>
					<td style="width:120px">
						<b>Apellido Paterno: </b>
					</td>
					<td>
						<input type="txt" id="txt_apepatbusqueda" class="textOnly" style="text-transform:uppercase; width:140px" maxlength="45" />
					</td>
					<td style="width:120px">
						<b>Apellido Materno: </b>
					</td>
					<td>
						<input type="txt" id="txt_apematbusqueda" class="textOnly" style="text-transform:uppercase; width:140px" maxlength="45" />
					</td>
					<td align="right">
						<button id="btn_buscarCOL" class="btn btn-small btn-primary"><i class="icon-search bigger-90"></i>Buscar</button>
					</td>
				</tr>
				<tr>
					<td colspan="7">&nbsp;</td>
				</tr>
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

	<!-- Modal de busqueda Centros -->
	<div id="dlg_AyudaCentro" class="modal hide" tabindex="-1" style="width:500px; position:top; margin-left: -300px; margin-top: 0px;" data-backdrop="static">
		<div class="modal-header widget-header">
			<button type="button" class="close" data-dismiss="modal">&times;</button>
			<h4 class="black bigger"><i class="icon-file-text-alt "></i>&nbsp;Consulta de Centros</h4>
		</div>
		<div class="modal-body" cellpadding="2">
			<table width="480px" border="0x">
				<tr>
					<td style="width:80px;text-align:left;">
						<label>Núm. Centro</label>
					</td>
					<td style="width:300px;text-align:left;">
						<label>Nombre Centro</label>
					</td>
				</tr>
				<tr>
					<td style="width:80px;text-align:left">
						<input type="txt" id="txt_CentroBusqueda" placeholder="CENTRO" class="numbersOnly" style="width:100px" maxlength="6">
					</td>
					<td style="width:300px;text-align:left;">
						<input type="txt" id="txt_NomCentroBusqueda" placeholder="NOMBRE CENTRO" style="text-transform:uppercase;width:240px" class="textOnly" maxlength="30">
						<button id="btn_BuscarCentro" class="btn btn-primary  icon-search" type="button">
							Buscar
						</button>
					</td>
				</tr>
			</table>
			<table>
				<tr>
					<td>
						<table id="grid_Centros"></table>
						<div id="grid_Centros_pager"></div>
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