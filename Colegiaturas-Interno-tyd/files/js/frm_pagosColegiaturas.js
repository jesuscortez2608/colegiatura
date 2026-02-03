function sanitize(string) { //función para sanitizar variables en JS
	var listaElementos = [];
	var returnList = [];
	var entity = {};
	entity.properti = "";
	listaElementos.push(entity);
	listaElementos.forEach(function (item) {
	item.properti = string;
	returnList.push(item);
	});
return returnList[0].properti;
  }

$(function(){
	ConsultaClaveHCM()
	var iContinuar = 0;
	validarCierreColegiaturas(function(){
		//console.log(iContinuar);
		if (iContinuar > 0) {
			CrearGridCifras();
			CrearGridImpresiones();
		}
	});
	stopScrolling(function(){
		dragablesModal();
	});
	var lConsultandoCifras = false;
		// btn_rechazos = $("#btn_rechazos");

		$("#btn_rechazos").hide();
	
	
	function stopScrolling(callback) {
		$("#dlg_consultarCifras").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_Rechazos").on("show.bs.modal", function () {
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
	/* =============== Funciones =============================== */
	function CrearGridCifras() {
		jQuery("#gd_Cifras").jqGrid({
			datatype: 'json',
			colNames:LengStr.idMSG60,
			colModel:[
				{name:'', 				index:'',				width:90, 	sortable:	false, 	align:"right",	fixed:	true},
				{name:'empleados',		index:'empleados',		width:110,	sortable:	false,	align:"right",	fixed:	true},
				{name:'movimientos',	index:'movimientos', 	width:90, 	sortable: 	false,	align:"right",	fixed: 	true},
				{name:'importe_factura',index:'importe_factura',width:110, 	sortable: 	false,	align:"right",	fixed:  true},
				{name:'importe_pagado',	index:'importe_pagado', width:110, 	sortable: 	false,	align:"right",	fixed:  true},
				{name:'importe_ajuste',	index:'importe_ajuste', width:110, 	sortable: 	false,	align:"right",	fixed:  true},
				{name:'importe_isr',	index:'importe_isr', 	width:110, 	sortable: 	false,	align:"right",	fixed:  true},
				{name:'total_gral',		index:'total_gral', 	width:110, 	sortable: 	false,	align:"right",	fixed:  true}
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			caption:'<i class="icon-bar-chart"></i>&nbsp;Cifras',
			width: 830,
			shrinkToFit: false,
			height: 200,
			pgbuttons: false,
			pgtext: null,
			loadComplete: function (Data) {
				var table = this;

				if (lConsultandoCifras) {
					var totalRenglones = jQuery("#gd_Cifras").jqGrid('getGridParam', 'reccount');
					var grid = $("#gd_Cifras");
					totalRegistros = grid.jqGrid('getCol', 'empleados');
					// console.log(totalRegistros[0]);
					if(totalRegistros != "<b>0</b>"){
						$("#dlg_consultarCifras").modal('show');
					}else{
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
				}

				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			}
		});
	}

	function CrearGridImpresiones() {
		jQuery("#gd_Rechazos").jqGrid({
			datatype: 'json',
			colNames:LengStr.idMSG61,
			colModel:[
				{name:'num_empleado',index:'num_empleado', width:80, sortable: false,align:"center",fixed: true},
				{name:'nombre_empleado',index:'nombre_empleado', width:250, sortable: false,align:"left",fixed: true},
				{name:'idfactura',index:'idfactura', width:10, sortable: false,align:"right",fixed: true, hidden: true},
				{name:'idu_ajuste',index:'idu_ajuste', width:75, sortable: false,align:"left",fixed: true},
				{name:'folio_factura',index:'folio_factura', width:270, sortable: false,align:"left",fixed: true},
				{name:'importe_factura',index:'importe_factura', width:100, sortable: false,align:"right",fixed: true},
				{name:'importe_pagado',index:'importe_pagado', width:100, sortable: false,align:"right",fixed: true}
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			// caption:'<i class="icon-remove red"></i>&nbsp;Rechazos',
			width: 905,
			shrinkToFit: false,
			height: 200,
			pgbuttons: false,
			pgtext: null,
			loadComplete: function (Data) {
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			}
		});
	}

	function generarPagos() {
		$.ajax({type:'POST',
			url:'ajax/json/json_fun_generar_pagos_colegiaturas.php',
			data:{'session_name':Session},
			beforeSend:function(){waitwindow('Generando pagos, porfavor espere...','open');},
			success:function(data)
			{
				var dataJson = JSON.parse(data);
				if (dataJson.facturas_traspasadas <= 0){
					// showalert(LengStrMSG.idMSG313, "", "gritter-info");
					showalert("No se generaron pagos de colegiaturas: " + dataJson.mensaje, "", "gritter-error");
				}
				else{
					var sMensaje="Se generaron los pagos de colegiaturas<br><b>Facturas traspasadas:</b> sfacturas_traspasadas <br><b>Facturas rechazadas:</b> sfacturas_rechazadas <br><b>Empleados dados de baja:</b> sempleados_baja<br>";
					sMensaje=sMensaje.replace('sfacturas_traspasadas', dataJson.facturas_traspasadas);
					sMensaje=sMensaje.replace('sfacturas_rechazadas', dataJson.facturas_rechazadas);
					sMensaje=sMensaje.replace('sempleados_baja', dataJson.empleados_baja);
					/*"Se generaron los pagos de colegiaturas" + "<br>" +
						"Facturas traspasadas: " + dataJson.facturas_traspasadas + "<br>" +
						"Facturas pagadas: " + dataJson.facturas_pagadas + "<br>" +
						"Facturas rechazadas: " + dataJson.facturas_rechazadas + "<br>" +
						"Empleados dados de baja: " + dataJson.empleados_baja + "<br>";*/
					showalert(sMensaje, "", "gritter-success");
					if(dataJson.empleados_baja > 0){
						setTimeout(function(){
							showmessage("Se generaron rechazos por colaboradores dados de baja", '', undefined, undefined, function onclose(event){
								$("#btn_rechazos").show();
							});
						}, 2000);				
					}
					else{
						$("#btn_rechazos").hide();
					}
				}
				waitwindow('','close');
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	function fnConsultarCifras(callback) {
		lConsultandoCifras = true;
		var urlu = "ajax/json/json_fun_generar_cifrascontrol_pago.php";
		// var urlu = 'ajax/json/json_fun_obtener_cifras_de_control.php?session_name=' + Session;;
		$("#gd_Cifras").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");
	}

	function fnConsultarRechazos(callback) {
		var urlu = "ajax/json/json_fun_imprimir_rechazos_generacion_pagos.php";
		$("#gd_Rechazos").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");
		callback();
	}
	
	function ImprimirRechazos(){
		// console.log('entra 1');
		var urlu = 'ajax/json/impresion_json_fun_imprimir_rechazos_generacion_pagos.php';
		location.href = urlu;		
	}
	
	function ImprimirCifras(){
		var urlu = 'ajax/json/impresion_json_fun_generar_cifrascontrol_pago.php';
		location.href = urlu;
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
	
	//Funcion Obsoleta de Impresión de Cifras.
	// function ImprimirCifras() {
		// var urlu = "ajax/json/json_fun_generar_cifrascontrol_pago.php";
		// var arr_Facturas = [];
		// var dataJsonDatos;
		// $.ajax({
			// type: "GET",
			// data: {},
			// url: urlu
		// }).done(function(data) {
			// var dataJson = jQuery.parseJSON(data);
			// if(dataJson.rows.length > 0) {
				// for(var i = 0; i < dataJson.rows.length; i++){
					// obj = {
						// 'Id. Ruta Pago': dataJson.rows[i].cell[0],
						// 'Nombre Ruta pago': dataJson.rows[i].cell[1],
						// 'Movimientos': dataJson.rows[i].cell[2],
						// 'Importe': dataJson.rows[i].cell[3],
						// 'Prestacion': dataJson.rows[i].cell[4],
						// 'Importe Cancelado': dataJson.rows[i].cell[5]
					// }
					// arr_Facturas.push(obj);
					// dataJsonDatos = JSON.stringify(arr_Facturas);
				// };
				// $.ajax({
					// type: 'POST',
					// url: 'ajax/frm/frm_imprimir.php',
					// data: {
						// 'title' : 'Generación de pagos - cifras de control',
						//'filter' : cDescripcionFiltros,
						// 'data' : dataJsonDatos,
						// 'fname' : 'ConsultaDeCifras'
					// }
				// }).done(function(data){
						// $('#divexport').html("" + data + "");
				// });
				
			// }
		// });
	// }

	/* =============== Eventos =============================== */
	$('#cnt_busquedaPagosColegiatura').dialog({
		title_html: true,
		title:'',
		width:700,
		height:300,
		modal: true,
		autoOpen: false,
		open: function(){
			$(this).css('overflow', 'hidden');
		},
		close: function(){
			$('#cnt_busquedaPagosColegiatura').html("");
		}
	});
	
	$('#btn_generar').click(function(event){
		$("#btn_generar").prop('disabled', true);
		bootbox.confirm(LengStrMSG.idMSG315, 
			function(result)
			{
				$("#btn_generar").prop('disabled', false);
				if (result)
				{	
					generarPagos();
				}
			}	
		);
		event.preventDefault();
	});
	
	//-- Imprimir Rechazos
	$("#btn_rechazos").click(function(event){
		fnConsultarRechazos(function(){
			var totalRenglones = jQuery("#gd_Rechazos").jqGrid('getGridParam', 'reccount');
			if(totalRenglones!=1)
			{
				$("#dlg_Rechazos").modal('show');
			}
			else
			{
				showalert(LengStrMSG.idMSG86, "", "gritter-info");
			}
		});	
		event.preventDefault();
	});
	$("#btn_CerrarRechazos").click(function(event){
		$("#dlg_Rechazos").modal('hide');
		event.preventDefault();
	});
	$("#btn_ImprimirRechazos").click(function(event){
		ImprimirRechazos();
		event.preventDefault();
	});
	//-- Consulta Cifras
	$("#btn_cifras").click(function(event){
		fnConsultarCifras();
		event.preventDefault();
	});
	$("#btn_CerrarCifras").click(function(event){
		$("#dlg_consultarCifras").modal('hide');
		event.preventDefault();
	});
	$("#btn_ImprimirCifras").click(function(event){
		ImprimirCifras();
		event.preventDefault();
	});

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 403
            }
        })
        .done(function(data){
            var dataS = sanitize(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }

});