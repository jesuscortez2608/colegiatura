function sanitize(string) { //función para sanitizar variables en JS
	var listaElementos = [];
	var returnList = [];
	var entity = {};
	var iEmpleado;
	var folFactura;
	var iFactura;
	entity.properti = "";
	listaElementos.push(entity);
	listaElementos.forEach(function (item) {
	item.properti = string;
	returnList.push(item);
	});
return returnList[0].properti;
  }

   //función para hacer un Trim y evitar vulnerabilidades :) 
 // ejemplo: var.makeTrim(" ");
 SessionIs();
 String.prototype.makeTrim = function (characters) {

	let result = this;

	for (let i = 0; i < characters.length; i++) {
		while (result.charAt(0) === characters[i]) {
			result = result.substring(1);
		}

		while (result.charAt(result.length - 1) === characters[i]) {
			result = result.substring(0, result.length - 1);
		}
	}
	return result;
}

$(function(){
	SessionIs();
	fnEstructuraGridConsulta();
	llenarComboEstatus();
	stopScrolling(function(){
		dragablesModal();
	});

	////Variables globales
	var NumEmpParametro, FolioFacParametro, EstatusParametro, ObservacionesParametro, NumFacturaParametro, nEstatus;
	var iOpcionFecha = 0
		, FechaIni = ''
		, FechaFin = ''
		, iEstatus = 0;
		
		
	function stopScrolling(callback) {
		$("#dlg_BeneficiariosFactura").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
	}
	function dragablesModal(){
		$(".draggable").draggable({
			// commenting the line below will make scrolling while dragging work
			helper: "clone",
			scroll: true,
			revert: "invalid"
		});
	}
	///////////////Configuración de Controles Fechas////////////////////////////////
	$("#txt_FechaIni").datepicker({
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
	// $("#txt_FechaIni").datepicker("setDate",new Date());
	$("#txt_FechaFin").datepicker("setDate",new Date());

	$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
	
	$(".ui-datepicker-trigger").css('display','none');
	
	// $("#txt_FechaIni").prop('disabled', true);
	// $("#txt_FechaFin").prop('disabled', true);
	

	////Cuando el check este selecciono se desbloquean datapicker
  
	$("#chkbx_fecha").change(function(event){
		if($("#chkbx_fecha").is(":checked")){
			$("#txt_FechaIni").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
			iOpcionFecha = 1;
		}else{
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
			LimpiarFechas();
			iOpcionFecha = 0;
		}
		event.preventDefault();
	});
	function LimpiarFechas(){
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val());
	}		
	$("#cbo_estatus").change(function(event)
	{
		iEstatus = $("#cbo_estatus").val();
		$("#gridConsulta-table").jqGrid("clearGridData");
		$("#Observaciones").hide();
		$("#txt_observaciones").val("");		
		event.preventDefault();
	});


///////////////////////OBTENER DATOS DE FACTURA CON XML////////////////////////////

function obtenerDatosFacturasConXML(empleado, folioFactura)
{
	
	$.ajax({type: "GET",
		url: "ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?",
		data: { 
			'iOpcion': 0,
			'sEmpleados': empleado,
			'tipo': $("#cbo_estatus").val(),
			'session_name': Session,
			'rows': 10,
			'page': 1,
			'sord': 'asc'
			
		},
		beforeSend:function(){},
		success:function(data){
			var dataS = sanitize(data);
			dataJson = JSON.parse(dataS);
			iFactura = buscarXML(dataJson.rows, folioFactura);
		}
	});		
}

///////////////////////BUSCAR XML DENTRO DE JSON////////////////////////////

function buscarXML(data, folio) {
	 // Verificar si contiene la cadena "34D7BCBC-953B-4942-8B8D-218434A3DA98"
	 var factura = 0
	 dataRecorre = data.length -1
	 for (let i = 0; i <= dataRecorre; i++) {
		if (data[i].cell[8] == folio && data[i].cell[28].length > 0){
			//console.log(data[i]);
			factura = 1;
		}
	}
	return factura
}

///////////////////////GRID CONSULTA////////////////////////////
	function fnEstructuraGridConsulta()
	{
		jQuery("#gridConsulta-table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG14,
			colModel:[
			{name:'idfactura'			,index:'idfactura'			,width:70, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},	
			{name:'fec_factura'			,index:'fec_factura'		,width:80, 	sortable: false,	align:"left",	fixed: true},	
			{name:'fol_factura'			,index:'fol_factura'		,width:270,	sortable: false,	align:"center",	fixed: true},	
			{name:'idu_tipodocumento'	,index:'idu_tipodocumento'	,width:100,	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_tipodocumento'	,index:'nom_tipodocumento'	,width:100,	sortable: false,	align:"left",	fixed: true},			
			{name:'serie'				,index:'serie'				,width:80, 	sortable: false,	align:"center",	fixed: true},
			{name:'id_empleado'			,index:'id_empleado'		,width:70, 	sortable: false,	align:"center",	fixed: true},	
			{name:'nom_empleado'		,index:'nom_empleado'		,width:220,	sortable: false,	align:"left",	fixed: true},
			{name:'id_centro'			,index:'id_centro'			,width:55, 	sortable: false,	align:"center",	fixed: true},
			{name:'nom_centro'			,index:'nom_centro'			,width:200,	sortable: false,	align:"left",	fixed: true},
			{name:'ottp'				,index:'ottp'				,width:45, 	sortable: false,	align:'center', formatter: 'checkbox', edittype: 'checkbox', editoptions: {value: '1:0', defaultValue: '1'}},
			{name:'fec_captura'			,index:'fec_captura'		,width:100,	sortable: false,	align:"left",	fixed: true},
			{name:'id_escuela'			,index:'id_escuela'			,width:100,	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_escuela'			,index:'nom_escuela'		,width:180,	sortable: false,	align:"left",	fixed: true},	
			{name:'imp_factura'			,index:'imp_factura'		,width:80, 	sortable: false,	align:"right",	fixed: true},	
			{name:'fec_pago'			,index:'fec_pago'			,width:80, 	sortable: false,	align:"center",	fixed: true},	
			{name:'id_rutapago'			,index:'id_rutapago'		,width:100,	sortable: false,	align:"center",	fixed: true, 	hidden:true},
			{name:'nom_rutapago'		,index:'nom_rutapago'		,width:100,	sortable: false,	align:"center",	fixed: true},	
			{name:'imp_a_pagar'			,index:'imp_a_pagar'		,width:80, 	sortable: false,	align:"right",	fixed: true},	
			{name:'id_ciclo_escolar'	,index:'id_ciclo_escolar'	,width:100,	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'ciclo_escolar'		,index:'ciclo_escolar'		,width:100,	sortable: false,	align:"center",	fixed: true},		
			{name:'id_estatus'			,index:'id_estatus'			,width:100,	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_estatus'			,index:'nom_estatus'		,width:80, 	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_estatus'			,index:'fec_estatus'		,width:100,	sortable: false,	align:"center",	fixed: true},	
			{name:'num_modifico_estatus',index:'Modifico_estatus'	,width:100,	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_modifico_estatus',index:'Modifico_estatus'	,width:200,	sortable: false,	align:"left",	fixed: true},	
			{name:'num_tarjeta'			,index:'num_tarjeta'		,width:100,	sortable: false,	align:"left",	fixed: true},	
			{name:'fec_baja'			,index:'fec_baja'			,width:100,	sortable: false,	align:"center",	fixed: true},	
			{name:'des_observaciones'	,index:'des_observaciones'	,width:100,	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_Autorizo_Gte'	,index:'nom_Autorizo_Gte'	,width:250,	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_Autorizo_Gte'	,index:'fec_Autorizo_Gte'	,width:80,	sortable: false,	align:"center",	fixed: true},	
			{name:'nom_Rechazo_Gte'		,index:'nom_Rechazo_Gte'	,width:250,	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_Rechazo_Gte'		,index:'fec_Rechazo_Gte'	,width:80,	sortable: false,	align:"center",	fixed: true},	
			{name:'nom_Rechazo_Admon'	,index:'nom_Rechazo_Admon'	,width:300,	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_Rechazo_Admon'	,index:'fec_Rechazo_Admon'	,width:80,	sortable: false,	align:"center",	fixed: true},	
			{name:'nom_Aclaracion'		,index:'nom_Aclaración'		,width:300,	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_Aclaracion'		,index:'fec_Aclaracion'		,width: 80,	sortable: false,	align:"center",	fixed: true},	
			{name:'nom_Justificacion'	,index:'nom_Justificacion'	,width:300,	sortable: false,	align:"center",	fixed: true},	
			{name:'aceptada_Por_Pagar'	,index:'aceptada_Por_Pagar',width:300,	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_Aceptada_por_pagar',index:'fec_Aceptada_por_pagar',width:80,	sortable: false,	align:"center",	fixed: true},	
			{name:'fec_pago'			,index:'fec_pago'			,width:80,	sortable: false,	align:"center",	fixed: true},	

			],

			caption:'Consultar Facturas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 300,
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gridConsulta-pager',
			sortname: 'fec_captura',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data) {
			var registros = jQuery("#gridConsulta-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					//showmessage('No se encontraron datos en la consulta', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id) {
				if(id >= 0){
					var fila = jQuery("#gridConsulta-table").getRowData(id);
					NumFacturaParametro = fila.idfactura;
					NumEmpParametro = fila.id_empleado;
					iEmpleado = fila.id_empleado;
					FolioFacParametro = fila.fol_factura;
					folFactura = fila.fol_factura;
					EstatusParametro = fila.id_estatus;
					ObservacionesParametro = fila.des_observaciones;
					var ottpValor = fila.ottp;
				}	
				if (EstatusParametro == 3)
				{
					$('#Observaciones').css('display','block');
					$('#txt_observaciones').val(ObservacionesParametro);
				}
				else
				{
					$('#Observaciones').css('display','none');
				}
			}
		});			
		 barButtongrid({
			pagId:'#gridConsulta-pager',
			position:'left',//center rigth
			Buttons:[
				{
					icon:'icon-list blue',
					click:function(event){
							//console.log(iEmpleado);
							iFactura = obtenerDatosFacturasConXML(iEmpleado, folFactura);
							var selr = jQuery('#gridConsulta-table').jqGrid('getGridParam','selrow');
							var rowData = jQuery('#gridConsulta-table').getRowData(selr);
							//console.log(rowData);
							if (($("#gridConsulta-table").find("tr").length - 1) == 0 ) {
								//message('No hay información');
								showalert(LengStrMSG.idMSG86, "", "gritter-info");
								return;
							}
							else if(NumFacturaParametro != 0){
								if(rowData.archivo1 == ''){
									showalert("La factura no tiene un XML relacionado", "", "gritter-info");
									return;
								}else{
									
									cargarFactura();
								}
								
							}else{
								showalert("Seleccione un registro", "", "gritter-info");
								return;
							}
						event.preventDefault();
					},
					title:'Ver Factura',
				},
				{
					icon:'icon-group pink',
					click:function(event){
						if(($('#gridConsulta-table').find('tr').length - 1) == 0){
							showalert(LengStrMSG.idMSG255, "", "gritter-info");
						}else{
							var selr = jQuery('#gridConsulta-table').jqGrid('getGridParam', 'selrow');
							if (selr){
								$('#gd_BeneficiariosFactura').jqGrid('clearGridData');
								$('#gd_BeneficiariosFactura').jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_por_factura.php?iEmpleado=' + NumEmpParametro + '&iFactura=' + NumFacturaParametro + '&inicializar=0'}).trigger('reloadGrid');
								
								$('#dlg_BeneficiariosFactura').modal('toggle');
								
								$('#dlg_BeneficiariosFactura').modal('show');
							}else{
								showalert(LengStrMSG.idMSG256, '', 'gritter-info');
							}
						}
						event.preventDefault();
					},
					title:'Beneficiarios Factura',
					style: 'font-size: 35px; width: 100%;',
				},
				{
					icon:'icon-print blue',
					click: function(event){
						if(($('#gridConsulta-table').find('tr').length - 1) == 0){
							showalert(LengStrMSG.idMSG87, '', 'gritter-info');
						}else{
							GenerarPdf();
						}
						event.preventDefault();
					},
					title:'Imprimir',
				}
			]
		});

		////////////////////CARGAR FACTURA /////////////////////////////////

		function cargarFactura(){
			var dataJson
			$.ajax({
				type:'POST',
				url:'ajax/json/json_leerfactura.php',
				data:{
					session_name : Session
					, 'nIsFactura' : 0
					// , 'sFacFiscal' : $("#sFacFiscal").val()
					, 'idFactura' : NumFacturaParametro
					, 'sFilename' : $("#sFilename").val()
					, 'sFiliePath' : $("#sFiliePath").val()
				},
			})
			.done(function(data){
				SessionIs();
				var dataS = sanitize(data);
				dataJson = json_decode(dataS);
				
				if(dataJson.estado == 0){
					leerFactura(dataJson);
					abrirFacturaPestana(dataJson);
				}else{
					loadIs = true;
					showalert(dataJson.mensaje, "", "gritter-info");
				}
			})
			.fail(function(s) {alert("Error al cargar ajax/json/json_leerfactura.php"); $('#pag_content').fadeOut();})
			.always(function() {});
			
			
		}
	
		function abrirFacturaPestana(dataJson) {
	
			var nuevaPestana = document.implementation.createHTMLDocument("Factura");
			//console.log("hola" + dataJson);
			nuevaPestana.body.innerHTML = dataJson.isFactura == 0 ? "<img src='" + dataJson.noDeducible + "' alt='Error: 404 not found'/>" : dataJson.factura;
			nuevaPestana.body.style.transform = 'scale(0.9)';
			nuevaPestana.body.style.alignItems = 'center';
			var pestana = window.open("");
			pestana.opener = null;
			pestana.document.write(nuevaPestana.documentElement.outerHTML);
		}	
		
		function leerFactura(obj){
			if(obj.isFactura == 0){
				$("#div_contenido").html("<img src='"+obj.noDeducible+"' alt='Error: 404 not found'/>");
				
			}else{
				$("#div_contenido").html(obj.factura);
				$("#btn_ver").click();
			}
			loadIs = true;
		}
		
		jQuery("#gd_BeneficiariosFactura").jqGrid({
				datatype: 'json',
				colNames:LengStr.idMSG126,
				colModel:[
			{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
			{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:250, 	sortable: false,	align:"left",	fixed: true},
			{name:'fec_nac_beneficiario',		index:'fec_nac_beneficiario', 	width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'edad_anio_beneficiario',		index:'edad_anio_beneficiario', 	width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'idu_parentesco',		index:'idu_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_parentesco',		index:'nom_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_tipo_pago',		index:'idu_tipo_pago', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'des_tipo_pago',		index:'des_tipo_pago', 		width:150, 	sortable: false,	align:"left",	fixed: true},
			{name:'nom_periodo',		index:'nom_periodo', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_carrera',		index:'idu_carrera', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_carrera',		index:'nom_carrera', 		width:200, 	sortable: false,	align:"left",	fixed: true,	hidden:false},
			{name:'imp_importeF',		index:'imp_importeF', 		width:70, 	sortable: false,	align:"right"},
			{name:'imp_importe',		index:'imp_importe', 		width:70, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
			{name:'idu_grado',			index:'idu_grado', 			width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_grado',			index:'nom_grado', 			width:130, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_ciclo',			index:'idu_ciclo', 			width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_ciclo_escolar',	index:'nom_ciclo_escolar', 	width:90, 	sortable: false,	align:"left",	fixed: true},
			{name:'descuento',			index:'descuento', 			width:70, 	sortable: false,	align:"right",	fixed: true},
			{name:'comentario',			index:'comentario', 		width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'keyx',				index:'keyx', 				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true}
				],
				scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
				viewrecords : false,
				rowNum:-1,
				hidegrid: false,
				rowList:[],
				width: null,
				shrinkToFit: false,
				height: 120,
				pgbuttons: false,
				pgtext: null,
				caption:' ',
				loadComplete: function (Data) {
				},
				onSelectRow: function(id) {
				}					
			});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
		setSizeBtnGrid('id_button2',35);			
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	///////////////////////////Llenar combo estatus
	function llenarComboEstatus(callback) 
	{
		var option="";
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_estatus_facturas.php",
		data: { }
		}).done(function(data){
			var dataS = sanitize(data);
			var dataJson = JSON.parse(dataS);
			if(dataJson.estado == 0)
			{

				// option = "<option value='-1'>TODOS</option>";
				option = "";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
				}
				$("#cbo_estatus").trigger("chosen:updated").html(option);
				$("#cbo_estatus").trigger("chosen:updated");
				if (callback != undefined) {
					callback();
				}
			}
			else
			{
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los estatus", "", "gritter-warning");
			}
		})
		.fail(function(s) {
			// message("Error al cargar json_fun_obtener_estatus_facturas.php" ); 
			showalert(LengStrMSG.idMSG88+" los estatus", "", "gritter-warning");
			$('#cbo_estatus').fadeOut();})
		.always(function() {});
	}
		

	//////////////////BOTON CONSULTAR///////////////////////////////////////////////
		$('#btn_consultar').click(function(event) 
		{
			// var CheckFecha = $('#chkbx_fecha').prop('checked')?1:0;
			// console.log(CheckFecha);
			$("#Observaciones").hide();
			$("#txt_observaciones").val("");	
			var params = "";
			var FechaInicial = "";
			var FechaFinal = "";
			var FolioFactura =  $('#txt_Folio').val().makeTrim(" ").toUpperCase();
			FechaInicial = formatearFecha($('#txt_FechaIni').val());
			FechaFinal = formatearFecha($('#txt_FechaFin').val());
			
			// if(iOpcionFecha == 1)
			// {
				// FechaInicial = formatearFecha($('#txt_FechaIni').val());
				// FechaFinal = formatearFecha($('#txt_FechaFin').val());
			// }
			// else
			// {
				// FechaInicial = '19000101';
				// FechaFinal = '19000101';
			// }	

				params += "estatus=" + $('#cbo_estatus').val() + "&";
				params += "fechaini=" + FechaInicial + "&";
				params += "fechafin=" + FechaFinal + "&";
				params += "CheckFecha=" + 1 + "&";
				params += "FolioFactura=" + FolioFactura + "&";
				params += "session_name=" + Session + "&";
			
			// if (iOpcionFecha == 0)
			// {
				// $("#txt_FechaIni" ).datepicker("setDate",new Date());
				// $("#txt_FechaFin" ).datepicker("setDate",new Date());
			// }

			if ($('#txt_Folio').val().length != 0)
			{
				// $("#txt_FechaIni" ).datepicker("setDate",new Date());
				// $("#txt_FechaFin" ).datepicker("setDate",new Date());
			}
			llenarGridFacturas(params);
			event.preventDefault();	
		});
		
	////////////////////////Función para cargar datos de grid//////////////////////////////////
	
	function llenarGridFacturas (params)
	{
		$("#gridConsulta-table").jqGrid("clearGridData");
		$("#gridConsulta-table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_facturas_colegiatura.php?&' + params}).trigger("reloadGrid");
		// $("#gridConsulta-table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_facturas_colegiatura_cc.php?&' + params}).trigger("reloadGrid");
	}
		
	////////////Nueva consulta
	
	$("#btn_NuevaConsulta").click(function(event) {  
		$("#txt_Folio").val("");
		$('#cbo_estatus').val(-1);
		$("#chkbx_fecha").prop("checked", false);
		$("#txt_FechaIni").datepicker("setDate",new Date());
		$("#txt_FechaFin").datepicker("setDate",new Date());
		$("#txt_FechaFin").val($("#txt_FechaIni").val());
		$('#txt_FechaIni').prop('disabled', true);
		$('#txt_FechaFin').prop('disabled', true);
		$("#Observaciones").hide();
		$("#txt_observaciones").val("");
		$('#gridConsulta-table').jqGrid('clearGridData');
		iOpcionFecha = 0;
		event.preventDefault();			
    });  
	
	
	////////////////////EXPORTAR PDF/////////////
	function GenerarPdf()
	{
		var iCheckFecha = 1
			, sFolFactura = ''
			, iEstatus = $("#cbo_estatus").val()
			, FechaInicial = formatearFecha($("#txt_FechaIni").val())
			, FechaFinal = formatearFecha($("#txt_FechaFin").val())
			, iRowsPerPage = -1
			, iPage = -1
			, sOrderBy = 'fec_captura'
			, sOrderType = 'ASC'
			, sColumns = '';
			
			if ($("#txt_Folio").val().makeTrim(" ") != '') {
				sFolFactura = $("#txt_Folio").val().makeTrim(" ").toUpperCase();
			}
			sColumns += 'idfactura,fec_factura,fol_factura,serie,id_empleado,nom_empleado,id_centro, nom_centro,ottp,fec_captura';
			sColumns += ',id_escuela,nom_escuela,imp_factura,fec_pago,id_rutapago,nom_rutapago,imp_a_pagar,id_ciclo_escolar';
			sColumns += ',ciclo_escolar,id_estatus,nom_estatus,fec_estatus,num_modifico_estatus, nom_modifico_estatus';
			sColumns += ',num_tarjeta,fec_baja,des_observaciones, id_tipodocumento, nom_tipodocumento';
			
			
		var sNombreReporte = 'rpt_consulta_facturas'
			, iIdConexion = '190'
			, sFormatoReporte = 'pdf';
			
		var sUrl = '';
			sUrl += 'nombre_reporte='+sNombreReporte;
			sUrl += '&id_conexion='+iIdConexion;
			sUrl += '&dbms=postgres';
			sUrl += '&formato_reporte='+sFormatoReporte;
			sUrl += '&iEstatus='+iEstatus;
			sUrl += '&dFechaInicial='+FechaInicial;
			sUrl += '&dFechaFinal='+FechaFinal;
			sUrl += '&iCheckFecha=1';
			sUrl += '&sFolFactura='+sFolFactura;
			sUrl += '&iRowsPerPage='+iRowsPerPage;
			sUrl += '&iPage='+iPage;
			sUrl += '&sOrderBy='+sOrderBy;
			sUrl += '&sOrderType='+sOrderType;
			sUrl += '&sColumns='+sColumns;
			
		// console.log(sUrl);
		// return;
		
		var xhr = new XMLHttpRequest();
		var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS_SPRING + '/reportes';
		
		xhr.open("POST", report_url, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		
		xhr.addEventListener("progress", function(evt){
			if(evt.lengthComputable) {
				var percentComplete = evt.loaded / evt.total;
				//console.log(percentComplete);
			}
		}, false);
		
		xhr.responseType = "blob";
		xhr.onreadystatechange = function(){
			waitwindow('','close');
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


		
		waitwindow('Obteniendo reporte, por favor espere...','open');
		xhr.send(sUrl);
		/*
		// var CheckFecha = $('#chkbx_fecha').prop('checked')?1:0;
		var CheckFecha = 1;
		var FolioFactura = $('#txt_Folio').val().trim().toUpperCase();
		var cEstatus = $('#cbo_estatus option:selected').html();
		
		if(CheckFecha == 1)
		{
			var FechaInicial = formatearFecha($('#txt_FechaIni').val());
			var FechaFinal = formatearFecha($('#txt_FechaFin').val());
		}
		// else
		// {
			// var FechaInicial = '19000101';
			// var FechaFinal = '19000101';
		// }	
		location.href = 'ajax/json/json_exportar_consulta_Facturas.php?&session_name='+Session+'&estatus=' + $('#cbo_estatus').val() + '&dFechaini='+ FechaInicial+'&dFechafin='+ FechaFinal+'&iCheckFecha='+CheckFecha+'&FolioFactura='+FolioFactura+'&rows=-1&page=-1&cEstatus=' + cEstatus;	
		*/
	}


});			



