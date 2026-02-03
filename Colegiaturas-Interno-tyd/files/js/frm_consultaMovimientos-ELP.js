$(function(){
	SessionIs();
	var sRegiones, sCiudades;
	fnEstructuraGrid();
	fnCargarEstatus();
	fnCargarRegionCiudadEmpleado(1);
	fnCargarRegionCiudadEmpleado(2);
	fnCargarGridBeneficiario();
	CargarGridColaborador();
	dragablesModal(function(){
		stopScrolling(function(){
			
		});
	});

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

	var nEmpleado="",nEstatus="", sFechaIni="", sFechaFin="", cEmpleado="", cEstatus="";
	var NomEstatus = '';
	
	$("#first_gridFacturas_pager").click(function(event) {
		var registros = jQuery("#gridFacturas").jqGrid('getGridParam', 'reccount');
		if(registros == 0){
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		} else {
			if ( $("#sp_1_gridFacturas_pager").val() < "2" || ( $("#sp_1_gridFacturas_pager").val() == "" || $("#sp_1_gridFacturas_pager").text() == "" ) || $("#sp_1_gridFacturas_pager").val() == "0" ) {
				return;
			} else {
				waitwindow("Realizando consulta, por favor espere...", "open");
			}
		}
		event.preventDefault();
	});
	$("#prev_gridFacturas_pager").click(function(event) {
		var registros = jQuery("#gridFacturas").jqGrid('getGridParam', 'reccount');
		if(registros == 0){
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		} else {
			if ( $("#sp_1_gridFacturas_pager").val() < "2" || ( $("#sp_1_gridFacturas_pager").val() == "" || $("#sp_1_gridFacturas_pager").text() == "" ) || $("#sp_1_gridFacturas_pager").val() == "0" ) {
				return;
			} else {
				waitwindow("Realizando consulta, por favor espere...", "open");
			}
		}
		event.preventDefault();
	});
	$("#next_gridFacturas_pager").click(function(event) {
		var registros = jQuery("#gridFacturas").jqGrid('getGridParam', 'reccount');
		if(registros == 0){
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		} else {
			if ( $("#sp_1_gridFacturas_pager").val() < "2" || ( $("#sp_1_gridFacturas_pager").val() == "" || $("#sp_1_gridFacturas_pager").text() == "" ) || $("#sp_1_gridFacturas_pager").val() == "0" ) {
				return;
			} else {
				waitwindow("Realizando consulta, por favor espere...", "open");
			}
		}
		event.preventDefault();
	});
	$("#last_gridFacturas_pager").click(function(event) {
		var registros = jQuery("#gridFacturas").jqGrid('getGridParam', 'reccount');
		if(registros == 0){
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		} else {
			if ( $("#sp_1_gridFacturas_pager").val() < "2" || ( $("#sp_1_gridFacturas_pager").val() == "" || $("#sp_1_gridFacturas_pager").text() == "" ) || $("#sp_1_gridFacturas_pager").val() == "0" ) {
				return;
			} else {
				waitwindow("Realizando consulta, por favor espere...", "open");
			}
		}
		event.preventDefault();
	});	
	
	function stopScrolling(callback) {
		$("#dlg_BusquedaEmpleados").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_BeneficiariosFactura").on("show.bs.modal", function () {
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
		
	}
	function dragablesModal(callback){
		$(".modal").draggable({
			// commenting the line below will make scrolling while dragging work
			// helper: "clone",
			handle: ".modal-header",
			scroll: true,
			// revert: "invalid"
		});
		
		if (callback != undefined){
			callback();
		}
	}
	$("#txt_FechaIni").datepicker({
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
			$( "#txt_FechaIni" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
	});
	
	$( "#txt_FechaIni" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaIni" ).val() );
		
	$(".ui-datepicker-trigger").css('display','none');
	//Botones
	$("#btn_Otro").click(function(){
		$("#txt_Numemp").val("");
		$("#txt_Nombre").val("");
		$("#txt_Centro").val("");
		$("#txt_NombreCentro").val("");
		$("#txt_fechaIngreso").val("");
		
		$("#txt_sueldoMensual").val("");
		$("#txt_rutaPago").val("");
		$("#txt_tarjeta").val("");
		$("#txt_topePropocional").val("");
		$("#txt_topeMensual").val("");
		
		$("#txt_acumuladoFacturas").val("");
		$("#txt_topeRestante").val("");
		
		$("#cbo_Estatus").val(-1);
		$('#gridFacturas').jqGrid('clearGridData');
		$("#txt_Motivo").val("");
		$("#txt_Numemp").focus();
		// event.preventDefault();
		return;
	});
	$("#btn_buscarE").click(function (event){
		LimpiarModalBusquedaEmpleados();
		$("#dlg_BusquedaEmpleados").modal('show');
		event.preventDefault();
	});
	$("#btn_BuscarEmpleado").click(function (event){
		var campos=0;
		if($('#txt_nombusqueda').val().replace('/^\s+|\s+$/g', '')!='')
		{
			campos++;	
		}
		if($('#txt_apepatbusqueda').val().replace('/^\s+|\s+$/g', '')!='')
		{
			campos++;
		}
		if($('#txt_apematbusqueda').val().replace('/^\s+|\s+$/g', '')!='')
		{
			campos++;
		}
		if(campos<2)
		{
			// showalert(LengStrMSG.idMSG244, "", "gritter-info");
			showalert("Proporcione al menos dos datos para la búsqueda", "", "gritter-info");
		}
		else
		{
			$("#grid_colaborador").jqGrid('setGridParam', { url:'ajax/json/json_proc_busquedaEmpleados_sueldos.php?nombre='+$('#txt_nombusqueda').val()+'&apepat='+$('#txt_apepatbusqueda').val()+'&apemat='+$('#txt_apematbusqueda').val()+'&session_name='+Session}).trigger("reloadGrid");
		}
		event.preventDefault();		
	});
	$("#btn_Consultar").click(function(event){
		
		nEmpleado=$("#txt_Numemp").val();
		nEstatus=$("#cbo_Estatus").val();
		cEmpleado=nEmpleado+' '+$("#txt_Nombre").val(); 
		cEstatus=$('#cbo_Estatus option:selected').html();	
		sFechaIni=formatearFecha($("#txt_FechaIni").val());
		sFechaFin=formatearFecha($("#txt_FechaFin").val());
		if(nEmpleado=="")
		{
			nEmpleado=0;
		}
		$('#gridFacturas').jqGrid('clearGridData');
		fnConsultarFacturas(0);
		event.preventDefault();
	});
	//Funciones
	$("#txt_Numemp").keydown(function(e)
	{
		var keycode = e.which;
		if(keycode == 13 /*|| keycode==9  */)
		{
			if($("#txt_Numemp").val().replace('/^\s+|\s+$/g', '').length != 8 )
			{
				$("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Centro").val("");
				$("#txt_NombreCentro").val("");
				$("#txt_fechaIngreso").val("");
				
				$("#txt_sueldoMensual").val("");
				$("#txt_rutaPago").val("");
				$("#txt_tarjeta").val("");
				$("#txt_topePropocional").val("");
				$("#txt_topeMensual").val("");
				
				$("#txt_acumuladoFacturas").val("");
				$("#txt_topeRestante").val("");
				$("#cbo_Estatus").val(-1);
				$('#gridFacturas').jqGrid('clearGridData');
				
				showalert(LengStrMSG.idMSG245, "", "gritter-info");
			}
			else
			{
				$.ajax({type: "POST",
				url: "ajax/json/json_regiones_ciudades_elp_gpe.php",
				data: { 
					'iOpcion':3,//valida la ciudad del empleado 
					'iNumEmp':$("#txt_Numemp").val(),
					'session_name':Session
				}
				}).done(function(data){
					var dataJson = JSON.parse(data);
					if(dataJson != '')
					{
						waitwindow('Cargando','open');
						ConsultarEmpleado(function(){
							waitwindow('Cargando','close');
						});
					}
					else
					{
						$("#txt_Numemp").val("");
						$("#txt_Nombre").val("");
						$("#txt_Centro").val("");
						$("#txt_NombreCentro").val("");
						$("#txt_fechaIngreso").val("");
						
						$("#txt_sueldoMensual").val("");
						$("#txt_rutaPago").val("");
						$("#txt_tarjeta").val("");
						$("#txt_topePropocional").val("");
						$("#txt_topeMensual").val("");
						
						$("#txt_acumuladoFacturas").val("");
						$("#txt_topeRestante").val("");
						$("#cbo_Estatus").val(-1);
						$('#gridFacturas').jqGrid('clearGridData');
						showalert(LengStrMSG.idMSG245, "", "gritter-warning");
						
					}
				})
				.fail(function(s) {
					showalert(LengStrMSG.idMSG88+' los datos del colaborador', "", "gritter-warning");
					})
				.always(function() {});
			}
			e.preventDefault();	
		}
		else
		{
				$("#txt_Nombre").val("");
				$("#txt_Centro").val("");
				$("#txt_NombreCentro").val("");
				$("#txt_fechaIngreso").val("");
				
				$("#txt_sueldoMensual").val("");
				$("#txt_rutaPago").val("");
				$("#txt_tarjeta").val("");
				$("#txt_topePropocional").val("");
				$("#txt_topeMensual").val("");
				
				$("#txt_acumuladoFacturas").val("");
				$("#txt_topeRestante").val("");
				$("#cbo_Estatus").val(-1);
				$('#gridFacturas').jqGrid('clearGridData');
		}
		
	});
	
	$("#txt_Numemp").on(' input propertychange paste', function(){
		$("#txt_Nombre").val("");
		$("#txt_Centro").val("");
		$("#txt_NombreCentro").val("");
		$("#txt_fechaIngreso").val("");
		
		$("#txt_sueldoMensual").val("");
		$("#txt_rutaPago").val("");
		$("#txt_tarjeta").val("");
		$("#txt_topePropocional").val("");
		$("#txt_topeMensual").val("");
		
		$("#txt_acumuladoFacturas").val("");
		$("#txt_topeRestante").val("");
		$("#cbo_Estatus").val(-1);
		$('#gridFacturas').jqGrid('clearGridData');
		
		if ( $("#txt_Numemp").val() != '' && isNaN($("#txt_Numemp").val()) == false && $("#txt_Numemp").val().length == 8 ) {
			$.ajax({type: "POST",
				url: "ajax/json/json_regiones_ciudades_elp_gpe.php",
				data: { 
					'iOpcion':3,//valida la ciudad del empleado 
					'iNumEmp':$("#txt_Numemp").val(),
					'session_name':Session
				}
				}).done(function(data){
					var dataJson = JSON.parse(data);
					if(dataJson != '')
					{
						waitwindow('Cargando','open');
						ConsultarEmpleado(function(){
							waitwindow('Cargando','close');
						});
					}
					else
					{
						$("#txt_Numemp").val("");
						$("#txt_Nombre").val("");
						$("#txt_Centro").val("");
						$("#txt_NombreCentro").val("");
						$("#txt_fechaIngreso").val("");
						
						$("#txt_sueldoMensual").val("");
						$("#txt_rutaPago").val("");
						$("#txt_tarjeta").val("");
						$("#txt_topePropocional").val("");
						$("#txt_topeMensual").val("");
						
						$("#txt_acumuladoFacturas").val("");
						$("#txt_topeRestante").val("");
						$("#cbo_Estatus").val(-1);
						$('#gridFacturas').jqGrid('clearGridData');
						showalert(LengStrMSG.idMSG245, "", "gritter-warning");
						
					}
				})
				.fail(function(s) {
					showalert(LengStrMSG.idMSG88+' los datos del colaborador', "", "gritter-warning");
					})
				.always(function() {});
		}
	});

	/*$("#txt_Numemp").focusout(function(e)
	{
		var keycode = e.which;
		
		if($("#txt_Numemp").val().length != 8 )
		{
			
			if($("#txt_Numemp").val().length !=0)
			{
				$("#txt_Numemp").focus();
				showalert(LengStrMSG.idMSG245, "", "gritter-info");
			}	
			$("#txt_Numemp").val("");
			$("#txt_Nombre").val("");
			$("#txt_Centro").val("");
			$("#txt_NombreCentro").val("");
			$("#txt_fechaIngreso").val("");
			
			$("#txt_sueldoMensual").val("");
			$("#txt_rutaPago").val("");
			$("#txt_tarjeta").val("");
			$("#txt_topePropocional").val("");
			$("#txt_topeMensual").val("");
			
			$("#txt_acumuladoFacturas").val("");
			$("#txt_topeRestante").val("");
			$("#cbo_Estatus").val(-1);
			$('#gridFacturas').jqGrid('clearGridData');
			
		}
		else
		{
			$.ajax({type: "POST",
			url: "ajax/json/json_regiones_ciudades_elp_gpe.php",
			data: { 
				'iOpcion':3,//valida la ciudad del empleado 
				'iNumEmp':$("#txt_Numemp").val(),
				'session_name':Session
			}
			}).done(function(data){
				var dataJson = JSON.parse(data);
				if(dataJson != '')
				{
					// waitwindow('Cargando','open');
					ConsultarEmpleado(function(){
						// waitwindow('Cargando','close');
					});
				}
				else
				{
					$("#txt_Numemp").val("");
					$("#txt_Nombre").val("");
					$("#txt_Centro").val("");
					$("#txt_NombreCentro").val("");
					$("#txt_fechaIngreso").val("");
					
					$("#txt_sueldoMensual").val("");
					$("#txt_rutaPago").val("");
					$("#txt_tarjeta").val("");
					$("#txt_topePropocional").val("");
					$("#txt_topeMensual").val("");
					
					$("#txt_acumuladoFacturas").val("");
					$("#txt_topeRestante").val("");
					$("#cbo_Estatus").val(-1);
					$('#gridFacturas').jqGrid('clearGridData');
					showalert(LengStrMSG.idMSG245, "", "gritter-info");
					
				}
			})
			.fail(function(s) {
				showalert(LengStrMSG.idMSG88+" los datos del empleado", "", "gritter-warning");
				})
			.always(function() {});
		}
		e.preventDefault();	
		
		
	})*/
	
	function fnConsultarEmpleado()
	{
		// waitwindow('Cargando','open');
		ConsultarEmpleado(function(){
			// waitwindow('Cargando','close');
		});
	}
	function ConsultarEmpleado(callback)
	{
		$.ajax({type: "POST", 
		url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
		data: { 
				'session_name': Session,
				'iEmpleado':$("#txt_Numemp").val()
			}
		})
		.done(function(data){				
			var dataJson = JSON.parse(data);
			if(dataJson!=null)
			{
				if(dataJson[0].cancelado==1)
				{
					showalert(LengStrMSG.idMSG246, "", "gritter-info");
					$("#txt_Numemp").val("");
					$("#txt_Nombre").val("");
					$("#txt_Centro").val("");
					$("#txt_NombreCentro").val("");
					$("#txt_fechaIngreso").val("");
					
					$("#txt_sueldoMensual").val("");
					$("#txt_rutaPago").val("");
					$("#txt_tarjeta").val("");
					$("#txt_topePropocional").val("");
					$("#txt_topeMensual").val("");
					
					$("#txt_acumuladoFacturas").val("");
					$("#txt_topeRestante").val("");
					$("#cbo_Estatus").val(-1);
					$('#gridFacturas').jqGrid('clearGridData');
				}
				else
				{
					$("#txt_Nombre").val(dataJson[0].nombre+' '+dataJson[0].appat+' '+dataJson[0].apmat);
					$("#txt_Centro").val(dataJson[0].centro);
					$("#txt_NombreCentro").val(dataJson[0].nombrecentro);
					$("#txt_fechaIngreso").val(dataJson[0].fec_alta);
					
					$("#txt_sueldoMensual").val(dataJson[0].sueldo);
					$("#txt_rutaPago").val(dataJson[0].nombrerutapago);
					$("#txt_tarjeta").val(dataJson[0].numerotarjeta);
					$("#txt_topePropocional").val(dataJson[0].topeproporcion);
					CargarDatosGenerales();
				}	
			}
			else
			{
					showalert(LengStrMSG.idMSG247, "", "gritter-info");
					$("#txt_Numemp").val("");
					$("#txt_Nombre").val("");
					$("#txt_Centro").val("");
					$("#txt_NombreCentro").val("");
					$("#txt_fechaIngreso").val("");
					
					$("#txt_sueldoMensual").val("");
					$("#txt_rutaPago").val("");
					$("#txt_tarjeta").val("");
					$("#txt_topePropocional").val("");
					
					$("#txt_TopeMensual").val("");
					$("#txt_acumuladoFacturas").val("");
					$("#txt_topeRestante").val("");
					$("#cbo_Estatus").val(-1);
					$('#gridFacturas').jqGrid('clearGridData');
				// });
			}
			callback();
		});	
	}
	function CargarDatosGenerales()
	{
		if($("#txt_sueldoMensual").val()!=0)
		{
			$.ajax({type: "POST", 
			url: "ajax/json/json_fun_calcular_topes_colegiaturas.php?",
			data: { 
					'iSueldo':accounting.unformat($("#txt_sueldoMensual").val()),
					'session_name': Session,
					'iEmpleado':$("#txt_Numemp").val()
				}
			})
			.done(function(data){				
				var dataJson = JSON.parse(data);
				if(dataJson != 0)
				{
					var ImporteFormato="0";
					$("#txt_topeMensual").val(dataJson.topeMensual);
					ImporteFormato=accounting.formatMoney(dataJson.acumulado, "", 2);
					$("#txt_acumuladoFacturas").val(ImporteFormato);
					//console.log($("#txt_topePropocional").val());
					ImporteFormato=((accounting.unformat($("#txt_topePropocional").val()))-(accounting.unformat($("#txt_acumuladoFacturas").val())));
					//console.log(ImporteFormato);
					ImporteFormato=accounting.formatMoney(ImporteFormato, "", 2);
					$("#txt_topeRestante").val(ImporteFormato);
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" los datos del empleado", "", "gritter-warning");
				}
			});
		}	
	}
	function fnEstructuraGrid()
	{
		jQuery("#gridFacturas").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG41,
			colModel:[
				{name:'idEstatus',			index:'idEstatus', 			width:70, 	sortable: false,	align:"center",	fixed: 	true, 	hidden:true},
				{name:'Estatus',			index:'Estatus', 			width:120, 	sortable: false,	align:"center",	fixed: 	true},	
				{name:'FechaEstatus',		index:'FechaEstatus', 		width:100, 	sortable: false,	align:"center",	fixed: 	true},	
				{name:'empEstatus',			index:'empEstatus', 		width:360, 	sortable: false,	align:"left",	fixed: 	true},	
				{name:'numEmp',				index:'numEmp', 			width:120, 	sortable: false,	align:"center",	fixed: 	true, 	hidden:true},
				{name:'empleado',			index:'empleado', 			width:360, 	sortable: false,	align:"left",	fixed: 	true},	
				{name:'facturaBaja',		index:'facturaBaja', 		width:100, 	sortable: false,	align:"center",	fixed: 	true},	
				{name:'facturaFiscal',		index:'facturaFiscal', 		width:250, 	sortable: false,	align:"left",	fixed: 	true},
				{name:'id_tipodocumento', 	index:'id_tipodocumento', 	width:10, 	sortable: false, 	align:"left", 	fixed:	true, 	hidden:true},
				{name:'nom_tipodocumento', 	index:'nom_tipodocumento', 	width:100, 	sortable: false, 	align:"left", 	fixed:	true},
				{name:'fechaFactura',		index:'fechaFactura', 		width:80, 	sortable: false,	align:"center",	fixed: 	true},	
				{name:'fechaCaptura',		index:'fechaCaptura', 		width:80, 	sortable: false,	align:"center",	fixed: 	true},	
				{name:'idCicloEscolar',		index:'idCicloEscolar', 	width:80, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'cicloEscolar',		index:'cicloEscolar', 		width:80, 	sortable: false,	align:"left",	fixed: 	true},	
				{name:'importeFactura',		index:'importeFactura', 	width:90, 	sortable: false,	align:"right",	fixed: 	true},	
				{name:'importePagado',		index:'importePagado', 		width:90, 	sortable: false,	align:"right",	fixed: 	true},	
				{name:'importeTope',		index:'importeTope', 		width:90, 	sortable: false,	align:"right",	fixed: 	true, 	hidden:true},
				{name:'rfc',				index:'rfc', 				width:110, 	sortable: false,	align:"left",	fixed: 	true},	
				{name:'nombreEscuela',		index:'nombreEscuela', 		width:280, 	sortable: false,	align:"left",	fixed: 	true},	
				{name:'idTipoDeduccion',	index:'idTipoDeduccion',	width:90, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'TipoDeduccion',		index:'TipoDeduccion', 		width:130, 	sortable: false,	align:"left",	fixed: 	true},	
				{name:'motivoRechazo',		index:'motivoRechazo', 		width:90, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true},
				{name:'idfactura',			index:'idfactura', 			width:90, 	sortable: false,	align:"left",	fixed: 	true, 	hidden:true}
				
			],
			caption:' ',
			scrollrows : true,
			width: null,
			loadonce: false, //
			shrinkToFit: false,
			height: 350,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gridFacturas_pager',//
			sortname: 'empleado, fecha',
			sortorder: "asc",
			viewrecords: true,//
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gridFacturas").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				if ( $("#sp_1_gridFacturas_pager").val() < "2" || ($("#sp_1_gridFacturas_pager").val() == "" || $("#sp_1_gridFacturas_pager").text() == "" ) ) {
					$("#first_gridFacturas_pager").attr("disabled", true);
					$("#prev_gridFacturas_pager").attr("disabled", true);
					$("#next_gridFacturas_pager").attr("disabled", true);
					$("#last_gridFacturas_pager").attr("disabled", true);
					
				}
				waitwindow("", "close");
			},
			onSelectRow: function(id)
			{			
				if(id >= 0){
					var fila = jQuery("#gridFacturas").getRowData(id); 
					if(fila['idEstatus']==3)//rechazada
					{
						$("#txt_Motivo").val(fila['motivoRechazo']);
					}
					else
					{
						$("#txt_Motivo").val("");
					}
					
				} else {
					$("#txt_Motivo").val("");
				}
			}		
		});
		 barButtongrid({
			pagId:"#gridFacturas_pager",
			position:"left",//center rigth
			Buttons:[
				{
					icon:"icon-group pink",	
					title:'Mostrar beneficiarios',
					click: function(event){
						if (($("#gridFacturas").find("tr").length - 1) == 0 ) 
						{
							showalert(LengStrMSG.idMSG248, "", "gritter-info");
						}
						else
						{	
							var selr = jQuery('#gridFacturas').jqGrid('getGridParam','selrow');
							
							if(selr)
							{
								var rowData = jQuery("#gridFacturas").getRowData(selr);
								console.log(rowData.numEmp+'='+rowData.idfactura);
								var urlu='ajax/json/json_fun_obtener_beneficiarios_por_factura.php?iEmpleado='+ rowData.numEmp+'&iFactura='+rowData.idfactura+'&inicializar='+0;
								$("#gd_BeneficiariosFactura").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
								$('#dlg_BeneficiariosFactura').modal('show');
							}
							else
							{
								showalert(LengStrMSG.idMSG249, "", "gritter-info");
							}
						}	
					}
				}
				/*,{
					icon:"icon-print",
					title:'Imprimir',//button: true
					click:function (event)
					{
						if ( ($("#gridFacturas").find("tr").length - 1) == 0 ) 
						{
							showalert("No existen información para imprimir", "", "gritter-info");						
						}
						else
						{
							//IMPRIMIR
							fnImprimir();
						}	
					}
				}
				,
				{
					icon:"icon-comments-alt green",	
					title:'Ver aclaraciones',
					click:function (event)
					{
						if (($("#gridFacturas").find("tr").length - 1) == 0 ) 
						{
							showalert(LengStrMSG.idMSG248, "", "gritter-info");
						}
						else
						{	
							var selr = jQuery('#gridFacturas').jqGrid('getGridParam','selrow');
							if(selr)
							{
								var rowData = jQuery("#gridFacturas").getRowData(selr);	
								fnConsultaBlog(rowData.numEmp, rowData.idfactura);
								fnActualizarBlog(rowData.idfactura);
								$( '#hid_factura' ).val(rowData.idfactura);
								$( '#hid_empleado' ).val(rowData.numEmp);
								$('#dlg_Blog').modal('show');					
							}
							else
							{
								$( '#hid_factura' ).val("");
								showalert(LengStrMSG.idMSG250, "", "gritter-info");						
							}
						}	
					}	
				}*/
			]
		});	
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	function fnCargarGridBeneficiario()
	{
		jQuery("#gd_BeneficiariosFactura").jqGrid({
			datatype: 'json',
			colNames:LengStr.idMSG126,
			colModel:[
				{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_parentesco',		index:'idu_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_parentesco',		index:'nom_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_tipo_pago',		index:'idu_tipo_pago', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'des_tipo_pago',		index:'des_tipo_pago', 		width:150, 	sortable: false,	align:"left",	fixed: true},
				{name:'nom_periodo',		index:'nom_periodo', 		width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_carrera',		index:'idu_carrera', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_carrera',		index:'nom_carrera', 		width:200, 	sortable: false,	align:"left",	fixed: true,	hidden:false},
				{name:'imp_importeF',		index:'imp_importeF', 		width:70, 	sortable: false,	align:"right"},
				{name:'imp_importe',		index:'imp_importe', 		width:70, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'idu_grado',			index:'idu_grado', 			width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_grado',			index:'nom_grado', 			width:130, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_ciclo',			index:'idu_ciclo', 			width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_ciclo_escolar',	index:'nom_ciclo_escolar', 	width:90, 	sortable: false,	align:"left",	fixed: true},
				{name:'descuento',			index:'descuento', 			width:70, 	sortable: false,	align:"right",	fixed: true},
				{name:'comentario',			index:'comentario', 		width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'keyx',				index:'keyx', 				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true}
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: null,
			shrinkToFit: false,
			height: 120,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			pgbuttons: false,
			pgtext: null,
			caption:' ',
			loadComplete: function (Data) {
				var registros = jQuery("#gd_BeneficiariosFactura").jqGrid('getGridParam', 'reccount');
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				var Total;
				var grid = $('#gd_BeneficiariosFactura');
				Total = grid.jqGrid('getCol', 'imp_importe', false, 'sum');
				$("#txt_TotalB").val(accounting.formatMoney(Total, "", 2));
				
			},
			onSelectRow: function(id) {
			}					
		});		
	}
	function CargarGridColaborador(){
		jQuery("#grid_colaborador").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG45,
			colModel:[
				{name:'num_emp',index:'num_emp', width:90, sortable: false,align:"center",fixed: true},
				{name:'nombre',index:'nombre', width:110, sortable: false,align:"left",fixed: true},
				{name:'apepat',index:'apepat', width:100, sortable: false,align:"left",fixed: true},
				{name:'apemat',index:'nombre', width:100, sortable: false,align:"left",fixed: true},
				{name:'centro',index:'centro', width:60, sortable: false,align:"left",fixed: true},
				{name:'nombreCentro',index:'nombreCentro', width:190, sortable: false,align:"left",fixed: true},
				{name:'puesto',index:'puesto', width:50, sortable: false,align:"left",fixed: true},
				{name:'nombrePuesto',index:'nombrePuesto', width:180, sortable: false,align:"left",fixed: true},
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: 920,
			shrinkToFit: false,
			height: 200,
			caption: 'Catálogo de Colaboradores',
			pgbuttons: false,
			pgtext: null,		
			loadComplete: function (Data) { },
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(clave) {
				var Data = jQuery("#grid_colaborador").jqGrid('getRowData',clave);
				$("#txt_Numemp").val(Data.num_emp);
				$("#dlg_BusquedaEmpleados").modal('hide');
				fnConsultarEmpleado();
				LimpiarModalBusquedaEmpleados();
			}
		});	
	}	
	function fnCargarEstatus()
	{
		var option="";
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_estatus_facturas.php",
		data: { }
		}).done(function(data){

			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				option = option + "<option value='-1'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
				}
				$("#cbo_Estatus").trigger("chosen:updated").html(option);
				$("#cbo_Estatus").trigger("chosen:updated");
				
			}
			else
			{
				//showalert(dataJson.mensaje, "", "gritter-warning");
				showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-warning");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-warning");
			$('#cbo_Estatus').fadeOut();})
		.always(function() {});
	}	
	function fnCargarRegionCiudadEmpleado(iOpcion)
	{
		$.ajax({type: "POST",
		url: "ajax/json/json_regiones_ciudades_elp_gpe.php",
		data: { 
			'iOpcion':iOpcion,//obtener regiones del usuario
			'session_name':Session
		}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson != '')
			{
				if(iOpcion==1)//regiones
				{
					sRegiones=dataJson;
				}
				else
				{
					sCiudades=dataJson;
				}	
			}
			else
			{
				//showalert(dataJson.mensaje, "", "gritter-warning");
				showalert(LengStrMSG.idMSG88+" las regiones del usuario", "", "gritter-warning");
				
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las regiones del usuario", "", "gritter-warning");
		})
		.always(function() {});
	}
	function LimpiarModalBusquedaEmpleados(){
		$('#txt_nombusqueda').val('');
		$('#txt_apepatbusqueda').val('');
		$('#txt_apematbusqueda').val('');
		$('#grid_colaborador').jqGrid('clearGridData');
	}
	$("#cbo_Estatus").change(function(event){
		if($("#cbo_Estatus").val() == -1){
			NomEstatus = 'Todos los Estatus';
		} else if($("#cbo_Estatus").val() == 0){
			NomEstatus = 'Pendiente';
		} else if($("#cbo_Estatus").val() == 1){
			NomEstatus = 'En Proceso';
		} else if($("#cbo_Estatus").val() == 2){
			NomEstatus = 'Aceptada (Por Pagar)';
		} else if($("#cbo_Estatus").val() == 3){
			NomEstatus = 'Rechazada';
		} else if($("#cbo_Estatus").val() == 4){
			NomEstatus = 'En Aclaracion';
		} else if($("#cbo_Estatus").val() == 5){
			NomEstatus = 'En Revision';
		} else if($("#cbo_Estatus").val() == 6){
			NomEstatus = 'Pagada';
		} else if($("#cbo_Estatus").val() == 7){
			NomEstatus = 'Cancelada';
		}
		event.preventDefault();
	});
	function fnConsultarFacturas(inicializar)
	{
		waitwindow("Realizando consulta, por favor espere...", "open");
		var urlu='ajax/json/json_fun_obtener_movimientos_colegiaturas.php?nEmpleado='+nEmpleado+'&nEstatus='+nEstatus+'&nCicloEscolar=0'
		+'&nTipoDeduccion=0&nRegion='+sRegiones+'&nCiudad='+sCiudades+'&nCentro=0&inicializar='+inicializar+'&fechaini='+sFechaIni+'&fechafin='+sFechaFin;
		$("#gridFacturas").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
		// var nombreConsulta='FACTURAS '+$('#cbo_Estatus option:selected').html();
		var nombreConsulta='Facturas '+NomEstatus;
		if ($("#cbo_Estatus").val()==-1)//todos los estatus
		{
			nombreConsulta='Facturas Todos los Estatus'
		}
		$("#txt_Motivo").val("");
		$('#gridFacturas').jqGrid('setCaption', nombreConsulta);
	}
	
	function fnImprimir()
	{
		
		var urlu='ajax/json/impresion_consulta_movimientos_personal_admon.php?nEmpleado='+nEmpleado+'&nEstatus='+nEstatus+'&nCicloEscolar=0&page='+-1+'&rows='+-1+
		'&nTipoDeduccion=0&nRegion='+sRegiones+'&nCiudad='+sCiudades+'&nCentro=0&inicializar=0&fechaini='+sFechaIni+'&fechafin='+sFechaFin+'&cEstatus='+cEstatus+'&cEmpleado='+cEmpleado;
		
		location.href = urlu;
	}
	function fnActualizarBlog(iFactura)
	{
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_marcar_blog.php?",
		data: { 
				'Factura':iFactura,
				'session_name': Session
			}
		})
		.done(function(data){				
			//fnObtenerNotificaciones();
		});	
	}
	$("#btn_EnviarComentario").click(function(event){
		if($("#txt_mensaje").val().replace('/^\s+|\s+$/g', '')=="")
		{
			showalert(LengStrMSG.idMSG251, "", "gritter-info");
			$("#txt_mensaje").val("");
			$("#txt_mensaje").focus();
			
		}
		else
		{
			fnEnviarComentario();
		}
		event.preventDefault();	
	});
	function fnEnviarComentario()
	{
		var Comentario=$("#txt_mensaje").val().toUpperCase().replace('/^\s+|\s+$/g', '');
		if(Comentario!="")
		{
			var opciones= {
				beforeSubmit: function(){
				}, 
				uploadProgress: function(){
				},
				success: function(data) 
				{
					var dataJson = JSON.parse(data);
					if (dataJson.estado !=1) {
						showalert(LengStrMSG.idMSG230+" el comentario", "", "gritter-warning");
					} else {
						//Comentario enviado
						showalert(LengStrMSG.idMSG253, "", "gritter-success");
					}
					$('#dlg_Blog').modal('hide');
					$("#txt_mensaje").val("");
				}
			};
			$( '#session_name1' ).val(Session);
			//$( '#hid_factura' ).val(iFactura);
			$("#txt_mensaje").val(Comentario);
			//$( '#hid_empleado' ).val(iEmpleado);
			
			$( '#fmComentario' ).ajaxForm(opciones) ;
			$( '#fmComentario' ).submit();
		}
		else
		{
			$("#txt_mensaje").val("");
			$("#txt_mensaje").focus();
			showalert(LengStrMSG.idMSG254, "", "gritter-info");
		}	
	}	
});		