<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>
<!-- VULNERABILIDADES -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>
<!-- VULNERABILIDADES -->

<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->			
<!--page specific plugin scripts-->
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_configuracionEscuelas-Escolaridad.js"></script>
<!--script type="text/javascript" src="files/js/frm_configuracionEscuelas-Escolaridad_PRUEBA.js"></script-->
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<style type="text/css">
	.chosen-container-multi .chosen-choices{
		overflow-y: auto;
		height: 110px !important;
		text-transform:uppercase;
	}
	.chosen-container-single .chosen-single{
		overflow: none;
	}
	// #textbox{text-transform:uppercase}
</style>

<div class="page-content">
	<div class="form-horizontal">
		
		<div class="row-fluid">
			<div class="span12">
				<div class="control-group">	
					<label class="control-label" >Estado:</label>
					<div class="controls">
						<div style="float: left">
							<select id="cbo_estado" class="chosen-select"  data-placeholder="SELECCIONE" tabindex="1">
								<option value="-1">SELECCIONE</option>
							</select>  
						</div>					
					</div>	
				</div>
				<div class="control-group">	
					<label class="control-label" >Municipio:</label>
					<div class="controls">
						<div style="float: left">
							<select id="cbo_municipio" class="chosen-select"  data-placeholder="SELECCIONE" tabindex="2">
							<option value="-1">SELECCIONE</option>
							<!--option value="0">N/A</option-->
							</select>  
						</div>					
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Localidad:</label>
					<div class="controls">
						<div style="float: left">
							<select id="cbo_localidad" class="chosen-select" data-placeholder="SELECCIONE" tabindex="3">
							<option value="-1">SELECCIONE</option>
							<!--option value="0">N/A</option-->
							</select>  
						</div>
					</div>
				</div>
				<div class="control-group">	
					<label class="control-label" >Tipo Escuela:</label>
					<div class="controls">
						<div style="float: left">
							<select id="cbo_tipoEscuela" class="chosen-select"  data-placeholder="" tabindex="4">
							<option value="0">TODOS</option>
							<option value="1">PÚBLICA</option>
							<option value="2">PRIVADA</option>
							</select>  
						</div>						
					</div>	
				</div>				
				<div class="control-group">	
					<label class="control-label" >Tipo Búsqueda:</label>
					<div class="controls">
						<div style="float: left">
							<select id="cbo_tipoBusqueda" class="chosen-select" tabindex="5">
							<option value="1">NOMBRE DE LA ESCUELA</option>
							<option value="2">RFC / CLAVE SEP</option>
							</select>  
						</div>						
						&nbsp;&nbsp;&nbsp;<input id="txt_escuela" class="span5" type="text" placeholder=" " style="text-transform:uppercase;" tabindex="6">
						<button class="btn btn-primary btn-small" onclick="return false;" id="btn_buscar" tabindex="7">
							 <i class=" icon-search bigger-110"></i>Buscar
						</button>
					</div>	
				</div>
			</div>
		</div>
		
		<div class="row-fluid">
			<div class="span12">
				<div class="control-group">
					<div id="gridEscuelas">
						<table id="gridEscuelas-table"></table>
						<div id="gridEscuelas-pager"></div>
						<label class="lbl"><b>Observaciones:</b></label>
						<div class="control-group">
							<textarea class="span12" id="txt_Motivo" style="resize:none" disabled="disabled" maxlength="300" style="text-transform:uppercase;"></textarea>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Agregar modal -->
<!--data-keyboard="false"-->
<div id="dlg_Agregar" class="modal hide" tabindex="-1" style="width:500px; height:auto; position:fixed;" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" id="Titulo_Modal"><i class="icon-file-text-alt "></i>&nbsp;Agregar Escuela</h4>
	</div>
	<div class="modal-body">
		<table width="450"  cellpadding="3">
			<tr>
				<div class="control-group" hidden>
					<label class="control-label"><b>Tipo de Escuela</b></label>
					<div class="controls">
						<td align="right" width="120px">
							<label>
								<input type="radio" id="radioPrivada" name="opcionRadio" checked hidden> <!--&nbsp;&nbsp;Privada&nbsp;&nbsp;&nbsp;&nbsp; -->
							</label>
						</td>
						<td>
							<label>
								<input type="radio" id="radioPublica" name="opcionRadio" hidden> <!--&nbsp;Pública&nbsp; -->
							</label>
						</td>
					</div>
				</div>
			</tr>
			<tr>
				<td align="right">Estado:&nbsp;</td>
				<td>
					<div style="float: left">
						<select id="cbo_estado_agregar" class="chosen-select"  data-placeholder="SELECCIONE">
						<option value="-1">SELECCIONE</option>
						</select>  
					</div>
				</td>
			</tr>
			<tr>
				<td align="right">Municipio:&nbsp;</td>
				<td >
					<div style="float: left">
						<select id="cbo_municipio_agregar" class="chosen-select"  data-placeholder="SELECCIONE">
						<option value="-1">SELECCIONE</option>
						<!--option value="0">N/A</option-->
						</select>  
					</div>					
				</td>
			</tr>
			<tr>
				<td align="right">Localidad:&nbsp;</td>
				<td>
					<div style="float: left">
						<select id="cbo_localidad_agregar" class="chosen-select"  data-placeholder="SELECCIONE">
						<option value='-1'>SELECCIONE</option>
						<!--option value="0">N/A</option-->
						</select>  
					</div>						
				</td>
			</tr>
			<tr>
				<td align="right">RFC:&nbsp;</td>
				<td ><input class="span6 textNumbersOnly" id="txt_RFC" type="text" maxlength="13" style="text-transform:uppercase;"  maxlength="20"></td>
			</tr>
			<tr>
				<td align="right">Nombre:&nbsp;</td>
				<td><input class="span12 textNumbersOnly" id="txt_nombre" type="text" style="text-transform:uppercase;" maxlength="100"></td>
			</tr>
			<tr>
				<td align="right">Escolaridad:&nbsp;</td>
				<td>
					<div style="float: left">
						<select id="cbo_escolaridad_agregar" class="chosen-select"  data-placeholder="">
						<option value=""></option>
						</select>  
					</div>
					
				</td>
			</tr>
			<tr>
				<td align="right" >Carrera:&nbsp;</td>
				<td>
					<!--
					<select id="cbo_carrera" class="span12">
					</select>
					-->
					<div style="float: left">
						<select id="cbo_carrera" class="chosen-select"  data-placeholder="" disabled>
						<option value=""></option>
						</select>  
					</div>
				</td>
			</tr>
			<tr>
				<td></td>
				<td >
					<label><input id="chkbx_eduEspecial" type="checkbox"/> &nbsp;Educación Especial</label>
					<label><input type="checkbox" id="chkbx_pdf" />&nbsp;PDF</label>
					<label><input type="checkbox" id="chkbx_notaCredito" />&nbsp;Nota de Crédito</label>
				</td>
			</tr>
			<!--
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			-->
		</table>
	</div>
	<div class="modal-footer">
		<div align="center">
			<button class="btn btn-small btn-primary" id="btn_aceptarmod">
			<i class="icon-save"></i>Guardar</button>
			<button class="btn btn-small btn-danger" id="btn_salirmod">
			<i class="icon-remove"></i>Salir</button>
		</div>
	</div>
</div>

<!-- Modal de Observaciones -->
<!--div id="dlg_Observaciones" class="modal hide modal-lg" tabindex="-1" style="width:550px; vertical-align: middle;" data-backdrop="static"-->
<!--div id="dlg_Observaciones"  class="modal hide modal-lg" tabindex="-1" style="width: 35%; vertical-align: middle;" data-backdrop="static"-->
<div id="dlg_Observaciones" class="modal hide modal-lg" tabindex="-1" style="width: 35%;vertical-align:middle;" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">&times;</button>
		<h4 class="black bigger"><i class="icon-file-text-alt"></i>&nbsp;Captura Observaciones</h4>
	</div>
	<div class="modal-body">
		<div class="row-fluid">
			<div class="form-horizontal">
				<div class="control-group">
					<div class="span6">
						<label class="control-label" for="txt_Motivos">Observaciones:</label>
						<div class="controls">
							<textarea class="span8 textNumbersOnly" id="txt_Motivos" maxlength="200" style="resize:none; width:400px; text-transform:uppercase;"></textarea>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!--table>
			<tr>
				<td align="right">Observaciones:&emsp;</td>
				<td><textarea class="span8 textNumbersOnly" id="txt_Motivos" maxlength="300" style="resize:none; width:400px; text-transform:uppercase;"></textarea></td>
			</tr>
		</table-->
	</div>
	<div class="modal-footer">
		<div align="right">
			<button class="btn btn-small btn-primary" id="btn_aceptar_observaciones">
			<i class="icon-save"></i>Guardar</button>
			<button class="btn btn-small btn-danger" id="btn_salir_observaciones">
			<i class="icon-remove"></i>Salir</button>
		</div>
	</div>
</div>