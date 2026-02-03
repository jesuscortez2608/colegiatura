$(function() {
	//variables de consulta.
	var iRutaPago, iEstatus = 0, iTipo = 0;
	var cRutaPago, cEstatus = "";
	var cEmpresa = "", iEmpresa = 0;
	var dFechaInicio, dFechaFin = '19000101';
	setTimeout(InicializarFormulario(), 0);

	//:::::::::::::::::: FUNCIONES ;;;;;;;;;;;;;;;;;;;;;;;
	function InicializarFormulario(){
		//Fechas
		CargarFechas();
		//Grid
		CrearGridPagos();
		//Combos
		CargarComboRutaPago();
		CargarComboEstatus();
		
		CargarEmpresas();
	}
	function CargarComboEstatus()
	{
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_estatus_facturas.php",
			data: { 
				session_name:Session,
				'iTipo':iTipo
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0){
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
					}
					$("#cbo_Estatus").trigger("chosen:updated").html(option);
					$("#cbo_Estatus").trigger("chosen:updated");
				}
				else{
					showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	function Consultar(){
		$("#gridPagos-table").jqGrid('clearGridData');
		CargarVariablesConsulta();
		urlu = 'ajax/json/json_fun_obtener_reporte_de_pagos_colegiaturas.php?' +
			'session_name=' + Session +
			'&iRutaPago=' + iRutaPago +
			'&iEstatus=' + iEstatus +
			'&iEmpresa=' + iEmpresa +
			'&dFechaInicio=' + dFechaInicio +
			'&dFechaFin=' + dFechaFin;
		$("#gridPagos-table").jqGrid('setGridParam',{ url: urlu }).trigger("reloadGrid");
	}

	function CargarVariablesConsulta(){
		iRutaPago = $('#cbo_rutaPago').val();
		cRutaPago = $('#cbo_rutaPago option:selected').html();
		
		iEstatus = $('#cbo_Estatus').val();
		cEstatus = $('#cbo_Estatus option:selected').html();
		
		iEmpresa = $('#cbo_empresa').val();
		cEmpresa = $('#cbo_empresa option:selected').html();
		
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
	}
	
	function CargarComboRutaPago(){
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
		.always(function() {});
	}

	function CargarFechas(){
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
		
		var fecha,anio,mmes,ddia;
		fecha = Date().split(' ');
		anio = fecha[3];
		mmes = fecha[1];
		ddia = fecha[2];
		
		console.log(anio);
		console.log(mmes);
		console.log(ddia);
		
		$(".ui-datepicker-trigger").css('display','none');
	}
	
	function CrearGridPagos(){
		jQuery("#gridPagos-table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG12,
			colModel:[
				{name:'tipo_movimiento',index:'tipo_movimiento', width:50, sortable: false, align:"center", fixed: true, hidden: true},
				{name:'rango_fecha_mes',index:'rango_fecha_mes', width:70, sortable: false, align:"center", fixed: true},
				{name:'idu_empresa',index:'idu_empresa', width:50, sortable: false, align:"right", fixed: true, hidden: true},
				{name:'nom_empresa',index:'nom_empresa', width:150, sortable: false, align:"left", fixed: true},
				{name:'id_ruta_pago',index:'id_ruta_pago', width:70, sortable: false, align:"center", fixed: true, hidden: true},
				{name:'num_empleado',index:'num_empleado', width:90, sortable: false, align:"center",fixed: true },
				{name:'nom_empleado',index:'nom_empleado', width:250, sortable: false, align:"left",fixed: true},
				{name:'fecha', index:'fecha', width:90, sortable: false, align:"left", fixed: true },
				{name:'idu_centro',index:'idu_centro', width:90, sortable: false, align:"left",fixed: true, hidden: true },
				{name:'nombre_centro',index:'nombre_centro', width:280, sortable: false, align:"left", fixed: true},
				{name:'num_tarjeta',index:'num_tarjeta', width:110, sortable: false, align:"left", fixed: true},
				{name:'importe_concepto',index:'importe_concepto', width:90, sortable: false, align:"right", fixed: true},
				{name:'importe_pagado',index:'importe_pagado', width:100, sortable: false, align:"right", fixed: true},
				{name:'idu_tipo_deduccion',index:'idu_tipo_deduccion', width:100, sortable: false, align:"left",fixed: true, hidden:true},
				{name:'tipo_deduccion',index:'tipo_deduccion', width:110, sortable: false, align:"left",fixed: true},
				{name:'descuento',index:'descuento', width:70, sortable: false, align:"center", fixed: true},
				{name:'folio_factura',index:'folio_factura', width:290, sortable: false,align:"left", fixed: true},
				{name:'id_factura',index:'id_factura', width:290, sortable: false,align:"left", fixed: true, hidden:true}
			],
			caption:'Reporte Pagos Colegiaturas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height:350,
			rowNum:20,
			rowList:[20, 40, 60],
			pager: '#gridPagos-pager',
			sortname: 'idu_empresa,rango_fecha_mes,tipo_movimiento,idu_centro,num_empleado',
			sortorder: "asc",
			viewrecords: true,
			hidegrid: false,
			loadComplete: function (Data) {
				var registros = jQuery("#gridPagos-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			}
		});
		
		barButtongrid({
			pagId:"#gridPagos-pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-print blue",	
				title:'Imprimir reporte',
				click: function(event){
					
					if (($("#gridPagos-table").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}
					else
					{
						GenerarPdf();
					}	
					event.preventDefault();	
				}
			}]
		});
		setSizeBtnGrid('id_button0',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	function Imprimir(){
		var totalRenglones = jQuery("#gridPagos-table").jqGrid('getGridParam', 'reccount');
		CargarVariablesConsulta();
		if(totalRenglones > 0){
			var urlu='ajax/json/impresion_json_fun_obtener_reporte_de_pagos_colegiaturas.php?' +
				'session_name=' + Session +
				'&iRutaPago=' + iRutaPago +
				'&cRutaPago=' + cRutaPago +
				'&iEmpresa=' + iEmpresa +
				'&cEmpresa=' + cEmpresa +
				'&iEstatus=' + iEstatus +
				'&cEstatus=' + cEstatus +				
				'&dFechaInicio=' + dFechaInicio +
				'&dFechaFin=' + dFechaFin +
				'&page=-1' +
				'&rows=-1';
			
			location.href = urlu;
		}
	}
	
	function updatePagerIcons(table) {
		var replacement = 
		{
			'ui-icon-seek-first' : 'icon-double-angle-left bigger-140',
			'ui-icon-seek-prev' : 'icon-angle-left bigger-140',
			'ui-icon-seek-next' : 'icon-angle-right bigger-140',
			'ui-icon-seek-end' : 'icon-double-angle-right bigger-140'
		};
		$('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function(){
			var icon = $(this);
			var $class = (icon.attr('class').replace('ui-icon', '')).replace('/^\s+|\s+$/g', '');
			
			if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
		})
	};
	
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

	
	/////////Consulta datos grid
	$('#btn_consultar').click(function(event){
		Consultar();
		
		event.preventDefault();	
	})
	
	function GenerarPdf(){
		// Paimi Arizmendi López
		// 28/08/2018
		// Código para mostrar un mensaje de espera mientras se descarga 
		// un archivo
		// ---------------------------------------------------------------
		
		// Parámetros del reporte
		// ---------------------------------------------------------------
		var sNombreReporte = 'rpt_pagos_colegiaturas',
			iIdConexion = '190',
			sFormatoReporte = 'pdf';
		
		var params = "nombre_reporte=" + sNombreReporte + "&";
		params += "id_conexion=" + iIdConexion + "&";
		params += "dbms=postgres&";
		params += "formato_reporte=" + sFormatoReporte + "&";
		params += "empresa=" + $("#cbo_empresa").val() + "&";
		params += "ruta_pago=" + $("#cbo_rutaPago").val() + "&";
		params += "estatus=" + $("#cbo_Estatus").val() + "&";
		params += "tipo_deduccion=" + $("#cbo_tipoDeduccion").val() + "&";
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
	
})	
	