$(function(){
	ConsultaClaveHCM()
	/** Inicialización
	-------------------------------------------------- */
		var nConsulta=1;
		var nCargarConsulta=0;
		var lConsultandoCifras = false;
		var TotalISR = 0;
		var ischecked = 0;
		var iContinuar = 0;
		var iEmpleadoGlobal = 0;
		
		// setTimeout(function(){
			// fnObtenerFacturasColegiaturasParaTraspaso(1);
		// }, 500);
		
		var lastSel = 0;
		var iSel = 0;
		var inicializarGrid = true;
		
		//Variables de filtrado
		var iOpcion, iFiltro = 0;
		var cBusqueda, cFiltro, cDescripcionFiltros = "";
		var iQuincena = 0;
		var iTipoNomina = 0;
	
		function sanitize(string) { //función para sanitizar variables en JS
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

	/** Eventos
	-------------------------------------------------- */
	validarCierreColegiaturas(function(){
		//console.log(iContinuar);
		if (iContinuar > 0) {
			ObtenerQuincena();
			GridFacturas();
			stopScrolling(function(){
				dragablesModal();
			});
		}
	});

	ObtenerDatosUsuario();
	
	function stopScrolling(callback) {
		$("#dlg_Cifras").on("show.bs.modal", function () {
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
	}
	function dragablesModal(){
		$(".draggable").draggable({
			// commenting the line below will make scrolling while dragging work
			helper: "clone",
			scroll: true,
			revert: "invalid"
		});
	}
	//BOTON CERRAR CIFRAS
	$("#btn_CerrarCifras").click(function(event){
		$('#dlg_Cifras').modal('hide');
		event.preventDefault();
	});
	
	//BOTON BUSCAR
	$("#btn_buscar").click(function(event) {
		/*iOpcion=0;
		iFiltro = $("#cbo_Tipo").val();
		cBusqueda= $("#txt_Buscar").val();
		nCargarConsulta=1;
		ActualizarGrid();*/
		// fnObtenerFacturasColegiaturasParaTraspaso(0);
		
		if ( nCargarConsulta > 0 ) {
			inicializarGrid = false;
		} else {
			inicializarGrid = true;			
		}
		fnObtenerFacturasColegiaturasParaTraspaso(1);
		//fnObtenerFacturasColegiaturasParaTraspaso(0);
		nCargarConsulta++;
		event.preventDefault();
	});
	
	//BOTON QUITAR FILTRO
	$("#btn_QuitarFiltro").click(function(event){
		$("#cbo_Tipo").val(0);
		$("#txt_Buscar").val("");
		$("#cbo_TipoMovimiento").val(0);
		if($("#txt_TipoNomina").val() == 1){
			$("#cbo_TipoNomina").val(0);
		}else{
			$("#cbo_TipoNomina").val(1);
		}
		// fnObtenerFacturasColegiaturasParaTraspaso(1);
		event.preventDefault();
	});
	
	//CHANGE TIPO
	$("#cbo_Tipo").change(function(event){
		$("#txt_Buscar").val("");
		event.preventDefault();
	});
	
	/** Inicializar grids
	-------------------------------------------------- */
	function GridFacturas (){
		jQuery("#gd_Facturas").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			//url:url,
			colNames:LengStr.idMSG101, //59
			colModel:[						
				{name:'marcado',index:'marcado',
							width:80, align: 'center', sortable:false,
							edittype:'checkbox-checkbox-2', editable:true, editoptions: { value:"True:False"}, 
							formatter: "checkbox", formatoptions: {disabled : false}},							
				{name:'id',				index:'id', 			width:40, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'idajuste',		index:'ajuste', 		width:40, 	sortable: false,	align:"center",	fixed: true, hidden:true}, //tipo movimiento
				{name:'ajuste',			index:'ajuste', 		width:75, 	sortable: false,	align:"left",	fixed: true},
				{name:'ottp',			index:'ottp', 			width:40, 	sortable: false,	align:"center",	fixed: true},			
				{name:'empleado',		index:'empleado', 		width:90, 	sortable: false,	align:"left",	fixed: true},
				{name:'nombreempleado',	index:'nombreempleado', width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'becadohojaazul',	index:'becadohojaazul', width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'becado',			index:'becado', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nombrebecado',	index:'nombrebecado', 	width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'factura',		index:'factura', 		width:270, 	sortable: false,	align:"left",	fixed: true},
				{name:'fecfactura',		index:'fecfactura', 	width:90, 	sortable: false,	align:"center",	fixed: true},
				{name:'idciclo',		index:'idciclo', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'ciclo',			index:'ciclo', 			width:90, 	sortable: false,	align:"center",	fixed: true},
				{name:'feccaptura',		index:'feccaptura', 	width:90, 	sortable: false,	align:"left",	fixed: true},
				{name:'idtipopago',		index:'idtipopago', 	width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'tipopago',		index:'tipopago', 		width:100, 	sortable: false,	align:"left",	fixed: true},
				{name:'idperiodo',		index:'idperiodo', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'periodo',		index:'periodo', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'importefactura',	index:'importefatura', 	width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'importepago',	index:'importepago', 	width:90, 	sortable: false,	align:"right",	fixed: true},
				{name:'idestudio',		index:'idestudio', 		width:150, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'estudio',		index:'estudio', 		width:150, 	sortable: false,	align:"left",	fixed: true},
				{name:'idescuela',		index:'idescuela', 		width:90, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'escuela',		index:'escuela', 		width:260, 	sortable: false,	align:"left",	fixed: true},
				{name:'rfc',			index:'rfc', 			width:110, 	sortable: false,	align:"left",	fixed: true},
				{name:'descuento',		index:'descuento', 		width:80, 	sortable: false,	align:"center",	fixed: true},
				{name:'iddeduccion',	index:'iddeduccion', 	width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'deduccion',		index:'deduccion', 		width:150, 	sortable: false,	align:"left",	fixed: true},
				{name:'observaciones',	index:'observaciones', 	width:200, 	sortable: false,	align:"left",	fixed: true/*, hidden:false*/},
				{name:'idrutapago',		index:'idrutapago', 	width:90, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'rutapago',		index:'rutapago', 		width:150, 	sortable: false,	align:"left",	fixed: true},
				{name:'tarjeta',		index:'tarjeta', 		width:150, 	sortable: false,	align:"left",	fixed: true},				
				{name:'idfactura',		index:'idfactura', 		width:150, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'marcar',			index:'marcar', 		width:150, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'usuario',		index:'usuario', 		width:150, 	sortable: false,	align:"left",	fixed: true, hidden:true}
			],
			//multiselect:true,
			caption:'Listado de Facturas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 400,
			rowNum: 10,
			rowList:[10, 20, 30],
			pager: '#gd_Facturas_pager',
			sortname: 'empleado',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,
			postData: {session_name:Session
				, "iInicializar" : 1
			},
			beforeRequest:function(){
				var myPostData = $('#gd_Facturas').jqGrid("getGridParam", "postData");
				myPostData.iInicializar = inicializarGrid ? 1 : 0;
			},
			loadComplete: function (Data){
				inicializarGrid = false;
				$('#gd_Facturas :checkbox').change(function(e){
					var id = $(e.target).closest('tr')[0].id;
					var rowData = $('#gd_Facturas').getRowData(id);
					// var ischecked = 0;
					
					if ( $(this).is(":checked") ) {
						ischecked = 1;
					}else{
						ischecked = 0;
					}
					// showalert("OPCIONES MARCADAS= "+ischecked, "", "gritter-info");
					// return;
						marcarFactura(rowData['idfactura'], ischecked, iQuincena, iTipoNomina, function(){
						
						});
				});				
				
													
				var registros = jQuery("#gd_Facturas").jqGrid('getGridParam', 'reccount');
				if(registros == 0 && nCargarConsulta==1){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}				
				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);			
			},
			onSelectRow: function(id){
				var rowData = $(this).getRowData(id);
				if(id >= 0){
					var fila = jQuery("#gd_Facturas").getRowData(id);
					iSel = 1;
				}	
			}				
		});
		barButtongrid({
			pagId:"#gd_Facturas_pager",
			position:"left",//center right
			Buttons:[
			{
				icon:"icon-check",
				click:function (event){
					if ( ($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					else{
						//console.log('marcar factura');
						marcarFactura(-1, 1, iQuincena, iTipoNomina, function(){
							fnObtenerFacturasColegiaturasParaTraspaso(0);
						});
					}	
				},
				title:'Marcar todos los registros'
			},
			{
				icon:"icon-check-empty",
				click:function (event){
					if ( ($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}else{
						marcarFactura(0, 1, 0, 0, function(){
							fnObtenerFacturasColegiaturasParaTraspaso(0);
						});
					}	
				},
				title:'Desmarcar todos los registros'
			},
			{
				icon:"icon-bar-chart ",
				click:function (event){
					$("#gd_Cifras").clearGridData();
					fnConsultarCifras();
				},
				title:'Consultar Cifras'//button: true
			},
			{
				icon:"icon-group pink",	
				click: function(event){
					var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
					if(selr && iSel==1){
						$("#gd_BeneficiariosFactura").jqGrid('clearGridData');
						var rowData = jQuery("#gd_Facturas").getRowData(selr);
						var urlu = 'ajax/json/json_fun_obtener_beneficiarios_por_factura.php?'
											+ 'iEmpleado=' + rowData.empleado
											+ '&iFactura=' + rowData.idfactura
											+ '&inicializar=' + 0;
						$("#gd_BeneficiariosFactura").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid"); 
						$('#dlg_BeneficiariosFactura').modal('show');
					}else{
						// showalert(LengStrMSG.idMSG307, "", "gritter-info");
						showalert("Seleccione la factura en la que desea ver los beneficiarios", "", "gritter-info");
					}	
				},
				title:'Mostrar beneficiarios'
			},
			{
				icon:"icon-print",
				click:function (event){
					if ( ($("#gd_Facturas").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}else{
						ImprimirTraspasos();
					}
				},
				title:'Imprimir'//button: true
			},
			{
				icon:"icon-share-alt green",
				click:function (event){
					var seleccionados=0;
					if ( ($("#gd_Facturas").find("tr").length - 1) == 0) {
						showalert(LengStrMSG.idMSG308, "", "gritter-info");
					} else {
						// Validar si ya se realizo el cierre del ciclo anterior
						$.ajax({
							type:'POST',
							url:'ajax/json/json_fun_generar_traspaso_colegiaturas.php?',
							data:{
								'iOpcion':3,
								'session_name' : Session
							},
							beforeSend:function(){},
							success:function(data){
								//var dataJson = jQuery.parseJSON(data);
								var dataJson = JSON.parse(data);
								if (dataJson.estado > 0) {
									// Validar que se hayan seleccionado registros para el traspaso
									$.ajax({type:'POST',
										url:'ajax/json/json_fun_generar_traspaso_colegiaturas.php?',
										data: { 
											'iOpcion':2,
											'session_name': Session
										},
										beforeSend:function(){},
										success:function(data){
											//var dataJson = jQuery.parseJSON(data);
											var dataJson = JSON.parse(data);
											if (dataJson.estado == 0) {
												showalert(dataJson.mensaje, "", "gritter-info"); // No se han seleccionado registros para el traspaso
											} else {
												// Validar si ya se realizó el traspaso y pregunta si desea realizarlo de nuevo
												$.ajax({type:'POST',
													url:'ajax/json/json_fun_generar_traspaso_colegiaturas.php?',
													data: { 
														'iOpcion':0,
														'session_name': Session
													},
													beforeSend:function(){},
													success:function(data){
														//var dataJson = jQuery.parseJSON(data);
														var dataJson = JSON.parse(data);
														if (dataJson.estado == 1) {
															// Ya se realizó el traspaso, pregunta si lo realizará de nuevo
															bootbox.confirm(dataJson.mensaje, 
																function(result) {
																	if (result) {
																		fnTraspaso();
																	}
																});
														} else {
															// Realizar el traspaso
															bootbox.confirm(LengStrMSG.idMSG309, 
																function(result){
																	if (result){
																		fnTraspaso();
																	}
																});
														}
													},
													error:function onError(){},
													complete:function(){},
													timeout: function(){},
													abort: function(){}
												});
											}
										},
										error:function onError(){},
										complete:function(){},
										timeout: function(){},
										abort: function(){}
									});
								} else {
									// bootbox.confirm(dataJson.mensaje + ' <b>¿Desea generar el cierre?</b>', function(result) {
										// if(result) {
											// showalert("Hay que generar el cierre", "", "gritter-warning");
											// activaOpc(findIndex('frm_generarCierre.php'),'frm_generarCierre.php');
										// }
									// });
									bootbox.confirm(dataJson.mensaje + ' <b>¿Desea generar el cierre?</b>','No', 'Si', 
									function(result){
										if (result){
											activaOpc(findIndex('frm_generarCierre.php'),'frm_generarCierre.php');
										}
									});
								}
							},
							error:function onError(){},
							complete:function(){},
							timeout: function(){},
							abort: function(){}
						});
					}
				},
				title:'Traspasar'//button: true
			}]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
		setSizeBtnGrid('id_button2',35);
		setSizeBtnGrid('id_button3',35);
		setSizeBtnGrid('id_button4',35);
		setSizeBtnGrid('id_button5',35);
	}
	
	
	//GRID BENEFICIARIOS FACTURA
	jQuery("#gd_BeneficiariosFactura").jqGrid({
		datatype: 'json',
		//mtype: 'POST',
		colNames:LengStr.idMSG126,
		colModel:[
			{name:'idu_hoja_azul',		index:'idu_hoja_azul', 		width:50, 	sortable: false,	align:"left",	fixed: true, 	hidden:true},
			{name:'idu_beneficiario',	index:'idu_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true},
			{name:'nom_beneficiario',	index:'nom_beneficiario', 	width:250, 	sortable: false,	align:"left",	fixed: true},
			{name:'nac_beneficiario',	index:'nac_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true}, //Raul Agrego
			{name:'edad_beneficiario',	index:'edad_beneficiario', 	width:50, 	sortable: false,	align:"left",	fixed: true,	hidden:true}, //Raul Agrego
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
		//viewrecords : true,
		viewrecords : false,
		rowNum:-1,
		hidegrid: false,
		rowList:[],
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
			
			var table = this;
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
			var Total;
			var grid = $('#gd_BeneficiariosFactura');
			Total = grid.jqGrid('getCol', 'imp_importe', false, 'sum');
			$("#txt_TotalB").val(accounting.formatMoney(Total, "", 2));
			
		}			
	});
	
	//CIFRAS
	jQuery("#gd_Cifras").jqGrid({
		datatype: 'json',
		colNames:LengStr.idMSG113,
		colModel:[
			{name:'', 				index:'',				width:50, 	sortable:	false, 	align:"right", 	fixed:true},
			{name:'empleados',		index:'empleados',		width:110,	sortable:	false,	align:"right",	fixed:true},
			{name:'movimientos',	index:'movimientos', 	width:90,	sortable: 	false,	align:"right",	fixed: true},
			{name:'importe_factura',index:'importe_factura',width:110,	sortable: 	false,	align:"right",	fixed: true},
			{name:'importe_pagado',	index:'importe_pagado', width:110, 	sortable: 	false,	align:"right",	fixed: true},
			{name:'importe_ajuste',	index:'importe_ajuste', width:110, 	sortable: 	false,	align:"right",	fixed: true},
			{name:'importe_isr',	index:'importe_isr', 	width:110, 	sortable: 	false,	align:"right",	fixed: true},
			{name:'total_isr',		index:'total_isr', 		width:110, 	sortable: 	false,	align:"right",	fixed: true, hidden: true},
			{name:'total_gral',		index:'total_gral',		width:110, 	sortable: 	false,	align:"right",	fixed: true, hidden: false},
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		viewrecords : false,
		rowNum:-1,
		hidegrid: false,
		rowList:[],
		caption:'<i class="icon-bar-chart"></i>&nbsp;Consulta de Cifras',
		width: 850,
		shrinkToFit: false,
		height: 230,
		pgbuttons: false,
		pgtext: null,
		loadComplete: function (Data) {
			var table = this;
			var grid = $('#gd_Cifras');
			iTotalRegistros = grid.jqGrid('getCol', 'empleados');
			// console.log(iTotalRegistros);
			aTotalISR = grid.jqGrid('getCol', 'total_isr', false);
			TotalISR = aTotalISR[0].replace(',','');
			// console.log(TotalISR);
			// alert(TotalISR);

			if (lConsultandoCifras) {
				// var totalCifras = jQuery("#gd_Cifras").jqGrid('getGridParam', 'reccount');
				// console.log(iTotalRegistros);
				if (iTotalRegistros != 0)
				// if (rowData['empleados']>0)
				{
					$('#dlg_Cifras').modal('show');
				}
				else
				{
					showalert(LengStrMSG.idMSG312, "", "gritter-info");
				}
			}
			// alert(TotalISR);
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
		}
	});
	
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	/** Validar Cierre de Colegiaturas */
	function validarCierreColegiaturas(callback) {
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_validar_cierre_colegiaturas.php',
			data:{
				'session_name':Session
			},
			beforeSend:function(){},
			success:function(data){
				//var dataJson = jQuery.parseJSON(data);
				var dataJson = JSON.parse(data);
				if (dataJson.estado == 0) {
					bootbox.confirm(dataJson.mensaje+". \<b>¿Desea realizar el cierre?\</b>", 'No', 'Sí', function(result) {
						if(result) {
							activaOpc(findIndex('frm_generarCierre.php'), 'frm_generarCierre.php');
						} else {
							loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:dataJson.mensaje}});
							return;
						}
					});
				} else {
					iContinuar = iContinuar + 1;
					if (callback != undefined) {
						callback();
					}
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	
	//CONSULTAR CIFRAS
	function fnConsultarCifras()
	{
		//console.log ('consultar cifras');
		lConsultandoCifras = true;
		var urlu='ajax/json/json_fun_obtener_cifras_de_control.php?session_name=' + Session;
		$("#gd_Cifras").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");
		
	}
	
	//OBTENER FACTURAS PARA TRASPASO
	function fnObtenerFacturasColegiaturasParaTraspaso(iOpcion)
	{
		//console.log('iOpcion='+iOpcion);
		$('#gd_Facturas tr').off();
		$("#gd_Facturas_cb").off();
		$('#gd_Facturas tbody').off();
		$("#gd_Facturas").jqGrid('clearGridData');
		
		//Actualizar el valor de las variables de filtrado.
		iFiltro = $("#cbo_Tipo").val();
		cFiltro = $('#cbo_Tipo option:selected').html();
		cBusqueda = $("#txt_Buscar").val().toUpperCase();
		cBusqueda = cBusqueda.makeTrim(" ");
		iTipoMov=$("#cbo_TipoMovimiento").val();
		iQuincena = $("#txt_TipoNomina").val();
		iTipoNomina = $("#cbo_TipoNomina").val();
		//Validar que los filtros se esten aplicando correctamente.
		var filtrosValidados = false;
		//console.log('iFiltro='+iFiltro);
		if(iFiltro == "0")
		{
			filtrosValidados = true;
		}
		else
		{
			if(cBusqueda == "")
			{
				//Verificar que el campo de busqueda no este vacio. De otro modo se debe de avizar al usuario.
				filtrosValidados = false;
				var sMensaje=LengStrMSG.idMSG310;
				//"Favor de especificar que "+ cFiltro + " se va a buscar.";
				sMensaje=sMensaje.replace('cFiltro', cFiltro);
				showalert(sMensaje, "", "gritter-info");
			}
			else
			{
				filtrosValidados = true;
			}
		}
		
		//console.log ('filtrosValidados='+filtrosValidados);
		if(filtrosValidados == true)
		{
			var url = 'ajax/json/json_fun_obtener_facturas_colegiaturas_para_traspaso.php?' +
							'&iOpcion=' + iOpcion +
							'&ifiltro=' + iFiltro +
							'&cbusqueda=' + cBusqueda +
							'&itipomov=' + iTipoMov +
							'&iquincena=' + iQuincena +
							'&itiponomina=' + iTipoNomina +
							'&session_name=' + Session;
							
			$("#gd_Facturas").jqGrid('setGridParam', {
				url:url,
				postData:{session_name:Session
					, "iInicializar" : inicializarGrid ? 1 : 0
				}
			}).trigger("reloadGrid");
		}
	}
	
	//MARCAR FACTURA
	function marcarFactura(factura, marca, quincena, tiponom, callback)
	{
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_marcar_traspaso_colegiaturas.php?',
			data: { 
				'iFactura':factura,
				'iMarca':marca,
				'iQuincena':quincena,
				'iTipoNom':tiponom,
				'session_name': Session
			}
		})
		.done(function(data){
			if (callback != undefined) {
				callback();
			}
		});
	}	
	
	//TRASPASO
	function fnTraspaso()
	{
		
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_generar_traspaso_colegiaturas.php?',
			data: { 
				'iOpcion':1,
				'iQuincena': iQuincena,
				'session_name': Session
			}
		})
		.done(function(data){
			//var dataJson = jQuery.parseJSON(data);	
			var dataJson = JSON.parse(data);
			if(dataJson.estado>0)
			{
				var sMensaje='Proceso de traspaso realizado exitosamente, '+dataJson.mensaje;
				showalert(sMensaje, "", "gritter-info");
				nCargarConsulta=0;
				inicializarGrid = true;
				fnObtenerFacturasColegiaturasParaTraspaso(1);
			}	
			
		});
	}
	
	//CREAR LEYENDA FILTROS IMPRESION
	function CrearLeyendaFiltrosImpresion()
	{
		cDescripcionFiltros = "";
		if(iFiltro == "1")
		{
			cDescripcionFiltros +=  "FACTURA: " + cBusqueda;
		}
		else if(iFiltro == "2")
		{
			cDescripcionFiltros +=  "EMPLEADO: " + cBusqueda;
		}
		else
		{
			cDescripcionFiltros = "No se aplicaron filtros de busqueda.";
		}
	}
	
	//IMPRIMIR TRASPASOS
	function ImprimirTraspasos()
	{
		
		
		var totalRenglones = jQuery("#gd_Facturas").jqGrid('getGridParam', 'reccount');
		// console.log('REGISTROS ='+totalRenglones);
		// return;
		if(totalRenglones > 0)
		{
			var iCurrentPage = -1
				, iRowsPerPage = -1
				, iNumEmpleado = 0
				, sOrderColumn = 'empleado'
				, sOrderType = 'ASC'
				, sColumns = "clv_tipo_registro, des_tipo_registro, ottp, empleado, nomempleado, beneficiario_hoja_azul, beneficiario, nombeneficiario, facturafiscal, fechafactura, idciclo, nomciclo, fechacaptura, idtipopago, tipopago, periodo, des_periodo, importe_fac, importe_pago, idestudio, estudio, idescuela, escuela, rfc, descuento, iddeduccion, deduccion, observaciones, idrutapago, rutapago, numtarjeta, idfactura, marcado, usuario,conexion"
				, iOpt = nConsulta
				, siFiltro = iFiltro
				, sBusqueda = cBusqueda
				, idTipoMov = iTipoMov
				, idQuincena = iQuincena
				, idTipoNomina = iTipoNomina
				, idMetodo = 1;
				
				
			var sNombreReporte = 'rpt_traspaso_movimientos'
				, iIdConexion = '190'
				, sFormatoReporte = 'pdf';
			var	sUrl = '';
				sUrl += 'nombre_reporte='+sNombreReporte;
				sUrl += '&id_conexion='+iIdConexion;
				sUrl += '&dbms=postgres';
				sUrl += '&formato_reporte='+sFormatoReporte;
				sUrl += '&iCurrentPage='+iCurrentPage;
				sUrl += '&iRowsPerPage='+iRowsPerPage;
				sUrl += '&iNumEmpleado='+iNumEmpleado;
				sUrl += '&sOrderColumn='+sOrderColumn;
				sUrl += '&sOrderType='+sOrderType;
				sUrl += '&sColumns='+sColumns;
				sUrl += '&iOpcion='+iOpt;
				sUrl += '&iNumUsuario='+iNumEmpleado;
				sUrl += '&iFiltro='+siFiltro;
				sUrl += '&cBusqueda='+sBusqueda;
				sUrl += '&iTipoMovto='+idTipoMov;
				sUrl += '&iQuincena='+idQuincena;
				sUrl += '&iTipoNomina='+idTipoNomina;
				// sUrl += '&iMetodo='+idMetodo;
				// sUrl += '&iEmpleado='+iEmpleadoGlobal;
				
				// alert(sUrl);
				// return;
				
				var xhr = new XMLHttpRequest();
				var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS_SPRING + '/reportes';
				
				xhr.open("POST", report_url, true);
				xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				xhr.timeout = 120000;
				xhr.addEventListener("progress", function(evt){
					if( evt.lengthComputable ) {
						var percentComplete = evt.loaded / evt.total;
						//console.log(percentComplete);
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
			var urlu='ajax/json/impresion_traspaso.php?' +
				'&iOpcion=' + nConsulta +
				'&ifiltro=' + iFiltro +
				'&cFiltro=' + cFiltro +
				'&cbusqueda=' + cBusqueda +
				'&itipomov=' + iTipoMov +
				'&iquincena=' + iQuincena +
				'&itiponomina=' + iTipoNomina +
				'&page=' + -1 +
				'&rows=' + -1;
			// alert(urlu);
			// return;
			location.href = urlu;
			*/
		}
	}
	$("#btn_ImprimirCifras").click(function(event){
		ImprimirCifras();
		event.preventDefault();
	});
	
	//IMPRIMIR CIFRAS
	function ImprimirCifras(){
		TotalISR = TotalISR.replace(/,/g, "");
		var urlu='ajax/json/impresion_json_fun_obtener_cifras_de_control.php?session_name='+ Session+'&TotalISR='+TotalISR;
		// console.log(urlu);
		// return;
		location.href = urlu;
	}
	function ObtenerQuincena(){
		sUrl = 'ajax/json/json_WS_obtener_quincena.php';
		$.ajax({
			type: "POST",
			url: sUrl,
			data:{}
		}).done(function(data){
			//var dataJson = jQuery.parseJSON(data);
			var dataJson = JSON.parse(data);
			$("#txt_TipoNomina").val(dataJson.valor);
			// console.log(dataJson.valor);
			if (dataJson.valor == 1){
				$("#cbo_TipoNomina").append('<option value="0" selected="selected">TODOS</option>');
				$("#cbo_TipoNomina").append('<option value="1" selected="selected">COLABORADOR</option>');
				$("#cbo_TipoNomina").append('<option value="3" selected="selected">DIRECTIVO</option>');
				// var Sel = $("#cbo_TipoNomina option:first").val();
				// alert(Sel);
				//$("#cbo_TipoNomina").val($("#cbo_TipoNomina option:first").val());
				$("#cbo_TipoNomina").val($("#cbo_TipoNomina option").first().val());
				//La media de JavaScript yo la resolví así $("#cbo_Escuela option").first().val()
			}else if (dataJson.valor == 2){
				$("#cbo_TipoNomina").append('<option value="1" selected="selected">COLABORADOR</option>');
			}
		})
		.fail(function(s){message("Error al cargar " + sUrl); $('#pag_content').fadeOut();})
		.always(function(){});
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
			var $class = icon.attr('class').replace('ui-icon', '');
			$class = $class.makeTrim(" ");
			if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
		})
	}
	
	// FUNCION TRIM PARA EVITAR VULNERABILIDAD

	String.prototype.makeTrim = function (characters) {

		let result = this;
	
		for (let i = 0; i < characters.length; i++) {
			while (result.charAt(0) === characters[i]) {
				result = result.substring(1);
			}
	
			while (result.charAt(result.length - 1) === characters[i]) {
				result = result.substring(0, result.length - 1);
			}
		}
		return result;
	}
	
	function ObtenerDatosUsuario(){
		$.ajax({type: "POST", 
			url:'ajax/json/json_ObtenerDatosUsuario.php',
			data: { 				
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);			
			iEmpleadoGlobal = dataJson.usuario;			
			
		});		
	}
	
	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 402
            }
        })
        .done(function(data){
            var dataS = sanitize(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }

	/** PRUEBA PARA CONTROLAR UN CLICK Y UN DOBLE CLICK SOBRE EL MISMO CONTROL
	var DELAY = 700;
	var clicks = 0;
	var timer = null;
	
	$("#btn_buscar").live("click", function(event){
		clicks++;
		
		if ( clicks === 1 ) {
			 timer = setTimeout(function() {
                clicks = 0;  //after action performed, reset counter
            }, DELAY);
			
			if ( nCargarConsulta > 0 ) {
				inicializarGrid = false;
			} else {
				inicializarGrid = true;			
			}
			fnObtenerFacturasColegiaturasParaTraspaso(1);
			nCargarConsulta++;
			event.preventDefault();
		} else {
			clearTimeout(timer);  //prevent single-click action

            clicks = 0; 

			inicializarGrid = true;
			fnObtenerFacturasColegiaturasParaTraspaso(1);
		}
	});
	*/
	
});
