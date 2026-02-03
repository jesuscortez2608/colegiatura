loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'Está opción se encuentra inactiva, favor de revisar con Administración de Beneficios'}});
$(function(){
	var iOpcion = 0
	, idIndicador = 0
	, idUsuario = 0
	, idMotivo = 0
	, idEstado = 0
	, dFechaInicial = ''
	, dFechaFinal = ''
	, OpcTipoIndicador = 0;
	
	var NomUsuario = ''
		, NomEstado = ''
		, NomMotivo = '';
	
	CargarEstados();
	CargarMotivosRevision();
	GridIndicadores(1);

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

	/**DATE PICKERS*/
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
	
	// $("#txt_FechaInicio").datepicker("setDate",new Date());
	// $("#txt_FechaFin").datepicker("setDate",new Date());
	$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
		
	$(".ui-datepicker-trigger").css('display','none');
	
	$(".ui-datepicker-trigger").css('display','none');
	/******************************************************************************************************/
	
	/***********************CONTROLES****************/
		$("#cbo_Indicadores").change(function(event){
		jQuery("#gridIndicadores-table").jqGrid("GridUnload");
		OpcTipoIndicador = $("#cbo_Indicadores").val();
		if($("#cbo_Indicadores").val() == 1){
			$("#divUsuario").show();
			$("#divEstado").hide();
			$("#divMotivo").hide();
		}else if($("#cbo_Indicadores").val() == 2){
			$("#txt_Numemp").val("");
			$("#txt_NombreEmp").val("");
			$("#divUsuario").hide();
			$("#divEstado").hide();
			$("#divMotivo").show();
		}else if($("#cbo_Indicadores").val() == 3){
			$("#txt_Numemp").val("");
			$("#txt_NombreEmp").val("");
			$("#divUsuario").hide();
			$("#divMotivo").hide();
			$("#divEstado").show();
		}else{
			$("#txt_Numemp").val("");
			$("#txt_NombreEmp").val("");
			$("#divEstado").hide();
			$("#divMotivo").hide();
			$("#divUsuario").show();
		}
		GridIndicadores(OpcTipoIndicador);
		event.preventDefault();
	});
	$("#btn_Consultar").click(function(event){
		idIndicador = $("#cbo_Indicadores").val();
		// console.log(idIndicador);
		switch(idIndicador){
			case "1":
				if($("#txt_Numemp").val().replace('/^\s+|\s+$/g', '') != ''){
					if($("#txt_Numemp").val().replace('/^\s+|\s+$/g', '').length < 8){
					showalert("Número de colaborador invalido", "", "gritter-info");
					$("#txt_Numemp").focus();
					}else if($("#txt_NombreEmp").val().replace('/^\s+|\s+$/g', '') == ''){
						showalert("Verifique el usuario", "", "gritter-info");
						$("#txt_Numemp").focus();
					} else {
						idUsuario = $("#txt_Numemp").val().replace('/^\s+|\s+$/g', '');					
						ActualizarGrid();
					}
				}else{
					idUsuario = 0;
					ActualizarGrid();
				}
			break;
			case "2":
				idMotivo = $("#cbo_Motivo").val();
				ActualizarGrid();
			break;
			case "3":
				idEstado = $("#cbo_Estado").val();
				ActualizarGrid();
			break;
			default:
				showalert("Seleccione un indicador", "", "gritter-info");
				$("#cbo_Indicadores").focus();
			break;
				
		}
		event.preventDefault();
	});
	function ActualizarGrid(){
		dFechaInicial = formatearFecha($("#txt_FechaInicio").val());
		dFechaFinal = formatearFecha($("#txt_FechaFin").val());
		switch(idIndicador){
			case "1":
				var sUrl = 'ajax/json/json_fun_indicadores_tiempo_promedio_respuesta.php?&session_name='+Session;
					sUrl += '&idUsuario='+idUsuario;
					sUrl += '&dFechaInicial='+dFechaInicial;
					sUrl += '&dFechaFinal='+dFechaFinal;
					
				$("#gridIndicadores-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
			break;
			case "2":
				var sUrl = 'ajax/json/json_fun_indicadores_actualizacion_por_motivo.php?&session_name='+Session;
					sUrl += '&iMotivo='+idMotivo;
					sUrl += '&dFechaInicial='+dFechaInicial;
					sUrl += '&dFechaFinal='+dFechaFinal;
					
				$("#gridIndicadores-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
			break;
			case "3":
				var sUrl = 'ajax/json/json_fun_indicadores_reincidencia_por_estado.php?&session_name='+Session;
					sUrl += '&idEstado='+idEstado;
					sUrl += '&dFechaInicial='+dFechaInicial;
					sUrl += '&dFechaFinal='+dFechaFinal;
				
				$("#gridIndicadores-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
			break;
			default:
			break;
		}
	}
	$("#txt_Numemp").keypress(function(e){
		var keycode = e.which;
		// console.log(keycode);
		if(keycode == 13 || keycode == 9){
			if($("#txt_Numemp").val().length != 8){
				showalert(LengStrMSG.idMSG113, "", "gritter-warning");
				$("#txt_Numemp").val("");
			}else{
				ConsultaEmpleado();
			}
		}else if(keycode == 0 || keycode == 8){
			$("#txt_NombreEmp").val("");
			// $("#txt_Numemp").val("");
		}
		
	});
	$("#cbo_Estado").change(function(event){
		NomEstado = $("#cbo_Estado option:selected").text();
		event.preventDefault();
	});
	$("#cbo_Motivo").change(function(event){
		NomMotivo = $("#cbo_Motivo option:selected").text();
		event.preventDefault();
	});
	/************************************************/
	//-----------ESTRUCTURA DE GRIDS----------------------------
	function GridIndicadores(iTipoIndicador){
		// if($("#cbo_Indicadores").val() == 1){
		if(iTipoIndicador == 1){
			iOpcion = $("#cbo_Indicadores").val();
			jQuery("#gridIndicadores-table").jqGrid({
				url:'',
				datatype:'json',
				colNames:[ "iUsuario","Usuario", "Tiempo Promedio"],
				colModel:[
					{name:'iusuario',		index:'iusuario',		width:10,	sortable: false,	align:"left",	fixed:true, hidden:true},
					{name:'snombreusuario',	index:'snombreusuario',	width:470,	sortable: false,	align:"left",	fixed:true},
					{name:'icantidaddias',	index:'icantidaddias',	width:470,	sortable: false,	align:"center",	fixed:true}
				],
				scrollrows:false,
				width:null,
				loadonce:false,
				shrinkToFit:false,
				height:400,
				rowNum:-1,
				pgbuttons:null,
				pgtext:null,
				pager:'gridIndicadores-pager',
				sortname:'idu_usuario',
				sortorder:'asc',
				viewrecords:true,
				hidegrid:false,
				caption:'Promedio de Actualización',
				loadComplete:function(data){
					var registros = jQuery("#gridIndicadores-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function(){
						updatePagerIcons(table);
					}, 0);
				},
			});			
		}
		// if($("#cbo_Indicadores").val() == 2){
		if(iTipoIndicador == 2){
			iOpcion = $("#cbo_Indicadores").val();
			jQuery("#gridIndicadores-table").jqGrid({
				url:'',
				datatype:'json',
				colNames:["idMotivo", "Motivo", "Cantidad", "Concluyó Revisión"],
				colModel:[
					{name:'imotivo',	index:'imotivo',	sortable: false, width:10,	align:"right",	fixed:true, hidden:true},
					{name:'motivo',		index:'motivo',		sortable: false, width:325,	align:"left",	fixed:true},
					{name:'cantidad',	index:'cantidad',	sortable: false, width:305,	align:"center",	fixed:true},
					{name:'revision',	index:'revision',	sortable: false, width:305,	align:"center",	fixed:true}
				],
				scrollrows:false,
				width:null,
				loadonce:false,
				shrinkToFit:false,
				height:400,
				rowNum:-1,
				pgtext:null,
				pgbuttons:null,
				pager:'gridIndicadores-pager',
				sortname:'motivo',
				sortorder:'asc',
				viewrecords:true,
				hidegrid:false,
				caption:'Motivos',
				loadComplete:function(data){
					var registros = jQuery("#gridIndicadores-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function(){
						updatePagerIcons(table);
					}, 0);
				},
			});
		}
		// if($("#cbo_Indicadores").val() == 3){
		if(iTipoIndicador == 3){
			iOpcion = $("#cbo_Indicadores").val();
			jQuery("#gridIndicadores-table").jqGrid({
				url:'',
				datatype:'json',
				colNames:["idEstado", "Estado", "Reincidencia"],
				colModel:[
					{name:'iestado',		index:'iestado',		width:10,	sortable:false,	align:"right",	fixed:true, hidden:true},
					{name:'snomestado',		index:'snomestado',		width:470,	sortable:false,	align:"left",	fixed:true},
					{name:'reincidencia',	index:'reincidencia',	width:470,	sortable:false,	align:"center",	fixed:true}
				],
				scrollrows:false,
				width:null,
				loadonce:false,
				shrinkToFit:false,
				height:400,
				rowNum:-1,
				// pgtext:null,
				// pgbuttons:null,
				pager:'gridIndicadores-pager',
				sortname:'snomestado',
				sortorder:'asc',
				viewrecords:true,
				hidegrid:false,
				caption:'Reincidencias por Estado',
				loadComplete:function(data){
					var registros = jQuery("#gridIndicadores-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function(){
						updatePagerIcons(table);
					}, 0);
				},
			});
		}
		barButtongrid({
			pagId:"#gridIndicadores-pager",
			position:"left",
			Buttons:[
				{
					icon:"icon-print blue",
					title:"Imprimir PDF",
					click: function(event){
						if(($("#gridIndicadores-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							GenerarPDF();
						}
						event.preventDefault();
					}
				}
			]
		});
		setSizeBtnGrid('id_button0', 35);
	}
	function ConsultaEmpleado(){
		var numEmp = $("#txt_Numemp").val().replace('/^\s+|\s+$/g', '');
		$.ajax({
			type:'POST',
			url:'ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?',
			data:{'iEmpleado' : numEmp
				, 'session_name' : Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != null){
					if(dataJson != 0){
						if(dataJson[0].cancelado == 1){
							showalert(LengStrMSG.idMSG212, "", "gritter-info");
							$("#txt_NombreEmp").val("");
							$("#txt_Numemp").val("");
							$("#txt_Numemp").focus();
						}else{
							$("#txt_NombreEmp").val(dataJson[0].nombre+' '+dataJson[0].appat+' '+dataJson[0].apmat);
						}
					}else{
						showalert(LengStrMSG.idMSG213, "", "gritter-info");
						$("#txt_NombreEmp").val("");
						$("#txt_Numemp").val("");
						$("#txt_Numemp").focus();
					}
				}else{
					showalert(LengStrMSG.idMSG214, "", "gritter-info");
					$("#txt_NombreEmp").val("");
					$("#txt_Numemp").val("");
					$("#txt_Numemp").focus();
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function CargarEstados(){
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
				if(dataJson.estado == 0)
				{
					// var option = "";
					var option = "<option value='0'>TODOS</option>";
					for(var i=1;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Estado").html(option);
					// $("#cbo_Estado").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'300px'});
					// $("#cbo_Estado").trigger("chosen:updated");
					$( "#cbo_Estado" ).val($("#cbo_Estado option").first().val());				
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function CargarMotivosRevision(){
		$("#cbo_Motivo").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_consulta_motivos_revision.php?",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "";
					option = option + "<option value=0> TODOS </option>"; 
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Motivo").html(option);
					$("#cbo_Motivo" ).val($("#cbo_Motivo option").first().val());
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" los motivos de revisión", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function GenerarPDF(){
		var sUrl = 'ajax/json/';
		var NomEstado = $("#cbo_Estado option:selected").text();
		switch(idIndicador){
			case "1":
				NomUsuario = $("#txt_NombreEmp").val().replace('/^\s+|\s+$/g', '');
				// var sUrl = 'ajax/json/impresion_json_fun_indicadores_tiempo_promedio_respuesta.php?&session_name='+Session;
				sUrl += 'impresion_json_fun_indicadores_tiempo_promedio_respuesta.php?&session_name='+Session;
				sUrl += '&idUsuario='+idUsuario;
				sUrl += '&NomUsuario='+NomUsuario;
				sUrl += '&dFechaInicial='+dFechaInicial;
				sUrl += '&dFechaFinal='+dFechaFinal;
					// console.log(sUrl);
					// return;
				location.href = sUrl;
			break;
			case "2":
				sUrl += 'impresion_json_fun_indicadores_actualizacion_por_motivo.php?&session_name='+Session;
				sUrl += '&idMotivo='+idMotivo;
				sUrl += '&NomMotivo='+NomMotivo;
				sUrl += '&dFechaInicial='+dFechaInicial;
				sUrl += '&dFechaFinal='+dFechaFinal;
				
				location.href = sUrl;
				
			break;
			case "3":
				sUrl += 'impresion_json_fun_indicadores_reincidencia_por_estado.php?&session_name='+Session;
				sUrl += '&idEstado='+idEstado;
				sUrl += '&NomEstado='+NomEstado;
				sUrl += '&dFechaInicial='+dFechaInicial;
				sUrl += '&dFechaFinal='+dFechaFinal;
				
				// console.log(sUrl);
				// return;
				location.href = sUrl;
			break;
		}
	}

	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}		
})