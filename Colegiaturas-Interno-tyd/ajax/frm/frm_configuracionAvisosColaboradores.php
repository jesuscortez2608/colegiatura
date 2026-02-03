<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>
<!--page specific plugin styles-->
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_configuracionAvisosColaboradores.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>

<div class="page-content">
	<div class="form-horizontal">
		<div class="span12 form-horizontal">	
			<div class="control-group">	
				<input type="hidden" class="span2" id="txt_Clave" readonly>		
				<label class="control-label" for="form-input-readonly">Mensaje:</label>
				<div class="controls">
					<textarea class="span6 textNumbersOnly" id="txt_mensaje" maxlength="200" style="resize:none; width:780px; height:70px; text-transform:uppercase;"></textarea> 
				</div>
			</div>
			<table>
				<tr>
					<td>
						<input type="hidden" id="txt_fecha" value="<?php echo date('d/m/Y'); ?>"/>
						<label class="control-label">Fecha Inicial:</label>
						<div class="controls">
							<div class="row-fluid input-append">
							<input type="text" id="dp_FechaInicio" class="input-small" readonly value="<?php echo date('d/m/Y'); ?>"/>
							<span class="add-on">
								<i class="icon-calendar"></i>
							</span>
						</div>
						</div><br>
					</td>
					<td>
						<label class="control-label">Fecha Final:</label>
						<div class="controls">
							<div class="row-fluid input-append">
								<input type="text" id="dp_FechaFin" class="input-small" readonly  value="<?php echo date('d/m/Y'); ?>"/>
								<span class="add-on">
									<i class="icon-calendar"></i>
								</span>
							</div>
						</div><br>
					</td>
					<td>
						&emsp;&emsp;&emsp;&emsp;
					</td>
					<td>
						<label style="position: relative; top: -12px; text-align: rigth">
							<input class="ace ace-checkbox-2"  id="chk_indefinido" type="checkbox"/>
							<span class="lbl">&nbsp;Indefinido</span>
						</label>
					</td>
				</tr>
			</table>					
			<div class="control-group">	
				<label class="control-label">Opción:</label>
				<div class="controls">
					<select class="span5" id="cbx_Opcion">
						<option value=""></option>
					</select>	
					<button class="btn btn-primary btn-small" id="btn_guardar" type="button">
						<i class="icon-save bigger-110"></i>
						Guardar
					</button>	
				</div>  
			</div>
		</div>
		<div class="row-fluid">	
		<div class="span12">
			<div id="gridAvisosColaboradores" style="">
				<table id="gridAvisosColaboradores-table"></table>
				<div id="gridAvisosColaboradores-pager"></div>
			</div>
			<br>
		</div>
		</div>		
	</div>
</div>