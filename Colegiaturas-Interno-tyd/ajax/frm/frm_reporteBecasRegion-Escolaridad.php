<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>
<script type="text/javascript" src="files/js/frm_reporteBecasRegion-Escolaridad.js"></script>

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
			<div class="span6">
				<label class="control-label" >Ruta de Pago:</label>
				<div class="controls">
					<select id="cbo_rutaPago" ></select>
				</div>
				<br>
			</div>
			<div class="span6">
				<!--Tipos de deduccion-->
				<label class="control-label" >Tipos de Deducción:</label>
				<div class="controls">
					<select id="cbo_tipoDeduccion" ></select>
				</div>
				<br>
			</div>
		</div>
		
		<div class="row-fluid">
			<div class="span6">
				<!--Estatus-->
				<label class="control-label" >Estatus:</label>
				<div class="controls">
					<select id="cbo_Estatus" ></select>
				</div>
				<br>
			</div>
			<div class="span6">
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
			</div>
		</div>
		
		<div class="row-fluid">
			<div class="span6">
				<!-- Tipo de Escuela -->
				<label class="control-label">Empresa:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<select id="cbo_empresa">
						</select>
					</div>
				</div>
				<br>
			</div>
			<div class="span6">
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
		</div>
		
		<div class="row-fluid">
			<div class="span12">
				<!--Consultar-->
				<button id="btn_consultar" class="btn btn-small btn-primary pull-right">
					<i class="icon-search bigger-110"></i>Consultar
				</button>
			</div>
		</div>
		<hr>
		
		<div class="row-fluid">
			<span class="span12">
				<div id="gridReporteRegionEscolaridad">
					<table id="gridReporteRegionEscolaridad-table"></table>
					<div id="gridReporteRegionEscolaridad-pager"></div>
				</div>
			</span>
		</div>
	</form>
</div>