

$(function(){
	SessionIs();
	fnEstructuraGrid();
	CargarGridColaborador();
	fnCargarEstatus();
	fnCargarDeducciones();
	fnCargarCiclosEscolares();
	fnCargarRegiones();
	fnEstructuraGridCentros();
	fnCargarGridBeneficiario();
	dragablesModal(function(){
		stopScrolling(function(){
			
		});
	});
	var nEmpleado="", nomColaborador="",nEstatus="", nCicloEscolar="", nTipoDeduccion="",nRegion="",nCiudad="", nCentro="",sFechaIni="", sFechaFin="";
	var cEmpleado="",cEstatus="",cCicloEscolar="",cTipoDeduccion="",cRegion="",cCiudad="",cCentro="";
	var NomEstatus = '';

	//** VULNERABILIDADES
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
	
	function sanitize(string) { //función para sanitizar variables
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
		
	//EVENTOS
	function stopScrolling(callback) {
		$("#dlg_BusquedaEmpleados").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_AyudaCentro").on("show.bs.modal", function () {
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
	$("#cbo_Region").change(function(event){
		fnCargarCiudades();
		$('#txt_CentroF').val("");  
		$('#txt_NombreCentroF').val("");
		event.preventDefault();
	});
	$("#cbo_Ciudad").change(function(event){
		$('#txt_CentroF').val("");  
		$('#txt_NombreCentroF').val("");
		event.preventDefault();
	});
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
		
		$("#cbo_Region").val("0");
		$("#cbo_Region").val("0");
		
		
		var option = "<option value='0'>TODAS</option>";
		$("#cbo_Ciudad").html(option);
		$("#cbo_Ciudad").val(0);
		$("#txt_CentroF").val("");
		$("#txt_NombreCentroF").val("");
		
		// $("#txt_FechaIni").val($("#txt_Fecha").val());
		// $("#txt_FechaFin").val($("#txt_Fecha").val());
		
		$("#cbo_Estatus").val(-1);
		$( "#cbo_CicloEscolar" ).val($("#cbo_CicloEscolar option").first().val());
		$("#cbo_tipoDeduccion").val(0);
		
		$("#txt_Numemp").focus();
		$('#gridFacturas').jqGrid('clearGridData');
		// event.preventDefault();
	});
	$("#btn_ayudaCentro").click(function(event){
		LimpiarModalBusquedaCentros();
		$("#dlg_AyudaCentro").modal('show');
		event.preventDefault();
	});
	$("#btn_BuscarCentro").click(function(event){
		$("#grid_Centros").jqGrid('setGridParam', { 
			url:'ajax/json/json_proc_ayudacentros_grid.php?iNumRegion='+$('#cbo_Region').val()+'&iNumCiudad='+$('#cbo_Ciudad').val()+'&iCentro='+$('#txt_CentroBusqueda').val()+'&cNomCentro='+$('#txt_NomCentroBusqueda').val()+'&session_name='+Session}).trigger("reloadGrid");
		event.preventDefault();
	});
	$("#btn_Consultar").click(function(event){
	
		nEmpleado=$("#txt_Numemp").val();
		nEstatus=$("#cbo_Estatus").val();
		nCicloEscolar=$("#cbo_CicloEscolar").val();
		nTipoDeduccion=$("#cbo_tipoDeduccion").val();
		nRegion=$("#cbo_Region").val();
		nCiudad=$("#cbo_Ciudad").val();
		nCentro=$("#txt_CentroF").val();
		
		cCentro=$("#txt_NombreCentroF").val();
		cEmpleado=$("#txt_Numemp").val()+' '+$("#txt_Nombre").val();
		cEstatus=$('#cbo_Estatus option:selected').html();
		cCicloEscolar=$('#cbo_CicloEscolar option:selected').html();
		cTipoDeduccion=$('#cbo_tipoDeduccion option:selected').html();
		cRegion=$('#cbo_Region option:selected').html();
		cCiudad=$('#cbo_Ciudad option:selected').html();
		
		
		sFechaIni=formatearFecha($("#txt_FechaIni").val());
		sFechaFin=formatearFecha($("#txt_FechaFin").val());
		if(nEmpleado=="")
		{
			nEmpleado=0;
		}
		if(nCentro=="")
		{
			nCentro=0;
		}
		fnConsultarFacturas(0);
		event.preventDefault();
	});
	
	
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
	
	$("#btn_buscarE").click(function (event){
		LimpiarModalBusquedaEmpleados();
		$("#dlg_BusquedaEmpleados").modal('show');
		event.preventDefault();
	});
	
	$("#btn_buscarCOL").click(function (event){
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
		// console.log(campos);
		if(campos<2)
		{
			// showalert(LengStrMSG.idMSG236, "", "gritter-info");
			showalert("Proporcione al menos dos datos para la búsqueda", "", "gritter-info");
		}
		else
		{
			$("#grid_colaborador").jqGrid('setGridParam', { url:'ajax/json/json_proc_busquedaEmpleados_sueldos.php?Mostrarbaja=1&nombre='+$('#txt_nombusqueda').val()+'&apepat='+$('#txt_apepatbusqueda').val()+'&apemat='+$('#txt_apematbusqueda').val()+'&session_name='+Session}).trigger("reloadGrid");
		}
		event.preventDefault();		
	});
	
	$("#btn_Porcentaje").on("click", function(event){
		
		$('#gd_Porcentajes').jqGrid('clearGridData');
		$('#gd_Porcentajes').jqGrid('setGridParam', {
			url: 'ajax/json/json_fun_verifica_porcentaje_especial.php',
			mtype: 'POST',
			postData: {
				iColaborador: $('#txt_Numemp').val()
			}
		}).trigger('reloadGrid');
		$('#dlg_Porcentajes').modal('toggle');
		$('#dlg_Porcentajes').modal('show');		
	});

	function fnConsultaPorcentajes(colaborador){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_verifica_porcentaje_especial.php',
			data:{
				'iColaborador': colaborador
			},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				var dataJson = JSON.parse(dataS);
				
				if (Object.keys(dataJson).length > 0){
					$('#btn_Porcentaje').show();
				}
				else{
					$('#btn_Porcentaje').hide();

				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	$("#txt_Numemp").keydown(function(e)
	{
		var keycode = e.which;
		// console.log(e.which);
		
		if(keycode == 13 /*|| keycode==9*/)
		{
			if($("#txt_Numemp").val().replace('/^\s+|\s+$/g', '').length != 8)
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
				showalert(LengStrMSG.idMSG237, "", "gritter-warning");
				fnConsultaPorcentajes($( "#txt_Numemp" ).val());
				
			}
			else
			{
				waitwindow('Cargando','open');
				ConsultarEmpleado(function(){					
					waitwindow('Cargando','close');	
					fnConsultaPorcentajes($( "#txt_Numemp" ).val());
				});				
				
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
			fnConsultaPorcentajes($( "#txt_Numemp" ).val());
		}
		
	});
	$("#txt_Numemp").on('input propertychange paste', function(){
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
			// console.log("Aqui");
			fnConsultaPorcentajes($( "#txt_Numemp" ).val());
			waitwindow('Cargando','open');
			ConsultarEmpleado(function(){
				waitwindow('Cargando','close');				
			});
			
		}
	});
	/*$("#txt_Numemp").focusout(function(e)
	{
		var keycode = e.which;
		
		if($("#txt_Numemp").val().length != 8 )
		{
			if($("#txt_Numemp").val().length !=0)
			{
				showalert(LengStrMSG.idMSG237, "", "gritter-warning");
				$("#txt_Numemp").focus();
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
			// waitwindow('Cargando','open');
			ConsultarEmpleado(function(){
				// waitwindow('Cargando','close');
			});
		}
		e.preventDefault();	
	});
	*/
	


	function fnConsultarEmpleado()
	{
		waitwindow('Cargando','open');
		ConsultarEmpleado(function(){
			waitwindow('Cargando','close');
		});
	}
	
	$('#btn_beneficiarios').click(function(){
		$.ajax({
			type: 'POST',
			url: 'ajax/frm/frm_Beneficiarios.php',
			data: {	}
			}).done(function(data){
				var sanitizedData = limpiarCadena(data);
				data = sanitizedData.replace(/<!--url-->/g,util_url);
				$("#dlg_Movimientos").html ("" + data + "");
				$("#dlg_Movimientos").dialog('open');
			});
	});	
	function fnEstructuraGrid()
	{
		jQuery("#gridFacturas").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			//colNames:LengStr.idMSG41,
			colNames:LengStr.idMSG136,
			colModel:[
				{name:'idEstatus',			index:'idEstatus', 			width:70, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'Estatus',			index:'Estatus', 			width:120, 	sortable: false,	align:"center",	fixed: true},
				{name:'FechaEstatus',		index:'FechaEstatus', 		width:100, 	sortable: false,	align:"center",	fixed: true},
				{name:'empEstatus',			index:'empEstatus', 		width:360, 	sortable: false,	align:"left",	fixed: true},
				{name:'numEmp',				index:'numEmp', 			width:120, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'empleado',			index:'empleado', 			width:360, 	sortable: false,	align:"left",	fixed: true},
				{name:'facturaBaja',		index:'facturaBaja', 		width:100, 	sortable: false,	align:"center",	fixed: true},
				{name:'facturaFiscal',		index:'facturaFiscal', 		width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'id_tipodocumento', 	index:'id_tipodocumento', 	width:10, 	sortable: false,	align:"left", 	fixed: true, hidden:true},
				{name:'nom_tipodocumento', 	index:'nom_tipodocumento', 	width:100, 	sortable: false,	align:"left", 	fixed: true},
				{name:'fechaFactura',		index:'fechaFactura', 		width:80, 	sortable: false,	align:"center",	fixed: true},
				{name:'fechaCaptura',		index:'fechaCaptura', 		width:80, 	sortable: false,	align:"center",	fixed: true},
				{name:'idCicloEscolar',		index:'idCicloEscolar', 	width:80, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'cicloEscolar',		index:'cicloEscolar', 		width:80, 	sortable: false,	align:"left",	fixed: true},
				{name:'importeFactura',		index:'importeFactura', 	width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importePagado',		index:'importePagado', 		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importeTope',		index:'importeTope', 		width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'rfc',				index:'rfc', 				width:110, 	sortable: false,	align:"left",	fixed: true},
				{name:'nombreEscuela',		index:'nombreEscuela', 		width:280, 	sortable: false,	align:"left",	fixed: true},
				{name:'idTipoDeduccion',	index:'idTipoDeduccion', 	width:90, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'TipoDeduccion',		index:'TipoDeduccion', 		width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'motivoRechazo',		index:'motivoRechazo', 		width:90, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'idfactura',			index:'idfactura', 			width:90, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				//BENEFICIARIOS
				
				
				{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'fec_nac_beneficiario',        index:'fec_nac_beneficiario',   width:100,  sortable: false,    align:"left",   fixed: true,    hidden:true},
				{name:'edad_anio_beneficiario',     index:'edad_anio_beneficiario',     width:100,  sortable: false,    align:"left",   fixed: true,    hidden:true},
				{name:'idu_parentesco',		index:'idu_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_parentesco',		index:'nom_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_tipo_pago',		index:'idu_tipo_pago', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'des_tipo_pago',		index:'des_tipo_pago', 		width:90, 	sortable: false,	align:"left",	fixed: true},
				{name:'nom_periodo',		index:'nom_periodo', 		width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_escolaridad',	index:'idu_escolaridad', 	width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_carrera',		index:'idu_carrera', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_carrera',		index:'nom_carrera', 		width:200, 	sortable: false,	align:"left",	fixed: true},
				{name:'imp_importeF',		index:'imp_importeF', 		width:70, 	sortable: false,	align:"right"},
				{name:'imp_importe',		index:'imp_importe', 		width:70, 	sortable: false,	align:"right",	fixed: true, 	hidden:true},
				{name:'idu_grado',			index:'idu_grado', 			width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_grado',			index:'nom_grado', 			width:130, 	sortable: false,	align:"left",	fixed: true},
				{name:'idu_ciclo',			index:'idu_ciclo', 			width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_ciclo_escolar',	index:'nom_ciclo_escolar', 	width:150, 	sortable: false,	align:"left",	fixed: true},
				{name:'descuento',			index:'descuento', 			width:70, 	sortable: false,	align:"right",	fixed: true},
				{name:'comentario',			index:'comentario', 		width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'keyx',				index:'keyx', 				width:100, 	sortable: false,	align:"left",	fixed: true, 	hidden:true}
				
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
			sortname: 'fecha',
			viewrecords: true,//
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#gridFacturas").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				waitwindow("", "close");
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);

				var total = 0;

				// Obtener el número total de páginas
				var grid = $(this);
					var totalPages = grid.getGridParam("lastpage");
					var totalFactura = 0;
					var totalPagado = 0;

					// Función para sumar la columna "importeFactura"
					function sumarImporteFactura() {
						var ids = grid.getDataIDs();
						for (var i = 0; i < ids.length; i++) {
							var rowData = grid.getRowData(ids[i]);
							var importeFactura = parseFloat(rowData.importeFactura.replace(/[^0-9.-]+/g,""));
							var importePagado = parseFloat(rowData.importePagado.replace(/[^0-9.-]+/g,""));
							totalFactura += importeFactura;
							totalPagado += importePagado;
						}
					}

					// Sumar la columna "importeFactura" de las páginas actuales y anteriores
					sumarImporteFactura();
					for (var i = 2; i <= totalPages; i++) {
						grid.trigger("reloadGrid", [{ page: i, current: false }]);
						sumarImporteFactura();
					}

					$("#txt_importeFactura").val(totalFactura.toLocaleString('en-EN', {minimumFractionDigits: 2}));
					$("#txt_importePagado").val(totalPagado.toLocaleString('en-EN', {minimumFractionDigits: 2}));
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
			/*{
				icon:"icon-group pink",	
				title:'Mostrar beneficiarios',
				click: function(event){
					if (($("#gridFacturas").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG238, "", "gritter-info");
					}
					else
					{
						var selr = jQuery('#gridFacturas').jqGrid('getGridParam','selrow');
						
						if(selr)
						{
							var rowData = jQuery("#gridFacturas").getRowData(selr);
							$('#gd_BeneficiariosFactura').jqGrid('clearGridData');
							var urlu='ajax/json/json_fun_obtener_beneficiarios_por_factura.php?iEmpleado='+ rowData.numEmp+'&iFactura='+rowData.idfactura+'&inicializar='+0;
							$("#gd_BeneficiariosFactura").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
							$('#dlg_BeneficiariosFactura').modal('show');
						}
						else
						{
							showalert(LengStrMSG.idMSG239, "", "gritter-info");
						}	
					}	
				}
			},*/
			{
				icon:"icon-print",
				title:'Imprimir',//button: true
				click:function (event)
				{
					if ( ($("#gridFacturas").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG87, "", "gritter-info");						
					}
					else
					{
						//IMPRIMIR
						//fnImprimir();
						fnGenerarPDF();
					}	
				}
			},
			{
				icon:"icon-comments-alt green",	
				title:'Ver aclaraciones',
				click:function (event)
				{
					// if($("#cbo_Estatus").val() != 4){
						// showalert("Solo es posible revisar blog de las factus en aclaración", "", "gritter-info");
						// return;
					// }else{
						if (($("#gridFacturas").find("tr").length - 1) == 0 ) {
							showalert(LengStrMSG.idMSG248, "", "gritter-info");
						} else {
							var selr = jQuery('#gridFacturas').jqGrid('getGridParam','selrow');
							if(selr){
								var rowData = jQuery("#gridFacturas").getRowData(selr);
								if (rowData['idEstatus'] != 4 && rowData['idEstatus'] != 6){
									showalert("Solo es posible revisar blog de las facturas en aclaración", "", "gritter-info");
									return;
								} else {
									fnConsultaBlog(rowData.numEmp, rowData.idfactura);
									fnActualizarBlog(rowData.idfactura);
									$( '#hid_factura' ).val(rowData.idfactura);
									$( '#hid_empleado' ).val(rowData.numEmp);
									if ( rowData.idEstatus == 6 ) {
										$("#txt_mensaje").prop('disabled', true);
										$("#btn_EnviarComentario").prop('disabled', true);
									} else {
										$("#txt_mensaje").prop('disabled', false);
										$("#btn_EnviarComentario").prop('disabled', false);
									}
									$('#dlg_Blog').modal('show');
								}
							} else {
								$( '#hid_factura' ).val("");
								showalert(LengStrMSG.idMSG250, "", "gritter-info");
							}
						}	
					// }
				}	
			},
			{
				icon:'icon-list blue',
				title:'Ver Factura',
				click: function(event) {
					if (($("#gridFacturas").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						VerFactura();
					}
					event.preventDefault();
				}
			}]
		});	
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
		setSizeBtnGrid('id_button2',35);
		setSizeBtnGrid('id_button3',35);
	}
	$("#btn_ver").on("click", function(event) {
		var cnt_ver_factura = $( "#cnt_ver_factura" ).dialog({
			modal: true,
			title: "<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-ok'></i> Factura</h4></div>",
			title_html: true,
			width: 1800,
			height: 900,
			autoOpen: false,
			buttons: [
				{
					text: "Cerrar",
					"class" : "btn btn-primary btn-mini",
					click: function() {
						// $("#gd_Facturas").jqGrid('resetSelection');
						// iFacturaSeleccionada = 0;
						$( this ).dialog( "close" );
					}
				}
			]
		});

		cnt_ver_factura.dialog("open");
		event.preventDefault();
	});
	function VerFactura() {
		var selr = jQuery('#gridFacturas').jqGrid('getGridParam', 'selrow');
		var rowData = jQuery('#gridFacturas').getRowData(selr);
		if ( selr ) {
			$("#nIsFactura").val(0);
			$("#idfactura").val(rowData.idfactura);
			$("#sFilename").val('');
			$("#sFiliePath").val('');
			cargarFactura();
		} else {
			showalert("Seleccione un registro", "", "gritter-info");
		}
	}
	function cargarFactura() {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_leerfactura.php',
			data:{
				session_name: Session
				, 'nIsFactura' : $("#nIsFactura").val()
				, 'idFactura'  : $("#idfactura").val()
				, 'sFilename'  : $("#sFilename").val()
				, 'sFiliePath' : $("#sFiliePath").val()
			},
		})
		.done(function(data){
			SessionIs();
			var sanitizedData = limpiarCadena(data);
			data = json_decode(sanitizedData);
			if ( data.estado == 0 ) {
				leerFactura(data);
			} else {
				loadIs = true;
				showalert(data.mensaje, "", "gritter-info");
			}
		})
		.fail(function(s) {
			// alert("Error al cargar ajax/json/json_leerfactura.php"); $('#pag_content').fadeOut();
			showalert("Ocurrio un problema al cargar la factura", "", "gritter-warning");
		})
		.always(function() {});
	}
	function leerFactura(obj) {
		if ( obj.isFactura == 0 ) {
			$("#div_contenido").html("<img src='"+obj.noDeducible+"' alt='Error: 404 not found'/>");
		} else {
			$("#div_contenido").html(obj.factura);
			
			$("#btn_ver").click();
		}
		loadIs = true;
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
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
		var opciones= {
			beforeSubmit: function(){
			}, 
			uploadProgress: function(){
			},
			success: function(data) 
			{
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if (dataJson.estado !=1) {
					showalert(LengStrMSG.idMSG252, "","gritter-warning");
				} else {
					showalert(LengStrMSG.idMSG253, "","gritter-success");
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
	function ConsultarEmpleado(callback)
	{
		// console.log("consulta empleado al limpiar");
		$.ajax({type: "POST", 
		url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
		data: { 
				'session_name': Session,
				'iEmpleado':$("#txt_Numemp").val()
			}
		})
		.done(function(data){	
			var sanitizedData = limpiarCadena(data);			
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson!=null)
			{
				/*
				if(dataJson[0].cancelado==1)
				{
					
					showalert(LengStrMSG.idMSG246, "","gritter-info");
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
					*/
					$("#txt_Nombre").val(dataJson[0].nombre+' '+dataJson[0].appat+' '+dataJson[0].apmat);
					$("#txt_Centro").val(dataJson[0].centro);
					$("#txt_NombreCentro").val(dataJson[0].nombrecentro);
					$("#txt_fechaIngreso").val(dataJson[0].fec_alta);
					
					$("#txt_sueldoMensual").val(dataJson[0].sueldo);
					$("#txt_rutaPago").val(dataJson[0].nombrerutapago);
					$("#txt_tarjeta").val(dataJson[0].numerotarjeta);
					$("#txt_topePropocional").val(dataJson[0].topeproporcion);
					CargarDatosGenerales();
				// }	
				
			}
			else
			{
				showalert(LengStrMSG.idMSG247, "","gritter-info");	
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
				
			}
			callback();
		});	
	}
	function CargarDatosGenerales()
	{
		// console.log("Entra al limpiar");
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
				var sanitizedData = limpiarCadena(data);			
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson != 0)
				{
					var ImporteFormato="0";
					$("#txt_topeMensual").val(dataJson.topeMensual);
					ImporteFormato=accounting.formatMoney(dataJson.acumulado, "", 2);
					$("#txt_acumuladoFacturas").val(ImporteFormato);
					ImporteFormato=accounting.unformat($("#txt_topePropocional").val())-accounting.unformat($("#txt_acumuladoFacturas").val());
					ImporteFormato=accounting.formatMoney(ImporteFormato, "", 2);
					$("#txt_topeRestante").val(ImporteFormato);
				}
				else
				{
					showalert(dataJson.mensaje, "","gritter-warning");	
				}
			});
		}	
	}
	function CargarGridColaborador(){
		jQuery("#grid_colaborador").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG45,
			colModel:[
				{name:'num_emp',index:'num_emp', width:80, sortable: false,align:"center",fixed: true},
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
			//postData:{session_name:Session},			
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
	function fnEstructuraGridCentros(){
		//grid_Centros
		jQuery("#grid_Centros").jqGrid({
			//url:'ajax/json/',
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG57,
			colModel:[
				{name:'numero',index:'numero', width:100, sortable: false,align:"center",fixed: false},
				{name:'nombre',index:'nombre', width:303, sortable: false,align:"left",fixed: false}
			],
			scrollrows : true,
			width: 420,
			loadonce: false,
			shrinkToFit: false,
			height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#grid_Centros_pager',
			sortname: 'idu_centro',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#grid_Centros").jqGrid('getGridParam', 'reccount');
				// console.log(registros);
				if (registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			ondblClickRow: function(id) {
				var Data = jQuery("#grid_Centros").jqGrid('getRowData',id);
				$('#txt_CentroF').val(Data['numero']);  
				$('#txt_NombreCentroF').val(Data['numero']+' '+Data['nombre']);
				$('#txt_CentroBusqueda').val("");	
				$('#txt_NomCentroBusqueda').val("");	
				$('#grid_Centros').jqGrid('clearGridData');
				$("#dlg_AyudaCentro").modal('hide');
			}
		});
	}
	function fnCargarGridBeneficiario()
	{
		jQuery("#gd_BeneficiariosFactura").jqGrid({
			datatype: 'json',
			//mtype: 'POST',
			colNames:LengStr.idMSG126,
			colModel:[
			{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
				{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'fec_nac_beneficiario',        index:'fec_nac_beneficiario',   width:100,  sortable: false,    align:"left",   fixed: true,    hidden:true},
				{name:'edad_anio_beneficiario',     index:'edad_anio_beneficiario',     width:100,  sortable: false,    align:"left",   fixed: true,    hidden:true},
				{name:'idu_parentesco',		index:'idu_parentesco', 	width:100, 	sortable: false,	align:"left",	fixed: true,    hidden:true},
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
			//viewrecords : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			// caption:'Beneficiarios',
			caption:' ',
			//pager : "#gd_Aclaracion_pager",
			//--Para que el tama�o sea automatico muy bueno ya con los otros cambios se evita crear tablas
			width: null,
			shrinkToFit: false,
			height: 120,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			//----------------------------------------------------------------------------------------------------------
			//caption: 'Cifras',
			pgbuttons: false,
			pgtext: null,
			//postData:{session_name:Session},
			
			loadComplete: function (Data) {
				var registros = jQuery("#gd_BeneficiariosFactura").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
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
		////////////// GRID DE PORCENTAJES ///////////////////

	jQuery("#gd_Porcentajes").jqGrid({
		datatype: 'json',
		colNames:LengStr.idMSG134,
		colModel:[
			{name:'idu_escolaridad',	index:'idu_escolaridad', 		width:150, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_escolaridad',	index:'nom_escolaridad', 	width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_parentesco',		index:'idu_parentesco', 	width:400, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nom_parentesco',		index:'nom_parentesco', 	width:150, 	sortable: false,	align:"left",	fixed: true},
			{name:'porcentaje',			index:'porcentaje', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'justificacion',		index:'justificacion', 		width:300, 	sortable: false,	align:"left",	fixed: true},
			{name:'fec_registro',		index:'fec_registro', 		width:100, 	sortable: false,	align:"left",	fixed: true},
			{name:'num_registro',		index:'num_registro', 	width:150, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'nom_registro',		index:'nom_registro', 	width:200, 	sortable: false,	align:"left",	fixed: true}
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		viewrecords : false,
		rowNum:-1,
		hidegrid: false,
		rowList:[],
		width: null,
		shrinkToFit: false,
		height:280,
		pgbuttons: false,
		pgtext: null,
		caption:' ',
		loadComplete: function (Data) {
		},
		onSelectRow: function(id) {
		}					
	});

	function LimpiarModalBusquedaEmpleados(){
		$('#txt_nombusqueda').val('');
		$('#txt_apepatbusqueda').val('');
		$('#txt_apematbusqueda').val('');
		$('#grid_colaborador').jqGrid('clearGridData');
	}
	function LimpiarModalBusquedaCentros(){
		$('#txt_CentroBusqueda').val('');
		$('#txt_NomCentroBusqueda').val('');
		$('#grid_Centros').jqGrid('clearGridData');
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
				showalert(LengStrMSG.idMSG88+' los estatus de las facturas', "","gritter-error");	
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+' los estatus de las facturas', "","gritter-error");	
			})
		.always(function() {});
	}
	function fnCargarDeducciones() 
	{
		var option="";
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
		data: { }
		}).done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				option = option + "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoDeduccion").trigger("chosen:updated").html(option);
				$("#cbo_tipoDeduccion").trigger("chosen:updated");
			}
			else
			{
				showalert(LengStrMSG.idMSG88+' los tipos de deducción', "","gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+' los tipos de deducción', "","gritter-error");
			})
		.always(function() {});
	}
	function fnCargarCiclosEscolares(){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {}
		}).done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = option + "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
			    $("#cbo_CicloEscolar").html(option);
				$("#cbo_CicloEscolar").trigger("chosen:updated");
			}
			else
			{
				showalert(LengStrMSG.idMSG88+' los ciclos escolares', "","gritter-error");
			}
		})
		.fail(function(s) 
		{
			showalert(LengStrMSG.idMSG88+' los ciclos escolares', "","gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	}
	function fnCargarRegiones(){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
			    $("#cbo_Region").html(option);
				$("#cbo_Region").trigger("chosen:updated");
			}
			else
			{
				showalert(LengStrMSG.idMSG88+' las regiones', "","gritter-error");
			}
		})
		.fail(function(s) 
		{
			showalert(LengStrMSG.idMSG88+' las regiones', "","gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	}
	function fnCargarCiudades(){
		if($(cbo_Region).val()>0)
		{
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_catalogociudades.php",
				data: {
					'region':$(cbo_Region).val()
				}
			}).done(function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Ciudad").html(option);
					$("#cbo_Ciudad").trigger("chosen:updated");
				}
				else
				{
					showalert(LengStrMSG.idMSG88+' las ciudades', "","gritter-error");	
				}
			})
			.fail(function(s) 
			{
				showalert(LengStrMSG.idMSG88+' las ciudades', "","gritter-error");	
				$('#cbo_Ciudad').fadeOut();
			})
			.always(function() {});
		}
		else
		{
			var option = "<option value='0'>TODAS</option>";
			$("#cbo_Ciudad").html(option);
		}	
	}
	function updatePagerIcons(table) {
		var replacement = 
		{
			'ui-icon-seek-first' : 'icon-double-angle-left bigger-140',
			'ui-icon-seek-prev' : 'icon-angle-left bigger-140',
			'ui-icon-seek-next' : 'icon-angle-right bigger-140',
			'ui-icon-seek-end' : 'icon-double-angle-right bigger-140'
		};
		$('.ui-pg-table:not(.navtable) > tbody > tr > .ui-pg-button > .ui-icon').each(function(){
			var icon = $(this);
			var $class = icon.attr('class').replace('ui-icon', '').replace('/^\s+|\s+$/g', '');
			
			if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
		})
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
		$('#gridFacturas').jqGrid('clearGridData');
		//var urlu='ajax/json/json_fun_obtener_movimientos_colegiaturas.php?nEmpleado='+nEmpleado+'&nEstatus='+$("#cbo_Estatus").val()+'&nCicloEscolar='+$("#cbo_CicloEscolar").val()+
		var urlu='ajax/json/json_fun_obtener_movimientos_colegiaturas_beneficiarios.php?nEmpleado='+nEmpleado+'&nEstatus='+$("#cbo_Estatus").val()+'&nCicloEscolar='+$("#cbo_CicloEscolar").val()+
		'&nTipoDeduccion='+$("#cbo_tipoDeduccion").val()+'&nRegion='+$("#cbo_Region").val()+'&nCiudad='+$("#cbo_Ciudad").val()+'&nCentro='+nCentro+'&inicializar='+inicializar+'&fechaini='+sFechaIni+'&fechafin='+sFechaFin;
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
	function fnGenerarPDF()
	{
		var sNombreReporte = 'rpt_consulta_movtos_pa'
			, iIdConexion = '190'
			, sFormatoReporte = 'pdf'
			, sOrderBy = 'fecha'
			, sOrderType = 'ASC'
			, sColumns = 'idEstatus, estatus, fechaEstatus, empEstatus, empEstatusNombre, fechaBaja, facturaFiscal, fechaFactura, fechaCaptura, idCicloEscolar, cicloEscolar, importeFactura, importePagado, importeTope, rfc, nombreEscuela, idTipoDeduccion, TipoDeduccion, motivoRechazo, idfactura, empleado, nombreempleado, fecha, id_tipodocumento, nom_tipodocumento';
		var sUrl = '';
			sUrl += 'nombre_reporte='+sNombreReporte;
			sUrl += '&id_conexion='+iIdConexion;
			sUrl += '&dbms=postgres';
			sUrl += '&formato_reporte='+sFormatoReporte;
			sUrl += '&nEmpleado='+nEmpleado;
			sUrl += '&nEstatus='+nEstatus;
			sUrl += '&nCicloEscolar='+nCicloEscolar;
			sUrl += '&nTipoDeduccion='+nTipoDeduccion;
			sUrl += '&dFechaInicial='+sFechaIni;
			sUrl += '&dFechaFinal='+sFechaFin;
			sUrl += '&nRegion='+nRegion;
			sUrl += '&nCiudad='+nCiudad;
			sUrl += '&nCentro='+nCentro;
			sUrl += '&iRowsPerPage=-1';
			sUrl += '&iPage=-1';
			sUrl += '&sOrderBy='+sOrderBy;
			sUrl += '&sOrderType='+sOrderType;
			sUrl += '&sColumns='+sColumns;
			
		// console.log(sUrl);
		// return;
		
		var xhr = new XMLHttpRequest();
		var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS + '/reportes';
		
		xhr.open("POST", report_url, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		
		xhr.addEventListener("progress", function(evt){
			if( evt.lengthComputable ) {
				var percentComplete = evt.loaded / evt.total;
				// console.log(percentComplete);
			}
		}, false);
		
		xhr.responseType = "blob";
		xhr.onreadystatechange = function(){
			waitwindow('','close');
			if ( this.readyState == XMLHttpRequest.DONE && this.status == 200 ) {
				var filename = sNombreReporte + "." + sFormatoReporte;
				
				var link = document.createElement('a');
				link.href = window.URL.createObjectURL(xhr.response);
				link.download = filename;
				link.style.display = 'none';
				
				document.body.appendChild(link);
				
				link.click();
				
				document.body.removeChild(link);
			} else if (this.readyState == XMLHttpRequest.DONE && this.status != 200 ) {
				showalert("No se pudo generar el reporte", "", "gritter-warning");
			}
		}
		waitwindow("Obteniendo reporte, por favor espere...", "open");
		xhr.send(sUrl);
		/*	
		var urlu='ajax/json/impresion_consulta_movimientos_personal_admon.php?'+
		'nEmpleado='+nEmpleado+
		'&nEstatus='+nEstatus+
		'&nCicloEscolar='+nCicloEscolar+
		'&page='+-1+
		'&rows='+-1+
		'&nTipoDeduccion='+nTipoDeduccion+
		'&nRegion='+nRegion+
		'&nCiudad='+nCiudad+
		'&nCentro='+nCentro+
		'&inicializar=0&fechaini='+sFechaIni+
		'&fechafin='+sFechaFin+
		'&cEstatus='+cEstatus+
		'&cCiclo='+cCicloEscolar+
		'&cDeduccion='+cTipoDeduccion+
		'&cRegion='+cRegion+
		'&cCiudad='+cCiudad+
		'&cCentro='+cCentro+
		'&cEmpleado='+cEmpleado;
	
		location.href = urlu;
		*/
	}
});	
	
// Petición 39116 - Crecer textarea conforme se va escribiendo.
function autoGrow(element) {
	element.style.height = "5px";  // Establece temporalmente la altura a 5px para obtener el scrollHeight correcto
	element.style.height = (element.scrollHeight) + "px";
}

$("#dlg_Blog").find(".close").click(function(){
	$("#txt_mensaje").val("");
	$("#txt_mensaje").css("height","20px");
});
		
function calculateTotal(columnName) {
	var total = 0;

    // Obtiene los IDs de todas las filas en el grid
    var ids = $("#gridFacturas").jqGrid('getDataIDs');

    // Itera sobre los IDs y suma los valores de la columna especificada
    for (var i = 0; i < ids.length; i++) {
        // Obtiene los datos de la fila actual
        var rowData = $("#gridFacturas").jqGrid('getRowData', ids[i]);
        // Obtiene el valor de la columna especificada
        var value = parseFloat(rowData[columnName].replace(/[^\d.-]/g, ''));
        // Si es un número válido, sumarlo al total
        if (!isNaN(value)) {
            total += value;
        }
    }

    return total.toFixed(2);
}

