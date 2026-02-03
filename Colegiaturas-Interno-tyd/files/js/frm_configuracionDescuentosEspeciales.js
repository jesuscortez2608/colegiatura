$(function(){
	/////Inicializa combos
	ConsultaClaveHCM()
	ObtenercomboEstudio1();
	ObtenercomboEstudio2();
	ObtenercomboEstudio3();
	ObtenercomboParentesco1();
	ObtenercomboParentesco2();
	ObtenercomboParentesco3();
	
	$("#cbo_ParentescoEmpleado").change(function(){
		//console.log($("#cbo_ParentescoEmpleado").val());
		($(this).val() == 3 ) ? $('#cbo_estudio1').find('option[value="7"]').hide() : $('#cbo_estudio1').find('option[value="7"]').show();

	});

	$("#cbo_ParentescoPuesto").change(function(){
		($(this).val() == 3 ) ? $('#cbo_Estudio2').find('option[value="7"]').hide() : $('#cbo_Estudio2').find('option[value="7"]').show();

	});

	$("#cbo_ParentescoCentro").change(function(){
		($(this).val() == 3 ) ? $('#cbo_estudio3').find('option[value="7"]').hide() : $('#cbo_estudio3').find('option[value="7"]').show();

	});
	
	CargarDescuentos();
	CargarGridDescuentos();
	stopScrolling();
	
	/////Limpia grid de parentesco al recargar la pagina
	
	soloNumero('txt_idEmpleado');
	soloNumero('txt_Puesto');
	soloNumero('txt_CentroC');
	soloNumero('txt_Centro');
	soloNumero('txt_descuento');
	soloLetras('txt_nombusqueda');
	soloLetras('txt_apepatbusqueda');
	soloLetras('txt_apematbusqueda');
	soloLetras('txt_puestoBusqueda');
	soloLetras('txt_centroBusqueda');
				
	/////Declaración de variables globales
	var respon = 0;
	var Data = 0;
	var iEmpleado = 0;
		iCentro = 0;
		iPuesto = 0;
		iSeccion = 0;
		iEscolaridad = 0;
		iParentesco = 0;
		iPorcentaje = 0;
		iFiltradoPor=0;
	var sComentario="";	
	var ExisteDescuento=0;
	
	$( '#tabs' ).tabs();
	$(".tabbable").tabs({
		beforeActivate: function (event, ui) {
			//console.log(ui.newPanel.attr('id'));
		}
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
	
	function getSelectedTabIndex(){
		return $("#tabs").tabs('option', 'active');
	}
	$(".ui-tabs-anchor").click(function(){
		
		Limpiar1();
		Limpiar2();
		Limpiar3();
		CambiarGrid();
		$('#gd_Parentescos').jqGrid('clearGridData');
	});
	function stopScrolling(){
		$("#dlg_colaborador").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_puesto").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_centro").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_descuento").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_Comentario").on("show.bs.modal", function () {
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
	function CambiarGrid()
	{
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				$('#contenedor_Colaboladores').css('display','block');
				$('#contenedor_Centro').css('display','none');	
				$('#contenedor_Puestos').css('display','none');	
				cargarColaboradores();
			break;
			case 1:
				$('#contenedor_Colaboladores').css('display','none');
				$('#contenedor_Centro').css('display','none');	
				$('#contenedor_Puestos').css('display','block');	
				cargarPuestos();				
			break;
			case 2:
				$('#contenedor_Colaboladores').css('display','none');
				$('#contenedor_Centro').css('display','block');	
				$('#contenedor_Puestos').css('display','none');	
				cargarCentros();
			break;
			default:
			break;
		}
	}
	
	function getSelectedTabIndex(){
		return $("#tabs").tabs('option', 'active');
	}
	
	$(".tabbable").tabs({
		beforeActivate: function (event, ui) {
			//console.log(ui.newPanel.attr('id'));
		}
	});
	
	/////////////////GRID COLABORADORES////////////////////////////
	function cargarColaboradores(){
		var Filtro=0;
		if ($("#txt_idEmpleado").val()>0)
		{
			Filtro='&nBusqueda='+$("#txt_idEmpleado").val();
		}
		//Actualizar Grid
		$("#gd_Colaboladores").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda=1&sidx=asc&sord=numemp'+Filtro+'&session_name=' +Session}).trigger("reloadGrid"); 
		
	}
	
	jQuery("#gd_Colaboladores").jqGrid({
		url:'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda=1&sidx=asc&sord=numemp', 
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG26,
		colModel:[
			{name:'numemp',			index:'numemp', 		width:70, 	sortable: false,	align:"center",	fixed: true},
			{name:'nomempleado',	index:'nomempleado', 	width:300, 	sortable: false,	align:"left",	fixed: true},
			{name:'centro',			index:'centro', 		width:100, 	sortable: false,	align:"center",	fixed: true},
			{name:'nomcentro',		index:'centro', 		width:220, 	sortable: false,	align:"left",	fixed: true},
			{name:'puesto',			index:'puesto', 		width:100, 	sortable: false,	align:"center",	fixed: true},
			{name:'nompuesto',		index:'puesto', 		width:250, 	sortable: false,	align:"left",	fixed: true},
			{name:'seccion',		index:'seccion', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nomseccion',		index:'nomseccion', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'idu_parentesco',	index:'idu_parentesco', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'parentesco',		index:'parentesco', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'idu_estudio',	index:'idu_estudio', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'estudio',		index:'estudio', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'por_descuento',	index:'por_descuento', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'numempregistro',	index:'numempregistro', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'des_comentario',	index:'des_comentario', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		width: null,
		loadonce: false,
		shrinkToFit: false,
		height: 200,
		rowNum:10,
		rowList:[10, 20, 30],
		pager: '#gd_Colaboladores_pages',
		sortname: 'numemp,idu_parentesco ',
		viewrecords: true,
		hidegrid:false,
		sortorder: "asc",
		caption: 'Descuentos Configurados por Colaborador',
		loadComplete: function (Data) {
			var registros = jQuery("#gd_Colaboladores").jqGrid('getGridParam', 'reccount');
			
			var table = this;
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
		},	
		onSelectRow: function(Row)
		{		
			var Data = jQuery("#gd_Colaboladores").jqGrid('getRowData',Row);
			LlenarGridParentescos(4,Data.numemp, 0);
			
			if(Row >= 0){
				
				var rowData = jQuery(this).getRowData(Row);
				iEmpleado =rowData.numemp;
				iCentro =rowData.centro;
				iPuesto =rowData.puesto;
				iFiltradoPor=0;
			}				
		}
	});
	/////////////////GRID PUESTOS////////////////////////////
	function cargarPuestos(){
		var Filtro=0;
		if ($("#txt_Puesto").val()!="" && $("#txt_Puesto").val()!=0 && $("#txt_NombrePuesto").val()!='')
		{
			Filtro='&nBusqueda='+$("#txt_Puesto").val();
			//Actualizar Grid
		}	
		$("#gd_Puestos").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda=3&sidx=asc&sord=puesto'+Filtro+'&session_name=' +Session}).trigger("reloadGrid"); 
	}
	jQuery("#gd_Puestos").jqGrid({
		url:'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda=3&sidx=asc&sord=puesto', 
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG26,
		colModel:[
			{name:'numemp',			index:'numemp', 		width:70, 	sortable: false,	align:"center",		fixed: true, hidden:true},
			{name:'nomempleado',	index:'nomempleado', 	width:300, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'centro',			index:'centro', 		width:220, 	sortable: false,	align:"center",		fixed: true, hidden:true},
			{name:'nomcentro',		index:'nomcentro', 		width:220, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'puesto',			index:'puesto', 		width:100, 	sortable: false,	align:"center",		fixed: true},
			{name:'nompuesto',		index:'puesto', 		width:200, 	sortable: false,	align:"left",		fixed: true},
			{name:'seccion',		index:'seccion', 		width:100, 	sortable: false,	align:"center",		fixed: true},
			{name:'nomseccion',		index:'nomseccion', 	width:200, 	sortable: false,	align:"left",		fixed: true},
			{name:'idu_parentesco',	index:'idu_parentesco', width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'parentesco',		index:'parentesco', 	width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'idu_estudio',	index:'idu_estudio', 	width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'estudio',		index:'estudio', 		width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'por_descuento',	index:'por_descuento', 	width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'numempregistro',	index:'numempregistro', width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			{name:'des_comentario',	index:'des_comentario', width:120, 	sortable: false,	align:"left",		fixed: true, hidden:true},
			],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		width: null,
		loadonce: false,
		shrinkToFit: false,
		height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
		rowNum:10,
		rowList:[10, 20, 30],
		pager: '#gd_Puestos_pages',
		sortname: 'puesto,idu_parentesco ',
		viewrecords: true,
		hidegrid:false,
		sortorder: "asc",
		caption: 'Descuentos Configurados por Puesto',
		loadComplete: function (Data) {
			var registros = jQuery("#gd_Puestos").jqGrid('getGridParam', 'reccount');
			
			var table = this;
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
		},
		onSelectRow: function(Row)
		{		
			var Data = jQuery("#gd_Puestos").jqGrid('getRowData',Row);
			LlenarGridParentescos(6,Data.puesto, Data.seccion);
			
			if(Row >= 0){
				
				var rowData = jQuery(this).getRowData(Row);
				iPuesto =rowData.puesto;
			}
			else
			{
				iPuesto =0;
			}
		}
	});	
	/////////////////GRID CENTROS////////////////////////////
	function cargarCentros(){
		var Filtro=0;
		if ($("#txt_CentroC").val()!='' && $("#txt_NombreCentroC").val()!='' && $("#txt_CentroC").val()!=0)
		{
			Filtro='&nBusqueda='+$("#txt_CentroC").val();
		}
		//Actualizar Grid
		$("#gd_Centros").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda=2&sidx=asc&sord=centro'+Filtro+'&session_name=' +Session}).trigger("reloadGrid"); 
	}
	jQuery("#gd_Centros").jqGrid({
		url:'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda=2&sidx=asc&sord=centro', 
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG26,
		colModel:[
			{name:'numemp',			index:'numemp', 		width:70, 	sortable: false,	align:"center",	fixed: true, hidden:true},
			{name:'nomempleado',	index:'nomempleado', 	width:300, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'centro',			index:'centro',		 	width:100, 	sortable: false,	align:"center",	fixed: true},
			{name:'nomcentro',		index:'nomcentro', 		width:250, 	sortable: false,	align:"left",	fixed: true},
			{name:'puesto',			index:'puesto', 		width:100, 	sortable: false,	align:"center",	fixed: true},
			{name:'nompuesto',		index:'puesto', 		width:250, 	sortable: false,	align:"left",	fixed: true},
			{name:'seccion',		index:'seccion', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nomseccion',		index:'nomseccion', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'idu_parentesco',	index:'idu_parentesco', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'parentesco',		index:'parentesco', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'idu_estudio',	index:'idu_estudio', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'estudio',		index:'estudio', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'por_descuento',	index:'por_descuento', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'numempregistro',	index:'numempregistro', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'des_comentario',	index:'des_comentario', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true}
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		width: null,
		loadonce: false,
		shrinkToFit: false,
		height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
		rowNum:10,
		rowList:[10, 20, 30],
		pager: '#gd_Centros_pages',
		sortname: 'centro,puesto,idu_parentesco',
		viewrecords: true,
		hidegrid:false,
		sortorder: "asc",
		caption: 'Descuentos Configurados por Centro',
		loadComplete: function (Data) {
			var registros = jQuery("#gd_Centros").jqGrid('getGridParam', 'reccount');
			var table = this;
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
		},
		onSelectRow: function(Row)
		{		
			var Data = jQuery("#gd_Centros").jqGrid('getRowData',Row);
			LlenarGridParentescos(5,Data.centro, Data.puesto);
			if(Row >= 0){
				var rowData = jQuery(this).getRowData(Row);
				iCentro =rowData.centro;
				iPuesto = rowData.puesto;	
			}
			else
			{	
				iCentro =0;	
			}
		}	
	});
	
	/////////////////GRID PARENTESCOS////////////////////////////
	function LlenarGridParentescos(Opcion,nBusqueda,nFiltradoPor)
	{
		$("#gd_Parentescos").jqGrid('setGridParam',
		{ url: 'ajax/json/json_fun_obtener_listado_configuraciones_descuentos.php?opc_busqueda='+Opcion+'&sidx=NumEmp&sord=asc&nBusqueda='+nBusqueda+'&nFiltro='+nFiltradoPor}).trigger("reloadGrid"); 
	}
	
	jQuery("#gd_Parentescos").jqGrid({
		url:'', 
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG26,
		colModel:[
			{name:'numemp',			index:'numemp', 		width:70, 	sortable: false,	align:"center",	fixed: true, hidden:true},
			{name:'nomempleado',	index:'nomempleado', 	width:300, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'centro',			index:'centro', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nomcentro',		index:'nomcentro', 		width:200, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'puesto',			index:'puesto', 		width:100, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nompuesto',		index:'puesto', 		width:130, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'seccion',		index:'seccion', 		width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'nomseccion',		index:'nomseccion', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'idu_parentesco',	index:'idu_parentesco', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'parentesco',		index:'parentesco', 	width:150, 	sortable: false,	align:"left",	fixed: true},
			{name:'idu_estudio',	index:'idu_estudio', 	width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'estudio',		index:'estudio', 		width:250, 	sortable: false,	align:"left",	fixed: true},
			{name:'por_descuento',	index:'por_descuento', 	width:80, 	sortable: false,	align:"center",	fixed: true},
			{name:'numempregistro',	index:'numempregistro', width:120, 	sortable: false,	align:"left",	fixed: true, hidden:true},
			{name:'des_comentario',	index:'des_comentario', width:500, 	sortable: false,	align:"left",	fixed: true}
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		width: null,
		loadonce: false,
		shrinkToFit: false,
		height: 200,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
		rowNum:10,
		rowList:[10, 20, 30],
		pager: '#gd_Parentescos_pages',
		viewrecords: true,
		hidegrid:false,
		sortname: 'numemp',
		sortorder: "asc",
		caption: '',
		loadComplete: function (Data) {
			var registros = jQuery("#gd_Parentescos").jqGrid('getGridParam', 'reccount');
			
			var table = this;
			setTimeout(function(){
				updatePagerIcons(table);
			}, 0);
		},	
		onSelectRow: function(Row)
		{		
			var Data = jQuery("#gd_Parentescos").jqGrid('getRowData',Row);
							
			if(Row >= 0){
				
				var rowData = jQuery(this).getRowData(Row);
				iEscolaridad = Data.idu_estudio;
				iParentesco = Data.idu_parentesco;
				iSeccion = Data.seccion;
				iPorcentaje = rowData.por_descuento;
				sComentario=rowData.des_comentario;
				iPuesto=rowData.puesto;
				iCentro=rowData.centro;
				iEmpleado=rowData.numemp;
			}
			else
			{
				iPuesto=0;
				iCentro=0;
				iEmpleado=0;
			}
		}				
	});
	barButtongrid({
		pagId:"#gd_Parentescos_pages",
		position:"left",//center right
		Buttons:[
		{
			icon:"icon-print blue",
			title:'Imprimir',
			click:function (event)
			{
			
				var tab =$("#tabs").tabs('option', 'active');			
				switch(tab)
				{
					case 0://Colaborador
						pdfColaborador();
					break;
					case 1://Puesto
						pdfPuesto();				
					break;
					case 2://centro
						pdfCentro();	
					break;
					default:
						pdfColaborador();
					break;
					
				}
				event.preventDefault();	
			}
		},
		{
			icon:"icon-remove red",
			title:'Eliminar',
			click:function (event)
			{
				var tab =$("#tabs").tabs('option', 'active');
				var fila = jQuery("#gd_Parentescos").jqGrid('getGridParam', 'selrow');
				
				switch(tab)
				{
					case 0:
						if(iEmpleado == 0){
							showalert(LengStrMSG.idMSG163, "", "gritter-info");
						}
						else if(fila == null)
						{
							showalert(LengStrMSG.idMSG164, "", "gritter-info");
						}						
			
						else
						{
							bootbox.confirm(LengStrMSG.idMSG165, function(result) 
							{
								if(result) 
								{	
									eliminarPorColaborador(iEmpleado,iCentro,iPuesto, sComentario);								
								}
									
							});
						}
					break;
					case 1:
						if(iPuesto == 0){
							// showalert(LengStrMSG.idMSG166, "", "gritter-info");
							showalert("Seleccione registro de puesto", "", "gritter-info");

						}
						else if(fila == null)
						{
							showalert(LengStrMSG.idMSG164, "", "gritter-info");
						}						
			
						else
						{
							bootbox.confirm(LengStrMSG.idMSG167, function(result) 
							{
								if(result) 
								{	
									eliminarPorPuesto(iPuesto,iSeccion, sComentario);				
								}
									
							});
						}
					break;
					case 2:			
						if(iCentro == 0){
							// showalert(LengStrMSG.idMSG168, "", "gritter-info");
							showalert("Seleccione registro de centro", "", "gritter-info");
						}
						else if(fila == null)
						{
							showalert(LengStrMSG.idMSG164, "", "gritter-info");
						}		
						else
						{
							bootbox.confirm(LengStrMSG.idMSG169, function(result) 
							{
								if(result) 
								{	
									eliminarPorCentro(iCentro,iPuesto, sComentario);					
								}
									
							});
						}		
					break;
					default:
					break;
				}
				event.preventDefault();	
			}
		}
		]
	});
	setSizeBtnGrid('id_button0',35);
	setSizeBtnGrid('id_button1',35);
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}

	//////////////////COMBO ESTUDIO COLABORADOR///////////////////////////////
	$("#cbo_estudio1").trigger("chosen:updated");
	function ObtenercomboEstudio1(){
		$("#cbo_estudio1").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {
				'iEscolaridad' : 0,
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='-1'>SELECCIONE</option>";
					var option = option + "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
					}
					$("#cbo_estudio1").html(option);
					$("#cbo_estudio1").trigger("chosen:updated");
				}
				else
				{
					//error
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	//////////////////COMBO ESTUDIO PUESTO///////////////////////////////
	$("#cbo_Estudio2").trigger("chosen:updated");
	function ObtenercomboEstudio2(){
		$("#cbo_Estudio2").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {
				'iEscolaridad' : 0,
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='-1'>SELECCIONE</option>";
					var option = option + "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
					}
					$("#cbo_Estudio2").html(option);
					$("#cbo_Estudio2").val(-1);
					$("#cbo_Estudio2").trigger("chosen:updated");
				}
				else
				{
					//error
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	//////////////////COMBO ESTUDIO CENTRO///////////////////////////////
	$("#cbo_Estudio3").trigger("chosen:updated");
	function ObtenercomboEstudio3(){
		$("#cbo_Estudio3").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {
				'iEscolaridad' : 0,
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='-1'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
					}
					$("#cbo_Estudio3").html(option);
					$("#cbo_Estudio3").val(-1);
					$("#cbo_Estudio3").trigger("chosen:updated");
				}
				else
				{
					//error
					showalert(LengStrMSG.idMSG88+" las escolaridad", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
/////////////////////////COMBO PARENTESCOS COLABORADOR//////////////////////
$("#cbo_ParentescoEmpleado").trigger("chosen:updated");
	function ObtenercomboParentesco1(){
	$("#cbo_ParentescoEmpleado").html("");
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",
			data: {'iTipo':1},
			beforeSend:function(){},
			success:function(data){	
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{
					var option = "<option value='-1'>SELECCIONE</option>";
					var option = option + "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_ParentescoEmpleado").html(option);
					$("#cbo_Estudio3").val(-1);
					$( "#cbo_ParentescoEmpleado" ).trigger("chosen:updated");
				}
				else
				{
					//Error
					showalert(LengStrMSG.idMSG88+ "los parentescos", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	/////////////////////////COMBO PARENTESCOS PUESTO//////////////////////
	$("#cbo_ParentescoPuesto").trigger("chosen:updated");
	function ObtenercomboParentesco2(){
	$("#cbo_ParentescoPuesto").html("");
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",
			data: {'iTipo':1},
			beforeSend:function(){},
			success:function(data){		
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{
					var option = "<option value='-1'>SELECCIONE</option>";
					var option = option + "<option value='0'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_ParentescoPuesto").html(option);
					$( "#cbo_ParentescoPuesto" ).trigger("chosen:updated");
				}
				else
				{
					//error
					showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
				}
			},	
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	/////////////////////////COMBO PARENTESCOS CENTRO//////////////////////
	$("#cbo_ParentescoCentro").trigger("chosen:updated");
	function ObtenercomboParentesco3(){
		$("#cbo_ParentescoCentro").html("");
			$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",
			data: {'iTipo':1},
			beforeSend:function(){},
			success:function(data){		
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_ParentescoCentro").html(option);
					$( "#cbo_ParentescoCentro" ).trigger("chosen:updated");
				}
				else
				{
					//error
					showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	////////////////////////////COLABORADORES//////////////////////////////////	
	$("#txt_idEmpleado").keydown(function(evt) 
	{
		if (evt.which == 13 || evt.which == 9 || evt.which == 0) { // SI PRESIONARON ENTER
			if(($("#txt_idEmpleado").val().length == 8)  || ($("#txt_idEmpleado").val()==''))
			{
				if($("#txt_idEmpleado").val()=='')
				{
					Limpiar1();
					cargarColaboradores();
				}
				else
				{
					Cargar_datos( function(){
						
						cargarColaboradores();
					});
				}	
				
			}
			else
			{
				$("#txt_idEmpleado").val('');
				$("#txt_idEmpleado").focus();
				$("#txt_nombreEmpleado").val('');
				$("#txt_Centro").val('');
				$("#txt_NombreCentro").val('');
				$('#gd_Colaboladores').jqGrid('clearGridData');
				$('#gd_Parentescos').jqGrid('clearGridData');
				
			}
			//$("#dlg_colaborador").modal('hide');
		}
	});
	
	$( '#txt_idEmpleado' ).on('input propertychange paste', function(){
		if(($("#txt_idEmpleado").val().length == 8)  || ($("#txt_idEmpleado").val()==''))
			{
				if($("#txt_idEmpleado").val()=='')
				{
					Limpiar1();
					cargarColaboradores();
				}
				else
				{
					Cargar_datos( function(){
						
						cargarColaboradores();
					});
				}	
			}
			else
			{
				$("#txt_idEmpleado").focus();
				$("#txt_nombreEmpleado").val('');
				$("#txt_Centro").val('');
				$("#txt_NombreCentro").val('');
				$("#cbo_estudio1").val(-1);
				$("#cbo_DescuentoEmpleado").val($("#cbo_DescuentoEmpleado option").first().val());
				$("#cbo_ParentescoEmpleado").val(-1);
				$('#gd_Colaboladores').jqGrid('clearGridData');
				$('#gd_Parentescos').jqGrid('clearGridData');
			}
	});
	
	function Cargar_datos(callback)
	{
		var respon = $('#txt_idEmpleado').val();	
		$.ajax({type: "POST",
			url: 'ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php',
			data: {'iEmpleado':respon},
			beforeSend:function(){},
			success:function(data){
				json = JSON.parse(data);
				if(json==null){
					showalert(LengStrMSG.idMSG170, "", "gritter-info");
					$("#txt_idEmpleado").val('');
					$("#txt_idEmpleado").focus();
					$("#txt_nombreEmpleado").val('');
					$("#txt_Centro").val('');
					$("#txt_NombreCentro").val('');
				}else if (json[0].cancelado == 1){
					showalert(LengStrMSG.idMSG171, "", "gritter-info");
					$("#txt_idEmpleado").val('');
					$("#txt_idEmpleado").focus();
					$("#txt_nombreEmpleado").val('');
					$("#txt_Centro").val('');
					$("#txt_NombreCentro").val('');
				}
				else 
				{	
					 $("#txt_nombreEmpleado").val(json[0].nombre+' '+json[0].appat+' '+json[0].apmat);
					 $("#txt_Centro").val(json[0].centro);
					 $("#txt_NombreCentro").val(json[0].nombrecentro);
				 }		
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}	
		});		
	}	
	////////////////////////////PUESTOS//////////////////////////////////	
	$("#txt_Puesto").keydown(function(evt) {

		if (evt.which == 13 || evt.which == 0 || evt.which == 9 ) { // SI PRESIONARON ENTER
			if(($("#txt_Puesto").val().length <= 3) && ($("#txt_Puesto").val().length > 0) && $("#txt_Puesto").val()!=0)
			{
			
				Cargar_Puestos(function(){
					cargarPuestos();
				});
				
			}
			else
			{
				
				$("#txt_Puesto").val('');
				$("#txt_Puesto").focus();
				$("#txt_NombrePuesto").val('');
				
				$("#cbo_Seccion").val(-0);
				$("#cbo_ParentescoPuesto").val(-1);
				$("#cbo_Estudio2").val(-1);
				$("#cbo_DescuentoPuesto").val($("#cbo_DescuentoPuesto option").first().val());
				cargarPuestos();
				// $('#gd_Puestos').jqGrid('clearGridData');
				$('#gd_Parentescos').jqGrid('clearGridData');
			}
		}
		if(evt.which == 8)
		{
			$("#txt_NombrePuesto").val('');
			$("#cbo_Seccion").val(-0);
			$("#cbo_ParentescoPuesto").val(-1);
			$("#cbo_Estudio2").val(-1);
			$("#cbo_DescuentoPuesto").val($("#cbo_DescuentoPuesto option").first().val());
			
			// $('#gd_Puestos').jqGrid('clearGridData');
			// cargarPuestos();
			$('#gd_Parentescos').jqGrid('clearGridData');
		}
	});
	$( '#txt_Puesto' ).on('input propertychange paste', function(){
		
		$("#txt_NombrePuesto").val('');
		$("#cbo_Seccion").val(-0);
		$("#cbo_ParentescoPuesto").val(-1);
		$("#cbo_Estudio2").val(-1);
		$("#cbo_DescuentoPuesto").val($("#cbo_DescuentoPuesto option").first().val());
		$("#cbo_Seccion").html("");
		//$('#gd_Puestos').jqGrid('clearGridData');
		$('#gd_Parentescos').jqGrid('clearGridData');
		if($( '#txt_Puesto' ).val()=='')
		{
			cargarPuestos();
		}	
	});
	function Cargar_Puestos(callback)
	{
		var respon = $('#txt_Puesto').val();
		$.ajax({type: "POST",
			url: 'ajax/json/json_calConsultaNombrePuesto.php',
			data: {'iPuesto':respon},
			beforeSend:function(){},
			success:function(data){
				json = JSON.parse(data);
				if (json == null){
					//showmessage('El Puesto no Existe', '', undefined, undefined, function onclose(){
					showalert(LengStrMSG.idMSG172, "", "gritter-info");
						$("#txt_Puesto").val('');
						$("#txt_Puesto").focus();
						$("#txt_NombrePuesto").val('');
						$('#gd_Puestos').jqGrid('clearGridData');
						$('#gd_Parentescos').jqGrid('clearGridData');
					//});
				}
				else{
					 //$("#txt_Puesto").val(json.Numero);
					 $("#txt_NombrePuesto").val(json.Nombre);
					 ObtenercomboSeccion();
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}	
		});		
	}
	/////////////////////////COMBO SECCION//////////////////////
	function ObtenercomboSeccion(){
		if($("#txt_Puesto").val().replace('/^\s+|\s+$/g', '')!='')
		{
			$("#cbo_Seccion").html("");
			$("#cbo_Seccion").removeAttr('disabled');
			$.ajax({
				type: "POST",
				url: 'ajax/json/json_PROC_OBTENESECCIONESPORPUESTO.php',
				//data: {iTipo:$("#txt_Puesto").val()},
				data: {iTipo:DOMPurify.sanitize($("#txt_Puesto").val())},
				beforeSend:function(){},
				success:function(data){					
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);	
					if(dataJson.estado == 0)
					{
						var option = "<option value='-1'>SELECCIONE</option>;<option value='0'>TODAS LAS SECCIONES</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].comb + "'>" + dataJson.datos[i].nombre + "</option>"; 
						}
						$("#cbo_Seccion").html(option);
						$("#cbo_Seccion").val(-1);
						$("#cbo_Seccion" ).trigger("chosen:updated");

					}
					else
					{
						//error
						showalert(LengStrMSG.idMSG88+" las secciones", "", "gritter-warning");
					}						
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}	
			});		
		}
		else
		{
			$("#cbo_Seccion").html("");
		}
	}
	////////////////////////////CENTROS//////////////////////////////////	
	$("#txt_CentroC").keydown(function(evt) 
	{
		if (evt.which == 13 || evt.which == 0 || evt.which == 9 ) { // SI PRESIONARON ENTER
			if(($("#txt_CentroC").val().length <= 6) && ($("#txt_CentroC").val().length > 0) || ($("#txt_CentroC").val()==''))
			{
				if($("#txt_CentroC").val()=='')
				{
					cargarCentros();
				}
				else
				{
					Cargar_Centros(function(){
						cargarCentros();
					});
				}	
			}
			else
			{
				$("#txt_CentroC").val('');
				$("#txt_CentroC").focus();
				$("#txt_NombreCentroC").val('');
				
				$("#cbo_PuestoC").val(-1);
				$("#cbo_ParentescoCentro").val(0);
				$("#cbo_Estudio3").val(-1);
				$("#cbo_DescuentoCentro").val($("#cbo_DescuentoCentro option").first().val());
			
			
				// $('#gd_Centros').jqGrid('clearGridData');
				$('#gd_Parentescos').jqGrid('clearGridData');
			}
		}
		if(evt.which == 8)
		{
			$("#txt_NombreCentroC").val('');
			$("#cbo_PuestoC").val(-1);
			$("#cbo_ParentescoCentro").val(0);
			$("#cbo_Estudio3").val(-1);
			$("#cbo_DescuentoCentro").val($("#cbo_DescuentoCentro option").first().val());
			
			
			// $('#gd_Centros').jqGrid('clearGridData');
			$('#gd_Parentescos').jqGrid('clearGridData');
		}
	});
	$( '#txt_CentroC' ).on('input propertychange paste', function(evt)
	{
		// if( $("#txt_CentroC").val()=='')
		// {
			// cargarCentros();
			
		// }
		// else
		// {
			
			$("#txt_NombreCentroC").val('');
			$("#cbo_PuestoC").val(-1);
			$("#cbo_ParentescoCentro").val(0);
			$("#cbo_Estudio3").val(-1);
			$("#cbo_DescuentoCentro").val($("#cbo_DescuentoCentro option").first().val());
			// $('#gd_Centros').jqGrid('clearGridData');
			$('#gd_Parentescos').jqGrid('clearGridData');
			if($( '#txt_CentroC' ).val()=='')
			{
				cargarCentros();
			}	
		// }
	});
	function Cargar_Centros(callback)
	{
		var respon = $('#txt_CentroC').val();
		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_obtener_catalogo_centros.php',
			// url: 'ajax/json/json_proc_obtener_nombre_centro.php',
			data: { 
				'iCentro':respon,
				'sCentro':$("#txt_NombreCentroC").val(),
				'iSeccion': 0,
			},
			beforeSend:function(){},
			success:function(data){
				json = JSON.parse(data);
				//console.log(json);
				if (!json.rows){
					//showmessage('El Centro no Existe', '', undefined, undefined, function onclose(){
					showalert(LengStrMSG.idMSG173, "", "gritter-info");
					$("#txt_CentroC").val('');
					$("#txt_CentroC").focus();
					$("#txt_NombreCentroC").val('');
					//});
				}else	
				{	
					// console.log(json.rows[0].cell["nom_centro"]);
					// console.log(json.rows[0].cell['nom_centro']);
					$("#txt_NombreCentroC").val(json.rows[0].cell[1]);
					 ObtenercomboPuesto();					 
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}	
		});		
	}
	/////////////////////////COMBO PUESTO DEL CENTRO//////////////////////
	function ObtenercomboPuesto(){
		$("#cbo_PuestoC").html("");
		$("#cbo_PuestoC").removeAttr('disabled');
		$.ajax({type: "GET",
				//url: 'ajax/json/json_proc_ayudaCentrosPuestos3.php?Nombre='+$("#txt_CentroC").val(),
				url: 'ajax/json/json_proc_ayudaCentrosPuestos3.php?Nombre='+DOMPurify.sanitize($("#txt_CentroC").val()),
			
			beforeSend:function(){},
			success:function(data){
			
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				 if(dataJson.estado == 0)
				 {
					 var option = "<option value='-1'>SELECCIONE</option>;<option value='0'>TODOS LOS PUESTOS</option>";
					 for(var i=0;i<dataJson.datos.length; i++)
					  {
						 option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					 }
					 $("#cbo_PuestoC").html(option);
					 $("#cbo_PuestoC" ).trigger("chosen:updated");

				 }
				 else
				 {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los puestos" , "", "gritter-error");
				 }						
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
		
	///////Configuración botones modal dlg_colaborador
	$("#btn_buscar1").click(function (event){	
		LimpiarModalColaborador();
		$("#dlg_colaborador").modal('show');
		CargarGridColaborador();
		event.preventDefault();			
	});
		
	function CargarGridColaborador(){
		jQuery("#grid-colaborador-table").jqGrid({
			//url: cUrl,
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG45,
			colModel:[
				{name:'num_emp',index:'num_emp', width:120, sortable: false,align:"center",fixed: true},
				{name:'nombre',index:'nombre', width:170, sortable: false,align:"center",fixed: true},
				{name:'apepat',index:'apepat', width:160, sortable: false,align:"center",fixed: true},
				{name:'apemat',index:'nombre', width:160, sortable: false,align:"center",fixed: true},
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
			loadComplete: function (Data) {},
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(clave)
			{
				var Data = jQuery("#grid-colaborador-table").jqGrid('getRowData',clave);
				$("#txt_idEmpleado").val(Data.num_emp);
				$("#txt_nombreEmpleado").val(Data.nombre+' '+Data.apepat+' '+Data.apemat);
				$("#txt_Centro").val(Data.centro);
				$("#txt_NombreCentro").val(Data.nombreCentro);
				$("#dlg_colaborador").modal('hide');
				cargarColaboradores();
			}					
		});	
	}

	///////////////BOTON BUSCAR/////////////////////////////////////
	$("#btn_buscarCOL").click(function (event){
		var filtroB =0;
		if($('#txt_nombusqueda').val().replace('/^\s+|\s+$/g', '') !='')// && $('#txt_apepatbusqueda').val().replace('/^\s+|\s+$/g', '')=='' && $('#txt_apematbusqueda').val().replace('/^\s+|\s+$/g', '')=='')
		{
			filtroB++;	
		}
		if($('#txt_apepatbusqueda').val().replace('/^\s+|\s+$/g', '') !='')// && $('#txt_apepatbusqueda').val().replace('/^\s+|\s+$/g', '')=='' && $('#txt_apematbusqueda').val().replace('/^\s+|\s+$/g', '')=='')
		{	
			filtroB++;
		}
		if($('#txt_apematbusqueda').val().replace('/^\s+|\s+$/g', '') !='')// && $('#txt_apepatbusqueda').val().replace('/^\s+|\s+$/g', '')=='' && $('#txt_apematbusqueda').val().replace('/^\s+|\s+$/g', '')=='')
		{	
			filtroB++;
		}
		//console.log(filtroB);
		if(filtroB<2)
		{
			showalert(LengStrMSG.idMSG174,"","gritter-info")
		}
		else
		{	
			$("#grid-colaborador-table").jqGrid('setGridParam', { url:'ajax/json/json_proc_busquedaEmpleados_sueldos.php?nombre='+$('#txt_nombusqueda').val()+'&apepat='+$('#txt_apepatbusqueda').val()+'&apemat='+$('#txt_apematbusqueda').val()}).trigger("reloadGrid");
		}
		
		event.preventDefault();		
	});

////////////////////////////////////GRID DE MODAL dlg_puesto/////////////////////////////////
		$("#btn_BuscarPuesto").click(function (event){	
			LimpiarModalPuesto();
			$("#dlg_puesto").modal('show');
			event.preventDefault();		
		});
		
		jQuery("#grid_puesto").jqGrid({
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG46,
		colModel:[
			{name:'numero',index:'numero', width:100, sortable: false,align:"center",fixed: true},
			{name:'nombre',index:'nombre', width:336, sortable: false,align:"center",fixed: true},
		],
		scrollrows : true,
		viewrecords : false,
		rowNum:-1,
		hidegrid: false,
		rowList:[],
		width: 456,
		shrinkToFit: false,
		height: 200,
		caption: 'Puestos',
		pgbuttons: false,
		pgtext: null,
		
		loadComplete: function (Data) {},
		//DOBLE CLIC AL GRID//
		ondblClickRow: function(clave)
		{
			var Data = jQuery("#grid_puesto").jqGrid('getRowData',clave);
			$("#txt_Puesto").val(Data.numero);
			$("#txt_NombrePuesto").val(Data.nombre);
			ObtenercomboSeccion();
			cargarPuestos();
			$("#dlg_puesto").modal('hide');	
		}	
	});	

	///////////////BOTON BUSCAR/////////////////////////////////////
	$("#btn_buscarPuest").click(function (event){
		$("#grid_puesto").jqGrid('setGridParam', { url:'ajax/json/json_proc_ayudaCentrosPuestos.php?Nombre='+$('#txt_puestoBusqueda').val()+'&iOpcion=1'}).trigger("reloadGrid");
		event.preventDefault();	
	});
	
	////////////////////////BOTON AGREGAR DESCUENTOS///////////////////////////////
	$("#btn_AgregarD").click(function (event){
		//console.log(1);
		// CargarGridDescuentos();
		$("#dlg_descuento").modal('show');
		$('#txt_descuento').focus();
		event.preventDefault();
	});
	//BOTON GUARDAR (MODAL) DESCUENTOS
	$('#btn_AgregarD2').click(function(){
		//if($('#txt_descuento').val() == '' || $('#txt_descuento').val() < 50 ||$('#txt_descuento').val() > 100){
		if($("#txt_descuento").val() == ''){
			showalert("Proporcione el porcentaje","","gritter-info");
			$("#txt_descuento").focus();
		}else if($('#txt_descuento').val() < 50 || $('#txt_descuento').val() > 100){
			showalert("Porcentaje invalido","", "gritter-error");
			// $('#txt_descuento').val('');
			$('#txt_descuento').focus();
		}else{
			//if($('#txt_descuento').val() == ExisteDescuento)
			GuardarPorcentaje();
			// CargarGridDescuentos();
			//CargarDescuentos();
			$('#txt_descuento').val('');
			$('#txt_descuento').focus();
			
		}
	})
	$('#dlg_descuento').on('hide.bs.modal', function (event) {
		$("#cbo_DescuentoEmpleado").val('');
		$("#cbo_DescuentoPuesto").val('');
		$("#cbo_DescuentoCentro").val('');
		$("#txt_descuento").val('');
		CargarDescuentos();
	});
	function GuardarPorcentaje(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_guardar_porcentaje_colegiaturas.php',
			data:{
				session_name:Session,
				prc_descuento: $('#txt_descuento').val(),
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			ExisteDescuento=dataJson.prc_descuento;
			if(dataJson.mensaje == 'Porcentaje guardado'){
				showalert(dataJson.mensaje,'','gritter-success')
				CargarGridDescuentos();
			}else{
				showalert(dataJson.mensaje,"", 'gritter-info');
			}
		})
		.fail(function(s) {message("Error al cargar " + url ); $('#pag_content').fadeOut();})
		.always(function() {});
	}
/////////////////////////////////////////////GRID MODAL DESCUENTOS////////////////////////////////////////
	function CargarGridDescuentos(){
		jQuery("#grid_descuento").GridUnload();
		jQuery("#grid_descuento").jqGrid({
			url: 'ajax/json/json_fun_obtener_descuentos_grid.php',
			datatype: 'json',
			mtype: 'POST',
			colNames:['Desc', 'Descuento'],
			align:'center',
			colModel:[
				{name:'prc_descuento',index:'prc_descuento', width:100, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'des_descuento',index:'des_descuento', width:336, sortable: false,align:"center",fixed: true},
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: true,
			rowList:[],
			//pager: "#grid_descuento_pager",
			width: 360,
			shrinkToFit: false,
			height: 200,
			caption: 'Disponibles',
			pgbuttons: false,
			pgtext: null,
			loadComplete: function (Data) {},
		});	
	}

	////////////////////////////////DIALOGO CENTROS/////////////////////////////////
	$("#btn_BuscarCentro").click(function (event){	
		// $("#txt_centroBusqueda").val("");
		// $('#grid_centro').jqGrid('clearGridData');
		LimpiarModalCentro();
		$("#dlg_centro").modal('show');
		event.preventDefault();	
	});
		
		jQuery("#grid_centro").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG47,
			colModel:[
				{name:'idu_centro',index:'idu_centro', width:100, sortable: false,align:"center",fixed: true},
				{name:'nom_centro',index:'nom_centro', width:356, sortable: false,align:"center",fixed: true},
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: 456,
			shrinkToFit: false,
			height: 200,
			caption: 'Centros',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			loadComplete: function (Data) {},
			//CLIC AL GRID//
			ondblClickRow: function(clave)
			{
				var Data = jQuery("#grid_centro").jqGrid('getRowData',clave);
				$("#txt_CentroC").val(Data.idu_centro);
				$("#txt_NombreCentroC").val(Data.nom_centro);
				ObtenercomboPuesto();
				cargarCentros();
				
				$("#dlg_centro").modal('hide');			
			}
		});

	///////////////BOTON BUSCAR CENTRO/////////////////////////////////////
	$("#btn_buscarCentro").click(function (event){
		// $("#grid_centro").jqGrid('setGridParam', { url:'ajax/json/json_proc_ayudaCentrosPuestos.php?Nombre='+$('#txt_centroBusqueda').val()+'&iOpcion=2'}).trigger("reloadGrid");
		$("#grid_centro").jqGrid('setGridParam', { url:'ajax/json/json_fun_obtener_catalogo_centros.php?sCentro='+$('#txt_centroBusqueda').val().toUpperCase()+'&iOpcion=2'}).trigger("reloadGrid");
		event.preventDefault();	
	});
	
	/////// Funciones para limpiar controles
	function Limpiar2(){
		$('#txt_Puesto').val('');
		$('#txt_NombrePuesto').val('');
		$("#cbo_Seccion").prop('disabled', true);
		$("#cbo_Seccion").val(-1);
		$("#cbo_PuestoC").prop('disabled', true);
		$("#cbo_Estudio2").val(-1);
		$('#cbo_ParentescoPuesto').val(-1);
		$("#cbo_DescuentoPuesto").val($("#cbo_DescuentoPuesto option").first().val());
	}	
	function Limpiar1(){
		$('#txt_idEmpleado').val('');
		$('#txt_nombreEmpleado').val('');
		$('#txt_Centro').val('');
		$('#txt_NombreCentro').val('');
		$("#cbo_estudio1").val(-1);
		$('#cbo_ParentescoEmpleado').val(-1);
		$("#cbo_DescuentoEmpleado").val($("#cbo_DescuentoEmpleado option").first().val());
	}
	function Limpiar3(){
		$('#txt_CentroC').val('');
		$('#txt_NombreCentroC').val('');
		$('#txt_CentroC').val('');
		$("#cbo_PuestoC").prop('disabled', true);
		$("#cbo_PuestoC").val(-1);
		$("#cbo_Seccion").prop('disabled', true);
		$("#cbo_Estudio3").val(-1);
		$("#cbo_ParentescoCentro").val(0);	
		$("#cbo_DescuentoCentro").val($("#cbo_DescuentoCentro option").first().val());		
	}
	
	function LimpiarModalColaborador()
	{
		$('#txt_nombusqueda').val('');
		$('#txt_apepatbusqueda').val('');
		$('#txt_apematbusqueda').val('');
		$('#grid-colaborador-table').jqGrid('clearGridData');			
	}
	function LimpiarModalPuesto()
	{
		$('#txt_puestoBusqueda').val('');
		$('#grid_puesto').jqGrid('clearGridData');			
	}
	function LimpiarModalCentro()
	{
		$('#txt_centroBusqueda').val('');
		$('#grid_centro').jqGrid('clearGridData');			
	}
	////////////////////////Funciones de eliminar según pantalla seleccionada//////////////////	
	function eliminarPorColaborador(numEmp,numCentro,numPuesto, sComentario)
	{
		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_eliminar_configuracion_de_descuentos.php',
			data: {session_name:Session,
				'iOpcion':1,
				'iEmpleado':iEmpleado,
				'iParentesco': iParentesco,
				'iEscolaridad': iEscolaridad,
				'iPorcentaje': iPorcentaje,
				'cComentario': sComentario.toUpperCase()//$("#txt_Comentario").val().toUpperCase()
			},
			beforeSend:function(){},
			success:function(data){
				json = json_decode(data);
				if (json.estado == 0)
				{
					//message("Registro eliminado correctamente")
					showalert("Registro eliminado correctamente", "","gritter-success");
					cargarColaboradores();
					//$('#gd_Parentescos').jqGrid('clearGridData');
					LlenarGridParentescos(4,iEmpleado, 0);			
					$('#txt_Comentario').val("");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}
	function eliminarPorPuesto(puesto,seccion, sComentario){

			$.ajax({type: "POST",
			url: 'ajax/json/json_fun_eliminar_configuracion_de_descuentos.php',
				data: {session_name:Session,
					'iOpcion':2,
					'iPuesto':puesto,
					'iSeccion': seccion,
					'iEscolaridad': iEscolaridad,
					'iParentesco': iParentesco,
					'iPorcentaje': iPorcentaje,
					'cComentario': sComentario.toUpperCase()//,$("#txt_Comentario").val().toUpperCase()
				},
				beforeSend:function(){},
				success:function(data){
					json = json_decode(data);
					if (json.estado == 0)
					{
						showalert(LengStrMSG.idMSG175, "","gritter-success");
						cargarPuestos();
						LlenarGridParentescos(6,iPuesto,iSeccion);				
						$('#txt_Comentario').val("");			
					}
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}	
			});	
	}
	function eliminarPorCentro(centro,puesto, sComentario){
		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_eliminar_configuracion_de_descuentos.php',
			data: {session_name:Session,
				'iOpcion':3,
				'iCentro':iCentro,
				'iPuesto':iPuesto,
				'iEscolaridad': iEscolaridad,
				'iParentesco': iParentesco,
				'iPorcentaje': iPorcentaje,
				'cComentario': sComentario.toUpperCase()//$("#txt_Comentario").val().toUpperCase()
			},
			beforeSend:function(){},
			success:function(data){
				json = json_decode(data);
				if (json.estado == 0)
				{
					//message("Registro eliminado correctamente");
					showalert(LengStrMSG.idMSG175, "","gritter-success");
					cargarCentros();
					LlenarGridParentescos(5,iCentro,iPuesto);			
					$('#txt_Comentario').val("");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}

	/////////////Configuración botones GUARDAR y funciones/////////////////////////////////////
	$('#btn_AgregarE').click(function(event)
	{
		if($("#txt_nombreEmpleado").val()=="")
		{
			showalert(LengStrMSG.idMSG176, "","gritter-info");
			$("#txt_nombreEmpleado").focus();
			$("#txt_idEmpleado").focus();
		}
		else if ($("#cbo_ParentescoEmpleado").val()==-1)
		{
			showalert(LengStrMSG.idMSG177, "","gritter-info");
			$("#cbo_ParentescoEmpleado").focus();
		}
		else if ($("#cbo_estudio1").val()==-1)
		{
			showalert(LengStrMSG.idMSG178, "","gritter-info");
			$("#cbo_estudio1").focus();
		}
		else if ( $("#cbo_DescuentoEmpleado").val()==0)
		{
			showalert(LengStrMSG.idMSG179, "","gritter-info");
			 $("#cbo_DescuentoEmpleado").focus();
		}
		else
		{
			$("#txt_Comentario").val("");	
			$("#dlg_Comentario").modal('show');
		}	
		//GuardarColaborador();
		event.preventDefault();			
	});
	
	$('#btn_AgregarP').click(function(event)
	{
		if($("#txt_NombrePuesto").val()=="")
		{
			showalert(LengStrMSG.idMSG235, "","gritter-info");
			$("#txt_NombrePuesto").focus();
			$("#txt_Puesto").focus();
		}
		else if ($("#cbo_Seccion").val()==-1)
		{
			showalert(LengStrMSG.idMSG181, "","gritter-info");
			$("#cbo_Seccion").focus();
		}
		else if ($("#cbo_ParentescoPuesto").val()==-1)
		{
			showalert(LengStrMSG.idMSG177, "","gritter-info");
			$("#cbo_ParentescoPuesto").focus();
		}else if ( $("#cbo_Estudio2").val()==-1)
		{
			showalert(LengStrMSG.idMSG178, "","gritter-info");
			 $("#cbo_Estudio2").focus();
		}
		else if ( $("#cbo_DescuentoPuesto").val()==0)
		{
			showalert(LengStrMSG.idMSG179, "","gritter-info");
			 $("#cbo_DescuentoPuesto").focus();
		}
		else
		{
			//GuardarPuesto();
			$("#txt_Comentario").val("");	
			$("#dlg_Comentario").modal('show');
		}	
		event.preventDefault();	
	});
	$('#btn_AgregarC').click(function(event)
	{
		if($("#txt_NombreCentroC").val()=="")
		{
			showalert(LengStrMSG.idMSG182, "","gritter-info");
			$("#txt_CentroC").focus();
		}
		else if ($("#cbo_PuestoC").val()==-1)
		{
			showalert(LengStrMSG.idMSG180, "","gritter-info");
			$("#cbo_PuestoC").focus();
		}
		else if ($("#cbo_ParentescoCentro").val()==0)
		{
			showalert(LengStrMSG.idMSG177, "","gritter-info");
			$("#cbo_ParentescoCentro").focus();
		}
		else if ( $("#cbo_Estudio3").val()==-1)
		{
			showalert(LengStrMSG.idMSG178, "","gritter-info");
			 $("#cbo_Estudio3").focus();
		}
		else if ( $("#cbo_DescuentoCentro").val()==0)
		{
			showalert(LengStrMSG.idMSG179, "","gritter-info");
			 $("#cbo_DescuentoCentro").focus();
		}
		else
		{
			//GuardarCentro();
			$("#txt_Comentario").val("");	
			$("#dlg_Comentario").modal('show');
		}	
		event.preventDefault();	
		
	});
	
	function GuardarPuesto()
	{
		if ($('#txt_Puesto').val().length == 0)
		{
			//message('Ingrese n&uacute;mero de puesto...');
			showalert(LengStrMSG.idMSG183, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_Seccion').val() == -1)
		{
			//message('Seleccione Secci&oacute;n...');
			showalert(LengStrMSG.idMSG181, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_ParentescoPuesto').val() == -1)
		{
		//	message('Seleccione parentesco...');
			showalert(LengStrMSG.idMSG177, "", "gritter-info");
			return false;
		}	
		else if ($('#cbo_Estudio2').val() == -1)
		{
			//message('Seleccione estudio...');
			showalert(LengStrMSG.idMSG178, "", "gritter-info");
			return false;
		}		
		else if ($('#cbo_DescuentoPuesto').val() == 0)
		{
			//message('Seleccione Descuento...');
			showalert(LengStrMSG.idMSG179, "", "gritter-info");
			return false;
		}
		else
		{
			$.ajax({type: "POST",
				url: 'ajax/json/json_fun_grabar_configuracion_de_descuentos.php',
				data: {session_name:Session,
					'Opcion':3,
					'puesto':$('#txt_Puesto').val(),
					'parentesco':$('#cbo_ParentescoPuesto').val(),
					'escolaridad':$('#cbo_Estudio2').val(),
					'seccion':$('#cbo_Seccion').val(),
					'porcentaje':$('#cbo_DescuentoPuesto').val(),
					'comentario':$("#txt_Comentario").val().toUpperCase()
				},
				beforeSend:function(){},
				success:function(data){
					json = json_decode(data);
					if (json.estado == 5)
					{
						// estado = 1 then 'Descuento empleado agregado correctamente' 
						// estado = 2 then 'Descuento empleado ya existe'  
						// estado = 3 then 'Descuento de centro agregado correctamente'
						// estado = 4 then 'Descuento de centro ya existe'  
						// estado = 5 then'Descuento de puesto agregado correctamente'  
						// estado = 6 then 'Descuento de puesto ya existe' 
						// else 'El estudio de maestría sólo se permite para el colaborador ' 
						//message(json.mensaje);
						showalert(LengStrMSG.idMSG188, "", "gritter-success");
						cargarPuestos();
						LlenarGridParentescos(6,iPuesto,$('#cbo_Seccion').val() );					
						LimpiarModalPuesto();

					}
					else if(json.estado == 6)
					{
						showalert(LengStrMSG.idMSG189, "", "gritter-info");
					}
					else
					{
						showalert(LengStrMSG.idMSG190, "", "gritter-info");
					}
					limpiarCombos(3);
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}	
			});			
			cargarPuestos();
		}	
	}

	function GuardarColaborador(){
		NumEmpleado = $('#txt_idEmpleado').val();
	
		if ($('#txt_idEmpleado').val().length == 0)
		{
			showalert(LengStrMSG.idMSG191, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_ParentescoEmpleado').val() == -1)
		{
			showalert(LengStrMSG.idMSG177, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_estudio1').val() == -1)
		{
			showalert(LengStrMSG.idMSG178, "", "gritter-info");
			return false;
		}	
		else if ($('#cbo_DescuentoEmpleado').val() == 0)
		{
			showalert(LengStrMSG.idMSG179, "", "gritter-info");
			return false;
		}
		else
		{
			$.ajax({
				type: "POST",
				url: 'ajax/json/json_fun_grabar_configuracion_de_descuentos.php',
				data: {
					session_name:Session,
					'Opcion':1,
					'Empleado':$('#txt_idEmpleado').val(),
					'escolaridad':$('#cbo_estudio1').val(),
					'porcentaje':$('#cbo_DescuentoEmpleado').val(),
					'parentesco':$('#cbo_ParentescoEmpleado').val(),
					'iCentro':$('#txt_Centro').val(),
					'comentario':$("#txt_Comentario").val().toUpperCase()
				},
				beforeSend:function(){},
				success:function(data)
				{
					// estado = 1 then 'Descuento empleado agregado correctamente' 
					// estado = 2 then 'Descuento empleado ya existe'  
						
					json = json_decode(data);
					if (json.estado == 1)
					{
						showalert(LengStrMSG.idMSG184, "", "gritter-success");
						cargarColaboradores();
						LlenarGridParentescos(4,$('#txt_idEmpleado').val(),0);
						LimpiarModalColaborador();								
					}
					else if(json.estado == 2)
					{
						showalert(LengStrMSG.idMSG185, "", "gritter-info");
					}
					else
					{
						showalert(LengStrMSG.idMSG190, "", "gritter-info");
					}
					limpiarCombos(1);
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}	
			});			
			cargarColaboradores();		
		}
	}
	function GuardarCentro(){
		NumCentro = $('#txt_CentroC').val();
		if ($('#txt_CentroC').val().length == 0)
		{
			showalert(LengStrMSG.idMSG192, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_ParentescoCentro').val() == 0)
		{
			showalert(LengStrMSG.idMSG177, "", "gritter-info");
			return false;
		}	
		else if ($('#cbo_Estudio3').val() == -1)
		{
			showalert(LengStrMSG.idMSG178, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_PuestoC').val() == null)
		{
			showalert(LengStrMSG.idMSG180, "", "gritter-info");
			return false;
		}
		else if ($('#cbo_DescuentoCentro').val() == 0)
		{
			showalert(LengStrMSG.idMSG179, "", "gritter-info");
			return false;
		}
		else
		{
			$.ajax({type: "POST",
				url: 'ajax/json/json_fun_grabar_configuracion_de_descuentos.php',
				data: {
					session_name:Session,
					'Opcion':2,
					'Centro':$('#txt_CentroC').val(),
					'parentesco':$('#cbo_ParentescoCentro').val(),
					'escolaridad':$('#cbo_Estudio3').val(),
					'puesto':$('#cbo_PuestoC').val(),
					'porcentaje':$('#cbo_DescuentoCentro').val(),
					'comentario':$("#txt_Comentario").val().toUpperCase()
				},
				beforeSend:function(){},
				success:function(data){
					json = json_decode(data);
					// estado = 3 then 'Descuento de centro agregado correctamente'
					// estado = 4 then 'Descuento de centro ya existe'  
					if (json.estado == 3)
					{
						showalert(LengStrMSG.idMSG186, "", "gritter-info");
						cargarCentros();
						LlenarGridParentescos(5,NumCentro,iPuesto);
						LimpiarModalCentro();
					}
					else if(json.estado == 4)
					{
						showalert(LengStrMSG.idMSG187, "", "gritter-info");
						cargarCentros();
					}
					else
					{
						showalert(LengStrMSG.idMSG190, "", "gritter-info");
					}
					limpiarCombos(2);
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}	
			});		
			cargarCentros();
		}
	}
	function limpiarCombos(tipo)
	{
		if(tipo==1)//empleado
		{
			$('#cbo_estudio1').val(-1);
			$('#cbo_ParentescoEmpleado').val(-1);
			$("#cbo_DescuentoEmpleado").val($("#cbo_DescuentoEmpleado option").first().val());
		}
		else if(tipo==2)//centro
		{
			$('#cbo_PuestoC').val(-1);
			$('#cbo_Estudio3').val(-1);
			$('#cbo_ParentescoCentro').val(0);
			$("#cbo_DescuentoCentro").val($("#cbo_DescuentoCentro option").first().val());
		}
		else//puesto
		{
			$('#cbo_ParentescoPuesto').val(-1);
			$("#cbo_DescuentoPuesto").val($("#cbo_DescuentoPuesto option").first().val());
			$('#cbo_Estudio2').val(-1);
			$('#cbo_Seccion').val(-1);
		}	
	}
	

	function pdfColaborador()
	{
		var iNumEmpParametro = 0;
		if($("#txt_idEmpleado").val()!='')
		{
			iNumEmpParametro=$("#txt_idEmpleado").val();
		}
		if (($("#gd_Colaboladores").find("tr").length - 1) == 0 ) 
		{
			showalert(LengStrMSG.idMSG87, "", "gritter-info");
		}
		else
		{
			location.href = 'ajax/json/json_exportar_descuentos_especiales.php?&rows=-1&opc_busqueda=4'+'&nBusqueda='+iNumEmpParametro+'&page=-1'+'&sidx=numemp,parentesco&sord=asc'+'&session_name='+Session;	
		}	
	}		
	
	function pdfPuesto()
	{
		var iNumPuestoParametro = 0;
		if($("#txt_Puesto").val()!='')
		{
			iNumPuestoParametro=$("#txt_Puesto").val();
		}
		if (($("#gd_Puestos").find("tr").length - 1) == 0 ) 
		{
			showalert(LengStrMSG.idMSG87, "", "gritter-info");
		}
		else
		{
			
			location.href = 'ajax/json/json_exportar_descuentos_especiales.php?&rows=-1&opc_busqueda=6'+'&nBusqueda='+iNumPuestoParametro+'&page=-1'+'&sidx=puesto,parentesco&sord=asc'+'&session_name='+Session+'&nFiltro=-1';	
		}
			
	}
			
	function pdfCentro()
	{
		var iNumCentroParametro =0;
		if( $("#txt_CentroC").val()!='')
		{
			iNumCentroParametro=$("#txt_CentroC").val();
		}
		if (($("#gd_Centros").find("tr").length - 1) == 0 ) 
		{
			showalert(LengStrMSG.idMSG87, "", "gritter-info");
		}
		else
		{
			location.href = 'ajax/json/json_exportar_descuentos_especiales.php?&rows=-1&opc_busqueda=5'+'&nBusqueda='+iNumCentroParametro+'&page=-1'+'&sidx=centro,puesto,idu_parentesco&sord=asc'+'&session_name='+Session+'&nFiltro=-1';	
		}
		
	}
	
	////Limpia modal de busqueda al guardar registro 
	function LimpiarModalColaborador()
	{
		$("#txt_nombusqueda").val("");
		$("#txt_apepatbusqueda").val("");
		$("#txt_apematbusqueda").val("");		
		$('#grid-colaborador-table').jqGrid('clearGridData');
	}
	
	function LimpiarModalPuesto()
	{
		$("#txt_puestoBusqueda").val("");
		$('#grid_puesto').jqGrid('clearGridData');
	}
	
	function LimpiarModalCentro()
	{
		$("#txt_centroBusqueda").val("");
		$('#grid_centro').jqGrid('clearGridData');
	}
	
	
	////////Funcionalidad boton btn_GuardaObservacion de modal
	$("#btn_GuardaObservacion").click(function(event)
	{	
		if( ($("#txt_Comentario").val().replace('/^\s+|\s+$/g', ''))!="")
		{
			var tab =$("#tabs").tabs('option', 'active');
			switch(tab)
			{
				case 0://Colaborador
					//eliminarPorColaborador(iEmpleado,iCentro,iPuesto);
					GuardarColaborador();
				break;
				case 1://Puesto
					//eliminarPorPuesto(iPuesto,iSeccion);		
					GuardarPuesto();
				break;
				case 2://centro
					//eliminarPorCentro(iCentro,iPuesto);	
					GuardarCentro();
				break;
				
				
				default:
				break;
							
			}
			$("#dlg_Comentario").modal('hide');
		}
		else
		{
			//message("Favor de proporcionar una aclaración");
			showalert(LengStrMSG.idMSG193, "", "gritter-info");
			$("#txt_Comentario").val("");
			$("#txt_Comentario").focus();
		}	
		event.preventDefault();	
	});
	function CargarDescuentos()
	{
		//json_fun_obtener_descuentos_colegiaturas.php
		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_obtener_descuentos_colegiaturas.php',
			data: {},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				dataJson = json_decode(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "";//<option value='-1'>SELECCIONE</option>;<option value='0'>TODAS LAS SECCIONES</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_DescuentoCentro").html(option);
					$("#cbo_DescuentoEmpleado").html(option);
					$("#cbo_DescuentoPuesto").html(option);
					var Sel = $("#cbo_DescuentoCentro option").first().val();
					$("#cbo_DescuentoEmpleado").val(Sel);
					$("#cbo_DescuentoEmpleado" ).trigger("chosen:updated");
					$("#cbo_DescuentoPuesto").val(Sel);
					$("#cbo_DescuentoPuesto" ).trigger("chosen:updated");
					$("#cbo_DescuentoCentro").val(Sel);
					$("#cbo_DescuentoCentro" ).trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los descuentos", "", "gritter-error");
				}			
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});		
	}

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 394
            }
        })
        .done(function(data){
            var dataS = limpiarCadena(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }
	
})

