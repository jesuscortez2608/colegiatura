//Variables de consulta para el reporte
var iTipoDeduccion = 0;
var cTipoDeduccion = "";
var dFechaInicio, dFechaFin = '19000101';

$(function(){
	SessionIs();
	CrearControlesFechas();
	CargarGrid();
	
	setTimeout(function(){
		//waitwindow('Obteniendo datos iniciales', 'open');
		CargarEmpresas(function(){
			//waitwindow('', 'close');
			CargarComboTiposDeducciones();
		});
	}, 0);

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

	
	function CrearControlesFechas()
	{
		$("#txt_FechaIni").datepicker({
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
			onSelect: function(selectedDate) {
				$( "#txt_FechaFin" ).datepicker( "option", "minDate", selectedDate );
			}
		}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
		
		$("#txt_FechaFin").datepicker({
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
			onSelect: function(selectedDate) {
				$( "#txt_FechaIni" ).datepicker( "option", "maxDate", selectedDate );
			}
		}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
		
		$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
		$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
		
		$(".ui-datepicker-trigger").css('display','none');
		
		// $("#txt_FechaIni").val('01/07/2018');
		// $("#txt_FechaFin").val('31/07/2018');
	}
	
	function CargarComboTiposDeducciones(callback)
	{
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = "<option value='0'>TODOS </option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoDeduccion").html(option);
				$("#cbo_tipoDeduccion").trigger("chosen:updated");
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-info");
			}
			
			if ( callback != undefined ) {
				callback();
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-warning");
			$('#cbo_tipoDeduccion').fadeOut();
		})
		.always(function(){});
	}
	
	function CargarGrid()
	{
		jQuery("#gridAcumuladoColegiaturas_table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG13,
			colModel:[
				{name:'Empresa',index:'Empresa', width:150, sortable: false,fixed: true},
				{name:'Fecha',index:'Fecha', width:150, sortable: false,fixed: true},
				{name:'Cheques',index:'Cheques', width:110, sortable: false,align:"right",fixed: true},
				{name:'Banamex',index:'Banamex', width:110, sortable: false,align:"right",fixed: true},
				{name:'Invernomina',index:'Invernomina', width:110, sortable: false,align:"right",fixed: true},
				{name:'Bancomer',index:'Bancomer', width:110, sortable: false,align:"right",fixed: true},
				{name:'Bancoppel',index:'Bancoppel', width:100, sortable: false,align:"right",fixed: true},
				{name:'Total Importe',index:'Total Importe', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total Prestacion',index:'Total Prestacion', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total50',index:'Total50', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total51',index:'Total51', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total52',index:'Total52', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total53',index:'Total53', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total54',index:'Total54', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total55',index:'Total55', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total56',index:'Total56', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total57',index:'Total57', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total58',index:'Total58', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total59',index:'Total59', width:110, sortable: false,align:"right",fixed: true},
				
				{name:'Total60',index:'Total60', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total61',index:'Total61', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total62',index:'Total62', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total63',index:'Total63', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total64',index:'Total64', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total65',index:'Total65', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total66',index:'Total66', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total67',index:'Total67', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total68',index:'Total68', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total69',index:'Total69', width:110, sortable: false,align:"right",fixed: true},
				
				{name:'Total70',index:'Total70', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total71',index:'Total71', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total72',index:'Total72', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total73',index:'Total73', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total74',index:'Total74', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total75',index:'Total75', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total76',index:'Total76', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total77',index:'Total77', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total78',index:'Total78', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total79',index:'Total79', width:110, sortable: false,align:"right",fixed: true},
				
				{name:'Total80',index:'Total80', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total81',index:'Total81', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total82',index:'Total82', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total83',index:'Total83', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total84',index:'Total84', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total85',index:'Total85', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total86',index:'Total86', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total87',index:'Total87', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total88',index:'Total88', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total89',index:'Total89', width:110, sortable: false,align:"right",fixed: true},
				
				{name:'Total90',index:'Total90', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total91',index:'Total91', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total92',index:'Total92', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total93',index:'Total93', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total94',index:'Total94', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total95',index:'Total95', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total96',index:'Total96', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total97',index:'Total97', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total98',index:'Total98', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total99',index:'Total99', width:110, sortable: false,align:"right",fixed: true},
				
				{name:'Total100',index:'Total100', width:110, sortable: false,align:"right",fixed: true},
				
				{name:'Total Facturas',index:'Total Facturas', width:110, sortable: false,align:"right",fixed: true},
				{name:'Total Empleado',index:'Total Empleado', width:110, sortable: false,align:"right",fixed: true},
			],
			caption:'Reporte Acumulado de Colegiaturas',
			scrollrows : true,
			width:null,
			loadonce: false,
			ShrinkToFit: false,
			shrinkToFit: false,
			height:'auto',
			rowNum:-1,
			//rowList:[20, 40, 60],
			pager: '#gridAcumuladoColegiaturas_pager',
			sortname: 'dfecha,tipo',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data)
			{
				// Recorrer el resultado del grid para ocultar 
				// columnas que no se necesitan
				// -------------------------------------------------- 
				// Obtener la última fila
				var Jdata = $("#gridAcumuladoColegiaturas_table").jqGrid('getRowData', ($("#gridAcumuladoColegiaturas_table").find("tr").length - 1) ); 
				/*
				if (Jdata.Total50 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total50"]);
				if (Jdata.Total51 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total51"]);
				if (Jdata.Total52 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total52"]);
				if (Jdata.Total53 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total53"]);
				if (Jdata.Total54 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total54"]);
				if (Jdata.Total55 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total55"]);
				if (Jdata.Total56 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total56"]);
				if (Jdata.Total57 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total57"]);
				if (Jdata.Total58 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total58"]);
				if (Jdata.Total59 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total59"]);
				
				if (Jdata.Total60 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total60"]);
				if (Jdata.Total61 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total61"]);
				if (Jdata.Total62 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total62"]);
				if (Jdata.Total63 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total63"]);
				if (Jdata.Total64 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total64"]);
				if (Jdata.Total65 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total65"]);
				if (Jdata.Total66 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total66"]);
				if (Jdata.Total67 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total67"]);
				if (Jdata.Total68 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total68"]);
				if (Jdata.Total69 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total69"]);
				
				if (Jdata.Total70 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total70"]);
				if (Jdata.Total71 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total71"]);
				if (Jdata.Total72 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total72"]);
				if (Jdata.Total73 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total73"]);
				if (Jdata.Total74 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total74"]);
				if (Jdata.Total75 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total75"]);
				if (Jdata.Total76 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total76"]);
				if (Jdata.Total77 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total77"]);
				if (Jdata.Total78 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total78"]);
				if (Jdata.Total79 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total79"]);
				
				if (Jdata.Total80 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total80"]);
				if (Jdata.Total81 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total81"]);
				if (Jdata.Total82 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total82"]);
				if (Jdata.Total83 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total83"]);
				if (Jdata.Total84 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total84"]);
				if (Jdata.Total85 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total85"]);
				if (Jdata.Total86 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total86"]);
				if (Jdata.Total87 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total87"]);
				if (Jdata.Total88 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total88"]);
				if (Jdata.Total89 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total89"]);
				
				if (Jdata.Total90 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total90"]);
				if (Jdata.Total91 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total91"]);
				if (Jdata.Total92 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total92"]);
				if (Jdata.Total93 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total93"]);
				if (Jdata.Total94 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total94"]);
				if (Jdata.Total95 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total95"]);
				if (Jdata.Total96 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total96"]);
				if (Jdata.Total97 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total97"]);
				if (Jdata.Total98 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total98"]);
				if (Jdata.Total99 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total99"]);
				
				if (Jdata.Total100 == "<b>0</b>") $("#gridAcumuladoColegiaturas_table").jqGrid('hideCol',["Total100"]);
				*/
				
				var registros = jQuery("#gridAcumuladoColegiaturas_table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
					//fixGrid({position:true,grid:'#gridAcumuladoColegiaturas_table', stretch: true, width: 'px',ctrlbuttons:true, scroll:true}); 
				}, 10);
			},
			onSelectRow: function(Data)
			{
				/*var Data = jQuery("#gridAcumuladoColegiaturas-table").jqGrid('getRowData',Numemp);
				Numemp =Data.Numemp;*/
			}
		});
		
		$("#gridAcumuladoColegiaturas_pager_center").hide();
		
		barButtongrid({
			pagId:"#gridAcumuladoColegiaturas_pager",
			position:"left",//center right
			Buttons:[
			{
				icon:"icon-print blue",
				title:'Imprimir reporte',
				click:function (event)
				{
					if (($("#gridAcumuladoColegiaturas_table").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}
					else
					{
						GenerarPdf();
					}
					event.preventDefault();	
				},
			}]
		})
		setSizeBtnGrid('id_button0',35);
	}
	
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	
	function CargarEmpresas(callback){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_listado_empresas_colegiaturas_cc.php',
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
				
				if (callback != undefined) {
					callback();
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function fnConsultarReporte()
	{
		$("#gridAcumuladoColegiaturas_table").jqGrid('clearGridData');
		CargarVariablesConsulta();
		$("#gridAcumuladoColegiaturas_table").jqGrid('setGridParam', { 
			url: 'ajax/json/json_fun_obtener_reporte_acumulado_colegiaturas.php?' + 
				'iTipoDeduccion=' + iTipoDeduccion +
				'&iEmpresa=' + $("#cbo_empresa").val() +
				'&dFechaInicio=' + dFechaInicio +
				'&dFechaFin=' + dFechaFin +
				'&session_name=' +Session,
		}).trigger("reloadGrid");
	}
	
	function CargarVariablesConsulta() {
		//Variables de consulta para el reporte
		iTipoDeduccion = $("#cbo_tipoDeduccion").val();
		cTipoDeduccion = $('#cbo_tipoDeduccion option:selected').html();;
		dFechaInicio = formatearFecha($('#txt_FechaIni').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
	}
	
	function GenerarPdf(){
		// Paimi Arizmendi López
		// 28/08/2018
		// Código para mostrar un mensaje de espera mientras se descarga 
		// un archivo
		// ---------------------------------------------------------------
		
		// Parámetros del reporte
		// ---------------------------------------------------------------
		dFechaInicial = formatearFecha($('#txt_FechaIni').val());
		dFechaFinal = formatearFecha($('#txt_FechaFin').val());
		
		var sNombreReporte = 'rpt_acumulado_colegiaturas',
			iIdConexion = '190',
			sFormatoReporte = 'pdf',
			iTipoDeduccion = $("#cbo_tipoDeduccion").val();
		
		var params = "nombre_reporte=" + sNombreReporte + "&";
		params += "id_conexion=" + iIdConexion + "&";
		params += "dbms=postgres&";
		params += "formato_reporte=" + sFormatoReporte + "&";
		params += "fecha_inicial=" + dFechaInicial + "&";
		params += "fecha_final=" + dFechaFinal + "&";
		params += "tipo_deduccion=" + iTipoDeduccion + "&";
		params += "iempresa=" + $("#cbo_empresa").val() + "&";
		
		var xhr = new XMLHttpRequest();
		var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS_SPRING + '/reportes';
		
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
		xhr.send(params);
	}
	
	$("#btn_consultar").click(function(event){
		fnConsultarReporte();
		event.preventDefault();	
	});
	
	// $("#btn_areas").click(function(event){
		// $.ajax({type:'GET',
			// url:oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS + '/catalogos/areas',
			// data:{},
			// beforeSend:function(){},
			// success:function(data){
				// for(var i in data){
					// console.log(data[i].nombre);
				// }
			// },
			// error:function onError(){},
			// complete:function(){},
			// timeout: function(){},
			// abort: function(){}
		// });
		
		// event.preventDefault();
	// });
});



	

