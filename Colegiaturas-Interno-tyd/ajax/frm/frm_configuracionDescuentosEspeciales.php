<?php
	header( 'X-Frame-Options: SAMEORIGIN' );	
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>

<!-- VULNERABILIDADES -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>
<!-- VULNERABILIDADES -->

<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/jquery-ui-1.10.3.full.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ui.jqgrid.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-responsive.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-skins.min.css" />

<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/utils.js"></script>

<script type="text/javascript" src="files/js/frm_configuracionDescuentosEspeciales.js"></script>
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
<div class="page-content" id="pagecontent">
	<div class="span12">
		
			<div id="tabs">
				<ul>
					<li><a href="#Colaborador" style="font-size: 14px;"><i class="blue icon-user bigger-110"></i>
							<b>Por Colaborador</b>
						</a>
					</li>
					<li>
						<a href="#Puesto" style="font-size: 14px;"><i class="blue icon-group bigger-110"></i>
							<b>Por Puesto</b>
						</a>
					</li>
					<li>
						<a href="#Centro" style="font-size: 14px;"><i class="blue icon-group bigger-110"></i>
							<b>Por Centro</b>
						</a>
					</li>
				</ul>
				<div id="Colaborador">
					<table  border="0"  width="100%" cellpadding="5">
						<tr>
							<td width="60%">
								<b style="text-align:right">Colaborador:&emsp;</b>
								<input type="text" class="span2 numbersOnly"  id="txt_idEmpleado" maxlength="8"/>
								<input type="text" class="span7" id="txt_nombreEmpleado" readonly />
								<button class="btn btn-info btn-small" id="btn_buscar1" style="position: relative; top: -5px;">
									<i class="icon-search icon-on-right bigger-110"> </i> 
								</button>								
							</td>						
							<td width="40%">
								<b style="text-align:right">Centro:&emsp;</b>
								<input id="txt_Centro" class="span3" type="text" readonly />
								<input type="text" class="span7" id="txt_NombreCentro" readonly />
							</td>
						</tr>
					</table>
					<table border="0" width="100%">
						<tr>
							<td>
								<b style="text-align:right">&emsp;Parentesco:&emsp;</b>
								<select class="span7" id="cbo_ParentescoEmpleado"  ></select>
							</td>							
							<td>
								<b style="text-align:right"  >Escolaridad:&emsp;&nbsp;</b>
								<select id="cbo_estudio1" class="span7"  ></select>	
							</td>
							<td>
								<b style="text-align:right" >Descuento (%):&emsp;&nbsp;</b>
								<select id="cbo_DescuentoEmpleado" class="span7"></select>
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<button class="btn btn-small btn-success" id="btn_AgregarD" onclick="return false;">
									<i class="icon-plus bigger-110"></i>Nuevo Porcentaje
								</button>
							</td>
						</tr>
						<tr align="right">
							<td colspan="8" style="position: relative; right: 10px;">
								<br><br><br><button class="btn btn-small btn-primary" id="btn_AgregarE" type="button">
									<i class="icon-plus bigger-110"></i>Agregar
								</button>
							</td>
						</tr>
					</table>
					<br>
				</div>
				<div id="Puesto">
					<table  border="0"  width="100%" >
						<tr>
							<td >
								<label style="text-align:right" >Puesto:&nbsp;</label>
							</td>
							<td colspan="4">
									<input id="txt_Puesto" class="span3 numbersOnly" type="text" maxlength="3" />
									<input  type="text" class="span7" id="txt_NombrePuesto" readonly />
									<button class="btn btn-info btn-small" onclick="return false;" id="btn_BuscarPuesto" style="position: relative; top: -5px;">
										<i class="icon-search icon-on-right bigger-110"></i>
									</button>
								
							</td>
							<td>
								<label style="text-align:right" >Sección:&nbsp;</label>	
							</td>
							<td colspan="3">
								<div class="controls">
									<select id="cbo_Seccion" disabled="true"></select>
								</div>
							</td>
						</tr>
						<tr>
							<td>
								<label style="text-align:right"  >Parentesco:&nbsp;</label>
							</td>
							<td>
								<select class="span12" id="cbo_ParentescoPuesto"  ></select>
							</td>
							<td>&nbsp;</td>
							<td>
									<label style="text-align:right"  >Escolaridad:&nbsp;</label>
							</td>
							<td>
									<select id="cbo_Estudio2" class="span12"  ></select>	
							</td>
							<td>
								<label style="text-align:right" >Descuento (%):&nbsp;</label>
							</td>
							<td>	
								<div class="controls">
									<select id="cbo_DescuentoPuesto"></select>
								</div>
							</td>	
						</tr>
						<tr><td colspan="7">&nbsp;</td></tr>
						<tr align="right">
							<td colspan="5"></td>
							<td colspan="2">
								<button class="btn btn-small btn-primary" id="btn_AgregarP" type="button" style="position: relative; left: -43px;">
									<i class="icon-plus bigger-110"></i>Agregar
								</button>
							</td>
						</tr>							
	
					</table>
					<br>	
				</div>
				<div id="Centro">
					<table  border="0"  width="100%" >
						<tr>
							<td><label style="text-align:right" >Centro:&nbsp;</label></td>
							<td colspan="4">
								<div class="controls">
								<input id="txt_CentroC" class="span3 numbersOnly" type="text" maxlength="6" />
								<input  type="text" class="span7" id="txt_NombreCentroC" readonly>
								<button class="btn btn-info btn-small" onclick="return false;" id="btn_BuscarCentro" style="position: relative; top: -5px;" >
									<i class="icon-search icon-on-right bigger-110"></i>
								</button>
								</div>
							</td>
							<td>
								<label style="text-align:right" >Puesto:&nbsp;</label>
							</td>
							<td colspan="3">
								<div class="controls">
									<select id="cbo_PuestoC" disabled="true"></select>
								</div>
							</td>
							
						</tr>
						<tr>
							<td>
								<label style="text-align:right"  >Parentesco:&nbsp;</label>
							</td>
							<td>
								<select class="span12" id="cbo_ParentescoCentro"  ></select>
							</td>
							<td>&nbsp;</td>
							<td>
									<label style="text-align:right"  >Escolaridad:&nbsp;</label>
							</td>
							<td>
									<select id="cbo_Estudio3" class="span12"  ></select>	
							</td>
							<td>
								<label style="text-align:right" >Descuento (%):&nbsp;</label>
							</td>
							<td>	
								<div class="controls">
									<select id="cbo_DescuentoCentro"></select>
								</div>
							</td>	
						</tr>
						<tr><td colspan="7">&nbsp;</td></tr>
						<tr align="right">
							<td colspan="6"></td>
							<td colspan="2">
								<button class="btn btn-small btn-primary" id="btn_AgregarC" type="button" style="position: relative; left: -43px;">
									<i class="icon-plus bigger-110"></i>Agregar
								</button>
							</td>
						</tr>								
					</table>
					<br>
				</div>	
					
			</div>

				<div id="contenedor_Colaboladores">
					<table id="gd_Colaboladores"></table>
					<div id="gd_Colaboladores_pages"></div>
				</div>
				<div id="contenedor_Centro" style="display:none">
					<table id="gd_Centros"></table>
					<div id="gd_Centros_pages"></div>
				</div>
				<div id="contenedor_Puestos" style="display:none">
					<table id="gd_Puestos"></table>
					<div id="gd_Puestos_pages"></div>
				</div>
				<br>
			
			
					<div id="contenedor_Parentescos">
						<table id="gd_Parentescos"></table>
						<div id="gd_Parentescos_pages"></div>
					</div><br>			
			<div id="dlg_colaborador" class="modal hide" tabindex="-1" style="width:950px;   height:auto; position:fixed; margin-left: -480px; margin-top: 0px;" data-backdrop="static">
			
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
								<input type="text" class="textOnly" id="txt_nombusqueda" style="text-transform:uppercase; width:140px" maxlength="30"/>
							</td>
							<td style="width:120px">
								<b>Apellido Paterno: </b>
							</td>
							<td>
								<input type="text" class="textOnly" id="txt_apepatbusqueda" style="text-transform:uppercase; width:140px" maxlength="30"/>
							</td>
							<td style="width:120px">
								<b>Apellido Materno: </b>
							</td>
							<td>
								<input type="text" class="textOnly" id="txt_apematbusqueda" style="text-transform:uppercase; width:140px" maxlength="30"/>
							</td>
							<td align="right">
								<button id="btn_buscarCOL" class="btn btn-small btn-primary icon-search">Buscar</button>
							</td>
						</tr>
						<tr><td colspan="7">&nbsp;</td></tr>
					</table>
					<table>
						<tr >
							<td>
								<table id="grid-colaborador-table"></table>
								<div id="grid-colaborador-pager"></div>
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
			<div id="dlg_puesto" class="modal hide" tabindex="-1" style="width:485px; height:auto; position:fixed; margin-left: -250px; margin-top: 0px;" data-backdrop="static">
				<div class="modal-header widget-header" >
					<button type="button" class="close" data-dismiss="modal">&times;</button>		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consulta de Puestos</h4>
				</div>
				<div class="modal-body">
					<table cellpadding="5">
						<tr>
							<td style="width:140px">
								<b>Nombre del Puesto:&ensp;</b>
							</td>
							<td style="width:68px">
								<input type="text" id="txt_puestoBusqueda" class="textOnly" style="text-transform:uppercase;" maxlength="30"/>
							</td>
							<td align="right">
								<button id="btn_buscarPuest" class="btn btn-small btn-primary icon-search">Buscar</button>
							</td>
						</tr>
						<tr>
							<td>
								<br>
							</td>
						</tr>
					</table>
					<table>
						<tr>
							<td colspan="2">
								<table id="grid_puesto"></table>
								<div id="grid_puesto_pager"></div>
							</td>
						<tr>
					</table>
				</div>
				<div class="modal-footer">
					<div align="center">
						<label><font color="black">Doble click para seleccionar...</font></label>
					</div>
				</div>	
			</div>
			<div id="dlg_centro" class="modal hide" tabindex="-1" style="width:485px; height:auto; position:fixed; margin-left: -250px; margin-top: 0px;" data-backdrop="static">
				<div class="modal-header widget-header" >
					<button type="button" class="close" data-dismiss="modal">&times;</button>		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consulta de Centro</h4>
				</div>
				<div class="modal-body">
					<table cellpadding="5">
						<tr>
							<td style="width:140px">
								<b>Nombre del Centro:&ensp;</b>
							</td>
							<td style="width:68px">
								<input type="text" class="textOnly" id="txt_centroBusqueda" style="text-transform:uppercase;" maxlength="30" />
							</td>
							<td align="right">
								<button id="btn_buscarCentro" class="btn btn-small btn-primary icon-search">Buscar</button>
							</td>
						</tr>
						<tr>
							<td>
								<br>
							</td>
						</tr>
					</table>
					<table>
						<tr>
							<td colspan="2">
								<table id="grid_centro"></table>
								<div id="grid_centro_pager"></div>
							</td>
						<tr>
					</table>
				</div>
				<div class="modal-footer">
					<div align="center">
						<label><font color="black">Doble click para seleccionar...</font></label>
					</div>
				</div>	
			</div>
			<div id="dlg_descuento" class="modal hide" tabindex="-1" style="width:390px;   height:auto; position:fixed; margin-left: -200px; margin-top: 0px;" data-backdrop="static">
				<div class="modal-header widget-header" >
					<button type="button" class="close" title="Cerrar" data-dismiss="modal">&times;</button>
					<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Agregar Descuento</h4>
				</div>
				<div class="modal-body">
					<table cellpadding="5">
						<tr>
							<td style="width:140px">
								<b>Descuento:&ensp;</b>
							</td>
							<td>
								<input type="text" id="txt_descuento" style="width: 50px;" maxlength="3"/>
							</td>
							<td align="right">
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								<button id="btn_AgregarD2" class="btn btn-small btn-success"><i class="icon-plus bigger-110"></i>Agregar</button>
								<!--<i class="icon-plus"></i>Nuevo Porcentaje-->
							</td>
						</tr>
						<tr>
							<table id="grid_descuento"></table>
							<!--<div id="grid_descuento_pager"></div>-->
						</tr>
					</table>
				</div>
			</div>
		<div id="dlg_Comentario" class="modal hide" tabindex="-1" style="width:525px; height:auto; position:fixed; margin-left: -250px; margin-top: 150px;" data-backdrop="static">
				<div class="modal-header widget-header" >
					<button id="btn_closeM" type="button" class="close" data-dismiss="modal">&times;</button>		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Captura Comentario</h4>
				</div>
				<div class="modal-body">
					<table>
					<br>
						<tr>
							<td align="right">Motivo:&nbsp;</td>
							<td ><textarea class="span5 textNumbersOnly" id="txt_Comentario" maxlength="300" style="resize:none; width:440px;height:80px; text-transform:uppercase;"></textarea></td>									
						</tr>								
					</table>	
				</div>
				<div class="modal-footer">
					<button class="btn btn-small btn-success" id="btn_GuardaObservacion" type="button">
							<i class="icon-save bigger-110"></i>&nbsp;Guardar
					</button>
				</div>	
		</div>
	</div>
	<div id="divexport">
	</div>