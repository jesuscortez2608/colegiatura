
//Variables de consulta para el reporte
var iRutaPago, iEstatus, iRegion, iCiudad, iTipoDeduccion, iTipoEscuela = 0;
var cRutaPago, cEstatus, cRegion, cCiudad, cTipoDeduccion, cEmpresa /*cTipoEscuela*/ = "";

var dFechaInicio, dFechaFin = '19000101';
		
$(function() {
	waitwindow('Cargando','open');
	setTimeout(InicializarFormulario, 0);
});
function limpiarCadena(cadena) {
	var listaElementos = [];
	var returnList = [];
	var entity = {};
	entity.properti = "";
	listaElementos.push(entity);
	listaElementos.forEach(function (item) {
	  item.properti = cadena;
	  returnList.push(item);
	});
	return returnList[0].properti;
}


/* FUNCIONES ----------------------------------------------------------- */
function InicializarFormulario(){

	CrearControlesFechas();
	CrearGridReporte();
	
	CargarComboRutaPago(function(){
		CargarComboEstatus(function(){
			CargarComboRegiones(function(){
				CargarComboTiposDeducciones(function(){
					CargarComboEmpresas (function(){
						DesbloquearFormulario();
					});
				});
			});
		});
	});
}

function DesbloquearFormulario(){
	waitwindow('Cargando','close');
}

function CrearControlesFechas() {
	//Fecha Inicio
	$("#txt_FechaInicio").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
		maxDate: "0D",
		readOnly: true,
		changeYear: true,
		changeMonth: true,
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		 onSelect: function( selectedDate ) {
			$( "#txt_FechaFin" ).datepicker( "option", "minDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	//Fecha Fin
	$("#txt_FechaFin").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
		maxDate: "0D",
		minDate: "0D",
		readOnly: true,
		changeYear: true,
		changeMonth: true,
		monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
		dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
		onSelect: function( selectedDate ) {
			$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	
	$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
	
	$(".ui-datepicker-trigger").css('display','none');
}

function CrearGridReporte(){
	jQuery("#gridReporteNivelEstudio").jqGrid({
		datatype: 'json',
		mtype: 'POST',
		colNames:LengStr.idMSG21,
		colModel:[
			{name:'idu_empresa', index:'idu_empresa', width:100, sortable: false, align:"center", fixed: true, hidden:true},
			{name:'nom_empresa', index:'nom_empresa', width:300, sortable: false, align:"left", fixed: true},
			{name:'idu_escolaridad', index:'idu_escolaridad', width:100, sortable: false, align:"center", fixed: true, hidden:true},
			{name:'nom_escolaridad', index:'nom_escolaridad', width:200, sortable: false, align:"left",fixed: true},
			{name:'colaboradores_por_nivel', index:'colaboradores_por_nivel', width:100, sortable: false, align:"right",fixed: true},
			{name:'facturas_ingresadas', index:'facturas_ingresadas', width:100, sortable: false, align:"right", fixed: true},
			{name:'importe', index:'importe', width:120, sortable: false, align:"right", fixed: true},
			{name:'reembolso', index:'reembolso', width:120, sortable: false, align:"right", fixed: true},
			{name:'porcentaje_colaboradores', index:'porcentaje_colaboradores', width:110, sortable: false, align:"right", fixed: true},
			{name:'porcentaje_facturas', index:'porcentaje_facturas', width:110, sortable: false, align:"right", fixed: true}
		],
		scrollrows: true,
		viewrecords: false,
		rowNum: -1,
		hidegrid: false,
		rowList: [],
		width: null,
		shrinkToFit: false,
		height: 350,
		pager: '#gridReporteNivelEstudio-pager',
		caption: 'Becas Otorgadas por Nivel de Estudios',
		pgbuttons: false,
		pgtext: null,
		loadComplete: function (Data) {
			var registros = jQuery("#gridReporteNivelEstudio").jqGrid('getGridParam', 'reccount');
			if(registros == 0){
				showalert(LengStrMSG.idMSG86, "", "gritter-info");
			}
			var table = this;
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
		},
		onSelectRow: function(Numemp) {
			var Data = jQuery("#gridReporteNivelEstudio").jqGrid('getRowData',Numemp);
			Numemp =Data.Numemp;
		}
	});	
	
	barButtongrid({
			pagId:"#gridReporteNivelEstudio-pager",
			position:"left",
			Buttons:[
			{
				icon:"icon-print blue",
				title:'Imprimir',
				click:function (event)
				{
					if (($("#gridReporteNivelEstudio-table").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}
					else
					{
						ImprimirReporte();
					}
					
					event.preventDefault();	
				},
				
			}]
		});	
		setSizeBtnGrid('id_button0',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}

function CargarComboRutaPago(callback){
	$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_rutas_pago.php",
		data: {}
	}).done(function(data) {
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			var option = "<option value='-1'>TODAS</option>";
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
			}
			$("#cbo_rutaPago").html(option);
			$("#cbo_rutaPago").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+" las rutas de pagos", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" las rutas de pagos", "", "gritter-error");
	})
	.always(function() {
		callback();
	});
}

function CargarComboEstatus(callback){
	var option="";
	$.ajax(
		{
			type: "POST",
			url: "ajax/json/json_fun_obtener_estatus_facturas.php",
			data: { } 
		})
	.done(function(data){
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			option = option + "";
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
			}
			$("#cbo_Estatus").html(option);
			$("#cbo_Estatus").trigger("chosen:updated");
			
			//$("#cbo_Estatus").val(1);
			$("#cbo_Estatus").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
		$('#cbo_Estatus').fadeOut();})
	.always(function() {
		callback();
	});
}

function CargarComboRegiones(callback) {
	$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_listado_regiones.php",
		data: {}
	}).done(function(data) {
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			var option = "<option value='0'>TODAS</option>";
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
			}
			$("#cbo_Region").html(option);
			$("#cbo_Region").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
		$('#cbo_CicloEscolar').fadeOut();
	})
	.always(function() {
		callback();
	});
}

function CargarComboCiudades(){
	if($(cbo_Region).val() > 0)
	{
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_catalogociudades.php",
			data: {
				'region':$(cbo_Region).val()
			}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_Ciudad").html(option);
				$("#cbo_Ciudad").trigger("chosen:updated");
			}
			else {
				showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
			$('#cbo_Ciudad').fadeOut();
		})
		.always(function() {});
	}
	else
	{
		var option = "<option value='0'>TODAS</option>";
		$("#cbo_Ciudad").html(option);
	}	
}

function CargarComboTiposDeducciones(callback) {
	$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
		data: {}
	}).done(function(data) {
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			var option = "<option value='0'>TODOS</option>";
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
			}
			$("#cbo_tipoDeduccion").html(option);
			$("#cbo_tipoDeduccion").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" los tipos de deducciones" , "", "gritter-error");
		$('#cbo_CicloEscolar').fadeOut();
	})
	.always(function() {
		callback();
	});
};

//--COMBO EMPRESAS
function CargarComboEmpresas(callback){
	var option="";
	$.ajax(
		{
			type: "POST",
			url: "ajax/json/json_fun_obtener_listado_empresas_colegiaturas.php",
			data: { } 
		})
	.done(function(data){
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			option = option + "<option value='0'>TODAS</option>";
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
			}
			$("#cbo_empresa").html(option);
			$("#cbo_empresa").trigger("chosen:updated");
			
			//$("#cbo_Estatus").val(1);
			$("#cbo_empresa").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+"las empresas", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" las empresas", "", "gritter-error");
		$('#cbo_empresa').fadeOut();})
	.always(function() {
		callback();
	});
}

function CargarVariablesDeConsulta( callback ){
	iRutaPago = $("#cbo_rutaPago").val();
	iEstatus = $("#cbo_Estatus").val();
	iRegion = $("#cbo_Region").val();
	iCiudad = $("#cbo_Ciudad").val();
	iTipoDeduccion = $("#cbo_tipoDeduccion").val();
	iTipoEscuela = $("#cbo_Tipo_Escuela").val();
	iEmpresa = $("#cbo_empresa").val();
	
	dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
	dFechaFin = formatearFecha($('#txt_FechaFin').val());
	
	cRutaPago = $('#cbo_rutaPago option:selected').html();
	cEstatus = $('#cbo_Estatus option:selected').html();
	cRegion = $('#cbo_Region option:selected').html();
	cCiudad = $('#cbo_Ciudad option:selected').html();
	cTipoDeduccion = $('#cbo_tipoDeduccion option:selected').html();
	//cTipoEscuela = $("#cbo_Tipo_Escuela option:selected").html();
	cEmpresa = $("#cbo_empresa option:selected").html();
	callback();
}

function Consultar()
{
	$("#gridReporteNivelEstudio").jqGrid('clearGridData');
	console.log(dFechaInicio);
	//dFechaInicio='20140411';
	//dFechaFin='20140411';
	CargarVariablesDeConsulta(function(){
		urlu = 'ajax/json/json_fun_obtener_reporte_colegiaturas_por_escolaridad.php?' +
		'session_name=' + Session +
		'&iRutaPago=' + iRutaPago +
		'&iEstatus=' + iEstatus +
		'&iRegion=' + iRegion +
		'&iCiudad=' + iCiudad +
		'&iTipoDeduccion=' + iTipoDeduccion +
		//'&iTipoEscuela=' + iTipoEscuela +
		'&iEmpresa=' + iEmpresa +
		//'&dFechaInicio=' + '20140411' + 
		//'&dFechaFin=' + '20140411'; 
		'&dFechaInicio=' + dFechaInicio +
		'&dFechaFin=' + dFechaFin;
		$("#gridReporteNivelEstudio").jqGrid('setGridParam',{ url: urlu }).trigger("reloadGrid");
	});	
}

function ImprimirReporte()
{
	var registros = jQuery("#gridReporteNivelEstudio").jqGrid('getGridParam', 'reccount');
	if(registros == 0){
		showalert(LengStrMSG.idMSG87, "", "gritter-info");
	}
	else
	{
		var urlu = 'ajax/json/impresion_reporte_colegiaturas_por_escolaridad.php?' +
			'session_name=' + Session +
			'&iRutaPago=' + iRutaPago +
			'&iEstatus=' + iEstatus +
			'&iRegion=' + iRegion +
			'&iCiudad=' + iCiudad +
			'&iTipoDeduccion=' + iTipoDeduccion +
			//'&iTipoEscuela=' + iTipoEscuela +
			'&iEmpresa=' + iEmpresa +
			'&dFechaInicio=' + dFechaInicio +
			'&dFechaFin=' + dFechaFin +
			'&cRutaPago=' + cRutaPago +
			'&cEstatus=' + cEstatus +
			'&cRegion=' + cRegion +
			'&cCiudad=' + cCiudad +
			'&cTipoDeduccion=' + cTipoDeduccion +
			//'&cTipoEscuela=' + cTipoEscuela;
			'&cEmpresa=' + cEmpresa;
		location.href = urlu;
	}
}

/* EVENTOS ------------------------------------------------ */
$("#btn_consultar").click(function(event){
	Consultar();
	event.preventDefault();
});
$("#cbo_Region").change(function(event){
	CargarComboCiudades();
	event.preventDefault();
});


