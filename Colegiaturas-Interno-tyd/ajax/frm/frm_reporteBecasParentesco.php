<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/frm_reporteBecasParentesco.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<div class="row-fluid">
		<form class="form-horizontal">
			<div class="span12;page-header position-relative">

				<div class="span6 control-group">
				
					<!--Ruta de pago-->
					<label class="control-label" >Ruta de Pago:</label>
					<div class="controls">
						<select id="cbo_rutaPago" ></select>
					</div>
					<br>
					
					<!--Region-->
					<label class="control-label" >Región:</label>
					<div class="controls">
						<select id="cbo_Region" ></select>
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
					
					<!--Tipos de deduccion-->
					<label class="control-label" >Tipos de Deducción:</label>
					<div class="controls">
						<select id="cbo_tipoDeduccion" ></select>
					</div>
					<br>
					
					<!--Empresa-->
					<label class="control-label">Empresa:</label>
					<div class="controls">
						<select id="cbo_Empresa"></select>
					</div>
					
				</div>
					
				<div class="span6 control-group">
				
					<!--Escolaridad-->
					<label class="control-label" >Escolaridad:</label>
					<div class="controls">
						<select id="cbo_Escolaridad" ></select>
					</div>
					<br>
							
					<!--Parentesco-->
					<label class="control-label" >Parentesco:</label>
					<div class="controls">
						<select id="cbo_Parentesco" ></select>
					</div>
					<br>
					
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
				</div>
			</div>
		</form>
	</div>
	<div class="row-fluid">
		<div class="span12">
			<!--Boton consultar-->
			<div class="controls">
				<button id="btn_consultar" class="btn btn-small btn-primary pull-right">
				<i class="icon-search bigger-110"></i>Consultar</button>
			</div>
		</div>
	</div>
	<div class="row-fluid">
		<div class="span12">
			<!--Grid del reporte-->
			<div class="control-group">
			<br>
				<div id="gridParentescoEscolaridad">
					<table id="gridParentescoEscolaridad-table"></table>
					<div id="gridParentescoEscolaridad-pager"></div>
				</div>
			</div>
		</div>
	</div>
	
</div>