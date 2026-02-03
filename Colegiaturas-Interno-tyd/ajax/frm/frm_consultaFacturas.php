<?php
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload; Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Colegiaturas"); 
	session_start();
?>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_consultaFactura.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>
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
<div class="span12; page-header position-relative; form-horizontal">
	<div class="span12">
		<div class="span6">
			<div class="control-group">
				<label class="control-label">Estatus:</label>
				<div class="controls">
					<select id="cbo_estatus" tabindex="1"></select>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Folio:</label>
				<div class="controls">
					<input type="text" id="txt_Folio" class="span7 textNumbersOnly" style="text-transform:uppercase" maxlength="40" tabindex="2" />
				</div>
			</div>
		</div>
		<div class="span6">
		<!--
			<div class="control-group">
				<label class="control-label">Por Fecha:</label>
				<div class="controls">
					<input class="ace ace-checkbox-2" id="chkbx_fecha" type="checkbox" name="form-field-checkbox" style="width=100px">
					<span class="lbl" tabindex="3"></span>
				</div>
			</div>
		-->
			<div class="control-group">
				<label class="control-label"> Fecha Inicial: </label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaIni" class="input-small" readonly tabindex ="4" value="<?php $datestring=date('Y-m-d') . ' first day of last month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>">
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>			
			</div>
			<div class="control-group">
				<label class="control-label"> Fecha Final: </label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" readonly tabindex="5" value="<?php echo date('d/m/Y'); ?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>			
			</div>
			<div class="control-group">
				<div class="controls">
					<button id="btn_consultar" class="btn btn-small btn-primary" tabindex="6">
						<i class="icon-search bigger-110"></i>Consultar
					</button>&emsp;
					<!--<button  class="btn btn-success btn-small" type="button" id="btn_NuevaConsulta" tabindex="7">
						<i class="icon-refresh  bigger-110"></i>Otra Consulta
					</button>
					-->
				</div>
			</div>
		</div>
	</div>
	<div class="span11">
		<div class="row-fluid">
			<div id="gridConsulta">
				<table id="gridConsulta-table"></table>
				<div id="gridConsulta-pager"></div>
			</div>	
		</div>	
		<div id="Observaciones" style="display:none">
			<h5>Observaciones:</h5>
			<div class="control-group">
			   <textarea class="span12" id="txt_observaciones" style="resize:none" readonly maxlength="300" tabindex="8"></textarea>
			</div>
		</div>
	</div>
	
</div>

<!---<div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:1150px; height:350px; position:left; left:350px" >-->

 <!--div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width: 58%; left: 800px; height: 300px;"-->
 <div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:50%; left: 40%; vertical-align: middle;" data-backdrop="static">
	<div class="modal-dialog modal-lg">
		<div class="modal-header widget-header" >
			<button type="button" class="close" data-dismiss="modal">&times;</button>			
			<h5 class="black bigger"><i class="icon-group "></i>&nbsp;<strong>Beneficiarios Factura</strong></h5>
		</div>
		<div class="modal-body">
			<div class="row-fluid ">
				<div class="span12">
					<div class="control-group">
						<div id="contenedor_gd_BeneficiariosFactura">
							<table id="gd_BeneficiariosFactura"></table>
						</div>
					</div>
				</div>	
			</div>
		</div>
	</div>	
</div>