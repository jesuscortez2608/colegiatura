$(function() {
	SessionIs();
	$("#pag_title").html('Seguimiento de Facturas Electrónicas de Colaboradores');
	var iFactura=0, iEmpleado=0, Boton=0;
	var NomXML = '', NomPDF = '';
	fnEstructuraGrid();
	fnConsultaEstatus();
	iEmpleado=$('#hid_idu_usuario').val();

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

	fnObtenerNotificaciones(function(){});
	CargarCiclosEscolares();
	waitwindow('Cargando','open');
	ConsultarEmpleado(function() {
		CargarDatosGenerales()
		fnConsultaAvisos(2);
		waitwindow('Cargando','close');
	});

	//Ocultar Sueldo del Colaborador
	$("#info-colab").hide();

	$("#sh-info-colab").click(function() {
		$("#info-colab").toggle();
		if($("#info-colab").is(':visible')){
			console.log(`El elemento es visible`);
			$("#arrow-info-colab").removeClass("icon-angle-right").addClass("icon-angle-down");
		}else{
			console.log(`El elemento no es visible.`);
			$("#arrow-info-colab").removeClass("icon-angle-down").addClass("icon-angle-right");
		}
	});

	var tipoConsulta=0;  // 0=PENDIENTE, 1=PROCESO, 2=ACEPTADA POR PAGAR, 3=RECHAZADA, 4=ACLARACION, 5=REVISION, 6=PAGADA
	//---------- VER FACTURA --->
	//2707
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
						$("#gd_Facturas").jqGrid('resetSelection');
						iFactura = 0;
						$( this ).dialog( "close" );
					}
				}
			]
		});

		cnt_ver_factura.dialog("open");
		event.preventDefault();
	});
	//----------------------------------------------------------------------------------------------<----!
	$('#cont_rechazo').hide();
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
			$( "#txt_FechaIni" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	//$("#txt_FechaIni" ).datepicker("setDate",new Date());
	$("#txt_FechaFin" ).datepicker("setDate",new Date());

	$( "#txt_FechaIni" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaIni" ).val() );

	$(".ui-datepicker-trigger").css('display','none');


	//Botones
	$("#btn_consultar").click(function(event){
		fnConsultarFacturas(0);
		event.preventDefault();
	});
	
	$("#btn_consultar").focusout(function(){
		$("#cbo_Estatus").focus();
	});

	$('#dlg_Blog').on('show.bs.modal', function (event) {
		// fnConsultaBlog(iEmpleado, iFactura);
		//Actualizar leido
		fnActualizarBlog(function(){fnObtenerNotificaciones();});
		//fnObtenerNotificaciones(function(){fnActualizarBlog();});
	});
	
	$('#dlg_Blog').on('hide.bs.modal', function (event) {
		fnObtenerNotificaciones();
	});
	
	function fnActualizarBlog(callback) {
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_marcar_blog.php?",
		data: {
				'Factura':iFactura,
				'session_name': Session
			}
		})
		.done(function(data){
			//fnObtenerNotificaciones();
		});
	}

	function ConsultarEmpleado(callback) {
		$.ajax({type: "POST",
		url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
		data: {
				'session_name': Session
			}
		})
		.done(function(data) {
			var dataJson = JSON.parse(data);
			if(dataJson!=null) {
				if(dataJson[0].cancelado==1) {
					loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'Colaborador dado de baja'}});	
				} else {
					$("#txt_SueldoMensual").val(dataJson[0].sueldo);
					$("#txt_TopeProp").val(dataJson[0].topeproporcion);
				}
			} else {
				// showmessage('No existe el número de empleado', '', undefined, undefined, function onclose(){
					loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'No existe el colaborador'}});	
					// showalert("No existe el número de empleado", "", "gritter-warning");
					// $("#txt_SueldoMensual").val("");
					// $("#txt_TopeProp").val("");
				// });
			}
			callback();
		});
	}
	function CargarDatosGenerales() {
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_calcular_topes_colegiaturas.php?",
		data: {
				'iSueldo':accounting.unformat($("#txt_SueldoMensual").val()),
				'session_name': Session
			}
		})
		.done(function(data) {
			var dataJson = JSON.parse(data);
			if(dataJson != 0) {
				var ImporteFormato="0";
				$("#txt_TopeMensual").val(dataJson.topeMensual);
				ImporteFormato=accounting.formatMoney(dataJson.acumulado, "", 2);
				$("#txt_AcumFactPag").val(ImporteFormato);
				ImporteFormato=accounting.unformat($("#txt_TopeProp").val())-accounting.unformat($("#txt_AcumFactPag").val());
				ImporteFormato=accounting.formatMoney(ImporteFormato, "", 2);
				$("#txt_TopeRest").val(ImporteFormato);
			} else {
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los importes", "", "gritter-error");
			}
		});
	}
	function fnConsultaEstatus() {
		var option="";
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_estatus_facturas.php",
		data: { }
		}).done(function(data){
			const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				option = option + "<option value='-1'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
				}
				$("#cbo_Estatus").trigger("chosen:updated").html(option);
				$("#cbo_Estatus").trigger("chosen:updated");
			} else {
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			}
		})
		.fail(function(s) {
			// message("Error al cargar json_fun_obtener_estatus_facturas.php" );
			showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			$('#cbo_Estatus').fadeOut();})
		.always(function() {});
	}
	//Combo Ciclos escolares
	function CargarCiclosEscolares() {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {}
		}).done(function(data){
			const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
			    $("#cbo_CicloEscolar").html(option);
				$("#cbo_CicloEscolar").trigger("chosen:updated");
			} else {
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
			}
		})
		.fail(function(s) {
			// message("Error al cargar ajax/json/json_fun_obtener_ciclos_escolares.php"  ); 
			showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	}
	function fnEstructuraGrid() {
		jQuery("#gd_Facturas").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG3,
			colModel:[
				//{name:'Sel', index:'Sel', width:70, sortable: false, align:"center", fixed: true},
				{name:'fechafactura',			index:'fechafactura', 			width:90, 	sortable: false,	align:"center",	fixed: 	true},
				{name:'idestatus',				index:'idestatus', 				width:150, 	sortable: false,	align:"center",	fixed: 	true, 	hidden:true},
				{name:'estatus',				index:'estatus', 				width:150, 	sortable: false,	align:"center",	fixed: 	true},
				{name:'fechaestatus',			index:'fechaestatus', 			width:90, 	sortable: false,	align:"center",	fixed: 	true},
				{name:'modificoestatus',		index:'modificoestatus', 		width:250, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'factura',				index:'factura', 				width:270, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'idtipodocumento',		index:'idtipodocumento',		width:10,	sortable: false,	align:"left",	fixed:	true,	hidden:true},
				{name:'nombretipodocumento',	index:'nombretipodocumento', 	width:270, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'nombreescuela',			index:'nombreescuela', 			width:200, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'importeF',				index:'importeF', 				width:100, 	sortable: false,	align:"right",	fixed: 	true},
				{name:'importe',				index:'importe', 				width:100, 	sortable: false,	align:"right",	fixed: 	true, 	hidden:true},
				{name:'fechapago',				index:'fechapago', 				width:90, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'importepagoF',			index:'importepagoF', 			width:100, 	sortable: false,	align:"right",	fixed: 	true},
				{name:'importepago',			index:'importepago', 			width:100, 	sortable: false,	align:"right",	fixed: 	true, 	hidden:true},
				{name:'tipoEscuela',			index:'tipoEscuela', 			width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'idu_ciclo',				index:'idu_ciclo', 				width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'cicloescolar',			index:'cicloescolar', 			width:100, 	sortable: false,	align:"center",	fixed: 	true},
				{name:'des_rechazo',			index:'des_rechazo', 			width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'ifactura',				index:'ifactura', 				width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'empleado',				index:'empleado', 				width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'archivo1',				index:'archivo1', 				width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'archivo2',				index:'archivo2', 				width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'idu_escuela',			index:'idu_escuela', 			width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'rfc_escuela',			index:'rfc_escuela', 			width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'nom_escuela',			index:'nom_escuela', 			width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'id_nota',				index:'id_nota', 				width:100, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'folio_nota',				index:'folio_nota', 			width:270, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'importe_aplicado',		index:'importe_aplicado', 		width:100, 	sortable: false,	align:"right",	fixed: 	true},
				{name:'opc_blog_colaborador',	index:'opc_blog_colaborador', 	width:120, 	sortable: false,	align:"left",	fixed: 	true,	hidden:true},
				{name:'blog_colaborador',		index:'blog_colaborador', 		width:120, 	sortable: false,	align:"center",	fixed: 	true,	hidden:true}
			],
			caption:'Facturas Pendientes',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 380,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_Facturas_pager',
			sortname: 'fechaFac',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				estatus=$("#cbo_Estatus").val();

				if (estatus!=4) {
					//var Jdata = $("#gd_Facturas").jqGrid('getRowData', ($("#gd_Facturas").find("tr").length - 1) );
					//if (Jdata.blog_colaborador == "<b>0</b>")
					$("#gd_Facturas").jqGrid('hideCol',["blog_colaborador"]);
				} else {
					$("#gd_Facturas").jqGrid('showCol',["blog_colaborador"]);
				}
				var registros = jQuery("#gd_Facturas").jqGrid('getGridParam', 'reccount');
				$('#cont_rechazo').hide();
				if(registros == 0) {
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					//showmessage('No se encontraron datos en la consulta', '', undefined, undefined, function onclose(){});
				}

				var table = this;
				setTimeout(function() {
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
				if(id >= 0) {
					var fila = jQuery("#gd_Facturas").getRowData(id);
					iFactura = fila['ifactura'];
					NomXML = fila['archivo1'];
					NomPDF = fila['archivo2'];
					// showalert("TipoDocto: "+fila['idtipodocumento'], "", "gritter-info");
					if(fila['idestatus']==3) {  //rechazada
						$('#cont_rechazo').show();
						$("#txt_MotivoRechazo").val(fila['des_rechazo']);
					} else {
						if (fila['idestatus'] == 1 && fila['des_rechazo']!='') {
							$('#cont_rechazo').show();
							$("#txt_MotivoRechazo").val(fila['des_rechazo']);
						} else {
							$("#txt_MotivoRechazo").val("");
							$('#cont_rechazo').hide();
						}
					}
				} else {
					$("#txt_MotivoRechazo").val("");
					$('#cont_rechazo').hide();
				}
			},
			ondblClickRow: function(id) {
				$("#gd_Facturas").jqGrid('resetSelection');
			}
		});
		barButtongrid({
			pagId:"#gd_Facturas_pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-list blue",
				title:'Ver Factura',
				click: function(event) {
					if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						var selr = jQuery('#gd_Facturas').jqGrid('getGridParam', 'selrow');
						if ( selr ) {
							VerFactura();
						} else {
							showalert("Seleccione la factura para visualizarla", "", "gritter-info");
							return;
						}
					}
					event.preventDefault();
				}
			},
			{
				icon:"icon-download-alt green",
				click:function (event) {
					if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						// message('No hay información');
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
						if(selr) {
							var rowData = jQuery("#gd_Facturas").getRowData(selr);
							if(rowData.ifactura=='') {
								showalert(LengStrMSG.idMSG324, "", "gritter-info");
							} else {
								if( (rowData.archivo1!='') || (rowData.archivo2!='')) {
									$("#txt_ciclo").val(rowData.idu_ciclo);
									$("#txt_archivo1").val(rowData.archivo1);
									$("#txt_archivo2").val(rowData.archivo2);
									$("#txt_empleado").val(iEmpleado);

									DescargarAnexos();
								} else {
									// message('La factura seleccionada no tiene anexos');
									showalert(LengStrMSG.idMSG325, "", "gritter-info");
								}
							}
						} else {
							//message('Seleccione la factura que desea descargar los anexos');
							showalert(LengStrMSG.idMSG324, "", "gritter-info");
						}
					}
				},
				title:'Descargar anexos'//button: true
			},
			{
				icon:"icon-trash red",
				title:'Eliminar factura',
				click: function(event) {
					if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
						if(selr) {
							var rowData = jQuery("#gd_Facturas").getRowData(selr);

							if(rowData.ifactura=='') {
								showalert(LengStrMSG.idMSG329, "", "gritter-info");
							} else if(rowData.idestatus==1 ) { //facturas pendientes // en proceso ya 

								bootbox.confirm(LengStrMSG.idMSG326,
								function(result){
									if (result) {
										$.ajax({type: "POST",
										url: "ajax/json/json_fun_eliminar_facturas_colegiaturas.php",
										data: {
												'idFactura':rowData.ifactura,
												'iFacturaFiscal':rowData.factura ,
												'session_name': Session
											}
										})
										.done(function(data){
											var dataJson = JSON.parse(data);
											if(dataJson.estado == 0) {
												//message(dataJson.mensaje);
												showalert(LengStrMSG.idMSG327, "", "gritter-success");
												fnConsultarFacturas(0);
											} else {
												// message('Ocurrio un problema al eliminar la factura');
												showalert(LengStrMSG.idMSG231+" la factura", "", "gritter-error");
											}
										});
									}
								});
							} else {
								// message("Solo se pueden eliminar facturas con estatus pendiente")
								showalert(LengStrMSG.idMSG328, "", "gritter-info");
							}
						} else {
							// message('Seleccione la factura que desea eliminar');
							showalert(LengStrMSG.idMSG329, "", "gritter-info");
						}
					}
				}
			},
			{
				icon:"icon-group pink",
				title:'Mostrar beneficiarios',
				click: function(event) {
					if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						// message('No hay información');
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
						if(selr) {
							var rowData = jQuery("#gd_Facturas").getRowData(selr);

							if(rowData.ifactura!='') { //facturas pendientes
								var rowData = jQuery("#gd_Facturas").getRowData(selr);
								//var empleado=93902761;
								var urlu='ajax/json/json_fun_obtener_beneficiarios_por_factura.php?iEmpleado='+ rowData.empleado+'&iFactura='+rowData.ifactura+'&inicializar='+0;
								$("#gd_BeneficiariosFactura").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");

								$('#dlg_BeneficiariosFactura').modal('show');

							} else {
								showalert(LengStrMSG.idMSG330, "", "gritter-info");
							}
						} else {
							// message('Seleccione la factura que desea ver los beneficiarios');
							showalert(LengStrMSG.idMSG330, "", "gritter-info");
						}
					}
				}
			},
			{
				icon:"icon-edit orange",
				title:'Modificar factura',
				click: function(event) {
					if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						// message('No hay información');
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
						if(selr) {
							var rowData = jQuery("#gd_Facturas").getRowData(selr);
							var param= {'Factura':rowData.ifactura
									, 'idu_escuela':rowData.idu_escuela
									, 'rfc_escuela':rowData.rfc_escuela
									, 'nom_escuela':rowData.nom_escuela
									, 'NomXML': rowData.archivo1
									, 'NomPDF': rowData.archivo2
								};
							if(rowData.ifactura=='') {
								showalert(LengStrMSG.idMSG331, "", "gritter-info");
							} else if(rowData.idestatus==1 || rowData.idestatus == 4) {		//facturas pendientes
								if (rowData.idtipodocumento == 2 || rowData.idtipodocumento != 4) {
									loadContent('ajax/frm/frm_subirFacturaElectronica_Modificar.php',param);
								} else {
									showalert("Solo puede modificar Ingresos o Pagos", "", "gritter-warning");
									return;
								}
								// if(rowData.tipoEscuela==1)//Escuela Pública
								// {
									//activaOpc(findIndex('frm_subirFacturasElectronicaEscuelaPublica.php'),'frm_subirFacturasElectronicaEscuelaPublica.php');
									// loadContent('ajax/frm/frm_subirFacturasElectronicaEscuelaPublica.php',param);
								// }
								// else
								// {
									//loadContent('ajax/frm/frm_subirFacturasElectronicaEscuelaPrivada.php',param);
									//activaOpc(findIndex('frm_subirFacturasElectronicaEscuelaPrivada.php?Opcion=1&Factura'+rowData.ifactura),'frm_subirFacturasElectronicaEscuelaPrivada.php?Opcion=1&Factura'+rowData.ifactura);
								// }
							} else {
								// showalert(LengStrMSG.idMSG332, "", "gritter-info");
								showalert("Solo se pueden modificar facturas con estatus pendiente o en aclaración", "", "gritter-info");
							}
						} else {
							showalert("Seleccione la factura a modificar", "", "gritter-info");
							return;
						}
					}
				}
			},
			{
				icon:"icon-comments-alt ",
				title:'Ver aclaraciones',
				click:function (event)
				{
					if (tipoConsulta!=4 && tipoConsulta != -1) {
						showalert("Solo es posible revisar blog de las facturas en aclaración", "", "gritter-info");
						return;
					} else {
						if (($("#gd_Facturas").find("tr").length - 1) == 0 ) {
							// message('No hay información');
							showalert(LengStrMSG.idMSG86, "", "gritter-info");
						} else {
							var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
							var rowData = jQuery("#gd_Facturas").getRowData(selr);
							var param= {'Factura':rowData.ifactura}
							//if(selr)
							if(rowData.ifactura!='') {
								var rowData = jQuery("#gd_Facturas").getRowData(selr);
								fnConsultaBlog(rowData.empleado, rowData.ifactura);
								//fnConsultaBlogRevision(rowData.empleado, rowData.ifactura);
								iFactura=rowData.ifactura;
								$('#dlg_Blog').modal('show');
							} else {
								// message('Seleccione la factura que desea ver las aclaraciones');
								showalert(LengStrMSG.idMSG333, "", "gritter-info");
							}
						}
					}
				},
				color:'rgb(22,167,101)'
			}
			/*,{
				icon:"icon-print blue ",	
				title:'Imprimir',
				click:function (event)
				{
					if (($("#gd_Facturas").find("tr").length - 1) == 0 ) 
					{
						showalert("No hay información", "", "gritter-info");
					}
					else
					{
						Imprimir();
					}
				}
			}*/
			]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
		setSizeBtnGrid('id_button2',35);
		setSizeBtnGrid('id_button3',35);
		setSizeBtnGrid('id_button4',35);
		setSizeBtnGrid('id_button5',35);

		jQuery("#gd_BeneficiariosFactura").jqGrid({
			datatype: 'json',
			//mtype: 'POST',
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
			//viewrecords : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			//caption:'Beneficiarios',
			//pager : "#gd_Aclaracion_pager",
			//--Para que el tama�o sea automatico muy bueno ya con los otros cambios se evita crear tablas
			width: null,
			shrinkToFit: false,
			height: 120,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			//----------------------------------------------------------------------------------------------------------
			//caption: 'Cifras',
			pgbuttons: false,
			pgtext: "Pag",
			//postData:{session_name:Session},
			
			loadComplete: function (Data) {
				var registros = jQuery("#gd_BeneficiariosFactura").jqGrid('getGridParam', 'reccount');

				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				var Total;
				var grid = $('#gd_BeneficiariosFactura');
				Total = grid.jqGrid('getCol', 'imp_importe', false, 'sum');
				$("#txt_TotalB").val(accounting.formatMoney(Total, "", 2));
			},
			onSelectRow: function(id) {
				// if(id >= 0){
					// var fila = jQuery("#gd_Beneficiarios").getRowData(id); 
					// $("#txt_Comentario_Especial").val(fila['comentario']);
					
				// } else {
					// $("#txt_Comentario_Especial").val("");
				// }
			}
		});
	}

	//DESCARGAR ANEXOS
	function DescargarAnexos() {		
		
		var sUrl = "ajax/proc/proc_descargar_zip.php?";
			sUrl += "txt_ciclo=" + $("#txt_ciclo").val() + "&";
			sUrl += "txt_archivo1=" + $("#txt_archivo1").val() + "&";
			sUrl += "txt_archivo2=" + $("#txt_archivo2").val() + "&";
			sUrl += "txt_empleado=" + $("#txt_empleado").val() + "&";
			sUrl += 'csrf_token='+$('#csrfToken').data('token');
		
		var xhr = new XMLHttpRequest();
		
		xhr.open("POST", sUrl, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		
		xhr.addEventListener("progress", function (evt) {
			if(evt.lengthComputable) {
				var percentComplete = evt.loaded / evt.total;
			}
		}, false);
		
		xhr.responseType = "blob";
		xhr.onreadystatechange = function() {
			waitwindow('', 'close');
			if(this.readyState == XMLHttpRequest.DONE && this.status == 200) {
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
			} else if (this.readyState == XMLHttpRequest.DONE && (this.status == 405 || this.status == 404 || this.status != 200) ) {
				//showalert("No se encontraron los documentos en Alfresco", "", "gritter-info");
				showalert("Documentos no disponibles", "", "gritter-error");
			}
		};
		
		waitwindow('Obteniendo archivos, por favor espere...', 'open');
		xhr.send(sUrl);
	}

	function fnObtenerNotificaciones() {		//fun_obtener_notificaciones_por_empleado
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_notificaciones_por_empleado.php",
		data: { 'session_name': Session,'iFactura':0}
		}).done(function(data){
			const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				if(dataJson.datos.length>0) {		// Hay mensajes sin leer
					var UltimoReg=dataJson.datos.length-1;
					var Notificar=0;
					Notificar=dataJson.datos[UltimoReg].notificar;
					
					var Empleado=dataJson.datos[UltimoReg].empleado;
					for(var i=0;i<dataJson.datos.length; i++) {
						if(dataJson.datos[i].leido==0) {
							if(dataJson.datos[i].destino==Empleado) {
								iFactura=dataJson.datos[i].id_factura;
							}
						}
					}
					if(Notificar!=0) {
					//label label-inverse arrowed-in
						$("#div_Notificacion").html(
							'<a class="radius-4" href="#"><font color="blue"><i id="btn_Blog" class="icon-envelope bigger-300" style="cursor: pointer;position: relative; top: 7px" '+
							'title="Tiene facturas en aclaración/Rechazadas, favor de revisar"  data-original-title="Tiene facturas en aclaración/Rechazadas, favor de revisar"></i>'+
							'<span class="badge badge-important">+'+Notificar+'</span></a>'
						);
						if(Boton==0) {
							Boton=1;
							$("#div_Notificacion").on("click", "#btn_Blog", function(){
								fnConsultaBlog(iEmpleado, iFactura);
								$('#dlg_Blog').modal('show');
							});
						}
					} else {
						$("#div_Notificacion").html("");
					}
				} else {
					$("#div_Notificacion").html("");
				}
			}
		})
		.fail(function(s) {
			// message("Error al cargar " + url );}
			showalert("Error al  ejecutar json_fun_obtener_notificaciones_por_empleado.php", "", "gritter-warning");
			$("#div_Blog").html("");})
		.always(function() {});
	}
	function Imprimir() {
		var params = "";
	//	params += "empleado=" + $('#cbo_empleados').val() + "&";
		params += "tipo=" + $('#cbo_Estatus').val() + "&";
		params += "fechaini=" + formatearFecha( $('#txt_FechaIni').val() ) + "&";
		params += "fechafin=" + formatearFecha( $('#txt_FechaFin').val() ) + "&";
		params += "session_name=" + Session + "&";
		//params += "nom_empleado=" + $("#cbo_empleados option:selected").html() + "&";
		params += "cEstatus=" + $("#cbo_Estatus option:selected").html() + "&";
		params += "cicloEscolar=" + $("#cbo_CicloEscolar").val() + "&";
		params += "sidx=fecha_estatus&";
		params += "iOpcion=1&";

		var urlu = 'ajax/json/impresion_facturas_colegiaturas_por_empleado.php?' + params;

		location.href = urlu;
		
		// var sFechaIni=formatearFecha($('#txt_FechaIni').val());
		// var sFechaFin=formatearFecha($('#txt_FechaFin').val());
		// var iTipo=$("#cbo_Estatus").val();
		// var CicloEscolar=$("#cbo_CicloEscolar").val();
		// var urlu='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?'+
			// 'iOpcion=1&tipo='+iTipo+'&session_name=' +Session+'&inicializar='+inicializar+'&fechaini='+sFechaIni+'&fechafin='+sFechaFin+'&cicloEscolar='+CicloEscolar;
		// var nombreConsulta='FACTURAS '+$('#cbo_Estatus option:selected').html();
		
	}
	function fnConsultarFacturas(inicializar) {
		tipoConsulta=$("#cbo_Estatus").val();
		var sFechaIni=formatearFecha($('#txt_FechaIni').val());
		var sFechaFin=formatearFecha($('#txt_FechaFin').val());
		var iTipo=$("#cbo_Estatus").val();
		var CicloEscolar=$("#cbo_CicloEscolar").val();
		var urlu='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?'+
			'iOpcion=1&tipo='+iTipo+'&session_name=' +Session+'&inicializar='+inicializar+'&fechaini='+sFechaIni+'&fechafin='+sFechaFin+'&cicloEscolar='+CicloEscolar;
		var nombreConsulta='FACTURAS '+$('#cbo_Estatus option:selected').html();

		$("#txt_MotivoRechazo").val("");
		$('#gd_Facturas').jqGrid('setCaption', nombreConsulta);

		$("#gd_Facturas").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
	}
	function updatePagerIcons(table) {
		var replacement =  {
			'ui-icon-seek-first' : 'icon-double-angle-left bigger-140',
			'ui-icon-seek-prev' : 'icon-angle-left bigger-140',
			'ui-icon-seek-next' : 'icon-angle-right bigger-140',
			'ui-icon-seek-end' : 'icon-double-angle-right bigger-140'
		};
		$('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function(){
			var icon = $(this);
			var $class = icon.attr('class').replace('ui-icon', '').replace(/^\s+|\s+$/g, '');

			if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
		})
	}

	$("#btn_EnviarComentario").click(function(event){
		if($("#txt_mensaje").val().replace(/^\s+|\s+$/g, '')=="") {
			// message("Favor de proporcionar un comentario");
			showalert(LengStrMSG.idMSG334, "", "gritter-info");
			$("#txt_mensaje").val("");
			$("#txt_mensaje").focus();
		} else {
			fnEnviarComentario();
		}
		event.preventDefault();	
	});
	function fnEnviarComentario() {
		var Comentario=$("#txt_mensaje").val().toUpperCase();
		var opciones= {
			beforeSubmit: function(){
			},
			uploadProgress: function(){
			},
			success: function(data) {
				var dataJson = JSON.parse(data);
				if (dataJson.estado !=1) {
					// message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG230+" el comentario", "", "gritter-warning");
				} else {
					// message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG335, "", "gritter-success");					
					UPD_NotificacionEnAclaracion(1, iFactura, iEmpleado);
				}
				$('#dlg_Blog').modal('hide');
				$("#txt_mensaje").val("");
			}
		};
		$( '#session_name1' ).val(Session);
		$( '#hid_factura' ).val(iFactura);
		$("#txt_mensaje").val(Comentario);
		$( '#hid_empleado' ).val(iEmpleado);

		$( '#fmComentario' ).ajaxForm(opciones) ;
		$( '#fmComentario' ).submit();
	}
////////////////////////BOTON Beneficiarios////////////////////////////
	$('#cnt_busquedaSF').dialog({
		title_html: true,
		width:700,
		height:460,
		modal: true,
		autoOpen: false,
		open: function(){
			$(this).css('overflow', 'hidden');
		},
		close: function(){
			$('#cnt_busquedaSF').html("");
		}
	});
	
	$('#btn_detalleBenefi').click(function(){
		$.ajax({
			type: 'POST',
			url: 'ajax/frm/frm_beneficiariosAgregados.php',
			data: {	}
			}).done(function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				data = sanitizedData.replace(/<!--url-->/g,util_url);
				$("#cnt_busquedaSF").html ("" + data + "");
				$("#cnt_busquedaSF").dialog('open');
			});
	});
	function setSizeBtnGrid(id,tamanio) {
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}

	//VER FACTURA
	function VerFactura(){
		var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
		var rowData = jQuery("#gd_Facturas").getRowData(selr);
		//var param= {'Factura':rowData.ifactura}
		//if(selr) 
		if(rowData.ifactura!='') {
			var rowData = jQuery("#gd_Facturas").getRowData(selr);
			$("#nIsFactura").val(0);
			// $("#sFacFiscal").val(rowData.factura);
			$("#idfactura").val(rowData.ifactura);
			$("#sFilename").val('');
			$("#sFiliePath").val('');
			cargarFactura();
		} else {
			showalert("Seleccione un registro", "", "gritter-info");
		}
	}
	function cargarFactura() {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_leerfactura.php',
			data:{session_name : Session
				, 'nIsFactura' : $("#nIsFactura").val()
				// , 'sFacFiscal' : $("#sFacFiscal").val()
				, 'idFactura' : $("#idfactura").val()
				, 'sFilename' : $("#sFilename").val()
				, 'sFiliePath' : $("#sFiliePath").val()
			},
		})
		.done(function(data){
			data = limpiarCadena(data); //Corrección de vulnerabilidad
			SessionIs();
			data = json_decode(data);
			if(data.estado == 0){
				leerFactura(data);
			} else {
				loadIs = true;
				showalert(data.mensaje, "", "gritter-info");
			}
		})
		.fail(function(s) {alert("Error al cargar ajax/json/json_leerfactura.php"); $('#pag_content').fadeOut();})
		.always(function() {});
	}
	function leerFactura(obj){
		if(obj.isFactura == 0) {
			$("#div_contenido").html("<img src='"+obj.noDeducible+"' alt='Error: 404 not found'/>");
		} else {
			$("#div_contenido").html(obj.factura);
			$("#btn_ver").click();
		}
		loadIs = true;
	}
});	

// Petición 39116 

// --- NOTIFICACIONES

function UPD_NotificacionEnAclaracion(iOpcion, iFactura, iEmpleado) {
	$.ajax({type:'POST',
		url:'ajax/json/json_fun_afecta_notificacion_aclaracion.php',
		data:{
			'iOpcion':iOpcion,
			// 'iFactura':'['+iFactura+']',
			'iFactura':iFactura,
			'iEmpleado':iEmpleado
		}
	});
}

// --- Crecer textarea conforme se va escribiendo.
function autoGrow(element) { // Establece temporalmente la altura a 5px para obtener el scrollHeight correcto
	if(element.scrollHeight < 100 ){
		element.style.height = "5px"; 
		element.style.height = (element.scrollHeight) + "px";
	}
}


// $("#dlg_Blog").find(".close").click(function(){
// 	$("#txt_mensaje").val("");
// 	$("#txt_mensaje").css("height","20px");
// });