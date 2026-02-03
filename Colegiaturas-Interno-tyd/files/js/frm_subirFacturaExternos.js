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

 //función para hacer un Trim y evitar vulnerabilidades :) 
 // ejemplo: var.makeTrim(" ");
 
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
	ConsultaClaveHCM()
    $.fn.modal.Constructor.prototype.enforceFocus = function () {};
	SessionIs();
	ConsultaRFCEmpresa();
	//Valida si el empleado esta bloqueado / Limitado
	setTimeout(
		ConsultaEmpleado(function(){
			fnEmpleadoBloqueado();
	}), 0);	
	iFactura=0;
	iIduEmpleado=$('#hid_idu_usuario').val();
	$("#txt_externo").val(1);
	$("#txt_tipoXml").val(2);
	validarUsuario();

	
	// Muestre el mensaje en azul de la ayuda, del tooltip
	$('[data-rel=tooltip]').tooltip();
	$('[data-rel=tooltip]').tooltip({
		container : 'body'
	});
	$('[data-rel=popover]').popover({
		container : 'body'
	});	

	$("#cbo_Beneficiario").change(function(){
		$("#txt_beneficiario_ext").val($("#cbo_Beneficiario").val());
		// alert($("#txt_beneficiario_ext").val());
	});
	function validarUsuario(){
		$.ajax({
			type:"POST",
			data:{'iIduEmpleado': iIduEmpleado},
			url:'ajax/json/json_fun_validar_usuario_externo.php',
		}).done(function(data){
			var dataS = sanitize(data);
			json = json_decode(dataS);
			// console.log(json.mensaje);
			if(json.estado != 1){
				loadContent({url:'ajax/frm/blank.php', dataIn:{mensaje: json.mensaje}});
				return;
			} else {
				llenarComboBeneficiarios();
			}
			// callback();
			// alert(json);
		})
		.fail(function(s){alert("Error al cargar ajax/json/json_fun_validar_usuario_externo.php");})
		.always(function(){
			// callback();
		});
	}
	function ConsultaRFCEmpresa(){
		$.ajax({
			type:"POST",
			data:{'iEmpresa' : 1,
					'session_name' : Session},
			url:'ajax/json/json_fun_obtener_rfc_empresa.php',
		}).done(function(data){
			var dataS = sanitize(data);
			json = json_decode(dataS);
			$("#txt_Rfc_Emp").val(json.rfc);
		})
		.fail(function(s){alert("Error al cargar json_fun_obtener_rfc_empresa.php");})
		.always(function(){});
	}
	function llenarComboBeneficiarios(){
		$.ajax({
			type: "POST",
			data: {'iIduEmpleado' : iIduEmpleado},
			url: 'ajax/json/json_fun_obtener_beneficiarios_externos.php?sidx=nom_empleado'})
			.done(function(data){
				var dataS = sanitize(data);
			json = json_decode(dataS);
				if(json.estado == 0){
					var select = "<option prc_descuento='0' value='0'>SELECCIONE</option>";
					// console.log(json.datos.length);
					if(json.datos.length == 0){
						// console.log("Es igual a 0");
						loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'No cuentas con beneficiarios asignados.'}});
						return;
					}
					for(var i=0; i < json.datos.length; i++){
						// select += "<option style='text-align: left;' value='"+json.datos[i].idu_beneficiario+"'>"+json.datos[i].nom_beneficiario+"</option>";
						select += "<option style='text-align: left;' prc_descuento='" + json.datos[i].prc_descuento + "' value='"+json.datos[i].idu_beneficiario+"'>"+json.datos[i].nom_beneficiario+"</option>";
					}
					$("#cbo_Beneficiario").html(select);
					// $("#cbo_Beneficiario").chosen({no_results_text: LengStr.idMSG32/*,width: '100px'*/});
					$("#cbo_Beneficiario").trigger("chosen:updated");
				}
				else{
					// alert(json.mensaje);
					showalert(json.mensaje, "", "gritter-info");
				}
			})
		.fail(function(s) {alert("Error al cargar ajax/json/json_fun_obtener_beneficiarios_externos.php");})
		.always(function() {});
	}	
	$("#div_msj").html('<i class="icon-ok green"></i>Favor de cargar el '+ 
				'<strong class="green">XML '+
					'<i class="icon-file-text green"></i>'+
				'</strong  > de la factura, para poder mostrar los datos de la escuela. '+
				'<strong class="red"><i class="icon-info-sign red"> </i>'+ LengStrMSG.idMSG434+' '+'</strong>'+LengStrMSG.idMSG435 );
	
	var Sueldo=0, iBeneficiario=0, iKeyx=0, iParentescoB=0, iTipoPagoB=0,sPeriodos='', iEscuelaFac=0, 
		nAntiguedad=0,dFechaValida='', idEscuelaVinculada=0, iLimpiar=0, iEscolaridadB=0,iPdf=0,iGradoB=0,
		iCicloB=0,iImporteB=0,iTotalFacturaCargada=0, iMod=0, iDescuentosDiferentes=0,  iRegresa=0;		
		//PrimerOpcion=0;
	
	if(($("#txt_Bloqueado").val()==0)&&($("#txt_Limitado").val()==0))
	{
		fnConsultarParametro(1);
		$("#div_cargando").css('display','block');
		EstructuraGridBeneficiarios();	
		load_cargando(0);
		setTimeout("$('#div_cargando').css('display','none');",1300);
		// ConsultaEmpleado(function()
		// {
			//CargarDatosGenerales();
			load_cargando(50);
		// });
		var Beneficiarios="<option parentesco='0' value='0'>SELECCIONE</option>";
		CargarParentescos(function(){
			ObtenerBeneficiariosHojaAzul(function(){
				CargarBeneficiariosCapturados(function(){
					$("#cbo_Beneficiario").html(Beneficiarios);
					$( "#cbo_Beneficiario" ).val($("#cbo_Beneficiario").first().val());
					$( "#cbo_Parentesco").val($( "#cbo_Beneficiario" ).val());
					if(($("#txt_EditarFactura").val()!=0) && ($("#txt_EditarFactura").val()!= undefined))
					{
						$("#pag_title").html('Modificar Factura Escuela Privada');
						//ocultar recibo y carta
						$("#nom_xml").hide();
						$("#div_xml").hide();
						// $("#nom_pdf").hide();
						// $("#div_pdf").hide();
						$("#btn_Otro").hide();
						iRegresa=1;
						
						$('#txt_id_Escuela').val( $("#txt_EditarIduEscuela").val() );
						$('#txt_RFC').val( $("#txt_EditarRfcEscuela").val() );
						$("#txt_Escuela").val( $("#txt_EditarNombreEscuela").val() );
						CargarEscolaridades();
						
						fnConsultarDatosFactura(function()
						{
							fnConsultarDetalles();
						});
					//	$("#btn_Cargar").hide();
					}
					load_cargando(95);
					
				});
			});
		});
		CargarTiposPagos();	
		CargarCiclosEscolares();
		fnConsultarMotivosAclaracion();
		load_cargando(100);
		$("#div_cargando").css('display','block');
	}
	
	$("#cbo_Periodo").chosen({width:'250px', height:'70px', resize:'none'});
	$("ul.chosen-choices").css({'overflow': 'auto', 'max-height': '70px'});
	
	$("#txt_FechaCap").val($("#txt_Fecha").val());
	$('#fileXml').ace_file_input({
		no_file:'XML...',
		btn_choose:'Examinar',
		btn_change:'Cambiar',
		droppable:false,
		thumbnail:false, 
		whitelist:'xml',
		blacklist:'exe|php|gif|png|jpg|jpeg'
	});
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
	
	//Al abrir el dialogo
	$('#dlg_AgregarDetalle').on('show.bs.modal', function (event) {
		if($("#txt_ifactura").val()==0)
		{
			fnGuaradarFactura();
		}
		//$("#cbo_Escuela").prop('disabled',true);
		
	});
	//Al Cerrar el dialogo
	$('#dlg_AgregarDetalle').on('hide.bs.modal', function (event) {
		//console.log("Cerrar dlg");
		$("#cbo_Beneficiario").val(0);
		$("#cbo_Parentesco").val(0);
		$("#cbo_TipoPago").val(0);
		$("#cbo_Periodo").html("");
		$("#cbo_Periodo").trigger("chosen:updated");
		$("#cbo_Escolaridad").val(0);
		$("#cbo_Grado").val(0);
		//$("#cbo_CicloEscolar").val(0);
		$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar").first().val());
		$("#txt_importeConcep").val('');
		//$("#txt_importeConcep").val("");
		//$("#cbo_Importes")
		fnConsultarDetalles();
	});
	
	$('#dlg_AyudaEscuelas').on('show.bs.modal', function (event) {
		$("#cbo_Estado").val($("#cbo_Estado").first().val());
		$("#cbo_Ciudad").val($("#cbo_Ciudad").first().val());
		$("#cbo_TipoConsulta").val($("#cbo_TipoConsulta").first().val());
		$("#txt_NombreBusqueda").val("");
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		
	});
	$('#dlg_AyudaEscuelas').on('hide.bs.modal', function (event) {
		if(idEscuelaVinculada==0 && iLimpiar==0)
		{
			Limpiar();
		}
	});
	
	$("#fileXml").change(function(event){
		validarXml(function(){
			if($("#txt_RFC").val()!='')
				CargarEscuelas();
		});
		// $("#cbo_Beneficiario").val(0);
		// $("#cbo_Beneficiario").trigger("chosen:updated");
		event.preventDefault();
	});
	
	//COMBO ESCUELA CHANGE
	$("#cbo_Escuela").change(function(event){
		//ChangeEscuela();
		iPdf=$("#cbo_Escuela").children(":selected").attr("pdf");
		//console.log("PDF "+iPdf);
		if($("#cbo_Escuela").val()!=0)
		{
			var comboEscuela = sanitize($("#cbo_Escuela option:selected").text())
			$("#div_escuelaPri").html(' ESCUELA: <b>'+ comboEscuela + '<b>');
			//$("#txt_NombreEscuela").val($("#cbo_Escuela option:selected").text());
			$("#txt_id_Escuela").val($("#cbo_Escuela").val());
			CargarEscolaridades();
		}
		event.preventDefault();
	});
	
	/*
	function ChangeEscuela(){
		iPdf=$("#cbo_Escuela").children(":selected").attr("pdf");
		//console.log("PDF "+iPdf);
		if($("#cbo_Escuela").val()!=0)
		{
			$("#div_escuelaPri").html(' ESCUELA: <b>'+$("#cbo_Escuela option:selected").text()+'<b>');
			//$("#txt_NombreEscuela").val($("#cbo_Escuela option:selected").text());
			$("#txt_id_Escuela").val($("#cbo_Escuela").val());
			CargarEscolaridades();
		}
		event.preventDefault();
	}*/
	
	//
	$("#txt_importeConcep").focusin(function(event){
		if ( $( this ).val().makeTrim(" ") != "" ) {
			if($( this ).val().makeTrim(" ") ==0)
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
		$( this ).val( accounting.formatMoney( $( this ).val() , "", 2) );
		event.preventDefault();
	});
	
	function validarXml(callback){
		var sExt = ($('#fileXml').val().substring($('#fileXml').val().lastIndexOf("."))).toLowerCase();
		$("#txt_ImporFact").val();
		$("#txt_RFC").val();
		$("#txt_FechaCap").val();
		$("#txt_Folio").val();
		if(sExt != '.xml')
		{
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
			success: function(data) 
			{				
				var dataS = sanitize(data);	
				var dataJson = JSON.parse(dataS);
				//if (dataJson[0].resultado > 0)
				if (dataJson[0].resultado != 0)
				{
					//message(dataJson[0].json.mensaje);
					// console.log(dataJson[0].json.mensaje);
					if(dataJson[0].resultado==-1)
					{
						showalert(dataJson[0].mensaje, "", "gritter-warning");
					}
					else
					{
						showalert(dataJson[0].json.mensaje, "", "gritter-info");
						
						// var option='';
						// for(var i=0;i<dataJson[0].importes.length; i++)
						// {
							// option = option + "<option value='" + dataJson[0].importes[i].value + "'>" + dataJson[0].importes[i].value + "</option>";
						// }
						// $("#cbo_Importes").html(option);
						// $("#cbo_Importes").trigger("chosen:updated");
						
					}	
					
					// if (dataJson[0].resultado != 2)
					// {
						//$('#dlg_AyudaEscuelas').modal('show');
					// }	
					Limpiar();
				}
				else
				{
					$("#txt_ImporFact").val(accounting.formatMoney(dataJson[0].json.importe_total, "", 2));
					$("#txt_RFC").val(dataJson[0].json.rfc_emisor);
					$("#txt_FechaCap").val(dataJson[0].json.fecha);
					$("#txt_Folio").val(dataJson[0].json.folio_fiscal);
					$("#txt_tipo_comprobante").val(dataJson[0].json.n_comprobante);
					$("#txt_clvUso").val(dataJson[0].json.clave_uso);
					$("#txt_FolioRelacionado").val(dataJson[0].json.foliorelacionado);
					
				//	$("#txt_FechaCap").val(dataJson[0].json.importes[0].value);
					var fechafactura=formatearFecha($('#txt_FechaCap').val());
					if (fechafactura < $("#txt_Anio").val())
					{
						//showmessage('La fecha de expedición de la factura debe ser del año en curso', '', undefined, undefined, function onclose(){
						//	Limpiar();
						//});
						showalert(LengStrMSG.idMSG397, "", "gritter-warning");
						Limpiar();
					}
					else
					{
						var fechaA=formatearFecha2(0,$("#txt_FechaCap").val());
						CompararFechaFactura(fechaA);
						
						var option='';
						for(var i=0;i<dataJson[0].json.importes.length; i++)
						{
							option = option + "<option value='" + dataJson[0].json.importes[i].value + "'>" + dataJson[0].json.importes[i].value + "</option>";
						}
						$("#cbo_Importes").html(option);
						$("#cbo_Importes").trigger("chosen:updated");
					}
				}
				callback();
			}
		};
		$( '#session_name1' ).val(Session);
		$( '#xmlupload' ).attr("action", "ajax/json/json_leer_Rfc_XML.php") ;
		$( '#xmlupload' ).ajaxForm(opciones) ;
		$( '#xmlupload' ).submit();
	}
	
	

	$("#cbo_Escolaridad").change(function(){
		CargarGrados();
	});
	
	$("#cbo_TipoPago").change(function(){
		CargarPeriodos();
	});
	
	$("#cbo_Estado").change(function(){
		CargarCiudades();
	});
	
	//BOTON AGREGAR
	$('#btn_Agregar').click(function(event){
		iKeyx=0;
		$("#cbo_Beneficiario").prop('disabled',false);
		if($("#txt_Folio").val()=="")
		{
			//message("Seleccione el xml de la factura, por favor...");
			showalert(LengStrMSG.idMSG398, "", "gritter-info");
		}
		else if($("#cbo_Escuela").val()==0)
		{
			//message("Seleccione la escuela, por favor...");
			showalert(LengStrMSG.idMSG399, "", "gritter-info");
		}
		else
		{
			// Cambiar los títulos de la ventana modal
			$("#tit_modal_beneficiario_eprv").html("<i class=\"icon-file-text-alt\"></i>&nbsp;Agregar Beneficiario");
			$("#btn_AgregarB").html("<i class=\"icon-plus bigger-110\"></i>Agregar</button>");
			EstructuraGridBeneficiariosEstudios();
			CargarGrados();
			//$("#txt_importe_compara").val($("#txt_ImporFact").val());
			imp_cadena=$("#txt_ImporFact").val();
			importe_factura=imp_cadena.replace(",", "");
			importe_factura=importe_factura*100;
			//alert(importe_factura);
			$("#txt_importe_compara").val(importe_factura);
			$('#dlg_AgregarDetalle').modal('show');
		}
		event.preventDefault();	
	});	
	
	//GRID BENEFICIARIOS ESTUDIOS	
	function EstructuraGridBeneficiariosEstudios(){
		jQuery("#grid_BeneficiariosEstudios").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG8,
				colModel:[
				{name:'idu_hoja_azul',index:'idu_hoja_azul', width:90, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'idu_beneficiario',index:'idu_beneficiario', width:90, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'nom_beneficiario',index:'nom_beneficiario', width:269, sortable: false,align:"left",fixed: true},
				{name:'idu_parentesco',index:'idu_parentesco', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_parentesco',index:'nom_parentesco', width:120, sortable: false,align:"left",fixed: true},
				{name:'idu_tipo_pago',index:'idu_tipo_pago', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'des_tipo_pago',index:'des_tipo_pago', width:120, sortable: false,align:"left",fixed: true},
				{name:'nom_periodo',index:'nom_periodo', width:150, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'idu_escolaridad',index:'idu_escolaridad', width:180, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_escolaridad',index:'nom_escolaridad', width:153, sortable: false,align:"left",fixed: true},
				{name:'idu_grado',index:'idu_grado', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_grado',index:'nom_grado', width:200, sortable: false,align:"left",fixed: true},
				{name:'idu_ciclo',index:'idu_ciclo', width:220, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_ciclo_escolar',index:'nom_ciclo_escolar', width:100, sortable: false,align:"left",fixed: true},
				{name:'imp_importe',index:'imp_importe', width:80, sortable: false,align:"right",fixed: true, hidden: true},
				{name:'imp_importeF',index:'imp_importeF', width:80, sortable: false,align:"right",fixed: true},
				{name:'keyx',index:'keyx', width:120, sortable: false,align:"left",fixed: true, hidden:true}
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
			caption: 'Beneficiarios Estudios',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},			
			loadComplete: function (Data) {
				/*var grid = $('#grid_BeneficiariosEstudios');
				iTotalFacturaCargada = grid.jqGrid('getCol', 'imp_importe', false, 'sum');
				$("#txt_Tolal").val(accounting.formatMoney(iTotalFacturaCargada, "", 2));*/				
			},
			onSelectRow: function(id) {
				/*if(id >= 0){
				
					var fila = jQuery("#grid_BeneficiariosEstudios").getRowData(id); 
					iBeneficiario=fila['idu_beneficiario'];
					iKeyx = fila['keyx'];
					iParentescoB=fila['idu_parentesco'];
					iTipoPagoB=fila['idu_tipo_pago'];
					
					sPeriodos=fila['nom_periodo'];
					iEscolaridadB=fila['idu_escolaridad'];
					iGradoB=fila['idu_grado'];
					iCicloB=fila['idu_ciclo'];
					iImporteB=fila['imp_importe'];
				} else {
					iKeyx=0;
					iParentescoB=0;
					iTipoPagoB=0;
					sPeriodos='';
					iEscolaridadB=0;
					iGradoB=0;
					iCicloB=0;
					iImporteB=0;
				}*/
			}				
		});
	}
	
	// $('#btn_Cargar').click(function(event){
		// $('#dlg_AyudaEscuelas').modal('show');
		// event.preventDefault();	
	// });	
	
	//
	$('#btn_ConsultaAyudaEscuela').click(function(event){
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		if($('#txt_NombreBusqueda').val().makeTrim(" "))
		{
			showalert(LengStrMSG.idMSG400, "", "gritter-info");			
		}
		else
		{
			cargarGridEscuelas();
		}	
		event.preventDefault();	
	});	
	
	//GRID ESCUELAS
	function cargarGridEscuelas()
	{
		$("#grid_ayudaEscuelas").jqGrid('setGridParam',	{ 
			url: 'ajax/json/json_fun_obtener_escuelas_colegiaturas.php?iTipoEscuela=2&iConfiguracion=0&iOpcion=1' +
			'&iEstado='+$('#cbo_Estado').val()+'&iMunicipio='+$('#cbo_Ciudad').val()+'&iBusqueda='+$('#cbo_TipoConsulta').val()+
			'&sBuscar='+$('#txt_NombreBusqueda').val().toUpperCase().makeTrim(" ")+'&iAyuda=1' + '&session_name=' + Session
		}).trigger("reloadGrid");
	}
	
	function ConsultaEmpleado(callback)
	{	
		$.ajax({type:'POST',
			url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
			data:{'session_name' : Session},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != 0)
				{
					Sueldo=accounting.unformat(dataJson[0].sueldo);
					$("#txt_SueldoMensual").val(dataJson[0].sueldo);
					$("#txt_TopeProp").val(dataJson[0].topeproporcion);
					nAntiguedad=dataJson[0].antiguedad;
					dFechaValida=formatearFecha2(1,dataJson[0].fec_alta);
					// $("#txt_Rfc_Emp").val(dataJson[0].rfc);
					// $("#txt_Rfc_Emp").val("COP920428Q20");
				}
				else
				{
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
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
	
	function CompararFechaFactura(fechaF){
		if($("#txt_Limitado").val()==1)
		{
			if(parseInt(dFechaValida)>=parseInt(fechaF))
			{
				showalert(LengStrMSG.idMSG401, "", "gritter-info");
				$("#txt_FechaCap" ).datepicker("setDate",new Date());
			}
		}
	}
	function CargarDatosGenerales()
	{
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_calcular_topes_colegiaturas.php?",
			data: { 
				'iSueldo':Sueldo,
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){			
				var dataJson = JSON.parse(data);
				if(dataJson != 0 )
				{
					var ImporteFormato=accounting.formatMoney((Sueldo/2),"", 2);
					$("#txt_TopeMensual").val(ImporteFormato);
					//$("#txt_TopeProp").val(dataJson.topeAnual);
				//	$("#txt_TopeMensual").val(dataJson.topeMensual);
					// console.log($("#txt_SueldoMensual").val());
					ImporteFormato=accounting.formatMoney(dataJson.acumulado, "", 2);
					$("#txt_AcumFactPag").val(ImporteFormato);
					ImporteFormato=accounting.unformat($("#txt_TopeProp").val())-accounting.unformat($("#txt_AcumFactPag").val());
					if($("#txt_Limitado").val()==1) 
					{
						if(ImporteFormato<=0)
						{
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no puedes subir facturas.'}});
						}	
					}		
					ImporteFormato=accounting.formatMoney(ImporteFormato, "", 2);
					$("#txt_TopeRest").val(ImporteFormato);
					
					// console.log("Tope");
					// console.log($("#txt_Limitado").val());
					
				}
				else
				{
				//error
					showalert(LengStrMSG.idMSG88+" los datos generales", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	
	//todos los Combos
	//Combo de escuela
	function CargarEscuelas(){
		// console.log("iEscuelaFac: " + iEscuelaFac);
		var Escuela="";
		$("#cbo_Escuela").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_consultar_escuela_rfc.php?",
			data: { 
				//session_name:Session,
				'nOpcion':2,
				//'cRFCescuela':$('#txt_RFC').val()
				'cRFCescuela':DOMPurify.sanitize($('#txt_RFC').val())
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);	
				var bloqueda=0;
				// console.log(dataJson.estado);
				if(dataJson.estado > 0){
				
					Escuela="<option value='0' pdf='0'>SELECCIONE ESCUELA</option>"
					// PrimerOpcion=0;
					//console.log(dataJson.datos);
					//$("#btn_Cargar").show();
					for(var i=0;i<dataJson.datos.length; i++)
					{
						iLimpiar=1;
						if(dataJson.datos[i].value != 0)
						{
							Escuela = Escuela + "<option value='" + dataJson.datos[i].value + "'  pdf='" + dataJson.datos[i].pdf + "'>" + dataJson.datos[i].nombre + "</option>"; 
							// if (PrimerOpcion==0){
								// PrimerOpcion=dataJson.datos[i].value;
							// }
						}
						else
						{
							bloqueda=1;
						}	
					}
					
					if(bloqueda==1 && dataJson.datos.length==1)
					{
						//message('No se puede subir la factura, porque la escuela está bloqueada');
						showalert(LengStrMSG.idMSG402, "", "gritter-info");
						Limpiar();
					}
					else
					{
						$("#cbo_Escuela").html(Escuela);
						$("#cbo_Escuela").val($("#cbo_Escuela").first().val());
						// $("#cbo_Escuela").val(PrimerOpcion);
						$("#cbo_Escuela").trigger("chosen:updated");
						//changeEscuela();
						if(iEscuelaFac!=0)
						{
							$( "#cbo_Escuela" ).val(iEscuelaFac);
							$( "#cbo_Escuela" ).prop('disabled',true);
							CargarEscolaridades();
						}
					}	
				}
				else{
					iLimpiar=0;
					showalert(LengStrMSG.idMSG403, "", "gritter-warning");
					$( '#filePdf' ).ace_file_input('reset_input');
					$( '#fileXml' ).ace_file_input('reset_input');
					$("#cbo_Beneficiario").val(0);
					$("#txt_RFC").val('');
					$("#txt_ImporFact").val('');
					$("#txt_FechaCap").val($("#txt_Fecha").val());
					
					//Limpiar();
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	//Combo Beneficiarios Hoja Azul
	function ObtenerBeneficiariosHojaAzul(callbackB)
	{//
		$("#cbo_Beneficiario").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_beneficiarios_hojaazul_combo.php",
			data: { 
				//'iEmpleado':91047781,
				session_name:Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0)
				{
					for(var i=0;i<dataJson.datos.length; i++)
					{
						Beneficiarios+="<option parentesco='"+ dataJson.datos[i].parentesco+"' value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					/*$("#cbo_Beneficiario").html(option);
					$( "#cbo_Beneficiario" ).val($("#cbo_Beneficiario option:first").val());
					$( "#cbo_Parentesco").val(dataJson.datos[0].value);*/
				}
				else
				{
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG88+" los beneficiarios", "", "gritter-warning");
				}
			},
			error:function onError(){callbackB();},
			complete:function(){callbackB();},
			timeout: function(){callbackB();},
			abort: function(){callbackB();}
		});	
	}
	//Combo Beneficiarios Captura de beneficiarios
	function CargarBeneficiariosCapturados(callbackB)
	{//
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_beneficiarios_combo.php",
			data: { 
				//'iEmpleado':91047781,
				session_name:Session
			},
			beforeSend:function(){},
			success:function(data){			
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0)
				{
					
					for(var i=0;i<dataJson.datos.length; i++)
					{
						Beneficiarios = Beneficiarios + "<option parentesco='"+ dataJson.datos[i].parentesco +"' value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					
					//$("#cbo_Beneficiario").html(option);
				}
				
				/*else
				{
					showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
				}*/
			},
			error:function onError(){callbackB();},
			complete:function(){callbackB();},
			timeout: function(){callbackB();},
			abort: function(){callbackB();}
		});	
	}
	//Combo Parentescos
	function CargarParentescos(callback)
	{
		$("#cbo_Parentesco").html("");
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",
			data: { 
				'iTipo':0
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);	
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Parentesco").html(option);
					$( "#cbo_Parentesco" ).val($("#cbo_Parentesco").first().val());
					$("#cbo_Parentesco").trigger("chosen:updated");
				}
				else
				{
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){callback();});
					showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});	
	}
	//Combo Escolaridades de la escuela seleccionada
	function CargarEscolaridades(){
		$("#cbo_Escolaridad").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_consultar_escuela_rfc.php?",
			data: { 
				session_name:Session,
				'nOpcion':3,
				//'cRFCescuela':$('#txt_RFC').val(),
				//'cNomEscuela':$("#cbo_Escuela option:selected").text()//$('#txt_NombreEscuela').val()
				'cRFCescuela':DOMPurify.sanitize($('#txt_RFC').val()),
				'cNomEscuela':DOMPurify.sanitize($("#cbo_Escuela option:selected").text())//$('#txt_NombreEscuela').val()
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado > 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Escolaridad").html(option);
					$("#cbo_Escolaridad").trigger("chosen:updated");
				}
				else if(dataJson.estado == 0)
				{
					//message(LengStr.idMSG11);
					// showalert(LengStr.idMSG11, "", "gritter-warning");
					$("#cbo_Escolaridad").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					$("#cbo_Escolaridad").trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				}
			},
			error:function onError(){ 
				// message("Error al cargar " + url );
				showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				$('#cbo_Escolaridad').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}	

	function fnConsultarMotivosAclaracion() {
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_motivos_combo.php",
			data: { 'iOpcion':2 },
			beforeSend:function(){},
			success:function(data){
				option = option + "<option value='0'>SELECCIONE</option>";
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if (dataJson.estado==0)
				{
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Aclaracion").trigger("chosen:updated").html(option);
					$("#cbo_Aclaracion").trigger("chosen:updated");
				}	
				else
				{
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
	
	//Combo Tipos de Pagos
	function CargarTiposPagos(){
		$("#cbo_TipoPago").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_pagos.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
			
				var dataS = sanitize(data)
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_TipoPago").html(option);
					$("#cbo_TipoPago").trigger("chosen:updated");
				}
				else if(dataJson.estado == 0)
				{
					//message(LengStr.idMSG11);
					// showalert(LengStr.idMSG11, "", "gritter-warning");
					$("#cbo_TipoPago").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					$("#cbo_TipoPago").trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los tipos de pagos", "", "gritter-error");
				}
			},
			error:function onError(){
				//message("Error al cargar " + url );
				showalert(LengStrMSG.idMSG88+" los tipos de pagos", "", "gritter-error");
				$('#cbo_TipoPago').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	//Combo Periodos
	function CargarPeriodos()
	{
		var option="";
		if($("#cbo_TipoPago").val()==0)
		{
			$("#cbo_Periodo").html("");
			$("#cbo_Periodo").trigger("chosen:updated");
		}
		else
		{
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_obtener_periodos_pagos.php",
				data: { 
					//'iTipoPago':$("#cbo_TipoPago").val()
					'iTipoPago':DOMPurify.sanitize($("#cbo_TipoPago").val())
				},
				beforeSend:function(){},
				success:function(data){
					var dataS = sanitize(data)
					var dataJson = JSON.parse(dataS);
					if(dataJson.estado == 0)
					{
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						$("#cbo_Periodo").trigger("chosen:updated").html(option);
						$("#cbo_Periodo").trigger("chosen:updated");
						if(sPeriodos!="")//Carga el perido
						{
							aPeriodos = sPeriodos.split(",");
							$('#cbo_Periodo').val(aPeriodos).trigger("chosen:updated");
							$("#cbo_Periodo").trigger("chosen:updated");
						}
					}
					else
					{
						//message(dataJson.mensaje);
						showalert(LengStrMSG.idMSG88+" los periodos de pago", "", "gritter-error");
						$("#cbo_Periodo").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
						$("#cbo_Periodo").trigger("chosen:updated");
					}					
					//Si la opcion es de inscripción se debe de seleccionar automaticamente la inscripción.
					if($("#cbo_TipoPago").val().toString().makeTrim(" ") == "1")
					{
						$("#cbo_Periodo").val("1");
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
	
	//Combo Ciclos escolares
	function CargarCiclosEscolares(){
		$("#cbo_CicloEscolar").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_CicloEscolar").html(option);
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				}
				else if(dataJson.estado == 0)
				{
					//message(LengStr.idMSG11);
					// showalert(LengStr.idMSG11, "", "gritter-warning");
					$("#cbo_CicloEscolar").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
				}
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
	
	//COMBO GRADOS ESCOLARES
	function CargarGrados()
	{
		if($("#cbo_Escolaridad").val() != 0)
		{
			$("#cbo_Escolaridad").val();
			$("#cbo_Grado").html("");
			$.ajax({
				type: "POST", 
				url: "ajax/json/json_fun_obtener_grados_escolares.php?",
				data: {
					//'iEscolaridad':$("#cbo_Escolaridad").val()
					'iEscolaridad':DOMPurify.sanitize($("#cbo_Escolaridad").val())
				},
				beforeSend:function(){},
				success:function(data){
					var dataS = sanitize(data);
					var dataJson = JSON.parse(dataS);
					if(dataJson.estado == 0)
					{
						var option = "";
						option = option + "<option value='-1'>" +"SELECCIONE" + "</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
						}
						$("#cbo_Grado").html(option);
						$( "#cbo_Grado" ).val($("#cbo_Grado").first().val());
						if($("#cbo_Escolaridad").val()== 1)//Maternidad
						{
							$( "#cbo_Grado" ).val(0);
							$( "#cbo_Grado" ).prop('disabled',true);
						}
						else
						{
							$( "#cbo_Grado" ).prop('disabled',false);
						}
						if(iEscolaridadB!=0)
						{
							$( "#cbo_Grado" ).val(iGradoB);
						}
					}
					else
					{
						// showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
						showalert(dataJson.mensaje, "", "gritter-warning");
					}
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		}	
		else
		{
			var option = "";
			option = option + "<option value='-1'>" +"SELECCIONE" + "</option>"; 	
			$("#cbo_Grado").html(option);
			$( "#cbo_Grado" ).val($("#cbo_Grado").first().val());
		}
	}
	
	function CargarEstados(callback)
	{
		$("#cbo_Estado").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_estados_escolares.php",
			data: {
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Estado").html(option);
					$( "#cbo_Estado" ).val($("#cbo_Estado").first().val());
				
				}
				else
				{
					showalert("Ocurrio un problema al consultar los estados", "", "gritter-warning");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	function CargarCiudades()
	{
		
		$("#cbo_Ciudad").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_municipios_escolares.php?",
			data: {
				//'iEstado':$("#cbo_Estado").val()
				'iEstado':DOMPurify.sanitize($("#cbo_Estado").val())
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				if(dataJson.estado == 0)
				{
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Ciudad").html(option);
					$( "#cbo_Ciudad" ).val($("#cbo_Ciudad").first().val());
					
				}
				else
				{
					showalert("Ocurrio un problema al consultar las ciudades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
		
	}
	//GRID
	function EstructuraGridBeneficiarios(){
		jQuery("#grid_Beneficiarios").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG8,
				colModel:[
				{name:'idu_hoja_azul',index:'idu_hoja_azul', width:90, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'idu_beneficiario',index:'idu_beneficiario', width:90, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'nom_beneficiario',index:'nom_beneficiario', width:269, sortable: false,align:"left",fixed: true},
				{name:'idu_parentesco',index:'idu_parentesco', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_parentesco',index:'nom_parentesco', width:120, sortable: false,align:"left",fixed: true},
				{name:'idu_tipo_pago',index:'idu_tipo_pago', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'des_tipo_pago',index:'des_tipo_pago', width:120, sortable: false,align:"left",fixed: true},
				{name:'nom_periodo',index:'nom_periodo', width:150, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'idu_escolaridad',index:'idu_escolaridad', width:180, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_escolaridad',index:'nom_escolaridad', width:153, sortable: false,align:"left",fixed: true},
				{name:'idu_grado',index:'idu_grado', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_grado',index:'nom_grado', width:200, sortable: false,align:"left",fixed: true},
				{name:'idu_ciclo',index:'idu_ciclo', width:220, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_ciclo_escolar',index:'nom_ciclo_escolar', width:100, sortable: false,align:"left",fixed: true},
				{name:'imp_importe',index:'imp_importe', width:80, sortable: false,align:"right",fixed: true, hidden: true},
				{name:'imp_importeF',index:'imp_importeF', width:80, sortable: false,align:"right",fixed: true},
				{name:'keyx',index:'keyx', width:120, sortable: false,align:"left",fixed: true, hidden:true}
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
				var grid = $('#grid_Beneficiarios');
				iTotalFacturaCargada = grid.jqGrid('getCol', 'imp_importe', false, 'sum');
				$("#txt_Tolal").val(accounting.formatMoney(iTotalFacturaCargada, "", 2));
				
			},
			onSelectRow: function(id) {
				if(id >= 0){
				
					var fila = jQuery("#grid_Beneficiarios").getRowData(id); 
					iBeneficiario=fila['idu_beneficiario'];
					iKeyx = fila['keyx'];
					iParentescoB=fila['idu_parentesco'];
					iTipoPagoB=fila['idu_tipo_pago'];
					
					sPeriodos=fila['nom_periodo'];
					iEscolaridadB=fila['idu_escolaridad'];
					iGradoB=fila['idu_grado'];
					iCicloB=fila['idu_ciclo'];
					iImporteB=fila['imp_importe'];
				} else {
					iKeyx=0;
					iParentescoB=0;
					iTipoPagoB=0;
					sPeriodos='';
					iEscolaridadB=0;
					iGradoB=0;
					iCicloB=0;
					iImporteB=0;
				}
			}				
		});
	}
	
	function MostrarGridEscuelas()
	{
		jQuery("#grid_ayudaEscuelas").jqGrid({
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG65,
		colModel:[
				{name:'idu_escuela',index:'idu_escuela', width:100, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'rfc_clave_sep',index:'rfc_clave_sep', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_escuela',index:'nom_escuela', width:310, sortable: false,align:"left",fixed: true},				
				{name:'opc_tipo_escuela',index:'opc_tipo_escuela', width:100, sortable: false,align:"left",fixed: true, hidden:true },				
				{name:'nom_tipo_escuela',index:'nom_tipo_escuela', width:120, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'clave_sep',index:'clave_sep', width:90, sortable: false,align:"left",fixed: true },
				{name:'escolaridad',index:'escolaridad', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_escolaridad',index:'nom_escolaridad', width:120, sortable: false,align:"left",fixed: true },
				{name:'opc_obligatorio_pdf',index:'opc_obligatorio_pdf', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_obligatorio',index:'nom_obligatorio', width:350, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'opc_escuela_bloqueada',index:'opc_escuela_bloqueada', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_bloqueada',index:'nom_bloqueada', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'fec_captura',index:'fec_captura', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				
				{name:'opc_educacion_especial',index:'opc_educacion_especial', width:100, sortable: false,align:"left",fixed: true,hidden:true },
				{name:'nom_educacion_especial',index:'nom_educacion_especial', width:100, sortable: false,align:"left",fixed: true,hidden:true },
				{name:'idu_tipo_deduccion',index:'idu_tipo_deduccion', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_tipo_deduccion',index:'nom_tipo_deduccion', width:100, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'observaciones',index:'observaciones', width:100, sortable: false,align:"left",fixed: true, hidden:true}
				],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			pgbuttons:true,
			loadonce: null,//false,
			//shrinkToFit: false,
			height: 205,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			width:550,
			rowNum:5,
			//rowList:[10, 20, 30],
			pager: '#grid_ayudaEscuelas_pager',
			sortname: 'nom_escuela',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			caption: 'Escuelas Privadas',
			loadComplete: function (Data) {
				var registros = jQuery("#grid_ayudaEscuelas").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert("No hay información", "", "gritter-info");
				}
				var table = this;
				//updatePagerIcons(table);
				
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(id)
			{
				var rowData = jQuery(this).getRowData(id)
				// sEscuela=rowData.nom_escuela;
				// nEscuelaSeleccionada==rowData.idu_escuela;
				idEscuelaVinculada=rowData.idu_escuela;
				fnGuardarEscuela();
				$("#dlg_AyudaEscuelas").modal('hide');
				
			}		
		});	
		jQuery("#grid_ayudaEscuelas").jqGrid('navGrid','#grid_ayudaEscuelas_pager',{search:false, edit:false,add:false,del:false});	
		jQuery("#grid_ayudaEscuelas_pager_left").hide();
	}	
	//BOTONES
	$( '#btn_Otro' ).click(function(event){
		Limpiar();
		event.preventDefault();
	});
	
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
	function Limpiar()
	{
		var escuela="<option value='0' >SELECCIONE ESCUELA</option>";
		$( '#fileXml' ).ace_file_input('reset_input');
		$( '#filePdf' ).ace_file_input('reset_input');
		$('#txt_ifactura').val(0);
		$("#txt_EditarFactura").val(0)
		$('#txt_ImporFact').val('');
		$('#cbo_Escuela').html(escuela);
		$("#cbo_Escuela").prop('disabled',false);
		$("#cbo_Escuela").trigger("chosen:updated");
		$("#cbo_Beneficiario").val(0);
		$('#txt_idEscuela').val('');
		$('#txt_RFC').val('');
		$("#txt_MotivoAclaracion").val("");
		$("#hidden_MotivoAclaracion").val("");
		$( "#cbo_Aclaracion" ).val(0);
		$("#txt_FechaCap").val($("#txt_Fecha").val());
		iKeyx=0, iMod=0, iParentescoB=0,iTipoPagoB=0,sPeriodos='',iEscolaridadB=0, iGradoB=0, iCicloB=0, iImporteB=0, iEscuelaFac=0;
	}//txt_Descuento
	$('#btn_AgregarB').click(function(event){
		imp_compara=$("#txt_importe_compara").val();
		cad_imp_concepto=$("#txt_importeConcep").val();
		imp_concepto=cad_imp_concepto.replace(",", "");
		imp_concepto=imp_concepto*100;
		if($("#cbo_Beneficiario").val()==0)
		{
			//message('Seleccione el beneficiario, por favor');
			showalert('Seleccione el beneficiario, por favor', "", "gritter-info");
		}
		else if($("#cbo_TipoPago").val()==0)
		{
			//message('Seleccione el tipo de pago, por favor');
			showalert("Seleccione el tipo de pago, por favor", "", "gritter-info");
		}
		else if ($("#cbo_Periodo").val() == null)
		{
			//message('Seleccione los periodos, por favor');
			showalert("Seleccione los periodos, por favor", "", "gritter-info");
		}
		else if($("#cbo_Escolaridad").val()==0)
		{
			//message('Seleccione la escolaridad, por favor');
			showalert("Seleccione la escolaridad, por favor", "", "gritter-info");
		}
		else if($("#cbo_Grado").val()==-1)
		{
			//message('Seleccione el grado escolar, por favor');
			showalert("Seleccione el grado escolar, por favor", "", "gritter-info");
		}
		else if($("#cbo_CicloEscolar").val()==0)
		{
			//message('Seleccione el ciclo escolar, por favor');
			showalert("Seleccione el ciclo escolar, por favor", "", "gritter-info");
		}
		else if($("#cbo_Importes").val()==0)
		{
			//message('Seleccione el importe, por favor');
			showalert("Seleccione el importe, por favor", "", "gritter-info");
		}
		else if(($("#cbo_Escolaridad").val()==6) && ($("#cbo_Parentesco").val()!=11))//MAestria solo el empleado
		{	
			//message('No es posible generar esta factura');
			showalert("No es posible generar esta factura", "", "gritter-info");
		}
		else if (imp_concepto>imp_compara) //El importe es mayor que el de la factura
		{	
			//message('No es posible generar esta factura');
			showalert("El importe capturado es mayor al importe de la factura", "", "gritter-info");
		}
		else
		{
			//fnPrecargarBeneficiarios(1);//Validar Costos
			fnAgregarBeneficiario();
		}
		event.preventDefault();	
	});
	
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
				'iEscuela':$("#cbo_Escuela").val(),
				'iEscolaridad':$("#cbo_Escolaridad").val(),
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
							$("#cbo_Grado").val(0);
							$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar").first().val());
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
							$("#cbo_Grado").val(0);
							$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar").first().val());
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
	//BOTON GUARDAR
	$("#btn_Guardar").click(function(event){
		if($("#fileXml").val() == ''){
			showalert("Proporcione el XML de la factura", "", "gritter-info");
			$("#fileXml").focus();
		}else if($("#txt_RFC").val().makeTrim(" ") == ''){
			showalert("Proporcione el XML de la factura", "", "gritter-info");
			$("#fileXml").focus();
		}else if($("#cbo_Beneficiario").val() == 0){
			showalert("Seleccione un beneficiario", "", "gritter-info");
			$("#cbo_Beneficiario").focus();
		}else{
			iFactura = $("#txt_ifactura").val();
			if(iFactura == ''){
				$("#txt_ifactura").val(0);
			}			
			fnValidarGuardado();
			event.preventDefault();
		}
	});
	
	//BOTON MOTIVO ACLARACION
	$('#btn_MotivoAclaracion').click(function(event){
		if($("#cbo_Aclaracion").val()==0)
		{
			showalert("Seleccione el motivo de aclaración","", "gritter-warning");
			$("#cbo_Aclaracion").focus();
		}
		else if($("#txt_MotivoAclaracion").val().makeTrim(" ")=='')
		{
			showalert("Proporcione justificación de aclaración","", "gritter-warning");	
			$("#txt_MotivoAclaracion").focus();
		}
		else
		{
			//$("#hidden_MotivoAclaracion").val($("#txt_MotivoAclaracion").val().toUpperCase());
			var sMotivo=$('#cbo_Aclaracion option:selected').html()+': '+$("#txt_MotivoAclaracion").val().makeTrim(" ").toUpperCase();
			$("#hidden_MotivoAclaracion").val(sMotivo);
			$("#dlg_AgregarAclaracion").modal('hide');
			
			fnValidarGuardado();
		}	
		event.preventDefault();	
	});	
	
	
	//VALIDAR GUARDADO
	function fnValidarGuardado()
	{
		//$("#hidden_MotivoAclaracion").val($("#txt_MotivoAclaracion").val().toUpperCase());
		var TotalF =accounting.unformat($("#txt_ImporFact").val());
		iTotalFacturaCargada=accounting.unformat(iTotalFacturaCargada);
		//console.log (TotalF+'='+iTotalFacturaCargada);
		if(TotalF==iTotalFacturaCargada)
		{
			$("#txt_MotivoAclaracion").val("");
			$("#hidden_MotivoAclaracion").val("");
		}
		 // if ( ($("#txt_RFC").val() == '') {
			// message('Agregue los detalles de la factura, por favor');	
			// showalert("Favor de seleccionar un XML", "", "gritter-info");
			// $("#nom_xml").focus();
		 // }
		else if( TotalF<iTotalFacturaCargada)
		{
			//message('El importe total de la factura es menor a los detalles capturados de la factura, favor de verificar');
			showalert("El importe total de la factura es menor a los detalles capturados de la factura, favor de verificar", "", "gritter-info");
		}
		else if((TotalF!=iTotalFacturaCargada)&&($("#cbo_Aclaracion").val()==0))
		{
			// if($("#hidden_MotivoAclaracion").val()=="")
			// {
				// showalert("Favor de seleccionar el motivo y justificar la aclaración", "", 'gritter-warning');
			// }
			// else
			// {
				// showalert("Favor de seleccionar el motivo y justificar la  aclaración", "", 'gritter-warning');
			// }
			$( "#cbo_Aclaracion").val(0);
			$( "#txt_MotivoAclaracion").val('');
			$("#dlg_AgregarAclaracion").modal('show');
		}
		// else if((TotalF!=iTotalFacturaCargada)&&($("#hidden_MotivoAclaracion").val()==""))
		// {
			// showalert("Favor de seleccionar el motivo y justificar de aclaración", "", 'gritter-warning');
			// $( "#cbo_Aclaracion").val(0);
			// $("#dlg_AgregarAclaracion").modal('show');
		// }
		
		else if((iPdf==1) && ($("#filePdf").val()==""))
		{
			//message("Favor de seleccionar un pdf");
			showalert("Favor de seleccionar un pdf", "", "gritter-info");
			$("#filePdf").focus();
		}else if($("#txt_RFC").val().length == ''){
			showalert("Seleccione un XML", "", "gritter-info");
		}
		else{
			// if($("#txt_ifactura").val()==0){
				fnGuaradarFactura();
			// }
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
	
	//BOTON EDITAR
	$('#btn_Editar').click(function(event){
		if ( ($("#grid_Beneficiarios").find("tr").length - 1) == 0 ) 
		{
			//message('No existen registros para editar');
			showalert("No existen registros para editar", "", "gritter-info");
		}
		else if(iKeyx==0)// no se a seleccionado el registro
		{
			//message('Seleccione el registro para editar');
			showalert("Seleccione el registro para editar", "", "gritter-info");
		}
		else //Editar
		{
			// Cambiar los títulos de la ventana modal
			$("#tit_modal_beneficiario_eprv").html("<i class=\"icon-file-text-alt\"></i>&nbsp;Modificar Beneficiario");
			$("#btn_AgregarB").html("<i class=\"icon-save bigger-110\"></i>Guardar</button>");
			
			iMod=iKeyx;
			//iKeyx
			$("#cbo_Beneficiario").val(iBeneficiario);
			$("#cbo_Parentesco").val(iParentescoB);
			$("#cbo_Escolaridad").val(iEscolaridadB);
			$("#cbo_TipoPago").val(iTipoPagoB);
			
			$("#cbo_CicloEscolar").val(iCicloB);
			$("#cbo_Importes").val(iImporteB);
			//$("#dlg_AgregarDetalle").dialog('open');
			$('#dlg_AgregarDetalle').modal('show');
			CargarGrados();
			CargarPeriodos();
		}
		event.preventDefault();	
	});	
	
	//BOTON ELIMINAR
	$('#btn_Eliminar').click(function(event){
		if ( ($("#grid_Beneficiarios").find("tr").length - 1) == 0 ) 
		{
			//message('No existen registros para eliminar');
			showalert("No existen registros para eliminar", "", "gritter-info");
		}
		else if(iKeyx==0)// no se a seleccionado el registro
		{
			//message('Seleccione el registro para eliminar');
			showalert("Seleccione el registro para eliminar", "", "gritter-info");
		}
		else //Elimina
		{
			$("#btn_Eliminar").prop('disabled', true);
			bootbox.confirm('¿Desea eliminar el registró?', 
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
	//Metodos
	
	function fnSubirFactura()
	{	
		// console.log('fnSubirFactura');
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
			beforeSubmit: function(){
				waitwindow('Guardando Factura ... ','open');
			}, 
			uploadProgress: function(){	},
			success: function(data)
			{
				waitwindow('Guardando Factura ... ','close');
				var dataJson = JSON.parse(data);
				//console.log("el estado es: " + dataJson.estado);
				//console.log(dataJson);
				// console.log(dataJson.estado+'='+dataJson.mensaje);				
				//alert(dataJson.estado+'='+dataJson.mensaje);
				if ((dataJson.estado == 1) || (dataJson.estado == 2))
				{
					// showmessage(dataJson.mensaje, '', undefined, undefined, function onclose()
					// {
					if (dataJson.estado == 1)
					{
						showalert("Factura registrada correctamente", "", "gritter-info");
						$("#cbo_Beneficiario").val(0);
						$("#cbo_Beneficiario").trigger("chosen:updated");
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
						//console.log("entramos aqui en este error 1014");
						showalert('Ocurrio un problema al subir la factura: ' + dataJson.mensaje, "", "gritter-error");
						Limpiar();
					}else{
						showalert(dataJson.mensaje, "", "gritter-error");
						Limpiar();
					}
					
					// Limpiar();
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
		$( '#xmlupload' ).attr("action", "ajax/proc/proc_subir_XML_Colegiaturas.php");
		$( '#xmlupload' ).ajaxForm(opciones);
		$( '#xmlupload' ).submit();
	}	
	function fnGuaradarFactura(){
		var sFecha=formatearFecha($('#txt_FechaCap').val());
		
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_grabar_stmp_facturas_colegiaturas.php?",
			data: { 
				session_name:Session,
				'iOpcion':1,
				'cFolioFiscal':$("#txt_Folio").val(),
				'iEscuela':0,
				'fecha':sFecha
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				//console.log(dataJson);
				if(dataJson.estado == 0)
				{
					$("#txt_ifactura").val(dataJson.factura);
					$("#cbo_Escuela").prop('disabled',true);
					
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
	
	function fnConsultarDetalles()
	{
		// if($("#txt_EditarFactura").val()==0)
		// {
			iFactura=$("#txt_ifactura").val();
			if (iFactura==''){
				iFactura=0;
			}
			
			$("#grid_Beneficiarios").jqGrid('setGridParam',
			{ url: 'ajax/json/json_fun_obtener_stmp_facturas_colegiaturas.php?cFolio='+$("#txt_Folio").val()+'&iFactura=' +iFactura+'&session_name=' +Session}).trigger("reloadGrid"); 
		// }
		// else
		// {
			// $("#grid_Beneficiarios").jqGrid('setGridParam',
			// { url: 'ajax/json/json_fun_obtener_detalle_factura_colegiatura.php?cFolio='+$("#txt_Folio").val()+'&iFactura=' +$("#txt_ifactura").val()+'&session_name=' +Session}).trigger("reloadGrid"); 
		// }
		iKeyx=0,iMod=0,iBeneficiario=0,iParentescoB=0, iTipoPagoB=0, sPeriodos='', iEscolaridadB=0, iGradoB=0, iCicloB=0, iImporteB=0;
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
	function fnConsultarParametro(iOpcion)
	{
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parametros_colegiaturas.php",
			data: { 
					session_name:Session,
					'iOpcion':iOpcion
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0)
				{
					iDescuentosDiferentes=dataJson.respuesta;
				}
				else 
				{
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
	
	function fnConsultarDatosFactura(callback)
	{//$("#txt_EditarFactura").val()
		//fun_obtener_factura_colegiatura
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
					
					//$("#cbo_Escuela").prop('disabled',false);
					$("#fileXml").prop('disabled',false);
					//$("#filePdf").prop('disabled',false);
					CargarEscuelas();
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
	
	function fnEmpleadoBloqueado()
	{//
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_consulta_empleado_colegiatura.php?",
			data: { 
					//'iEmpleado':$("#txt_Empleado").val(),
					'session_name': Session
				},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				//console.log(dataJson);
				if(dataJson != null)
				{	
					$("#txt_Limitado").val(0);
					if(dataJson.LIMITADO==1)
					{
						$("#txt_Limitado").val(1);
						if(nAntiguedad<12)
						{
							$("#txt_Bloqueado").val(1);
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'No cuenta con esta prestación.'}});
						}
						else if(dataJson.BLOQUEADO==1)
						{
							$("#txt_Bloqueado").val(1);
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no puedes subir facturas.'}});
							
						} 
						else 
						{
							$("#txt_Bloqueado").val(0);
						}
					} 
					else if(dataJson.BLOQUEADO==1)
					{
						$("#txt_Bloqueado").val(1);
						loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'De momento no puedes subir facturas.'}});
						
					} 
					else 
					{
						$("#txt_Bloqueado").val(0);
					}
				}
				else
				{
					if(nAntiguedad<12)
					{
						
						$("#txt_Limitado").val(1);
						$("#txt_Bloqueado").val(1);
						loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'No cuenta con esta prestación.'}});
					}
					else
					{				
						
						$("#txt_Limitado").val(1);
						$("#txt_Bloqueado").val(0);
					}	
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});		
	}
	
	function fnPrecargarBeneficiarios(Opcion, callback)
	{//Opcion=0 Precargar Opcion=1 Valida Costo
		if($("#cbo_Beneficiario").val()!=0)
		{
			waitwindow('Cargando beneficiario','open');
			$.ajax({type: "POST", 
			url: "ajax/json/json_fun_precargar_captura_empleado_beneficiarios.php?",
			data: { 
					//'iEmpleado':$("#txt_Empleado").val(),
					'iBeneficiario': $("#cbo_Beneficiario").val(),
					'iEscuela': $("#cbo_Escuela").val(),
					'iEscolaridad':$("#cbo_Escolaridad").val(),
					'iGrado':$("#cbo_Grado").val(),
					'session_name': Session
				},
				beforeSend:function(){},
				success:function(data){
					var dataJson = JSON.parse(data);
					//console.log(dataJson);
					if(dataJson != null)
					{	
						// if(Opcion==0)//Costo Autorizado
						// {
							// if(dataJson.idu_costo_conf == 2)
							// {
								// showalert("Gerente pendiente de validar costos", "", "gritter-warning");
							// }
							// else if(dataJson.idu_costo_conf==1 )
							// {
							
								// showalert("Pendiente de capturar costos para el beneficiario seleccionado", "", "gritter-warning");
							// }
							// else
							// {	
								//Precargar los datos del beneficiario
								if(dataJson.nom_periodo!='')
								{
									$("#cbo_TipoPago").val(dataJson.idu_tipo_pago);
									$("#cbo_Escolaridad").val(dataJson.idu_escolaridad);
									$("#cbo_CicloEscolar").val(dataJson.idu_ciclo); // Debe seleccionar el ciclo más nuevo
									$("#cbo_CicloEscolar").val($("#cbo_CicloEscolar").first().val());
									//$("#txt_importeConcep").val("0.00");
									// $("#cbo_CicloEscolar").val(dataJson.idu_ciclo); // Debe seleccionar el ciclo más nuevo
									// $("#txt_importeConcep").val(dataJson.imp_importe);
									sPeriodos=dataJson.nom_periodo;
									iEscolaridadB=dataJson.idu_escolaridad;
									iGradoB=dataJson.idu_grado;
									CargarGrados();
									CargarPeriodos();
								}	
							// }	
						// }
						// else
						// {
							// if(dataJson.idu_costo_conf==0)
							// {
								// fnAgregarBeneficiario();
							// }
							// else if(dataJson.idu_costo_conf==2 )//Costo Sin Autorizado
							// {
								// showalert("Gerente pendiente de validar costos", "", "gritter-warning");
							// }
							// else//if(dataJson.idu_costo_conf==0 )//Costo Sin Autorizado
							// {	
								// showmessage('No se ha capturado este costo', '', undefined, undefined, function onclose(){ });
								// showalert("NO SE HA CAPTURADO ESTE COSTO", "", "gritter-warning");
								// showalert("Pendiente de capturar costos para el beneficiario seleccionado", "", "gritter-warning");
							// }
						// }
					}
				},
				error:function onError(){waitwindow('Cargando beneficiario','close');},
				complete:function(){waitwindow('Cargando beneficiario','close');},
				timeout: function(){waitwindow('Cargando beneficiario','close');},
				abort: function(){waitwindow('Cargando beneficiario','close');}
			});		
			waitwindow('Cargando beneficiario','close');
		}	
	}

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 382
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