<?php
	header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/frm_ReporteFacturaAjuste.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<form class="form-horizontal">
		<div class="row-fluid">
			<div class="span6 control-group">
			
				<!--Ruta Pago-->
				<label class="control-label">Ruta de Pago:</label>
				<div class="controls">
					<select id="cbo_rutaPago"></select>
				</div>
				<br>
				
				<!--Estatus-->						
				<label class="control-label">Escolaridad:</label>
				<div class="controls">
					<select id="cbo_Escolaridad"></select>
				</div>
				<br>

				<!--Region-->		
				<label class="control-label">Región:</label>
				<div class="controls">
					<select id="cbo_Region"></select>
				</div>
				<br>
				
				<!--Ciudad-->	
				<label class="control-label">Ciudad:</label>
				<div class="controls">
					<select id="cbo_Ciudad">
						<option value='0'>TODAS</option>
					</select>
				</div>
				<br>
				
				<label class="control-label">Tipo Deducción:</label>
				<div class="controls">
					<select id="cbo_tipoDeduccion"></select>
				</div>
				<br>
					
			</div>
			
			<div class="span6 control-group">
				<div>
					<input id="rdbtn_ciclo" name="form-field-radio" type="radio" class="ace" style="align:right"/>
					<span class="lbl">Por Ciclo</span>
				</div>
				<!--Ciclo Escolar-->
				<label class="control-label">Ciclo Escolar:</label>
				<div class="controls">
					<select id="cbo_cicloEscolar" disabled></select>
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
				
				<!-- Empleado -->
				<label class="control-label">Colaborador:</label>
					<div class="controls">
						<input type="text" id="txt_Empleado" class="input-small"/>						
					</div>
				<br>
				
				<!-- Boton Consultar -->
				<div class="controls">
					<button id="btn_consultar" class="btn btn-small btn-primary">
					<i class="icon-search bigger-110"></i>Consultar</button>
				</div>

			</div>
		</div>		
		
		<div class="row-fluid">
			<div class="span12">				
				<div class="control-group">
					<table id="gridReporteNivelEstudio"></table>
					<div id="gridReporteNivelEstudio-pager"></div>
				</div>
				<br>
			</div>
		</div>
		
		<!--  REPORTE 
		<form id="formreporte" name="formreporte" action="http://10.27.112.122:8080/colegiaturas/rest/reportes" method="POST">
			<input type="hidden" id="nombre_reporte" name="nombre_reporte" value="rpt_pagos_por_porcentaje"/>
			<input type="hidden" id="id_conexion" name="id_conexion" value="190"/>
			<input type="hidden" id="formato_reporte" name="formato_reporte" value="pdf"/>
			<input type="hidden" id="porcentaje" name="porcentaje" value="80"/>
			<input type="hidden" id="empresa" name="empresa" value="0"/>
			<input type="hidden" id="fecha_inicial" name="fecha_inicial" value="20180101"/>
			<input type="hidden" id="fecha_final" name="fecha_final" value="20180824"/> -->
		</form>
	</form>
</div>