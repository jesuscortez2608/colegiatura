loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'Está opción se encuentra inactiva, favor de revisar con Administración de Beneficios'}});
$(function(){
SessionIs();

	//VARIABLES GLOBALES
		var idUsuario = 0
			, idEstado = 0
			, idMunicipio = 0
			, sidRfc = ''
			, sidClaveSEP = ''
			, idEscolaridad = 0
			, dFechaInicial = ''
			, dFechaFinal = ''
			, NomEstado = ''
			, NomMunicipio = ''
			, NomEscolaridad = '';
			
	//DATE PICKERS
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
	
	fnEstructuraGrid();
	CargarEstados(function(){
		CargarMunicipios();
	});
	CargaEscolaridad();

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

	
	//**************************************************************************
	//-------------------ACCIONES DE CONTROLES-------------------------------
	$("#txt_usuario").keypress(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode== 0 || keycode == 46){
			idUsuario = 0;
		}
		// e.preventDefault()
	});
	$("#txt_Rfc").keypress(function(e){
		var keycode = e.which;
		if(keycode == 8 || keyc+ode == 0 || keycode == 46){
			sidRfc = '';
		}
		
	});
	$("#txt_ClaveSEP").keypress(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			sidClaveSEP = '';
		}
		
	});
	$("#txt_usuario").keyup(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode== 0 || keycode == 46){
			idUsuario = 0;
		}
		// e.preventDefault()
	});
	$("#txt_Rfc").keyup(function(e){
		var keycode = e.which;
		if(keycode == 8 || keyc+ode == 0 || keycode == 46){
			sidRfc = '';
		}
		
	});
	$("#txt_ClaveSEP").keyup(function(e){
		var keycode = e.which;
		if(keycode == 8 || keycode == 0 || keycode == 46){
			sidClaveSEP = '';
		}
		
	});
	//**************************************************************************
	$("#btn_consultar").click(function(event){
		$("#gridEscuelas-table").jqGrid('clearGridData');
		if($("#txt_usuario").val().replace('/^\s+|\s+$/g', '') != ''){
			if($("#txt_usuario").val().replace('/^\s+|\s+$/g', '').length != 8){
				showalert("Ingrese un número de colaborador valido", "", "gritter-info");
				$("#txt_usuario").focus();
				return;
			}else{
				idUsuario = $("#txt_usuario").val().replace('/^\s+|\s+$/g', '');
			}
		} else {
			idUsuario = 0;
		}
		if($("#cbo_Estado").val() != 0){
			idEstado = $("#cbo_Estado").val();
		}
		if($("#cbo_Municipio").val() != 0){
			idMunicipio = $("#cbo_Municipio").val();
		}
		if($("#txt_Rfc").val().replace('/^\s+|\s+$/g', '') != ''){
			sidRfc = $("#txt_Rfc").val().replace('/^\s+|\s+$/g', '').toUpperCase();
		} else {
			sidRfc = '';
		}
		if($("#txt_ClaveSEP").val().replace('/^\s+|\s+$/g', '') != ''){
			sidClaveSEP = $("#txt_ClaveSEP").val().replace('/^\s+|\s+$/g', '').toUpperCase();
		} else {
			sidClaveSEP = '';
		}
		if($("#cbo_Escolaridad").val() != 0){
			idEscolaridad = $("#cbo_Escolaridad").val();
		}
		
		ActualizarGrid();
		event.preventDefault();
	});
	//-------------------------------------------------------------------
	function ActualizarGrid(inicializar){
		dFechaInicial = formatearFecha($("#txt_FechaInicio").val());
		dFechaFinal = formatearFecha($("#txt_FechaFin").val());
		var sUrl = 'ajax/json/json_fun_reporte_por_rango_incidencias.php?&session_name='+Session;
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
		$("#gridEscuelas-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
	}
	//-------------------------------------------------------------------
	function fnEstructuraGrid(){
		jQuery("#gridEscuelas-table").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG76,
			colModel:[
				{name:'iusuario',		index:'iusuario', 		width:10, 	sortable: true,	align:"left",	fixed: true, hidden:true},
				{name:'susuario',		index:'susuario', 		width:300, 	sortable: true,	align:"left",	fixed: true},
				{name:'iestado',		index:'iestado', 		width:10, 	sortable: true,	align:"left",	fixed: true, hidden:true},
				{name:'sestado',		index:'sestado', 		width:250, 	sortable: true,	align:"left",	fixed: true},
				{name:'imunicipio',		index:'imunicipio', 	width:10, 	sortable: true,	align:"left",	fixed: true, hidden:true},
				{name:'smunicipio',		index:'smunicipio', 	width:250, 	sortable: true,	align:"left",	fixed: true},
				{name:'srfc',			index:'srfc', 			width:150, 	sortable: true,	align:"left",	fixed: true},
				{name:'sclavesep',		index:'sclavesep', 		width:150, 	sortable: true,	align:"left",	fixed: true},
				{name:'iescolaridad',	index:'iescolaridad',	width:10, 	sortable: true,	align:"left",	fixed: true, hidden:true},
				{name:'sescolaridad',	index:'sescolaridad', 	width:150, 	sortable: true,	align:"left",	fixed: true},				
				{name:'dfecharevision',	index:'dfecharevision', width:100, 	sortable: true,	align:"center",	fixed: true}
			],
			caption:'Registros',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 400,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[],
			pager: '#gridEscuelas-pager',
			sortname:'iestado,dfecharevision',
			sortorder:'asc',
			viewrecords: true,
			hidegrid:false,
			loadComplete: function (Data) {
				var registros = jQuery("#gridEscuelas-table").jqGrid('getGridParam', 'reccount');
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
			pagId:"#gridEscuelas-pager",
			position:"left",//center rigth
			Buttons:[
				{
					icon:"icon-print blue bigger-140",
					title:'Imprimir PDF',
					click: function(event){
						if(($("#gridEscuelas-table").find("tr").length - 1) == 0){
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
	function setSizeBtnGrid(id, tamanio){
		$("#"+id).attr('width', tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px", "width":"100%"})
	}
	
	//-----------ACCION DE COMBOS---------------------
	$("#cbo_Estado").change(function(){
		if($("#cbo_Estado").val() == 0){
			idEstado = 0;
		}
		NomEstado = $("#cbo_Estado option:selected").text();
		$("#cbo_Municipio").val(0);
		$("#cbo_Municipio").val($("#cbo_Municipio option").first().val());
		$("#cbo_Municipio").trigger("chosen:selected");
		$("#gridEscuelas-table").jqGrid('clearGridData');
		CargarMunicipios();
		ActualizarGrid(1);
	});
	$("#cbo_Municipio").change(function(){
		if($("#cbo_Municipio").val() == 0){
			idMunicipio = 0;
		}
		NomMunicipio = $("#cbo_Municipio option:selected").text();
		$("#gridEscuelas-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	});
	$("#cbo_Escolaridad").change(function(){
		if($("#cbo_Escolaridad").val() == 0){
			idEscolaridad = 0;
		}
		NomEscolaridad = $("#cbo_Escolaridad option:selected").text();
		$("#gridEscuelas-table").jqGrid('clearGridData');
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
					$("#cbo_Estado").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'250px'});
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
					for(var i=1;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Municipio").html(option);
					$("#cbo_Municipio").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'250px'});
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
					$("#cbo_Escolaridad").chosen({no_results_text:'NO SE ENCUENTRA: ', width:'250px'});
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
	//-----------IMPRIMIR PDF-------------------
	function GenerarPDF(){
		var sUrl = 'ajax/json/impresion_json_fun_reporte_por_rango_incidencias.php?&session_name='+Session;
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
		console.log(sUrl);
		// return;
		location.href = sUrl;
	}
});