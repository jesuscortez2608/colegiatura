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
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_consultaMovimientosPersonalAdministracion.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }

	#txt_mensaje{
		width: 100%;
		resize: none;
		max-height: 150px;
	}
	
</style>
<div class="page-content">
	<div class="row-fluid">
		<div class="form-horizontal">
			<div class="span12;page-header position-relative" style="background-color:#307ECC; color:#FFFFFF">
				<h4>Datos del Colaborador</h4>
			</div>
			<div class="span12 form-horizontal">
				<div class="span8">
					<div class="control-group">	
					<br>
						<label class="control-label" for="form-input-readonly">Colaborador:</label>			
						<div class="controls">	
							 <form class="form-search">
								<input type="text" class="span3 numbersOnly" id="txt_Numemp"  maxlength="10">
								<input class="span6"   type="text" id="txt_Nombre" readonly >
								<button class="btn btn-info btn-small" onclick="return false;" id="btn_buscarE">
									 <i class="icon-search icon-on-right bigger-110"></i>
								</button>
							</form> 
						</div>
						<label class="control-label" for="form-input-readonly">Centro:</label>
						<div class="controls">
							<input type="text" class="span3" id="txt_Centro"  readonly >      
							<input type="text" class="span7" id="txt_NombreCentro" readonly>
						</div>
					</div>    
				</div>	
				<div class="span4">
					<div class="control-group">
					<br>
						<label class="control-label" for="form-input-readonly">Tope Anual Prop:</label>
						 <div class="controls">	
							<input type="text" class="span10" id="txt_topePropocional" readonly style="text-align:right;">
						 </div><br>
						<label class="control-label" for="form-input-readonly">Tope Mensual:</label>
						 <div class="controls">
							<input type="text" class="span10" id="txt_topeMensual" readonly style="text-align:right;">
						 </div>
					</div>
			   </div>
			</div>
			<div class="span12">
				<div class="span4">
					<div class="control-group row-fluid">	
						<label class="control-label" for="form-input-readonly">Fecha Ingreso:</label>
						<div class="controls">	   
							<input type="text" class="span12" id="txt_fechaIngreso" readonly>
						</div><br>
						<label class="control-label" for="form-input-readonly">Ruta Pago:</label>
						 <div class="controls">
							<input type="text" class="span12" id="txt_rutaPago" readonly>
						 </div><br>
						 <div class="span12">
							<div class="controls">
								 <button class="btn btn-small btn-success" id="btn_Porcentaje" type="button" style="display: none;">
									Porcentaje especial
								</button>
							</div>
						 </div>						
					</div>	
				</div>
				<div class="span4">
					<div class="control-group">	
						<label class="control-label" for="form-input-readonly">Sueldo Mensual:</label>
						<div class="controls">	
							<input type="text" class="span12" id="txt_sueldoMensual" readonly style="text-align:right;"> 
						</div><br>
						<label class="control-label" for="form-input-readonly">Tarjeta:</label>
						 <div class="controls">
							<input type="text" class="span12" id="txt_tarjeta" readonly>
						 </div>
					</div>	
				</div>
				<div class="span4">
					<div class="control-group">	
						<label class="control-label" for="form-input-readonly">Acumulado Fac.Pagada:</label>
						 <div class="controls">
							<input type="text" class="span10" id="txt_acumuladoFacturas" readonly style="text-align:right;">
						 </div><br>
						<label class="control-label" for="form-input-readonly">Tope Restante:</label>
						 <div class="controls">
							<input type="text" class="span10" id="txt_topeRestante" readonly style="text-align:right;">
						 </div>
					</div>	
				</div>
			</div>
		</div>
	</div>
	<div class="row-fluid">
		<div class="form-horizontal">
			<div class="span12;page-header position-relative" style="background-color:#307ECC; color:#FFFFFF">
				<h4>Filtros</h4>
			</div>
			<div class="span12 form-horizontal">	
				<div class="span4">
					<div class="control-group">
					<br>
						<label class="control-label" for="cbo_Estatus">Estatus:</label>			
						<div class="controls">	
							<select id="cbo_Estatus">
							</select>
						</div><br>
						<label class="control-label">Ciclo Escolar:</label>
						<div class="controls">
							<select id="cbo_CicloEscolar">
							</select>
						</div>
					</div>
				</div>     
				<div class="span4">
					<div class="control-group">
					<br>
						<label class="control-label">Región:</label>
						<div class="controls">
							<select id="cbo_Region">
							</select>
						</div><br> 
						<label class="control-label">Ciudad:</label>
						<div class="controls">
							<select id="cbo_Ciudad">
								<option value='0'>TODAS</option>
							</select>
						</div>						
					</div>
				</div>
				<div class="span4">
					<div class="control-group">
						<br>
						<label class="control-label" for="txt_FechaIni">Fecha Inicial:</label>
						<input type="hidden" id="txt_Fecha" name="txt_Fecha"  value="<?php $datestring=date('Y-m-d') . ' first day of last month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>">
						<div class="controls">
							<div class="row-fluid input-append">
								<input type="text" id="txt_FechaIni" class="input-small" readonly value="<?php $datestring=date('Y-m-d') . ' first day of last month'; $dt=date_create($datestring); echo $dt->format('d/m/Y'); ?>">
								<span class="add-on">
									<i class="icon-calendar"></i>
								</span>
							</div>
						</div>	<br>
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
			</div>  
			<div class="span12 form-horizontal">	
				<div class="span4">
					<label class="control-label">Tipo Deducción:</label>
					<div class="controls">
						<select id="cbo_tipoDeduccion">
						</select>
					</div>
				</div>
				<div class="span8">
					<label class="control-label">Centro:</label>
					<div class="controls" >
						<input type="hidden" id="txt_CentroF" >
						<form class="form-search">
							<input type="text" class="span10" id="txt_NombreCentroF" readonly>
							<button class="btn btn-info btn-small" onclick="return false;" id="btn_ayudaCentro">
								 <i class="icon-search icon-on-right bigger-110"></i>
							</button>
						</form> 
					</div>
				</div>
			</div>  
			<div class="span12">
				<div class="span6">
				</div>
				<div class="span6">
					<div class="controls">
						<button class="btn btn-primary btn-small" id="btn_Consultar">
								<i class="icon-search bigger-110"></i>Consultar
							</button>
							<button class="btn btn-success btn-small" id="btn_Otro">
								<i class="icon-refresh bigger-110"></i>Otra Consulta
							</button>
					</div><br>	
				</div>	
			</div>
			<div class="row-fluid">
				<div class="span12">
					<div id="contenedor_gridFacturas" style="">
						<table id="gridFacturas"></table>
						<div id="gridFacturas_pager"></div>
					</div>
					<br>
					<div id="container_totales" style="display: flex;justify-content: flex-end;">
						<label for="txt_importeFactura" style="margin: 0 20px;">Importe Factura:</label>
						<input type="text" id="txt_importeFactura" name="Importe Factura" readonly>
						<label for="txt_importePagado" style="margin: 0 20px;">Importe Pagado:</label>
						<input type="text" id="txt_importePagado" name="Importe Pagado" readonly>
					</div>
					<h5>Motivo:</h5>
					<div class="control-group">
					   <textarea class="span12" id="txt_Motivo" disabled="disabled" style="resize:none"></textarea>
					</div>
				</div>
			</div>	
		</div>
	</div>
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
</div> 
<div id="dlg_Movimientos" style="display:none"/>
<!-- Modal de busqueda de Empleados -->
<div id="dlg_BusquedaEmpleados" class="modal hide" tabindex="-1" style="width:950px;   height:auto; position:top; margin-left: -480px; margin-top: 0px;" data-backdrop="static">
<!--div id="dlg_BusquedaEmpleados" class="modal hide" style="width:auto;   height:auto; position:top; margin-left: auto; margin-top: auto;" -->
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consulta de Colaboradores</h4>
	</div>
	<div class="modal-body">
		<table cellpadding="2">
			<br>
			<tr>
				<td style="width:70px; text-align:right">
					<b>Nombre: </b>
				</td>
				<td>
					<input type="txt" id="txt_nombusqueda" style="text-transform:uppercase; width:140px" class="textOnly" maxlength="50">
				</td>
				<td style="width:120px;text-align:right">
					<b>Apellido Paterno: </b>
				</td>
				<td>
					<input type="txt" id="txt_apepatbusqueda" style="text-transform:uppercase; width:140px" class="textOnly" maxlength="50">
				</td>
				<td style="width:120px; text-align:right">
					<b>Apellido Materno: </b>
				</td>
				<td>
					<input type="txt" id="txt_apematbusqueda" style="text-transform:uppercase; width:140px" class="textOnly" maxlength="50">
				</td>
				<td align="right">
					<!--button id="btn_buscarCOL" class="btn btn-small btn-primary icon-search">Buscar</button-->
					<button id="btn_buscarCOL" class="btn btn-primary btn-small" >
								<i class="icon-search bigger-110"></i>Buscar
							</button>
				</td>
			</tr>
			<tr><td colspan="7">&nbsp;</td></tr>
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
<div id="dlg_AyudaCentro" class="modal hide" tabindex="-1" style="width:450px; position:top; margin-left: -300px; margin-top: 0px;" data-backdrop="static">
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
				<td style="width:200px;text-align:center;" >
					<input type="txt" id="txt_NomCentroBusqueda" placeholder="NOMBRE CENTRO" style="text-transform:uppercase;width:300px;" class="textOnly" maxlength="30">
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

<!-- Modal Beneficiarios por factura-->
<!--div id="dlg_BeneficiariosFactura"  class="modal fade" tabindex="-1" style="width:1150px; height:350px; position:fixed"-->
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
				<input type="hidden" name="txt_TotalB" class="span8" id="txt_TotalB" style="text-align:right" readonly />
			</div>	
		</div>
	</div>
</div>


<!-- Modal Blog-->
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
									<div class="dialogs" id="div_Blog">
										
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
					
					<!-- <input placeholder="ESCRIBIR COMENTARIO ..." type="text" name="txt_mensaje" id="txt_mensaje" class="width-75" style="text-transform:uppercase;" /> -->
					<textarea name="txt_mensaje" id="txt_mensaje" placeholder="ESCRIBIR COMENTARIO ..." rows="1" oninput="autoGrow(this)"></textarea>
					
					<button class="btn btn-small btn-primary no-radius" id="btn_EnviarComentario">
						<i class="icon-share-alt"></i>
						<span class="hidden-phone">Enviar</span>
					</button>
				</form>
            </div>
        </div>
    </div>
</div>
<div id="dlg_Porcentajes"  class="modal hide modal-lg" tabindex="-1" style="width: 55%; left: 35%; vertical-align: middle;" data-backdrop="static">
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Porcentajes Especiales</h4>
	</div>
	<div class="modal-body">
		<div class="row-fluid">
			<div class="form-horizontal">	
				<div class="control-group">
					<div class="span12">
						<table id="gd_Porcentajes"></table>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div id="divexport">
</div>