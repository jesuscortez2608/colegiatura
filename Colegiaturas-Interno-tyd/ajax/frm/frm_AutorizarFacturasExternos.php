<?php

header('X-Frame-Options: SAMEORIGIN');
header("Content-type:text/html;charset=utf-8;");
header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>

<!--[if lte IE 8]>
  <link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->

<script type="text/javascript" src="files/js/frm_AutorizarFacturasExternos.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<div class="row-fluid">
		<div class="span12">
			<div class="form-horizontal">				
				<div class="row-fluid">
					<div class="span12" id="div_MostrarMensaje"></div>
					<div class="span3 right">
						<div id="div_Notificacion_G"></div>
					</div>
				</div>				
			</div>
			<div class="row-fluid">
				<div class="span8">
					<div id="contenedor_gd_Facturas">
						<table id="gd_Facturas"></table>
						<div id="gd_Facturas_pager"></div>
					</div>
					<br>					
				</div>	
			</div>
			<div class="row-fluid">
				<div class="span6" id="cnt_opciones_gerente" >						
					<button id="btn_ver_factura" class="btn btn-small btn-primary">
						<i class=" icon-search smaller-200"></i>
						Ver Factura 
					</button>
				</div>
				<div class="span6" id="cnt_opciones_gerente" >	
					<button id="btn_autorizar_factura" class="btn btn-small btn-success">
						<i class=" icon-check smaller-200"></i>
						Autorizar 
					</button>
					<button id="btn_cancelar_factura" class="btn btn-small btn-danger">
						<i class=" icon-remove smaller-200"></i>
						Rechazar 
					</button>
				</div>
			</div>
		</div>		
	</div>
	<!--------VER FACTURA----------------->
	<input type="button" id="btn_ver" name="btn_ver" value="Modal" style="display:none;"/>
	
	<div id="cnt_ver_factura" style="width:1800px;height:900px;display:none;">
		<style>
			.qrcode {
				width: auto\9;
				height: auto;
				/* max-width: 100%; */
				vertical-align: middle;
				border: 0;
				width: 135px;
				-ms-interpolation-mode: bicubic;
			}
		</style>
		
		<input type="hidden" id="nIsFactura" name="nIsFactura" value=""/>
		<!--<input type="hidden" id="sFacFiscal" name="sFacFiscal" value=""/>-->
		<input type="hidden" id="idfactura" name="idfactura" value=0/>
		<input type="hidden" id="sFilename" name="sFilename" value=""/>
		<input type="hidden" id="sFiliePath" name="sFiliePath" value=""/>
		
		<div class="widget-box">
			<div class="widget-header widget-header-small">
				<h5 class="lighter"><b id="b_titulo"></b></h5>
			</div>	
			<div class="widget-body">
				<div class="widget-main">
					<div id="div_contenido">
					</div>
					<div class="hr hr-double"></div>
				</div>	
			</div>
		</div>
	</div>
	<!-----------FIN VER FACTURA----------------->
	<div id="div_cargando" class="ui-widget-overlay ui-front" style="display: none;">
		<div class="ui-dialog-titlebar ui-widget-header ui-corner-all ui-helper-clearfix">
			<span class="ui-dialog-title" id="ui-id-2">
				<div class="widget-header widget-header-small">
					<h4 class="smaller">
						<i class="icon-coffee"></i>
							Cargando...
					</h4>
					<div id="div_load" class="progress progress-success progress-striped  active" data-percent="0%">
						<div id="div_loading" class="bar" style="width: 0%;"></div>
					</div>
				</div>
			</span>
		</div>
	</div>

	<!--div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:900px; height:350px; position:center;"-->
	<div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:auto; left: 650px; height: 300px;" data-backdrop="static">
		<div class="modal-header widget-header" >
			<button type="button" class="close" data-dismiss="modal">&times;</button>			
			<h4 class="black bigger" ><i class="icon-group "></i>&nbsp;Beneficiarios</h4>
		</div>
		<div class="modal-body">
			<div class="row-fluid ">
				<div class="span12">
					<div class="control-group">
						<div id="contenedor_gd_BeneficiariosFactura">
							<table id="gd_BeneficiariosFactura"></table>
							<div id="gd_BeneficiariosFactura_pager"></div>
						</div>
					</div>
				</div>	
			</div>
		</div>
	</div>
</div>

	<div id="dlg_JustificacionRechazo" class="modal hide" tabindex="-1" style="width: 30%; left: 750px; height:300px;" data-backdrop="static">
		<div class="modal-header widget-header">
			<button type="button" class="close" data-dismiss="modal">&times;</button>
			<h4 class="black bigger"><i class="icon-edit"></i>&nbsp;Motivo de Rechazo</h4>
		</div>
		<div class="modal-body">
			<div class="row-fluid">
				<div class="span12">
					<div class="control-group">
						<div id="JustificacionRechazo">
							<label class="control-label" for="form-field-1"><b>Motivo:</b></label>
								<div class="controls">
									<select class="span10" id="cbo_motivo_rechazo" tabindex="1"></select>
								</div></br>
							<label class="control-label" for="form-field-2"><b>Justificacion:</b></label>
								<textarea id="txt_Justificacion_Rechazo" class="textNumbersOnly" style="text-transform: uppercase; resize: none; width: 520px; height: 60px" maxlength="300" tabindex="2"/>
							<div id="Guardar_Justificacion" align="right">
								<button id="btn_rechazar" class="btn btn-small btn-danger"><i class="icon-remove" tabindex="3"></i> Rechazar</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

<input type="hidden" id="hid_anio_actual" name="hid_anio_actual" value="<?php echo date('Y'); ?>"/>
<div id="cnt_busquedaAFG" style="display:none"/>
<div id="cnt_busquedaAFG2" style="display:none"/>

<form id="frm_descarga_zip" name="frm_descarga_zip" method="POST" action="ajax/proc/proc_descargar_zip.php" enctype="multipart/form-data">
	<input type="hidden" id="txt_ciclo" name="txt_ciclo" />
	<input type="hidden" id="txt_archivo1" name="txt_archivo1" />
	<input type="hidden" id="txt_archivo2" name="txt_archivo2" />
	<input type="hidden" id="txt_empleado" name="txt_empleado" />
</form>
<input type="hidden" id="hid_idu_usuario" name="hid_idu_usuario" value="<?php echo $iUsuario;  ?>"/>