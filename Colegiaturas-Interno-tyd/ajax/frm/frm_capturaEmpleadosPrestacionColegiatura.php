<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?> 
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/jquery-ui-1.10.3.full.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ui.jqgrid.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-responsive.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-skins.min.css" />


<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_capturaEmpleadosPrestacionColegiatura.js"></script>

<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>


<style type="text/css" media="screen">
	th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:5px;
    }
	#dlg_AyudaEscuelas .modal-body {
		max-height: 500px;
		overflow-y: auto;
		padding: 15px;
		position: relative;
	}
	
</style>

<div class="form-horizontal">
	<br>
	<div class="span12">
		<div class="span8">
			<div class="control-group">
				<label class="control-label" >Colaborador:</label>
				<div class="controls"> 
					<input type="text" class="span3 numbersOnly"  id="txt_Numemp"  placeholder="Núm.Colaborador" tabindex="1" maxlength="8">
					<input type="text" class="span8" id="txt_Nombre" readonly>
						<button class="btn btn-info btn-small" onclick="return false;" id="btn_buscar">
						 <i class="icon-search icon-on-right bigger-110"></i>
					</button>
				</div><br>
				<label class="control-label" >Centro:</label>
				<div class="controls">
					<input type="text" class="span3" id="txt_Centro" readonly>
					<input type="text" class="span8" id="txt_NombreCentro" readonly>
				</div><br>
				<label class="control-label" >Fecha Ingreso:</label>
				<div class="controls">
					<input type="text" class="span3" id="txt_FechaIngreso" readonly>
				</div><br>
				<div class="controls">
					<input class="ace ace-checkbox-2" id="ckb_especial" type="checkbox" >
					<label class="lbl span4" for="ckb_especial" tabindex="2"> Especial</label>
					<input class="ace ace-checkbox-2" id="ckb_limitado" type="checkbox" >
					<label class="lbl span4" for="ckb_limitado" tabindex="3"> Limitado</label>
					<input class="ace ace-checkbox-2" id="ckb_bloquear" type="checkbox" >
					<label class="lbl span4" for="ckb_bloquear" tabindex="4"> Bloquear</label>
					<input type="hidden" id="txt_Puesto">
					<input type="hidden" id="txt_Seccion">
				</div><br>
				<div class="controls">
				<br>
					<button class="btn btn-small btn-primary " id="btn_GuardarColaborador" tabindex="5">
						<i class="icon-save bigger-110"></i>Guardar Colaborador
					</button>
					
					<button class="btn btn-small btn-primary " id="btn_AgregarBeneficiario" tabindex="6">
						<i class="icon-plus bigger-110"></i>Agregar Beneficiario
					</button>
					
					<button class="btn btn-small btn-success" id="btn_Otro" type="button" tabindex="7">
						<i class="icon-user bigger-110"></i>Otro Colaborador
					</button>
					
				</div>
			</div>
		</div>	
	</div>
	<div class="span12">
		<div class="control-group">
			<div id="contenedor_Beneficiarios">
				<table id="gd_Beneficiarios" border=0></table>
				<div id="gd_Beneficiarios_pager"></div>
			</div>
		</div>	
		<!--
		<div class="control-group">
			<button class="btn btn-warning btn-small" id="btn_Modificar" type="button">
				<i class="icon-edit bigger-110"></i>
					Modificar Beneficiario
			</button>
			<button class="btn btn-small btn-primary" id="btn_AgregarEstudio">
				<i class="icon-plus bigger-110"></i>Agregar Estudio
			</button>
		</div>	-->
		<div class="control-group">
		<label class="lbl"><b>Observaciones:</b></label>
			 <textarea class="span10" id="txt_Motivo" style="width:800px;resize:none" disabled="disabled"></textarea>
		</div>
	</div>
	<div class="span12">
		<div class="control-group">
			<div id="contenedor_Detalles">
				<table id="gd_Detalles"></table>
				<div id="gd_Detalles_pager"></div>
			</div>
		</div>	
	</div>	
	<!--
	<div class="span12">
		
		<div class="span6">	
			<div class="control-group">
				<button class="btn btn-small btn-danger" id="btn_Eliminar" type="button">
					<i class="icon-trash bigger-110"></i>
						Eliminar
				</button>
			</div>
		</div>
	</div>
	-->
</div>


<!--Modal para anotar justificacion al momenta de Bloquear o DesBloquear un usuario-->
<div id="dlg_ModalJustificacionBloqueo" class="modal hide fade" tabindex="-1" style="width:560px; height:230px; position:fixed;" data-backdrop="static">
	<div class="modal-header widget-header" data-focus-on="input:first">
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-edit"></i>&nbsp; Justificación</h4>
	</div>
	<div class="modal-body">
		<label id="lblJustificacionBloqueo"></label>
		<textarea id="txt_JustificacionBloqueo" class="textNumbersOnly"
			style="text-transform:uppercase; resize:none; width:515px; height:40px; marging-top:20px"
			maxlength="300" tabindex="1001">
		</textarea>
	</div>
	<div class="modal-footer">
		<div class="span12">
			<div class="span8">
			</div>
			<div class="span4">
				<button class="btn btn-small btn-success" id="btn_GuardarJusticacionBloqueo" type="button" tabindex="1002">
					<i class="icon-check bigger-110"></i>Aceptar
				</button>
			</div>
		</div>	
	</div>	 
</div>

<!--Modal para anotar justificacion al momenta de Marcar o Desmarcar como Especial un usuario-->
<div id="dlg_ModalJustificacionEspecial" class="modal hide fade" tabindex="-1" style="width:560px; height:230px; position:fixed;" data-backdrop="static">
	<div class="modal-header widget-header" data-focus-on="input:first">
		<button type="button" class="close" data-dismiss="modal">&times;</button>
		<h4 class="black bigger" ><i class="icon-edit"></i>&nbsp; Observaciones</h4>
	</div>
	<div class="modal-body">
		<label id="lblJustificacionEspecial"></label>
		<textarea id="txt_JustificacionEspecial" class="textNumbersOnly"
			style="text-transform:uppercase; resize:none; width:515px; height:40px; marging-top:20px"
			maxlength="300" tabindex="2001">
		</textarea>
	</div>
	<div class="modal-footer">
		<div class="span12">
			<div class="span8">
			</div>
			<div class="span4">
				<button class="btn btn-small btn-success" id="btn_GuardarJusticacionEspecial" type="button" tabindex="2002">
					<i class="icon-check bigger-110"></i>Aceptar
				</button>
			</div>
		</div>	
	</div>	 
</div>



<!--div id="dlg_AgregarB" title="Agregar Beneficiario" style="display:none"-->
<div id="dlg_AgregarB"  class="modal  hide fade" tabindex="-1" style="width:530px; height:450px; position:fixed;" data-backdrop="static">
	<div class="modal-header widget-header" data-focus-on="input:first">
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-user "></i>&nbsp;Agregar Beneficiario</h4>
	</div>
	<div class="modal-body">
		<table width="500" border=0>
			<tr>
				<td colspan="2" aling="center"><div id="div_empleado"></div></td>
			</tr>
			<tr>
				<td align="right" width="150"><label>Beneficiario:&nbsp;</label></td>
				<td  >
					<input type="text" id="txt_Beneficiario" style="width:20px" readonly tabindex="3001"/>
				</td>
			</tr>
			<tr>
				<td align="right"><label>Nombre:&nbsp;</label></td>
				<td ><input type="text" class="textOnly" style="text-transform:uppercase; width:280px" id="txt_NombreB"   tabindex="3002" maxlength="45" /></td>
			</tr>
			<tr>	
				<td align="right"><label>Apellido Paterno:&nbsp;</label></td>
				<td ><input type="text" class="textOnly" style="text-transform:uppercase;width:280px" id="txt_ApPat"  tabindex="3003" maxlength="45" /></td>
			</tr>
			<tr>	
				<td align="right"><label>Apellido Materno:&nbsp;</label></td>
				<td ><input type="text" class="textOnly" style="text-transform:uppercase;width:280px" id="txt_ApMat"  tabindex="3004" maxlength="45" /></td>
			</tr>
			<tr>
				<td  align="right">Parentesco:&nbsp;</td>
				<td>
					<select id="cbo_Parentesco" tabindex="3005" style="width:280px">
						 <option value="0">SELECCIONE PARENTESCO</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">Becado Especial:&nbsp; </td>
				<td ><input type="checkbox"  id="ckb_Especial" tabindex="3006" /></td>
				<br>
			</tr>
			<tr height="80">
				<td align="right">
					<label id="lblObservaciones">Observaciones:</label>
					&nbsp;
				</td>
				 <td width="365">
				 <textarea name="txt_Observaciones" class="textNumbersOnly" style="text-transform:uppercase;resize:none; width: 280px;  height: 40px; marging-top:20px"  maxlength="300" id="txt_Observaciones" disabled tabindex="3007"></textarea>
				 </td>
			</tr>
		 </table>  
	</div>	
	<div class="modal-footer">
		<div class="span12">
			<div class="span8">
			</div>
			<div class="span4">
				<button class="btn btn-small btn-primary" id="btn_GuardarB" type="button" tabindex="3008"> <i class="icon-save bigger-110"></i>Guardar </button>
			</div>
		</div>	
	</div>	 
</div>
<!--<div id="dlg_AgregarEstudio" title="Agregar Estudio" style="display:none">-->
<div id="dlg_AgregarEstudio"  class="modal  hide fade" tabindex="-1" style="width:450px; height:300px; position:fixed; " data-backdrop="static">
	<div class="modal-header widget-header" data-focus-on="input:first">
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-book "></i>&nbsp;Agregar Estudio</h4>
	</div>
	<div class="modal-body">
		<input type="hidden" id="txt_idEscuela">
		<input type="hidden" id="txt_clvSEP">
		<table width="400px">
			<tr>
				<td colspan="3"><div id="div_empleadoEstudio"></div></td>
			</tr>
			<tr>
				<td colspan="3"><div id="div_beneficiarioEstudio"></div></td>
			</tr>
			<tr>
				<td align="right">Escuela:&nbsp;</td>
				<td colspan="2">
				<!--
					<input type="text" id="txt_escuelaSeleccion" tabindex="1"  style="width:250px" readonly>
					-->
					<input type="txt"  id="txt_escuelaSeleccion" style="text-transform:uppercase;width:250px"  placeholder="Nombre" readonly tabindex="4001">
					<button class="btn btn-small btn-primary" id="btn_ConsultaEscuela" type="button" data-toggle="modal"> 
					<i class="icon-search bigger-110"></i> 
					</button>
				</td>
				
			<tr>
			
			<tr>
				<td align="right">Escolaridad:&nbsp;</td>
				<td colspan="2">
					<select id="cbo_Escolaridad"  tabindex="4002" style="width:300px">
						<option value="0">SELECCIONE ESCOLARIDAD</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">Grado:&nbsp;</td>
				<td colspan="2">
					<select id="cbo_Grado"  tabindex="4003" style="width:300px">
						<option value="-1">SELECCIONE GRADO</option>
					</select>
				</td>
			
			</tr>
			
		</table>
	</div>	
	<div class="modal-footer">
		<div class="span12">
			<div class="span8">
			</div>
			<div class="span4">
				<button class="btn btn-small btn-primary" id="btn_GuardarEstudio" type="button" tabindex="4004"> 
				<i class="icon-save bigger-110"></i>Guardar </button>
			</div>
		</div>	
	</div>	
</div>

<div id="dlg_AyudaEscuelas"  class="modal hide" tabindex="-1" style="width:820px; height:550px; position:fixed" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">x</button>			
		<h4 class="black bigger"><i class="icon-home "></i>&nbsp;Escuelas</h4>
	</div>
	<div class="modal-body">
		<table border="0" >
			<tr>
				<td width="90px" style="text-align:right"><label>Estado: </label></td>
				<td width="200px"><select id="cbo_Estado" class="chosen-select" tabindex="5001"></select></td>
				<td width="60px" style="text-align:right"><label>Municipio: </label></td>
				<td width="200px" ><select id="cbo_Ciudad" class="chosen-select"  tabindex="5002"></select></td>
				<td width="90px" style="text-align:right"><label>Localidad: </label></td>
				<td width="200px"><select id="cbo_Localidad" tabindex="5003"></td>
			</tr>
			<tr>
				<td><br><label>Buscar por:</label></td>
				<td colspan="5">
					<div>
						&nbsp;&nbsp;&nbsp;<select id="cbo_TipoConsulta" class="chosen-select" style="width:35%;" tabindex="5004">
							<option value="1"> Nombre</option>
							<option value="2"> RFC/Clave SEP</option>
						</select>
						
						<input type="text" class="textNumbersOnly" id="txt_NombreBusqueda" style="text-transform:uppercase;width:300px"  placeholder="Nombre ó Clave SEP " maxlength="50" tabindex="5005"/>
						&nbsp; &nbsp; &nbsp; <button class="btn btn-small btn-primary" id="btn_ConsultaAyudaEscuela" type="button" tabindex="5006"> 
						<i class="icon-search bigger-110"></i> </button>
					</div>
				</td>
			</tr>
		</table>
		<div id="gridEscuelas">
			<table id="grid_ayudaEscuelas" ></table>
			<div id="grid_ayudaEscuelas_pager" ></div>
		</div>
	</div>
	<div class="modal-footer">
		<div class="span12">
			<div class="span8">
				<label><font color="black">Doble click para seleccionar...</font></label>
			</div>
			<div class="span4">
			</div>
		</div>	
	</div>		
</div>

<!-- Modal de busqueda de Empleados -->
<div id="dlg_BusquedaEmpleados" class="modal hide" tabindex="-1" style="width:960px; height:auto; position:fixed; margin-left: -480px; margin-top: 0px;" data-backdrop="static">		
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consulta de Colaborador</h4>
	</div>
	<div class="modal-body">
		<table cellpadding="7">
			<br>
			<tr>
				<td style="width:70px">
					<b>Nombre: </b>
				</td>
				<td>
					<input type="txt"  class="textOnly" id="txt_NombreEBusqueda" style="text-transform:uppercase; width:140px" maxlength="30">
				</td>
				<td style="width:120px">
					<b>Apellido Paterno: </b>
				</td>
				<td>
					<input type="txt" class="textOnly" id="txt_apepatbusqueda" style="text-transform:uppercase; width:140px" maxlength="30">
				</td>
				<td style="width:123px">
					<b>Apellido Materno: </b>
				</td>
				<td>
					<input type="txt" class="textOnly" id="txt_apematbusqueda" style="text-transform:uppercase; width:140px" maxlength="30">
				</td>
				<td align="right">
					<button id="btn_buscarCOL" class="btn btn-small btn-primary"><i class="icon-search"></i>Buscar</button>
				</td>
			</tr>
			<tr><td colspan="7">&nbsp;</td></tr>
		</table>
		<table>
			<tr >
				<td>
					<table id="grid_colaborador"></table>
					<div id="grid_colaborador_pager"></div>
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
