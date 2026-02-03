var cantidadImp = [];
var rowBeneficiario = ['idu_hoja_azul', 'idu_beneficiario', 'Beneficiario', 'Fecha de nacimiento', 'Edad', 'idu_parentesco', 
									'Parentesco', 'idu_tipo_pago', 'Tipo Pago', 'Periodo', 'idu_escolaridad', 'Escolaridad', 'idu_carrera', 
									'Carrera', 'Importe Concepto', 'imp_importe', 'idu_grado', 'Grado', 'idu_ciclo', 'Ciclo Escolar', 'Descuento', 'comentario',	
									'keyx'];
$(function(){
	ConsultaClaveHCM();
	fnConsultaPorcentajes($( '#txt_Numemp' ).val()); // Se agrega para consultar cuando viene desde seguimiento de facturas 
	var iFactura, iImporteFactura, iTopeMensual, nImporteOriginal = 0, iGuardaAclaracion=0, nConsulta=0, iTipoDoc = 0;
	var iConsultarFac=0;
	var importesPagadosOriginalesArray = null;
	var Activa = 0;
	var iCicloFactura = 0;
	var iContador = 0;
	var sEscolaridades = 0
		, sEscolaridadesResp = '';

		function sanitize(string) { //función para sanitizar variables
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
		

	var cMoneda ='';
	
	SessionIs();
	$( '#tabs' ).tabs();
	// console.log("ACTIVAR PESTAÑA = "+ $("#hid_estatus").val());

	function fnConsultaPorcentajes(colaborador){
		
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_verifica_porcentaje_especial.php',
			data:{
				'iColaborador': colaborador
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				
				if (Object.keys(dataJson).length > 0){
					$('#btn_Porcentaje').show();
				}
				else{
					$('#btn_Porcentaje').hide();

				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}

	function fnConsultarTipoMoneda(factura){
		var idFactura = factura;
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_tipo_moneda.php',
			data:{
				'iFactura':idFactura
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				cMoneda = dataJson.moneda;
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	validarCierreColegiaturas(function(){
		setTimeout(function(){
			dragablesModal(function(){
				StopBackgroudScroll(function(){
				});
			});
			if($( '#txt_Numemp' ).val().length==8)
			{
				$("#pag_title").html("Aceptar/Rechazar Facturas");
				$("html, body").animate({ scrollTop: 0 }, "fast");
				waitwindow('Por favor espere...', 'open');
				// console.log('consulta datos input');
				ConsultarDatosEmpleados(function(){
						ConsultaEmpleado(function(){
							CargarDatosGenerales(function(){
								iConsultarFac=1;	
								fnConsultarFacturas(0);	
								
							});
						});
					});
				if ( $("#hid_estatus").val() == 1 ) {
					Activa = 0;
				} else if ( $("#hid_estatus").val() == 2 ) {
					Activa = 1;
				} else if ( $("#hid_estatus").val() == 3 ) {
					Activa = 2;
				} else if ( $("#hid_estatus").val() == 4 ) {
					Activa = 3;
				} else if ( $("#hid_estatus").val() == 5 ) {
					Activa = 4;
				}
				
				$( "#tabs" ).tabs({ active: Activa });
			} else {
				$("#div_observaciones").hide();
				$("#btn_regresarSeg").hide();
			}
		}, 500);
	});
	// Llega del Seg. por Personal Admon.
	
	// $( "#txt_Observaciones" ).dblclick(function() {
	  // alert( "Handler for .dblclick() called." );
	// });
	/*** Boton para regresar a la opcion de Seg. Facturas por Personal Admon  */
	$("#btn_regresarSeg").click(function(event) {
		$("#hid_regresa").val(1);
			// $("#btn_regresarSeg").prop('disabled', false);
			var param = {
				IdColaborador : $("#hid_iColaborador").val(),
				dFechaInicial : $("#hid_FechaIni").val(),
				dFechaFinal : 	$("#hid_FechaFin").val(),
				IdEstatus : 	$("#hid_estatus").val(),
				idRegion : 		$("#hid_region").val(),
				idCiudad : 		$("#hid_ciudad").val(),
				idTipoNom : 	$("#hid_tNomina").val(),
				iRegresa :		$("#hid_regresa").val()
			}
			loadContent('ajax/frm/frm_seguimientoFacturasPersonalAdministracion.php', param);
			// activaOpc(findIndex('frm_seguimientoFacturasPersonalAdministracion.php'), 'frm_seguimientoFacturasPersonalAdministracion.php', param)
		event.preventDefault();
	});
	$( '#btn_regresarSeg' ).focusout(function(event){
		$("#txt_Numemp").focus();
		event.preventDefault();
	});
	
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
	
	function CargaEscolaridad(callback) {
		$("#cbo_Escolaridades").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php?",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0) {
					var option = "<option value=0>TODAS</option>";
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + (dataJson.datos[i].idu_escolaridad) + "'>" + (dataJson.datos[i].nom_escolaridad) + "</option>"; 
					}
					
					$("#cbo_Escolaridades").html(option);
					/*
					if (sEscolaridades > 0) {
						$("#cbo_Escolaridades").val(sEscolaridades);
					} else {
						*/
						//$("#cbo_Escolaridades").val($("#cbo_Escolaridades option:first").val());
						$($("#cbo_Escolaridades").children()[0]).prop('selected', 'selected');
					//}
//					$("#cbo_Escolaridades" ).val($("#cbo_Escolaridades option:first").val());
					$("#cbo_Escolaridades").trigger("chosen:updated");
					if (callback != undefined) {
						callback();
					}
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	/*** ------------------------------------------------------------------------- */
	GridAplicarNota();
	$("#btn_Blog").prop("disabled",true);
	$("#btn_Blog_Csc").prop("disabled",true);
		
	sel_importe_nc=0;
	sel_importe_aplicado_nc=0;
	sel_importe_aplicar_nc=0;	
	sel_ImportePagar=0;
	//showalert("valor 3     " + sel_ImportePagar,"","gritter-info");
	sel_factura_nc=0;  //en el grid de nota de credito es el numero de la factura
	sel_importeCal=0;
	sel_opc_modifico_pago=0;
	sel_nota_credito=0; //almacena el valor de la factura de la nota de credito en caso contrario guarda 0	
	FecIni='19000101'; // constantes para el llamado del grid de la nota de credito, en la consulta de nota de credito si se ocupan las fechas 
	FecFin='19000101';	
	
	//BOTON PARA VER PORCENTAJES
	$("#btn_Porcentaje").on("click", function(event){
		
		$('#gd_Porcentajes').jqGrid('clearGridData');
		$('#gd_Porcentajes').jqGrid('setGridParam', {
			url: 'ajax/json/json_fun_verifica_porcentaje_especial.php',
			mtype: 'POST',
			postData: {
				iColaborador: $('#txt_Numemp').val()
			}
		}).trigger('reloadGrid');
		$('#dlg_Porcentajes').modal('toggle');
		$('#dlg_Porcentajes').modal('show');		
	});
	//BOTON PARA VER LA FACTURA
	$("#btn_ver").on("click", function(event){
	
	
			var cnt_ver_factura = $( "#cnt_ver_factura" ).dialog({
			modal: true,
			title: "<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-ok'></i> Factura</h4></div>",
			title_html: true,
			width: 1800,
			height: 900,
			autoOpen: false,
			// show: {
				// effect: "fade",
				// duration: 1500
			// },
			// hide:{
				// effect: "fade",
				// duration: 1500
			// },
			buttons: [
				{
					text: "Cerrar",
					"class" : "btn btn-primary btn-mini",
					click: function(event){
						var tab =$("#tabs").tabs('option', 'active');
						switch(tab) {
							case 0:
								grid="#gd_Proceso";
							break;
							case 1:
								grid="gd_AceptadaPorPagar"
							break;
							case 2:
								grid="#gd_Rechazadas";
							break;
							case 3:
								grid="#gd_Aclaracion";
							break;
							case 4:
								grid="#gd_Revision";
							break;
							case 5:
								grid="#gd_NotaCredito";
							break;
							default:
							break;
						}
						// $(grid).jqGrid('resetSelection');
						
						// $("#gridFacturasExternos-table").jqGrid('resetSelection');
						// iFactura = 0;
						$( this ).dialog( "close" );
						
						event.preventDefault();
					}
				}
			]
		});

		//cnt_ver_factura.dialog("open");
		event.preventDefault();
	});

//	$('#rdb_Rechazado').is(":checked");
	fnConsultarMotivosRevision();
	fnConsultaDeducciones();
	fnConsultarMotivosRechazos();
	fnEstructuraGrid();

	$("#cbo_Rechazo").prop('disabled',true);
	$("#cbo_MotivoRevision").prop('disabled',true);

	$( '#txt_Numemp' ).on('input propertychange', function(event){
		$("#txt_Nombre").val("");
		$("#txt_Centro").val("");
		$("#txt_NombreCentro").val("");
		$("#txt_Puesto").val("");
		$("#txt_NombrePuesto").val("");
		$("#txt_Sueldo").val("");
		$("#txt_TopeAnual").val("");
		$("#txt_TopeMensual").val("");
		$("#txt_TopeAnualRestante").val("");
		$("#txt_AcumuladoFacturaPagada").val("");
		$("#txt_RutaPago").val("");
		$("#txt_Fecha").val("");
		$('#btn_Porcentaje').hide();
		//LimpiarTextos();

		$("#txt_ciclo").val("");
		$("#txt_archivo1").val("");
		$("#txt_archivo2").val("");
		$("#empleado").val("");
		$("#cbo_Deduccion").val(1);
		$("#cbo_Rechazo").val(0);
		$("#cbo_MotivoRevision").val(0);
		iGuardaAclaracion=0;
		
		$("#ckb_Limitado").prop('checked', false);

		$('#gd_Beneficiarios').jqGrid('clearGridData');
		$('#gd_Proceso').jqGrid('clearGridData');
		$('#gd_AceptadaPorPagar').jqGrid('clearGridData');
		$('#gd_Rechazadas').jqGrid('clearGridData');
		$('#gd_Aclaracion').jqGrid('clearGridData');
		$('#gd_PagosMensuales').jqGrid('clearGridData');
		$('#gd_Revision').jqGrid('clearGridData');
		$('#gd_NotaCredito').jqGrid('clearGridData');
		
		if($( '#txt_Numemp' ).val().length==8)
		{
			// console.log('consulta datos input');
			
			ConsultarDatosEmpleados(
				function(){
					ConsultaEmpleado(function(){
						CargarDatosGenerales(function(){
							iConsultarFac=1;
							fnConsultaPorcentajes($( '#txt_Numemp' ).val());	
							fnConsultarFacturas(0);
						});
					});
				});
		}
		// fnConsultarBeneficiarios(1);
		// fnConsultarFacturas(1);
		event.preventDefault(); //se desahibilita opción prevent por petición 39116.1
	});
	/*
	if($("#txt_Numemp").val().length>0)
	{
		ConsultarDatosEmpleados(
			function(){
				ConsultaEmpleado(
				function(){
				iConsultarFac=1;	
				fnConsultarFacturas(0);
			});
		});
	}*/
	function StopBackgroudScroll(callback){
		$("#dlg_PagosMensuales").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_ModificarImportes").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_Blog").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_Blog_Csc").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_Consultar_Costos").on("show.bs.modal", function () {
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
	}
	
	function getSelectedTabIndex(){
		return $("#tabs").tabs('option', 'active');
	}
	
	$(".tabbable").tabs({
		beforeActivate: function (event, ui) {
			//console.log(ui.newPanel.attr('id'));
		}
	});
	$(".ui-tabs-anchor").click(function(event){
		
		//Limpiar();
		iConsultarFac=1;
		fnConsultarFacturas(0);
		$('#gd_Parentescos').jqGrid('clearGridData');
		
		event.preventDefault();
	});
	
	$( '#txt_ImporteNuevo' ).focusin(function(event){
		if (  ($( this ).val()).replace(/^\s+|\s+$/gm,'') != "" ) {
			$( this ).val( accounting.unformat( $( this ).val()) );
		}
		event.preventDefault();
	});
	
	$( '#txt_ImporteNuevo' ).focusout(function(event){
		$( this ).val( accounting.formatMoney( $( this ).val() , "", 2) );
		event.preventDefault();
	});
	$("#rdb_Aceptado").change(function(event){
		if($('#rdb_Rechazado').is(":checked"))
		{
			$("#cbo_Rechazo").prop('disabled',false);
		}
		else
		{
			$("#cbo_Rechazo").val(0);
			$("#cbo_Rechazo").prop('disabled',true);
		}	
		
		if($('#rdb_Revision').is(":checked")){
			$("#cbo_MotivoRevision").prop('disabled', false);
		}else{
			$("#cbo_MotivoRevision").val(0);
			$("#cbo_MotivoRevision").prop('disabled', true);
		}
		if( $("#rdb_Aclaracion").is(":checked") ) {
			$("#txt_Observaciones").prop('disabled', true);
		} else {
			$("#txt_Observaciones").prop('disabled', false);
		}
		event.preventDefault();
	});
	
	$("#rdb_Rechazado").change(function(event){
		if($('#rdb_Rechazado').is(":checked"))
		{
			$("#cbo_Rechazo").prop('disabled',false);
		}
		else
		{
			$("#cbo_Rechazo").val(0);
			$("#cbo_Rechazo").prop('disabled',true);
		}

		if($('#rdb_Revision').is(":checked")){
			$("#cbo_MotivoRevision").prop('disabled', false);
		}else{
			$("#cbo_MotivoRevision").val(0);
			$("#cbo_MotivoRevision").prop('disabled', true);
		}
		if( $("#rdb_Aclaracion").is(":checked") ) {
			$("#txt_Observaciones").prop('disabled', true);
		} else {
			$("#txt_Observaciones").prop('disabled', false);
		}
		event.preventDefault();
	});
	$("#rdb_Aclaracion").change(function(event){
		if($('#rdb_Rechazado').is(":checked"))
		{
			$("#cbo_Rechazo").prop('disabled',false);
			$("#txt_Observaciones").prop('disabled', true);
		}
		else
		{
			$("#cbo_Rechazo").val(0);
			$("#cbo_Rechazo").prop('disabled',true);
			$("#txt_Observaciones").prop('disabled', false);
		}

		if($('#rdb_Revision').is(":checked")){
			$("#cbo_MotivoRevision").prop('disabled', false);
		}else{
			$("#cbo_MotivoRevision").val(0);
			$("#cbo_MotivoRevision").prop('disabled', true);
		}
		if( $("#rdb_Aclaracion").is(":checked") ) {
			$("#txt_Observaciones").prop('disabled', true);
		} else {
			$("#txt_Observaciones").prop('disabled', false);
		}
		event.preventDefault();
	});
	$("#rdb_Revision").change(function(event) {
		if($('#rdb_Rechazado').is(":checked")) {
			$("#cbo_Rechazo").prop('disabled', false);
		} else {
			$("#cbo_Rechazo").val(0);
			$("#cbo_Rechazo").prop('disabled', true);
		}
		
		if($('#rdb_Revision').is(":checked")) {
			$("#cbo_MotivoRevision").prop('disabled', false);
		} else {
			$("#cbo_MotivoRevision").val(0);
			$("#cbo_MotivoRevision").prop('disabled', true);
		}
		if( $("#rdb_Aclaracion").is(":checked") ) {
			$("#txt_Observaciones").prop('disabled', true);
		} else {
			$("#txt_Observaciones").prop('disabled', false);
		}
		event.preventDefault();
	});
	
	//PRESIONAR TECLA NUMERO EMPLEADO
	$("#txt_Numemp").keypress(function(e){
		var keycode = e.which;
		//console.log(keycode);
		if(keycode == 13 || keycode == 9 || keycode == 0)//9
		{
			//console.log($("#txt_iduempleado").val().length);
			if(($("#txt_Numemp").val().length != 8) && ($("#txt_Numemp").val().length != 0))
			{
				LimpiarTextos();
				//showmessage('Empleado no Valido, Favor de Verificar', '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG271, "", "gritter-warning");
				
				
				
			}
			else if($("#txt_Numemp").val().length == 0)
			{
				LimpiarTextos();
				fnConsultarBeneficiarios(1);
				fnConsultarFacturas(1);
			}
			else
			{
				if (keycode!=8 || keycode!=0){
					ConsultarDatosEmpleados(function(){
						//waitwindow('Consultando datos del colaborador', 'open');
						ConsultaEmpleado(function(){
							CargarDatosGenerales(function(){
								fnConsultaPorcentajes($( '#txt_Numemp' ).val());
								fnConsultarFacturas(0);
							});
						});
					});
				}else{
					LimpiarTextos();
				}
			}
		}else if (keycode==8 || keycode==0){
			LimpiarTextos();
		}
	});
	
	//LIMPIAR TEXTOS
	function LimpiarTextos(){
		$("#txt_Numemp").focus();
		$("#txt_Numemp").val("");
		$("#txt_Nombre").val("");
		$("#txt_Centro").val("");
		$("#txt_NombreCentro").val("");
		$("#txt_Puesto").val("");
		$("#txt_NombrePuesto").val("");
		$("#txt_Sueldo").val("");
		$("#txt_TopeAnual").val("");
		$("#txt_TopeMensual").val("");
		$("#txt_AcumuladoFacturaPagada").val("");
		$("#txt_RutaPago").val("");
		$("#txt_Fecha").val("");
		$('#gd_Proceso').jqGrid('clearGridData');
		$('#gd_AceptadaPorPagar').jqGrid('clearGridData');
		$('#gd_Rechazadas').jqGrid('clearGridData');
		$('#gd_Aclaracion').jqGrid('clearGridData');
		$('#gd_Revision').jqGrid('clearGridData');
		$('#gd_NotaCredito').jqGrid('clearGridData');
		$('#btn_Porcentaje').hide();
		
	}
	
	
	//CONSULTAR DATOS DE EMPLEADOS
	function ConsultarDatosEmpleados(callback) {
		// if(isNaN($("#txt_Numemp").val()))
		// {
			// console.log(1);
		// }
		// else
		// {
			// console.log(0);
		// }
		if($("#txt_Numemp").val()!='' && isNaN($("#txt_Numemp").val())==false)
		{
		$.ajax({type: "POST",
			url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
			data: {
				'iEmpleado':$("#txt_Numemp").val(),
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson!=null){
					if(dataJson[0].cancelado==1){
						
							$("#txt_Numemp").focus();
							$("#txt_Numemp").val("");
							$("#txt_Nombre").val("");
							$("#txt_Centro").val("");
							$("#txt_NombreCentro").val("");
							$("#txt_Puesto").val("");
							$("#txt_NombrePuesto").val("");
							$("#txt_Sueldo").val("");
							$("#txt_TopeMensual").val("");
							$("#txt_TopeAnual").val("");
							$("#txt_AcumuladoFacturaPagada").val("");
							$("#txt_TopeAnualRestante").val("");
							$("#txt_RutaPago").val("");
							$("#txt_Fecha").val("");
							$("#ckb_Limitado").prop('checked', false);
						
						//showalert(LengStrMSG.idMSG272, "", "gritter-info");
					}
					else{
						$("#txt_Nombre").val(dataJson[0].nombre+' '+dataJson[0].appat+' '+dataJson[0].apmat);
						$("#txt_Centro").val(dataJson[0].centro);
						$("#txt_NombreCentro").val(dataJson[0].nombrecentro);
						$("#txt_Puesto").val(dataJson[0].puesto);
						$("#txt_NombrePuesto").val(dataJson[0].nombrepuesto);
						$("#txt_Sueldo").val(dataJson[0].sueldo);
						$("#txt_TopeAnual").val(dataJson[0].topeproporcion);
						$("#txt_RutaPago").val(dataJson[0].nombrerutapago);
						$("#txt_Fecha").val(dataJson[0].fec_alta);
						$("#ckb_Limitado").prop('checked', false);
					}
				}
				else{
					//showmessage('No existe el número de empleado', '', undefined, undefined, function onclose(){
						$("#txt_Numemp").focus();
						$("#txt_Numemp").val("");
						$("#txt_Nombre").val("");
						$("#txt_Centro").val("");
						$("#txt_NombreCentro").val("");
						$("#txt_Puesto").val("");
						$("#txt_NombrePuesto").val("");
						$("#txt_Sueldo").val("");
						$("#txt_TopeAnual").val("");
						$("#txt_TopeMensual").val("");
						$("#txt_TopeAnualRestante").val("");
						$("#txt_AcumuladoFacturaPagada").val("");
						$("#txt_RutaPago").val("");
						$("#txt_Fecha").val("");
						$("#ckb_Limitado").prop('checked', false);
					//});
					showalert(LengStrMSG.idMSG273, "", "gritter-info");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
		}
	}
	function CargarDatosGenerales(callback) {
		var iColaborador = $("#txt_Numemp").val().replace(/^\s+|\s+$/gm,'');
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_calcular_topes_colegiaturas.php?",
		data: {
				'iEmpleado' : iColaborador,
				'iSueldo':accounting.unformat($("#txt_Sueldo").val()),
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != 0) {
					if ($("#txt_Numemp").val().replace(/^\s+|\s+$/gm,'') != '' || $("#txt_Numemp").val().replace(/^\s+|\s+$/gm,'') > 0){
						// console.log(dataJson);
						var ImporteFormato="0";
						
						ImporteFormato = accounting.unformat($("#txt_TopeAnual").val()) - accounting.unformat(dataJson.acumulado);
						ImporteFormato = accounting.formatMoney(ImporteFormato, "",2);

						$("#txt_TopeAnualRestante").val(ImporteFormato);
						$("#txt_TopeMensual").val(dataJson.topeMensual);
					} else {
						$("#txt_TopeAnualRestante").val("");
						$("#txt_TopeMensual").val("");
					}
				} else {
					// message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los importes", "", "gritter-error");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
		/*
		.done(function(data) {
			var dataJson = JSON.parse(data);
			if(dataJson != 0) {
				// console.log(dataJson);
				var ImporteFormato="0";

				ImporteFormato = accounting.unformat($("#txt_TopeAnual").val()) - accounting.unformat(dataJson.acumulado);
				ImporteFormato = accounting.formatMoney(ImporteFormato, "",2);

				$("#txt_TopeAnualRestante").val(ImporteFormato);
			} else {
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los importes", "", "gritter-error");
			}
			if (callback != undefined){
				callback();
			}
		});*/
	}
	
	function ConsultaEmpleado(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_consulta_empleado_colegiatura.php?",
			data: {
				'iEmpleado':$("#txt_Numemp").val(),
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != null){
					if(dataJson.LIMITADO==1){
						//Marcar un checkbox
						$("#ckb_Limitado").prop('checked', true);
					}
					else{
						//Desmarcar un checkbox
						$("#ckb_Limitado").prop('checked', false);
					}
					iConsultarFac=0;
					fnConsultarPagosPorMes();
				}
			},	
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	
	
	function SumaImporteConcepto(){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab) {
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			// case 4:
				// grid="#gd_NotaCredito";
			// break;
			default:
			break;
		}
		//console.log('Suma importe Concepto='+ $(grid).find("tr").length);
		iImporteConcepto=0;
		/*for(var i = 0; i < $("#gd_Proceso").find("tr").length - 1; i++){
			importe=0;
			var Jdata = $("#gd_Proceso").jqGrid('getRowData', i );
			importe=Jdata.importeConcepto;
			console.log("importe="+importe);
			//importePagadoTotal += parseFloat(Jdata.imp_importeF);
			iImporteConcepto+= parseFloat(Jdata.importeConcepto);
		}*/
		sel=0;
		for(var i = 0; i < $(grid).find("tr").length - 1; i++) {
			var Jdata = $(grid).jqGrid('getRowData',i);
			if((Jdata.marcado.toUpperCase())=="TRUE")
			{
				//obj = {'factura':Jdata.ifactura};
				//arr_export.push(obj);
				sel+=1;				
				importe=Jdata.importeConcepto;
				importe=importe.replace(",","");
				//console.log('importe='+importe+' sel='+sel);
				iImporteConcepto+=parseFloat(importe);
								
			}			
		}
	}
	/*DIALOGOS
	
/*-----FUNCIONALIDADES DE BOTONES--------------*/
	//GUARDAR
	$("#btn_Guardar").click(function(event){
		
		var iEstatus="";
		iGuardaAclaracion=0;
		SumaImporteConcepto();
		
		//return;
		var selr="", iEstatus=0, grid="", Mensaje="", rowData="";
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');
		if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		{
			//message('No hay información');
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
			return;
		}
		
		// var arr_export = [];
		// var keysx = '';
		// var obj = {};
		var contadorSeleccionados = 0;
		var lista = jQuery(grid).getDataIDs();
		for(i=0;i<lista.length;i++){
			rowData=jQuery(grid).getRowData(lista[i]);
			//showalert((rowData.marcado).toUpperCase(), "", "gritter-info");
			if ((rowData.marcado).toUpperCase() == 'TRUE') {
				contadorSeleccionados += 1;
				iFactura=rowData.ifactura;
			}
		}
		
		if($('#rdb_Aceptado').is(":checked")){
			iEstatus=1;
			if(contadorSeleccionados==0)
			{
				showalert(LengStrMSG.idMSG274, "", "gritter-info");
				return;
			}
		}
		else if($('#rdb_Rechazado').is(":checked")){
			iEstatus=2;
			if(contadorSeleccionados==0)
			{
				showalert(LengStrMSG.idMSG275, "", "gritter-info");
				return;
			}
		}else if($('#rdb_Revision').is(":checked")){
			iEstatus=4
			// console.log(iEstatus);
			if(contadorSeleccionados == 0){
				//showalert(LengStrMSG.idMSG275, "", "gritter-info");
				showalert("Marque al menos una factura para envíar a revisión", "", "gritter-info");
				return;
			}
		}
		else{
			if(contadorSeleccionados==0)
			{
				showalert(LengStrMSG.idMSG276, "", "gritter-info");
				return;
			}
			else if(contadorSeleccionados>1)
			{
				showalert(LengStrMSG.idMSG277, "", "gritter-info");
				//showalert("Hola", "", "gritter-info");
				return;
			}
			iEstatus=3;
			iGuardaAclaracion=1;
		}
		
		if (iEstatus==2){
			if($("#cbo_Rechazo").val()==0){
				//message("Seleccione el motivo de rechazo");
				showalert(LengStrMSG.idMSG278, "", "gritter-info");
				$("#cbo_Rechazo").focus();
				return;
			}
			if($("#txt_Observaciones").val().replace(/^\s+|\s+$/gm,'')==''){
				//message("Proporcione las observaciones por el rechazo");
				showalert(LengStrMSG.idMSG279, "", "gritter-info");
				$("#txt_Observaciones").focus();
				return;
			}
		}
		if (iEstatus==3){//aclaracion
			//iFactura=arr_export[0].factura;
			
			if(iFactura!=0)
			{
				$('#hid_factura').val(iFactura);
				fnConsultaBlog($("#txt_Numemp").val(), iFactura);
				//$('#dlg_Blog').modal('show');
			}
			else
			{
			//	message("Favor de seleccionar la factura que desea ver el blog");
				showalert(LengStrMSG.idMSG280, "", "gritter-info");
			}
		}
		if(iEstatus == 4){//Revision
			if($("#cbo_MotivoRevision").val()==0){
				//message("Seleccione el motivo de rechazo");
				showalert("Seleccione el motivo de revisión", "", "gritter-info");
				$("#cbo_MotivoRevision").focus();
				return;
			}
			if($("#txt_Observaciones").val().replace(/^\s+|\s+$/gm,'') == ''){
				showalert("Proporcione las Observaciones para la Revision","","gritter-info");
				$("#txt_Observaciones").focus();
				return;
			}
			// console.log('iEstatus='+iEstatus);
			// return;
			var contadorEspeciales = 0;
			var lista = jQuery(grid).getDataIDs();
			for(i=0;i<lista.length;i++) {
				rowData=jQuery(grid).getRowData(lista[i]);
				//showalert((rowData.marcado).toUpperCase(), "", "gritter-info");
				if ((rowData.marcado).toUpperCase() == 'TRUE' && rowData.idTipoDocto == 4) {
					contadorEspeciales += 1;
					// console.log('no puedes porque es especial\nCantidad Total de especiales='+contadorEspeciales);
				}
			}
			if (contadorEspeciales > 0){
				showalert("No puedes enviar a revisión facturas de escuelas EXTRANJERAS/EN LINEA", "", "gritter-info");
				return;
			} else {
				fnGuardar();
			}
		}
		else
		{
			if($("#cbo_Deduccion").val()==0){
				showalert(LengStrMSG.idMSG281, "", "gritter-info");
				$("#cbo_Deduccion").focus();
				return;
			}
			else
			{
				if(iTipoDoc == 4 && iEstatus == 4){
					showalert("No puedes enviar a revisión facturas de escuelas EXTRANJERAS/EN LINEA", "", "gritter-info");
					return;
				} else {
					fnGuardar();
				}
				//console.log('Guardo');
			}
		}
		event.preventDefault();
	});

	//BOTON PAGOS
	$('#btn_Pagos').click(function(event){
		if($("#txt_Nombre").val()!='')
		{
			nConsulta=1;
			fnConsultarPagosPorMes();
			//$('#dlg_PagosMensuales').modal('show');
		}
		else
		{
			//message("Favor de proporcione el numero del empleado");
			// showalert(LengStrMSG.idMSG282, "", "gritter-info");
			showalert("Favor de ingresar número de colaborador", "", "gritter-info");
			$("txt_Numemp").focus();
		}		
		event.preventDefault();
	});
	
	//BOTON CONSULTAR COSTOS ESCUELA
	$('#btn_ConsultarCostosEscuela').click(function(event){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{ 
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');
		
		if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		{
			//message('No hay información');
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
			return;
		}
		
		if(iFactura!=0)
		{
			if(iTipoDoc !=4 && iTipoDoc != 2){
				//fnConsultaBlog($("#txt_Numemp").val(), iFactura);	
				// fnCargarCostos();
				// fnCargarDescuentos();
				$('#dlg_Consultar_Costos').modal('show');
			} else {
				showalert("Solo puede consultar costos de ingresos y pagos", "", "gritter-info");
				return;
			}
		}
		else
		{
			//	message("Favor de seleccionar la factura que desea ver el blog");
			// showalert(LengStrMSG.idMSG288, "", "gritter-info");
			showalert("Seleccione la factura de la que desea consultar costos", "", "gritter-info");
		}
		
		event.preventDefault();
	});
	function CargarCiclosEscolares(callback){
		$("#cbo_CicloEscolar").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{						
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_CicloEscolar").html(option);
					
					if (iCicloFactura > 0) {
						$("#cbo_CicloEscolar").val(iCicloFactura);
					} else {
						//$("#cbo_CicloEscolar").val($("#cbo_CicloEscolar option:first").val());
						$($("#cbo_CicloEscolar").children()[0]).prop('selected', 'selected');
					}
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
				}
				callback();
			},
			error:function onError(){
				//message("Error al cargar " + url);
				showalert(LengStrMSG.idMSG88+" los ciclos escoles" , "", "gritter-error");
				$('#cbo_CicloEscolar').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	$("#dlg_Consultar_Costos").on('shown', function(event){
		//console.log("VARIABLE DE LA ESCOLARIDAD DE LA FACTURA = "+sEscolaridades);
		CargarCiclosEscolares(function(){
			CargaEscolaridad(function(){
				fnConsultarEscuela(function(){
					fnCargarCostos(function(){
						fnCargarDescuentos(function(){
							
						});					
					});
				});
			});
		});
	});
	$("#cbo_CicloEscolar").change(function(event) {
		fnCargarCostos(function(){
			fnCargarDescuentos(function(){
				
			});					
		});
		event.preventDefault();
	});
	$("#cbo_Escolaridades").change(function(event) {
		$("#gd_Costos").jqGrid("clearGridData");
		$("#gd_Descuentos").jqGrid("clearGridData");
		
		sEscolaridades = $("#cbo_Escolaridades").val();
		fnCargarCostos(function(){
			fnCargarDescuentos(function(){
				
			});
		});
		event.preventDefault();
	});
	$("#dlg_Consultar_Costos").on('hide.bs.modal', function(event){
		$("#gd_Costos").jqGrid('clearGridData');
		$("#gd_Descuentos").jqGrid('clearGridData');
		$("#txt_cc_escuela").val("");
		$("#txt_cc_estado").val("");
		$("#txt_cc_ciudad").val("");
		$("#txt_cc_rfc").val("");
		$("#txt_cc_razon_social").val("");
		$("#txt_cc_clavesep").val("");
	});
	//BOTON CERRAR CONSULTAR COSTOS
	$('#btn_Cerrar_Consulta_Costos').click(function(event){		
		$('#dlg_Consultar_Costos').modal('hide');
		
		event.preventDefault();
	});
	//----------------------------------------------------------------------------------------------------------------
	function fnConsultarEscuela(callback){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_consultar_escuela.php',
			data:{
				'idFactura' : iFactura,
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson != null){
				$("#txt_cc_escuela").val(dataJson[0].sescuela);
				$("#txt_cc_estado").val(dataJson[0].sestado);
				$("#txt_cc_ciudad").val(dataJson[0].smunicipio);
				$("#txt_cc_rfc").val(dataJson[0].srfc);
				$("#txt_cc_razon_social").val(dataJson[0].srazonsocial);
				$("#txt_cc_clavesep").val(dataJson[0].sclavesep);
				
				callback();
			}
		})
		.fail(function(s) {alert("Error al cargar ajax/'rutaJson'"); $('#pag_content').fadeOut();})
		.always(function() {});
		
	}
	//CARGAR DESCUENTOS	
	function fnCargarDescuentos(callback){
		var OpcCicloD = $("#cbo_CicloEscolar").val();
		var sUrl = 'ajax/json/json_fun_consultar_costos_descuentos_escuela.php?&session_name='+Session;
			sUrl += '&idFactura='+iFactura;
			sUrl += '&iCicloEscolar='+OpcCicloD;
			sUrl += '&sEscolaridades='+sEscolaridades;
			sUrl += '&iOpcion=2';
		$("#gd_Descuentos").GridUnload();
		jQuery("#gd_Descuentos").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			url:sUrl,
			colNames:LengStr.idMSG88,
			colModel:
			[	
				{name:'nom_escuela',		index:'nom_escuela', 		width:300, sortable: false,	align:"left",	fixed: true},
				{name:'ciclo_escolar',		index:'ciclo_escolar', 		width:100, sortable: false,	align:"center",	fixed: true},
				{name:'escolaridad',		index:'escolaridad',		width:150, sortable: false,	align:"left",	fixed: true /*,hidden:true*/},
				{name:'carrera',			index:'carrera', 			width:250, sortable: false,	align:"left",	fixed: true },
				{name:'tpp',				index:'tpp', 				width:200, sortable: false,	align:"left",	fixed: true},
				{name:'descuento',			index:'descuento', 			width:100, sortable: false,	align:"left",	fixed: true},
				{name:'motivo_descuento',	index:'motivo_descuento', 	width:300, sortable: false,	align:"left",	fixed: true},
				{name:'fecha_rev',			index:'fecha_rev', 			width:120, sortable: false, align:"right",	fixed: true},			
			],
			caption:"Descuentos",
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:-1,
			// rowList:[10, 20, 30],
			pager: '#gd_Descuentos_pager',
			//sortname: 'fecestatus',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			pgbuttons: false,
			pgtext: null,
			loadComplete: function (Data) {
				var registrosDesc = jQuery("#gd_Descuentos").jqGrid('getGridParam', 'reccount');
				var registrosCost = jQuery("#gd_Costos").jqGrid('getGridParam', 'reccount');
					if( registrosDesc == 0 && registrosCost == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
						// showalert("No se encontraron descuentos", "", "gritter-info");
					}
				callback();
			},
			// onSelectRow: function(rowid) {				
			// }				
		});
	}
	
	//CARGAR COSTOS	
	function fnCargarCostos(callback){
		var OpcCicloC = $("#cbo_CicloEscolar").val();
		var sUrl = 'ajax/json/json_fun_consultar_costos_descuentos_escuela.php?&session_name='+Session;
			sUrl += '&idFactura='+iFactura;
			sUrl += '&iCicloEscolar='+OpcCicloC;
			sUrl += '&sEscolaridades='+sEscolaridades;
			sUrl += '&iOpcion=1';
			
		// console.log(sUrl);
		// return;
		$("#gd_Costos").GridUnload();
		jQuery("#gd_Costos").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			url:sUrl,
			colNames:LengStr.idMSG89,
			colModel:
			[				
				{name:'nom_escuela',		index:'nom_escuela', 		width:300, sortable: false,	align:"left",	fixed: true},
				{name:'ciclo_escolar',		index:'ciclo_escolar', 		width:100, sortable: false,	align:"center",	fixed: true},
				{name:'escolaridad',		index:'escolaridad', 		width:150, sortable: false,	align:"left",	fixed: true /*,hidden:true*/},
				{name:'carrera',			index:'carrera', 			width:250, sortable: false,	align:"left",	fixed: true },
				{name:'tpp',				index:'tpp', 				width:200, sortable: false,	align:"left",	fixed: true},
				{name:'costo',				index:'costo', 				width:100, sortable: false,	align:"left",	fixed: true},
				{name:'motivo_descuento',	index:'motivo_descuento',	width:100, sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'fecha_rev',			index:'fecha_rev', 			width:120, sortable: false,	align:"right",	fixed: true},			
			],
			caption:"Costos",
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:-1,
			// rowList:[10, 20, 30],
			pager: '#gd_Costos_pager',
			//sortname: 'fecestatus',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			pgbuttons: false,
			pgtext: null,
			loadComplete: function (Data) {
				var registros = jQuery("#gd_Costos").jqGrid('getGridParam', 'reccount');
					// if(registros == 0){
						// showalert(LengStrMSG.idMSG86, "", "gritter-info");
						// showalert("No se encontraron costos", "", "gritter-info");
					// }
				callback();
			},
			// onSelectRow: function(rowid) {				
			// }				
		});
	}
	
	//MODIFICAR IMPORTE
	$('#btn_ModificarImporte').click(function(event){
		
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');
			
		//console.log(selr);
		if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		{
			//message('No hay información');
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
			return;
		}
		// var marcados=fnRegistrosMarcados();
		// console.log(marcados);
		//if(marcados.length==1)
		if(iFactura!=0)
		{
			//iFactura=marcados[0].factura;
			
			urlu = 'ajax/json/json_fun_obtener_beneficiarios_por_factura_modificar_pagos.php?iEmpleado=' + $("#txt_Numemp").val() + '&iFactura=' + iFactura + '&inicializar=' + 0;
			$("#gd_ModificarImporteAPagar").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");
			
			if(iFactura > 0) {
				if (tab==0 && sel_nota_credito>0){
					showalert("No se pueden modificar costos a una factura con nota de crédito ", "", "gritter-info");
					return;
				}
				// nImporteOriginal=$('#txt_ImporteActual').val();
				CargarImportesPagadosOriginales();
				//$('#txt_ImporteActual').val(fila['importeConcepto']);
				//nImporteOriginal=$('#txt_ImporteActual').val();
				$('#dlg_ModificarImportes').modal('show');
				// nImporteOriginal = accounting.unformat($("#txt_ImporteActual").val());
				
					
			}
			else {
				//message('Seleccione la factura que desea modificar el importe a pagar');
				showalert(LengStrMSG.idMSG283, "", "gritter-info");
			}
		}
		else //if(marcados.length==0)
		{
			showalert(LengStrMSG.idMSG283, "", "gritter-info");
		}
		// else
		// {
			// showalert(LengStrMSG.idMSG284, "", "gritter-info");
		// }
		event.preventDefault();	
	});
	
	
	//BOTON GUARDAR IMPORTES
	$('#btn_GuardarImportes').click(function(event){
		var nImporteNuevo = 0;
			
		//if(ValidarImportePagado() == true)
		if (ValidarImporteConcepto() == true)
		{
			//Cargar el importe nuevo en el campo.
			nImporteNuevo = $("#txt_ImporteNuevo").val(ObtenerImportePagadoTotal());
		//}
		//else
		//{
			// return;
		//}
			// console.log('Importes='+$("#txt_ImporteActual").val()+'='+nImporteNuevo+'='+iImporteFactura);
			/*if (nImporteNuevo > iImporteFactura){
				//message('El importe no puede ser mayor que la factura, favor de verificar');
				showalert(LengStrMSG.idMSG285, "", "gritter-info");
				return;
			}
			else */
			
			
			if($("#txt_Justificacion").val()=='')
			{
				//message('Favor de proporcionar una justificación');
				showalert(LengStrMSG.idMSG286, "", "gritter-info");
			}
			else {
				fnGrabaImporte();
			}
		}
			
		event.preventDefault();	
	});
	// $("#dlg_ModificarImportes").on("shown.bs.modal", function(event){
		// nImporteOriginal = accounting.unformat($("#txt_ImporteActual").val());
		// console.log('ImporteOriginal = '+nImporteOriginal);
		// event.preventDefault();
	// });
	//BOTON ANEXOS
	$('#btn_Anexos').click(function(event){
		var grid = '';
		var tab = $("#tabs").tabs('option', 'active');
		switch(tab) {
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			//case 5:
			//	grid="#gd_NotaCredito";
			//break;
			default:
			break;
		}
		if ((jQuery(grid).find("tr").length -1) == 0 ) {
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		} else {
			var selr = jQuery(grid).jqGrid('getGridParam', 'selrow');
			var rowData = jQuery(grid).getRowData(selr);
			
			if (selr) {
				if ( iFactura != '' || iFactura > 0 ) {
					if ((rowData.archivo1 != '') || (rowData.archivo2 != '')) {
						$("#txt_ciclo").val(rowData.idciclo);
						$("#txt_archivo1").val(rowData.archivo1);
						$("#txt_archivo2").val(rowData.archivo2);
						$("#txt_empleado").val($("#txt_Numemp").val());
						
						DescargarAnexos();
					} else {
						showalert(LengStrMSG.idMSG347, "", "gritter-info");
					}
				} else {
					showalert(LengStrMSG.idMSG348, "", "gritter-info");
				}
			} else {
				showalert(LengStrMSG.idMSG348, "", "gritter-info");
			}
		}
		/*
		switch(tab){
			case 0:
				if (($("#gd_Proceso").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				else{
					DescargarAnexos();
				}
			break;
			case 1:
				if (($("#gd_Rechazadas").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				else{
					DescargarAnexos();
				}
			break;
			case 2:
				if (($("#gd_Aclaracion").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				else{
					DescargarAnexos();
				}
			break;
			case 3:
				if (($("#gd_Revision").find("tr").length - 1) == 0 ){
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				else{
					DescargarAnexos();
				}
			break;
			case 4:
				if (($("#gd_NotaCredito").find("tr").length - 1) == 0 ){
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				else{
					DescargarAnexos();
				}
			break;
			default:
			break;
			*/
		event.preventDefault();	
	});
	
	//BOTON VER FACTURA
	$("#btn_verFactura").click(function(event){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab){
			case 0:
				var selr = jQuery('#gd_Proceso').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Proceso').getRowData(selr);
				if (($("#gd_Proceso").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					return;
				}
				else if(iFactura != 0){
					if(rowData.archivo1 == ''){
						showalert("La factura no tiene un XML relacionado", "", "gritter-info");
						return;
					}else{
						VerFactura();
					}
					
				}else{
					showalert("Seleccione un registro", "", "gritter-info");
					return;
				}
			break;
			case 1:
				var selr = jQuery('#gd_AceptadaPorPagar').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_AceptadaPorPagar').getRowData(selr);
				if (($("#gd_AceptadaPorPagar").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					return;
				}else if(iFactura != 0){
					if(rowData.archivo1 == ''){
						showalert("La factura no tiene un XML relacionado", "", "gritter-info");
						return;
					}else{
						VerFactura();
					}
				}else{
					showalert("Seleccione un registro", "", "gritter-info");
					return;
				}
			break;
			case 2:
				var selr = jQuery('#gd_Rechazadas').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Rechazadas').getRowData(selr);
				if (($("#gd_Rechazadas").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					return;
				}else if(iFactura != 0){
					if(rowData.archivo1 == ''){
						showalert("La factura no tiene un XML relacionado", "", "gritter-info");
						return;
					}else{
						VerFactura();
					}
				}else{
					showalert("Seleccione un registro", "", "gritter-info");
					return;
				}
			break;
			case 3:
				var selr = jQuery('#gd_Aclaracion').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Aclaracion').getRowData(selr);
				if (($("#gd_Aclaracion").find("tr").length - 1) == 0 ) {
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					return;
				}else if(iFactura != 0){
					if(rowData.archivo1 == ''){
						showalert("La factura no tiene un XML relacionado", "", "gritter-info");
						return;
					}else{
						VerFactura();
					}
				}else{
					showalert("Seleccione un registro", "", "gritter-info");
					return;
				}
			break;
			case 4:
				var selr = jQuery('#gd_Revision').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Revision').getRowData(selr);
				if (($("#gd_Revision").find("tr").length - 1) == 0 ){
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					return;
				}else if(iFactura != 0){
					if(rowData.archivo1 == ''){
						showalert("La factura no tiene un XML relacionado", "", "gritter-info");
						return;
					}else{
						VerFactura();
					}
				}else{
					showalert("Seleccione un registro", "", "gritter-info");
					return;
				}
			break
			case 5:
				var selr = jQuery('#gd_NotaCredito').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_NotaCredito').getRowData(selr);
				if (($("#gd_NotaCredito").find("tr").length - 1) == 0 ){
					//message('No hay información');
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					return;
				}else if(iFactura != 0){
					if(rowData.archivo1 == ''){
						showalert("La factura no tiene un XML relacionado", "", "gritter-info");
						return;
					}else{
						VerFactura();
					}
				}else{
					showalert("Seleccione un registro", "", "gritter-info");
					return;
				}
			break;
			default:
			break;
		}
		event.preventDefault();	
	});
	
	//--BOTON NOTA DE CREDITO
	$("#btn_notacredito").click(function(event){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{ 
			case 0:
				grid="#gd_Proceso";
			break;
			case1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');	
		//console.log('grid='+grid);	
		if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		{
			//message('No hay información');
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
			return;
		}
		
		if (sel_opc_modifico_pago==1) {			
			showalert("No se permite aplicar nota de crédito a una factura que se le han modificado los costos ", "", "gritter-info");
			return;
		}
		
		if(iFactura != 0){			
			if (sel_nota_credito==0){
				//cnt_notacredito.dialog("open");
				$("#txt_importe_nc").val('');
				$("#cnt_notacredito" ).dialog("open");
				$("#btn_notacredito").prop('disabled', true);
			}else{
				$("#btn_notacredito").prop('disabled', true);
				bootbox.confirm('¿Desea quitar la nota de crédito aplicada a esta factura?','No', 'Si', 
				function(result){
					$("#btn_notacredito").prop('disabled', false);
					if (result){
						DesaplicarNotaCredito();
					}
				});
			}					
		}else{
			showalert("Seleccione un registro", "", "gritter-info");
			return;
		}
		//console.log(empleado);		
		event.preventDefault();	
	});
	
	//--IMPORTE NOTA DE CREDITO
	$("#txt_importe_nc").focusin(function(event){
		if (  ($( this ).val()).replace(/^\s+|\s+$/gm,'') != "" ) {
			if(($( this ).val()).replace(/^\s+|\s+$/gm,'') ==0)
			{
				$( this ).val( "");
			}
			else{
				$( this ).val( accounting.unformat( $( this ).val()) );
			}	
		}
		event.preventDefault()
	});
	
	$( '#txt_importe_nc' ).focusout(function(event){
		$( this ).val( accounting.formatMoney( $( this ).val() , "", 2) );
		event.preventDefault();
	});
	
	//--CONTENEDOR NOTA DE CREDITO 
	//var cnt_notacredito = 
	$("#cnt_notacredito" ).dialog({
		modal: true,
		title: "<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-note'></i> Aplicar descuento de nota de crédito</h4></div>",
		title_html: true,
		width: 1250,
		height: 600,
		autoOpen: false,
		open: function(){
		//	console.log("al abrir");
			ActualizarGridAplicarNota();
		},
		close: function(){
		//	console.log("al cerrar");
			$("#btn_notacredito").prop('disabled', false);
		},		
		buttons: [
			{
				text: "Aplicar",
				"class" : "btn btn-primary btn-mini",
				click: function(event){
					$("#gd_NotaCreditoAplicar").focus();
					//$("#gridFacturasExternos-table").jqGrid('resetSelection');
					//iFactura = 0;
					AplicarNota();
					$("#btn_notacredito").prop('disabled', false);
					$("#txt_importe_nc").val('');
					$( this).focusout();
					
					event.preventDefault();
				} 
			},
			{
				text: "Cerrar",
				"class" : "btn btn-primary btn-mini",
				click: function(event){
					//$("#gridFacturasExternos-table").jqGrid('resetSelection');
					//iFactura = 0;
					$( this ).dialog( "close" );
					$("#btn_notacredito").prop('disabled', false);
					
					event.preventDefault();
				} 
			}
		]				
	});	
	
	//GRID DE NOTA DE CREDITO QUE SE ENCUENTRA EN EL DIALOG DE NOTA DE CREDITO
	function GridAplicarNota(){
		//FACTURAS NOTAS DE CREDITO
		var empleado= $("#txt_Numemp").val();
		$("#gd_NotaCreditoAplicar").GridUnload();
		
		jQuery("#gd_NotaCreditoAplicar").jqGrid({
			datatype:'json',
			mtype:'GET',
			url: 'ajax/json/json_fun_obtener_nota_credito_empleado.php?iEmpleado='+empleado,
			colNames: LengStr.idMSG118,
			colModel:			
			[				
				{name:'numemp',				index:'numemp', 			width:300, sortable: false,	align:"center",	fixed: true,	hidden:true},
				{name:'empleado',			index:'empleado', 			width:300, sortable: false,	align:"center",	fixed: true,	hidden:true},
				{name:'folio',				index:'folio', 				width:300, sortable: false,	align:"center",	fixed: true},
				{name:'importe',			index:'importe', 			width:150, sortable: false,	align:"right",	fixed: true 	/*,hidden:true*/},
				{name:'importe_aplicado',	index:'importe_aplicado', 	width:150, sortable: false,	align:"right",	fixed: true },
				{name:'importe_aplicar',	index:'importe_aplicar', 	width:150, sortable: false,	align:"right",	fixed: true},
				{name:'folio_relacionado',	index:'folio_relacionado', 	width:300, sortable: false,	align:"left",	fixed: true},
				{name:'factura',			index:'factura', 			width:100, sortable: false,	align:"left",	fixed: true,		hidden:true},
			],
			scrollrows: true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,
			rowNum: 10,
			rowList: [10, 20, 30],
			pager: '#gd_NotaCreditoAplicar_pager',
			sortname:'folio',
			viewrecords: true,
			hidegrid: false,
			sortorder: "asc",
			//pgtext: null,
			loadComplete: function (Data) {
				var registros = jQuery("#gd_NotaCreditoAplicar").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				
				/*var table = this;
				setTimeout(function(){
				updatePagerIcons(table);
				}, 0);
				*/
				/*$('#gd_NotaCreditoAplicar :checkbox').change(function(e){
				SeleccionarDeducible();
				});*/
			},
			onSelectRow: function(id){
				var selr = jQuery('#gd_NotaCreditoAplicar').jqGrid('getGridParam','selrow');
				if(selr )
				{				
					var rowData = jQuery("#gd_NotaCreditoAplicar").getRowData(selr);					
					sel_importe_nc=rowData.importe;
					sel_importe_aplicado_nc=rowData.importe_aplicado;
					sel_importe_aplicar_nc=rowData.importe_aplicar;
					sel_factura_nc=rowData.factura;
				}
			}
		});		
	}
	
	//--ACTUALIZAR GRID 
	function ActualizarGridAplicarNota(){
		empleado=$("#txt_Numemp").val();
		$("#gd_NotaCreditoAplicar").jqGrid('clearGridData');
		$("#gd_NotaCreditoAplicar").jqGrid('setGridParam', {url:'ajax/json/json_fun_obtener_nota_credito_empleado.php?iEmpleado='+empleado}).trigger("reloadGrid");
	}
	
	//--APLICAR NOTA
	function AplicarNota(){
		importeaplicar=0;
		importepagar=0;
		
		imp=$("#txt_importe_nc").val();
		imp=imp.replace(".","");
		imp=imp.replace(",","");
		imp=imp/100;
		
		importeaplicar=String(sel_importe_aplicar_nc);
		importeaplicar=importeaplicar.replace(".","");
		importeaplicar=importeaplicar.replace(",","");
		importeaplicar=parseInt(importeaplicar);
		importeaplicar=importeaplicar/100;
		
		importepagar=String(sel_ImportePagar);
		importepagar=importepagar.replace(".","");
		importepagar=importepagar.replace(",","");
		importepagar=parseInt(importepagar);
		importepagar=importepagar/100;
		//console.log('importe='+imp);
		//return;
		if (sel_factura_nc==0){
			showalert("Favor de seleccionar nota de crédito", "", "gritter-info");			
			return;
		}
		
		if (imp==0){
			showalert("Favor de capturar importe válido", "", "gritter-info");
			return;
		}
	//	showalert("mensajeeeeeee" + imp+'  =   '+sel_ImportePagar,"","gritter-info");
		//console.log(imp+'='+sel_importe_aplicar_nc);
		if (imp>importeaplicar){
			showalert("El importe no debe exceder de "+sel_importe_aplicar_nc, "", "gritter-info");
			return;
		}
		

		if (imp>importepagar){
			showalert("El importe para esta factura no debe ser  mayor a "+sel_ImportePagar, "", "gritter-info");
			return;
		}
		
		GrabarAplicarNota();
	}
	
	/*
	function formatearImporte(x){
		x=String(x);
		x=x.replace(".","");
		x=x.replace(",","");
		x=parseInt(x);
		x=x/100;
		return x;
	}*/
	
	//--DESAPLICAR NOTA DE CREDITO
	function DesaplicarNotaCredito(){
		$.ajax({
			type: "POST", 			
			url: "ajax/json/json_fun_desaplicar_nota_credito_empleado.php",
			data: { 
					'iNotaCredito': sel_nota_credito,
					'iFactura': 	iFactura					
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson.estado==0){
					showalert(dataJson.mensaje, "", "gritter-info");					
				}
				fnConsultarFacturas(0);
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}		
		});		
	}
		
	//GRABAR APLICAR NOTA
	function GrabarAplicarNota(){
		iImporteFactura=iImporteFactura.toString();
		iImporteFactura.replace(',','');
		
		sel_importeCal=sel_importeCal.toString();
		sel_importeCal=sel_importeCal.replace(',','');
		sel_importeCal=sel_importeCal.replace('<font color="#FF0000" size="4"><b>','');
											 //<font color="#FF0000" size="4"><b>
		sel_importeCal=sel_importeCal.replace('<font size="4" color="#FF0000"><b>','');
		//<font color="#FF0000" size="4"><b>
		sel_importeCal=sel_importeCal.replace('<font color="#FF0000" size="4"><b>','');									   
		sel_importeCal=sel_importeCal.replace('</b></font>','');
		
		importe_nc=$("#txt_importe_nc").val();
		importe_nc=importe_nc.replace(',','');
		
		sel_importe_aplicado_nc=sel_importe_aplicado_nc.toString();
		sel_importe_aplicado_nc=sel_importe_aplicado_nc.replace(',','');
		
		sel_importe_nc=sel_importe_nc.toString();
		sel_importe_nc=sel_importe_nc.replace(',','');
		//console.log('Grabar Aplicar Nota');
		// return;
		$.ajax({
			type: "POST", 			
			url: "ajax/json/json_fun_grabar_aplicar_nota_credito.php",
			data: { 
					'iNotaCredito': 		sel_factura_nc,
					'iFactura': 			iFactura,
					'iImporteNota':			sel_importe_nc, 
					'iImporteFactura': 		iImporteFactura,
					'iPrcDescuento':		0,
					'iImporteCalculado':	sel_importeCal,
					'iImporteAplicado': 	importe_nc,  //sel_importe_aplicado_nc, 
					'iImportePagado': 		sel_importe_aplicado_nc 
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson.estado==0){
					showalert(dataJson.mensaje, "", "gritter-info");
					ActualizarGridAplicarNota();
					fnConsultarFacturas(0);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}		
		});		
	}
	
	function VerFactura(){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab){
			case 0:
				var selr = jQuery('#gd_Proceso').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Proceso').getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.ifactura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			break;
			case 1:
				var selr = jQuery('#gd_AceptadaPorPagar').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_AceptadaPorPagar').getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.ifactura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			break;
			case 2:
				var selr = jQuery('#gd_Rechazadas').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Rechazadas').getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.ifactura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			break;
			case 3:
				var selr = jQuery('#gd_Aclaracion').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Aclaracion').getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.ifactura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			break;
			case 4:
				var selr = jQuery('#gd_Revision').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_Revision').getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.ifactura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			break;
			case 5:
				var selr = jQuery('#gd_NotaCredito').jqGrid('getGridParam','selrow');
				var rowData = jQuery('#gd_NotaCredito').getRowData(selr);
				$("#nIsFactura").val(0);
				// $("#sFacFiscal").val(rowData.factura);
				$("#idfactura").val(rowData.factura);
				$("#sFilename").val('');
				$("#sFiliePath").val('');
				cargarFactura();
			break;
			default:
			break;
		}
	}
	function cargarFactura(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_leerfactura.php',
			data:{
				session_name : Session
				, 'nIsFactura' : $("#nIsFactura").val()
				// , 'sFacFiscal' : $("#sFacFiscal").val()
				, 'idFactura' : $("#idfactura").val()
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
	//GRABAR IMPORTE
	function fnGrabaImporte(){
		// console.log("Importe Original= "+nImporteOriginal);
		 // return;
		$.ajax({
			type: "POST",
			url: "ajax/json/json_fun_grabar_importe_pagado.php",
			data: {
				'session_name': Session,
				'iFactura': iFactura,
				'nImporteOriginal' : accounting.unformat(nImporteOriginal),
				"importes_actualizados" : ObtenerDatosGridPagos(),
				'nImporteNuevo': accounting.unformat($('#txt_ImporteNuevo').val()),
				'sJustificacion': $("#txt_Justificacion").val().toUpperCase()
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson.estado == 0) {
					showalert(dataJson.mensaje, "", "gritter-info");
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose() {
						fnConsultarFacturas(0);
						$('#dlg_ModificarImportes').modal('hide');
						$("#txt_Justificacion").val('');
					//});
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(dataJson.mensaje, "", "gritter-info");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}			
		});		
	}
	//Al Cerrar el dialogo
	$('#dlg_ModificarImportes').on('hide.bs.modal', function (event) {
		
		$("#txt_Justificacion").val('');
		//event.preventDefault();	
	});
	
	//BOTON ENVIAR COMENTARIO
	$("#btn_EnviarComentario").click(function(event){
		if( ( $("#txt_mensaje").val() ).replace(/^\s+|\s+$/gm,'') == "")
		{
			showalert(LengStrMSG.idMSG287, "", "gritter-info");
			$("#txt_mensaje").val("");
			$("#txt_mensaje").focus();
		}
		else
		{
			fnEnviarComentario();
			if($('#rdb_Aclaracion').is(":checked")){
				if(iGuardaAclaracion==1)
				{
					fnGuardar();
					//console.log('Guardar');
				}	
			}			
		}
		event.preventDefault();	
	});	
	
	//BOTON BLOG
	$("#btn_Blog").click(function(event){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{ 
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid='#gd_AceptadaPorPagar';
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');
		//console.log(selr);
		if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		{
			//message('No hay información');
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
			return;
		}
		//var marcados=fnRegistrosMarcados();
		// if(iFactura!=0)
		// {
			//iFactura=marcados[0].factura;
			if(iFactura!=0)
			{
				fnConsultaBlog($("#txt_Numemp").val(), iFactura);
				$('#dlg_Blog').modal('show');
			}
			else
			{
			//	message("Favor de seleccionar la factura que desea ver el blog");
				showalert(LengStrMSG.idMSG288, "", "gritter-info");
			}
		// }
		// else if(marcados.length>1)
		// {
				// showalert(LengStrMSG.idMSG289, "", "gritter-info");
		// }
		// else
		// {
			// showalert(LengStrMSG.idMSG290, "", "gritter-info");
		// }
		event.preventDefault();
	});
	
	
//--BOTON BLOG SERVICIOS COMPARTIDOS
	//BOTON BLOG
	$("#btn_Blog_Csc").click(function(event){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{ 
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid='#gd_AceptadaPorPagar';
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');	
		//console.log('grid='+grid);	
		if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		{
			//message('No hay información');
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
			return;
		}
		//console.log('iFactura='+iFactura);
		if(iFactura!=0)
		{
			if(iTipoDoc != 4 && iTipoDoc != 2){
				fnConsultaBlogRevision($("#txt_Numemp").val(), iFactura);	//utils.js
				fnActualizarBlog_csc(iFactura);
				// $('#hid_factura_csc').val(iFactura);
				// $('#hid_empleado_csc').val($("#txt_Numemp").val());			
				$('#dlg_Blog_Csc').modal('show');
			} else {
				showalert("No se puede enviar blog de escuelas EXTRANJERAS/EN LINEA", "", "gritter-info");
				return;
			}
		}
		else
		{
		//	message("Favor de seleccionar la factura que desea ver el blog");
			showalert(LengStrMSG.idMSG288, "", "gritter-info");
		}
		
		event.preventDefault();
	});
	/*
	$('#btn_Beneficiarios').click(function(){
		$("#dlg_Beneficiarios").dialog('open');
	});
	$('#btn_RegresarP').click(function(){
		$("#dlg_PagosMensuales").dialog('close');
	});
	$('#btn_RegresarB').click(function(){
		$("#dlg_Beneficiarios").dialog('close');
	});*/

//--BLOG SERVICIOS COMPARTIDOS
	//BOTON ENVIAR  COMENTARIO CSC
	$("#btn_EnviarComentario_csc").click(function(event){
		if($("#txt_mensaje_csc").val().replace(/^\s+|\s+$/gm,'')=="")
		{
			showalert(LengStrMSG.idMSG251, "", "gritter-info");
			$("#txt_mensaje_csc").val("");
			$("#txt_mensaje_csc").focus();
		}
		else
		{
			fnEnviarComentario_csc();
		}
		event.preventDefault();	
	});		
	
	//ENVIAR COMENTARIO CSC
	function fnEnviarComentario_csc()
	{
		var Comentario=$("#txt_mensaje_csc").val().toUpperCase().replace(/^\s+|\s+$/gm,'');
		var opciones= {
			beforeSubmit: function(){
			}, 
			uploadProgress: function(){
			},
			success: function(data) 
			{
				var dataJson = JSON.parse(data);
				if (dataJson.estado !=1) {
					showalert(LengStrMSG.idMSG252, "","gritter-warning");
				} else {
					showalert(LengStrMSG.idMSG253, "","gritter-success");
				}
				$('#dlg_Blog_Csc').modal('hide');
				$("#txt_mensaje_csc").val("");
			}
		};
		$( '#session_name1_csc' ).val(Session);	
		$( '#hid_factura_csc' ).val(iFactura);		
		$("#txt_mensaje_csc").val(Comentario);		
		
		$( '#fmComentario_csc' ).ajaxForm(opciones) ;
		$( '#fmComentario_csc' ).submit();
	}
	
	//ACTUALIZAR BLOG
	function fnActualizarBlog_csc(iFactura)
	{
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_marcar_blog_revision.php?",
		data: { 
				'Factura':iFactura,
				'session_name': Session
			}
		})
		.done(function(data){				
			//fnObtenerNotificaciones();
		});	
	}
//--	
	function ObtenerDatosGridPagos() {
		var arr_export = [];
		for(var i = 0; i < $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++){
			var Jdata = $("#gd_ModificarImporteAPagar").jqGrid('getRowData', i + 1);
			var obj = {
				'idfactura' : Jdata.idfactura,
				'keyx' : Jdata.keyx,
				'imp_importe' : Jdata.imp_importe,//console.log(accounting.unformat($('#txt_ImporteNuevo').val()));
				'descuento' : Jdata.descuento.replace('%', ''),
				'imp_importe_pagado' : Jdata.imp_importeF //Jdata.imp_importe_pagado
			};
			arr_export.push(obj);
		}
		var dataJson = JSON.stringify(arr_export);
		return dataJson;
	}
	
	//CARGAR IMPORTES PAGADOS
	
	function CargarImportesPagadosOriginales(){
		importesPagadosOriginalesArray = [];		
		
		for(var i = 0; i <= $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++) {
			
			var Jdata = $("#gd_ModificarImporteAPagar").jqGrid('getRowData', i + 1);
			//importesPagadosOriginalesArray.push(Jdata.imp_importe_pagado);
			//console.log('originales Cargar='+Jdata.nom_escolaridad);
			//console.log('originales Cargar='+Jdata.imp_importeF)
			
			importesPagadosOriginalesArray.push(Jdata.imp_importeF);
		}
		// nImporteOriginal = $("#txt_ImporteActual").val();
		//$('#dlg_ModificarImportes').modal('show');
	}
	
	// Valida los campos de importe pagado.
	/*
	function ValidarImportePagado(){
		var existeModificacion = false;
		var arr_export = [];
		
		for(var i = 0; i < $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++){
			var Jdata = $("#gd_ModificarImporteAPagar").jqGrid('getRowData', i + 1);
			
			// Validar que los importes pagados no estén vacios;
			if(Jdata.imp_importe_pagado == ""){
				// message("Verifique el valor de los importes pagados.");
				showalert(LengStrMSG.idMSG291, "", "gritter-info");
				return false;
			}
			
			// Validar que los importes pagados no exedan el descuento calculado --> ("descuento" * "importe_concepto").
			var descuento = Jdata.descuento.replace('%','');
			var MaximoPermitido = Jdata.imp_importe * (descuento / 100.00);
			
			
			// if(Jdata.imp_importe_pagado > MaximoPermitido){
				// var msj=LengStrMSG.idMSG292 + MaximoPermitido;
				// showalert(msj, "", "gritter-info");
				// return false;
			// }
			
			// Verificar si se han modificado algún Importe.
			console.log('Cambios='+Jdata.imp_importeF+'='+importesPagadosOriginalesArray[i]);
			// if(!(Jdata.imp_importe_pagado == importesPagadosOriginalesArray[i])){
			if(!(Jdata.imp_importeF == importesPagadosOriginalesArray[i])){
				existeModificacion = true;
			}
		}
		
		if(existeModificacion == false){
			// message("No se han efectuado cambios para guardar.");
			showalert(LengStrMSG.idMSG293, "", "gritter-info");
			return false;
		}
		
		// Se han pasado todas las validaciones correctamente. Se permite guardar.
		return true;
	}
	*/
	
	function ValidarImporteConcepto(){
		var existeModificacion = false;
		var cnt_diferentes = 0;
		var realizoMovto = 0;
		var arr_export = [];
		var acumuladoDetalles = 0;
		
		for(var i = 0; i < $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++){
			var Jdata = $("#gd_ModificarImporteAPagar").jqGrid('getRowData', i + 1);
			
			//Validar que los importes pagados no estén vacios;
			if(Jdata.imp_importe_pagado == ""){
				//message("Verifique el valor de los importes pagados.");
				showalert(LengStrMSG.idMSG291, "", "gritter-info");
				return false;
			}
			
			//Validar que los importes pagados no exedan el descuento calculado --> ("descuento" * "importe_concepto").
			var descuento = Jdata.descuento.replace('%','');
			var MaximoPermitido = Jdata.imp_importe; //* (descuento / 100.00);			
			//console.log('importeF='+Jdata.imp_importeF+'='+MaximoPermitido);
			//accounting.unformat($('#txt_ImporteNuevo').val())
			if(accounting.unformat(Jdata.imp_importeF) > MaximoPermitido & cMoneda == "MXN") {
			//	console.log('msg292');
				var msj=LengStrMSG.idMSG292 + MaximoPermitido;
				showalert(msj, "", "gritter-info");
				return false;
			}
			
			importeActual=$("#txt_ImporteActual").val();
			if(parseInt(importeActual)> parseInt(MaximoPermitido)){
				//console.log('importe actual='+$("#txt_ImporteActual").val()+' Maximo='+MaximoPermitido);
				var msj=LengStrMSG.idMSG292 + MaximoPermitido;
				showalert(msj, "", "gritter-info");
				return false;				
			}
			//console.log('input='+$("input[name='imp_importeF']").val());
			if(Jdata.imp_importeF == ''){	
			//	console.log('importeF es vacío');
				
				if ($("input[name='imp_importeF']").val()==''){
					showalert('Favor de agregar importe', "", "gritter-info");
					return false;
				}else{
					//Jdata.imp_importeF=$("input[name='imp_importeF']").val();
					showalert('Favor de dar enter para confirmar importe', "", "gritter-info");
					return false;
					//console.log ('Jdata='+Jdata.imp_importeF);
				}
			}else{
				//console.log('No es vacío');
				realizoMovto++;
			}
			
			//Verificar si se han modificado algún Importe.
			//console.log('Cambios actual vs original='+Jdata.imp_importeF+'='+importesPagadosOriginalesArray[i]);
			//if(!(Jdata.imp_importe_pagado == importesPagadosOriginalesArray[i])){
			// if(!(Jdata.imp_importeF == importesPagadosOriginalesArray[i])){
				// existeModificacion = true;
			// }
			if ( (Jdata.imp_importeF != Jdata.imp_importe) || (Jdata.imp_importeF == Jdata.imp_importe) ) {
				cnt_diferentes++;
			}
		}
		acumuladoDetalles = $("#gd_ModificarImporteAPagar").jqGrid('getCol', 'imp_importeF', false, 'sum');
		acumuladoDetalles = accounting.unformat(acumuladoDetalles);
		
		if ( (acumuladoDetalles > iImporteFactura) & cMoneda == 'MXN' ) {
			showalert("El importe de los conceptos no debe superar el importe de la factura", "", "gritter-info");
			
			return false;
		} else {
			if ( realizoMovto > 0 ) {
				if ( cnt_diferentes > 0 ) {
					existeModificacion = true;
				}
			} else {
				if ( Jdata.imp_importeF == Jdata.imp_importe ) {
					existeModificacion = true;
				}
			}
		}
		if(existeModificacion == false){
			//message("No se han efectuado cambios para guardar.");
			showalert(LengStrMSG.idMSG293, "", "gritter-info");
			return false;
		}
		
		// Se han pasado todas las validaciones correctamente. Se permite guardar.
		return true;
	}
	
	function ObtenerImportePagadoTotal(){
		var importePagadoTotal = 0.00;
		for(var i = 0; i < $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++)
		{
			var Jdata = $("#gd_ModificarImporteAPagar").jqGrid('getRowData', i + 1);
			//importePagadoTotal += parseFloat(Jdata.imp_importe_pagado);
			importePagadoTotal += parseFloat(Jdata.imp_importeF);
		}
		return importePagadoTotal;
	}
	
	function fnEstructuraGrid(){
		/*FACTURAS EN PROCESO*/
		//var url='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?empleado=0&tipo=0&session_name='+Session;
		jQuery("#gd_Proceso").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			//url:url,
			colNames:LengStr.idMSG28,
			colModel:
			[
				{name:'marcado',index:'marcado',
						width:50, align: 'center', sortable:false,
						edittype:'checkbox', editable:true, editoptions: { value:"True:False"}, 
						formatter: "checkbox", formatoptions: {disabled : false} },
				{name:'fecha_asiganacion',		index:'fecha_asiganacion', 		width:50, 	sortable: false,	align:"center",	fixed: true,	hidden:true},			
				{name:'fecha_conclusion',		index:'fecha_conclusion', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},			
				{name:'estatus_revision',		index:'estatus_revision', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nom_estatus_revision',	index:'nom_estatus_revision', 	width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'otpp',					index:'otpp', 					width:50, 	sortable: false,	align:"center",	fixed: true},
				{name:'idBeneficiario',			index:'idBeneficiario', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreBecado',			index:'nombreBecado', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'factura',				index:'factura', 				width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaFactura',			index:'fechaFactura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaCaptura',			index:'fechaCaptura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'importeRealFact',		index:'importeRealFact',		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeConcepto',		index:'importeConcepto',		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'topeFactura',			index:'topeFactura', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeCal',				index:'importeCal', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importePagar',			index:'importePagar', 			width:90, 	sortable: false,	align:"right",	fixed: true/*,	hidden:true*/},
				{name:'rfc',					index:'rfc', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idEscuela',				index:'idEscuela', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreEscuela',			index:'nombreEscuela', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'idciclo',				index:'idciclo', 				width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ciclo',					index:'ciclo', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idTipoEscuela',			index:'idTipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipoEscuela',			index:'tipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ifactura',				index:'ifactura', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'empleado',				index:'empleado', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'comentario',				index:'comentario', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'aclaracion',				index:'aclaracion', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'observaciones',			index:'observaciones', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo1',				index:'archivo1', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo2',				index:'archivo2', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'deduccion',				index:'deduccion', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'idTipoDocto',			index:'idTipoDocto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipo_docto',				index:'tipo_docto', 			width:120, 	sortable: false,	align:"left",	fixed: true		/*,hidden:true*/},
				{name:'opc_blog',				index:'opc_blog', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog',					index:'blog', 					width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'opc_blog_colaborador',	index:'opc_blog_colaborador', 	width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog_colaborador',		index:'blog_colaborador', 		width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'id_nota',				index:'id_nota',				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'folio_nota',				index:'folio_nota', 			width:270, 	sortable: false,	align:"left",	fixed: true/*, 	hidden:true*/},
				{name:'importe_aplicado',		index:'importe_aplicado', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	/*hidden:true*/},
				{name:'idmotivorevision',		index:'idmotivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'motivorevision',			index:'motivorevision', 		width:250, 	sortable: false,	align:"left",	fixed: true 	/*,hidden:true*/},
				{name:'opc_modifico_pago',		index:'opc_modifico_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'des_metodo_pago',		index:'des_metodo_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'fol_relacionado',		index:'fol_relacionado', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'iCiclo',					index:'iCiclo', 				width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true}
				
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_Proceso_pager',
			sortname: 'fecestatus',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gd_Proceso").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
				}
				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				
				$('#gd_Proceso :checkbox').change(function(e){
					SeleccionarDeducible();
				});
			},
			onSelectRow: function(rowid) {
				if(rowid >= 0){
					var fila = jQuery("#gd_Proceso").getRowData(rowid); 
					iFactura=fila['ifactura'];
					iTipoDoc = fila['idTipoDocto'];
					iImporteFactura=accounting.unformat(fila['importeRealFact']);
					sel_importeCal=fila['importeCal'];
					sel_ImportePagar=fila['importePagar'];
					//showalert("valor 1     " + sel_ImportePagar,"","gritter-info");
					$("#txt_AclaracionCostos").val(fila['aclaracion']);
					//$('#txt_ImporteActual').val(fila['importePagar']);
					$('#txt_ImporteActual').val(fila['importeConcepto']);
					nImporteOriginal = fila['importeConcepto'];
					$("#txt_ciclo").val(fila['idciclo']);
					iCicloFactura = fila['iCiclo'];
					$("#txt_archivo1").val(fila['archivo1']);
					$("#txt_archivo2").val(fila['archivo2']);
					$("#txt_empleado").val($("#txt_Numemp").val());
					fnConsultarBeneficiarios(0);
					fnConsultarTipoMoneda(iFactura);
					
					sel_nota_credito=fila['id_nota'];
					sel_opc_modifico_pago=fila['opc_modifico_pago'];
					Aplicar_Desaplicar_Nota();
					
				} else {
					iFactura=0;
					iTipoDoc=0;
					sel_ImportePagar=0;
					//showalert("valor 2     " + sel_ImportePagar,"","gritter-info");
					sel_nota_credito=0;
					sel_opc_modifico_pago=0;
					iCicloFactura = 0;
					$('#txt_ImporteActual').val(0);
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#empleado").val("");
					iImporteFactura=0
					$("#txt_AclaracionCostos").val("");
					fnConsultarTipoMoneda(iFactura);					
					fnConsultarBeneficiarios(1);
					
				}
			}				
		});

		/*FACTURAS ACEPTADA POR PAGAR*/
		//var url='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?empleado=0&tipo=0&session_name='+Session;
		jQuery("#gd_AceptadaPorPagar").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			//url:url,
			colNames:LengStr.idMSG28,
			colModel:
			[
				{name:'marcado',index:'marcado',
						width:50, align: 'center', sortable:false,
						edittype:'checkbox', editable:true, editoptions: { value:"True:False"}, 
						formatter: "checkbox", formatoptions: {disabled : false} },
				{name:'fecha_asiganacion',		index:'fecha_asiganacion', 		width:50, 	sortable: false,	align:"center",	fixed: true,	hidden:true},			
				{name:'fecha_conclusion',		index:'fecha_conclusion', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},			
				{name:'estatus_revision',		index:'estatus_revision', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nom_estatus_revision',	index:'nom_estatus_revision', 	width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'otpp',					index:'otpp', 					width:50, 	sortable: false,	align:"center",	fixed: true},
				{name:'idBeneficiario',			index:'idBeneficiario', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreBecado',			index:'nombreBecado', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'factura',				index:'factura', 				width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaFactura',			index:'fechaFactura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaCaptura',			index:'fechaCaptura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'importeRealFact',		index:'importeRealFact',		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeConcepto',		index:'importeConcepto',		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'topeFactura',			index:'topeFactura', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeCal',				index:'importeCal', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importePagar',			index:'importePagar', 			width:90, 	sortable: false,	align:"right",	fixed: true/*,	hidden:true*/},
				{name:'rfc',					index:'rfc', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idEscuela',				index:'idEscuela', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreEscuela',			index:'nombreEscuela', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'idciclo',				index:'idciclo', 				width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ciclo',					index:'ciclo', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idTipoEscuela',			index:'idTipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipoEscuela',			index:'tipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ifactura',				index:'ifactura', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'empleado',				index:'empleado', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'comentario',				index:'comentario', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'aclaracion',				index:'aclaracion', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'observaciones',			index:'observaciones', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo1',				index:'archivo1', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo2',				index:'archivo2', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'deduccion',				index:'deduccion', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'idTipoDocto',			index:'idTipoDocto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipo_docto',				index:'tipo_docto', 			width:120, 	sortable: false,	align:"left",	fixed: true		/*,hidden:true*/},
				{name:'opc_blog',				index:'opc_blog', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog',					index:'blog', 					width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'opc_blog_colaborador',	index:'opc_blog_colaborador', 	width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog_colaborador',		index:'blog_colaborador', 		width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'id_nota',				index:'id_nota',				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'folio_nota',				index:'folio_nota', 			width:270, 	sortable: false,	align:"left",	fixed: true/*, 	hidden:true*/},
				{name:'importe_aplicado',		index:'importe_aplicado', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	/*hidden:true*/},
				{name:'idmotivorevision',		index:'idmotivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'motivorevision',			index:'motivorevision', 		width:250, 	sortable: false,	align:"left",	fixed: true 	/*,hidden:true*/},
				{name:'opc_modifico_pago',		index:'opc_modifico_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'des_metodo_pago',		index:'des_metodo_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'fol_relacionado',		index:'fol_relacionado', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'iCiclo',					index:'iCiclo', 				width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true}
				
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_AceptadaPorPagar_pager',
			sortname: 'fecestatus',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gd_AceptadaPorPagar").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
				}
				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				
				$('#gd_AceptadaPorPagar :checkbox').change(function(e){
					SeleccionarDeducible();
				});
			},
			onSelectRow: function(rowid) {
				if(rowid >= 0){
					var fila = jQuery("#gd_AceptadaPorPagar").getRowData(rowid); 
					iFactura=fila['ifactura'];
					iTipoDoc = fila['idTipoDocto'];
					iImporteFactura=accounting.unformat(fila['importeRealFact']);
					sel_importeCal=fila['importeCal'];
					sel_ImportePagar=fila['importePagar'];
				//	showalert("valor 1     " + sel_ImportePagar,"","gritter-info");
					$("#txt_AclaracionCostos").val(fila['aclaracion']);
					//$('#txt_ImporteActual').val(fila['importePagar']);
					$('#txt_ImporteActual').val(fila['importeConcepto']);
					nImporteOriginal = fila['importeConcepto'];
					$("#txt_ciclo").val(fila['idciclo']);
					iCicloFactura = fila['iCiclo'];
					$("#txt_archivo1").val(fila['archivo1']);
					$("#txt_archivo2").val(fila['archivo2']);
					$("#txt_empleado").val($("#txt_Numemp").val());
					fnConsultarBeneficiarios(0);
					sel_nota_credito=fila['id_nota'];
					sel_opc_modifico_pago=fila['opc_modifico_pago'];
					Aplicar_Desaplicar_Nota();
				} else {
					iFactura=0;
					iTipoDoc=0;
					sel_ImportePagar=0;
				//	showalert("valor 2     " + sel_ImportePagar,"","gritter-info");
					sel_nota_credito=0;
					sel_opc_modifico_pago=0;
					iCicloFactura = 0;
					$('#txt_ImporteActual').val(0);
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#empleado").val("");
					iImporteFactura=0
					$("#txt_AclaracionCostos").val("");
					fnConsultarBeneficiarios(1);
				}
			}				
		});

		
		
		/*FACTURAS RECHAZADAS*/
		jQuery("#gd_Rechazadas").jqGrid({
			datatype: 'json',
			//mtype: 'POST',
			colNames:LengStr.idMSG28,
			colModel:[
				{name:'marcado',index:'marcado',
						width:50, align: 'center', sortable:false,
						edittype:'checkbox', editable:true, editoptions: { value:"True:False"}, 
						formatter: "checkbox", formatoptions: {disabled : false} },
				{name:'fecha_asiganacion',		index:'fecha_asiganacion', 		width:50, 	sortable: false,	align:"center",	fixed: true,	hidden:true},			
				{name:'fecha_conclusion',		index:'fecha_conclusion', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},			
				{name:'estatus_revision',		index:'estatus_revision', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nom_estatus_revision',	index:'nom_estatus_revision', 	width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'otpp',					index:'otpp', 					width:50,  	sortable: false,	align:"center",	fixed: true},
				{name:'idBeneficiario',			index:'idBeneficiario', 		width:100, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'nombreBecado',			index:'nombreBecado', 			width:250, 	sortable: false,	align:"left", 	fixed: true},
				{name:'factura',				index:'factura', 				width:300, 	sortable: false,	align:"left", 	fixed: true},
				{name:'fechaFactura',			index:'fechaFactura', 			width:100, 	sortable: false,	align:"left", 	fixed: true},
				{name:'fechaCaptura',			index:'fechaCaptura', 			width:100, 	sortable: false,	align:"left", 	fixed: true},
				{name:'importeRealFact',		index:'importeRealFact',		width:90,  	sortable: false,	align:"right",	fixed: true},
				{name:'importeConcepto',		index:'importeConcepto',		width:90,  	sortable: false,	align:"right",	fixed: true},
				{name:'topeFactura',			index:'topeFactura', 			width:90,  	sortable: false,	align:"right",	fixed: true},
				{name:'importeCal',				index:'importeCal', 			width:90,  	sortable: false,	align:"right",	fixed: true},
				{name:'importePagar',			index:'importePagar', 			width:90,  	sortable: false,	align:"right",	fixed: true,	hidden:true},
				{name:'rfc',					index:'rfc', 					width:100, 	sortable: false,	align:"left", 	fixed: true},
				{name:'idEscuela',				index:'idEscuela', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'nombreEscuela',			index:'nombreEscuela', 			width:250, 	sortable: false,	align:"left", 	fixed: true},
				{name:'idciclo',				index:'idciclo', 				width:100, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'ciclo',					index:'ciclo', 					width:100, 	sortable: false,	align:"left", 	fixed: true},
				{name:'idTipoEscuela',			index:'idTipoEscuela', 			width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'tipoEscuela',			index:'tipoEscuela', 			width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'ifactura',				index:'ifactura', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'empleado',				index:'empleado', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'comentario',				index:'comentario', 			width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'aclaracion',				index:'aclaracion', 			width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'observaciones',			index:'observaciones', 			width:300, 	sortable: false,	align:"left", 	fixed: true,	hidden:false},
				{name:'archivo1',				index:'archivo1', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'archivo2',				index:'archivo2', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'deduccion',				index:'deduccion', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'idTipoDocto',			index:'idTipoDocto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipo_docto',				index:'tipo_docto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'opc_blog',				index:'opc_blog', 				width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'blog',					index:'blog', 					width:120, 	sortable: false,	align:"left", 	fixed: true,	hidden:true},
				{name:'opc_blog_colaborador',	index:'opc_blog_colaborador', 	width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog_colaborador',		index:'blog_colaborador', 		width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'id_nota',				index:'id_nota',				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'folio_nota',				index:'folio_nota', 			width:270, 	sortable: false,	align:"left",	fixed: true, 	/*hidden:true*/},
				{name:'importe_aplicado',		index:'importe_aplicado', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	/*hidden:true*/},
				{name:'idmotivorevision',		index:'idmotivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'motivorevision',			index:'motivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'opc_modifico_pago',		index:'opc_modifico_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'des_metodo_pago',		index:'des_metodo_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'fol_relacionado',		index:'fol_relacionado', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'iCiclo',					index:'iCiclo', 				width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true}
			],
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_Rechazadas_pager',
			sortname: 'fecestatus',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gd_Rechazadas").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
				}	
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				$('#gd_Rechazadas :checkbox').change(function(e){
					SeleccionarDeducible();
				});
			},
			onSelectRow: function(id) {
				if(id >= 0){
					var fila = jQuery("#gd_Rechazadas").getRowData(id);
					iFactura=fila['ifactura'];
					iTipoDoc = fila['idTipoDocto'];
					iImporteFactura = accounting.unformat(fila['importeRealFact']);
					//$('#txt_ImporteActual').val(fila['importePagar']);
					$('#txt_ImporteActual').val(fila['importeConcepto']);
					nImporteOriginal = fila['importeConcepto'];
					$("#txt_AclaracionCostos").val(fila['aclaracion']);
					$("#txt_ciclo").val(fila['idciclo']);
					iCicloFactura = fila['iCiclo'];
					$("#txt_archivo1").val(fila['archivo1']);
					$("#txt_archivo2").val(fila['archivo2']);
					$("#txt_empleado").val($("#txt_Numemp").val());
					fnConsultarBeneficiarios(0);
					sel_nota_credito=fila['id_nota'];
					sel_opc_modifico_pago=fila['opc_modifico_pago'];
					Aplicar_Desaplicar_Nota();
				} else {
					iFactura=0;
					iTipoDoc=0;
					iImporteFactura=0;
					sel_nota_credito=0;
					sel_opc_modifico_pago=0;
					iCicloFactura = 0;
					$('#txt_ImporteActual').val(0);
					$("#txt_AclaracionCostos").val("");
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#empleado").val("");
					fnConsultarBeneficiarios(1);
				}
			}				
		});	
		
		/*FACTURAS CON ACLARACIÓN*/
		jQuery("#gd_Aclaracion").jqGrid({
			datatype: 'json',
			//mtype: 'POST',
			colNames:LengStr.idMSG28,
			colModel:[
				{name:'marcado',index:'marcado',
						width:50, align: 'center', sortable:false,
						edittype:'checkbox', editable:true, editoptions: { value:"True:False"}, 
						formatter: "checkbox", formatoptions: {disabled : false} },
				{name:'fecha_asiganacion',		index:'fecha_asiganacion', 		width:50, 	sortable: false,	align:"center",	fixed: true,	hidden:true},			
				{name:'fecha_conclusion',		index:'fecha_conclusion', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'estatus_revision',		index:'estatus_revision', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},	
				{name:'nom_estatus_revision',	index:'nom_estatus_revision', 	width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'otpp',					index:'otpp', 					width:50, 	sortable: false,	align:"center",	fixed: true},
				{name:'idBeneficiario',			index:'idBeneficiario', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreBecado',			index:'nombreBecado', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'factura',				index:'factura', 				width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaFactura',			index:'fechaFactura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaCaptura',			index:'fechaCaptura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'importeRealFact',		index:'importeRealFact', 		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeConcepto',		index:'importeConcepto', 		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'topeFactura',			index:'topeFactura', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeCal',				index:'importeCal', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importePagar',			index:'importePagar', 			width:90, 	sortable: false,	align:"right",	fixed: true,	hidden:true},
				{name:'rfc',					index:'rfc', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idEscuela',				index:'idEscuela', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreEscuela',			index:'nombreEscuela', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'idciclo',				index:'idciclo', 				width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ciclo',					index:'ciclo', 					width:100, 	sortable: false,	align:"left",	fixed: true}	,
				{name:'idTipoEscuela',			index:'idTipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipoEscuela',			index:'tipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ifactura',				index:'ifactura', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'empleado',				index:'empleado', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'comentario',				index:'comentario', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'aclaracion',				index:'aclaracion', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'observaciones',			index:'observaciones', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo1',				index:'archivo1', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo2',				index:'archivo2', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'deduccion',				index:'deduccion', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'idTipoDocto',			index:'idTipoDocto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipo_docto',				index:'tipo_docto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'opc_blog',				index:'opc_blog', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true}, //CSC
				{name:'blog',					index:'blog', 					width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'opc_blog_colaborador',	index:'opc_blog_colaborador', 	width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog_colaborador',		index:'blog_colaborador', 		width:120, 	sortable: false,	align:"center",	fixed: true/*,	hidden:true*/},				
				{name:'id_nota',				index:'id_nota',				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'folio_nota',				index:'folio_nota', 			width:270, 	sortable: false,	align:"left",	fixed: true/*, 	hidden:true*/},
				{name:'importe_aplicado',		index:'importe_aplicado', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	/*hidden:true*/},
				{name:'idmotivorevision',		index:'idmotivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'motivorevision',			index:'motivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'opc_modifico_pago',		index:'opc_modifico_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'des_metodo_pago',		index:'des_metodo_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'fol_relacionado',		index:'fol_relacionado', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'iCiclo',					index:'iCiclo', 				width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true}
			],
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_Aclaracion_pager',
			sortname: 'fecestatus',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gd_Aclaracion").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
					$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				$('#gd_Aclaracion :checkbox').change(function(e){
					SeleccionarDeducible();
				});
			},
			onSelectRow: function(id) {
				if(id >= 0){
					$("#hid_factura").val('');
					var fila = jQuery("#gd_Aclaracion").getRowData(id); 
					iFactura=fila['ifactura'];
					iTipoDoc = fila['idTipoDocto'];
					iImporteFactura=accounting.unformat(fila['importeRealFact']);
					//$('#txt_ImporteActual').val(fila['importePagar']);
					$('#txt_ImporteActual').val(fila['importeConcepto']);
					nImporteOriginal = fila['importeConcepto'];
					$("#txt_AclaracionCostos").val(fila['aclaracion']);
					$("#txt_ciclo").val(fila['idciclo']);
					iCicloFactura = fila['iCiclo'];
					$("#txt_archivo1").val(fila['archivo1']);
					$("#txt_archivo2").val(fila['archivo2']);
					$("#txt_empleado").val($("#txt_Numemp").val());
					$("#hid_factura").val(fila['ifactura']);
					fnConsultarBeneficiarios(0);
					sel_nota_credito=fila['id_nota'];
					sel_opc_modifico_pago=fila['opc_modifico_pago'];
					Aplicar_Desaplicar_Nota();
					fnConsultarTipoMoneda(iFactura);
				} else {
					iFactura=0;
					iTipoDoc=0;
					iImporteFactura=0;
					sel_opc_modifico_pago=0;
					sel_nota_credito=0;
					iCicloFactura = 0;
					$('#txt_ImporteActual').val(0);
					$("#txt_AclaracionCostos").val("");
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#empleado").val("");
					fnConsultarBeneficiarios(1);
					fnConsultarTipoMoneda(iFactura);
				}
			}
		});
		
		//FACTURAS EN REVISION
		jQuery("#gd_Revision").jqGrid({
			datatype:'json',
			mtype:'GET',
			colNames: LengStr.idMSG28,
			colModel:			
			[
				{name:'marcado',index:'marcado',
						width:50, align: 'center', sortable:false,
						edittype:'checkbox', editable:true, editoptions: { value:"True:False"}, 
						formatter: "checkbox", formatoptions: {disabled : false} },
				{name:'fecha_asiganacion',		index:'fecha_asiganacion', 		width:150, 	sortable: false,	align:"center",	fixed: true/*,	hidden:true*/},			
				{name:'fecha_conclusion',		index:'fecha_conclusion', 		width:150, 	sortable: false,	align:"left",	fixed: true/*,	hidden:true*/},	
				{name:'estatus_revision',		index:'estatus_revision', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},	
				{name:'nom_estatus_revision',	index:'nom_estatus_revision', 	width:150, 	sortable: false,	align:"left",	fixed: true/*,	hidden:true*/},
				{name:'otpp',					index:'otpp', 					width:50, 	sortable: false,	align:"center",	fixed: true},
				{name:'idBeneficiario',			index:'idBeneficiario', 		width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreBecado',			index:'nombreBecado', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'factura',				index:'factura', 				width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaFactura',			index:'fechaFactura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'fechaCaptura',			index:'fechaCaptura', 			width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'importeRealFact',		index:'importeRealFact', 		width:90, 	sortable: false, 	align:"right",	fixed: true},
				{name:'importeConcepto',		index:'importeConcepto', 		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'topeFactura',			index:'topeFactura', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeCal',				index:'importeCal', 			width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importePagar',			index:'importePagar', 			width:90, 	sortable: false,	align:"right",	fixed: true,	hidden:true},
				{name:'rfc',					index:'rfc', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idEscuela',				index:'idEscuela', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nombreEscuela',			index:'nombreEscuela', 			width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'idciclo',				index:'idciclo', 				width:100, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ciclo',					index:'ciclo', 					width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idTipoEscuela',			index:'idTipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipoEscuela',			index:'tipoEscuela', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'ifactura',				index:'ifactura', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'empleado',				index:'empleado', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'comentario',				index:'comentario', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'aclaracion',				index:'aclaracion', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'observaciones',			index:'observaciones', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:false},
				{name:'archivo1',				index:'archivo1', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'archivo2',				index:'archivo2', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'deduccion',				index:'deduccion', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'idTipoDocto',			index:'idTipoDocto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'tipo_docto',				index:'tipo_docto', 			width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'opc_blog',				index:'opc_blog', 				width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog',					index:'blog', 					width:120, 	sortable: false,	align:"center",	fixed: true		/*,hidden:true*/},
				{name:'opc_blog_colaborador',	index:'opc_blog_colaborador', 	width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'blog_colaborador',		index:'blog_colaborador', 		width:120, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'id_nota',				index:'id_nota',				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'folio_nota',				index:'folio_nota', 			width:270, 	sortable: false,	align:"left",	fixed: true, 	/*hidden:true*/},
				{name:'importe_aplicado',		index:'importe_aplicado', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	/*hidden:true*/},
				{name:'idmotivorevision',		index:'idmotivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'motivorevision',			index:'motivorevision', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:false},
				{name:'opc_modifico_pago',		index:'opc_modifico_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'des_metodo_pago',		index:'des_metodo_pago', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'fol_relacionado',		index:'fol_relacionado', 		width:250, 	sortable: false,	align:"left",	fixed: true	},
				{name:'iCiclo',					index:'iCiclo', 				width:250, 	sortable: false,	align:"left",	fixed: true,	hidden:true}
			],
			scrollrows: true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,
			rowNum: 10,
			rowList: [10, 20, 30],
			pager: '#gd_Revision_pager',
			sortname:'fecestatus',
			viewrecords: true,
			hidegrid: false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gd_Revision").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
				showalert(LengStrMSG.idMSG86, "", "gritter-info");
				$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
				}

				var table = this;
				setTimeout(function(){
				updatePagerIcons(table);
				}, 0);

				$('#gd_Revision :checkbox').change(function(e){
				SeleccionarDeducible();
				});
			},
			onSelectRow: function(id){
				//se copia del grid de facturas con aclaracion
				if (id >= 0){
					$("#hid_factura_csc").val('');
					var fila = jQuery("#gd_Revision").getRowData(id); 
					iFactura=fila['ifactura'];
					iTipoDoc = fila['idTipoDocto'];
					iImporteFactura=accounting.unformat(fila['importeRealFact']);
					//$('#txt_ImporteActual').val(fila['importePagar']);
					$('#txt_ImporteActual').val(fila['importeConcepto']);
					nImporteOriginal = fila['importeConcepto'];
					$("#txt_AclaracionCostos").val(fila['aclaracion']);
					// $("#txt_Observaciones").val(fila['observaciones']);
					$("#txt_ciclo").val(fila['idciclo']);
					iCicloFactura = fila['iCiclo'];
					$("#txt_archivo1").val(fila['archivo1']);
					$("#txt_archivo2").val(fila['archivo2']);
					$("#txt_empleado").val($("#txt_Numemp").val());
					$("#hid_factura_csc").val(fila['ifactura']);
					fnConsultarBeneficiarios(0);
					sel_nota_credito=fila['id_nota'];
					sel_opc_modifico_pago=fila['opc_modifico_pago'];
					Aplicar_Desaplicar_Nota();
				} else {
					iFactura=0;
					iTipoDoc = 0;
					iImporteFactura=0;
					sel_nota_credito=0;
					sel_opc_modifico_pago=0;
					iCicloFactura = 0;
					$('#txt_ImporteActual').val(0);
					$("#txt_AclaracionCostos").val("");
					// $("#txt_Observaciones").val("");
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#empleado").val("");
					fnConsultarBeneficiarios(1);
					
				}
			}
		});
		
		//AL SELECCIONAR UN REGISTRO NOS DIRA SI TIENE NOTA O NO PARA APLICAR O DESAPLICAR NOTA
		function Aplicar_Desaplicar_Nota(){
			if (sel_nota_credito==0){
				$("#btn_notacredito").text('Aplicar Nota de Crédito');
			}else{
				$("#btn_notacredito").text('Revertir cambios');
			}			
		}
		
		//FACTURAS NOTAS DE CREDITO
		jQuery("#gd_NotaCredito").jqGrid({
			datatype:'json',
			mtype:'GET',
			colNames: LengStr.idMSG118,
			colModel:			
			[				
				{name:'numemp',				index:'numemp', 			width:300, sortable: false,	align:"center",	fixed: true,	hidden:true},
				{name:'empleado',			index:'empleado', 			width:300, sortable: false,	align:"center",	fixed: true,	hidden:true},
				{name:'folio',				index:'folio', 				width:300, sortable: false,	align:"center",	fixed: true},
				{name:'importe',			index:'importe', 			width:150, sortable: false,	align:"right",	fixed: true		/*,hidden:true*/},
				{name:'importe_aplicado',	index:'importe_aplicado', 	width:150, sortable: false,	align:"right",	fixed: true },
				{name:'importe_aplicar',	index:'importe_aplicar', 	width:150, sortable: false,	align:"right",	fixed: true},
				{name:'folio_relacionado',	index:'folio_relacionado', 	width:300, sortable: false,	align:"left",	fixed: true},
				{name:'factura',			index:'factura', 			width:100, sortable: false,	align:"left",	fixed: true ,hidden:true},				
			],
			scrollrows: true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200,
			rowNum: 10,
			rowList: [10, 20, 30],
			pager: '#gd_NotaCredito_pager',
			sortname:'fecestatus',
			viewrecords: true,
			hidegrid: false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gd_NotaCredito").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && iConsultarFac==1)
				{
				showalert(LengStrMSG.idMSG86, "", "gritter-info");
				$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
				}

				var table = this;
				setTimeout(function(){
				updatePagerIcons(table);
				}, 0);

				$('#gd_NotaCredito :checkbox').change(function(e){
				SeleccionarDeducible();
				});
			},
			onSelectRow: function(id){
				//se copia del grid de facturas con aclaracion
				if (id >= 0){
					var fila = jQuery("#gd_NotaCredito").getRowData(id); 
					iFactura=fila['factura'];
					iImporteFactura=accounting.unformat(fila['importeRealFact']);
					//$('#txt_ImporteActual').val(fila['importePagar']);
					$('#txt_ImporteActual').val(fila['importeConcepto']);
					nImporteOriginal = fila['importeConcepto'];
					$("#txt_AclaracionCostos").val(fila['aclaracion']);
					$("#txt_ciclo").val(fila['idciclo']);
					$("#txt_archivo1").val(fila['archivo1']);
					$("#txt_archivo2").val(fila['archivo2']);
					$("#txt_empleado").val($("#txt_Numemp").val());
					fnConsultarBeneficiarios(0);
				} else {
					iFactura=0;
					iImporteFactura=0;
					$('#txt_ImporteActual').val(0);
					$("#txt_AclaracionCostos").val("");
					$("#txt_ciclo").val("");
					$("#txt_archivo1").val("");
					$("#txt_archivo2").val("");
					$("#empleado").val("");
					fnConsultarBeneficiarios(1);
				}
			}
		});		
		
		/*PAGOS MENSUALES*/
		jQuery("#gd_PagosMensuales").jqGrid({
			datatype: 'json',
			//mtype: 'POST',
			colNames:LengStr.idMSG29,
			colModel:[
				{name:'mes',		index:'mes', 		width:130, sortable: false,	align:"left",	fixed: true},
				{name:'pagado',		index:'pagado', 	width:110, sortable: false,	align:"right",	fixed: true, hidden:true},
				{name:'pagadoF',	index:'pagado', 	width:110, sortable: false,	align:"right",	fixed: true},
				{name:'tope',		index:'tope', 		width:110, sortable: false,	align:"right",	fixed: true, hidden:true},
				{name:'topeF',		index:'tope', 		width:110, sortable: false,	align:"right",	fixed: true},
				{name:'restante',	index:'restante', 	width:110, sortable: false,	align:"right",	fixed: true/*, hidden:true*/},
				{name:'restanteF',	index:'restanteF', 	width:110, sortable: false,	align:"right",	fixed: true, hidden:true},
				{name:'ajuste',		index:'ajuste', 	width:110, sortable: false,	align:"right",	fixed: true, hidden:true}
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			//viewrecords : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			//pager : "#gd_Aclaracion_pager",
			//--Para que el tama?o sea automatico muy bueno ya con los otros cambios se evita crear tablas
			width: 350,
			//shrinkToFit: false,
			height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			//----------------------------------------------------------------------------------------------------------
			//caption: 'Cifras',
			//pgbuttons: false,
			//pgtext: null,
		//	postData:{session_name:Session},
			
			loadComplete: function (Data) {
				var registros = jQuery("#gd_PagosMensuales").jqGrid('getGridParam', 'reccount');
				
				//if(registros < 0){
				//	$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
					/*if(nConsulta==1)
					{
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}	
					$("#txt_Restante").val(accounting.unformat($("#txt_TopeAnual").val()));*/
				//}
				//else
				//{
					var Total, Tope, Ajuste;
					var grid = $('#gd_BeneficiariosFactura');
					//Tope =$("#gd_PagosMensuales").jqGrid('getCol', 'restante', false, 'max');
					// Total = $("#gd_PagosMensuales").jqGrid('getCol', 'pagado', false, 'sum');
					Total = Data.pagado_anual;
					if (Total < 0){
						$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(0, "", 2));
					}
					else{
						$("#txt_AcumuladoFacturaPagada").val(accounting.formatMoney(Total, "", 2));
					}
					$("#txt_Pagadas").val(accounting.formatMoney(Total, "", 2));
					
					//Tope=accounting.unformat($("#txt_TopeAnual").val())-accounting.unformat(Total);
					Tope= $("#gd_PagosMensuales").jqGrid('getCol','restanteF');
					Ajuste= $("#gd_PagosMensuales").jqGrid('getCol','ajuste');
					$("#txt_ajuste").val(accounting.formatMoney(Ajuste[0], "", 2));
					//console.log('Tope='+Tope[0]);
					$("#txt_Restante").val(accounting.unformat($("#txt_TopeAnual").val()));
					$("#txt_Restante").val(accounting.formatMoney(Tope[0], "", 2));
					//$("#txt_Restante").val(Tope[0]);
					if(nConsulta==1)
					{
						$('#dlg_PagosMensuales').modal('show');
						nConsulta=0;
					}	
				//}
			}		
		});	
		fixGrid({position:true,grid:'#gd_PagosMensuales', stretch: true, width: '%',ctrlbuttons:true, scroll:true});
		
		/*BENEFICIARIOS*/
		
		jQuery("#gd_Beneficiarios").jqGrid({
			datatype: 'json',
			//mtype: 'POST',
			colNames: rowBeneficiario,
			colModel:[
				{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
					{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:300, 	sortable: false,	align:"left",	fixed: true},
					{name:'fec_nac_beneficiario', index:'fec_nac_beneficiario', width: 100, 	sortable: false,	align:"left", fixed: true, hidden: true},
					{name:'edad_beneficiario', 	index:'edad_beneficiario', width: 100, 	sortable: false,	align:"left", 	fixed: true, hidden: true},					
					{name:'idu_parentesco',		index:'idu_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nom_parentesco',		index:'nom_parentesco', 	width:150, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_tipo_pago',		index:'idu_tipo_pago', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'des_tipo_pago',		index:'des_tipo_pago', 		width:150, 	sortable: false,	align:"left",	fixed: true},
					{name:'nom_periodo',		index:'nom_periodo', 		width:100, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:200, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_carrera',		index:'idu_carrera', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nom_carrera',		index:'nom_carrera', 		width:200, 	sortable: false,	align:"left",	fixed: true,	hidden:false},
					{name:'imp_importeF',		index:'imp_importeF', 		width:100, 	sortable: false,	align:"right"},
					{name:'imp_importe',		index:'imp_importe', 		width:70, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
					{name:'idu_grado',			index:'idu_grado', 			width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nom_grado',			index:'nom_grado', 			width:200, 	sortable: false,	align:"left",	fixed: true},
					{name:'idu_ciclo',			index:'idu_ciclo', 			width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'nom_ciclo_escolar',	index:'nom_ciclo_escolar', 	width:90, 	sortable: false,	align:"left",	fixed: true},
					{name:'descuento',			index:'descuento', 			width:80, 	sortable: false,	align:"right",	fixed: true},
					{name:'comentario',			index:'comentario', 		width:300, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
					{name:'keyx',				index:'keyx', 				width:100, 	sortable: false,	align:"left",	fixed: true, hidden: true}
				
				//{name:'edad_anio_beneficiario',	index:'edad_anio_beneficiario', 	width:150, 	sortable: false,	align:"left",	fixed: true}
				//{name:'fecha_beneficiario' ,index:'fecha_beneficiario', width:150, 	sortable: false,	align:"left",	fixed: true},
				//{name:'edad_anio_beneficiario',	index:'edad_anio_beneficiario', 	width:150, 	sortable: false,	align:"left",	fixed: true},
				//{name:'edad_mes_beneficiario',	index:'edad_mes_beneficiario', 	width:150, 	sortable: false,	align:"left",	fixed: true}
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			//viewrecords : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			caption:'Beneficiarios',
			//pager : "#gd_Aclaracion_pager",
			//--Para que el tama?o sea automatico muy bueno ya con los otros cambios se evita crear tablas
			width: null,
			shrinkToFit: false,
			height: 120,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			//----------------------------------------------------------------------------------------------------------
			//caption: 'Cifras',
			pgbuttons: false,
			pgtext: null,
			
			loadComplete: function (Data) {
				var dato = ($("#gd_Beneficiarios").jqGrid('getCol', 'idu_escolaridad'))
				//console.log(dato[0])
				if (dato[0] == 1 ){
					$("#gd_Beneficiarios").jqGrid('showCol', ['fec_nac_beneficiario']);
					$("#gd_Beneficiarios").jqGrid('showCol', ['edad_beneficiario']);
					
				}
				else{
					$("#gd_Beneficiarios").jqGrid('hideCol', ['fec_nac_beneficiario']);
					$("#gd_Beneficiarios").jqGrid('hideCol', ['edad_beneficiario']);
					
				}

				// if (Data.escolaridades != undefined) {
					// Data.escolaridades
					// sEscolaridades = Data.escolaridades;					
				// }
				// console.log(Data.idu_carrera);
				// if (Data.idu_carrera == 0 || Data.idu_carrera == undefined) {
					// $("#gd_Beneficiarios").jQuery()
					// $("#gd_Beneficiarios").jqGrid('hideCol',["nom_carrera"]);
				// } else {
					// $("#gd_Beneficiarios").jqGrid('showCol',["nom_carrera"]);
				// }
				
			},
			onSelectRow: function(id) {
				if(id >= 0){
					var fila = jQuery("#gd_Beneficiarios").getRowData(id); 
					$("#txt_Comentario_Especial").val(fila['comentario']);
					
				} else {
					$("#txt_Comentario_Especial").val("");
				}
			}	
			
		}
		);
		

		


		/*Modificar Importe A Pagar*/
//--MODIFICAR IMPORTE A PAGAR	
		jQuery("#gd_ModificarImporteAPagar").jqGrid({
			datatype: 'json',
			colNames:LengStr.idMSG62,
			colModel:[
				{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",fixed: true, 	hidden:true},
				{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",fixed: true,	hidden:true},
				{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:230, 	sortable: false,	align:"left",fixed: true},
				{name:'idu_parentesco',		index:'idu_parentesco', 	width:100, 	sortable: false,	align:"left",fixed: true, 	hidden:true},
				{name:'nom_parentesco',		index:'nom_parentesco', 	width:90, 	sortable: false,	align:"left",fixed: true},
				{name:'idu_tipo_pago',		index:'idu_tipo_pago', 		width:50, 	sortable: false,	align:"left",fixed: true, 	hidden:true},
				{name:'des_tipo_pago',		index:'des_tipo_pago', 		width:100, 	sortable: false,	align:"left",fixed: true},
				{name:'nom_periodo',		index:'nom_periodo', 		width:100, 	sortable: false,	align:"left",fixed: true, 	hidden:true},
				{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:50, 	sortable: false,	align:"left",fixed: true, 	hidden:true},
				{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:132, 	sortable: false,	align:"left",fixed: true},
				//{name:'imp_importeF', index:'imp_importeF', width:70, sortable: false, align:"right"},
				//{name:'imp_importe',index:'imp_importe', width:100, sortable: false,align:"right",fixed: true/*, hidden:true*/},
				{
					name:'imp_importeF',
					index:'imp_importeF',
					width:100,
					sortable: false,
					align:"right",
					editable: true,
					formatter: 'currency',
					formatoptions: { decimalSeparator: ".", thousandsSeparator: ",", decimalPlaces: 2 },
					editoptions: {
						dataInit: function(element) {
							$("#" + element.id).css('text-align','right');
							var objeto = (((element.id).replace('_imp_importeF',''))-1);
							//console.log('replace='+((element.id).replace('_imp_importeF','')));
							//console.log('objeto='+objeto);
							if(cantidadImp[objeto] != 0)
								$(element).val(cantidadImp[objeto]);						
							
							//$(element).val(jQuery("#gd_ModificarImporteAPagar").jqGrid('setCell',(element.id).replace("_imp_importeF",""),'imp_importeF'));
							$(element).keypress(function(e) {								
								//$(element).keyup(function(e) {								
								//console.log(e.which);
								if (e.which==13){
									//console.log('enter');
									//console.log(cantidadImp[0]+'='+cantidadImp[1]);
									//$("#" + this).blour();
									//$("#btn_GuardarImportes").focus();
									cantidadImp[objeto] = $(element).val();
									//cantidadImp[objeto] =(((element.id).replace('_imp_importeF',''))-1);
									//$("#"+((element.id).replace("_imp_importeF",""))).trigger("click");
									//console.log('cantidadImp[objeto]='+cantidadImp[objeto]);
									$("#txt_ImporteActual").val(accounting.formatMoney(cantidadImp[objeto], "",2));
									jQuery("#gd_ModificarImporteAPagar").jqGrid('setCell',(element.id).replace("_imp_importeF",""),'imp_importeF',$(element).val());
									//jQuery("#gd_ModificarImporteAPagar").jqGrid('setCell',(element.id).replace("_imp_importeF",""),'imp_importe_pagado',pagar);
									$(element).remove();
									//pagado=jQuery("#gd_ModificarImporteAPagar").jqGrid('getCell', (element.id).replace("_imp_importeF",""),'imp_importe_pagado');
									descuento=$('#gd_ModificarImporteAPagar').jqGrid('getCell',(element.id).replace("_imp_importeF",""),'descuento'); //accounting.formatMoney(,2) (descuento/100)
									pagar=accounting.formatMoney($(element).val()*(descuento/100), "",2);
									jQuery("#gd_ModificarImporteAPagar").jqGrid('setCell',(element.id).replace("_imp_importeF",""),'imp_importe_pagado',pagar);
									//return false;
									/*var sumaCon = 0.00;
									for(var i = 0; i < $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++) {
											
												if(cantidadImp[i] != 0 && $('#gd_ModificarImporteAPagar').jqGrid('getCell',(i+1),'imp_importeF') == '000')
												{
													jQuery("#gd_ModificarImporteAPagar").jqGrid('setCell',(i+1),'imp_importeF',cantidadImp[i]);
												}
												sumaCon += parseFloat($('#gd_ModificarImporteAPagar').jqGrid('getCell',(i+1),'imp_importeF'));
											
										}
										$("#txt_ImporteActual").val(accounting.formatMoney(sumaCon, "",2));*/

								}

								
								if (e.which != 8 && e.which != 0 && e.which != 46 && (e.which < 48 || e.which > 57 )) {
									//console.log('--');
									//8= retroceso
									//0=suprimir
									return false;								
								}
								//event.preventDefault();	
							});
							
							$(element).afterSubmitCell(function(){
								//console.log('aqui');
								return false;								
							});
							
							/*$(element).afterSaveCell(function(){
								console.log('aca');
								//return false;
							});*/	
							/*$(element).onSelectCell(function(){	
								console.log('se cerró');
							});*/
						}
					}/*,
					afterSaveCell: (function(){
						console.log('aqui');
						return false;								
					})*/
				},
				
				{name:'imp_importe',		index:'imp_importe', 		width:100, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'imp_importe_pagado', index:'imp_importe_pagado', width:100, 	sortable: false, 	align:"right"},				
				{name:'idu_grado',			index:'idu_grado', 			width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_grado',			index:'nom_grado', 			width:210, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_ciclo',			index:'idu_ciclo', 			width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_ciclo_escolar',	index:'nom_ciclo_escolar', 	width:80, 	sortable: false,	align:"center",	fixed: true},
				{name:'descuento', 			index:'descuento', 			width:70, 	sortable: false, 	align:"right", 	fixed: true},
				{name:'comentario',			index:'comentario', 		width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'keyx',				index:'keyx', 				width:100, 	sortable: false, 	align:"left",	fixed:	true, 	hidden:true},
				{name:'idfactura',			index:'idfactura', 			width:100, 	sortable: false, 	align:"left", 	fixed:	true, 	hidden:true}
			],
			cellEdit: true,
			cellsubmit: 'clientArray',
			editurl: 'clientArray',
			scrollrows: true,
			viewrecords: false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: null,//'100%',
			shrinkToFit: false,
			height: 110,
			pgbuttons: false,
			pgtext: null,
			loadComplete: function (Data) {
				//console.log(Data);
				for(var j = 0; j < Data.rows.length; j++) {
					cantidadImp[j] = 0;
				}
			 },
			onSelectRow: function(id) {
				 fixeImporte();
				/*alert("OK");
				if(id >= 0){
					var fila = jQuery("#gd_Beneficiarios").getRowData(id);
					$("#txt_Comentario_Especial").val(fila['comentario']);
				} else {
					$("#txt_Comentario_Especial").val("");
				}*/
			}
			
		});		
	}	
	

	////////////// GRID DE PORCENTAJES ///////////////////

	jQuery("#gd_Porcentajes").jqGrid({
		datatype: 'json',
		colNames:LengStr.idMSG134,
		colModel:[
			{name:'idu_escolaridad',	index:'idu_escolaridad', 		width:150, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_parentesco',		index:'idu_parentesco', 	width:400, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nom_parentesco',		index:'nom_parentesco', 	width:150, 	sortable: false,	align:"left",	fixed: true},
			{name:'porcentaje',			index:'porcentaje', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'justificacion',		index:'justificacion', 		width:300, 	sortable: false,	align:"left",	fixed: true},
			{name:'fec_registro',		index:'fec_registro', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'num_registro',		index:'num_registro', 	width:150, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_registro',		index:'nom_registro', 	width:200, 	sortable: false,	align:"left",	fixed: true}
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		viewrecords : false,
		rowNum:-1,
		hidegrid: false,
		rowList:[],
		width: null,
		shrinkToFit: false,
		height:280,
		pgbuttons: false,
		pgtext: null,
		caption:' ',
		loadComplete: function (Data) {
		},
		onSelectRow: function(id) {
		}					
	});



	//--
	function RecalcularImportes(){
	//	console.log('Recalcula Importe');
	}
	
	function DescargarAnexos()
	{
		//console.log('ciclo: ' + $("#txt_ciclo").val().replace(/^\s+|\s+$/gm,''));
		var sUrl = 'ajax/proc/proc_descargar_zip.php?';
			sUrl += '&txt_ciclo='+ $("#txt_ciclo").val().replace(/^\s+|\s+$/gm,'');
			sUrl += '&txt_archivo1='+$("#txt_archivo1").val().replace(/^\s+|\s+$/gm,'');
			sUrl += '&txt_archivo2='+$("#txt_archivo2").val().replace(/^\s+|\s+$/gm,'');
			sUrl += '&txt_empleado='+$("#txt_empleado").val().replace(/^\s+|\s+$/gm,'');
			sUrl += '&csrf_token='+$('#csrfToken').data('token');
			sUrl += '&token='+$("#txt_token").val();//.replace(/^\s+|\s+$/gm,'');
			
			//console.log(sUrl);
			//return;
			
		var xhr = new XMLHttpRequest();
		
		xhr.open("POST", sUrl, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	
		xhr.addEventListener("progress", function(evt) {
			
			if (evt.lengthComputable) {
				
				var percentComplete = evt.loaded / evt.total;
				//console.log(percentComplete);;
			}
		}, true);
		
		xhr.responseType = "blob";
		xhr.onreadystatechange = function(){
			waitwindow('', 'close');
			

			//console.log('readyState: ' + this.readyState + ' estatus: ' + this.status);
			if ( this.readyState == XMLHttpRequest.DONE && this.status == 200 ) {
				var filename = "download.zip";
				
				var link = document.createElement('a');
				link.href = window.URL.createObjectURL(xhr.response);
				link.download = filename;
				link.style.display = 'none';
				
				document.body.appendChild(link);
				
				link.click();
				
				document.body.removeChild(link);
				
				$("#txt_archivo1").val("");
				$("#txt_archivo2").val("");
				$("#txt_empleado").val("");
				$("#txt_ciclo").val("");
				$("txt_token").val("");
			} else if (this.readyState == XMLHttpRequest.DONE && (this.status == 405 || this.status == 404 || this.status != 200)){
				showalert("Documentos no disponibles zip", "", "gritter-error");
			}
		};
		
		waitwindow('Obteniendo archivos, por favor espere...', 'open');
		xhr.send(sUrl);

	}
	function fnConsultarFacturas(inicializar){
		$("#btn_Blog").prop("disabled",true);
		$("#btn_Blog_Csc").prop("disabled",true);
		$("#btn_ModificarImporte").prop("disabled",true);

		
		var tab =$("#tabs").tabs('option', 'active');
		
		
			tab += 1;
		
		
		 //console.log(tab);
		var empleado=$("#txt_Numemp").val();
		if(empleado.length==8)
		{
			var urlu='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?iOpcion=0&sEmpleados='+empleado+'&tipo='+tab+'&session_name=' +Session+'&inicializar='+inicializar;
			//console.log('switch tab='+tab);
			$("#btn_notacredito").prop("disabled", false);
			switch(tab)
			{
				
				case 1:
					if($("#txt_FechaIni").val()!='')
					{
						urlu='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?iOpcion=0&sEmpleados='+empleado+'&tipo=1&fechaini='+$("#txt_FechaIni").val()+'&fechafin='+$("#txt_FechaFin").val()+'&session_name=' +Session+'&inicializar='+inicializar;
					}
					else
					{
						urlu='ajax/json/json_fun_obtener_facturas_colegiaturas_por_empleado.php?iOpcion=0&sEmpleados='+empleado+'&tipo=1&session_name=' +Session+'&inicializar='+inicializar;
					}
					$("#gd_Proceso").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
					$("#btn_ModificarImporte").prop("disabled",false);
				break;
				case 2:
					$("#gd_AceptadaPorPagar").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
				break;
				case 3:
					$("#gd_Rechazadas").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
				break;
				case 4:
					$("#btn_Blog").prop("disabled",false);
					$("#gd_Aclaracion").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");
					$("#btn_ModificarImporte").prop("disabled",false); 
				break;
				case 5:
					$("#btn_Blog_Csc").prop("disabled",false);
					$("#gd_Revision").jqGrid('setGridParam',{url: urlu}).trigger("reloadGrid");
				break;
				case 6:		
					$("#btn_notacredito").prop("disabled", true);
					urlu='ajax/json/json_fun_obtener_nota_credito_empleado.php?iEmpleado='+empleado;
					$("#gd_NotaCredito").jqGrid('setGridParam',{url: urlu}).trigger("reloadGrid");
				break;
				default:
				break;
			}
			iFactura=0;
			$("#txt_Observaciones").val("");
			fnConsultarBeneficiarios(1);
			
			waitwindow('', 'close');
		}	
	}
	
	function fnConsultarBeneficiarios(inicializar) {
		var empleado = $("#txt_Numemp").val();
		var urlu = 'ajax/json/json_fun_obtener_beneficiarios_por_factura.php?iEmpleado=' + empleado + '&iFactura=' + iFactura + '&inicializar=' + inicializar;
		$("#gd_Beneficiarios").jqGrid('setGridParam', { url: urlu}).trigger("reloadGrid");
	}
	
	function fnConsultaDeducciones() {
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
			data: { },
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				//console.log(dataS);
				if(dataJson.estado == 0) {
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Deduccion").trigger("chosen:updated").append(option);
					$("#cbo_Deduccion").val(1); 
					$("#cbo_Deduccion").trigger("chosen:updated");
					
				}
				else
				{
					//showalert(dataJson.mensaje, "", "gritter-warning");
					showalert(LengStrMSG.idMSG88+" los tipos de deducción", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}
	
	function fnConsultarMotivosRechazos() {
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_motivos_combo.php",
			data: { 'iOpcion':1 },
			beforeSend:function(){},
			success:function(data){
				option = option + "<option value='0'>SELECCIONE</option>";
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if (dataJson.estado==0)
				{
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + (dataJson.datos[i].value) + "'>" + (dataJson.datos[i].nombre) + "</option>";
					}
					
					$("#cbo_Rechazo").trigger("chosen:updated").append(option);
					$("#cbo_Rechazo").trigger("chosen:updated");
				}	
				else
				{
					//showalert(dataJson.mensaje, "", "gritter-warning");
					showalert(LengStrMSG.idMSG88+" los motivos", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}
	
	//--CONSULTAR MOTIVO REVISION
	function fnConsultarMotivosRevision() {
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_motivos_combo.php",
			data: { 'iOpcion':4 },
			beforeSend:function(){},
			success:function(data){
				option = option + "<option value='0'>SELECCIONE</option>";
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if (dataJson.estado==0)
				{
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + (dataJson.datos[i].nombre) + "</option>";
					}
					$("#cbo_MotivoRevision").trigger("chosen:updated").append(option);
					$("#cbo_MotivoRevision").trigger("chosen:updated");
				}	
				else
				{
					//showalert(dataJson.mensaje, "", "gritter-warning");
					showalert(LengStrMSG.idMSG88+" los motivos", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}

	function fnConsultarPagosPorMes(callback){
		var empleado=$("#txt_Numemp").val();
		if($("#txt_Nombre").val()!="")
		{
			var urlu='ajax/json/json_fun_obtener_listado_importe_pagado_por_mes.php?iEmpleado='+empleado+'&session_name=' +Session;
			$("#gd_PagosMensuales").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
		}
			
		if (callback != undefined){
			callback();
		}
	}
	function fnEnviarComentario(){
		var Comentario=$("#txt_mensaje").val().toUpperCase();
		var opciones= {
			beforeSubmit: function(){
				//	alert('antes de subir');
				//console.log('antes de subir');
			}, 
			uploadProgress: function(){
				//console.log('subiendo');
			},
			success: function(data) 
			{
				var dataJson = JSON.parse(data);
				if (dataJson.estado !=1) {
					//message(dataJson.mensaje);
					//showalert(dataJson.mensaje, "", "gritter-info");
					showalert(LengStrMSG.idMSG230+' el comentario', "","gritter-warning");
				} else {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG298, "","gritter-success");
				}
				$('#dlg_Blog').modal('hide');
				$("#txt_mensaje").val("");
			}
		};
		$( '#session_name1' ).val(Session);
		if ($('#hid_factura' ).val().replace(/^\s+|\s+$/gm,'') == '') {
			$('#hid_factura' ).val(iFactura);
		}
		$("#txt_mensaje").val(Comentario);
		$( '#iEmpleado' ).val($("#txt_Numemp").val());
		
		$( '#fmComentario' ).ajaxForm(opciones) ;
		$( '#fmComentario' ).submit();
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
			var $class = (icon.attr('class').replace('ui-icon', '')).replace(/^\s+|\s+$/gm,'');
			
			if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
		})
	}
	function fnGuardar()
	{
		var selr="", iEstatus=0, grid="", Mensaje="";
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		if($('#rdb_Aceptado').is(":checked"))
		{
			iEstatus=1;
			//console.log('restante='+accounting.unformat($("#txt_Restante").val()));
			if (iImporteConcepto>accounting.unformat($("#txt_Restante").val())) {
				Mensaje='<font color="red">'+LengStrMSG.idMSG299+'</font>';//"El colaborador sobrepasa el tope anual ¿Desea marcar las facturas para pagarse?";
				//console.log('no puede')
			//}else{
				//console.log('si puede');
			}else if(accounting.unformat($("#txt_Restante").val())<=0)
			{
				Mensaje='<font color="red">'+LengStrMSG.idMSG299+'</font>';//"El colaborador sobrepasa el tope anual ¿Desea marcar las facturas para pagarse?";
			}
			else
			{
				Mensaje=LengStrMSG.idMSG300;//"¿Desea marcar las facturas para pagarse?";
			}	
			sObservaciones=$("#txt_Observaciones").val().toUpperCase();
		}
		else if($('#rdb_Rechazado').is(":checked"))
		{
			iEstatus=2;
			Mensaje=LengStrMSG.idMSG301;//"¿Desea rechazar las facturas?";
			sObservaciones=$("#txt_Observaciones").val().toUpperCase();
		}
		else if($('#rdb_Revision').is(":checked")){									
			iEstatus = 4;
			Mensaje="¿Desea enviar a revisión la factura?";
			sObservaciones=$("#txt_Observaciones").val().toUpperCase();	
		}																			
		else
		{
			iEstatus=3;
			Mensaje=LengStrMSG.idMSG302;//"¿Desea mandar las facturas a aclaración?";
			sObservaciones='';
			//sAclaracion=$("#txt_Observaciones").val().toUpperCase();
		}
		// var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');
		// console.log(selr);
		// if ((jQuery(grid).find("tr").length - 1) == 0 ) 
		// {
		////	message('No hay información');
			// showalert(LengStrMSG.idMSG86, "", "gritter-info");
		// }
		// else
		// {
			// if(selr.length != 0)
			// {	
			$("#btn_Guardar").prop('disabled', true);
				bootbox.confirm(Mensaje,'No','Si', function(result) 
				{
					$("#btn_Guardar").prop('disabled', false);
					var arr_export = [];
					//var keysx = '';
					var obj = {};
					
					//Notificaciones 39116
					// var arr_iFacturas = []; 
					var arr_iFacturas = "";
					var iEmpleado = $("#txt_Numemp").val();

					for(var i = 0; i < $(grid).find("tr").length - 1; i++) {
						var Jdata = $(grid).jqGrid('getRowData',i);
						if((Jdata.marcado.toUpperCase())=="TRUE")
						{
							obj = {'factura':Jdata.ifactura};
							arr_export.push(obj);

							//Notificaciones 39116
							// arr_iFacturas.push(Jdata.ifactura);
							arr_iFacturas = Jdata.ifactura;
						}	
						
					}
					var dataJsonf = JSON.stringify(arr_export);
					var iFacturasN = JSON.stringify(arr_iFacturas); //Notificaciones 39116
					if(result) 
					{
						if (iEstatus==3){
							//console.log('confirmando ifactura='+iFactura);
							$('#dlg_Blog').modal('show');
						}
						// console.log(dataJsonf);
						// alert('Prueba');
						// exit();
						$.ajax({type: "POST",
							url: "ajax/json/json_guardar_estatus_factura_autorizar_rechazar.php",
							data: { 
								'session_name':Session,
								'iEstatus':iEstatus,
								'iDeducion':$("#cbo_Deduccion").val(),
								'iRechazo':$("#cbo_Rechazo").val(),
								'cComentario':sObservaciones,
								'iRevision':$("#cbo_MotivoRevision").val(),
								'json':dataJsonf,
								'numEmp': $("#txt_Numemp").val()
							},
							beforeSend:function(){},
							success:function(data){
								iContador = iContador + 1;
								var dataJson = JSON.parse(data);
								if (dataJson.estado==1)
								{
									
									if (iEstatus==1)
									{
										showalert(LengStrMSG.idMSG303, "", "gritter-success");
									}
									else if (iEstatus==2)
									{
										showalert(LengStrMSG.idMSG304, "", "gritter-success");
									}
									/*39116 - Ruth */
									else if(iEstatus==3){
										if(iEstatus==3){
											
											enviarNotificacionEmpleado(iEmpleado);
											UPD_NotificacionEnAclaracion(0, iFacturasN, iEmpleado)
										}else{
											UPD_NotificacionEnAclaracion(2, iFacturasN, iEmpleado)
										}
									}
									/*39116 - Ruth */
									else if(iEstatus==4)
									{
										showalert("Factura(s) enviada(s) a Revision","","gritter-success");
									}
				
									else
									{
										showalert(LengStrMSG.idMSG305, "", "gritter-success");
									}	

									

									//showalert(dataJson.mensaje, "", "gritter-success");
									//message(dataJson.mensaje);
									iConsultarFac=0;
									fnConsultarFacturas(0);
									fnConsultarBeneficiarios(1);
									$("txt_Comentario_Especial").val("");
									$("#txt_AclaracionCostos").val("")
									$("#txt_Observaciones").val("");
									$("#cbo_Rechazo").val(0);
									$("#cbo_Deduccion").val(1);
									$("#rdb_Aceptado").prop('checked',true);
									$("#cbo_Rechazo").val(0);
									$("#cbo_Rechazo").prop('disabled',true);
									$("#cbo_MotivoRevision").val(0);
									$("#cbo_MotivoRevision").prop('disabled',true);
									iGuardaAclaracion=0;
									
									CargarDatosGenerales(function(){
										
									});
									
								}	
								else 
								{
									//message(dataJson.mensaje);
									showalert(dataJson.mensaje, "", "gritter-info");
									//console.log("error aca");
								}
							},
							error:function onError(){},
							complete:function(){},
							timeout: function(){},
							abort: function(){}	
						});
						
					}
				})
			// }
			// else 
			// {
				////alert("Debe de seleccionar una factura");
				// showalert(LengStrMSG.idMSG306, "", "gritter-info");
			// }
		// }	
	}
	function fnRegistrosMarcados()
	{
		var selr="",  grid="";
		var tab =$("#tabs").tabs('option', 'active');
		//console.log('fnRegistrosMarcados');
		switch(tab)
		{
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		var selr = jQuery(grid).jqGrid('getGridParam','selarrrow');
		var arr_export = [];
		for(var i = 0; i < selr.length; i++)
		{
			var rowData = jQuery(grid).getRowData(selr[i]);
			arr_export[i] = {};
			arr_export[i].factura = rowData.ifactura;
			
			if (selr.length == 1) {
				$("#txt_ciclo").val((rowData.idciclo).replace(/^\s+|\s+$/gm,''));
				$("#txt_archivo1").val((rowData.archivo1).replace(/^\s+|\s+$/gm,'') );
				$("#txt_archivo2").val( (rowData.archivo2).replace(/^\s+|\s+$/gm,'') );
				$("#txt_empleado").val( $("#txt_Numemp").val() );
				
				//console.log("Archivos a descargar: ");
				//console.log("Archivo 1: " + $("#txt_archivo1").val());
				//console.log("Archivo 2: " + $("#txt_archivo2").val());
				//console.log("Empleado : " + $("#txt_empleado").val());
				//console.log('importe');
				$("#txt_ImporteActual").val(rowData.importePagar);
				//$("#txt_ImporteActual").val(rowData.importeConcepto);
				fnConsultarBeneficiarios(0);
			} else {
				$("#txt_ciclo").val("");
				$("#txt_archivo1").val("");
				$("#txt_archivo2").val("");
				$("#txt_empleado").val($("#txt_Numemp").val());
				$("#txt_ImporteActual").val("");
			}
		}
		
		return arr_export;
	}
	function SeleccionarDeducible()
	{
		
		//console.log('Seleccionar Deducible');
		var selr="",  grid="", deduccion=0;
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				grid="#gd_Proceso";
			break;
			case 1:
				grid="#gd_AceptadaPorPagar";
			break;
			case 2:
				grid="#gd_Rechazadas";
			break;
			case 3:
				grid="#gd_Aclaracion";
			break;
			case 4:
				grid="#gd_Revision";
			break;
			case 5:
				grid="#gd_NotaCredito";
			break;
			default:
			break;
		}
		
		var lista = jQuery(grid).getDataIDs();
		for(i=0;i<lista.length;i++){
			rowData=jQuery(grid).getRowData(lista[i]);
			if (rowData.marcado.toUpperCase() == 'TRUE') 
			{	
				if(deduccion==0)
				{
					deduccion=rowData.deduccion;
				}
				else
				{
					if(deduccion!=rowData.deduccion && deduccion!=-1)
					{
						deduccion=-1; // escuelas publicas y privadas
					}
				}	
				
			}
		}
		if(deduccion>0)
		{
			$("#cbo_Deduccion").val(deduccion);		
		}
		else
		{
			$("#cbo_Deduccion").val(1);
		}
	}

	function ConsultaClaveHCM(){
		$.ajax({type: "POST", 
			url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
			data: {                 
				'iOpcion': 401
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

function fixeImporte()
{
	var sumaCon = 0.00;
	for(var i = 0; i < $("#gd_ModificarImporteAPagar").find("tr").length - 1; i++) {
			/*if(!$("#" + (i+1) + "_imp_importeF"))
			{*/
				if(cantidadImp[i] != 0 && $('#gd_ModificarImporteAPagar').jqGrid('getCell',(i+1),'imp_importeF') == '000')
				{
					jQuery("#gd_ModificarImporteAPagar").jqGrid('setCell',(i+1),'imp_importeF',cantidadImp[i]);
				}
				if($('#gd_ModificarImporteAPagar').jqGrid('getCell',(i+1),'imp_importeF') == '')
				{
					sumaCon += parseFloat($('#'+(i+1)+'_imp_importeF').val());
				}
				else
				{
					sumaCon += parseFloat($('#gd_ModificarImporteAPagar').jqGrid('getCell',(i+1),'imp_importeF'));
				}
				
			//}
		}
		//if(sumaCon != 0)
			$("#txt_ImporteActual").val(accounting.formatMoney(sumaCon, "",2));

}

var intv = setInterval(fixeImporte,100);

// Petición 39116 
// --- NOTIFICACIONES ---- Función de Ruuuu
function UPD_NotificacionEnAclaracion(iOpcion, iFactura, iEmpleado) {
    $.ajax({type:'POST',
        url:'ajax/json/json_fun_afecta_notificacion_aclaracion.php',
        data:{
            'iOpcion':iOpcion,
            'iFactura':iFactura,
            'iEmpleado':iEmpleado
        }
    });
}



/*ENVIO CORREO PETICIÓN 39116*/
function enviarNotificacionEmpleado(num_empleado){		
	// Realizamos una solicitud AJAX para enviar la notificación.
	$.ajax({
		url: "ajax/proc/proc_envia_notificacion_factura_colaborador.php",
		type: "GET",
		data: {
			'num_empleado' : num_empleado,
		},
		success: function(response) {
			/*let respServicio = JSON.parse(response);
			console.log(`respServicio: ${respServicio.estatus}`);

			//respServicio.mensaje == "Ok" ?  console.log("Se notifico al usuario.") : console.log("Ocurrio un error.");*/

		},
		error: function(xhr, status, error) {
			// Manejamos el error si ocurre al obtener el contenido del archivo HTML
			console.error("Error al obtener el contenido del archivo HTML:", error);
		}
	});
}

function autoGrow(element) { // Establece temporalmente la altura a 5px para obtener el scrollHeight correcto
    if(element.scrollHeight < 100 ){
        element.style.height = "5px"; 
        element.style.height = (element.scrollHeight) + "px";
    }
}