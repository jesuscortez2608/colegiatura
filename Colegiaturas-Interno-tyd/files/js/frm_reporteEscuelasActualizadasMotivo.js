loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:'Está opción se encuentra inactiva, favor de revisar con Administración de Beneficios'}});
$(function(){
	SessionIs();
//------INICIALIZAR
		
	var idEstado = 0
		, idMunicipio = 0
		, idMotivo = 0
		, dFechaInicial = ''
		, dFechaFinal = ''
		, NomEstado = ''
		, NomMunicipio = ''
		, NomMotivo = '';

	CargarEstados(function(){
		CargarMunicipios();
	});
	CargarMotivosRevision();
	fnEstructuraGrid();
	$("#cbo_Municipio").chosen({no_results_text: 'NO SE ENCUENTRA',width:'300px'});
	$("#cbo_Estado").chosen({no_results_text: 'NO SE ENCUENTRA',width:'300px'});
	$("#cbo_Motivo").chosen({no_results_text: 'NO SE ENCUENTRA',width:'300px'});
	
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
			// $("#gridEscuelas-table").jqGrid('clearGridData');
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
			// $("#gridEscuelas-table").jqGrid('clearGridData');
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	
	// $("#txt_FechaInicio").datepicker("setDate",new Date());
	$("#txt_FechaFin").datepicker("setDate",new Date());
	
	$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
	$(".ui-datepicker-trigger").css('display','none');	
	
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

	function ActualizarGrid(inicializar){
		dFechaInicial = formatearFecha($("#txt_FechaInicio").val());
		dFechaFinal = formatearFecha($("#txt_FechaFin").val());
		
		var sUrl = 'ajax/json/json_fun_reporte_escuelas_actualizadas_por_motivo.php?&session_name='+Session;
		sUrl += '&idEstado=' + idEstado;
		sUrl += '&idMunicipio=' + idMunicipio;
		sUrl += '&idMotivo=' + idMotivo;
		sUrl += '&dFechaInicial=' + dFechaInicial;
		sUrl += '&dFechaFinal=' + dFechaFinal;
		
		if (inicializar == 1){
			sUrl = '';
		}
		// console.log(sUrl);
		// return;
		$("#gridEscuelas-table").jqGrid('setGridParam', {url: sUrl,}).trigger("reloadGrid");
	}

	function fnEstructuraGrid(){
		jQuery("#gridEscuelas-table").jqGrid({
			url:'',
			datatype:'json',
			colNames:LengStr.idMSG102,
			colModel:[
				{name: 'iestado',			index:'iestado',			width:50,	align:"right",	fixed: true,	hidden:true},
				{name: 'sestado',			index:'sestado',			width:250,	align:"left",	fixed: true,	hidden:false},
				{name: 'imunicipio',		index:'imunicipio',			width:50,	align:"right",	fixed: true,	hidden:true},
				{name: 'smunicipio',		index:'smunicipio',			width:250,	align:"left",	fixed: true,	hidden:false},
				{name: 'imotivo',			index:'imotivo',			width:50,	align:"right",	fixed: true,	hidden:true},
				{name: 'smotivo',			index:'smotivo',			width:250,	align:"left",	fixed: true,	hidden:false},
				{name: 'icantidadmotivo',	index:'icantidadmotivo',	width:180,	align:"center",	fixed: true,	hidden:false},
				{name: 'icantidadconcluyo',	index:'icantidadconcluyo',	width:180,	align:"center",	fixed: true,	hidden:false}
			],
			scrollrows:	true,	//PARA QUE FUNCIONE EL SCROLL CON EL SETSELECCION
			width:	null,
			loadonce: false,
			shrinkToFit:false,
			height:400,
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gridEscuelas-pager',
			sortname:'iestado,imunicipio',
			sortorder:'desc',
			viewrecords:true,
			hidegrid:false,
			caption:'Registros',
			loadComplete:function(data){
				var registros = jQuery("#gridEscuelas-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}	
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);			
			},
			onSelectRow:function(id){},
		});
		barButtongrid(
		{
			pagId:"#gridEscuelas-pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-print",	
				title:'Imprimir',
				click: function(event){
					if (($("#gridEscuelas-table").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}
					else
					{
						//Imprimir();
							GenerarPDF();
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
	//-------EVENTOS DE COMBO-------------------------------------
	$("#cbo_Estado").change(function(){
		idEstado = 0;
		idEstado = $("#cbo_Estado").val();		
		NomEstado = $("#cbo_Estado option:selected").text();
		// alert(NomEstado);
		$("#cbo_Municipio").val(0);
		$("#cbo_Municipio").val($("#cbo_Municipio option").first().val());
		$("#cbo_Municipio").trigger("chosen:selected");
		$("#gridEscuelas-table").jqGrid('clearGridData');
		CargarMunicipios();
		ActualizarGrid(1);
	});
	
	$("#cbo_Municipio").change(function(){
		idMunicipio = 0;
		idMunicipio = $("#cbo_Municipio").val();
		NomMunicipio = $("#cbo_Municipio option:selected").text();
		$("#gridEscuelas-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	});	
	$("#cbo_Motivo").change(function(){
		idMotivo = 0;
		idMotivo = $("#cbo_Motivo").val();
		NomMotivo = $("#cbo_Motivo option:selected").text();
		$("#gridEscuelas-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	});
	
	$("#btn_consultar").click(function(event){
		$("#gridEscuelas-table").jqGrid('clearGridData');
		idEstado = $("#cbo_Estado").val();
		idMunicipio = $("#cbo_Municipio").val();
		idMotivo = $("#cbo_Motivo").val();
		ActualizarGrid();
		event.preventDefault();
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
					var option = "<option value='-1'>TODOS</option>";
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
					var option = "<option value='-1'>TODOS</option>";
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
	//CARGAR MOTIVOS REVISION	
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
					var option = "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Motivo").html(option);
					$("#cbo_Motivo" ).val($("#cbo_Motivo option").first().val());
					$("#cbo_Motivo").trigger("chosen:updated");
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" los motivos de revisi�n", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function GenerarPDF(){
		NomEstado = $("#cbo_Estado option:selected").text();
		NomMunicipio = $("#cbo_Municipio option:selected").text();
		NomMotivo = $("#cbo_Motivo option:selected").text();
		var sUrl = 'ajax/json/impresion_json_fun_reporte_esc_actualizadas_motivo.php?&session_name='+Session;
			sUrl += '&idEstado=' + idEstado;
			sUrl += '&idMunicipio=' + idMunicipio;
			sUrl += '&idMotivo=' + idMotivo;
			sUrl += '&dFechaInicial=' + dFechaInicial;
			sUrl += '&dFechaFinal=' + dFechaFinal;
			sUrl += '&NomEstado=' + NomEstado;
			sUrl += '&NomMunicipio=' + NomMunicipio;
			sUrl += '&NomMotivo=' + NomMotivo;
			console.log(sUrl);
			// return;
		location.href = sUrl;
			
	}
})