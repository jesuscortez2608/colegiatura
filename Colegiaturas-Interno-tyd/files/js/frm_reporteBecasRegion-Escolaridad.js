$(function(){
	var iRutaPago, iEstatus, iTipoDeduccion, iEmpresa = 0;
	var cRutaPago, cEstatus, cTipoDeduccion, cNombreEmpresa = "";
	var dFechaInicio, dFechaFin = "";
	var arrayEscolaridades = [];  //--- Arreglo de escolaridades.
	var gridNombresColumnas = []; //--- Arreglo que almacena los nombres(Encabezados) de las columnas del grid.
	var gridModeloColumnas = [];  //--- Arreglo que almacena el cuerpo(Modelo) de las columnas del grid.
	
	var datosReporte = [];
	
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

	
	waitwindow('Cargando','open');
	setTimeout(function(){
		Inicializarformulario();
	}, 0);
	
	/* FUNCIONES ======================================= */
	function Inicializarformulario()
	{
		CargarGrid();
		
		CrearControlesFechas();
		
		CargarComboRutaPago(function(){
			CargarComboEstatus(function(){
				CargarComboTiposDeducciones(function(){
					DesbloquearFormulario();
					CargarEmpresas();
				});
			});
		});
	}
	
	function DesbloquearFormulario()
	{
		waitwindow('Cargando','close');
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
			showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {
			callback();
		});
	};
	
	function CargarComboEstatus(callback)
	{
		var option = "";
		$.ajax({
			type: "POST",
			url: "ajax/json/json_fun_obtener_estatus_facturas.php",
			data: { } 
		})
		.done(function(data) {
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
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" los estatus de facturas", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los estatus de facturas", "", "gritter-error");
			$('#cbo_Estatus').fadeOut();
		})
		.always(function() {
			callback();
		});
	}
	
	function CargarComboRutaPago(callback)
	{
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_rutas_pago.php",
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
				$("#cbo_rutaPago").html(option);
				$("#cbo_rutaPago").trigger("chosen:updated");
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
		})
		.always(function() {
			callback();
		});
	}
	
	function CrearControlesFechas()
	{
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
	
	function CargarVariablesConsulta()
	{
		iRutaPago = $("#cbo_rutaPago").val();
		iEstatus = $("#cbo_Estatus").val();
		iTipoDeduccion = $("#cbo_tipoDeduccion").val();
		iEmpresa = $("#cbo_empresa").val();
		
		cRutaPago = $('#cbo_rutaPago option:selected').html();
		cEstatus = $('#cbo_Estatus option:selected').html();
		cTipoDeduccion = $('#cbo_tipoDeduccion option:selected').html();
		cNombreEmpresa = $("#cbo_empresa option:selected").html();
		
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
	}
	
	function CargarGrid(){
		$("#gridReporteRegionEscolaridad-table").jqGrid("GridUnload");
		$("#gridReporteRegionEscolaridad-table").jqGrid({
			url:'',
			datatype:'json',
			colNames:LengStr.idMSG122,
			colModel:[
				{name:'idu_empresa',	index:'idu_empresa',	width:10,	sortable:false,	align:"right",	fixed:true,	hidden:true},
				{name:'nom_empresa', 	index:'nom_empresa',	width:150,	sortable:false,	align:"left",	fixed:true},
				{name:'idu_region',		index:'idu_region',		width:10,	sortable:false,	align:"left",	fixed:true, hidden:true},
				{name:'nom_region',		index:'nom_region',		width:150,	sortable:false,	align:"left",	fixed:true},
				{name:'idu_escolaridad_1', index:'idu_escolaridad_1', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_2', index:'idu_escolaridad_2', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_3', index:'idu_escolaridad_3', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_4', index:'idu_escolaridad_4', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_5', index:'idu_escolaridad_5', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_6', index:'idu_escolaridad_6', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_7', index:'idu_escolaridad_7', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_8', index:'idu_escolaridad_8', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_9', index:'idu_escolaridad_9', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'idu_escolaridad_10', index:'idu_escolaridad_10', width:110,	sortable:false,	align:"right",	fixed:true},
				{name:'total_general',	index:'total_general',	width:150,	sortable:false,	align:"right",	fixed:true}
			],
			scrollrows:true,
			width:null,
			loadonce:false,
			shrinkToFit:false,
			height:'auto',
			rowNum:-1,
			//rowList:[10, 20, 30],
			pager:'#gridReporteRegionEscolaridad-pager',
			align:'center',
			sortname:'',
			sortorder:'',
			viewrecords:true,
			hidegrid:false,
			caption:'Reporte de Becas por Regi&oacute;n-Escolaridad',
			loadComplete:function(data){
				var registros = jQuery("#gridReporteRegionEscolaridad-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table=this;
				setTimeout(function(){
					updatePagerIcons(table);
				},0);
			},
		});
		
		barButtongrid({
			pagId:'#gridReporteRegionEscolaridad-pager',
			position:'left',
			Buttons:[
			{
				icon:'icon-print',
				title:'Imprimir',
				click:function(event){
					if(($("#gridReporteRegionEscolaridad-table").find("tr").length - 1) == 0){
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}else{
						GenerarPdf();
					}
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid("id_button0", 35);
	}
	
	function setSizeBtnGrid(id,tamanio) {
		$("#"+id).attr('width',tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	
	function ActualizarGrid() {
		iRutaPago = $("#cbo_rutaPago").val();
		iEstatus = $("#cbo_Estatus").val();
		iTipoDeduccion = $("#cbo_tipoDeduccion").val();
		iEmpresa = $("#cbo_empresa").val();
		
		cRutaPago = $('#cbo_rutaPago option:selected').html();
		cEstatus = $('#cbo_Estatus option:selected').html();
		cTipoDeduccion = $('#cbo_tipoDeduccion option:selected').html();
		cNombreEmpresa = $("#cbo_empresa option:selected").html();
		
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
		
		sUrl = 'ajax/json/json_fun_obtener_reporte_colegiaturas_region_escolaridad_dinamico.php?&session_name=' + Session + '&';
		sUrl += 'iRutaPago=' + iRutaPago + '&';
		sUrl += 'iEstatus=' + iEstatus + '&';
		sUrl += 'iTipoDeduccion=' + iTipoDeduccion + '&';
		sUrl += 'iEmpresa=' + iEmpresa + '&';
		sUrl += 'dFechaInicio=' + dFechaInicio + '&';
		sUrl += 'dFechaFin=' + dFechaFin + '&';
		
		$("#gridReporteRegionEscolaridad-table").jqGrid('clearGridData');
		$("#gridReporteRegionEscolaridad-table").jqGrid('setGridParam', {
			url: sUrl,
		}).trigger("reloadGrid");
	}
	
	function CargarEmpresas(){
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
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	/* EVENTOS ======================================= */
	$("#btn_consultar").click(function(event){
		ActualizarGrid();
		event.preventDefault();
	});
	
	
	function GenerarPdf(){
		// Paimi Arizmendi López
		// 28/08/2018
		// Código para mostrar un mensaje de espera mientras se descarga 
		// un archivo
		// ---------------------------------------------------------------
		
		// Parámetros del reporte
		// ---------------------------------------------------------------
		var sNombreReporte = 'rpt_becas_region_escolaridad',
			iIdConexion = '190',
			sFormatoReporte = 'pdf';
		
		var params = "nombre_reporte=" + sNombreReporte + "&";
		params += "id_conexion=" + iIdConexion + "&";
		params += "dbms=postgres&";
		params += "formato_reporte=" + sFormatoReporte + "&";
		params += "ruta_pago=" + $("#cbo_rutaPago").val() + "&";
		params += "estatus=" + $("#cbo_Estatus").val() + "&";
		params += "tipo_deduccion=" + $("#cbo_tipoDeduccion").val() + "&";
		params += "empresa=" + $("#cbo_empresa").val() + "&";
		params += "fecha_inicial=" + formatearFecha($('#txt_FechaInicio').val()) + "&";
		params += "fecha_final=" + formatearFecha($('#txt_FechaFin').val()) + "&";
		
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
		xhr.send(params);
	}
});