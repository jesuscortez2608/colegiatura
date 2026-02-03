
//Variables de consulta para el reporte
var iRutaPago, iEstatus, iRegion, iCiudad, iTipoDeduccion, iTipoEscuela = 0;
var cRutaPago, cEscolaridad, cRegion, cCiudad, cTipoDeduccion, cEmpresa /*cTipoEscuela*/ = "";
var iOpcCiclo=0, iOpcFecha = 1;

var dFechaInicio, dFechaFin = '19000101';
		
$(function() {
	waitwindow('Cargando','open');
	setTimeout(InicializarFormulario, 0);
});

/* FUNCIONES ----------------------------------------------------------- */
function InicializarFormulario(){

	CrearControlesFechas();
	CrearGridReporte();
	
	CargarComboRutaPago(function(){
		CargarComboEscolaridades(function(){
			CargarComboRegiones(function(){
				CargarComboTiposDeducciones(function(){
					CargarComboCicloEscolar (function(){
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

function CrearGridReporte(){
	jQuery("#gridReporteNivelEstudio").jqGrid({
		datatype: 'json',
		mtype: 'POST',
		colNames:LengStr.idMSG121,
		colModel:[
			{name:'idfactura', index:'idfactura', width:50, sortable: false, align:"center", fixed: true, hidden:true},
			{name:'importefactura', index:'importefactura', width:100, sortable: false, align:"right", fixed: true},
			{name:'porc_pagado', index:'porc_pagado', width:80, sortable: false, align:"center", fixed: true},
			{name:'importepagado', index:'importepagado', width:100, sortable: false, align:"right", fixed: true/*, hidden:true*/},
			{name:'fechafactura', index:'fechafactura', width:100, sortable: false, align:"center",fixed: true},
			{name:'foliofiscal', index:'foliofiscal', width:300, sortable: false, align:"left",fixed: true},
			{name:'idu_empleado', index:'idu_empleado', width:110, sortable: false, align:"right", fixed: true, hidden:true},
			{name:'nom_empleado', index:'nom_empleado', width:300, sortable: false, align:"left", fixed: true},			
			{name:'becado', index:'becado', width:300, sortable: false, align:"left", fixed: true},
			{name:'parentesco', index:'parentesco', width:120, sortable: false, align:"left", fixed: true},
			{name:'idu_estatus', index:'idu_estatus', width:50, sortable: false, align:"right", fixed: true, hidden:true},
			{name:'nom_estatus', index:'nom_estatus', width:150, sortable: false, align:"left", fixed: true},
		],
		scrollrows: true,
		viewrecords: true,
		rowNum: -1,
		hidegrid: false,
		rowList: [],
		width: null,
		shrinkToFit: false,
		height: 250,
		pager: '#gridReporteNivelEstudio-pager',
		caption: 'Facturas con Ajuste',
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

function CargarComboEscolaridades(callback)
{
	$.ajax({
		type: "POST",
		url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
		data: {}
	})
	.done(function(data){
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			var option = "<option value='0'>TODAS</option>";
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
			}
			$("#cbo_Escolaridad").html(option);
			$("#cbo_Escolaridad").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
		}
	})
	.fail(function(s)
	{
		showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
	})
	.always(function()
	{
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



//--COMBO CICLOS ESCOLARES
function CargarComboCicloEscolar(callback){
	var option="";
	$.ajax(
		{
			type: "POST",
			//url: "ajax/json/json_fun_obtener_listado_empresas_colegiaturas.php",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: { } 
		})
	.done(function(data){
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
			}
			$("#cbo_cicloEscolar").html(option);
			$("#cbo_cicloEscolar").trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+"las empresas", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" las empresas", "", "gritter-error");
		$('#cbo_cicloEscolar').fadeOut();})
	.always(function() {
		callback();
	});
}
/*
function CargarComboCicloEscolar(){
	$("#cbo_CicloEscolar").html("");	
	$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
		data: {},
		beforeSend:function(){},
		success:function(data){
			var dataJson = JSON.parse(data);
			if(dataJson.estado == 0)
			{
				var option = "";
				option = option + "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_CicloEscolar").html(option);
				$("#cbo_CicloEscolar").trigger("chosen:updated");
			}
			else if(dataJson.estado == 0)
			{
				//message(LengStr.idMSG11);
				// showalert(LengStr.idMSG11, "", "gritter-warning");
				$("#cbo_CicloEscolar").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
				$("#cbo_CicloEscolar").trigger("chosen:updated");
			}
			else
			{
				//message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
			}
		},
		error:function onError(){
			//message("Error al cargar " + url);
			showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		},
		complete:function(){},
		timeout: function(){},
		abort: function(){}
	});
}*/

function CargarVariablesDeConsulta( callback ){
	iRutaPago = $("#cbo_rutaPago").val();
	iEscolaridad = $("#cbo_Escolaridad").val();
	iRegion = $("#cbo_Region").val();
	iCiudad = $("#cbo_Ciudad").val();
	iTipoDeduccion = $("#cbo_tipoDeduccion").val();	
	if(iOpcCiclo == 1){
		iCicloEscolar = $("#cbo_cicloEscolar").val();
		dFechaInicio = '19000101';
		dFechaFin = '19000101';
	}
	if(iOpcFecha == 1){
		iCicloEscolar = -1;
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
	}
	iNumEmp=$('#txt_Empleado').val();
	cRutaPago = $('#cbo_rutaPago option:selected').html();
	cEscolaridad = $('#cbo_Escolaridad option:selected').html();
	cRegion = $('#cbo_Region option:selected').html();
	cCiudad = $('#cbo_Ciudad option:selected').html();
	cTipoDeduccion = $('#cbo_tipoDeduccion option:selected').html();
	//cNumemp = $('#txt_').html();
	if (iNumEmp==''){
		iNumEmp=0;
	}
	
	callback();
}

function Consultar()
{
	$("#gridReporteNivelEstudio").jqGrid('clearGridData');
	console.log(dFechaInicio);
	//dFechaInicio='20140411';
	//dFechaFin='20140411';
	CargarVariablesDeConsulta(function(){
		urlu = 'ajax/json/json_fun_obtener_reporte_facturas_ajuste.php?' +
		'session_name=' + Session +
		'&iRutaPago=' + iRutaPago +
		'&iEscolaridad=' + iEscolaridad +
		'&iRegion=' + iRegion +
		'&iCiudad=' + iCiudad +
		'&iTipoDeduccion=' + iTipoDeduccion +
		'&iCicloEscolar=' + iCicloEscolar +		
		'&dFechaInicio=' + dFechaInicio +
		'&dFechaFin=' + dFechaFin +
		'&iNumEmp=' + iNumEmp ;
		// console.log(urlu);
		// return;
		$("#gridReporteNivelEstudio").jqGrid('setGridParam',{ url: urlu }).trigger("reloadGrid");
	});	
}

//IMPRIMIR REPORTE
function ImprimirReporte()
{
	CargarVariablesDeConsulta(function(){
		console.log('Imprimir Reporte');
	});
	
	sUrl = 'ajax/json/json_exportar_reporte_factura_ajuste.php?&session_name='+Session;
	
	var sNombreReporte = 'rpt_facturas_con_ajuste'
		, iIdConexion = '190'
		, sFormatoReporte = 'pdf';
		
	var sUrl = "nombre_reporte=" + sNombreReporte + "&";
		sUrl += "id_conexion=" + iIdConexion + "&";
		sUrl += "dbms=postgres&";
		sUrl += "formato_reporte=" + sFormatoReporte + "&";	
		sUrl += "irutapago=" + iRutaPago + "&";
		sUrl += "iescolaridad=" + iEscolaridad + "&";
		sUrl += "iregion=" + iRegion + "&";			
		sUrl += "iciudad=" + iCiudad + "&";
		sUrl += "itipodeduccion=" + iTipoDeduccion + "&";
		sUrl += "icicloescolar=" + iCicloEscolar + "&";
		sUrl += "dfechainicio=" + dFechaInicio + "&";
		sUrl += "dfechafin=" + dFechaFin + "&";
		sUrl += "inumemp=" + iNumEmp + "&";
	
	console.log(sUrl);
	
	var xhr = new XMLHttpRequest();
	var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS + '/reportes';
	
	xhr.open("POST", report_url, true);
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	
	xhr.addEventListener("progress", function (evt) {
		if(evt.lengthComputable) {
			var percentComplete = evt.loaded / evt.total;
			console.log(percentComplete);
		}
	}, false);
	
	xhr.responseType = "blob";
	xhr.onreadystatechange = function() {
		waitwindow('', 'close');
		if(this.readyState == XMLHttpRequest.DONE && this.status == 200) {
			var filename = sNombreReporte + "." + sFormatoReporte;
			
			var link = document.createElement('a');
			link.href = window.URL.createObjectURL(xhr.response);
			link.download = filename;
			link.style.display = 'none';
			
			document.body.appendChild(link);
			
			link.click();
			
			document.body.removeChild(link);
		}
	}
	
	waitwindow('Obteniendo reporte, por favor espere...', 'open');
	xhr.send(sUrl);
}

/* EVENTOS ------------------------------------------------ */
	$("#rdbtn_ciclo").change(function(){
		if($("#rdbtn_ciclo").is(":checked")){
			iOpcCiclo = 1;
			iOpcFecha = 0;
			$("#cbo_cicloEscolar").prop('disabled', false);
			$("#txt_FechaInicio").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
		}else if($("#rdbtn_fecha").is(":checked")){
			iOpcFecha = 1;
			iOpcCiclo = 0;
			$("#cbo_cicloEscolar").prop('disabled', true);
			$("#txt_FechaInicio").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
		}
	});
	
	$("#rdbtn_fecha").change(function(){
		if($("#rdbtn_fecha").is(":checked")){
			iOpcFecha = 1;
			iOpcCiclo = 0;
			$("#cbo_cicloEscolar").prop('disabled', true);
			$("#txt_FechaInicio").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
		} else if($("#rdbtn_ciclo").is(":checked")){
			iOpcCiclo = 1;
			iOpcFecha = 0;
			$("#cbo_cicloEscolar").prop('disabled', false);
			$("#txt_FechaInicio").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
		}
	});
	
$("#btn_consultar").click(function(event){
	Consultar();
	event.preventDefault();
});
$("#cbo_Region").change(function(event){
	CargarComboCiudades();
	event.preventDefault();
});


