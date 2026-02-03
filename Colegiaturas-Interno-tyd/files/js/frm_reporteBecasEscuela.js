$(function(){
	var iEscuelaSeleccion=0;
	waitwindow('Cargando','open');
	setTimeout(InicializandoFormulario, 0);
	
	$('#dlg_AyudaEscuelas').on('show.bs.modal', function (event) {
		// $("#cbo_Estado").val($("#cbo_Estado option").first().val());
		// $("#cbo_Ciudad").val($("#cbo_Ciudad option").first().val());
		$("#cbo_TipoConsulta").val($("#cbo_TipoConsulta option").first().val());
		$("#txt_NombreBusqueda").val("");
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		if(iEscuelaSeleccion==0)
		{
			$("#txt_Escuela").val("");
			$("#txt_IdEscuela").val("");
			$("#txt_RFC").val("");
		}
		
	});

});

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


	function stopScrolling(callback) {
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
	
//==========/ FUNCIONES /=====================================================//
	function InicializandoFormulario(){
		CrearControlesFechas();
		CreargridBecasEscuela();
		CrearGridEscuelas();
		CargarComboRutaPago(function(){
			CargarComboEstatus(function(){
				CargarComboRegiones(function(){
					CargarComboTiposDeducciones(function(){
						CargarComboEscolaridades(function(){
							DesbloquearFormulario();
							CargarEstados(function(){
								CargarCiudades(function(){
									CargarLocalidades();
								});
							});
						});
					});
				});
			});
		});
		stopScrolling(function(){
			dragablesModal();
		});
		CargarEmpresas();
	}

	function cargarGridEscuelas(){
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		$("#grid_ayudaEscuelas").jqGrid('setGridParam',	{ 
			url: 'ajax/json/json_fun_obtener_escuelas_colegiaturas.php?iTipoEscuela=0&iConfiguracion=1&iOpcion=1' +
			'&iEstado='+$('#cbo_Estado').val()+'&iMunicipio='+$('#cbo_CiudadModal').val()+'&iLocalidad='+$("#cbo_Localidad").val()+'&iBusqueda='+$('#cbo_TipoConsulta').val()+
			'&sBuscar='+$('#txt_NombreBusqueda').val().toUpperCase().replace('/^\s+|\s+$/g', '') + '&session_name=' + Session
		}).trigger("reloadGrid");
	}
	
	function CargarEstados(callback){
		$("#cbo_Estado").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_estados_escolares.php",
			data: {
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0){
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Estado").html(option);
					$( "#cbo_Estado" ).val($("#cbo_Estado option").first().val());
				} else {
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	function CargarCiudades(callback){
		$("#cbo_CiudadModal").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_municipios_escolares.php?",
			data: {
				'iEstado':$("#cbo_Estado").val()
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0){
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_CiudadModal").html(option);
					$( "#cbo_CiudadModal" ).val($("#cbo_CiudadModal option").first().val());
				} else {
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});	
	}
	function CargarLocalidades(){
		$("#cbo_Localidad").html("");
		 $.ajax({
			type: "POST",
			url: "ajax/json/json_fun_obtener_localidades_escolares.php?",
			data:{
				'iMunicipio' : $("#cbo_CiudadModal").val(),
				'iEstado' : $("#cbo_Estado").val()
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					// var option = "<option value='-1'>SELECCIONE</option>";
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].numero + "'>"  + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Localidad").html(option);
					// $("#cbo_Localidad").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'200px'});
					$("#cbo_Localidad").trigger("chosen:updated");
				}else{
					showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		 });
	}
	
	function DesbloquearFormulario(){
		waitwindow('Cargando','close');
	}

	function CargarComboTiposDeducciones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoDeduccion").html(option);
				$("#cbo_tipoDeduccion").trigger("chosen:updated");
			} else {
				showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			}
			callback();
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	}

	function CargarComboEscolaridades(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {}
		}).done(function(data) {
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
			callback();
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las escolaridades" , "", "gritter-error");
		})
		.always(function() {});
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
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Ciudad").html(option);
					$("#cbo_Ciudad").trigger("chosen:updated");
				} else {
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				}
			})
			.fail(function(s) {
				showalert(LengStrMSG.idMSG88+" las ciudades" , "", "gritter-error");
				$('#cbo_Ciudad').fadeOut();
			})
			.always(function() {});
		} else {
			var option = "<option value='0'>TODAS</option>";
			$("#cbo_Ciudad").html(option);
			callback();
		}	
	}

	function CargarComboRutaPago(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_rutas_pago.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='-1'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_rutaPago").html(option);
				$("#cbo_rutaPago").trigger("chosen:updated");
				
			} else{
				showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las rutas de pago" , "", "gritter-error");
		})
		.always(function() {callback();});
	}

	function CargarComboEstatus(callback){
		var option="";
		$.ajax(
			{
				type: "POST",
				url: "ajax/json/json_fun_obtener_estatus_facturas.php",
				data: { } 
			})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				option = option; //+ "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
				}
				$("#cbo_Estatus").html(option);
				$("#cbo_Estatus").trigger("chosen:updated");
				
				$("#cbo_Estatus").val(0);
				$("#cbo_Estatus").trigger("chosen:updated");
			} else {
				showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			$('#cbo_Estatus').fadeOut();})
		.always(function() {callback();});
	}

	function CargarComboRegiones(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_Region").html(option);
				$("#cbo_Region").trigger("chosen:updated");
			} else {
				showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			}
			callback();
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	}
	function CargarEmpresas(){
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

	function CreargridBecasEscuela(){
		jQuery("#gridBecasEscuela-table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG19,
			colModel:[
				{name:'Empresa',	index:'idu_empresa', 	width:400,	sortable: false,	align:"left",	fixed: true},
				{name:'RFC', 		index:'RFC', 			width:400, 	sortable: false, 	align:"left", 	fixed: true},
				{name:'TipoEscuela', index:'TipoEscuela', width:80, sortable: false, align:"left", fixed: true},
				{name:'total_facturas', index:'total_facturas', width:70, sortable: false, align:"right", fixed: true},
				{name:'total_importe_facturas', index:'total_importe_facturas', width:100, sortable: false, align:"right", fixed: true},
				{name:'total_rembolso_facturas', index:'total_rembolso_facturas', width:100, sortable: false, align:"right", fixed: true},
				{name:'nom_escolaridad', index:'nom_escolaridad', width:120, sortable: false, align:"left", fixed: true},
				{name:'totalBeneficiarios', index:'totalBeneficiarios', width:100, sortable: false, align:"right", fixed: true}
			], 		
			caption:'Reporte Becas Por Escuela',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 400,
			rowNum:-1,
			rowList:[20, 30, 40, 50],
			pager: '#gridBecasEscuela-pager',
			sortname: 'idu_empresa,rfc',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data) {
			var registros = jQuery("#gridBecasEscuela-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id){
				if(id >= 0){
					
				}
			}
		});
		barButtongrid({
			pagId:"#gridBecasEscuela-pager",
			position:"left",//center right
			Buttons:[
			{
				icon:"icon-print blue",
				title:'Imprimir',
				click:function (event){
					if (($("#gridBecasEscuela-table").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					} else {
						GenerarPdf();
					}
					event.preventDefault();	
				},
			}]
		});	
		setSizeBtnGrid('id_button0',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	
	$("#dlg_AyudaEscuelas").on('hide.bs.modal', function (event) {
		fnLimpiarAyudaEscuelas();
	});
	
	function fnLimpiarAyudaEscuelas(){
		$("#txt_NombreBusqueda").val("");
		$("#cbo_Estado").val(0);
		CargarCiudades(function(){
			CargarLocalidades();
		});
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
	}
	function CrearGridEscuelas(){
		jQuery("#grid_ayudaEscuelas").jqGrid({
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG65,
		colModel:[
				{name:'idu_escuela',index:'idu_escuela', width:100, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'rfc_clave_sep',index:'rfc_clave_sep', width:120, sortable: false,align:"left",fixed: true, hidden:false},
				{name:'nom_escuela',index:'nom_escuela', width:310, sortable: false,align:"left",fixed: true},				
				{name:'opc_tipo_escuela',index:'opc_tipo_escuela', width:100, sortable: false,align:"left",fixed: true, hidden:true },				
				{name:'nom_tipo_escuela',index:'nom_tipo_escuela', width:80, sortable: false,align:"left",fixed: true},
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
			height: 205,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			width:750,
			rowNum:5,
			//rowList:[10, 20, 30],
			pager: '#grid_ayudaEscuelas_pager',
			sortname: 'nom_escuela',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			caption:'Catálogo de Escuelas',
			loadComplete: function (Data) {
				var registros = jQuery("#grid_ayudaEscuelas").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(id){
				var rowData = jQuery(this).getRowData(id);
				$('#txt_IdEscuela').val(rowData.idu_escuela);
				$('#txt_RFC').val(rowData.rfc_clave_sep);
				if(rowData.rfc_clave_sep.replace('/^\s+|\s+$/g', '')==""){
					showalert(LengStrMSG.idMSG319, "", "gritter-info");
				}
				$("#txt_Escuela").val(rowData.nom_escuela);
				$("#txt_NombreBusqueda").val("");
				iEscuelaSeleccion=1;
				$("#dlg_AyudaEscuelas").modal('hide');
			}		
		});	
		jQuery("#grid_ayudaEscuelas").jqGrid('navGrid','#grid_ayudaEscuelas_pager',{search:false, edit:false,add:false,del:false});	
		jQuery("#grid_ayudaEscuelas_pager_left").hide();
	}	


function updatePagerIcons(table){
	var replacement = {
		'ui-icon-seek-first' : 'icon-double-angle-left bigger-140',
		'ui-icon-seek-prev' : 'icon-angle-left bigger-140',
		'ui-icon-seek-next' : 'icon-angle-right bigger-140',
		'ui-icon-seek-end' : 'icon-double-angle-right bigger-140'
	};
	
	$('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function(){
		var icon = $(this);
		var $class = icon.attr('class').replace('ui-icon', '').replace('/^\s+|\s+$/g', '');
		if($class in replacement) icon.attr('class', 'ui-icon '+ replacement[$class]);
	});
}

	function llenarGridReporteBecasEscuelas(){
		var iRutaPago = $('#cbo_rutaPago').val();
		var iEstatus = $('#cbo_Estatus').val();
		var iRegion = $('#cbo_Region').val();
		var iCiudadParametro = $('#cbo_Ciudad').val();
		var iDeduccionParametro = $('#cbo_tipoDeduccion').val();
		var dFechaIni = formatearFecha($('#txt_FechaInicio').val());
		var dFechaFin = formatearFecha($('#txt_FechaFin').val());
		var iEscolaridad = $('#cbo_Escolaridad').val();
		var iEscuela = $('#txt_IdEscuela').val();
		var iEmpresa = $("#cbo_empresa").val();
		
		var sUrl = '';
			sUrl = 'ajax/json/json_fun_obtener_reporte_pagos_por_escuela.php?&session_name='+Session;
			sUrl += '&iRutaPago='+iRutaPago;
			sUrl += '&iEstatus='+iEstatus;
			sUrl += '&iRegion='+iRegion;
			sUrl += '&iCiudadParametro='+iCiudadParametro;
			sUrl += '&iDeduccionParametro='+iDeduccionParametro;
			sUrl += '&dFechaIni='+dFechaIni;
			sUrl += '&dFechaFin='+dFechaFin;
			sUrl += '&iEscolaridad='+iEscolaridad;
			sUrl += '&iEscuela='+iEscuela;
			sUrl += '&iEmpresa='+iEmpresa;
			console.log(sUrl);
			// return;
	
		// $("#gridBecasEscuela-table").jqGrid('setGridParam',{url: 'ajax/json/json_fun_obtener_reporte_pagos_por_escuela.php?&iRutaPago=' + iRutaPago+ '&iEstatus=' + iEstatus+ '&iRegion='+iRegion+'&dFechaIni=' + dFechaIni+ '&dFechaFin=' +dFechaFin+ '&iEscolaridad=' + iEscolaridad + '&iEscuela='+iEscuela + '&iCiudadParametro='+iCiudadParametro+'&iDeduccionParametro='+iDeduccionParametro}).trigger("reloadGrid");
		$("#gridBecasEscuela-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
	}
	
	////////////////////EXPORTAR PDF/////////////
		
	function GenerarPdf(){
		
		var sNombreReporte = 'rpt_pagos_por_escuela'
			, iIdConexion = '190'
			, sFormatoReporte = 'pdf';
		
		var iRutaPago = $('#cbo_rutaPago').val();
		var iEstatus = $('#cbo_Estatus').val();
		var iRegion = $('#cbo_Region').val();
		var iCiudadParametro = $('#cbo_Ciudad').val();
		var iDeduccionParametro = $('#cbo_tipoDeduccion').val();
		var dFechaIni = formatearFecha($('#txt_FechaInicio').val());
		var dFechaFin = formatearFecha($('#txt_FechaFin').val());
		var iEscolaridad = $('#cbo_Escolaridad').val();
		var iEscuela = ($('#txt_IdEscuela').val() != "") ? $('#txt_IdEscuela').val() : "0" ;
		var iEmpresa = $("#cbo_empresa").val();
		
		var sUrl = 'nombre_reporte='+sNombreReporte;
			sUrl += '&id_conexion='+iIdConexion;
			sUrl += '&dbms=postgres';
			sUrl += '&formato_reporte='+sFormatoReporte;
			sUrl += '&idrutapago='+iRutaPago;
			sUrl += '&idestatus='+iEstatus;
			sUrl += '&idregion='+iRegion;
			sUrl += '&idciudad='+iCiudadParametro;
			sUrl += '&idempresa='+iEmpresa;
			sUrl += '&idtipodeduccion='+iDeduccionParametro;
			sUrl += '&dfechainicial='+dFechaIni;
			sUrl += '&dfechafinal='+dFechaFin;
			sUrl += '&idescolaridad='+iEscolaridad;
			sUrl += '&idescuela='+iEscuela;
			
		console.log(sUrl);
		// return;
		
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
		xhr.send(sUrl);
		
		
		// var cRutaPago = $('#cbo_rutaPago option:selected').html();
		// var cEstatus = $('#cbo_Estatus option:selected').html();
		// var cRegion = $('#cbo_Region option:selected').html();
		// var cCiudadParametro = $('#cbo_Ciudad option:selected').html();
		// var cDeduccionParametro = $('#cbo_tipoDeduccion option:selected').html();
		// var cEscolaridad = $('#cbo_Escolaridad option:selected').html();
		// var cEscuela = $('#txt_Escuela').val();
		
		// location.href = 'ajax/json/json_exportar_reporte_por_escuela.php?&iRutaPago=' + iRutaPago+ '&iEstatus=' + iEstatus+ '&iRegion='+iRegion+'&dFechaIni=' + dFechaIni+ '&dFechaFin=' +dFechaFin+ '&iEscolaridad=' + iEscolaridad + '&iEscuela='+iEscuela + '&iCiudadParametro='+iCiudadParametro+'&iDeduccionParametro='+iDeduccionParametro + '&cRutaPago=' + cRutaPago + '&cEstatus=' + cEstatus + '&cRegion='+ cRegion+ '&cCiudadParametro=' +cCiudadParametro+ '&cDeduccionParametro=' + cDeduccionParametro+ '&cEscolaridad=' + cEscolaridad+ '&cEscuela=' +cEscuela;
	}

	//==========/ EVENTOS /=====================================================//
	$("#cbo_Estado").change(function(){ //--->COMBO ESTADOS MODAL
		$("#cbo_CiudadModal").val(0);
		$("#cbo_CiudadModal").val($("#cbo_CiudadModal option").first().val());
		$("#cbo_Localidad").val(0);
		$("#cbo_Localidad").val($("#cbo_Localidad option").first().val());
		CargarCiudades(function(){
			CargarLocalidades();
		});
	});
	
	$("#cbo_CiudadModal").change(function(){ //-->COMBO CIUDAD MODAL
		CargarLocalidades();
	});
	
	$("#cbo_Region").change(function(event){
		CargarComboCiudades();
		event.preventDefault();
	});
	
	$('#btn_ConsultaEscuela').click(function(event){
		$("#dlg_AyudaEscuelas").modal('show');
		event.preventDefault();	
	});
	
	$("#btn_ConsultaAyudaEscuela").click(function(event){
		iEscuelaSeleccion=0;
		$('#grid_ayudaEscuelas').jqGrid('clearGridData');
		if($('#txt_NombreBusqueda').val().replace('/^\s+|\s+$/g', '')==""){
			showalert(LengStrMSG.idMSG320, "", "gritter-info");
		} else{
			// $("#grid_ayudaEscuelas").jqGrid('setGridParam',
			// { url: 'ajax/json/json_fun_obtener_escuelas_escolaridad.php?Ayuda=1&inicializar='+inicializar+'&opc_tipo_escuela=' + tipo_escuela + '&term=' + $('#txt_NombreBusqueda').val().toUpperCase()+'&session_name=' +Session}).trigger("reloadGrid"); 
			cargarGridEscuelas();
		}
		event.preventDefault();
	});
	$('#btn_Salir').click(function(event){
		$("#dlg_AyudaEscuelas").modal('hide');
		event.preventDefault();	
	});
	$("#btn_Consultar").click(function(event){
		$('#gridBecasEscuela-table').jqGrid('clearGridData');
		llenarGridReporteBecasEscuelas();
		event.preventDefault();
	});
	