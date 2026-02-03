<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_reporteBecasCentro.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
	}
</style>

<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>

<div class="page-content">
	<form class="form-horizontal">
		<div class="span12">
		
			<div class="span6 control-group">
			
				<!-- Ruta de Pago -->
				<label class="control-label">Ruta de Pago:</label>
				<div class="controls">
					<select id="cbo_rutaPago">
					</select>
				</div>
				<br>

				<!-- Estatus -->
				<label class="control-label">Estatus:</label>
				<div class="controls">
					<select id="cbo_Estatus">
						<option value="-1">SELECCIONE</option>
						<option value="2">PROCESO</option>
						<option value="6">PAGADO</option>
					</select>
				</div>
				<br>

				<!-- Región -->
				<label class="control-label">Región:</label>
				<div class="controls">
					<select id="cbo_Region"></select>
				</div>
				<br>

				<!-- Ciudad -->
				<label class="control-label">Ciudad:</label>
				<div class="controls">
					<select id="cbo_Ciudad">
						<option value='0'>TODAS</option>
					</select>
				</div>
				<br>
				<!-- Area -->
				<label class="control-label">Área:</label>
				<div class="controls">
					<select id="cbo_area">
						<option value="0">TODAS</option>
					</select>
				</div>
				<br>
				
				<!-- Seccion -->
				<label class="control-label">Sección:</label>
				<div class="controls">
					<select id="cbo_seccion" disabled>
						<option value="0">TODAS</option>
					</select>
				</div>
				<br>
				<!-- Centro -->
				<label class="control-label">Centro:</label>
				<div class="controls">
					<input type="hidden" id="txt_CentroF">
					<form class="form-search">
						<input type="text" id="txt_NombreCentroF" readonly>
						<button class="btn btn-info btn-small" onclick="return false;" id="btn_ayudaCentro">
							<i class="icon-search icon-on-right bigger-110"></i>
						</button>
					</form>
				</div>
			</div>
			<div class="span6 control-group">
				<!-- Tipos de Deducción -->
				<label class="control-label" >Tipos de Deducción:</label>
				<div class="controls">
					<select id="cbo_tipoDeduccion" >
					</select>
				</div>
				<br>
				<div >
					<input id="rdbtn_ciclo" name="form-field-radio" type="radio" class="ace" style="align:right"/>
					<span class="lbl">Por Ciclo</span>
				</div>
				<label class="control-label" for="cbo_CicloEscolar">Ciclo Escolar:</label>
					<div class="controls">
						<select id="cbo_CicloEscolar" disabled></select>
					</div>
					<br>
				<div align="left">
					<input id="rdbtn_fecha" name="form-field-radio" type="radio" class="ace" style="align:right" checked="true"/>
					<span class="lbl">Por Fecha</span>
				</div>
				<!-- Fecha Inicial -->
				<label class="control-label" for="txt_FechaInicio">Fecha Inicial:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaInicio" class="input-small" readonly value="<?php $datestring=date('Y-m-d') . ' first day of this month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>">
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
				
				<!-- Escolaridad -->
				<label class="control-label">Escolaridad:</label>
				<div class="controls">
					<select id="cbo_Escolaridad"></select>
				</div>
				<br>
				<!-- Empresa -->
				<label class="control-label">Empresa:</label>
				<div class="controls">
					<select id="cbo_empresa">
					</select>
				</div>
			</div>
		</div>
		<!--<form id="formReporte" name="formReporte" action=""-->
	</form>
	
	<div class="row-fluid">
		<br>
		<div class="controls">
			<button id="btn_consultar" class="btn btn-small btn-primary pull-right">
			<i class="icon-search bigger-110"></i>Consultar</button>
		</div>
	</div>
	<div class="row-fluid">
		<div class="span12">
			<label id="lblNotaEstatusProceso" style="hidden:true;"><b>* NOTA:</b> El Estatus Proceso incluye los estatus de Facturas en Proceso, Aceptadas, Aclaración y en Revisión.</label>
		</div>
	</div>
	<div class="row-fluid">
		<div class="span12">
			<!-- Grid Reporte -->
			<div class="control-group">
				<div id="gridReporteCentro">
					<table id="gridReporteCentro-table"></table>
					<div id="gridReporteCentro-pager"></div>
				</div>
			</div>
		</div>
	</div>
	
</div>

<!-- Modal de busqueda Centros -->
<div id="dlg_AyudaCentro" class="modal hide" tabindex="-1" style="width:450px; position:top; margin-left:-300px; margin-top:0px;" data-backdrop="static">
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consulta de Centros</h4>
	</div>
	<div class="modal-body" cellpadding="2">
		<table width="400px" border="0x">
			<tr>
				<td style="width:80px;text-align:center;">
					<label>Número Centro</label>
				</td>
				<td style="width:200px;text-align:center;">
					<label>Nombre Centro</label>
				</td>
			</tr>
			<tr>
				<td style="width:80px;text-align:center;">
					<input type="txt" id="txt_CentroBusqueda" placeholder="CENTRO" class="numbersOnly" style="width:100px" maxlength="6">
				</td>
				<td style="width:200px; text-align:center;" >
					<input type="txt" id="txt_NomCentroBusqueda" placeholder="NOMBRE CENTRO" style="text-transform:uppercase; width:300px" maxlength="30">
				</td>	
			</tr>
			<tr>
				<td></td>	
				<td style="text-align:right;">
					<button id="btn_BuscarCentro" class="btn btn-primary btn-small icon-search" type="button">
						Buscar
					</button>
				</td>
			</tr>
		</table>
		<table>
			<tr>
				<td >
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