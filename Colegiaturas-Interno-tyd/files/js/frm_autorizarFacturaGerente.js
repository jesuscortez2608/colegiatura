$(function() {
	var currentYear = $( '#hid_anio_actual' ).val();
	var iUsuario = $("#hid_idu_usuario").val();
	//var nomUsuario = $("#hid_nom_usuario").val();
	var nomUsuario = DOMPurify.sanitize($("#hid_nom_usuario").val());
	var iEstatusSeleccionado = 0;
	var iFacturaSeleccionada = 0;
	var iEmpleadoSeleccionado = 0;
	var cEscuelaSeleccionada = '';
	var x, y;
	var iMsjConsulta=0;
	fnConsultaAvisos(3);
	// soloLetras('txt_Justificacion_Rechazo');
	/** Declaraciones
	-------------------------------------------------- */	
	$("#btn_ver").on("click", function(event) {
		var cnt_ver_factura = $( "#cnt_ver_factura" ).dialog({
			modal: true,
			title: "<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-ok'></i> Factura</h4></div>",
			title_html: true,
			width: 1800,
			height: 900,
			autoOpen: false,
			buttons: [
				{
					text: "Cerrar",
					"class" : "btn btn-primary btn-mini",
					click: function() {
						// $("#gd_Facturas").jqGrid('resetSelection');
						// iFacturaSeleccionada = 0;
						$( this ).dialog( "close" );
					}
				}
			]
		});

		cnt_ver_factura.dialog("open");
		event.preventDefault();
	});
	function stopScrolling(callback) {
		$("#dlg_BeneficiariosFactura").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_JustificacionRechazo").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
	}
	function dragablesModal(callback){
		$(".modal").draggable({
			// commenting the line below will make scrolling while dragging work
			// helper: "clone",
			handle: ".modal-header",
			scroll: true,
			// revert: "invalid"
		});
		
		if (callback != undefined){
			callback();
		}
	}
		$("#txt_FechaIni").datepicker({
			showOn: 'both',
			dateFormat: 'dd/mm/yy',
			yearRange: '1900:' + currentYear,
			buttonImageOnly: true,
			numberOfMonths: 1,
			//minDate: "0D",
			readOnly: true,
			changeYear: true,
			changeMonth: true,
			monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
			monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
			dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
			dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
			dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
			onSelect: function( selectedDate, obj ) {
				$('#txt_FechaFin').datepicker( 'option', 'minDate', selectedDate);
				$("#gd_Facturas").jqGrid("clearGridData");
				$("#gd_BeneficiariosFactura").jqGrid("clearGridData");
			}
		});
		
		$("#txt_FechaFin").datepicker({
			showOn: 'both',
			dateFormat: 'dd/mm/yy',
			yearRange: '1900:' + currentYear,
			buttonImageOnly: true,
			numberOfMonths: 1,
			minDate: "0D",
			readOnly: true,
			changeYear: true,
			changeMonth: true,
			monthNames: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
			monthNamesShort: ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
			dayNames: ['Domingo','Lunes','Martes','Mi&eacute;rcoles','Jueves','Viernes','S&aacute;bado'],
			dayNamesShort: ['Dom','Lun','Mar','Mi&eacute;','Juv','Vie','S&aacute;b'],
			dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','S&aacute;'],
			onSelect: function( selectedDate, obj ) {
				$('#txt_FechaIni').datepicker( 'option', 'maxDate', selectedDate);
				$("#gd_Facturas").jqGrid("clearGridData");
				$("#gd_BeneficiariosFactura").jqGrid("clearGridData");
			}
		});
		
		
    //VULNERABILIDADES
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

	/** Eventos
	-------------------------------------------------- */
		setTimeout(function(){
			loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no esta disponible la opcion.'}});
			return;
			
			$("#div_cargando").css('display','block');
			load_cargando(0);
			
			fnEstructuraGrid();
			dragablesModal(function(){
				stopScrolling(function(){
					
				});
			});
			
			llenarComboCentros(function(){
				load_cargando(30);
				llenarComboEstatus(function(){
					llenarComboEmpleados(function(){
						fnObtenerNotificaciones(function(){
							load_cargando(100);
							$("#div_cargando").css('display','none');
						
						// $("#cbo_estatus").val("0");
						// $("#cbo_estatus").trigger("chosen:updated");
						
						// $('#cnt_opciones_gerente').show();
						});
					});
				});
			});
		}, 0);
		
		$("#cbo_empleados").change(function(event){
			$("#gd_Facturas").jqGrid("clearGridData");
			$("#gd_BeneficiariosFactura").jqGrid("clearGridData");
			event.preventDefault();
		});
		
		$("#cbo_estatus").change(function(event){
			
			if ( $("#cbo_estatus").val()==-1) {  //todas
				x = 1;
				y = 1;
				HabilitarBotones(x,y);
				// event.preventDefault();
			}
			else if ( $("#cbo_estatus").val()==0) {
				x = 1;
				y = 1;
				HabilitarBotones(x,y);
				// event.preventDefault();
			} else if( $("#cbo_estatus").val()==1) {
				x = 0;
				y = 1;
				HabilitarBotones(x,y);
				// event.preventDefault();
			} else {
				x = 0;
				y = 0;
				HabilitarBotones(x,y);
				// event.preventDefault();
			}
			$("#gd_Facturas").jqGrid("clearGridData");
			$("#gd_BeneficiariosFactura").jqGrid("clearGridData");
			
			event.preventDefault();
		});
		
		function HabilitarBotones(x,y) {
			if(x == 1 && y == 1){
				$("#btn_autorizar_factura").show();
				$("#btn_cancelar_factura").show();
			}
			if(x == 1 && y == 0){
				$("#btn_autorizar_factura").show();
				$("#btn_cancelar_factura").hide();
			}
			if(x == 0 && y == 1){
				$("#btn_autorizar_factura").hide();
				$("#btn_cancelar_factura").show();
			}
			if(x == 0 && y == 0){
				$("#btn_autorizar_factura").hide();
				$("#btn_cancelar_factura").hide();
			}
		}
		
		$("#cbo_centro").change(function(event){
			$("#div_cargando").css('display','block');
			load_cargando(50);
			llenarComboEmpleados(function(){
				load_cargando(100);
				$("#div_cargando").css('display','none');
			});
			$("#gd_Facturas").jqGrid("clearGridData");
			$("#gd_BeneficiariosFactura").jqGrid("clearGridData");
			event.preventDefault();
		});
		//-----------------------------------------------------------------------------
		$("#div_Notificacion_G").click(function(event){
			$("#cbo_estatus").val(0);
			$("#cbo_estatus").trigger("chosen:updated");
			HabilitarBotones(1,1);
			$("#cbo_empleados").val(0);
			
			$("#btn_consultar").click();
			
			// if($("#cbo_empleados").val() == 0){
				// var params = "";
				// params += "empleado=" + sEmpleados + "&";
				// params += "tipo=" + $('#cbo_estatus').val() + "&";
				// params += "session_name=" + Session + "&";
				// params += "iOpcion=2&";
				// iMsjConsulta=1;
				// showalert(params, "", "gritter-info");
			// }else{
				// showalert(sEmpleados, "", "gritter-info");
			// }
		});
		
		//////////////////BOTON AUTORIZAR///////////////////////////////////////////////
		$("#btn_autorizar_factura").click(function(event){
			
			if (iEmpleadoSeleccionado == 0 && iFacturaSeleccionada == 0) {
				// showalert(LengStrMSG.idMSG432, "", "gritter-info");
				showalert("Seleccionar factura a autorizar", "", "gritter-info");
			} else if (iEmpleadoSeleccionado != 0 && iFacturaSeleccionada != 0 && iEstatusSeleccionado != 0) {
				showalert(LengStrMSG.idMSG431, "", "gritter-info");
			} else if(iEstatusSeleccionado != 0 && iEstatusSeleccionado != 1){
				showalert("Solo puede autorizar facturas en estatus <b>PENDIENTES Y EN PROCESO</b>", "", "gritter-info");
			}else {
				if(iEmpleadoSeleccionado == iUsuario){ //------->VALIDAR NO AUTORIZAR PROPIAS FACTURAS DEL COLABORADOR
					showalert("No puedes autorizar tus propias facturas", "", "gritter-info");//------->VALIDAR NO AUTORIZAR PROPIAS FACTURAS DEL COLABORADOR
				} else{
					$("#btn_autorizar_factura").prop('disabled', true);//
					bootbox.confirm(LengStrMSG.idMSG336,"No","Si",
						function(result) {
							$("#btn_autorizar_factura").prop('disabled', false);
							if (result) {
								$(this).keypress(function(e){
									if(e.which == 13){
										return false;
										e.preventDefault();
									}
								});
								$(this).keydown(function(e){
									if(e.which == 13){
										return false;
										e.preventDefault();
									}
								});
								$(this).keyup(function(e){
									if(e.which == 13){
										return false;
										e.preventDefault();
									}
								});
								$.ajax({type:'POST',
									url:'ajax/json/json_fun_grabar_estatus_factura.php',
									data:{'iEstatus' : 1
										,'iFactura' : iFacturaSeleccionada
										,'sDesObservaciones' : ''
										,'session_name' : Session
										,'iColaborador': iEmpleadoSeleccionado
										,'nombreUsuario': nomUsuario
								},
								beforeSend:function() {
									waitwindow('Por favor espere...','open');
								},
								success:function(data) {
									var dataJson = JSON.parse(data);
									if (dataJson.estado < 0) {
										//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
										showalert(dataJson.mensaje, "", "gritter-info");
									} else {
										var sMensaje = LengStrMSG.idMSG337.replace('cEscuelaSeleccionada',cEscuelaSeleccionada);
										sMensaje=sMensaje.replace('cFechaFactura',cFechaFactura);
										sMensaje=sMensaje.replace('cImportepagoF',cImportepagoF);
										
										//"Se ha autorizado la factura de " + cEscuelaSeleccionada +" <br>Fecha de factura : " + cFechaFactura;
										//mensaje += "<br>Importe Factura : " + cImportepagoF;
										showalert(sMensaje, "", "gritter-success");
										
										iEmpleadoSeleccionado = 0;
										iFacturaSeleccionada = 0;
										iEstatusSeleccionado = 0;
										cEscuelaSeleccionada = "";
										cFechaFactura = "";
										cImportepagoF = "";
										setTimeout(function(){ 
											var params = "";
											params += "empleado=" + $('#cbo_empleados').val() + "&";
											// params += "tipo=" + $('#cbo_estatus').val(-1) + "&";
											// params += "fechaini=" + formatearFecha( $('#txt_FechaIni').val() ) + "&";
											// params += "fechafin=" + formatearFecha( $('#txt_FechaFin').val() ) + "&";
											params += "session_name=" + Session + "&";
											params += "iOpcion=2&";
											iMsjConsulta=0;
											$("#btn_consultar").click();
											llenarGridFacturas(params);
											$("#btn_consultar").click();
											fnObtenerNotificaciones(function(){
												load_cargando(100);
												$("#div_cargando").css('display','none');
											});
											waitwindow('','close');
										}, 4000);
										// fnObtenerNotificaciones(callback);
										// llenarGridFacturas(params);
									}
								},
								error:function onError(){},
								complete:function(){},
								timeout: function(){},
								abort: function(){}
								});
						}
					});
					
				}   //------->VALIDAR NO AUTORIZAR PROPIAS FACTURAS DEL COLABORADOR
			}
			event.preventDefault();
		});
		 $("a.confirm").keypress(function(event){
			 if( event.which == 13){
				 return false;
			 }
		 	event.preventDefault();
		 });
		 $("a.confirm").keydown(function(event){
			 if( event.which == 13){
				 return false;
			 }
		 	event.preventDefault();
		 });
		 $("a.confirm").keyup(function(event){
			 if( event.which == 13){
				 return false;
			 }
		 	event.preventDefault();
		 });
		//////////////////BOTON CONSULTAR///////////////////////////////////////////////
		$('#btn_consultar').click(function(event) {
			$("#cnt_motivo_rechazo").hide();
			$("#txt_MotivoRechazo").val("");
			
			iEstatusSeleccionado = 0;
			iFacturaSeleccionada = 0;
			iEmpleadoSeleccionado = 0;
			cEscuelaSeleccionada = "";
			cFechaFactura = "";
			cImportepagoF = "";
			
			sEmpleados = "";
			if ($("#cbo_empleados").val() == "0" ) {
				nCnt = 0;
				$("#cbo_empleados option").each(function(){
					if ($(this).val() != 0) {
						if (nCnt > 0) {
							sEmpleados += "," + $(this).val();
						} else {
							sEmpleados += $(this).val();
						}
						nCnt++;
					}
				});
			} else {
				sEmpleados = $("#cbo_empleados").val();
			}
			
			
			var params = "";
			params += "sEmpleados=" + sEmpleados + "&";
			params += "tipo=" + $('#cbo_estatus').val() + "&";
			// params += "fechaini=" + formatearFecha( $('#txt_FechaIni').val() ) + "&";
			// params += "fechafin=" + formatearFecha( $('#txt_FechaFin').val() ) + "&";
			params += "session_name=" + Session + "&";
			params += "iOpcion=2&";
			iMsjConsulta=1;
			llenarGridFacturas(params);
			fnObtenerNotificaciones(function(){
				load_cargando(100);
				$("#div_cargando").css('display','none');
			});
			
			// event.preventDefault();
		});
		////////////////////// B O T O N    R E C H A Z A R ////////////////////
		
		$('#btn_cancelar_factura').click(function(event) {
			llenarComboMotivosRechazo(function(){});
			$('#txt_Justificacion_Rechazo').prop('disabled', true);
			// $("#dlg_JustificacionRechazo").modal('show');
			if (iEmpleadoSeleccionado == 0 && iFacturaSeleccionada == 0) {
				// showalert(LengStrMSG.idMSG428, "", "gritter-info");
				showalert("Seleccionar factura a rechazar", "", "gritter-info");
			}
			//else if (iEmpleadoSeleccionado != 0 && iFacturaSeleccionada != 0 && iEstatusSeleccionado != 1){	
				// showalert(LengStrMSG.idMSG344, "", "gritter-info");
				//showalert("Solo se permiten rechazar facturas con estatus EN PROCESO", "", "gritter-info");
			//} 
			else if(iEmpleadoSeleccionado == iUsuario){
				showalert("No puedes rechazar tus propias facturas", "", "gritter-info");
			}
			else if(iEstatusSeleccionado != 0 && iEstatusSeleccionado != 1){
				showalert("Solo puede rechazar facturas en estatus PENDIENTE Y EN PROCESO", "", "gritter-info");
			}else{
				$("#dlg_JustificacionRechazo").modal('show');
			}
			event.preventDefault();
		});
		$('#cbo_motivo_rechazo').change(function(event) {
			var valor = $('#cbo_motivo_rechazo').val();
			// alert(valor);
			if( valor != 0) {
				$("#txt_Justificacion_Rechazo").prop('disabled', false);
				$('#txt_Justificacion_Rechazo').focus();
			} else {
				$('#txt_Justificacion_Rechazo').prop('disabled', true);
			}
			event.preventDefault();
		})
		
		////////////////////// B O T O N   R E C H A Z A R    M O D A L ////////////////////
		$('#btn_rechazar').click(function(event) {
			var iMotivo = $("#cbo_motivo_rechazo").val();
			if($('#cbo_motivo_rechazo').val()==0){
				showalert("Seleccione un motivo","","gritter-info");
				$('#cbo_motivo_rechazo').focus();
			}else if($('#txt_Justificacion_Rechazo').val() == '') {
				showalert("Introduzca una justificacion","","gritter-info");
				$("#txt_Justificacion_Rechazo").focus();
				return;
			} else {
				$.ajax({type:'POST',
					url:'ajax/json/json_fun_grabar_estatus_factura.php',
					data:{'iEstatus' : 0//iEstatusSeleccionado - Anteriormente se establecio con 0 para pruebas
						,'iFactura' : iFacturaSeleccionada
						,'sDesObservaciones' : $('#txt_Justificacion_Rechazo').val()
						,'session_name' : Session
						,'iMotivo': iMotivo
						,'iColaborador': iEmpleadoSeleccionado
						,'nombreUsuario': nomUsuario
					},
					beforeSend:function(){
						waitwindow('Por favor espere...', 'open');
					},
					success:function(data){
						// waitwindow('', 'close');
						var dataJson = JSON.parse(data);
						if (dataJson.estado < 0) {
							showalert(dataJson.mensaje, "", "gritter-info");
							// waitwindow('', 'close');
						} else {
							// var sMensaje =LengStrMSG.idMSG346.replace('cEscuelaSeleccionada',cEscuelaSeleccionada);
							// sMensaje=sMensaje.replace('cFechaFactura',cFechaFactura);
							// sMensaje=sMensaje.replace('cImportepagoF',cImportepagoF);
							var sMensaje = 'Se ha rechazado la factura de cEscuelaSeleccionada<br>Fecha de factura :  cFechaFactura<br>Importe Factura: cImportepagoF'.replace('cEscuelaSeleccionada', cEscuelaSeleccionada);
							sMensaje = sMensaje.replace('cFechaFactura',cFechaFactura);
							sMensaje = sMensaje.replace('cImportepagoF',cImportepagoF);
						
							//"Se ha cancelado la factura de " + cEscuelaSeleccionada+" <br>Fecha de factura : " + cFechaFactura;
							//mensaje += "<br>Importe Factura: " + cImportepagoF;
							showalert(sMensaje, "", "gritter-success");	
							iEmpleadoSeleccionado = 0;
							iFacturaSeleccionada = 0;
							iEstatusSeleccionado = 0;
							cEscuelaSeleccionada = "";
							cFechaFactura = "";
							cImportepagoF = "";
							
							setTimeout(function(){
								var params = "";
								params += "empleado=" + $('#cbo_empleados').val() + "&";
								// params += "tipo=" + $('#cbo_estatus').val(-1) + "&";
								// params += "fechaini=" + formatearFecha( $('#txt_FechaIni').val() ) + "&";
								// params += "fechafin=" + formatearFecha( $('#txt_FechaFin').val() ) + "&";
								params += "session_name=" + Session + "&";
								params += "iOpcion=2&";
								iMsjConsulta=0;
								$("#btn_consultar").click();
								llenarGridFacturas(params);
								$("#btn_consultar").click();
								fnObtenerNotificaciones(function(){
									load_cargando(100);
									$("#div_cargando").css('display','none');
								});
								waitwindow('','close');
							}, 4000);
						}
					},
					error:function onError(){
						// waitwindow('', 'close');
					},
					complete:function(){
						// waitwindow('', 'close');
					},
					timeout: function(){
						// waitwindow('', 'close');
					},
					abort: function(){
						// waitwindow('', 'close');
					}
				});
				$('#dlg_JustificacionRechazo').modal('hide');
				fnObtenerNotificaciones(function(){
					load_cargando(100);
					$("#div_cargando").css('display','none');
				});
			}
		})
		$("#dlg_JustificacionRechazo").on('hide.bs.modal', function(event){
			$('#cbo_motivo_rechazo').val('');
			$('#txt_Justificacion_Rechazo').val('');
		});
	/** Métodos
	-------------------------------------------------- */
		function llenarGridFacturas (sParams){
			$("#gd_Facturas").jqGrid('clearGridData');
			// console.log(sParams);
			// $("#btn_consultar").click();
			var url = 'ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?' + sParams;
			$("#gd_Facturas").jqGrid('setGridParam',{ url:url}).trigger("reloadGrid");
		}
		
		function fnEstructuraGrid() {
			jQuery("#gd_Facturas").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG55,
				colModel:[
					//{name:'Sel',index:'Sel', width:70, sortable: false,align:"center",fixed: true},
					{name:'fechafactura',		index:'fechafactura', 		width:70, 	sortable: false,	align:"left",	fixed: true},
					{name:'factura',			index:'factura', 			width:270, 	sortable: false,	align:"left",	fixed: true},
					{name:'idtipodocumento',	index:'idtipodocumento', 	width:250, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nombretipodocumento',index:'nombretipodocumento',width:150, 	sortable: false,	align:"left",	fixed: true},
					{name:'nombreescuela',		index:'nombreescuela', 		width:200, 	sortable: false,	align:"left",	fixed: true},
					{name:'importeF',			index:'importeF', 			width:80, 	sortable: false,	align:"right",	fixed: true},
					{name:'importe',			index:'importe', 			width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
					{name:'fechapago',			index:'fechapago', 			width:90, 	sortable: false,	align:"left",	fixed: true},
					{name:'nom_rutapago',		index:'nom_rutapago', 		width:100, 	sortable: false,	align:"left",	fixed: true/*	, hidden: true*/},
					{name:'importepagoF',		index:'importepagoF', 		width:100, 	sortable: false,	align:"right",	fixed: true},
					{name:'importepago',		index:'importepago', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
					{name:'tipoEscuela',		index:'tipoEscuela', 		width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'id_ciclo_escolar',	index:'id_ciclo_escolar', 	width:100, 	sortable: false,	align:"center",	fixed: true, 	hidden:true},
					{name:'cicloescolar',		index:'cicloescolar', 		width:100, 	sortable: false,	align:"center",	fixed: true},
					{name:'des_rechazo',		index:'des_rechazo', 		width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'ifactura',			index:'ifactura', 			width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'empleado',			index:'empleado', 			width:250, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'colaborador',		index:'colaborador', 		width:250, 	sortable: false,	align:"left",	fixed: true, 	hidden:false},
					{name:'rutapago',			index:'rutapago', 			width:90, 	sortable: false,	align:"left",	fixed: true, 	hidden: true},
					{name:'idestatus',			index:'idestatus', 			width:150, 	sortable: false,	align:"center",	fixed: true, 	hidden:true},
					{name:'estatus',			index:'estatus', 			width:80, 	sortable: false,	align:"center",	fixed: true},
					{name:'fechaestatus',		index:'fechaestatus', 		width:90, 	sortable: false,	align:"left",	fixed: true},
					{name:'modificoestatus',	index:'modificoestatus', 	width:250, 	sortable: false,	align:"left",	fixed: true},
					{name:'nom_archivo_1',		index:'nom_archivo_1', 		width:250, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nom_archivo_2',		index:'nom_archivo_2', 		width:250, 	sortable: false,	align:"left",	fixed: true, 	hidden:true}
				],
				caption:'Listado de Facturas',
				scrollrows : true,
				width: null,
				loadonce: false,
				shrinkToFit: false,
				height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
				rowNum:10,
				rowList:[10, 20, 30],
				pager: '#gd_Facturas_pager',
				sortname: 'fechaCaptura',
				sortorder: "desc",
				viewrecords: true,
				hidegrid:false,
				loadComplete: function (Data) {
					var registros = jQuery("#gd_Facturas").jqGrid('getGridParam', 'reccount');
					if(registros == 0 && iMsjConsulta==1) {
						
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}	
					var table = this;
					setTimeout(function(){
						updatePagerIcons(table);
					}, 0);
					var Total;
					var grid = $('#gd_Facturas');
					Total = grid.jqGrid('getCol', 'importe', false, 'sum');
					$("#txt_Tolal").val(accounting.formatMoney(Total, "", 2));
					Total=0;
					Total = grid.jqGrid('getCol', 'importepago', false, 'sum');
					$("#txt_TolalPagado").val(accounting.formatMoney(Total, "", 2));
				},
				onSelectRow: function(id) {
					if(id >= 0){
						var fila = jQuery("#gd_Facturas").getRowData(id);
					
						iEstatusSeleccionado = fila['idestatus'];
						iFacturaSeleccionada = fila['ifactura'];
						iEmpleadoSeleccionado = fila['empleado'];
						cEscuelaSeleccionada = fila['nombreescuela'];
						cFechaFactura = fila['fechafactura'];
						cImportepagoF = fila['importeF'];
						
						if(fila['idestatus']==3)//rechazada
						{
							$("#cnt_motivo_rechazo").show();
							$("#txt_MotivoRechazo").val(fila['des_rechazo']);
						} else {
							$("#cnt_motivo_rechazo").hide();
							$("#txt_MotivoRechazo").val("");
						}
						
					} else {
						$("#cnt_motivo_rechazo").hide();
						$("#txt_MotivoRechazo").val("");
						
						iEstatusSeleccionado = 0;
						iFacturaSeleccionada = 0;
						iEmpleadoSeleccionado = 0;
						cEscuelaSeleccionada = "";
						cFechaFactura = "";
						cImportepagoF = "";
					}
				}				
			});
			
			barButtongrid({
				pagId:"#gd_Facturas_pager",
				position:"left",//center rigth
				Buttons:[
				{
					icon:"icon-list blue",	
					title:'Ver Factura',
					click: function(event){
						if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
							showalert(LengStrMSG.idMSG86, "", "gritter-info");
						}else{
							VerFactura();
						}	
						event.preventDefault();	
					}
				},
				{
					icon:"icon-download-alt green",
					click:function (event)
					{
						if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
							//message('No hay información');
							showalert(LengStrMSG.idMSG86, "", "gritter-info");
						}else{
							var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
							var rowData = jQuery("#gd_Facturas").getRowData(selr);
							if(selr){
								if(rowData.ifactura!=''){ //facturas pendientes){
									var rowData = jQuery("#gd_Facturas").getRowData(selr);
									if( (rowData.nom_archivo_1!='') || (rowData.nom_archivo_2!='')){
										$("#txt_ciclo").val(rowData.id_ciclo_escolar);
										$("#txt_archivo1").val(rowData.nom_archivo_1);
										$("#txt_archivo2").val(rowData.nom_archivo_2);
										// $("#txt_empleado").val($("#cbo_empleados").val()); 
										$("#txt_empleado").val(rowData.empleado); 
										DescargarAnexos();
									}else{
										//message('La factura seleccionada no tiene anexos');
										showalert(LengStrMSG.idMSG347, "", "gritter-info");	
									}
								}else{
									showalert(LengStrMSG.idMSG348, "", "gritter-info");
								}
							}
							else								
							{
								showalert(LengStrMSG.idMSG348, "", "gritter-info");	
							}
						}	
					},
					title:'Descargar anexos'//button: true 
				},
				{
					icon:"icon-group pink",	
					title:'Mostrar beneficiarios',
					click: function(event){
						var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
						if(selr)
						{
							var rowData = jQuery("#gd_Facturas").getRowData(selr);
							
							if(rowData.ifactura!='') //facturas pendientes)
							{
								var rowData = jQuery("#gd_Facturas").getRowData(selr);
								//var empleado=93902761;
								var urlu='ajax/json/json_fun_obtener_beneficiarios_por_factura.php?iEmpleado='+ rowData.empleado+'&iFactura='+rowData.ifactura+'&inicializar='+0;
								$("#gd_BeneficiariosFactura").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
				
								$('#dlg_BeneficiariosFactura').modal('show');
							}
							else
							{
								// message('Seleccione la factura que desea ver los beneficiarios');
								showalert(LengStrMSG.idMSG349, "", "gritter-info");	
							}
						}
						else
						{
							// message('Seleccione la factura que desea ver los beneficiarios');
							showalert(LengStrMSG.idMSG349, "", "gritter-info");	
						}							
					}
				},
				]
			});
			setSizeBtnGrid('id_button0',35); 
			setSizeBtnGrid('id_button1',35);
			setSizeBtnGrid('id_button2',35);
			
			jQuery("#gd_BeneficiariosFactura").jqGrid({
				datatype: 'json',
				colNames:LengStr.idMSG126,
				colModel:[
					{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
					{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:250, 	sortable: false,	align:"left",	fixed: true},
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
				/**-------------------------------------------------------------------------------------------------------------------------------------
				
				--------------------------------------------------------------------------------------------------------------------------------------*/
				scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
				caption:'Beneficiario De Factura',
				viewrecords : false,
				rowNum:-1,
				hidegrid: false,
				rowList:[],
				width: null,
				shrinkToFit: false,
				height: 120,
				pgbuttons: false,
				pgtext: null,
				loadComplete: function (Data) {
				},
				onSelectRow: function(id) {
				}					
			});		
		}
		
		function DescargarAnexos() {
			var sUrl = 'ajax/proc/proc_descargar_zip.php?';
			sUrl += 'txt_ciclo='+$("#txt_ciclo").val().replace('/^\s+|\s+$/g', '');
			sUrl += '&txt_archivo1='+$("#txt_archivo1").val().replace('/^\s+|\s+$/g', '');
			sUrl += '&txt_archivo2='+$("#txt_archivo2").val().replace('/^\s+|\s+$/g', '');
			sUrl += '&txt_empleado='+$("#txt_empleado").val().replace('/^\s+|\s+$/g', '');
			sUrl += '&csrf_token='+$('#csrfToken').data('token');
			
			console.log(sUrl);
			// return;
			
			var xhr = new XMLHttpRequest();
			
			xhr.open("POST", sUrl, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			
			xhr.addEventListener("progress", function(evt) {
				if (evt.lengthComputable) {
					var percentComplete = evt.loaded / evt.total;
					console.log(percentComplete);;
				}
			}, false);
			
			xhr.responseType = "blob";
			xhr.onreadystatechange = function(){
				waitwindow('', 'close');
				if ( this.readyState == XMLHttpRequest.DONE && this.status == 200 ) {
					var filename = "download.zip";
					
					var link = document.createElement('a');
					link.href = window.URL.createObjectURL(xhr.response);
					link.download = filename;
					link.style.display = 'none';
					
					document.body.appendChild(link);
					
					link.click();
					
					document.body.removeChild(link);
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#txt_empleado").val("");
				} else if (this.readyState == XMLHttpRequest.DONE && (this.status == 405 || this.status == 404 || this.status != 200)) {
					showalert("Documentos no disponibles", "", "gritter-error");
				}
			};
			
			waitwindow('Obteniendo archivos, por favor espere...', 'open');
			xhr.send(sUrl);
		}
		function Imprimir() {
			var params = "";
			params += "empleado=" + $('#cbo_empleados').val() + "&";
			params += "tipo=" + $('#cbo_estatus').val() + "&";
			params += "fechaini=" + formatearFecha( $('#txt_FechaIni').val() ) + "&";
			params += "fechafin=" + formatearFecha( $('#txt_FechaFin').val() ) + "&";
			params += "session_name=" + Session + "&";
			params += "nom_empleado=" + $("#cbo_empleados option:selected").html() + "&";
			params += "cEstatus=" + $("#cbo_estatus option:selected").html() + "&";
			params += "iOpcion=2&";
			
			var urlu = 'ajax/json/impresion_facturas_colegiaturas_por_empleado.php?' + params;
				
			location.href = urlu;
		}		

		function llenarComboCentros(callback) {
			$.ajax({type:'POST',
				url:'ajax/json/json_proc_obtener_centros_por_empleado.php',
				data:{
					'session_name':Session,
					'format' : 'select'
				},
				beforeSend: function() {},
				success: function(data) {
					var sanitizedData = limpiarCadena(data);
					$("#cbo_centro").trigger("chosen:updated").html(sanitizedData);
					$("#cbo_centro").trigger("chosen:updated");
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
		
		function llenarComboEstatus(callback) {
			var option="";
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_obtener_estatus_facturas.php",
				data: { },
				beforeSend:function(){},
				success:function(data){
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0)
					{
						//option = option + "<option value='0'>SELECCIONE</option>";
						option = option + "<option value='-1'>TODOS</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
						}
						$("#cbo_estatus").trigger("chosen:updated").html(option);
						$("#cbo_estatus").val(-1);
						$("#cbo_estatus").trigger("chosen:updated");
						// if (callback != undefined) {
							
						// }
					}
					else
					{
						// message(dataJson.mensaje);
						showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-info");	
					}
				},
				error:function onError(){callback();},
				complete:function(){callback();},
				timeout: function(){callback();},
				abort: function(){callback();}
			});	
		}
		
		function llenarComboEmpleados(callback) {
			$.ajax({type:'POST',
				url:'ajax/json/json_fun_obtener_empleados_por_centro.php',
				//data:{'sListadoCentros':$("#cbo_centro").val()},
				data:{'sListadoCentros':DOMPurify.sanitize($("#cbo_centro").val())},
				beforeSend:function(){},
				success:function(data){
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					var arreglo = dataJson.resultado;
					var option = "";
					for(var i in arreglo){
						option = option + "<option centro='" + arreglo[i].idu_centro + "' value='" + arreglo[i].idu_empleado + "'>" + arreglo[i].nom_empleado + "</option>";
					}
					$("#cbo_empleados").trigger("chosen:updated").html(option);
					$("#cbo_empleados").trigger("chosen:updated");
					// if (callback != undefined) {
						// callback();
					// }
				},
				error:function onError(){callback();},
				complete:function(){callback();},
				timeout: function(){callback();},
				abort: function(){callback();}
			});
		}
		
		function llenarComboMotivosRechazo(callback) {
			var iOpcion = 3;
			$.ajax({type:'POST',
				url: 'ajax/json/json_fun_obtener_listado_motivos_combo.php?',
				data:{iOpcion},
				beforeSend:function(){},
				success:function(data){
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					var option="";
					option = option + "<option value='0'>SELECCIONE</option>";
					for(var i = 0; i < dataJson.datos.length; i++ ){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_motivo_rechazo").trigger("chosen:updated").html(option);
					$("#cbo_motivo_rechazo").trigger("chosen:updated");
				},
				error: function onError(){callback();},
				complete: function(){callback();},
				timeout: function(){callback();},
				abort: function(){callback();}
			});
		}
	
	function load_cargando(nPorcen) {
		if(nPorcen == -1) {
			var porc = $("#div_loading").css('width').replace("%",'');
			porc = $("#div_loading").css('width').replace("px",'');
			if(porc >= limit)
			{
				if(limite <= 30)
				{
					limite++;
					porc = limit;
				}
				else
				{
					limite = 0;
					limit++;
					porc = limit + (Math.floor((Math.random() * 5) + 1));
					if(porc >= 99){limit = 99; porc = limit;}
				}
				
			} 
			else
			{
				porc = limit + (Math.floor((Math.random() * 10) + 1));
			}
			porc = (porc+'%');
			$("#div_load").attr('data-percent',porc);
			$("#div_loading").css('width',porc);
		} else {
			var porc = nPorcen;
			porc = (porc+'%');
			$("#div_load").attr('data-percent',porc);
			$("#div_loading").css('width',porc);
		}
	}
	
	function fnObtenerNotificaciones(callback) {	
		$.ajax({type:'POST',
			url:'ajax/json/json_fun_total_facturas_pendientes_aturizar.php',
			data:{	'nOpcion':1,
					'sListadoCentros':$("#cbo_centro").val()},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				var estado = dataJson.estado;
				
				if(estado==0) {
					var total=dataJson.total;
					var empledos="";
					if (total>0) {
						empleados=dataJson.empleados;
					
						$("#div_Notificacion_G").html(
							'<a class="radius-4" href="#"><font color="green"><i id="btn_Blog" class="icon-envelope-alt blue bigger-300" style="cursor: pointer;position: relative; top: 7px" '+
							'title="Tiene facturas pendientes por autorizar  '+empleados+'"  data-original-title="Tiene facturas pendientes por autorizar '+empleados+'"></i>'+
							'<span class="badge badge-important">+'+dataJson.total+'</span></a>' 
						);
					} else {
						$("#div_Notificacion_G").html("");
					}
				} else {
					$("#div_Notificacion_G").html("");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	
	function VerFactura() {
		var selr = jQuery('#gd_Facturas').jqGrid('getGridParam', 'selrow');
		var rowData = jQuery('#gd_Facturas').getRowData(selr);
		if(iFacturaSeleccionada != 0) {
			if(rowData.nom_archivo_1 == '') {
				showalert("La factura no tiene un XML relacionado", "", "gritter-info");
				return;
			} else {
				// var rowData = jQuery("gd_Facturas").getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.ifactura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			}
		} else {
			showalert("Seleccione un registro", "", "gritter-info");
		}
	}
	function cargarFactura() {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_leerfactura.php',
			data:{
				session_name: Session
				, 'nIsFactura': $("#nIsFactura").val()
				// , 'sFacFiscal': $("#sFacFiscal").val()
				, 'idFactura': $("#idfactura").val()
				, 'sFilename': $("#sFilename").val()
				, 'sFiliePath': $("#sFiliePath").val()
			},
		})
		.done(function(data){
			SessionIs();
			var sanitizedData = limpiarCadena(data);
			data = json_decode(sanitizedData);
			if(data.estado == 0) {
				leerFactura(data);
			} else {
				loadIs = true;
				showalert(data.mensaje, "", "gritter-info");
			}
		})
		.fail(function(s) {alert("Error al cargar ajax/json/json_leerfactura.php"); $('#pag_content').fadeOut();})
		.always(function() {});
		
	}
	function leerFactura(obj) {
		if(obj.isFactura == 0) {
			$("#div_contenido").html("<img src='"+obj.noDeducible+"' alt='Error: 404 not found'/>");
		} else {
			$("#div_contenido").html(obj.factura);
			
			$("#btn_ver").click();
		}
		loadIs = true;
	}
	
	function setSizeBtnGrid(id,tamanio) {
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
});