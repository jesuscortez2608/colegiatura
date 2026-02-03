<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>
<script type="text/javascript" src="files/js/frm_reporteBecasEscuela.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
	#dlg_AyudaEscuelas .modal-body {
		max-height: 500px;
		overflow-y: auto;
		padding: 15px;
		position: relative;
	}
</style>
<div class="page-content">
	<form class="form-horizontal">
		<div class="span12">
		
			<div class="span6 control-group">

				<!--Ruta pago-->
				<label class="control-label" >Ruta de Pago:</label>
				<div class="controls">
					<select id="cbo_rutaPago" ></select>
				</div>
				<br>
				
				<!--Estatus-->
				<label class="control-label" >Estatus:</label>
				<div class="controls">
					<select id="cbo_Estatus" ></select>
				</div>
				<br>
				
				<!--Región-->
				<label class="control-label">Región:</label>
				<div class="controls">
					<select id="cbo_Region"></select>
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
				
				<!--Tipos de Deducción-->
				<label class="control-label">Tipos de Deducción:</label>
				<div class="controls">
					<select id="cbo_tipoDeduccion"></select>
				</div>
				<br>
						
			</div>
			
			<div class="span6 control-group">
			
				
				
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
				<br>
				
				<!--Escolaridad-->
				<label class="control-label" >Escolaridad:</label>
				<div class="controls">
					<select id="cbo_Escolaridad" ></select>
				</div>
				<br>
				
				<!--Escuela-->
				<label class="control-label" for="txt_Escuela">Escuela:</label>
				<div class="controls">
				
					<input type="hidden" id="txt_IdEscuela">
					<input type="hidden" id="txt_RFC">
					
					<input type="text"  id="txt_Escuela" readonly>
					<button type="button" id="btn_ConsultaEscuela" class="btn btn-small btn-primary">
						<i class="icon-search bigger-110"></i>
					</button>
					
				</div>
				<br>				
				<!--Empresa-->
				<label class="control-label">Empresa:</label>
				<div class="controls">
					<select id="cbo_empresa"></select>
				</div>
			</div>
		</div>
		<div class="row-fluid">
			<!--Boton Consultar-->
			<div class="controls">
				<button id="btn_Consultar" class="btn btn-small btn-primary pull-right">
				<i class="icon-search bigger-110"></i>Consultar</button>
			</div>
		</div>
		<div class="row-fluid">
			<div class="span12">
				<div class="control-group">
				<br>
					<div id="gridBecasEscuela">
						<table id="gridBecasEscuela-table"></table>
						<div id="gridBecasEscuela-pager"></div>
					</div>
				</div>
			</div>
		
		</div>
		
	</form>
</div>

<div id="dlg_AyudaEscuelas"  class="modal hide" tabindex="-1" style="width:820px; height:550px; position:fixed" data-backdrop="static">
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">×</button>			
		<h4 class="black bigger"><i class="icon-home "></i>&nbsp;Escuelas</h4>
	</div>
	<div class="modal-body">
		<table border="0" >
			<tr>
				<td width="90px" style="text-align:right"><label>Estado: </label></td>
				<td width="200px"><select id="cbo_Estado" style="width:100%;" tabindex="5001"></select></td>
				<td width="60px" style="text-align:right"><label>Municipio: </label></td>
				<td width="200px" ><select id="cbo_CiudadModal" style="width:100%;" tabindex="5002"></select></td>
				<td width="60px" style="text-align:right"><label>Localidad:</label></td>
				<td width="200px"><select id="cbo_Localidad" style="width:100%;" tabindex="5003"></select></td>
			</tr>
			<tr>
				<td><br><label>Buscar por:</label></td>
				<td colspan="5">
					<div>
						&nbsp;&nbsp;&nbsp;<select id="cbo_TipoConsulta" style="width:35%;" tabindex="5004">
							<option value="1"> Nombre</option>
							<option value="2"> RFC/Clave SEP</option>
						</select>
						
						<input type="text" class="textNumbersOnly" id="txt_NombreBusqueda" style="text-transform:uppercase;width:300px"  placeholder="Nombre o Clave SEP " maxlength="50" tabindex="5005"/>
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