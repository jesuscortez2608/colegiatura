loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'Está opción se encuentra inactiva, favor de revisar con Administración de Beneficios'}});
$(function(){
SessionIs();	
	// VARIABLES GLOBALES
		var idUsuario = 0
			, idEstado = 0
			, idMunicipio = 0
			, sidRfc = ""
			, sidClaveSEP = ""
			, idEscolaridad = 0
			, dFechaInicial = ""
			, dFechaFinal = "";
			
		var NomEstado = ""
			, NomMunicipio = ""
			, NomEscolaridad = "";
	
	//------PICKERS DE FECHAS
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
	//-----------------------------------------------------------------------------------------
	
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

	//-------INICIALIZACION
	
	fnEstructuraGrid();
	CargarEstados(function(){
		CargarMunicipios();
	});
	CargaEscolaridad();
	//***************************************************************
	//-------------------ACCIONES DE CONTROLES------------------------------------------------
	$("#txt_usuario").keypress(function(e){
		// console.log(e.which);
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			idUsuario = 0;
		}
	});
	$("#txt_ClaveSEP").keypress(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			sidClaveSEP = "";
		}
	});
	$("#txt_Rfc").keypress(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			sidRfc = "";
		}
	});	
	$("#txt_usuario").keyup(function(e){
		// console.log(e.which);
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			idUsuario = 0;
		}
	});
	$("#txt_ClaveSEP").keyup(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			sidClaveSEP = "";
		}
	});
	$("#txt_Rfc").keyup(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			sidRfc = "";
		}
	});	
		
	//***************************************************************
	//----BOTON
	$("#btn_consultar").click(function(event){
		$("#gd_concluyoRevision-table").jqGrid('clearGridData');

		if($("#txt_usuario").val() != ''){
			idUsuario = $("#txt_usuario").val();
		} else {
			idUsuario = 0;
		}
		if($("#cbo_Estado").val() != -1){
			idEstado = $("#cbo_Estado").val();
		}
		if($("#cbo_Municipio").val() != -1){
			idMunicipio = $("#cbo_Municipio").val();
		}
		if($("#txt_Rfc").val().replace('/^\s+|\s+$/g', '') != ''){
			sidRfc = $("#txt_Rfc").val().replace('/^\s+|\s+$/g', '');
		} else {
			sidRfc = '';
		}
		if($("#txt_ClaveSEP").val().replace('/^\s+|\s+$/g', '') != ''){
			sidClaveSEP = $("#txt_ClaveSEP").val().replace('/^\s+|\s+$/g', '');
		} else {
			sidClaveSEP = '';
		}
		if($("#cbo_Escolaridad").val() != 0){
			idEscolaridad = $("#cbo_Escolaridad").val();
		}
		// if($("#cbo_Estado").val() == -1){
			// showalert("Seleccione un estado", "", "gritter-info");		
		// }else{
			idEstado = $("#cbo_Estado").val();
			ActualizarGrid();
		// }
		event.preventDefault();
	});
	//------------------------------------------------------------------------
	
	function ActualizarGrid(inicializar){
		dFechaInicial = formatearFecha($("#txt_FechaInicio").val());
		dFechaFinal = formatearFecha($("#txt_FechaFin").val());
		sUrl = 'ajax/json/json_fun_reporte_costos_sin_modificar.php?&session_name='+Session;
		sUrl += '&idusuario='+idUsuario;
		sUrl += '&idestado='+idEstado;
		sUrl += '&idmunicipio='+idMunicipio;
		sUrl += '&sidrfc='+sidRfc;
		sUrl += '&sidclavesep='+sidClaveSEP;
		sUrl += '&idescolaridad='+idEscolaridad;
		sUrl += '&dfechainicial='+dFechaInicial;
		sUrl += '&dfechafinal='+dFechaFinal;
		
		if(inicializar == 1){
			sUrl = '';
		}
		console.log(sUrl);
		// return;
		
		$("#gd_concluyoRevision-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");

	}
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	function fnEstructuraGrid(){
		jQuery("#gd_concluyoRevision-table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG79,			
			colModel:[
				{name:'susuario',		index:'susuario',		width:300,	align:"left",	fixed: true},
				{name:'sestado',		index:'sestado', 		width:270,	align:"left",	fixed: true},
				{name:'smunicipio',		index:'smunicipio', 	width:200,	align:"left",	fixed: true},
				{name:'srfc',			index:'srfc', 			width:150,	align:"right",	fixed: true},
				{name:'sclavesep',		index:'sclavesep', 		width:120,	align:"right",	fixed: true},
				{name:'sescolaridad',	index:'sescolaridad', 	width:150,	align:"left",	fixed: true},
				{name:'dfechapendiente',index:'dfechapendiente',width:120,	align:"center",	fixed: true},
				{name:'dfecharevision',	index:'dfecharevision', width:180,	align:"center",	fixed: true}
			],
			
			caption:'Registros',
			scrollrows : true,
			width: null,
			loadonce: false,
			// multiselect: true,
			shrinkToFit: false,
			height: 400,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_concluyoRevision-pager',
			sortname:'dfecharevision',
			sortorder:'asc',
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data) {
				var registros = jQuery("#gd_concluyoRevision-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}	
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);

			},
			onSelectRow: function(id){},
		});
		barButtongrid({
			pagId:"#gd_concluyoRevision-pager",
			position:"left",//center rigth
			Buttons:[
				{
					icon:"icon-print blue bigger-140",	
					title:'Imprimir PDF',
					click: function(event){
						if (($("#gd_concluyoRevision-table").find("tr").length - 1) == 0 ) {
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}
						else{
							GenerarPDF();
						}	
						event.preventDefault();	
					}
				}
			]
		});
			setSizeBtnGrid('id_button0',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
		$("#"+id).attr('width',tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	//---------------------------------ACCION DE COMBOS----------------------------------------------------------
	$("#cbo_Estado").change(function(){
		// $("#txt_NombreEscuela").val($("#cbo_Escuela option:selected").text());
		if($("#cbo_Estado").val() == -1){
			idEstado = 0;
		}
		NomEstado = $("#cbo_Estado option:selected").text();
		// alert(NomEstado);
		$("#cbo_Municipio").val(0);
		$("#cbo_Municipio").val($("#cbo_Municipio option").first().val());
		$("#cbo_Municipio").trigger("chosen:selected");
		$("#gd_concluyoRevision-table").jqGrid('clearGridData');
		CargarMunicipios();
		ActualizarGrid(1);
	});
	
	$("#cbo_Municipio").change(function(){
		if($("#cbo_Municipio").val() == -1){
			idMunicipio = 0;
		}
		NomMunicipio = $("#cbo_Municipio option:selected").text();
		$("#gd_concluyoRevision-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	});
	
	$("#cbo_Escolaridad").change(function(){
		if($("#cbo_Escolaridad").val() == 0){
			idEscolaridad = 0;
		}
		NomEscolaridad = $("#cbo_Escolaridad option:selected").text();
		$("#gd_concluyoRevision-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	});
	
	//----------------------------CARGAR COMBOS----------------------------------------------------------
	$("#cbo_Estado").trigger("chosen:updated");
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
				if(dataJson.estado == 0)
				{
					// var option = "";
					var option = "<option value='0'>TODOS</option>";
					for(var i=1;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Estado").html(option);
					$("#cbo_Estado").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'300px'});
					$("#cbo_Estado").trigger("chosen:updated");
					$( "#cbo_Estado" ).val($("#cbo_Estado option").first().val());				
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	function CargarMunicipios(){
		$("#cbo_Municipio").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_municipios_escolares.php?",
			data: {
				//'iEstado':$("#cbo_Estado").val()
				'iEstado':DOMPurify.sanitize($("#cbo_Estado").val())
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Municipio").html(option);
					$("#cbo_Municipio").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'300px'});
					$("#cbo_Municipio").trigger("chosen:updated");
					
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
		
	}
	$("#cbo_Escolaridad").trigger("chosen:updated");
	function CargaEscolaridad(){
		$("#cbo_Escolaridad").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php?",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>"; 
					}
					$("#cbo_Escolaridad").html(option);
					$("#cbo_Escolaridad").chosen({no_results_text:'NO SE ENCUENTRA: ', width:'300px'});
					$("#cbo_Escolaridad").trigger("chosen:updated");
					$("#cbo_Escolaridad" ).val($("#cbo_Escolaridad option").first().val());
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
//************************************************

//----------------------IMPRESION DE PDF------------------------------------------------	
	function GenerarPDF(){
		var sUrl = 'ajax/json/impresion_json_fun_reporte_costos_sin_modificar.php?&session_name='+Session;
			sUrl += '&idusuario='+idUsuario;
			sUrl += '&idestado='+idEstado;
			sUrl += '&idmunicipio='+idMunicipio;
			sUrl += '&sidrfc='+sidRfc;
			sUrl += '&sidclavesep='+sidClaveSEP;
			sUrl += '&idescolaridad='+idEscolaridad;
			sUrl += '&dfechainicial='+dFechaInicial;
			sUrl += '&dfechafinal='+dFechaFinal;
			sUrl += '&NomEstado='+NomEstado;
			sUrl += '&NomMunicipio='+NomMunicipio;
			sUrl += '&NomEscolaridad='+NomEscolaridad;
		location.href = sUrl;
	}
});