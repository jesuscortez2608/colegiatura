$(function(){
SessionIs();
var iEmpleado = 0
	, sNomEmpleado = ''
	, iOpcionFecha = 0
	, dFechaIni = ''
	, dFechaFin = '';
	GridEmpleadosColegiaturas();
	
	
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
	
	$("#txt_FechaInicio").prop('disabled', true);
	$("#txt_FechaFin").prop('disabled', true);
	
	$("#chkbx_fecha").change(function(event){
		if($("#chkbx_fecha").is(":checked")){
			$("#txt_FechaInicio").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
			iOpcionFecha = 1;
			// alert(iOpcionFecha);
		}else{
			$("#txt_FechaInicio").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
			// LimpiarFechas();
			iOpcionFecha = 0;
			// alert(iOpcionFecha);
		}
		event.preventDefault();
	});
	
	$("#txt_numEmp").on('paste', function(event){
		var element = this;
		setTimeout(function(){
			var text = $(element).val();
			if($(element).val().length == 8 && (!isNaN(parseInt(text)) && isFinite(text))){
				$(element).val(text);
				ConsultaEmpleado();
			}else{
				$("#txt_nomEmp").val("");
				event.preventDefault();
			}
		}, 0);
	});
	$("#txt_numEmp").keypress(function(e){
		var keycode = e.which;
		if(keycode == 13 || keycode == 9){
			if($("#txt_numEmp").val().length != 8){
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");
				$("#txt_nomEmp").val("");
			}else{
				ConsultaEmpleado();
			}
		}else if(keycode == 8 || keycode == 46){
			LimpiarDatos();
		}
	});
	$("#txt_numEmp").keyup(function(e){
		var keycode = e.which;
		if(keycode == 13 || keycode == 9){
			if($("#txt_numEmp").val().length != 8){
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");
				$("#txt_nomEmp").val("");
			}else{
				ConsultaEmpleado();
			}
		}else if(keycode == 8 || keycode == 46){
			LimpiarDatos();
		}
	});
	function ConsultaEmpleado(){
		iNumEmp = $("#txt_numEmp").val().replace('/^\s+|\s+$/g', '');
		if(iNumEmp != ''){
			$.ajax({
				type:"POST",
				url:"ajax/json/json_fun_consulta_empleado_co.php?",
				data:{
					'iNumEmp' : iNumEmp,
					'session_name' : Session
				}
			})
			.done(function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != null){
					if(dataJson.cancelado == '1'){
						showalert(LengStrMSG.idMSG135, "", "gritter-warning");
					}else{
						$("#txt_nomEmp").val(dataJson.nom_empleado);
					}
				}else{
					showalert("No existe el colaborador", "", "gritter-warning");
				}
			});
		}else{
			showalert("Proporcione un número de colaborador", "", "gritter-info");
			$("#txt_numEmp").focus();
		}
	}
	function LimpiarDatos(){
		$("#txt_nomEmp").val('');
		$("#gridPrestacion-table").jqGrid('clearGridData');
		ActualizarGrid(1);
	}
	$("#btn_Consultar").click(function(event){
		jQuery("#gridPrestacion-table").jqGrid('clearGridData');
		if($("#txt_numEmp").val().replace('/^\s+|\s+$/g', '') == ''){
			iEmpleado = 0;
			sNomEmpleado = '';
		}else{
			iEmpleado = $("#txt_numEmp").val().replace('/^\s+|\s+$/g', '');
			sNomEmpleado = $("#txt_nomEmp").val().replace('/^\s+|\s+$/g', '').toUpperCase();
		}
		if(iOpcionFecha == 1){
			dFechaIni = formatearFecha($("#txt_FechaInicio").val());
			dFechaFin = formatearFecha($("#txt_FechaFin").val());
		}else{
			dFechaIni = '19000101';
			dFechaFin = '19000101';
		}
		ActualizarGrid();
		
		event.preventDefault();
	});
	
	function ActualizarGrid(inicializar){
		sUrl = 'ajax/json/json_fun_reporte_empleados_sin_antiguedad.php?&session_name='+Session+'&';
		sUrl += 'iEmpleado='+iEmpleado+'&';
		sUrl += 'iOpcionFecha='+iOpcionFecha+'&';
		sUrl += 'dFechaIni='+dFechaIni+'&';
		sUrl += 'dFechaFin='+dFechaFin+'&';
		if(inicializar == 1){
			sUrl = '';
		}
		$("#gridPrestacion-table").jqGrid('setGridParam', {url: sUrl,}).trigger("reloadGrid");
	}
	function GridEmpleadosColegiaturas(){
		jQuery("#gridPrestacion-table").jqGrid("GridUnload");
		jQuery("#gridPrestacion-table").jqGrid({
			url:'',
			datatype:'json',
			colNames:LengStr.idMSG109,	
			colModel:[
				{name:'iempleado',		index:'iempleado',			width:80,	align:"right",	fixed:true},
				{name:'snombre',		index:'snombre',			width:250,	align:"left",	fixed:true},
				{name:'scentro',		index:'scentro',			width:50,	align:"right",	fixed:true},
				{name:'snombrecentro',	index:'snombrecentro',		width:250,	align:"left",	fixed:true},
				{name:'spuesto',		index:'spuesto',			width:50,	align:"right",	fixed:true},
				{name:'snombrepuesto',	index:'snombrepuesto',		width:250,	align:"left",	fixed:true},
				{name:'dfechaingreso',	index:'dfechaingreso',		width:70,	align:"center",	fixed:true},
				{name:'iusuario',		index:'iusuario',			width:70,	align:"right",	fixed:true},
				{name:'snombreusuario',	index:'snombreusuario',		width:250,	align:"left",	fixed:true},
				{name:'dfecharegistro',	index:'dfecharegistro',		width:157,	align:"center",	fixed:true}
			],
			scrollrows:true,
			width:null,
			loadonce:false,
			shrinkToFit:false,
			height:400,
			rowNum:10,
			rowList:[10, 20, 30],
			pager:'#gridPrestacion-pager',
			align:"center",
			sortname:'dfecharegistro',
			sortorder:'asc',
			viewrecords:true,
			hidegrid:false,
			caption:'Prestación Antes de Tiempo',
			loadComplete:function(data){
				var registros = jQuery("#gridPrestacion-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				},0);
			},
		});
		barButtongrid(
		{
			pagId:'#gridPrestacion-pager',
			position:'left',
			Buttons:[
			{
				icon:'icon-print',
				title:'Imprimir',
				click:function(event){
					if(($("#gridPrestacion-table").find("tr").length - 1) == 0){
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}else{
						GenerarPDF();
					}
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid("id_button0", 35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	function GenerarPDF(){
		var sUrl = 'ajax/json/impresion_json_fun_reporte_empleados_sin_antiguedad.php?&session_name='+Session+'&';
		sUrl += 'iEmpleado='+iEmpleado+'&';
		sUrl += 'sNomEmpleado='+sNomEmpleado+'&';
		sUrl += 'iOpcionFecha='+iOpcionFecha+'&';
		sUrl += 'dFechaIni='+dFechaIni+'&';
		sUrl += 'dFechaFin='+dFechaFin+'&';
		console.log(sUrl);
		// return;
		location.href = sUrl;
	}
})