<?php
    header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = 'Colegiaturas';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
?>

<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_reporteEmpleadosEspeciales.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="span12; form-horizontal">
	<div class="span12">
		<div class="span8">
			<div class="control-group">
				<label class="control-label">Colaborador:</label>
				<div class="controls">
					<input type="text" id="txt_numEmp" class="span4 numbersOnly" tabindex="1" maxlength="8"/>
					<input type="text" id="txt_nomEmp" class="span6 textOnly" style="text-transform:uppercase" readonly maxlength="80" />
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Por Fecha:</label>
				<div class="controls">
					<input class="ace ace-checkbox-2" id="chkbx_fecha" type="checkbox" name="form-field-checkbox" style="width=100px" />
					<span class="lbl" tabindex="2"></span>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Fecha Inicial:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaInicio" class="input-small" tabindex="3" readonly value="<?php echo date('01/m/Y'); ?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Fecha Final:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" tabindex="3" readonly value="<?php echo date('d/m/Y'); ?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>			
		</div>
		<div class="span11" align="right">
			<div class="controls">
				<button class="btn btn-small btn-primary" id="btn_Consultar" tabindex="5">
					<i class="icon-search bigger-110"></i>Consultar
				</button>
			</div>
			<br>
		</div>		
		<div class="span11">
			<div class="control-group">
				<div id="gridEmpEspeciales">
					<table id="gridEmpEspeciales-table"></table>
					<div id="gridEmpEspeciales-pager"></div>
				</div>
				<br>
				<label class="lbl"><b>Observaciones:</b></label>
				<textarea class="span12" id="txt_Motivo" style="resize:none;text-transform:uppercase" readonly disabled="disabled"></textarea>
			</div>
		</div>
	</div>
</div>