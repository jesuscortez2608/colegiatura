SessionIs();
$(function(){
	setTimeout(InicializarFormulario, 0);
});

//--------------------------------- Funciones ---------------------------------
function InicializarFormulario(){
	CargarDescuentos();
	CrearControlesFechas();
	CrearGridPorcentajes();
	CargarEmpresas();
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


	function CrearControlesFechas(){
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

	function CrearGridPorcentajes(){
	jQuery("#gridPorcentaje-table").jqGrid({
		//url:'ajax/json/',
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG11,
		colModel:[
			{name:'nom_empresa',		index:'nom_empresa', 		width:90, 	sortable: false,	align:"left",	fixed: true},
			{name:'Fechacorte',			index:'Fechacorte', 		width:115, 	sortable: false,	align:"center",	fixed: true},
			{name:'Numero Empleado',	index:'Numero Empleado',	width:90, 	sortable: false,	align:"left",	fixed: true},
			{name:'Nombre Empleado',	index:'Nombre Empleado',	width:300, 	sortable: false,	align:"left",	fixed: true},
			{name:'Numero Centro',		index:'Numero Centro', 		width:60, 	sortable: false,	align:"left",	fixed: true},
			{name:'Nombre Centro',		index:'Nombre Centro', 		width:220, 	sortable: false,	align:"left",	fixed: true},
			{name:'Importe Factura',	index:'Importe Factura',	width:118, 	sortable: false,	align:"right",	fixed: true},
			{name:'Total Pagado',		index:'Total Pagado', 		width:100, 	sortable: false,	align:"right",	fixed: true},
			{name:'Total Facturas',		index:'Total Facturas', 	width:70, 	sortable: false,	align:"right",	fixed: true},
			{name:'IdRutaPago',			index:'IdRutaPago', 		width:100, 	sortable: false,	align:"center",	fixed: true, hidden: true},
			{name:'Ruta Pago',			index:'Ruta Pago', 			width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'Numero Tarjeta',		index:'Numero Tarjeta', 	width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'porcentaje',			index:'porcentaje', 		width:80, 	sortable: false,	align:"left",	fixed: true},
			{name:'total_empleados',	index:'total_empleados',	width:100, 	sortable: false,	align:"center",	fixed: true}
				
		],
		
			caption:'Reporte Pago Por Porcentaje',
			scrollrows : true,
			width:null,
			loadonce: false,
			shrinkToFit: false,
			height: 'auto',
			rowNum:-1,
			// rowList:[20, 30, 40, 50],
			pager: '#gridPorcentaje-pager',
			sortname: 'fechacorte, tipo, num_empleado',
			pgbuttons: false,
			pgtext: null,
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data) {
			var registros = jQuery("#gridPorcentaje-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id){
				if(id >= 0){
					
				}
			}
		});
			barButtongrid({
			pagId:"#gridPorcentaje-pager",
			position:"left",//center right
			Buttons:[
			{
				icon:"icon-print blue",
				title:'Imprimir',
				click:function (event)
				{
					if (($("#gridPorcentaje-table").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					} else {
						GenerarPdf();
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
	
//////////////////BOTON CONSULTAR/////////////////////
	$('#btn_consultar').click(function(event){
		$("#gridPorcentaje-table").jqGrid('clearGridData');
		llenarGridReportePorcentaje();
		event.preventDefault();	
	});
	
///////////////Función para cargar datos de grid//////////////////////
	
	function llenarGridReportePorcentaje()
	{
		var iPorcentaje = $('#cbo_porcentaje').val();
		var dFechaInicial = formatearFecha($('#txt_FechaInicio').val());
		var dFechaFinal = formatearFecha($('#txt_FechaFin').val());
		var iEmpresa = $("#cbo_empresa").val();
		var sUrl = '';
		
		sUrl = 'ajax/json/json_fun_obtener_reporte_pagos_por_porcentaje.php?&session_name='+Session;
		sUrl += '&iPorcentaje='+iPorcentaje;
		sUrl += '&dFechaInicial='+dFechaInicial;
		sUrl += '&dFechaFinal='+dFechaFinal;
		sUrl += '&idEmpresa='+iEmpresa;
		// console.log(sUrl);
		// return;
		$("#gridPorcentaje-table").jqGrid('setGridParam',{ url: sUrl,}).trigger("reloadGrid");
	}
	
////////////////////EXPORTAR PDF/////////////
		
	function GenerarPdf()
	{
		var iPorcentaje, iEmpresa, dFechaInicial, dFechaFinal;
		var sNomEmpresa = '';
		iPorcentaje = $('#cbo_porcentaje').val();
		iEmpresa = $("#cbo_empresa").val();
		sNomEmpresa = $("#cbo_empresa option:selected").text();
		dFechaInicial = formatearFecha($('#txt_FechaInicio').val());
		dFechaFinal = formatearFecha($('#txt_FechaFin').val());
		// sUrl = 'ajax/json/json_exportar_reporte_pagos_porcentaje.php?&session_name='+Session;
		
		var sNombreReporte = 'rpt_pagos_por_porcentaje'
			, iIdConexion = '190'
			, sFormatoReporte = 'pdf';
			
		var sUrl = "nombre_reporte=" + sNombreReporte + "&";
			sUrl += "id_conexion=" + iIdConexion + "&";
			sUrl += "dbms=postgres&";
			sUrl += "formato_reporte=" + sFormatoReporte + "&";
			sUrl += 'porcentaje='+iPorcentaje + "&";
			sUrl += 'fecha_inicial='+dFechaInicial + "&";
			sUrl += 'fecha_final='+dFechaFinal + "&";
			sUrl += 'empresa='+iEmpresa + "&";
			// sUrl += '&sNomEmpresa='+sNomEmpresa;
		console.log(sUrl);
		// return;
		
		
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
		// return;
		// $("#porcentaje").val( iPorcentaje );
		// $("#empresa").val( iEmpresa );
		// $("#fecha_inicial").val( dFechaInicial );
		// $("#fecha_final").val( dFechaFinal );
		
		// $("#formreporte").submit();
		//location.href = sUrl;
	}
	function CargarDescuentos(){
		//json_fun_obtener_descuentos_colegiaturas.php
		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_obtener_descuentos_colegiaturas.php',
			data: {},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				dataJson = json_decode(sanitizedData);
				if(dataJson.estado == 0){
					var option = "";//<option value='-1'>SELECCIONE</option>;<option value='0'>TODAS LAS SECCIONES</option>";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_porcentaje").html(option);
					var Sel = $("#cbo_porcentaje option").first().val();
					$("#cbo_porcentaje").val(Sel);
					$("#cbo_porcentaje" ).trigger("chosen:updated");
				} else {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los descuentos", "", "gritter-error");
				}			
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	function CargarEmpresas(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_listado_empresas_colegiaturas.php',
			data:{},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				dataJson = json_decode(sanitizedData);
				if(dataJson.estado == 0){
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length;i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_empresa").html(option);
					var Sel = $("#cbo_empresa option").first().val();
					$("#cbo_empresa").val(Sel);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}