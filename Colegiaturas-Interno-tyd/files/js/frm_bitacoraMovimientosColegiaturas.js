$(function(){
	var dFechaInicio, dFechaFin = '19000101';
	var sNomEmpleado, sNomRegion, sNomCiudad, sNomCentro, sNomTipoMovimiento = '';
	var iEmpleado, iTipoMovimientoBitacora, iRegion, iCiudad, iCentro = 0;
	var myPostData = '';
	
	$(function(){
		setTimeout(InicializarFormulario(), 0);
	});
	function InicializarFormulario(){
		soloNumero("txt_numEmpleado");
		cargarComboTiposMovimientos(function(){
				crearGridBitacorasColegiaturas(1);
		});
		// crearGridBitacorasColegiaturas(1);
		crearGridBusquedaDeCentros();
		crearControlesFechas();
		cargarComboRegiones( function(){
			cargarComboCiudades();
		});
		cargarGridColaborador();
		stopScrolling(function(){
			draggablesModal();
		});
	}
	// StopScrolling
	function stopScrolling(callback){
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
	}
	function draggablesModal(){
		$(".draggable").draggable({
			// commenting the line below will make scrolling while dragging work
			helper: "clone",
			scroll: true,
			revert: "invalid"
		});
	}
	/***================EVENTOS================================*/
	$("#cbo_tipoMovimiento").change(function(event){
		jQuery("#gridBitacoraColegiaturas-table").jqGrid("GridUnload");
		iTipoMovimientoBitacora = $("#cbo_tipoMovimiento").val();
		crearGridBitacorasColegiaturas(iTipoMovimientoBitacora);
		
		event.preventDefault();
	});
	$("#cbo_ciudad").change(function(event){
		LimpiarGrid();
		
		event.preventDefault();
	});
	$("#cbo_region").change(function(event){
		LimpiarGrid();
		$("#cbo_ciudad").val(0);
		// $("#cbo_ciudad").val($("#cbo_ciudad option:first").val());
		cargarComboCiudades();
		
		event.preventDefault();
	});
/*/-----------------TXT COLABORADOR--------------------------*/
	$("#txt_numEmpleado").change(function(event){
		LimpiarGrid();
		event.preventDefault();
	});
	$("#txt_numEmpleado").keydown(function(event)
	{
		//alert(event.which);
		if (event.which == 13  )
		{
			if($("#txt_numEmpleado").val().length == 8)
			{
				Cargar_Empleado();
			}
			else{
				
				$("#txt_numEmpleado").val('');
				$("#txt_numEmpleado").focus();
			
				$("#txt_Nombre").val('');
				
			}
			$("#btn_Consultar").prop("disabled", false);
			event.preventDefault();
		}
		if(event.which == 8)
		{
			$("#txt_Nombre").val('');
		}
	});

	// $("#txt_numEmpleado").focusin(function(event){
		// $("#btn_Consultar").prop("disabled", true);
		// event.preventDefault();
	// });
	// $("#txt_numEmpleado").focusout(function(event){
		// if($("#txt_numEmpleado").val().length == 8){
			// Cargar_Empleado();
		// }else{
			// $("#txt_numEmpleado").val('');
			// $("#txt_numEmpleado").focus();
			// $("#txt_Nombre").val('');
		// }
		// $("#btn_Consultar").prop("disabled", false);
		// event.preventDefault();
	// });
	//==============================================================================================================
	//========================BOTON CONSULTAR===================================================
	$("#btn_Consultar").click(function(event){
		Consultar(0);
		event.preventDefault();
	});
	//-------------------BOTON BUSQUEDA COLABORADOR-(INTERFAZ)----------------------------------------
	$("#btn_buscar").click(function(event) {
		LimpiarModalBusquedaEmpleados();
		$("#dlg_BusquedaEmpleados").modal('show');
		
		event.preventDefault();
	});
	//------------------BOTON BUSQUEDA COLABORADOR-(MODAL)---------------------------------------------
	$("#btn_buscarCOL").click(function(event){
		
		var campos=0;
		if($('#txt_NombreBusqueda').val().espacioblanco()!='')
		{
			campos++;	
		}
		if($('#txt_apepatbusqueda').val().espacioblanco()!='')
		{
			campos++;
		}
		if($('#txt_apematbusqueda').val().espacioblanco()!='')
		{
			campos++;
		}
		if(campos<2)
		{
			showalert(LengStrMSG.idMSG91, "", "gritter-info");
		}
		else
		{
		
			$("#grid_colaborador").jqGrid('setGridParam', {
				url:'ajax/json/json_proc_busquedaEmpleados_sueldos.php?nombre=' + $('#txt_NombreBusqueda').val()
						+ '&apepat=' + $('#txt_apepatbusqueda').val()
						+ '&apemat=' + $('#txt_apematbusqueda').val()
			}).trigger("reloadGrid");
		}	
		event.preventDefault();
	});
	//-----------BOTON BUSQUEDA CENTROS (INTERFAZ)-----------------------------------------------------------------------------
	$("#btn_ayudaCentro").click(function(event){
		jQuery("#grid_Centros").jqGrid("clearGridData");
		$('#txt_CentroBusqueda').val("");
		$('#txt_NomCentroBusqueda').val("");
		$("#dlg_AyudaCentro").modal('show');
		event.preventDefault();
	});
	//----------BOTON BUSQUEDA CENTROS (MODAL)--------------------------------------------------------------------------------
	$("#btn_BuscarCentro").click(function(event) {
		$("#grid_Centros").jqGrid("clearGridData");
		if($('#txt_CentroBusqueda').val().espacioblanco()=="" &&  $('#txt_NomCentroBusqueda').val().espacioblanco()=="")
		{
			showalert(LengStrMSG.idMSG92,"","gritter-info");
			$('#txt_CentroBusqueda').val("");
			$('#txt_NomCentroBusqueda').val("");
			
		}
		else
		{
			$("#grid_Centros").jqGrid('setGridParam', {
			url:'ajax/json/json_proc_ayudacentros_grid.php?'
				+ 'iNumRegion=' + $('#cbo_region').val()
				+ '&iNumCiudad=' + $('#cbo_ciudad').val()
				+ '&iCentro=' + $('#txt_CentroBusqueda').val().espacioblanco()
				+ '&cNomCentro=' + $('#txt_NomCentroBusqueda').val().espacioblanco()
				+ '&session_name='+ Session
			}).trigger("reloadGrid");
		}
		event.preventDefault();
	});
	
	//----------BOTON LIMPIAR---------------------------------------------------------------------------------------------------
	$("#btn_Limpiar").click(function(event){
		$("#gridBitacoraColegiaturas-table").jqGrid("clearGridData");
		Consultar(1);
		$("#cbo_region").val($("#cbo_region option").first().val());
		
		$("#cbo_ciudad").val(0);
		$("#txt_NombreCentroF").val("");
		cargarComboRegiones( function(){
			cargarComboCiudades();
		});
		$("#txt_numEmpleado").val("");
		$("#txt_Nombre").val("");
		iEmpleado = 0
		, iRegion = 0
		, iCiudad = 0
		, iCentro = 0;
		$("#txt_CentroF").val(0);
		
		event.preventDefault();
	});
	/**====================FIN EVENTOS==================================================================================
	===================================================================================================================*/
	function crearGridBitacorasColegiaturas(iTipoMovimientoBitacora){
		if(iTipoMovimientoBitacora == 1){
			jQuery("#gridBitacoraColegiaturas-table").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG130,
				colModel:[
					{ name:'fec_registro', 		 	 index:'fec_registro', 		 	 width:90,  align:"center",  fixed: true },
					{ name:'nom_tipo_movimiento',	 index:'nom_tipo_movimiento', 	 width:200, align:"left", 	 fixed: true, hidden:true },
					{ name:'folio_factura', 		 index:'folio_factura', 		 width:300, align:"left", 	 fixed: true },
					{ name:'importe_original', 		 index:'importe_original', 		 width:120, align:"right",   fixed: true },
					{ name:'importe_pagado', 		 index:'importe_pagado', 		 width:120, align:"right",   fixed: true },
					{ name:'idu_empleado', 		 	 index:'idu_empleado', 		 	 width:320, align:"left", 	 fixed: true },
					{ name:'numero_puesto', 	 	 index:'numero_puesto', 	 	 width:240, align:"left", 	 fixed: true },
					{ name:'porcentaje', 	     	 index:'porcentaje', 	 	 	 width:100, align:"left", 	 fixed: true },
					{ name:'nom_escolaridad', 	     index:'nom_escolaridad', 	 	 width:200, align:"left", 	 fixed: true },
					{ name:'idu_centro', 	 	 	 index:'idu_centro', 	 	 	 width:260, align:"left", 	 fixed: true },
					{ name:'idu_ciudad', 	 	 	 index:'idu_ciudad', 	 	 	 width:180, align:"left", 	 fixed: true },
					{ name:'idu_region', 	 	 	 index:'idu_region', 	 	 	 width:180, align:"left", 	 fixed: true },
					{ name:'justificacion', 		 index:'justificacion', 		 width:450, align:"left", 	 fixed: true, hidden:false },
					{ name:'idu_usuario',			 index:'idu_usuario',			 width:320, align:"left", 	 fixed: true },
					{ name:'idu_puesto_usuario', 	 index:'idu_puesto_usuario', 	 width:320, align:"left", 	 fixed: true },
					{ name:'idu_centro_usuario', 	 index:'idu_centro_usuario', 	 width:320, align:"left", 	 fixed: true }
				],
				scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION
				viewrecords: true,
				hidegrid: false,
				width: null,
				shrinkToFit: false,
				height: 400,
				rowNum: 10,
				rowList: [10, 20, 30],
				pager: '#gridBitacoraColegiaturas-pager',
				sortname: "fec_registro",
				sortorder: "desc",
				caption:'Bitácora de Movimientos',
				pgbuttons: true,
				postData:{ session_name:Session },
				beforeRequest:function(){
					myPostData = $('#gridBitacoraColegiaturas-table').jqGrid("getGridParam", "postData");
				},
				loadComplete: function (Data){
					var registros = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function() {	updatePagerIcons(table); }, 0);
				},
				onSelectRow: function(Numemp){
					var Data = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getRowData',Numemp);
					Numemp = Data.Numemp;
				}
			});
		}
		if(iTipoMovimientoBitacora == 2){
			jQuery("#gridBitacoraColegiaturas-table").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG66,
				colModel:[
					{ name:'fec_registro', 			index:'fec_registro', 			width:150, align:"center",  fixed: true },
					{ name:'idu_empleado', 			index:'idu_empleado', 			width:320, align:"left",  	fixed: true },
					{ name:'numero_puesto', 		index:'numero_puesto', 			width:240, align:"left",  	fixed: true },
					{ name:'porcentaje', 			index:'porcentaje', 		 	width:100, align:"left",  	fixed: true },
					{ name:'nom_escolaridad', 		index:'nom_escolaridad', 		width:200, align:"left",  	fixed: true },
					{ name:'idu_centro', 			index:'idu_centro', 			width:260, align:"left",  	fixed: true },
					{ name:'idu_ciudad', 			index:'idu_ciudad', 			width:180, align:"left",  	fixed: true },
					{ name:'idu_region', 			index:'idu_region', 			width:180, align:"left",  	fixed: true },
					{ name:'estatus_empleado', 		index:'estatus_empleado', 		width:180, align:"left",  	fixed: true },
					{ name:'opc_bloqueado_estatus', index:'opc_bloqueado_estatus', 	width:180, align:"left",  	fixed: true },
					{ name:'justificacion', 		index:'justificacion', 			width:450, align:"left",  	fixed: true, hidden:false },
					{ name:'idu_usuario', 			index:'idu_usuario', 			width:320, align:"left",  	fixed: true },
					{ name:'idu_puesto_usuario', 	index:'idu_puesto_usuario', 	width:320, align:"left",  	fixed: true },
					{ name:'idu_centro_usuario', 	index:'idu_centro_usuario', 	width:320, align:"left",  	fixed: true }
				],
				scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION
				viewrecords: true,
				hidegrid: false,
				width: null,
				shrinkToFit: false,
				height: 400,
				rowNum: 10,
				rowList: [10, 20, 30],
				pager: '#gridBitacoraColegiaturas-pager',
				sortname: "fec_registro,idu_empleado",
				sortorder: "desc",
				caption:'Bitácora de Movimientos',
				pgbuttons: true,
				postData:{ session_name:Session },
				beforeRequest:function(){
					myPostData = $('#gridBitacoraColegiaturas-table').jqGrid("getGridParam", "postData");
				},
				loadComplete: function (Data){
					var registros = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function() {	updatePagerIcons(table); }, 0);
				},
				onSelectRow: function(Numemp){
					var Data = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getRowData',Numemp);
					Numemp = Data.Numemp;
				}
			});
		}
		//OPCION #3 NO SE UTILIZARA
		if(iTipoMovimientoBitacora == 3){
			jQuery("#gridBitacoraColegiaturas-table").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG67,
				aligncolNames:"center",
				colModel:[
					{ name:'fec_registro', 		 	 index:'fec_registro', 				width:90,  align:"center", fixed: true },
					{ name:'hora_moviento', 		 index:'hora_moviento', 			width:80,  align:"center", fixed: true,  hidden:true },
					{ name:'movimiento', 			 index:'movimiento', 				width:200, align:"left",   fixed: true },
					{ name:'folio_factura', 		 index:'folio_factura', 			width:300, align:"left",   fixed: true, hidden:true },
					{ name:'importe_original', 		 index:'importe_original', 			width:120, align:"right",  fixed: true, hidden:true },
					{ name:'importe_pagado', 		 index:'importe_pagado', 			width:120, align:"right",  fixed: true, hidden:true },
					{ name:'opc_bloqueado_estatus',  index:'opc_bloqueado_estatus', 	width:120, align:"left",   fixed: true, hidden:true },			
					{ name:'idu_empleado', 			 index:'idu_empleado', 				width:320, align:"left",   fixed: true },
					{ name:'numero_puesto', 	 	 index:'numero_puesto', 			width:240, align:"left",   fixed: true },
					{ name:'idu_centro', 	 	 	 index:'idu_centro', 				width:260, align:"left",   fixed: true },
					{ name:'idu_ciudad', 	 	 	 index:'idu_ciudad', 				width:180, align:"left",   fixed: true },
					{ name:'idu_region', 	 	 	 index:'idu_region', 				width:180, align:"left",   fixed: true },
					{ name:'justificacion', 		 index:'justificacion', 			width:450, align:"left",   fixed: true, hidden:false },
					{ name:'estatus_empleado', 		 index:'estatus_empleado', 			width:90,  align:"left",   fixed: true },
					{ name:'idu_usuario',			 index:'idu_usuario', 				width:320, align:"left",   fixed: true },
					{ name:'idu_puesto_usuario', 	 index:'idu_puesto_usuario', 		width:320, align:"left",   fixed: true },
					{ name:'idu_centro_usuario', 	 index:'idu_centro_usuario', 		width:320, align:"left",   fixed: true }
				],
				scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION
				viewrecords: true,
				hidegrid: false,
				width: null,
				shrinkToFit: false,
				height: 400,
				rowNum: 10,
				rowList: [10, 20, 30],
				pager: '#gridBitacoraColegiaturas-pager',
				sortname: "fec_registro",
				sortorder: "desc",
				caption:'Bitácora de Movimientos',
				pgbuttons: true,
				postData:{ session_name:Session },
				beforeRequest:function(){
					myPostData = $('#gridBitacoraColegiaturas-table').jqGrid("getGridParam", "postData");
				},
				loadComplete: function (Data){
					var registros = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						// showalert("No se encontro información", "", "gritter-info");
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function() {	updatePagerIcons(table); }, 0);
				},
				onSelectRow: function(Numemp){
					var Data = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getRowData',Numemp);
					Numemp = Data.Numemp;
				}
			});
		}
		if(iTipoMovimientoBitacora == 4 || iTipoMovimientoBitacora == 5){
			jQuery("#gridBitacoraColegiaturas-table").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG68,
				colModel:[
					{ name:'fec_registro', 			 index:'fec_registro', 			width:120, align:"center",  fixed: true },
					{ name:'nom_tipo_movimiento', 	 index:'nom_tipo_movimiento', 	width:200, align:"left", 	fixed: true,  hidden:true  },
					{ name:'idu_empleado', 			 index:'idu_empleado', 			width:320, align:"left", 	fixed: true },
					{ name:'numero_puesto', 	 	 index:'numero_puesto', 		width:240, align:"left", 	fixed: true },
					{ name:'porcentaje', 	 		 index:'porcentaje',			width:100, align:"left", 	fixed: true },
					{ name:'nom_escolaridad', 	 	 index:'nom_escolaridad',		width:200, align:"left", 	fixed: true },
					{ name:'idu_centro', 	 		 index:'idu_centro', 			width:260, align:"left", 	fixed: true },
					{ name:'idu_ciudad', 	 		 index:'idu_ciudad', 			width:180, align:"left", 	fixed: true },
					{ name:'idu_region', 	 		 index:'idu_region', 			width:180, align:"left", 	fixed: true },					
					{ name:'justificacion', 		 index:'justificacion', 		width:450, align:"left", 	fixed: true, hidden:false },
					{ name:'estatus', 				 index:'estatus', 				width:90,  align:"left", 	fixed: true,  hidden:true },
					{ name:'idu_usuario',			 index:'idu_usuario', 			width:320, align:"left", 	fixed: true },
					{ name:'idu_puesto_usuario', 	 index:'idu_puesto_usuario',	width:320, align:"left", 	fixed: true },
					{ name:'idu_centro_usuario', 	 index:'idu_centro_usuario',	width:320, align:"left", 	fixed: true }
				],
				scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION
				viewrecords: true,
				hidegrid: false,
				width: null,
				shrinkToFit: false,
				height: 400,
				rowNum: 10,
				rowList: [10, 20, 30],
				pager: '#gridBitacoraColegiaturas-pager',
				sortname: "fec_registro",
				sortorder: "desc",
				caption:'Bitácora de Movimientos',
				pgbuttons: true,
				postData:{ session_name:Session },
				beforeRequest:function(){
					myPostData = $('#gridBitacoraColegiaturas-table').jqGrid("getGridParam", "postData");
				},
				loadComplete: function (Data){
					var registros = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						// showalert("No se encontro información", "", "gritter-info");
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function() {	updatePagerIcons(table); }, 0);
				},
				onSelectRow: function(Numemp){
					var Data = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getRowData',Numemp);
					Numemp = Data.Numemp;
				}
			});
		}
		if(iTipoMovimientoBitacora == 7){
			jQuery("#gridBitacoraColegiaturas-table").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG131,
				colModel:[
					{ name:'idu_empleado', 		index:'idu_empleado', 		width:375, align:"left",  fixed: true},
					{ name:'idu_centro',		index:'idu_centro', 		width:300, align:"left",  fixed: true},
					{ name:'numero_puesto',	 	index:'numero_puesto', 		width:250, align:"left",  fixed: true},
					{ name:'porcentaje',	 	index:'porcentaje', 		width:100, align:"center",fixed: true},
					{ name:'nom_escolaridad', 	index:'nom_escolaridad',	width:200, align:"left",  fixed: true},
					{ name:'idu_region',	 	index:'idu_region', 		width:250, align:"left",  fixed: true},
					{ name:'idu_ciudad',	 	index:'idu_ciudad', 		width:250, align:"left",  fixed: true},
					{ name:'fec_alta',	 		index:'fec_alta', 			width:150, align:"center",fixed: true},
					{ name:'idu_usuario',	 	index:'idu_usuario', 		width:375, align:"left",  fixed: true},
					{ name:'idu_puesto_usuario',index:'idu_puesto_usuario', width:375, align:"left",  fixed: true},
					{ name:'idu_centro_usuario',index:'idu_centro_usuario', width:375, align:"left",  fixed: true},
					{ name:'fec_registro',	 	index:'fec_registro', 		width:150, align:"center",fixed: true},
				],
				scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION
				viewrecords: true,
				hidegrid: false,
				width: null,
				shrinkToFit: false,
				height: 400,
				rowNum: 10,
				rowList: [10, 20, 30],
				pager: '#gridBitacoraColegiaturas-pager',
				sortname: "fec_registro",
				sortorder: "desc",
				caption:'Bitácora de Movimientos',
				pgbuttons: true,
				postData:{ session_name:Session },
				beforeRequest:function(){
					myPostData = $('#gridBitacoraColegiaturas-table').jqGrid("getGridParam", "postData");
				},
				loadComplete: function (Data){
					var registros = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						// showalert("No se encontro información", "", "gritter-info");
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function() {	updatePagerIcons(table); }, 0);
				},
				onSelectRow: function(Numemp){
					var Data = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getRowData',Numemp);
					Numemp = Data.Numemp;
				}
			});
		}	
		if(iTipoMovimientoBitacora == 8){
			jQuery("#gridBitacoraColegiaturas-table").jqGrid({
				datatype: 'json',
				mtype: 'GET',
				colNames:LengStr.idMSG132,
				colModel:[
					{ name:'nombre', 			index:'nombre', 		width:375, align:"left",  fixed: true},
					{ name:'nom_centro',		index:'nom_centro', 		width:300, align:"left",  fixed: true},
					{ name:'nom_puesto',		index:'nom_puesto', 		width:250, align:"left",  fixed: true},
					{ name:'porcentaje',		index:'porcentaje', 		width:100, align:"center",fixed: true},
					{ name:'escolaridad', 		index:'escolaridad',	width:200, align:"left",  fixed: true},
					// { name:'parentesco', 		index:'parentesco',	width:200, align:"left",  fixed: true, hidden: true},
					// { name:'seccion', 			index:'seccion',	width:200, align:"left",  fixed: true, hidden: true},
					{ name:'justificacion',		index:'justificacion', 		width:250, align:"left",  fixed: true},
					{ name:'fecha_ingreso',		index:'fecha_ingreso', 		width:250, align:"left",  fixed: true},
					{ name:'fec_movimiento',	index:'fec_movimiento', 			width:150, align:"center",fixed: true},
					{ name:'nombre_autorizo',	 index:'nombre_autorizo', 		width:375, align:"left",  fixed: true},
					{ name:'nom_puesto_autorizo',index:'nom_puesto_autorizo', width:375, align:"left",  fixed: true},
					{ name:'nom_puesto_autorizo',index:'nom_puesto_autorizo', width:375, align:"left",  fixed: true}
				],
				scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION
				viewrecords: true,
				hidegrid: false,
				width: null,
				shrinkToFit: false,
				height: 400,
				rowNum: 10,
				rowList: [10, 20, 30],
				pager: '#gridBitacoraColegiaturas-pager',
				sortname: "fec_ingreso",
				sortorder: "desc",
				caption:'Bitácora de Movimientos',
				pgbuttons: true,
				postData:{ session_name:Session },
				beforeRequest:function(){
					myPostData = $('#gridBitacoraColegiaturas-table').jqGrid("getGridParam", "postData");
				},
				loadComplete: function (Data){
					var registros = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getGridParam', 'reccount');
					if(registros == 0){
						// showalert("No se encontro información", "", "gritter-info");
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					var table = this;
					setTimeout(function() {	updatePagerIcons(table); }, 0);
				},
				onSelectRow: function(Numemp){
					var Data = jQuery("#gridBitacoraColegiaturas-table").jqGrid('getRowData',Numemp);
					Numemp = Data.Numemp;
				}
			});
		}
		barButtongrid({
			pagId:"#gridBitacoraColegiaturas-pager",
			position:"left",
			Buttons:[
				{
					icon:"icon-print blue",
					title:"Imprimir PDF",
					click: function(event){
						if(($("#gridBitacoraColegiaturas-table").find("tr").length - 1) == 0){
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
	//==========FUNCIONES============================================================================================
	function cargarComboTiposMovimientos(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_movimientos_bitacora.php",
			data: {}
		}).done(function(data,textStatus,jqXHR){
			// var dataJson = jQuery.parseJSON(data);
			var dataJson = JSON.parse(jqXHR.responseText);
			if(dataJson.estado == 0)
			{
				// var option = "<option value='0'>SELECCIONE</option>";
				var option = "";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoMovimiento").html(option);
				$("#cbo_tipoMovimiento").trigger("chosen:updated");
				
				callback();
			}else{
				var error=LengStrMSG.idMSG88+' los tipos de movimientos';
				showalert(error, "", "gritter-warning");
			}
		})
		.fail(function(s) {
			var error=LengStrMSG.idMSG88+' los tipos de movimientos';
			showalert(error, "", "gritter-warning");
		})
		.always(function() {});
	}
	//------------------------------GRID CENTROS
	function crearGridBusquedaDeCentros(){
		jQuery("#grid_Centros").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG57,
			colModel:[
				{name:'numero', index:'numero', width:100, sortable: false, align:"center", fixed: false},
				{name:'nombre', index:'nombre', width:330, sortable: false, align:"left", fixed: false}
			],
			pgbuttons: true,
			scrollrows: true,
			width: 480,
			loadonce: false,
			shrinkToFit: false,
			height: 200,
			rowNum: 10,
			//rowList: [10, 20, 30],
			pager: '#grid_Centros_pager',
			sortname: 'idu_centro',
			viewrecords: true,
			hidegrid: false,
			sortorder: "asc",
			loadComplete: function (Data){
				var registros = jQuery("#grid_Centros").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					// showalert("No se encontro información", "", "gritter-info");
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			ondblClickRow: function(id)
			{
				var Data = jQuery("#grid_Centros").jqGrid('getRowData',id);
				$('#txt_CentroF').val(Data['numero']);
				$('#txt_NombreCentroF').val(Data['numero']+' '+Data['nombre']);
				$('#txt_CentroBusqueda').val("");
				$('#txt_NomCentroBusqueda').val("");
				$('#grid_Centros').jqGrid('clearGridData');
				$("#dlg_AyudaCentro").modal('hide');
				//$("#gridBitacoraColegiaturas-table").clearGridData("clearGridData");
				LimpiarGrid();
				iCentroParametro = Data['numero'];
				cCentroNombre = Data['nombre'];
			}
		});
		jQuery("#grid_Centros").jqGrid('navGrid','#grid_Centros_pager',{search:false, edit:false,add:false,del:false});	
		jQuery("#grid_Centros_pager_left").hide();
	}
	//---------------------------COMBO REGION------------------------------------
	function cargarComboRegiones(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data,textStatus,jqXHR) {
			// var dataJson = jQuery.parseJSON(data);
			var dataJson = JSON.parse(jqXHR.responseText);
			if(dataJson.estado == 0)
			{
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_region").html(option);
				$("#cbo_region").trigger("chosen:updated");
				
				callback();
			}
			else
			{
				//showalert(dataJson.mensaje, "", "gritter-warning");
				var error=LengStrMSG.idMSG88+' las regiones';
				showalert(error, "", "gritter-warning");
			}
		})
		.fail(function(s) {
			var error=LengStrMSG.idMSG88+' las regiones';
			showalert(error, "", "gritter-warning");
			$('#cbo_region').fadeOut();
		})
		.always(function() {});
	}
	//---------------------COMBO CIUDAD-------------------------------------------
	function cargarComboCiudades(){
		if($("#cbo_region").val() > 0){
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_catalogociudades.php",
				data: { //limpiarCadena
					'region':limpiarCadena($("#cbo_region").val())
				}
			}).done(function(data,textStatus,jqXHR) {
				// var dataJson = jQuery.parseJSON(data);
				var dataJson = JSON.parse(jqXHR.responseText);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_ciudad").html(option);
					$("#cbo_ciudad").trigger("chosen:updated");
				}
				else {
					var error=LengStrMSG.idMSG88+' las ciudades';
					showalert(error, "", "gritter-warning");
				}
			})
			.fail(function(s) {
				var error=LengStrMSG.idMSG88+' las ciudades';
				showalert(error, "", "gritter-warning");
				$('#cbo_ciudad').fadeOut();
			})
			.always(function() {});
		} else {
			var option = "<option value='0'>TODAS</option>";
			$("#cbo_ciudad").html(option);
		}	
	}
	//------------------------BUSQUEDA DE COLABORADOR---------------------------------
	function Cargar_Empleado(){
		var respon = $('#txt_numEmpleado').val();
		$.ajax({
			type: "POST",
			url: 'ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php',
			data: {	'iEmpleado':respon }
		})
		.done(function(data){
			// json = jQuery.parseJSON(data);
			json = JSON.parse(data);
			if(json==null){
				showalert(LengStrMSG.idMSG89, "", "gritter-info");
					$("#txt_numEmpleado").val('');
					$("#txt_numEmpleado").focus();
					$("#txt_Nombre").val('');
			}else if (json[0].cancelado == 1){
				showalert(LengStrMSG.idMSG90, "", "gritter-info");
				$("#txt_numEmpleado").val('');
				$("#txt_numEmpleado").focus();
				$("#txt_Nombre").val('');
			}
			else {
					$("#txt_Nombre").val(json[0].nombre+' '+json[0].appat+' '+json[0].apmat);
				 }
			})
		.fail(function(s){
			var error=LengStrMSG.idMSG88+' los datos del empleado';
			showalert(error, "", "gritter-warning");
		})
		.always(function() {});
	};
	//------------------------CONTROLES DE FECHAS-------------------------------------
	function crearControlesFechas(){
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
			onSelect: function( selectedDate ){
				$( "#txt_FechaFin" ).datepicker( "option", "minDate", selectedDate );
				//$("#gridBitacoraColegiaturas-table").jqGrid('clearGridData');
				LimpiarGrid();
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
			onSelect: function( selectedDate ){
				$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", selectedDate );
				//$("#gridBitacoraColegiaturas-table").jqGrid('clearGridData');
				LimpiarGrid();
			}
		}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
		
		// $("#txt_FechaInicio" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).datepicker("setDate",new Date());
		
		$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
		$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
		
		$(".ui-datepicker-trigger").css('display','none');
	}
	function cargarGridColaborador(){
		jQuery("#grid_colaborador").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG45,
			colModel:[
				{name:'num_emp',index:'num_emp', width:120, sortable: false,align:"center",fixed: true},
				{name:'nombre',index:'nombre', width:170, sortable: false,align:"center",fixed: true},
				{name:'apepat',index:'apepat', width:160, sortable: false,align:"center",fixed: true},
				{name:'apemat',index:'apemat', width:160, sortable: false,align:"center",fixed: true},
				{name:'centro',index:'centro', width:100, sortable: false,align:"center",fixed: true},
				{name:'nombreCentro',index:'nombreCentro', width:150, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'puesto',index:'puesto', width:185, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'nombrePuesto',index:'nombrePuesto', width:180, sortable: false,align:"center",fixed: true},
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: 920,
			shrinkToFit: false,
			height: 200,
			caption: 'Colaboradores',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			loadComplete: function (Data) { 
				var registros = jQuery("#gridBitacoraColegiaturas_marcado").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					// showalert("No se encontro información", "", "gritter-info");
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
			},
			ondblClickRow: function(clave) {
				var Data = jQuery("#grid_colaborador").jqGrid('getRowData',clave);
				
				$("#txt_numEmpleado").val(Data.num_emp);
				$("#txt_Nombre").val(Data.nombre + ' ' + Data.apepat + ' ' + Data.apemat);
				//$("#gridBitacoraColegiaturas-table").jqGrid('clearGridData');
				LimpiarGrid();
				$("#dlg_BusquedaEmpleados").modal('hide');
				 LimpiarModalBusquedaEmpleados();
			}
		});
	};
	function Consultar(inicializar){
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
		//TipoMovimiento
		iTipoMovimientoBitacora = $("#cbo_tipoMovimiento").val();
		sNomTipoMovimiento = $("#cbo_tipoMovimiento option:selected").text();
		//Colaborador
		iEmpleado = $("#txt_numEmpleado").val().espacioblanco();
		if(iEmpleado == ''){
			iEmpleado = 0;
		}
		sNomEmpleado = $("#txt_Nombre").val().espacioblanco();
		//Region
		iRegion = $("#cbo_region").val();
		sNomRegion = $("#cbo_region opction:selected").text();
		//Ciudad
		iCiudad = $("#cbo_ciudad").val();
		sNomCiudad = $("#cbo_ciudad option:selected").text();
		//Centro
		iCentro = $("#txt_CentroF").val();
		if(iCentro == ''){
			iCentro = 0;
		}
		sNomCentro = $("#txt_NombreCentroF").val().espacioblanco();
		var sUrl = '';
		if(iTipoMovimientoBitacora==6){
			sUrl = 'ajax/json/json_fun_bitacora_conceptos_sat_colegiaturas.php?'
				+ 'dFechaInicio=' + dFechaInicio
				+ '&dFechaFin=' + dFechaFin
				+ '&iEmpleado=' + iEmpleado
				+ '&session_name='+ Session;
		} else if(iTipoMovimientoBitacora==8){ 
			sUrl = 'ajax/json/json_fun_obtener_bit_colegiaturas_config_descuentos.php?'
				+ 'dFechaInicio=' + dFechaInicio
				+ '&dFechaFin=' + dFechaFin
				+ '&iEmpleado=' + iEmpleado
				+ '&iRegion=' + iRegion
				+ '&iCiudad=' + iCiudad
				+ '&iCentro=' + iCentro
				+ '&session_name='+ Session;
		} else { 
			sUrl = 'ajax/json/json_fun_obtener_bitacora_movimientos_colegiaturas.php?'
				+ 'dFechaInicio=' + dFechaInicio
				+ '&dFechaFin=' + dFechaFin
				+ '&iEmpleado=' + iEmpleado
				+ '&iTipoMovimientoBitacora=' + iTipoMovimientoBitacora
				+ '&iRegion=' + iRegion
				+ '&iCiudad=' + iCiudad
				+ '&iCentro=' + iCentro
				+ '&session_name='+ Session;
		}
		
		if(inicializar == 1){
			sUrl = '';
		}
		// return;
		$("#gridBitacoraColegiaturas-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
	}
	function GenerarPDF(){
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
		// TipoMovimiento
		iTipoMovimientoBitacora = $("#cbo_tipoMovimiento").val();
		sNomTipoMovimiento = $("#cbo_tipoMovimiento option:selected").text();
		// Colaborador
		iEmpleado = $("#txt_numEmpleado").val().espacioblanco();
		if(iEmpleado == ''){
			iEmpleado = 0;
		}
		sNomEmpleado = $("#txt_Nombre").val().espacioblanco();
		// Region
		iRegion = $("#cbo_region").val();
		sNomRegion = $("#cbo_region option:selected").text();
		// Ciudad
		iCiudad = $("#cbo_ciudad").val();
		sNomCiudad = $("#cbo_ciudad option:selected").text();
		// Centro
		iCentro = $("#txt_CentroF").val();
		if(iCentro == ''){
			iCentro = 0;
		}
		sNomCentro = $("#txt_NombreCentroF").val().espacioblanco();
		
		
		var sUrl = 'ajax/json/';
		switch(iTipoMovimientoBitacora){
			case "1":
				sUrl += 'impresion_json_fun_obt_bit_mov_colegiaturas_editar.php?&session_name='+Session;
				sUrl += '&dFechaInicio='+dFechaInicio;
				sUrl += '&dFechaFin='+dFechaFin;
				sUrl += '&iEmpleado='+iEmpleado;
				sUrl += '&iTipoMovimientoBitacora='+iTipoMovimientoBitacora;
				sUrl += '&iRegion='+iRegion;
				sUrl += '&iCiudad='+iCiudad;
				sUrl += '&iCentro='+iCentro;
				sUrl += '&sNomTipoMovimiento='+sNomTipoMovimiento;
				sUrl += '&sNomEmpleado='+sNomEmpleado;
				sUrl += '&sNomRegion='+sNomRegion;
				sUrl += '&sNomCiudad='+sNomCiudad;
				sUrl += '&sNomCentro='+sNomCentro;
				sUrl += '&sidx='+myPostData.sidx;
				sUrl += '&sord='+myPostData.sord;
				
				location.href = sUrl;
			break;
			case "2":
				sUrl += 'impresion_json_fun_obt_bit_mov_colegiaturas_bloqueado.php?&session_name='+Session;
				sUrl += '&dFechaInicio='+dFechaInicio;
				sUrl += '&dFechaFin='+dFechaFin;
				sUrl += '&iEmpleado='+iEmpleado;
				sUrl += '&iTipoMovimientoBitacora='+iTipoMovimientoBitacora;
				sUrl += '&iRegion='+iRegion;
				sUrl += '&iCiudad='+iCiudad;
				sUrl += '&iCentro='+iCentro;
				sUrl += '&sNomTipoMovimiento='+sNomTipoMovimiento;
				sUrl += '&sNomEmpleado='+sNomEmpleado;
				sUrl += '&sNomRegion='+sNomRegion;
				sUrl += '&sNomCiudad='+sNomCiudad;
				sUrl += '&sNomCentro='+sNomCentro;
				sUrl += '&sidx='+myPostData.sidx;
				sUrl += '&sord='+myPostData.sord;
				
				location.href = sUrl;
			break;
			case "3"://CANCELAR PAGO NO SE UTILIZA
			break;
			case "4":
				sUrl += 'impresion_json_fun_obt_bit_mov_colegiaturas_marcado.php?&session_name='+Session;
				sUrl += '&dFechaInicio='+dFechaInicio;
				sUrl += '&dFechaFin='+dFechaFin;
				sUrl += '&iEmpleado='+iEmpleado;
				sUrl += '&iTipoMovimientoBitacora='+iTipoMovimientoBitacora;
				sUrl += '&iRegion='+iRegion;
				sUrl += '&iCiudad='+iCiudad;
				sUrl += '&iCentro='+iCentro;
				sUrl += '&sNomTipoMovimiento='+sNomTipoMovimiento;
				sUrl += '&sNomEmpleado='+sNomEmpleado;
				sUrl += '&sNomRegion='+sNomRegion;
				sUrl += '&sNomCiudad='+sNomCiudad;
				sUrl += '&sNomCentro='+sNomCentro;
				sUrl += '&sidx='+myPostData.sidx;
				sUrl += '&sord='+myPostData.sord;
				
				location.href = sUrl;
			break;
			case "5":
				sUrl += 'impresion_json_fun_obt_bit_mov_colegiaturas_marcado.php?&session_name='+Session;
				sUrl += '&dFechaInicio='+dFechaInicio;
				sUrl += '&dFechaFin='+dFechaFin;
				sUrl += '&iEmpleado='+iEmpleado;
				sUrl += '&iTipoMovimientoBitacora='+iTipoMovimientoBitacora;
				sUrl += '&iRegion='+iRegion;
				sUrl += '&iCiudad='+iCiudad;
				sUrl += '&iCentro='+iCentro;
				sUrl += '&sNomTipoMovimiento='+sNomTipoMovimiento;
				sUrl += '&sNomEmpleado='+sNomEmpleado;
				sUrl += '&sNomRegion='+sNomRegion;
				sUrl += '&sNomCiudad='+sNomCiudad;
				sUrl += '&sNomCentro='+sNomCentro;
				sUrl += '&sidx='+myPostData.sidx;
				sUrl += '&sord='+myPostData.sord;
				
				location.href = sUrl;
			break;
			case "6"://CONCEPTOS PAGABLES NO SE UTILIZA
			break;
			case "7":
				sUrl += 'impresion_json_fun_obt_bit_mov_colegiaturas_prestacion.php?&session_name='+Session;
				sUrl += '&dFechaInicio='+dFechaInicio;
				sUrl += '&dFechaFin='+dFechaFin;
				sUrl += '&iEmpleado='+iEmpleado;
				sUrl += '&iTipoMovimientoBitacora='+iTipoMovimientoBitacora;
				sUrl += '&iRegion='+iRegion;
				sUrl += '&iCiudad='+iCiudad;
				sUrl += '&iCentro='+iCentro;
				sUrl += '&sNomTipoMovimiento='+sNomTipoMovimiento;
				sUrl += '&sNomEmpleado='+sNomEmpleado;
				sUrl += '&sNomRegion='+sNomRegion;
				sUrl += '&sNomCiudad='+sNomCiudad;
				sUrl += '&sNomCentro='+sNomCentro;
				sUrl += '&sidx='+myPostData.sidx;
				sUrl += '&sord='+myPostData.sord;
				
				location.href = sUrl;
			break;
			case "8":
				sUrl += 'impresion_json_fun_obt_bit_mov_colegiaturas_configuracion_descuento.php?&session_name='+Session;
				sUrl += '&dFechaInicio='+dFechaInicio;
				sUrl += '&dFechaFin='+dFechaFin;
				sUrl += '&iEmpleado='+iEmpleado;
				sUrl += '&iTipoMovimientoBitacora='+iTipoMovimientoBitacora;
				sUrl += '&iRegion='+iRegion;
				sUrl += '&iCiudad='+iCiudad;
				sUrl += '&iCentro='+iCentro;
				sUrl += '&sNomTipoMovimiento='+sNomTipoMovimiento;
				sUrl += '&sNomEmpleado='+sNomEmpleado;
				sUrl += '&sNomRegion='+sNomRegion;
				sUrl += '&sNomCiudad='+sNomCiudad;
				sUrl += '&sNomCentro='+sNomCentro;
				sUrl += '&sidx='+myPostData.sidx;
				sUrl += '&sord='+myPostData.sord;
				
				location.href = sUrl;
			break;
		}
		
	}
	
	function LimpiarGrid(){
		jQuery("#gridBitacoraColegiaturas-table").jqGrid("clearGridData");
	}
	function LimpiarModalBusquedaEmpleados(){
		$('#txt_NombreBusqueda').val('');
		$('#txt_apepatbusqueda').val('');
		$('#txt_apematbusqueda').val('');
		$('#grid_colaborador').jqGrid('clearGridData');
		
	};
	function setSizeBtnGrid(id,tamanio){//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	
	String.prototype.espacioblanco = function () {
		return this.replace(/^\s+|\s+$/g, "");
	};
	
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
})