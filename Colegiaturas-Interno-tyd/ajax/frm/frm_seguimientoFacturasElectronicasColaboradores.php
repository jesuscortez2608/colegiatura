<?php
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = 'Colegiaturas';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
?>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_seguimientoFacturasElectronicasColaboradores.js"></script>
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>

<style type="text/css" media="screen">
       th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
	div.itemdiv.dialogdiv::before {
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		background-color: #ffffff;
		border-color: #ffffff;
		border-image: none;
		border-style: none;
		border-width: 0 0px;
		bottom: 0;
		content: "";
		display: none;
		left: 19px;
		max-width: 1px;
		position: absolute;
		top: 0;
		width: 1px;
	}
	
	.itemdiv.dialogdiv > .body {
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		border-color: #dde4ed;
		border-image: none;
		border-style: solid;
		border-width: 1px 1px 1px 2px;
		margin-right: 1px;
		padding: 3px 7px 7px;
		left: -40px;
		width: 95%;
	}
	#div_datos, #div_filtros {
		// height:30px;
		// border: 0.1px solid black;
	}
</style>

<div class="page-content">
	<div class="form-horizontal">
		<div class="row-fluid">
			<div class="span12" id="div_MostrarMensaje"></div>
			<div class="span3 right">
				<div id="div_Notificacion"></div>
			</div>
		</div>
		<div class="row-fluid" id="sh-info-colab">
			<div id="div_datos" class="span12;page-header position-relation" style="background-color:#307ECC;color:#FFFFFF; Cursor: pointer;">
			
				<h4>Datos del Colaborador <b id="arrow-info-colab" class="arrow icon-angle-right"></b></h4>
			</div>
		</div>
		<div class="row-fluid" id="info-colab">
			<div class="span4">
			<br>
				<div class="control-group">
					<label class="control-label" for="txt_SueldoMensual" >Sueldo Mensual:</label>
					<div class="controls">
						<input class="span6" id="txt_SueldoMensual" type="text" style="text-align:right;" readonly />
					</div>	<br>
					<label class="control-label" for="txt_AcumFactPag">Acum.Facturas Pagadas:</label>
					<div class="controls">
						<input class="span6" id="txt_AcumFactPag" type="text"  style="text-align:right;" readonly />
					</div><br>
				</div>
			</div>
			<div class="span4">
			<br>
				<div class="control-group">
					<label class="control-label" for="txt_TopeProp" >Tope Anual Proporcional:</label>
					<div class="controls">
						<input class="span6" id="txt_TopeProp" type="text" style="text-align:right;" readonly />
					</div>	<br>
					<label class="control-label" for="txt_TopeRest" >Tope Proporcional Restante:</label>
					<div class="controls">
						<input class="span6" id="txt_TopeRest" type="text" style="text-align:right;" readonly />
					</div>
				</div>
			</div>
			<div class="span4">
			<br>
				<div class="control-group">
					<label class="control-label" for="txt_TopeMensual" >Tope Mensual:</label>
					<div class="controls">
						<input class="span6" id="txt_TopeMensual" type="text" style="text-align:right;" readonly />
					</div>	
				</div>
			</div>
		</div>
		<div>&nbsp;</div>
		<!--hr-->
		<div class="row-fluid">
			<!--div class="span12;page-header position-relation" style="background-color:#438EB9;color:#FFFFFF"-->
			<div id="div_filtros" class="span12;page-header position-relation" style="background-color:#307ECC;color:#FFFFFF">
				<h4>Filtros</h4>
			</div>
		</div>
		<div class="row-fluid">
		<br>
			<div class="span5">
				<label class="control-label" for="form-field-1">Estatus:</label>
				<div class="controls">
					<select class="span12" id="cbo_Estatus" tabindex="1"></select>
				</div>
				<br>
				<label class="control-label" for="txt_FechaIni">Fecha Inicial:</label>
				<input type="hidden" id="txt_Fecha" name="txt_Fecha"  value="<?php echo date('d/m/Y'); ?>" >
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaIni" tabindex="3" class="input-small" readonly value="<?php $datestring=date('Y-m-d') . ' first day of last month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>"/> 
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>
			<div class="span4">
				<label class="control-label" for="form-field-1">Ciclo Escolar:</label>
				<div class="controls">
					<select class="span12" id="cbo_CicloEscolar" tabindex="2"></select>
				</div><br>
				<label class="control-label" for="txt_FechaFin">Fecha Final:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" readonly value="<?php echo date('d/m/Y'); ?>" tabindex="4"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>
		</div>
		<div class="row-fluid">
			<div class="span12">
				<button class="btn btn-primary btn-small pull-right" id="btn_consultar" tabindex="5">
					<i class="icon-search bigger-110"></i>Consultar
				</button>
			</div>
		</div>
		<br>
		<div class="row-fluid">
			<div class="span12">
				<div id="contenedor_gd_Facturas">
					<table id="gd_Facturas"></table>
					<div id="gd_Facturas_pager"></div>
				</div>
				<div id="cont_rechazo">
					<br>
					<span><FONT FACE="arial" SIZE=4>Motivo rechazo:</FONT></span>
					
					<textarea class="span12 limited " id="txt_MotivoRechazo"  style="resize:none;text-transform:uppercase;" maxlength="300" readonly></textarea>
				</div>
			</div>
		</div>		
	</div>
	<!-- ---------------VER FACTURA ------>
	<input type="button" id="btn_ver" name="btn_ver" value="Modal" style="display:none;"/>
	
	<div id="cnt_ver_factura" style="width:1800px;height:900px;display:none;" data-keyboard="false">
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
		<input type="hidden" id="idfactura" name="idfactura" value=""/>
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
	<!-- ---------FIN VER FACTURA ------>
</div>
		
<div class="modal fade" id="dlg_Blog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                 <h4 class="modal-title"><i class=" icon-comments-alt bigger-110"></i> B L O G</h4>
            </div>
            <div class="modal-body">
				<div class="form-horizontal">
					<div class="span12">
						<div class="widget-box ">
							<div class="widget-body">
								<div class="widget-main no-padding">
									<div class="dialogs span12" id="div_Blog">
										
									</div>
								</div><!--/widget-main-->
							</div><!--/widget-body-->
						</div><!--/widget-box-->
					</div><!--/span-->	
				</div>
			</div>
            <div class="modal-footer">
				<form id="fmComentario" autocomplete="off" name="fmComentario" action="ajax/json/json_fun_grabar_blog_aclaraciones.php" method="POST" enctype="multipart/form-data">
					<input type="hidden" id="session_name1" name="session_name1">
					<input type="hidden" id="hid_factura" name="hid_factura">
					<input type="hidden" id="hid_empleado" name="hid_empleado">
					<!--<textarea class="span12 limited" id="txt_Observaciones" placeholder="ESCRIBIR COMENTARIO ..." maxlength="300" style="resize:none;text-transform:uppercase;"></textarea>-->
					<!--<input placeholder="ESCRIBIR COMENTARIO ..." type="text" name="txt_mensaje" id="txt_mensaje" class="width-75 textNumbersOnly" style="text-transform:uppercase;" maxlength="300" />-->
					<textarea name="txt_mensaje" id="txt_mensaje" placeholder="ESCRIBIR COMENTARIO ..." rows="1" oninput="autoGrow(this)" class="width-75" style="text-transform:uppercase;" ></textarea>
					
					<button class="btn btn-small btn-primary no-radius" id="btn_EnviarComentario">
						<i class="icon-share-alt"></i>
						<span class="hidden-phone">Enviar</span>
					</button>
				</form>
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>
<!--div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:900px; height:350px; position:center;"-->

<!--div class="modal fade" id="dlg_Blog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true"-->
<!--div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width: 90%; left: 350px; height: 300px;"-->
<div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:50%; left: 40%; vertical-align: middle;" data-backdrop="static">
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
					</div>
				</div>
			</div>	
		</div>
	</div>
	<div class="modal-footer">
	</div>
</div>
<form id="frm_descarga_zip" name="frm_descarga_zip" method="POST" action="ajax/proc/proc_descargar_zip.php" enctype="multipart/form-data">
	<input type="hidden" id="txt_ciclo" name="txt_ciclo" />
	<input type="hidden" id="txt_archivo1" name="txt_archivo1" />
	<input type="hidden" id="txt_archivo2" name="txt_archivo2" />
	<input type="hidden" id="txt_empleado" name="txt_empleado" />
</form>
	<input type="hidden" id="hid_idu_usuario" name="hid_idu_usuario" value="<?php echo $iUsuario;  ?>"/>

