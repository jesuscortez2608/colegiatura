$(function(){
	$.fn.modal.Constructor.prototype.enforceFocus = function () {};
	SessionIs();
	iFactura=0;
	nGrado=0;
	iEscuela=0;
	iTipoComprobante=0; //Indica el tipo de comprobante del Xml que se va a subir 1=Ingreso, 2=Nota de Credito, 3=Pago
	iEscolaridad=0;
	var iCarrera = 0;
	var impConcepto = 0;
	var iEditarB = 0;
	
	//--variables del grid	
	sel_iBeneficiario=0;
	sel_iEscolaridad=0;

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
	
	$("#cbo_Carrera").prop("disabled",true);
	
	$("#txt_beneficiario_ext").val(0);
	$("#lbl_importeFac").text('Importe Factura:');
	$("#lbl_FechaFac").text('Fecha Factura:');
	// Muestre el mensaje en azul de la ayuda, del tooltip
	$('[data-rel=tooltip]').tooltip();
	$('[data-rel=tooltip]').tooltip({
		container : 'body'
	});
	$('[data-rel=popover]').popover({
		container : 'body'
	});
	
	function stopScrolling(callback) {
		$("#dlg_AgregarDetalle").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_AgregarAclaracion").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_AyudaEscuelas").on("show.bs.modal", function () {
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
	//Valida si el empleado esta bloqueado / Limitado
	setTimeout(
		ConsultaEmpleado(function() {
			// $("#btn_Cargar").hide();
			fnEmpleadoBloqueado( function() {
				CargarDatosGenerales(function(){
					fnConsultarDatosFactura(function(){
						CargarEscuelas();
						CargarParentescos(function(){
							fnConsultarDetalles(function(){
								CargarTiposPagos(function(){
									CargarCarreras();
								});
							});
						});						
					});
				});
			});
			// fnConsultarDatosFactura(function() {
				$("#lbl_estatus").text("detalle");
				// fnConsultarDetalles();
				// CargarEscuelas();
			// });
			stopScrolling(function(){
				dragablesModal();
			});
		})
	,0);
	//$( "#cbo_Escuela" ).prop('disabled',true); '<strong class="red"><i class="icon-info-sign red"> </i>Si su factura paga más de un beneficiario deberá capturar el costo por cada uno de los beneficiarios.</strong>'+
	$("#div_msj").html('<i class="icon-ok green"></i>Favor de cargar el '+ 
				'<strong class="green">XML '+
					'<i class="icon-file-text green"></i>'+
				'</strong  > de la factura, para poder mostrar los datos de la escuela. '+ LengStrMSG.idMSG435 );
				
	$("#div_msj").hide();
	var Sueldo=0, iBeneficiario=0, iKeyx=0, iParentescoB=0, iTipoPagoB=0,sPeriodos='', iEscuelaFac=0, 
		nAntiguedad=0,dFechaValida='', idEscuelaVinculada=0, iLimpiar=0, iEscolaridadB=0,iPdf=0,iGradoB=0,
		iCicloB=0,iImporteB=0,iTotalFacturaCargada=0, iMod=0, iDescuentosDiferentes=0,  iRegresa=0;	
		
/*------------------------------------------------------------------------------------------------------------------------	
	C	O	N	S	U	L	T	A 	-	E	M	P	L	E	A	D	O 
------------------------------------------------------------------------------------------------------------------------*/
	function ConsultaEmpleado(callback) {
		$.ajax({type:'POST',
			url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
			data:{'session_name' : Session},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != 0) {
					Sueldo=accounting.unformat(dataJson[0].sueldo);
					$("#txt_SueldoMensual").val(dataJson[0].sueldo);
					$("#txt_TopeProp").val(dataJson[0].topeproporcion);
					nAntiguedad=dataJson[0].antiguedad;
					dFechaValida=formatearFecha2(1,dataJson[0].fec_alta);
					$("#txt_Rfc_Emp").val(dataJson[0].rfc);
				} else {
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
/*------------------------------------------------------------------------------------------------------------------------	
	E	M	P	L	E	A	D	O	- 	B	L	O	Q	U	E	A	D	O
------------------------------------------------------------------------------------------------------------------------*/
	function fnEmpleadoBloqueado(callback)
	{
		// console.log('EMPLEADO BLOQUEADO');
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_consulta_empleado_colegiatura.php?",
			data: { 
					//'iEmpleado':$("#txt_Empleado").val(),
					'session_name': Session
				},
			beforeSend:function(){},
			success:function(data){
				var dataJson=JSON.parse(data);
				
				if(dataJson != null) {
					$("#txt_Limitado").val(0);
					if(dataJson.LIMITADO==1) {
						$("#txt_Limitado").val(1);
						if(dataJson.BLOQUEADO==1) {
							$("#txt_Bloqueado").val(1);
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no puedes subir facturas.'}});
						} else {
							//console.log('entra');
							$("#txt_Bloqueado").val(0);
						}
					} else if(dataJson.BLOQUEADO==1) {
						$("#txt_Bloqueado").val(1);
						loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no puedes subir facturas.'}});
					} else {
						$("#txt_Bloqueado").val(0);
					}
				} else {
					console.log('Antiguo='+nAntiguedad);
					loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'No cuenta con esta prestación.'}});
					$("#txt_Limitado").val(1);
					$("#txt_Bloqueado").val(0);
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});		
	}
/*------------------------------------------------------------------------------------------------------------------------	
	CARGAR DATOS GENERALES
------------------------------------------------------------------------------------------------------------------------*/
	function CargarDatosGenerales(callback) {
		console.log('Carga Datos Generales');
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_calcular_topes_colegiaturas.php?",
			data: { 
				'iSueldo':Sueldo,
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				//console.log('dataJson='+dataJson);
				if(dataJson != 0 ) {
					var ImporteFormato=accounting.formatMoney((Sueldo/2),"", 2);
					$("#txt_TopeMensual").val(ImporteFormato);
					//$("#txt_TopeProp").val(dataJson.topeAnual);
				//	$("#txt_TopeMensual").val(dataJson.topeMensual);
					// console.log($("#txt_SueldoMensual").val());
					//console.log('ImporteFormato='+ImporteFormato);
					ImporteFormato=accounting.formatMoney(dataJson.acumulado, "", 2);
					//console.log('ImporteFormato acumulado='+dataJson.acumulado);
					$("#txt_AcumFactPag").val(ImporteFormato);
					ImporteFormato=accounting.unformat($("#txt_TopeProp").val())-accounting.unformat($("#txt_AcumFactPag").val());
					//console.log('ImporteFormato='+ImporteFormato);
					if($("#txt_Limitado").val()==1) {
						console.log('ImporteFormato='+ImporteFormato);
						if(ImporteFormato<=0) {
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no puedes subir facturas.'}});
						}
					}
					ImporteFormato=accounting.formatMoney(ImporteFormato, "", 2);
					$("#txt_TopeRest").val(ImporteFormato);
				} else {
					//error
					showalert(LengStrMSG.idMSG88+" los datos generales", "", "gritter-error");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});	
	}
				
	//console.log('BLOQUEADO='+$("#txt_Bloqueado").val());
	if(($("#txt_Bloqueado").val()==0)/*&&($("#txt_Limitado").val()==0)*/)
	{
		
		//console.log('BLOQUEADO Y LIMITADO =0');
		fnConsultarParametro(1);
		$("#div_cargando").css('display','block');
		EstructuraGridBeneficiarios();	
		load_cargando(0);
		setTimeout("$('#div_cargando').css('display','none');",1300);
			load_cargando(50);
		
		var Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";	
					
					$("#cbo_Beneficiario").html(Beneficiarios);
					$("#cbo_Beneficiario").val($("#cbo_Beneficiario option").first().val());
					$("#cbo_Parentesco").val($("#cbo_Beneficiario").val());
					if(($("#txt_EditarFactura").val()!=0) && ($("#txt_EditarFactura").val()!= undefined)) {
						$("#pag_title").html('Modificar Factura Escuela '); //Privada
						//ocultar recibo y carta
						$("#nom_xml").hide();
						$("#div_xml").hide();
						$("#btn_Otro").hide();
						iRegresa=1;
						
						$('#txt_id_Escuela').val( $("#txt_EditarIduEscuela").val() );
						$('#txt_RFC').val( $("#txt_EditarRfcEscuela").val() );
						$("#txt_Escuela").val( $("#txt_EditarNombreEscuela").val() );
						$("#lbl_estatus").text($("#txt_EditarFactura").val());
					}
					load_cargando(95);
					
				
		//CargarTiposPagos();	
		//CargarCiclosEscolares();
		fnConsultarMotivosAclaracion();
		load_cargando(100);
		$("html, body").animate({ scrollTop: 0 }, "fast");
		$("#div_cargando").css('display','block');
	}
	
	$("#cbo_Periodo").chosen({width:'250px', height:'70px', resize:'none'});
	$("ul.chosen-choices").css({'overflow': 'auto', 'max-height': '70px'});	
	
	$("#txt_FechaCap").val($("#txt_Fecha").val());
/*------------------------------------------------------------------------------------------------------------------------	
	C	O	N	S	U	L	T	A	R 	-	P	A	R	A	M	E	T	R	O
------------------------------------------------------------------------------------------------------------------------*/
	function fnConsultarParametro(iOpcion)
	{
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parametros_colegiaturas.php",
			data: { 
				//session_name:Session,
				'nom_parametro':'PERMITIR_DESCUENTOS_DIFERENTES' //iOpcion
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0) {
					//iDescuentosDiferentes=dataJson.respuesta;
					iDescuentosDiferentes=dataJson.valor_parametro;
				} else {
					//message("Ocurrio un problema al consultar la configuración");
					showalert("Ocurrio un problema al consultar la configuración", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}	
	
/*------------------------------------------------------------------------------------------------------------------------	
	C	O	N	S	U	L	T	A	R 	-	M	O	T	I	V	O	S 	-	A	C	L	A	R	A	C	I	O	N
------------------------------------------------------------------------------------------------------------------------*/	
	function fnConsultarMotivosAclaracion() {
		console.log('motivos aclaracion');
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_motivos_combo.php",
			data: { 'iOpcion':2 },
			beforeSend:function(){},
			success:function(data){
				option = option + "<option value='0'>SELECCIONE</option>";
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);
				if (dataJson.estado==0) {
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}


					$("#cbo_Aclaracion").trigger("chosen:updated").html(option);
					$("#cbo_Aclaracion").trigger("chosen:updated");
				} else {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" las aclaraciones", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}
	
/*------------------------------------------------------------------------------------------------------------------------	
	X	M	L
------------------------------------------------------------------------------------------------------------------------*/
	$('#fileXml').ace_file_input({
		no_file:'XML...',
		btn_choose:'Examinar',
		btn_change:'Cambiar',
		droppable:false,
		thumbnail:false, 
		whitelist:'xml',
		blacklist:'exe|php|gif|png|jpg|jpeg'
	});	
	
	//--CHANGE XML
	$("#fileXml").change(function(event){		
		validarXml(function(){
			if($("#txt_RFC").val()!='')
				
				CargarEscuelas();
		});
		event.preventDefault();
	});
	
	//--XML	
	function validarXml(callback) {
		console.log('Validar XML');
		var sExt = ($('#fileXml').val().substring($('#fileXml').val().lastIndexOf("."))).toLowerCase();
		$("#txt_ImporFact").val();
		$("#txt_RFC").val();
		$("#txt_FechaCap").val();
		$("#txt_Folio").val();
		if(sExt != '.xml') {
			$( '#fileXml' ).ace_file_input('reset_input');
			//message('El archivo seleccionado no es un xml, favor de verificar');
			showalert(LengStrMSG.idMSG390, "", "gritter-info");
			return; 
		}
		var opciones= {
			beforeSubmit: function(){
				//	alert('antes de subir');
				//console.log('antes de subir');
			}, 
			uploadProgress: function(){
				//console.log('subiendo');
			},
			success: function(data) {
				var dataJson = JSON.parse(data);
				//if (dataJson[0].resultado > 0)
					//console.log('resultado='+dataJson[0].resultado);
				if (dataJson[0].resultado != 0) {
					//message(dataJson[0].json.mensaje);
					console.log(dataJson[0].json.mensaje);
					if(dataJson[0].resultado==-1) {
						showalert(dataJson[0].mensaje, "", "gritter-warning");
					} else {
						showalert(dataJson[0].json.mensaje, "", "gritter-info");
											
					}
					Limpiar();
				} else {
					//console.log('n_comprobante='+dataJson[0].json.n_comprobante);
					iTipoComprobante=dataJson[0].json.n_comprobante;
					if (iTipoComprobante==2) {
						//showalert("Es nota de credito", "", "gritter-info");
						$("#lbl_importeFac").text('Importe nota de crédito:');
						$("#lbl_FechaFac").text('Fecha nota de crédito:');
						$("#txt_Tolal").val(accounting.formatMoney(dataJson[0].json.importe_total, "", 2));
						$("#btn_Agregar").prop("disabled",true);						
					} else {
						$("#lbl_importeFac").text('Importe Factura:');
						$("#lbl_FechaFac").text('Fecha Factura:');
						$("#txt_Tolal").val('');
						$("#btn_Agregar").prop("disabled",false);	
						
					}
					$("#txt_ImporFact").val(accounting.formatMoney(dataJson[0].json.importe_total, "", 2));
					$("#txt_RFC").val(dataJson[0].json.rfc_emisor);
					$("#txt_FechaCap").val(dataJson[0].json.fecha);
					$("#txt_Folio").val(dataJson[0].json.folio_fiscal);
					$("#txt_tipo_comprobante").val(dataJson[0].json.n_comprobante);
					
				//	$("#txt_FechaCap").val(dataJson[0].json.importes[0].value);
					var fechafactura=formatearFecha($('#txt_FechaCap').val());
					if (fechafactura < $("#txt_Anio").val()) {
						//showmessage('La fecha de expedición de la factura debe ser del año en curso', '', undefined, undefined, function onclose(){
						//	Limpiar();
						//});
						showalert(LengStrMSG.idMSG397, "", "gritter-warning");
						Limpiar();
					} else {
						var fechaA=formatearFecha2(0,$("#txt_FechaCap").val());
						//CompararFechaFactura(fechaA);
						
						var option='';
						for(var i=0;i<dataJson[0].json.importes.length; i++) {
							option = option + "<option value='" + dataJson[0].json.importes[i].value + "'>" + dataJson[0].json.importes[i].value + "</option>";
						}
						// $("#cbo_Importes").html(option);
						// $("#cbo_Importes").trigger("chosen:updated");
					}
				}
				callback();
			}
		};
		$( '#session_name1' ).val(Session);
		$( '#xmlupload' ).attr("action", "ajax/json/json_leer_Rfc_XML.php") ;
		$( '#xmlupload' ).ajaxForm(opciones);
		$( '#xmlupload' ).submit();
	}
	
/*------------------------------------------------------------------------------------------------------------------------	
	P	D	F
------------------------------------------------------------------------------------------------------------------------*/
	$('#filePdf').ace_file_input({
		no_file:'PDF...',
		btn_choose:'Examinar',
		btn_change:'Cambiar',
		droppable:false,
		onchange:null,
		thumbnail:false 
	});	
	
	$("#filePdf").change(function(event){
		var sExt = ($('#filePdf').val().substring($('#filePdf').val().lastIndexOf("."))).toLowerCase();
		if((sExt != '.pdf') && (sExt != '.jpg') && (sExt != '.png') &&  (sExt != '.jpeg') &&  (sExt != '.bmp'))
		{
			$( '#filePdf' ).ace_file_input('reset_input');
			$( '#filePdf' ).focus();
			showalert(LengStrMSG.idMSG389, "", "gritter-info");
			return;
		}
		event.preventDefault();
	});
/*------------------------------------------------------------------------------------------------------------------------	
	E	S	C	U	E	L	A	S
------------------------------------------------------------------------------------------------------------------------*/
	function CargarEscuelas(){
		//var Factura = $("#txt_EditarFactura").val();
		var Factura = DOMPurify.sanitize($("#txt_EditarFactura").val());
		console.log("CargarEscuelas");
		var Escuela="";
		$("#cbo_Escuela").html("");
		$.ajax({type: "POST",
			// url: "ajax/json/json_fun_consultar_escuela_rfc.php?",
			url: "ajax/json/json_fun_consultar_escuela.php?",
			data: { 
				session_name:Session,
				'idFactura' : Factura,
				'iOpcion' : 1
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = json_decode(sanitizedData);
				
				var bloqueda=0;
				if(dataJson.estado == 0){
					var Escuela = '';
					for(var i = 0; i < dataJson.datos.length; i++){
						Escuela = Escuela + "<option value='" + dataJson.datos[i].idEscuela + "'>" + dataJson.datos[i].nomEscuela + "</option>";
					}

					$("#cbo_Escuela").html(Escuela);
					$("#cbo_Escuela").val($("#cbo_Escuela option").first().val());
					$("#cbo_Escuela").trigger("chosen:updated");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	//--COMBO ESCUELA CHANGE
	$("#cbo_Escuela").change(function(event){
		//ChangeEscuela();
		iPdf=$("#cbo_Escuela").children(":selected").attr("pdf");
				
		if (iTipoComprobante==2){ //Si es nota de credito
			fnGuaradarFactura();
		} else {
			if($("#cbo_Escuela").val()!=0) {
				//$("#div_escuelaPri").html(' ESCUELA: <b>'+$("#cbo_Escuela option:selected").text()+'</b>');
				escuela = $("#cbo_Escuela option:selected").text();
				$("#div_escuelaPri").text(escuela);
				$("#txt_id_Escuela").val($("#cbo_Escuela").val());
			}
		}
		event.preventDefault();
	});
/*---------------------------------------------------------------------------------------------------------------------------
	B	O	T	O	N  	-	A	G	R	E	G	A	R
----------------------------------------------------------------------------------------------------------------------------*/
//--BOTON AGREGAR
	$('#btn_Agregar').click(function(event) {
		iKeyx=0;
		
		//btn_Agregar
		$("#cbo_Beneficiario").prop('disabled',false);
		sel_iBeneficiario=0;
		sel_iEscolaridad=0;
			
		if(($("#txt_EditarFactura").val()!=0) && ($("#txt_EditarFactura").val()!= undefined)) {
			$("#tit_modal_beneficiario_eprv").html("<i class=\"icon-file-text-alt\"></i>&nbsp;Agregar Beneficiario");
			$("#btn_AgregarB").html("<i class=\"icon-plus bigger-110\"></i>Agregar</button>");
			if($("#cbo_Escuela").val() == 0){
				showalert(LengStrMSG.idMSG399, "", "gritter-info");
			} else {
				RevisarEscuelaConfigurada();
			}
		} else {
			if($("#fileXml").val()=="") {
				showalert(LengStrMSG.idMSG398, "", "gritter-info");
			} else if($("#cbo_Escuela").val()==0) {
				showalert(LengStrMSG.idMSG399, "", "gritter-info");
			} else {
				// Cambiar los títulos de la ventana modal
				$("#tit_modal_beneficiario_eprv").html("<i class=\"icon-file-text-alt\"></i>&nbsp;Agregar Beneficiario");
				$("#btn_AgregarB").html("<i class=\"icon-plus bigger-110\"></i>Agregar</button>");
				$("#txt_importe_compara").val($("#txt_ImporFact").val());
				RevisarEscuelaConfigurada();				
			}
		}
		event.preventDefault();	
	});

//--REVISAR ESCUELA CONFIGURADA
	function RevisarEscuelaConfigurada() {
		//$("#cbo_Beneficiario").html("");
		console.log('Revisar Escuela Configurada');
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_beneficiario_empleado_rfc.php",
			data: { 				
				session_name:Session,
				iopcion: 1,
				crfc: $("#txt_RFC").val()	
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				
				if(dataJson.datos[0] == 'undefined') {
					showalert("Favor de configurar tus beneficiarios para esta escuela", "", "gritter-warning");
				} else {
					if(dataJson.estado == 0) {
						if (dataJson.datos.length==0) {
							showalert("Favor de configurar tus beneficiarios para esta escuela", "", "gritter-warning");
						} else {
							iEscuela=dataJson.datos[0].value;
							//--cargar beneficiarios
							iBeneficiario=0;
							iEscolaridadB=0;
							iGradoB=0;
							iCicloB=0;
							CargarBeneficiariosCapturados(function(){
								CargarEscolaridades();
							});
							
							//CargarBeneficiariosCapturados(function(){
								CargarParentescos(function(){
									CargarTiposPagos(function(){

									});	
									//$("#txt_importe_compara").val($("#txt_ImporFact").val());
									imp_cadena=$("#txt_ImporFact").val();
									importe_factura=imp_cadena.replace(",", "");
									importe_factura=importe_factura*100;						
									$("#txt_importe_compara").val(importe_factura);
									console.log('importe factura-----------------'+importe_factura);
									$('#dlg_AgregarDetalle').modal('show');
									$("#cbo_Beneficiario").focus();
								});
							//});
						}					
					} else {
						showalert("Favor de configurar tus beneficiarios para esta escuela", "", "gritter-warning");
					}				
				}
			},
			error:function onError(){/*callbackB();*/},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	};
	
/*---------------------------------------------------------------------------------------------------------------------------
	G	R	I	D	- 	B	E	N	E	F	I	C	I	A	R	I	O	S 
----------------------------------------------------------------------------------------------------------------------------*/	
	//--GRID BENEFICIARIOS
	function EstructuraGridBeneficiarios(){
		jQuery("#grid_Beneficiarios").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG8,
				colModel:[
				{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:90, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:90, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:269, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_parentesco',		index:'idu_parentesco', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_parentesco',		index:'nom_parentesco', 	width:120, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_tipo_pago',		index:'idu_tipo_pago', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'des_tipo_pago',		index:'des_tipo_pago', 		width:120, 	sortable: false,	align:"left",	fixed: true},
				{name:'nom_periodo',		index:'nom_periodo', 		width:150, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:180, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:153, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_grado',			index:'idu_grado', 			width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_grado',			index:'nom_grado', 			width:200, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_ciclo',			index:'idu_ciclo', 			width:220, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_ciclo_escolar',	index:'nom_ciclo_escolar', 	width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_carrera',		index:'idu_carrera', 		width:10, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_carrera',		index:'nom_carrera', 		width:220, 	sortable: false,	align:"left",	fixed: true},
				{name:'imp_importe',		index:'imp_importe', 		width:80, 	sortable: false,	align:"right",	fixed: true, hidden: true},
				{name:'imp_importeF',		index:'imp_importeF', 		width:80, 	sortable: false,	align:"right",	fixed: true},
				{name:'keyx',				index:'keyx', 				width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true}
				],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: null,
			shrinkToFit: false,
			height: 200,
			//----------------------------------------------------------------------------------------------------------
			caption: 'Beneficiarios',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			
			loadComplete: function (Data) {
				// console.log(Data);
				// return;
				var grid = $('#grid_Beneficiarios');
				// iTotalFacturaCargada = grid.jqGrid('getCol', 'imp_importe', false, 'sum');
				iTotalFacturaCargada = accounting.formatMoney(Data.totalFactura, "", 2);
				// iTotalFacturaCargada = accounting.formatMoney(iTotalFacturaCargada,"",2);
				console.log("TOTAL DE FACTURA POR BENEFICIARIOS = "+iTotalFacturaCargada);
				$("#txt_Tolal").val(accounting.formatMoney(iTotalFacturaCargada, "", 2));				
			},
			onSelectRow: function(id) {
				if(id >= 0){
				
					var fila = jQuery("#grid_Beneficiarios").getRowData(id); 
					iBeneficiario=fila['idu_beneficiario'];
					iKeyx = fila['keyx'];
					iParentescoB=fila['idu_parentesco'];
					iTipoPagoB=fila['idu_tipo_pago'];
					//iEscolaridad=fila['idu_tipo_pago'];
					
					sPeriodos=fila['nom_periodo'];
					iEscolaridadB=fila['idu_escolaridad'];
					iGradoB=fila['idu_grado'];
					iCicloB=fila['idu_ciclo'];
					iImporteB=fila['imp_importe'];
					iCarrera = fila['idu_carrera'];
					impConcepto = fila['imp_importeF'];
					
					sel_iBeneficiario=fila['idu_beneficiario'];
					sel_iEscolaridad=fila['idu_escolaridad'];
					console.log(fila['idu_escolaridad']);
					console.log('GRADO = '+iGradoB);
				} else {
					iKeyx=0;
					iParentescoB=0;
					iTipoPagoB=0;
					sPeriodos='';
					iEscolaridadB=0;
					iGradoB=0;
					iCicloB=0;
					iImporteB=0;
					iCarrera = 0;
					impConcepto = 0;
					
					sel_iBeneficiario=0;
					sel_iEscolaridad=0;
				}
			}				
		});
	}
	
	//--CONSULTAR DETALLES	
	function fnConsultarDetalles(callback) {
		
		console.log('Consultar Detalles');
		iFactura=$("#txt_ifactura").val();
		if (iFactura==''){
			iFactura=0;
		}		
		console.log('ajax/json/json_fun_obtener_stmp_facturas_colegiaturas.php?cFolio='+$("#txt_Folio").val()+'&iFactura=' +iFactura+'&session_name=' +Session);
		$("#grid_Beneficiarios").jqGrid('clearGridData');
		$("#grid_Beneficiarios").jqGrid('setGridParam',
		{ url: 'ajax/json/json_fun_obtener_stmp_facturas_colegiaturas.php?cFolio='+$("#txt_Folio").val()+'&iFactura=' +iFactura+'&session_name=' +Session}).trigger("reloadGrid"); 
				
		// callback();
		iKeyx = 0, iMod = 0, iBeneficiario = 0, iParentescoB = 0, iTipoPagoB = 0, sPeriodos = '', iEscolaridadB = 0, iGradoB = 0, iCicloB = 0, iImporteB = 0, iCarrera = 0;
	}
	
/*---------------------------------------------------------------------------------------------------------------------------
	B	O	T	O	N  	-	E	D	I	T	A	R
----------------------------------------------------------------------------------------------------------------------------*/
	$('#btn_Editar').click(function(event){
		iEditarB = 1;
		console.log('Click boton Editar');
		
		esc=$("#cbo_Escuela").val();
		console.log('esc='+esc);
		if (esc==0 || esc==null) {
			showalert("Favor de seleccionar escuela", "", "gritter-info");
			return;
		}
		if ( ($("#grid_Beneficiarios").find("tr").length - 1) == 0 ) {
			showalert("No existen registros para editar", "", "gritter-info");
		} else if ( iKeyx == 0 ) { // no se a seleccionado el registro
			showalert("Seleccione el registro para editar", "", "gritter-info");
		} else { //Editar
			// Cambiar los títulos de la ventana modal
			$("#tit_modal_beneficiario_eprv").html("<i class=\"icon-file-text-alt\"></i>&nbsp;Modificar Beneficiario");
			$("#btn_AgregarB").html("<i class=\"icon-save bigger-110\"></i>Guardar</button>");
			console.log("KEYXBENEFICIARIO = "+iKeyx);
			iMod=iKeyx;
			//iKeyx
			// $("#cbo_Beneficiario").val(iBeneficiario);
			// $("#cbo_Parentesco").val(iParentescoB);
			// $("#cbo_Escolaridad").val(iEscolaridadB);
			
			// $("#cbo_TipoPago").val(iTipoPagoB);			
			// $("#cbo_CicloEscolar").val(iCicloB);
			// $("#cbo_Grado").val(iGradoB);
			// $("#cbo_Carrera").val(iCarrera);
			
			
			//------------------------------------------------
			CargarBeneficiariosCapturados(function(){
				CargarEscolaridades();
			});
			
			//CargarGrados();
			
			
			// console.log('iEscolaridadB='+iEscolaridadB);
			//$("#cbo_Beneficiario").val(iBeneficiario);
			//$("#cbo_Parentesco").val(iParentescoB);
			//$("#cbo_Escolaridad").val(iEscolaridadB);
			
			
			// $("#cbo_TipoPago").val(iTipoPagoB);			
			//$("#cbo_CicloEscolar").val(iCicloB);
			// $("#cbo_Grado").val(iGradoB);
			
			$("#txt_importe_compara").val($("#txt_ImporFact").val());
			CargarParentescos(function(){
				CargarTiposPagos(function(){
					CargarPeriodos();
				});
			});
			$("#txt_importeConcep").val(impConcepto);
			setTimeout(
				MostrarModal()
			, 2000);
			// $('#dlg_AgregarDetalle').modal('show');
		}
		event.preventDefault();	
	});	
	function MostrarModal(){
		$('#dlg_AgregarDetalle').modal('show');
	}
/*---------------------------------------------------------------------------------------------------------------------------
	B	O	T	O	N  	-		E	L	I	M	I	N	A	R
----------------------------------------------------------------------------------------------------------------------------*/
	$('#btn_Eliminar').click(function(event){
		if ( ($("#grid_Beneficiarios").find("tr").length - 1) == 0 ) {
			showalert("No existen registros para eliminar", "", "gritter-info");
		}
		else if ( iKeyx == 0 ) {// no se a seleccionado el registro
			showalert("Seleccione el registro para eliminar", "", "gritter-info");
		} else { //Elimina
		
			$("#btn_Eliminar").prop('disabled', true);
			bootbox.confirm('¿Desea eliminar el registro?', 
			function(result){
				$("#btn_Eliminar").prop('disabled', false);
				if (result){
					$.ajax({type: "POST",
					url: "ajax/json/json_fun_eliminar_stmp_detalle_factura_colegiatura.php?",
						data: 
						{ 
							session_name:Session,
							'iKeyx':iKeyx
						},
						beforeSend:function(){},
						success:function(data){				
							var dataJson = JSON.parse(data);	
							if(dataJson.estado==1){
								//Se eliminó el beneficiario de la factura
								showalert(dataJson.mensaje, "", "gritter-info");
								// showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){
									fnConsultarDetalles();
								// });
							}
							else{
								// showmessage('Ocurrio un problema al eliminar el beneficiario', '', undefined, undefined, function onclose(){});
								showalert("Ocurrio un problema al eliminar el beneficiario", "", "gritter-error");
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
	
/*---------------------------------------------------------------------------------------------------------------------------
	D	I	A	L	O	G
----------------------------------------------------------------------------------------------------------------------------*/
	//--ABRIR DIALOG
	$('#dlg_AgregarDetalle').on('show.bs.modal', function (event) {
		//$("#div_escuelaPri").html(' ESCUELA: <b>'+$("#cbo_Escuela option:selected").text()+'</b>');
		escuelaPri = $("#cbo_Escuela option:selected").text();
		$("#div_escuelaPri").text(escuelaPri);
		// console.log('Abre al modal');
		// console.log('VALOR CARRERA ='+$("#cbo_Escolaridad").children(":selected").attr("opc_carrera"));
		if($("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1){
			$("#cbo_Carrera").prop('disabled', false);
			$("#cbo_Carrera").val(iCarrera);
		} else {
			Carrera = "";
			Carrera="<option value='0'>SELECCIONE</option>";
			$("#cbo_Carrera").html(Carrera);
			$("#cbo_Carrera").prop('disabled', true);
		}

		if($("#txt_ifactura").val()==0) {
			fnGuaradarFactura();
		}
		console.log("TIPO PAGO= "+$("#cbo_TipoPago").val());
		if ( $("#cbo_TipoPago").val() == "1" ) {
			$("#cbo_Periodo").val("1");
			$("#cbo_Periodo").trigger("chosen:updated");
		} else if ( $("#cbo_TipoPago").val() == "8" ) {
			$("#cbo_Periodo").val("1");
			$("#cbo_Periodo").trigger("chosen:updated");
		}
	});
	
	//--CERRAR DIALOG
	$('#dlg_AgregarDetalle').on('hide.bs.modal', function (event) {
		iEditarB = 0;
		//console.log("Cerrar dlg");
		$("#cbo_Beneficiario").val(0);
		$("#cbo_Parentesco").val(0);
		$("#cbo_TipoPago").val(0);
		$("#cbo_Periodo").html("");
		$("#cbo_Periodo").trigger("chosen:updated");
		$("#cbo_Escolaridad").val(0);
		$("#cbo_Grado").val(-1);
		$("#cbo_Carrera").val(0);
		$("#cbo_Carrera").trigger('chosen:updated');
		$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar option").first().val());
		$("#txt_importeConcep").val('');
		
		fnConsultarDetalles();
	});
	
	//--
	$('#dlg_AyudaEscuelas').on('show.bs.modal', function (event) {
		$("#cbo_Estado").val($("#cbo_Estado option").first().val());
		$("#cbo_Ciudad").val($("#cbo_Ciudad option").first().val());
		$("#cbo_TipoConsulta").val($("#cbo_TipoConsulta option").first().val());
		$("#txt_NombreBusqueda").val("");
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		
	});
	//--
	$('#dlg_AyudaEscuelas').on('hide.bs.modal', function (event) {
		if(idEscuelaVinculada==0 && iLimpiar==0) {
			Limpiar();
		}
	});
	
/**	
----------------------------------------------------------------------------------------------------------------------------------------------------------
	//--A	G	R	E	G	A	R	/	M	O	D	I	F	I	C	A	R 	-	B	E	N	E	F	I	C	I	A	R	I	O	
----------------------------------------------------------------------------------------------------------------------------------------------------------
*/	
	/*---------------------------------------------------------------------------------------------------------------------------	
		B	E	N	E	F	I	C	I	A	R	I	O	S 	-	C	A	P	T	U	R	A	D	O	S		
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarBeneficiariosCapturados(callbackB) {
		console.log('CARGA BENEFICIARIOS CAPTURADOS');
		$("#cbo_Beneficiario").html("");
		$.ajax({type: "POST", 
			//url: "ajax/json/json_fun_obtener_parentescos.php?",
			//url: "ajax/json/json_fun_obtener_beneficiarios_por_escuela.php?",
			url: "ajax/json/json_fun_obtener_datos_por_escuela_empleado.php?",
			data: { 
				session_name:Session,
				'iopcion': 1,
				//'crfc': $("#txt_RFC").val(),
				'crfc': DOMPurify.sanitize($("#txt_RFC").val()),
				'ibeneficiario':0,
				'itipobeneficiario':0
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0) {
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++) {
						//option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre +  "</option>";												
						//option = option + "<option parentesco='"+ dataJson.datos[i].parentesco + "' escolaridad='" + dataJson.datos[i].escolaridad + "' grado='" + dataJson.datos[i].grado + "' carrera='" + dataJson.datos[i].carrera + "' value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 	
						option = option + "<option parentesco='"+ dataJson.datos[i].ivalor + "'  value='" + dataJson.datos[i].value + "'  tipo='" + dataJson.datos[i].tipo + "'>" + dataJson.datos[i].nombre + "</option>"; 	
					}
					$("#cbo_Beneficiario").html(option);
					//$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario option").first().val());
					if (iBeneficiario>0) {
						$("#cbo_Beneficiario").val(iBeneficiario);
					} else {
						$("#cbo_Beneficiario" ).val($("#cbo_Beneficiario option").first().val());
					}
					$("#cbo_Beneficiario").trigger("chosen:updated");
					CargarParentescos(function(){
						console.log('');
					});
				} else {
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){callback();});
					showalert(LengStrMSG.idMSG88+" los beneficiarios", "", "gritter-error");
				}
			},
			error:function onError(){callbackB();},
			complete:function(){callbackB();},
			timeout: function(){callbackB();},
			abort: function(){callbackB();}
		});		
	}	
	
	//--BENEFICIARIO
	$("#cbo_Beneficiario").change(function(){
		if ( iEditarB > 0 ){
			iKeyx=0;
			iBeneficiario = 0;
			iParentescoB=0;
			iTipoPagoB=0;
			sPeriodos='';
			iEscolaridadB=0;
			iGradoB=0;
			iCicloB=0;
			iImporteB=0;
			iCarrera = 0;
			impConcepto = 0;
			
			sel_iBeneficiario=0;
			sel_iEscolaridad=0;
			
			CargarEscolaridades();	
			
			var nParentesco=$("#cbo_Beneficiario").children(":selected").attr("parentesco");
			var nEscolaridad=$("#cbo_Beneficiario").children(":selected").attr("escolaridad");
			var nCarrera=$("#cbo_Beneficiario").children(":selected").attr("carrera");
			var option = "<option value='0'>SELECCIONE</option>";
			
			nGrado=$("#cbo_Beneficiario").children(":selected").attr("grado");
			
			$("#cbo_Parentesco").val(nParentesco);
			$("#cbo_Periodo").html("");
			$("#cbo_Periodo").trigger("chosen:updated");
			
			// $("#cbo_Escolaridad").html( $("#cbo_Escolaridad") );
			$("#cbo_Escolaridad").val(0);
			$("#cbo_Escolaridad").trigger("chosen:updated");
			
			$("#cbo_TipoPago").val(0);
			$("#cbo_TipoPago").trigger("chosen:updated");
			
			if ( $("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1 ){
				// $("#cbo_Carrera").val(nCarrera);
				$("#cbo_Carrera").trigger("chosen:updated");
				$("#cbo_Carrera").prop('disabled', false);
			} else {
				
				$("#cbo_Carrera").html(option);
				$("#cbo_Carrera").val(0);
				$("#cbo_Carrera").trigger("chosen:updated");
				$("#cbo_Carrera").prop('disabled', true);			
			}
		} else {
			var nParentesco=$("#cbo_Beneficiario").children(":selected").attr("parentesco");
			var nEscolaridad=$("#cbo_Beneficiario").children(":selected").attr("escolaridad");
			var nCarrera=$("#cbo_Beneficiario").children(":selected").attr("carrera");
			var option = "<option value='0'>SELECCIONE</option>";
			
			nGrado=$("#cbo_Beneficiario").children(":selected").attr("grado");
			//console.log(nCarrera);
			$("#cbo_Parentesco").val(nParentesco);
			$("#cbo_Periodo").html("");
			$("#cbo_Periodo").trigger("chosen:updated");
			
			
			$("#cbo_Escolaridad").val(0);
			$("#cbo_Escolaridad").trigger("chosen:updated");
			
			
			$("#cbo_TipoPago").val(0);
			$("#cbo_TipoPago").trigger("chosen:updated");
			
			$("#cbo_Grado").val(-1);
			grado = $("#cbo_Grado option").first().val();
			$("#cbo_Grado").text(grado);
			$("#cbo_Grado").trigger("chosen:updated");
		
			if ( $("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1 ){
				// $("#cbo_Carrera").val(nCarrera);
				$("#cbo_Carrera").trigger("chosen:updated");
				$("#cbo_Carrera").prop('disabled', false);
			} else {
				
				$("#cbo_Carrera").html(option);
				$("#cbo_Carrera").val(0);
				$("#cbo_Carrera").trigger("chosen:updated");
				$("#cbo_Carrera").prop('disabled', true);			
			}
			CargarEscolaridades();	
		}
	});
	
	/*---------------------------------------------------------------------------------------------------------------------------	
		C	A	R	G	A	R 	-	E	S	C	O	L	A	R	I	D	A	D	E	S
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarEscolaridades() {
		console.log('-----carga escolaridades------');
		$("#cbo_Escolaridad").html("");
		$.ajax({type: "POST",			
			url: "ajax/json/json_fun_obtener_datos_por_escuela_empleado.php?",
			data: {
				'session_name':Session,
				'iopcion': 2,
				/*'crfc': $("#txt_RFC").val(),
				'ibeneficiario':$("#cbo_Beneficiario").children(":selected").attr("value"),
				'itipobeneficiario':$("#cbo_Beneficiario").children(":selected").attr("tipo"),*/
				'crfc': DOMPurify.sanitize($("#txt_RFC").val()),
				'ibeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("value")),
				'itipobeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("tipo")),
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					if ( iEditarB > 0 ) {
						var option = "<option opc_carrera='0' value='0'>SELECCIONE</option>";
					} else {
						var option = "";
					}
					for(var i=0;i<dataJson.datos.length; i++) {
						//option = option + "<option opc_carrera='" + dataJson.datos[i].tipo + "' value='" + dataJson.datos[i].idu_escolaridad + "' id_escuela='" + dataJson.datos[i].ivalor + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
						// option = option + "<option id_escuela='"+ dataJson.datos[i].ivalor + "'  escolaridad='" + dataJson.datos[i].value + "'  opc_carrera='" + dataJson.datos[i].tipo + "'>" + dataJson.datos[i].nombre + "</option>"; 	
						//option = option + "<option id_escuela='"+ dataJson.datos[i].ivalor + "'  escolaridad='" + dataJson.datos[i].value + "'  value='" + dataJson.datos[i].value + "' opc_carrera='" + dataJson.datos[i].tipo + "'>" + dataJson.datos[i].nombre + "</option>"; 	
						option = option + "<option id_escuela='"+ dataJson.datos[i].ivalor + "'  escolaridad='" + dataJson.datos[i].value + "'  value='" + dataJson.datos[i].value + "' opc_carrera='" + dataJson.datos[i].tipo + "' bloqueado='" + dataJson.datos[i].bloqueado + "'>" + dataJson.datos[i].nombre + "</option>"; 	
					}
					
					//console.log('Modificar escolaridad='+sel_iEscolaridad);
					//var nEscolaridad=$( "#cbo_Beneficiario option:selected" ).attr("escolaridad");
					$("#cbo_Escolaridad").html(option);	
					if ( iEscolaridadB > 0 ) {
						$("#cbo_Escolaridad").val(iEscolaridadB);
						if ( $("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1 ) {
							$("#cbo_Carrera").prop('disabled', false);
							CargarCarreras();
						}
					} else {
						$("#cbo_Escolaridad" ).val($("#cbo_Escolaridad option").first().val());
						if ( $("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1) {
							$("#cbo_Carrera").prop('disabled', false);
							CargarCarreras();
						}
					}	
					$("#cbo_Escolaridad").trigger("chosen:updated");
					CargarGrados();
					CargarCiclosEscolares();
				}
				else
				{					
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	
	//CHANGE ESCOLARIDAD
	$("#cbo_Escolaridad").change(function(event){
		console.log('opc_carrera='+$("#cbo_Escolaridad").children(":selected").attr("opc_carrera"));
		//console.log('escolaridad='+$("#cbo_Escolaridad").children(":selected").attr("escolaridad"));
		if($("#cbo_Escolaridad").children(":selected").attr("bloqueado") == 1) {
			showalert("La escuela se encuentra bloqueada", "", "gritter-warning");
			$("#btn_AgregarB").prop("disabled", true);
			return;
		} else {
			$("#btn_AgregarB").prop("disabled", false);
		}				
		if ($("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1) {
			CargarCarreras();
			$("#cbo_Carrera").prop("disabled",false);
			console.log('Si se cargan las carreras en el change');
		} else {
			$("#cbo_Carrera").prop("disabled",true);
			
			carrera="<option value='0' >SELECCIONE </option>";
			$("#cbo_Carrera").html(carrera);
			$("#cbo_Carrera").val($("#cbo_Carrera option").first().val());
			$("#cbo_Carrera").trigger("chosen:updated");
			// iCarrera=0;	
			console.log('No se cargan las carreras en el change');
		}
		if( $("#cbo_Escolaridad").children(":selected").attr("escolaridad") == 1 ) {
			iGradoB = 0;			
		}// else {
			//iGradoB = $("#cbo_Escolaridad").children(":selected").attr('escolaridad');
		//}
		CargarGrados();
		CargarCiclosEscolares();
		event.preventDefault();
	});
	
	/*---------------------------------------------------------------------------------------------------------------------------	
		C	I	C	L	O	S 	-	E	S	C	O	L	A	R	E	S
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarCiclosEscolares(){
		console.log('cargar ciclos escolares');
		$("#cbo_CicloEscolar").html("");
		$.ajax({type: "POST",
			//url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			//url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			url: "ajax/json/json_fun_obtener_datos_por_escuela_empleado.php?",
			data: {
				'session_name':Session,
				'iopcion': 5,
				/*'crfc': $("#txt_RFC").val(),
				'ibeneficiario':$("#cbo_Beneficiario").children(":selected").attr("value"),
				'itipobeneficiario':$("#cbo_Beneficiario").children(":selected").attr("tipo"),*/
				'crfc': DOMPurify.sanitize($("#txt_RFC").val()),
				'ibeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("value")),
				'itipobeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("tipo")),
				'iescolaridad':0 //$("#cbo_Escolaridad").children(":selected").attr("escolaridad")
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					if ( iEditarB > 0 ) {
						var option = "<option value='0'>SELECCIONE</option>";
					} else {
						var option = "";
					}
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 	
					}					
					$("#cbo_CicloEscolar").html(option);
					if ( iCicloB > 0 ) {
						$("#cbo_CicloEscolar").val(iCicloB);
					} else {
						$("#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar option").first().val());
					}
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				} else {
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	/*---------------------------------------------------------------------------------------------------------------------------	
		C	O	M	B	O	- 	T	I	P	O 	-	P	A	G	O		
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarTiposPagos(callback){
		console.log('cargar tipos pagos');
		$("#cbo_TipoPago").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_pagos.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
			
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_TipoPago").html(option);
					if ( iTipoPagoB > 0 ) {
						$("#cbo_TipoPago").val(iTipoPagoB);
					} else {
						$("#cbo_TipoPago" ).val($("#cbo_TipoPago option").first().val());
					}	
					$("#cbo_TipoPago").trigger("chosen:updated");
				} else if(dataJson.estado == 0) {
					//message(LengStr.idMSG11);
					// showalert(LengStr.idMSG11, "", "gritter-warning");
					$("#cbo_TipoPago").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					$("#cbo_TipoPago").trigger("chosen:updated");
				} else {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los tipos de pagos", "", "gritter-error");
				}
			},
			error:function onError(){
				//message("Error al cargar " + url );
				showalert(LengStrMSG.idMSG88+" los tipos de pagos", "", "gritter-error");
				$('#cbo_TipoPago').fadeOut();
			},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	
	$("#cbo_TipoPago").change(function(){
		$("#cbo_Periodo").val(0);
		$("#cbo_Periodo").html(0);
		$("#cbo_Periodo").trigger("chosen:updated");
		
		CargarPeriodos();
	});
	
	/*---------------------------------------------------------------------------------------------------------------------------
		C	O	M	B	O 	- 	P	A	R	E	N	T	E	S	C	O	S
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarParentescos(callback) {
		console.log('CargarParentescos');
		$("#cbo_Parentesco").html("");
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",
			//url: "ajax/json/json_fun_obtener_beneficiario_empleado_rfc.php?",
			data: {
				'iTipo':0			
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0) {
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					var nParentesco=$("#cbo_Beneficiario").children(":selected").attr("parentesco");
					$("#cbo_Parentesco").html(option);
					//$( "#cbo_Parentesco" ).val($("#cbo_Parentesco option").first().val());
					$("#cbo_Parentesco").val(nParentesco);
					$("#cbo_Parentesco").trigger("chosen:updated");
				} else {
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){callback();});
					showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
				}
				callback();
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});	
	}	
	/*---------------------------------------------------------------------------------------------------------------------------
		C	A	R	G	A	R	- 	C	A	R	R	E	R	A	S
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarCarreras() {
		console.log('---Cargar carreras---');
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_datos_por_escuela_empleado.php?",
			data: {
				'session_name':Session,
				'iopcion': 4,
				/*'crfc': $("#txt_RFC").val(),
				'ibeneficiario':$("#cbo_Beneficiario").children(":selected").attr("value"),
				'itipobeneficiario':$("#cbo_Beneficiario").children(":selected").attr("tipo"),
				'iescolaridad':$("#cbo_Escolaridad").children(":selected").attr("escolaridad")*/
				'crfc': DOMPurify.sanitize($("#txt_RFC").val()),
				'ibeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("value")),
				'itipobeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("tipo")),
				'iescolaridad':DOMPurify.sanitize($("#cbo_Escolaridad").children(":selected").attr("escolaridad"))
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0) {
					if ( iEditarB > 0 ){
						Carrera="";
						Carrera="<option value='0'>SELECCIONE</option>";
						$("#cbo_Carrera").html(Carrera);			
					} else {
						Carrera = "";
					}
					if(dataJson.datos != null) {
						for(var i=0;i<dataJson.datos.length; i++) {
							Carrera = Carrera + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
						}
					}
					$("#cbo_Carrera").html(Carrera);
					if (  iCarrera > 0 ){
						$("#cbo_Carrera").val(iCarrera);
					} else {
						$("#cbo_Carrera").val( $("#cbo_Carrera option").first().val() );
					}
					// $("#cbo_Carrera").val(nCarrera);					
					$("#cbo_Carrera").trigger("chosen:updated");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	/*---------------------------------------------------------------------------------------------------------------------------
		C	A	R	G	A	R	- 	P	E	R	I	O	D	O	S
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarPeriodos() {
		var option="";
		if($("#cbo_TipoPago").val()==0) {
			$("#cbo_Periodo").html("");
			$("#cbo_Periodo").trigger("chosen:updated");
		} else {
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_obtener_periodos_pagos.php",
				data: { 
					//'iTipoPago':$("#cbo_TipoPago").val()
					'iTipoPago':DOMPurify.sanitize($("#cbo_TipoPago").val())
				},
				beforeSend:function(){},
				success:function(data){
					const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0) {
						for(var i=0;i<dataJson.datos.length; i++) {
							option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						$("#cbo_Periodo").trigger("chosen:updated").html(option);
						$("#cbo_Periodo").trigger("chosen:updated");
						if ( sPeriodos != "" ) { //Carga el perido
							aPeriodos = sPeriodos.split(",");
							$('#cbo_Periodo').val(aPeriodos).trigger("chosen:updated");
							$("#cbo_Periodo").trigger("chosen:updated");
						}
					} else {
						//message(dataJson.mensaje);
						showalert(LengStrMSG.idMSG88+" los periodos de pago", "", "gritter-error");
						$("#cbo_Periodo").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
						$("#cbo_Periodo").trigger("chosen:updated");
					}					
					//Si la opcion es de inscripción se debe de seleccionar automaticamente la inscripción.
					if($("#cbo_TipoPago").val().toString().replace(/^\s+|\s+$/g, '') == "1") {
						$("#cbo_Periodo").val("1");
						$("#cbo_Periodo").trigger("chosen:updated");
					} else if($("#cbo_TipoPago").val().toString().replace(/^\s+|\s+$/g, '') == "8") {
						$("#cbo_Periodo").val("1");
						$("#cbo_Periodo").trigger("chosen:updated");
					} else {
						$("#cbo_Periodo").val(0);
						$("#cbo_Periodo").trigger("chosen:updated");
					}
				},
				error:function onError(){
					//message("Error al cargar " + url );
					showalert(LengStrMSG.idMSG88+" los periodos de pago" , "", "gritter-error");
					$('#cbo_Periodo').fadeOut();
				},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		}	
	}
	
	/*---------------------------------------------------------------------------------------------------------------------------
		C	A	R	G	A	R	-	 	G	R	A	D	O	S
	----------------------------------------------------------------------------------------------------------------------------*/
	function CargarGrados() {
		console.log('cargar grados escolares');
		$("#cbo_Grado").html("");
		$.ajax({type: "POST",
			//url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			//url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			url: "ajax/json/json_fun_obtener_datos_por_escuela_empleado.php?",
			data: {
				'session_name':Session,
				'iopcion': 3,
				/*'crfc': $("#txt_RFC").val(),
				'ibeneficiario':$("#cbo_Beneficiario").children(":selected").attr("value"),
				'itipobeneficiario':$("#cbo_Beneficiario").children(":selected").attr("tipo"),
				'iescolaridad':$("#cbo_Escolaridad").children(":selected").attr("escolaridad")*/
				'crfc': DOMPurify.sanitize($("#txt_RFC").val()),
				'ibeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("value")),
				'itipobeneficiario':DOMPurify.sanitize($("#cbo_Beneficiario").children(":selected").attr("tipo")),
				'iescolaridad':DOMPurify.sanitize($("#cbo_Escolaridad").children(":selected").attr("escolaridad"))
			},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					if ( iEditarB > 0 ) {
						if ( $("#cbo_Beneficiario").val() != iBeneficiario) {							
							var option = "<option value='-1'>SELECCIONE</option>";
						} else if ( $("#cbo_Escolaridad").val() == 0 ) {
							var option = "<option value='-1'>SELECCIONE</option>";
						} else {
							var option = "";
						}
					} else {
						if ( $("#cbo_Escolaridad").val() == 0 ) {
							var option = "<option value='-1'>SELECCIONE</option>";
						} else {
							var option = "";
						}
					}
					for(var i=0;i<dataJson.datos.length; i++) {
						//option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 	
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 	
					}					
					
					$("#cbo_Grado").html(option);
					if (iGradoB > 0) {
						if ( $("#cbo_Escolaridad").val() == 0 ) {
							$("#cbo_Grado").val(-1);
						} else if ( $("#cbo_Escolaridad").val() == 8 ) {
							$("#cbo_Grado").val(0);
						} else {
							$("#cbo_Grado").val(iGradoB);
						}
					} else if ( iGradoB == 0 && $("#cbo_Escolaridad").val() == 1 ) {
						$("#cbo_Grado").val(0);
					} else if ( iGradoB == 0 && $("#cbo_Escolaridad").val() == 8 ){
						$("#cbo_Grado").val(0);
					} else {
						$("#cbo_Grado" ).val($("#cbo_Grado option").first().val());
					}
					$("#cbo_Grado").trigger("chosen:updated");
				} else {					
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}
	/*---------------------------------------------------------------------------------------------------------------------------
		B	O	T	O	N	- 	A	G	R	E	G	A	R 	-	B	E	N	E	F	I	C	I	A	R	I	O
	----------------------------------------------------------------------------------------------------------------------------*/
	$('#btn_AgregarB').click(function(event){
		// imp_compara=$("#txt_importe_compara").val();
		cad_imp_compara=$("#txt_importe_compara").val();
		imp_compara=cad_imp_compara.replace(",", "");
		imp_compara=imp_compara*100;
		cad_imp_concepto=$("#txt_importeConcep").val();
		imp_concepto=cad_imp_concepto.replace(",", "");
		imp_concepto=imp_concepto*100;
		var esco=$("#cbo_Escolaridad").val();
		console.log('----------------------------------------------------------------------');
		console.log('ImporteConcepto ='+imp_concepto);
		console.log('ImporteCompara ='+imp_compara);
		console.log('----------------------------------------------------------------------');
		console.log('ESCOLARIDAD');
		console.log(esco);
		//console.log($("#cbo_Escolaridad").document.getElementById("value"));
		//console.log(document.getElementById("cbo_Escolaridad").options[document.getElementById("cbo_Escolaridad").selectedIndex].value);
		//console.log(document.getElementById("cbo_ciudad").value);
		//document.getElementById("cbo_Escolaridad").options.selectedIndex=5;
		//a=$("#cbo_Escolaridad").val(options[select.selectedIndex]);
		console.log('escolaridad='+$("#cbo_Escolaridad").children(":selected").attr("escolaridad"));
		
		//return;
		//--
		iBeneficiario=0;
		if($("#cbo_Beneficiario").val()==0) {
			showalert('Seleccione el beneficiario, por favor', "", "gritter-info");
		} else if ( $("#cbo_TipoPago").val() == 0 ) {
			showalert("Seleccione el tipo de pago, por favor", "", "gritter-info");
		} else if ( $("#cbo_Periodo").val() == null ) {
			showalert("Seleccione los periodos, por favor", "", "gritter-info");
		} else if ( $("#cbo_Escolaridad").val() == 0 ) {
			showalert("Seleccione la escolaridad, por favor", "", "gritter-info");
		} else if ( $("#cbo_Grado").val() == -1 ) {
			showalert("Seleccione el grado escolar, por favor", "", "gritter-info");
		} else if ( $("#cbo_CicloEscolar").val() == 0 ) {
			showalert("Seleccione el ciclo escolar, por favor", "", "gritter-info");
		} else if ( ($("#cbo_Escolaridad").val() == 7 ) && ( $("#cbo_Parentesco").val() != 11 ) ) {//MAestria solo el empleado
			showalert("No es posible generar esta factura", "", "gritter-info");
		} else if ( imp_concepto == '' ) { //El importe es nulo ó cero
			showalert("Favor de agregar importe", "", "gritter-info");
		} else if ( imp_concepto > imp_compara ) { //El importe es mayor que el de la factura
			console.log ('importe concpeto='+imp_concepto+' importe compara='+imp_compara);
			showalert("El importe capturado es mayor al importe de la factura", "", "gritter-info");
		} else if ( $("#cbo_Escolaridad").children(":selected").attr("opc_carrera") == 1 && $("#cbo_Carrera").val() == 0 ) {
			showalert("Seleccione la carrera", "", "gritter-info");
			$("#cbo_Carrera").focus();
		} else {
			//fnPrecargarBeneficiarios(1);//Validar Costos
			fnAgregarBeneficiario();
		}
		event.preventDefault();	
	});
	
	
	

			
	//--IMPORTE
	$("#txt_importeConcep").focusin(function(event){
		if ( $( this ).val().replace(/^\s+|\s+$/g, '') != "" ) {
			if($( this ).val().replace(/^\s+|\s+$/g, '') ==0)
			{
				$( this ).val( "");
			}
			else{
				$( this ).val( accounting.unformat( $( this ).val()) );
			}	
		}
		event.preventDefault()
	});
	$( '#txt_importeConcep' ).focusout(function(event){
		 // var numTecleado = 0;
		 // numTecleado = Math.round(($(this).val() * 100)/100);
		 // console.log("NUMERO TECLEADO = "+ numTecleado);
		 // return;
		$( this ).val( accounting.formatMoney( $( this ).val() , "", 2) );
		event.preventDefault();
	});

	
	



/*
//--COMBO ESTADO	
	$("#cbo_Estado").change(function(){
		CargarCiudades();
	});
*/
	
/*	
//--
	$('#btn_ConsultaAyudaEscuela').click(function(event){
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		if($('#txt_NombreBusqueda').val().replace(/^\s+|\s+$/g, '')=="")
		{
			showalert(LengStrMSG.idMSG400, "", "gritter-info");			
		}
		else
		{
			cargarGridEscuelas();
		}	
		event.preventDefault();	
	});	
*/

/*	
//--GRID ESCUELAS
	function cargarGridEscuelas()
	{
		$("#grid_ayudaEscuelas").jqGrid('setGridParam',	{ 
			url: 'ajax/json/json_fun_obtener_escuelas_colegiaturas.php?iTipoEscuela=2&iConfiguracion=0&iOpcion=1' +
			'&iEstado='+$('#cbo_Estado').val()+'&iMunicipio='+$('#cbo_Ciudad').val()+'&iBusqueda='+$('#cbo_TipoConsulta').val()+
			'&sBuscar='+$('#txt_NombreBusqueda').val().toUpperCase().replace(/^\s+|\s+$/g, '')+'&iAyuda=1' + '&session_name=' + Session
		}).trigger("reloadGrid");
	}
*/

	
//--
	function formatearFecha2(opcion, fecha){
		// fecha - debe tener formato dd/mm/yyyy para devolverla en formato ddmmyyyy
		// ejemplo: 21/05/2013
		//			21052013
		var fecha_aux = fecha.split('/');
		anio =fecha_aux[2];
		if(opcion==1)
		{
			var nanio =parseInt(anio)+1;
			anio=nanio;
		}
		
		mes = fecha_aux[1];
		dia = fecha_aux[0];
		
		return (''+anio+''+ mes + dia);
	}

//--	
	function CompararFechaFactura(fechaF){
		if($("#txt_Limitado").val()==1)
		{
			if(parseInt(dFechaValida)>=parseInt(fechaF))
			{
				//Solo se permite subir facturas despues 
				//showalert(LengStrMSG.idMSG401, "", "gritter-info");
				// showalert("NO se puede", "", "gritter-info");
				$("#txt_FechaCap" ).datepicker("setDate",new Date());
			}
		}
	}

//--GUARDAR ESCUELA
	function fnGuardarEscuela()
	{
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_actualizar_escuelas_colegiaturas_sep.php?",
			data: { 
				session_name:Session,
				'iEscuela':idEscuelaVinculada,
				'cRFC':$('#txt_RFC').val()
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				var bloqueda=0;
				
				if(dataJson.estado ==1){
					//Escuala actualizada correctamente
					showalert(dataJson.mensaje, "", "gritter-success");
					CargarEscuelas();
				}
				else{
					showalert("Ocurrio un problema al actualizar la escuela", "", "gritter-warning");
					Limpiar();
				}
			},
			error:function onError(){showalert("Ocurrio un problema al actualizar la escuela", "", "gritter-warning");
					Limpiar();},
			complete:function(){ },
			timeout: function(){showalert("Ocurrio un problema al actualizar la escuela", "", "gritter-warning");
					Limpiar();},
			abort: function(){showalert("Ocurrio un problema al actualizar la escuela", "", "gritter-warning");
					Limpiar();}
		});	
	}

//--LIMPIAR
	function Limpiar()
	{
		var escuela="<option value='0' >SELECCIONE ESCUELA</option>";
		$( '#fileXml' ).ace_file_input('reset_input');
		$( '#filePdf' ).ace_file_input('reset_input');
		$('#txt_ifactura').val(0);
		$("#txt_EditarFactura").val(0)
		$('#txt_ImporFact').val('');
		$('#cbo_Escuela').html(escuela);
		//$("#cbo_Escuela").prop('disabled',false);   //16052018
		$("#cbo_Escuela").trigger("chosen:updated");
		$('#txt_idEscuela').val('');
		$('#txt_RFC').val('');
		$("#txt_MotivoAclaracion").val("");
		$("#hidden_MotivoAclaracion").val("");
		$( "#cbo_Aclaracion" ).val(0);
		$("#txt_FechaCap").val($("#txt_Fecha").val());
		$("#lbl_importeFac").text('Importe Factura:');
		$("#lbl_FechaFac").text('Fecha Factura:');
		$("#btn_Agregar").prop("disabled",false);
		iKeyx=0, iMod=0, iParentescoB=0,iTipoPagoB=0,sPeriodos='',iEscolaridadB=0, iGradoB=0, iCicloB=0, iImporteB=0, iEscuelaFac=0;
		if ( ($("#grid_Beneficiarios").find("tr").length - 1) > 0 ) 
		{
			fnConsultarDetalles();
		}
	}//txt_Descuento



//--AGRERGAR A TEMPORAL DETALLE CUANDO ES NOTA DE CREDITO
// function fnAgregarNotaCreditoDetalle(){
	
	
// }

//--AGREGAR BENEFICIARIO	
	function fnAgregarBeneficiario(){
		var periodos="";
		for(var i = 0; i < $("#cbo_Periodo").val().length; i++)
		{
			periodos += (i != 0)?',':'';
			periodos += $('#cbo_Periodo').val()[i];
		}
		iFactura=$("#txt_ifactura").val();
		if (iFactura==''){
			iFactura=0;
		}
		$.ajax({type:'POST',
			url:"ajax/json/json_fun_grabar_stmp_detalle_facturas_colegiaturas.php",
			data:{
				session_name:Session,
				'cFolioFiscal':$("#txt_Folio").val(),
				'iBeneficiario':$("#cbo_Beneficiario").val(),
				'iParentesco':$("#cbo_Parentesco").val(),
				'iTipoPago':$("#cbo_TipoPago").val(),
				'cPeriodo':periodos,
				'iEscuela': $("#cbo_Escolaridad").children(":selected").attr("id_escuela"),//iEscuela,//$("#cbo_Escuela").val(),
				'iEscolaridad':$("#cbo_Escolaridad").children(":selected").attr("escolaridad"), //$("#cbo_Escolaridad").val(),
				'iCarrera':$("#cbo_Carrera").val(),
				'iGrado':$("#cbo_Grado").val(),
				'iCiclo':$("#cbo_CicloEscolar").val(),
				'iImporte':accounting.unformat($("#txt_importeConcep").val()), //accounting.unformat($("#cbo_Importes").val()),//
				'iFactura':iFactura, //$("#txt_ifactura").val(),
				'iKeyx':iMod,
				'iConfDesc':iDescuentosDiferentes
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				//console.log(dataJson);
				if(dataJson.estado != -2)
				{
					$('#dlg_AgregarDetalle').modal('hide');
						showalert(dataJson.mensaje, "", "gritter-info");
					// showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){
							$("#cbo_Beneficiario").val(0);
							$("#cbo_Parentesco").val(0);
							$("#cbo_TipoPago").val(0);
							$("#cbo_Periodo").html("");
							$("#cbo_Periodo").trigger("chosen:updated");
							$("#cbo_Escolaridad").val(0);
							$("#cbo_Grado").val(-1);
							$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar option").first().val());
							//$("#txt_importeConcep").val("");
							iKeyx=0;
							iMod=0;
							iParentescoB=0;
							iTipoPagoB=0;
							sPeriodos='';
							iEscolaridadB=0;
							iGradoB=0;
							iCicloB=0;
							iImporteB=0;
					// });
				}
				else 
				{
					$('#dlg_AgregarDetalle').modal('hide');
						showalert("Ocurrio un ploblema al capturar el beneficiario, favor de comunicarse a mesa de ayuda", "", "gritter-error");
					// showmessage('Ocurrio un ploblema al capturar el beneficiario, favor de comunicarse a mesa de ayuda', '', undefined, undefined, function onclose(){
							$("#cbo_Beneficiario").val(0);
							$("#cbo_Parentesco").val(0);
							$("#cbo_TipoPago").val(0);
							$("#cbo_Periodo").html("");
							$("#cbo_Periodo").trigger("chosen:updated");
							$("#cbo_Escolaridad").val(0);
							$("#cbo_Grado").val(-1);
							$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar option").first().val());
							//$("#txt_importeConcep").val("");
							
							
					// });
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}	
	
//--BOTON GUARDAR
	$('#btn_Guardar').click(function(event){
		//$("#dlg_AgregarAclaracion").modal('hide');
		iFactura=$("#txt_ifactura").val();
		if (iFactura==''){
			$("#txt_ifactura").val(0);
		}
		fnValidarGuardado();
		event.preventDefault();	
	});	
	
//--BOTON MOTIVO ACLARACION
	$('#btn_MotivoAclaracion').click(function(event){
		if($("#cbo_Aclaracion").val()==0)
		{
			showalert("Seleccione el motivo de aclaración","", "gritter-warning");
			$("#cbo_Aclaracion").focus();
		}
		else if($("#txt_MotivoAclaracion").val().replace(/^\s+|\s+$/g, '')=='')
		{
			showalert("Proporcione justificación de aclaración","", "gritter-warning");	
			$("#txt_MotivoAclaracion").focus();
		}
		else
		{
			//$("#hidden_MotivoAclaracion").val($("#txt_MotivoAclaracion").val().toUpperCase());
			var sMotivo=$('#cbo_Aclaracion option:selected').html()+': '+$("#txt_MotivoAclaracion").val().replace(/^\s+|\s+$/g, '').toUpperCase();
			$("#hidden_MotivoAclaracion").val(sMotivo);
			$("#dlg_AgregarAclaracion").modal('hide');
			
			fnValidarGuardado();
		}	
		event.preventDefault();	
	});	
	
//--VALIDAR GUARDADO
	function fnValidarGuardado()
	{
		//$("#hidden_MotivoAclaracion").val($("#txt_MotivoAclaracion").val().toUpperCase());
		var TotalF =accounting.unformat($("#txt_ImporFact").val());
		iTotalFacturaCargada=accounting.unformat(iTotalFacturaCargada);
		console.log (TotalF+'='+iTotalFacturaCargada);
		// return;
		if(TotalF==iTotalFacturaCargada)
		{
			$("#txt_MotivoAclaracion").val("");
			$("#hidden_MotivoAclaracion").val("");
		}
		if (iTipoComprobante!=2){
			if ( ($("#grid_Beneficiarios").find("tr").length - 1) == 0 ) 
			{
				//message('Agregue los detalles de la factura, por favor');	
				showalert("Favor de agregar los detalles de la factura.", "", "gritter-info");
			}
			else if( TotalF<iTotalFacturaCargada)
			{
				//message('El importe total de la factura es menor a los detalles capturados de la factura, favor de verificar');
				showalert("El importe total de la factura es menor a los detalles capturados de la factura, favor de verificar", "", "gritter-info");
			}
			else if((TotalF!=iTotalFacturaCargada)&&($("#cbo_Aclaracion").val()==0))
			{
				if($("#hidden_MotivoAclaracion").val()=="")
				{
					showalert("Favor de seleccionar el motivo y justificar la aclaración", "", 'gritter-warning');
				}
				else
				{
					showalert("Favor de seleccionar el motivo y justificar la  aclaración", "", 'gritter-warning');
				}
				$( "#cbo_Aclaracion").val(0);
				$( "#txt_MotivoAclaracion").val('');
				$("#dlg_AgregarAclaracion").modal('show');
			}
			else if((TotalF!=iTotalFacturaCargada)&&($("#hidden_MotivoAclaracion").val()==""))
			{
				showalert("Favor de seleccionar el motivo y justificar de aclaración", "", 'gritter-warning');
				$( "#cbo_Aclaracion").val(0);
				$("#dlg_AgregarAclaracion").modal('show');
			}
			else if((iPdf==1) && ($("#filePdf").val()==""))
			{
				//message("Favor de seleccionar un pdf");
				showalert("Favor de seleccionar un pdf", "", "gritter-info");
				$("#filePdf").focus();
			}
			else{
				$("#btn_MotivoAclaracion").prop('disabled', true);
				$("#btn_Guardar").prop('disabled', true);
				bootbox.confirm('¿Está seguro que la información de la factura es correcta?', 
				function(result){
					$("#btn_MotivoAclaracion").prop('disabled', false);
					$("#btn_Guardar").prop('disabled', false);
					//abrir dialogo de aclaracion
					if (result){
						fnSubirFactura();
					}
					 
				});
			}
		}else{
			$("#btn_MotivoAclaracion").prop('disabled', true);
			$("#btn_Guardar").prop('disabled', true);
			bootbox.confirm('¿Está seguro que la información de la factura es correcta?', 
				function(result){
					$("#btn_MotivoAclaracion").prop('disabled', false);
					$("#btn_Guardar").prop('disabled', false);
					//abrir dialogo de aclaracion
					if (result){
						fnSubirFactura();
					}
					 
				});
		}
	}

	//Metodos
//--GUARDAR FACTURA	
	function fnGuaradarFactura(){
		var sFecha=formatearFecha($('#txt_FechaCap').val());
		
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_grabar_stmp_facturas_colegiaturas.php?",
			data: { 
				session_name:Session,
				'iOpcion':1,
				'cFolioFiscal':$("#txt_Folio").val(),
				'iEscuela':$("#cbo_Escuela").val(),
				'fecha':sFecha
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				//console.log(dataJson);
				if(dataJson.estado == 0)
				{
					$("#txt_ifactura").val(dataJson.factura);
					//$("#cbo_Escuela").prop('disabled',true);
					
					// $("#btn_Cargar").hide();
				}
				else 
				{
					//showmessage('Ocurrio un ploblema al capturar la factura, favor de comunicarse a mesa de ayuda', '', undefined, undefined, function onclose(){});
					showalert("Ocurrio un ploblema al capturar la factura, favor de comunicarse a mesa de ayuda", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}	

//--FUNCION SUBIR FACTURA
	function fnSubirFactura()
	{
		console.log('fnSubirFactura');
		var sExt = ($('#fileXml').val().substring($('#fileXml').val().lastIndexOf("."))).toLowerCase();
		//console.log('sExt');
		if(sExt != '.xml')
		{
			//console.log($("#txt_EditarFactura").val());
			if( $("#txt_EditarFactura").val()==0)
			{
				$('#fileXml').ace_file_input('reset_input');
				//message('El archivo seleccionado no es un xml, favor de verificar');
				showalert("El archivo seleccionado no es un XML", "", "gritter-info");
			}
		}

		$('#txt_FechaFactura').val(formatearFecha($('#txt_FechaCap').val()));
		$('#txt_Rfc_fac').val($('#txt_RFC').val());
		var opciones = {
			//console.log('opciones');
			beforeSubmit: function(){
				waitwindow('Guardando Factura ... ','open');
			},
			uploadProgress: function(){	},
			success: function(data)
			{
				waitwindow('Guardando Factura ... ','close');
				var dataJson = JSON.parse(data);
				console.log(dataJson.estado+'='+dataJson.mensaje);
				//alert('estado='+dataJson.estado+' mensaje='+dataJson.mensaje);
				if ((dataJson.estado == 1) || (dataJson.estado == 2))
				{
					// showmessage(dataJson.mensaje, '', undefined, undefined, function onclose()
					// {
					if (dataJson.estado == 1)
					{
						showalert(dataJson.mensaje, "", "gritter-info");
					}
					else
					{
						showalert(dataJson.mensaje, "", "gritter-warning");
					}
					//Regresa a pantalla seguimiento de factuas por colaborador
					if(iRegresa == 1)
					{
						loadContent('ajax/frm/frm_seguimientoFacturasElectronicasColaboradores.php','');
					}
					else
					{
						Limpiar();
					}
				}
				else
				{
					if(dataJson.estado < 0)
					{
						showalert('Ocurrio un problema al subir la factura: ' + dataJson.mensaje, "", "gritter-error");
					}
				}
			},
			error:function()
			{
				waitwindow('Cargando','close');
				showalert("Ocurrio un problema al subir la factura", "", "gritter-error");
			}
		};
		$( '#session_name1' ).val(Session);
		//$( '#txt_EditarFactura' ).val();
		$( '#xmlupload' ).attr("action", "ajax/proc/proc_subir_XML_Colegiaturas.php") ;
		$( '#xmlupload' ).ajaxForm(opciones) ;
		$( '#xmlupload' ).submit();
	}
	
	//Para el cragado de informacion
	var limite = 0;
	var limit = 86;
	load_cargando(0);
	function load_cargando(nPorcen)
	{
		if(nPorcen == -1)
		{
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
			//console.log(limite + ' ' + limit + ' '  + porc);
			porc = (porc+'%');
			$("#div_load").attr('data-percent',porc);
			$("#div_loading").css('width',porc);
		}
		else
		{
			var porc = nPorcen;
			porc = (porc+'%');
			$("#div_load").attr('data-percent',porc);
			$("#div_loading").css('width',porc);
		}	
	}
	function fnConsultarDatosFactura(callback) {
		console.log('fnConsultarDatosFactura');
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_factura_colegiatura.php",
			data: { 
					session_name:Session,
					'Factura':$("#txt_EditarFactura").val()
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				// console.log(dataJson);
				if((dataJson.estado == 0) )
				{
					$("#txt_RFC").val(dataJson.datos[0].rfc);
					$("#txt_ImporFact").val(dataJson.datos[0].importe);
					$("#txt_FechaCap").val(dataJson.datos[0].fecha);
					iEscuelaFac=dataJson.datos[0].escuela;
					$("#txt_Folio").val(dataJson.datos[0].foliofiscal);
					$("#txt_ifactura").val($("#txt_EditarFactura").val());					
					$("#fileXml").prop('disabled',false);					
				}
				else 
				{
					//message("Ocurrio un problema al consultar la factura");
					showalert("Ocurrio un problema al consultar la factura", "", "gritter-error");
				}
			},
			error:function onError(){
				callback();
			},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
});	