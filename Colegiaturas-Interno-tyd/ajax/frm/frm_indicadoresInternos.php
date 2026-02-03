<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<script type="text/javascript" src="files/js/frm_indicadoresInternos.js"></script>
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>


<div class="page-header position-relative; form-horizontal">
	<div class="span12" align="center">
		<input id="chk_indicadores" class="ace ace-switch ace-switch-4 On" type="checkbox" onclick="CambioCheck(this)">
		<div class="lbl icon-ok bigger-150" style="width:100px" content="INDICADORES\a0\a0\a0\a0\a0\a0\a0\a0\a0\a0INTERNOS"></div>
	</div>
	<!-- FIRST ONE -->
	<div class="tabbable"> <!-- Only required for left/right tabs -->
		<ul class="nav nav-tabs">
			<li class="active"><a href="#tab1" id="press_tab1" data-toggle="tab"></a></li>
			<li><a href="#tab2" id="press_tab2" data-toggle="tab"></a></li>
		</ul>
		<div class="tab-content">
			<div class="tab-pane active" id="tab1">				
				<div class="tabbable"> <!-- Only required for left/right tabs -->
					<ul class="nav nav-tabs">
						<li class="active"><a href="#tabi1" id="press_tabi1" data-toggle="tab"></a></li>
						<li><a href="#tabi2" id="press_tabi2" data-toggle="tab"></a></li>
					</ul>
					<!-- RADIOS -->
					<div class="span12" align="center">						
						<div class="span2">
							<input type='radio' name='indicadores_radio' class='indicadores_radio' value='1' checked><span> &nbsp;Centro</span>
						</div>
						<div class="span2">
							<input type='radio' name='indicadores_radio' class='indicadores_radio' value='2'><span> &nbsp;Analísta</span>
						</div>
					</div>

					<div class="tab-content">
						<div class="tab-pane active" id="tabi1">
							<div class="span9">								
								<!-- FECHAS -->
								<div class="span8">
									<div class="span6">
										<div class="control-group">
											<label class="control-label" for="cbo_anio_Centro"> Año: </label>
											<div class="controls">
												<div class="row-fluid input-append">
														<select name="cbo_anio_Centro" id="cbo_anio_Centro" class="cbo_anio">
														</select>
												</div>
											</div>
										</div>
									</div>
									
									<div class="span6">
										<label class="control-label" for="cbo_mes_Centro"> Mes: </label>
										<div class="controls">
											<div class="row-fluid input-append">
														<select name="cbo_mes_Centro" id="cbo_mes_Centro">
														</select>
											</div>
										</div>
									</div>
								</div>

								<!-- BOTONES -->
								<div class="span12">
									<div class="span6">
										<label class="control-label" style="text-align:left;">Centro:</label>
										<select class="span8" id="cbo_Centro"></select>
									</div>

									<div class="controls">
										<button class="btn btn-primary btn-small" id="btn_ConsultarCentro">
											<i class="icon-search bigger-110"></i>Consultar
										</button>
										<button class="btn btn-success btn-small" onclick="Limpiar('Centro')">
											<i class="icon-refresh bigger-110"></i>Limpiar
										</button>
									</div>
									<br>
								</div>
							</div>
							<!-- TABLA -->
							<div class="control-group">
								<div class="span12">
									<div id="gridIndicadoresInternosCentro">
									<br>
										<table id="gridIndicadoresCentro-table"></table>
										<div id="gridIndicadoresCentro-pager"></div>
									</div>				
								</div>
							</div>
						</div>
						<div class="tab-pane" id="tabi2">
							<div class="span9">								
								<!-- FECHAS -->
								<div class="span8">
									<div class="span6">
										<div class="control-group">
											<label class="control-label" for="cbo_anio_Colab"> Año: </label>
											<div class="controls">
												<div class="row-fluid input-append">
														<select name="cbo_anio_Colab" id="cbo_anio_Colab" class="cbo_anio">
														</select>
												</div>
											</div>
										</div>
									</div>
									
									<div class="span6">
										<label class="control-label" for="cbo_mes_Colab"> Mes: </label>
										<div class="controls">
											<div class="row-fluid input-append">
														<select name="cbo_mes_Colab" id="cbo_mes_Colab">
														</select>
											</div>
										</div>
									</div>
								</div>

								<!-- BOTONES -->
								<div class="span12">
									<div class="span6">
										<label class="control-label">Colaborador:</label>
										<select class="span8" id="cbo_Colaborador"></select>
									</div>

									<div class="controls">
										<button class="btn btn-primary btn-small" id="btn_ConsultarColab">
											<i class="icon-search bigger-110"></i>Consultar
										</button>
										<button class="btn btn-success btn-small" onclick="Limpiar('Colab')">
											<i class="icon-refresh bigger-110"></i>Limpiar
										</button>
									</div>
									<br>
								</div>
							</div>
							<!-- TABLA -->
							<div class="control-group">
								<div class="span12">
									<div id="gridIndicadoresInternosColab">
									<br>
										<table id="gridIndicadoresColab-table"></table>
										<div id="gridIndicadoresColab-pager"></div>
									</div>				
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			
			<div class="tab-pane" id="tab2">
				<div class="span9">								
					<!-- FECHAS -->
					<div class="span8">
						<div class="span6">
							<div class="control-group">
								<label class="control-label" for="txt_FechaIniFactura"> Fecha Inicial: </label>
								<div class="controls">
									<div class="row-fluid input-append">
											<input type="text" id="txt_FechaIniFactura" class="input-small txt_FechaIni" readonly value="<?php echo date('d/m/Y'); ?>"/>
											<span class="add-on">
												<i class="icon-calendar"></i>
											</span>
									</div>
								</div>
							</div>
						</div>
						
						<div class="span6">
							<label class="control-label"> Fecha Final: </label>
							<div class="controls">
								<div class="row-fluid input-append">
										<input type="text" id="txt_FechaFinFactura" class="input-small txt_FechaFin" readonly value="<?php echo date('d/m/Y'); ?>"/>
										<span class="add-on">
											<i class="icon-calendar"></i>
										</span>
								</div>
							</div>
						</div>
					</div>

					<!-- BOTONES -->
					<div class="span12">
						<div class="span6">
							<label class="control-label" style="text-align:left;">Estatus:</label>
							<select class="span8" id="cbo_Estatus"></select>
						</div>
							<div class="controls">
							<button class="btn btn-primary btn-small" id="btn_ConsultarFactura" onclick="CargargridFactura()">
								<i class="icon-search bigger-110"></i>Consultar
							</button>
							<button class="btn btn-success btn-small"  onclick="Limpiar('Factura')">
								<i class="icon-refresh bigger-110"></i>Limpiar
							</button>
						</div>
						<br>
					</div>
				</div>
				<!-- TABLA -->
				<div class="control-group">
					<div class="span12">
						<div id="gridIndicadoresInternosFactura">
							<br>
							<table id="gridIndicadoresFactura-table"></table>
							<div id="gridIndicadoresFactura-pager"></div>
						</div>				
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<style>

	/* ESTILOS DE SLIDE SUPERIOR */
	input[type=checkbox].ace.ace-switch {
		width: 200px !important;
	}

	input.ace.ace-switch.ace-switch-4[type="checkbox"] + .lbl::before, input.ace.ace-switch.ace-switch-5[type="checkbox"] + .lbl::before {
		content:"\a0\a0\a0\a0\a0\a0\a0\a0\a0\a0\a0\a0\a0 FACTURAS \a0\a0\a0\a0\a0\a0\a0\a0\a0\a0 INDICADORES" !important;
		text-indent: -35px !important;
		width: 200px !important;
	}
	input.ace.ace-switch.ace-switch-4[type="checkbox"] + .lbl::after, input.ace.ace-switch.ace-switch-5[type="checkbox"] + .lbl::after {
		height: 18px !important;
		width: 90px !important;
	}
	input.ace.ace-switch.ace-switch-4[type="checkbox"]:checked + .lbl::after, input.ace.ace-switch.ace-switch-5[type="checkbox"]:checked + .lbl::after {
		left: 110px !important;
	}

	/* FORM */
	.form-horizontal .control-label {
		text-align: left;
		width: 90px;
	}

	.form-horizontal .controls {
		margin-left: 90px;
	}

	.span12 {
		margin-left: 0 !important;
	}

	input.indicadores_radio + span {
		vertical-align: middle;
	}

	/* DATE PICKER */
	div#ui-datepicker-div {
		z-index: 99 !important;
	}

	/* TABLA */
	.jqg-second-row-header{
		background:#365266 !important;
		color: white;
		text-transform: uppercase;
	}

	.jqg-third-row-header{
		background: #75A0CA !important;
	}
	
	.ui-jqgrid-sortable{
		color: black !important;
	}

	tr.ui-jqgrid-labels > th {
		white-space: pre-wrap !important;
	}

	.tab-content {
		border: none !important;
	}

	ul.nav.nav-tabs {
		display: none;
	}

	.ui-th-ltr, .ui-jqgrid .ui-jqgrid-htable th.ui-th-ltr {
		text-align: center !important;
	}

	#gridIndicadoresCentro-pager_center{
		display:none;
	}

	.ui-jqgrid .ui-jqgrid-htable th div {
		height: fit-content !important;
	}

	td#gridIndicadoresCentro-pager_center,td#gridIndicadoresColab-pager_center {
		display: none;
	}
</style>