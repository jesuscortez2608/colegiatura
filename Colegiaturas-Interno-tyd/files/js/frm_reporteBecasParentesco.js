$(function(){
	waitwindow('Cargando','open');
	setTimeout(InicializarFormulario(), 0);
});

//==========/ FUNCIONES /=====================================================//
function InicializarFormulario(){
	CrearControlesFechas();
	CrearGridReporte();
	CargarComboRutaPago(function(){
		CargarComboRegiones(function(){
			CargarComboTiposDeducciones(function(){
				CargarComboEscolaridades(function(){
					CargarComboParentescos(function(){
						CargarEmpresas(function(){
							DesbloquearFormulario();
						});
					});
				});
			});
		});
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


function DesbloquearFormulario(){
	waitwindow('Cargando','close');
}

	function CargarComboRutaPago(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_rutas_pago.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='-1'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_rutaPago").html(option);
				$("#cbo_rutaPago").trigger("chosen:updated");
			} else {
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

	function CargarComboCiudades(){
		if($(cbo_Region).val() > 0){
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_catalogociudades.php",
				data: {
					'region':$(cbo_Region).val()
				}
			}).done(function(data) {
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Ciudad").html(option);
					$("#cbo_Ciudad").trigger("chosen:updated");
				} else {
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				}
			})
			.fail(function(s) {
				showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				$('#cbo_Ciudad').fadeOut();
			})
			.always(function() {});
		} else {
			var option = "<option value='0'>TODAS</option>";
			$("#cbo_Ciudad").html(option);
		}	
	}

	function CargarComboRegiones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_Region").html(option);
				$("#cbo_Region").trigger("chosen:updated");
			} else {
				showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {
			callback();
		});
	}

	function CargarComboTiposDeducciones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoDeduccion").html(option);
				$("#cbo_tipoDeduccion").trigger("chosen:updated");
			} else {
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
	}

	function CargarComboEscolaridades(callback)
	{
		$.ajax({
			type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {}
		})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
				}
				$("#cbo_Escolaridad").html(option);
				$("#cbo_Escolaridad").trigger("chosen:updated");
			} else {
				showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
			}
		})
		.fail(function(s){
			showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
		})
		.always(function(){
			callback();
		});
	}

	function CargarComboParentescos(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_parentescos.php",
			data: { 'iTipo':1},
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_Parentesco").html(option);
				$("#cbo_Parentesco").trigger("chosen:updated");
			} else {
				showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
		})
		.always(function() {
			callback();
		});
	}
	function CargarEmpresas(callback){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_listado_empresas_colegiaturas.php',
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
					$("#cbo_Empresa").html(option);
					var Sel = $("#cbo_Empresa option").first().val();
					$("#cbo_Empresa").val(Sel);
				}
			},
			error:function onError(){},
			complete:function(){callback()},
			timeout: function(){},
			abort: function(){}
		});
	}

	function CrearControlesFechas(){
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
			
	function CrearGridReporte(){
		jQuery("#gridParentescoEscolaridad-table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG25,
			colModel:[
				{name:'Empresa', 			index:'Empresa', 				width:220, sortable: false, align:"left",  fixed: true},
				{name:'Parentesco',			index:'Parentesco', 			width:220, sortable: false, align:"left",  fixed: true},
				{name:'total_beneficiarios',index:'total_beneficiarios', 	width:160, sortable: false, align:"right", fixed: true},
				{name:'total_facturas',		index:'total_facturas', 		width:160, sortable: false, align:"right", fixed: true},
				{name:'prc_beneficiarios',	index:'prc_beneficiarios', 		width:160, sortable: false, align:"right", fixed: true},
				{name:'prc_facturas',		index:'prc_facturas', 			width:170, sortable: false, align:"right", fixed: true}
			],
			
			scrollrows : true,
			viewrecords : true,
			rowNum:-1,
			loadonce: false,
			hidegrid: false,
			rowList:[],
			// width: 900,
			width: null,
			shrinkToFit: false,
			height: 350,
			caption: 'Becas por Tipo Beneficiario',
			pager: '#gridParentescoEscolaridad-pager',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			loadComplete: function (Data) {
				var registros = jQuery("#gridParentescoEscolaridad-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(Numemp) {
				var Data = jQuery("#gridParentescoEscolaridad-table").jqGrid('getRowData',Numemp);
				Numemp =Data.Numemp;
			}
		});
		barButtongrid({
				pagId:"#gridParentescoEscolaridad-pager",
				position:"left",//center right
				Buttons:[
				{
					icon:"icon-print blue",
					title:'Imprimir',
					click:function (event){
						if (($("#gridParentescoEscolaridad-table").find("tr").length - 1) == 0 ) {
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						} else {
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

/////////////////BOTON CONSULTAR/////////////////////
	$('#btn_consultar').click(function(event) {
		llenarGridReporteParentesco();
		event.preventDefault();	
	});
	
	function llenarGridReporteParentesco() {
		var iRutaPago = $('#cbo_rutaPago').val();
		var iRegion = $('#cbo_Region').val();
		var iCiudadParametro = $('#cbo_Ciudad').val();
		var iDeduccionParametro = $('#cbo_tipoDeduccion').val();
		var dFechaIni = formatearFecha($('#txt_FechaInicio').val());
		var dFechaFin = formatearFecha($('#txt_FechaFin').val());
		var iEscolaridad = $('#cbo_Escolaridad').val();
		var iParentesco = $('#cbo_Parentesco').val();
		var iEmpresa = $("#cbo_Empresa").val();
	
		$("#gridParentescoEscolaridad-table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_reporte_becas_por_parentesco.php?&iRutaPago=' + iRutaPago+ '&iRegion='+iRegion+'&dFechaIni=' + dFechaIni+ '&dFechaFin=' +dFechaFin+ '&iEscolaridad=' + iEscolaridad + '&iCiudadParametro='+iCiudadParametro+'&iDeduccionParametro='+iDeduccionParametro +'&iParentesco='+ iParentesco + '&iEmpresa=' + iEmpresa}).trigger("reloadGrid");
	}
	
	////////////////////EXPORTAR PDF/////////////
		
	function GenerarPdf() {
		
		var iRutaPago = $('#cbo_rutaPago').val();
		var iRegion = $('#cbo_Region').val();
		var iCiudadParametro = $('#cbo_Ciudad').val();
		var iDeduccionParametro = $('#cbo_tipoDeduccion').val();
		var dFechaIni = formatearFecha($('#txt_FechaInicio').val());
		var dFechaFin = formatearFecha($('#txt_FechaFin').val());
		var iEscolaridad = $('#cbo_Escolaridad').val();
		var iParentesco = $('#cbo_Parentesco').val();
		var iEmpresa = $("#cbo_Empresa").val();
		
		var cRutaPago = $('#cbo_rutaPago option:selected').html();
		var cRegion = $('#cbo_Region option:selected').html();
		var cCiudadParametro = $('#cbo_Ciudad option:selected').html();
		var cDeduccionParametro = $('#cbo_tipoDeduccion option:selected').html();
		var cEscolaridad = $('#cbo_Escolaridad option:selected').html();
		var cParentesco = $('#cbo_Parentesco option:selected').html();
		var cEmpresa = $("#cbo_Empresa option:selected").html();
		
		var	sUrl = 'ajax/json/json_exportar_reporte_por_parentesco.php?&session_name='+Session;
			sUrl += '&iRutaPago='+iRutaPago;
			sUrl += '&iRegion='+iRegion;
			sUrl += '&dFechaIni='+dFechaIni;
			sUrl += '&dFechaFin='+dFechaFin;
			sUrl += '&iEscolaridad='+iEscolaridad;
			sUrl += '&iCiudad='+iCiudadParametro;
			sUrl += '&iDeduccion='+iDeduccionParametro;
			sUrl += '&iParentesco='+iParentesco;
			sUrl += '&iEmpresa='+iEmpresa;
			sUrl += '&cRutaPago='+cRutaPago;
			sUrl += '&cRegion='+cRegion;
			sUrl += '&cCiudad='+cCiudadParametro;
			sUrl += '&cDeduccion='+cDeduccionParametro;
			sUrl += '&cEscolaridad='+cEscolaridad;
			sUrl += '&cParentesco='+cParentesco;
			sUrl += '&cEmpresa='+cEmpresa;
			
		// console.log(sUrl);
		// return;
		location.href = sUrl;
	}

//==========/ EVENTOS /=====================================================//
$("#cbo_Region").change(function(event){
	CargarComboCiudades();
	event.preventDefault();
});
$("#cbo_Escolaridad").change(function(event){
	event.preventDefault();
});

$("#cbo_rutaPago").change(function(event){
	//alert($("#cbo_rutaPago").val());
	event.preventDefault();
});
