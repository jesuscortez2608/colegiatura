$(function(){
	ConsultaClaveHCM()
	var strData;
	nNumeroMovimientos=0;
	Num_quincena=0;
	var estatusProceso = 0
		, mensajeProceso = "";
		
	var FechaActual = '';
	var iContinuar = 0;
	
	FechaActual = $("#txt_fecha").val();
	
	validarCierreColegiaturas(function(){
		//console.log(iContinuar);
		if (iContinuar > 0) {
			setTimeout(function(){
				puedeGenerarIncentivos(function(){
					ObtenerQuincena();
					//mostrarGridIncentivosAdmin(); 			
					mostrarGridIncentivos();
				});
			}, 500);
		}
	});
	
	var hoy = new Date();
	var mm = hoy.getMonth()+1;
	var yyyy = hoy.getFullYear();
	var conexion=0;
	
	if (mm<10){
		mm='0'+mm;		
	}
	
	// Validar si se pueden generar los incentivos
	// 13/09/2018 - Proceso de colegiaturas (ctl_proceso_colegiaturas)
	function puedeGenerarIncentivos(callback) {
		$.ajax({type:'GET',
			url:"ajax/json/json_fun_generar_incentivos_colegiaturas.php",
			// postData:{/*"session_name" : Session
			data:{"session_name" : Session
				,'valor':'3'
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				estatusProceso = dataJson.estatus;
				mensajeProceso = dataJson.mensaje;
				
				if (estatusProceso < 0) {
					showalert(mensajeProceso, "", "gritter-error");
				} else {
					callback(estatusProceso, mensajeProceso);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function validarCierreColegiaturas(callback) {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_validar_cierre_colegiaturas.php',
			data:{
				'session_name':Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson.estado == 0) {
					bootbox.confirm(dataJson.mensaje+". \<b>¿Desea realizar el cierre?\</b>", 'No', 'Sí', function(result) {
						if(result) {
							activaOpc(findIndex('frm_generarCierre.php'), 'frm_generarCierre.php');
						} else {
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:dataJson.mensaje}});
							return;
						}
					});
				} else {
					iContinuar = iContinuar + 1;
					if (callback != undefined) {
						callback();
					}
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	// //--OBTENER INCENTIVOS ADMIN (SISTEMA ANTERIOR) -- YA NO SE UTILIZA
	// function ObtenerIncentivosAdmin(){		//callback
	// 	$.ajax({type:'POST',
	// 	url:'ajax/json/json_fun_obtener_incentivos_admin.php',
	// 	data:{
			
	// 	},
	// 	beforeSend:function(){},
	// 	success:function(data){
	// 		var dataJson = JSON.parse(data);
	// 		//console.log(dataJson);
	// 			if (dataJson.estado==0){
	// 				ComplementarIncentivos();
	// 				if (dataJson.movimientos > 0) {
	// 					insertarMovtoBitacora(4);
	// 				}
	// 			}else{
	// 				showalert(dataJson.mensaje, "", "gritter-error");					
	// 			}				
	// 		},
	// 	error:function onError(){callback ();},
	// 	complete:function(){}, //callback ();
	// 	timeout: function(){},
	// 	abort: function(){}
	// 	});
	// }
	
	//--OBTENER INCENTIVOS PERSONAL (SISTEMA NUEVO)
	function ComplementarIncentivos(){
		// console.log('algo');
		// return;
		$.ajax({type:'POST',
		url:'ajax/json/json_fun_complementar_incentivos.php',
		data:{
			'iOpcion' : 0
		},
		beforeSend:function(){},
		success:function(data){
			insertarMovtoBitacora(4);
			//var dataJson = JSON.parse(data);
				//if (dataJson.estado==0){
					//showalert(dataJson.mensaje, "", "gritter-info");
					//strData = data;
					//var fname = "IncentivosColegiaturas";
					//var campo1 = "Num Emp";
					//var campo2="Incentivo";	
					// console.log('strData='+strData);
					// return;
					//exportData("ajax/json/json_fun_generar_incentivos_unificados.php?iOpcion=1");
					/*$.ajax({
						type: 'POST',
						url: 'ajax/json/json_fun_exportar_excel_incentivos_colegiaturas.php',
						//url: 'ajax/json/json_fun_exportar_excel.php',
						data: {
							//'title' : title,
							//'filter' : '',
							'campo1': campo1,
							'campo2': campo2,
							'data' : strData,
							'fname' : fname
						}
					}).done(function(data){*/
						//$('#formgetexcel_file').submit();
						
						//$('#divexport').html("" + data + "");
					//});					
				//}else{
				//	showalert(dataJson.mensaje, "", "gritter-info");
				//}				
			},
		error:function onError(){},
		complete:function(){},
		timeout: function(){},
		abort: function(){}
		});
	}
	
	//--MOSTRAR GRID INCENTIVOS
	function mostrarGridIncentivosAdmin (){
		jQuery("#gd_incentivosAdmin").jqGrid({
			url: "ajax/json/json_fun_obtener_incentivos_admin.php",			
			datatype: 'json',
			mtype: 'GET',			
			colNames:['Colaborador','Importe','ISR', 'Total'],
			colModel:[						
				//{name:'empresa',index:'empresa', width:280, sortable:false},
				{name:'numemp',		index:'numemp', 	width:350, 					sortable:false},				
				{name:'importe',	index:'importe', 	width:150, align:"right",	sortable:false},				
				{name:'isr',		index:'isr', 		width:150, align:"right",	sortable:false},
				{name:'total',		index:'total', 		width:150, align:"right",	sortable:false}
			],
			//multiselect:true,
			caption:'Listado de Facturas Admin',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 300,
			rowNum:20,
			rowList:[20, 30, 40, 50],
			pager: '#gd_incentivosAdmin_pager',
			sortname: 'fechafactura',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data)
			{
				//$("#btn_generarIncentivos").show();
				//$("#btn_enviar").show();
			},
			onSelectRow: function(id)
			{
				
			}				
		});				
	}
	
	//MOSTRAR GRID INCENTIVOS
	function mostrarGridIncentivos(){
		//jQuery("#gd_incentivos").jqGrid('clearGridData');
		jQuery("#gd_incentivos").jqGrid({
			url: "ajax/json/json_fun_generar_incentivos_colegiaturas.php",
			datatype: 'json',
			mtype: 'GET',
			postData:{"session_name" : Session
				, 'valor': 0
			},
			colNames:['Empresa','Colaborador','Importe','ISR', 'Total'],
			colModel:[						
				{name:'empresa',	index:'empresa', 	width:280, 					sortable:false},
				{name:'numemp',		index:'numemp', 	width:350, 					sortable:false},
				//{name:'numemp',	index:'numemp', 	width:280, 					sortable:false},
				{name:'importe',	index:'importe', 	width:150, 	align:"right",	sortable:false},				
				{name:'isr',		index:'isr', 		width:150, 	align:"right",	sortable:false},
				{name:'total',		index:'total', 		width:150, 	align:"right",	sortable:false}
			],
			//multiselect:true,
			caption:'Listado de Facturas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 300,
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_incentivos_pager',
			sortname: 'fechafactura',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data)
			{
				$("#btn_generarIncentivos").show();
				$("#btn_enviar").show();
				// $("#btn_unir").show(); -- YA NO SE UTILIZA
				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id)
			{
				//if(id >= 0){
					// var rowData = jQuery(this).getRowData(id);
					// nEmpleadoSeleccionado = rowData['empleado'];
				//}
			}				
		});
		
		barButtongrid({
			pagId:'#gd_incentivos_pager',
			position:'left',
			Buttons:[
			{
				icon:'icon-print',
				title:'Imprimir',
				click:function(event){
					if(($("#gd_incentivos").find("tr").length - 1) == 0){
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
			var $class = icon.attr('class').replace('ui-icon', '') .replace('/^\s+|\s+$/g', '');
			
			if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
		})
	}
	
	function setSizeBtnGrid(id,tamanio) {
		$("#"+id).attr('width',tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	
	//BOTON GENERAR INCENTIVOS
	$('#btn_generarIncentivos').click(function(event){	
		nNumeroMovimientos = jQuery("#gd_incentivos").jqGrid('getGridParam', 'reccount');
		if (nNumeroMovimientos <= 0) {
			//showmessage('No existen movimientos para generar el archivo de incentivos', '', undefined, undefined, function onclose(){});
			showalert("No existen movimientos para generar el archivo de incentivos", "", "gritter-info");
		}
		else
		{
			exportData(); //"ajax/json/json_fun_generar_incentivos_colegiaturas.php?valor=1");			
		}	
	});
	 
	//--BOTON UNIR INCENTIVOS -- YA NO SE UTILIZA
	// $('#btn_unir').click(function(event){
	// 	/*ObtenerIncentivosAdmin(function()
	// 	{
	// 		ComplementarIncentivos();
	// 	});*/
	// 	ObtenerIncentivosAdmin();
	// });
	
	//--BOTON ENVIAR
	$('#btn_enviar').click(function(event){
		//showalert("enviar", "", "gritter-info");
		nNumeroMovimientos = jQuery("#gd_incentivos").jqGrid('getGridParam', 'reccount');
		if (nNumeroMovimientos <= 0) {
			//showmessage('No existen movimientos de incentivos para envíar', '', undefined, undefined, function onclose(){});
			showalert("No existen movimientos de incentivos para envíar", "", "gritter-info");
		}
		else
		{
			$("#btn_enviar").prop('disabled', true);
			bootbox.confirm('¿Desea envíar información de los incentivos? ', 
			function(result){
				$("#btn_enviar").prop('disabled', false);
				if (result){
					conexion= yyyy+''+mm+''+Num_quincena;
					//showalert(conexion, "", "gritter-info");
					$.ajax({
						type:'POST',
						//url:'ajax/proc/proc_enviar_incentivos_colegiaturas.php',
						url:'ajax/proc/proc_enviar_incentivos_unificados.php',
						data:{
							'session_name': Session,
							'conexion' : conexion,
							'FechaActual' : FechaActual,
							'valor' : 2
						},
						beforeSend:function(){},
						success:function(data){
							var dataJson = JSON.parse(data);
							if (dataJson.estado==0){
								showalert(dataJson.mensaje, "", "gritter-info");
								insertarMovtoBitacora(5);
							}else{
								showalert(dataJson.mensaje, "", "gritter-error");					
							}				
						},
						error:function onError(){},
						complete:function(){},
						timeout: function(){},
						abort: function(){}
					});
				}
			});
			
		}
		event.preventDefault();
	});	
	
	//DESCARGAR ARCHIVO
	function descargarArchivo(contenidoEnBlob, nombreArchivo) {
		var reader = new FileReader();
		reader.onload = function (event) {
			var save = document.createElement('a');
			save.href = "C:\,"; //event.target.result;
			save.target = '_blank';
			save.download = nombreArchivo || 'archivo.dat';
			var clicEvent = new MouseEvent('click', {
				'view': window,
					'bubbles': true,
					'cancelable': true
			});
			save.dispatchEvent(clicEvent);
			(window.URL || window.webkitURL).revokeObjectURL(save.href);
		};
		reader.readAsDataURL(contenidoEnBlob);
	};

//--OBTENER QUINCENA
	function ObtenerQuincena(){
		sUrl = 'ajax/json/json_WS_obtener_quincena.php';
		$.ajax({
			type: "POST",
			url: sUrl,
			data:{}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			$("#txt_TipoNomina").val(dataJson.valor);
			// console.log(dataJson.valor);
			Num_quincena=dataJson.valor;			
		})
		.fail(function(s){message("Error al cargar " + sUrl); $('#pag_content').fadeOut();})
		.always(function(){});
	}
		
	
//--EXPORTAR ARCHIVO EXCEL	
	/*function exportData() {
		var fname = "IncentivosColegiaturas";
		var campo1 = "Num Emp";
		var campo2="Incentivo";
		//var title = "Reporte de pagos de colegiaturas";		
		//
		$.ajax({
				type: 'GET',
				url: "ajax/json/json_fun_generar_incentivos_colegiaturas.php?valor=1", 
		})
		.done(function(data){
			strData = data;		
			// console.log('strData='+strData);
			// return;
			$.ajax({
				type: 'POST',
				url: 'ajax/json/json_fun_exportar_excel_incentivos_colegiaturas.php',
				//url: 'ajax/json/json_fun_exportar_excel.php',
				data: {
					//'title' : title,
					//'filter' : '',
					'campo1': campo1,
					'campo2': campo2,
					'data' : strData,
					'fname' : fname
				}
			}).done(function(data){
				$('#formgetexcel_file').submit();
				//$('#divexport').html("" + data + "");
			});
		}).fail(function(s) { 
			showInfo('Ocurrio un error al imprimir los datos del grid');
		});		
	}*/
	
	//--EXPORTAR ARCHIVO EXCEL	
	function exportData() {
		location.href = 'ajax/json/json_fun_exportar_excel_incentivos_colegiaturas.php?valor=1&rows=-1&page=-1';
		ComplementarIncentivos();

		// var fname = "IncentivosColegiaturas";
		// var campo1 = "Num Emp";
		// var campo2="Incentivo";
		// //var title = "Reporte de pagos de colegiaturas";		
		// //
		// $.ajax({
		// 		type: 'GET',
		// 		url: "ajax/json/json_fun_generar_incentivos_colegiaturas.php?valor=1", 
		// 		data: {
		// 			'rows': -1,
		// 			'page':-1
		// 		},
		// })
		// .done(function(data){
		// 	strData = data;
		// 	/*
		// 	if(strData != '' || strData != undefined) {
		// 		insertarMovtoBitacora(3);
		// 	}
		// 	*/
		// 	 console.log('strData='+strData);
		// 	$.ajax({
		// 		type: 'POST',
		// 		url: 'ajax/json/json_fun_exportar_excel_incentivos_colegiaturas.php',
		// 		//url: 'ajax/json/json_fun_exportar_excel.php',
		// 		data: {
		// 			//'title' : title,
		// 			//'filter' : '',
		// 			'campo1': campo1,
		// 			'campo2': campo2,
		// 			'data' : strData,
		// 			'fname' : fname
		// 		}
		// 	}).done(function(data){
		// 		$('#formgetexcel_file').submit();
		// 		//$('#divexport').html("" + data + "");
		// 	});
		// }).fail(function(s) { 
		// 	showInfo('Ocurrio un error al imprimir los datos del grid');
		// });		
	}
	function insertarMovtoBitacora(iMovto) {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_ins_bit_proceso_colegiaturas.php',
			data:{
				'iMovto':iMovto,
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				//console.log(dataJson.mensaje);
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
//--IMPRIMIR GRID
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

	function imprimirGrid(){
		var title = "Generacion de Incentivos";
		var fname = "GeneracionIncentivos";
		$.ajax({
				type: 'GET',
				url: "ajax/json/json_fun_generar_incentivos_colegiaturas?valor=2", 
		})
		.done(function(data){
			strData = data;
			$.ajax({
				type: 'POST',
				url: 'ajax/frm/frm_exportar.php',
				data: {
					'title' : title,
					'data' : strData,
					'fname' : fname
				}
			}).done(function(data){
				data = limpiarCadena(data);
				$('#divexport').html("" + data + "");
			});
		}).fail(function(s) { 
			showInfo('Ocurrio un error al imprimir los datos');
		});
	}
	
	function GenerarPdf(){
		// Paimi Arizmendi López
		// 28/08/2018
		// Código para mostrar un mensaje de espera mientras se descarga 
		// un archivo
		// ---------------------------------------------------------------
		
		// Parámetros del reporte
		// ---------------------------------------------------------------
		var sNombreReporte = 'rpt_generacion_incentivos_colegiaturas',
			iIdConexion = '190',
			sFormatoReporte = 'pdf';
		
		var params = "nombre_reporte=" + sNombreReporte + "&";
		params += "id_conexion=" + iIdConexion + "&";
		params += "dbms=postgres&";
		params += "formato_reporte=" + sFormatoReporte + "&";
		
		var xhr = new XMLHttpRequest();
		var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS + '/reportes';
		
		xhr.open("POST", report_url, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		
		xhr.addEventListener("progress", function (evt) {
			if(evt.lengthComputable) {
				var percentComplete = evt.loaded / evt.total;
				//console.log(percentComplete);
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

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 398
            }
        })
        .done(function(data){
            var dataS = limpiarCadena(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }
});