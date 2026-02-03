$(function(){	
	//---------------------------------------------------------------------	
	// CargargridCentro();
	// CargargridColab();
	// CargargridFactura();
	fnCargarAnios();
	CargarCombo("Centro");
	CargarCombo("Colaborador");
	CargarCombo("Estatus");

		
	// ---------------------------- F E C H A S ---------------------------------

		$("#txt_FechaIniFactura").datepicker({    
			onSelect: function( selectedDate ) {
				$( "#txt_FechaFinFactura" ).datepicker( "option", "minDate", selectedDate );
			}
		});

		$("#txt_FechaFinFactura").datepicker({    
			onSelect: function( selectedDate ) {
				$( "#txt_FechaIniFactura" ).datepicker( "option", "maxDate", selectedDate );
			}
		});    
});

	//-------------- G R I D S ----------------
	function CargargridCentro(){
		var nombre_centro = "N/A";
		dAnio = $('#cbo_anio_Centro').val();
		dMes = $('#cbo_mes_Centro').val();
		centro = $("#cbo_Centro").val();

		jQuery("#gridIndicadoresCentro-table").GridUnload(); //------> Recarga GRID 
		jQuery("#gridIndicadoresCentro-table").jqGrid({
			url:'ajax/json/json_indicadoresInternos_consultarIndicadores.php?',
			datatype: 'json',
			mtype: 'GET',
			colNames: LengStr.idMSG137,
			colModel:[
				{name:'nombre'	,index:'nombre'	,width:200,	resizable:false,	sortable:true,	align:"center",	fixed: true, hidden:true, sortable: false},
				{name:'anio' ,index:'anio' ,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'mes'	 ,index:'mes' ,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'dias_revision'	,index:'dias_revision'		,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'solicitudes',index:'solicitudes'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta'	,index:'meta'		,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'tiempo_promedio',index:'tiempo_promedio'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplimiento',index:'per_cumplimiento'	,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'rev_en_tiempo'	,index:'rev_en_tiempo'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'eficiencia'	,index:'eficiencia'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_per_efic'	,index:'meta_per_efic'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplim_eficiencia'	,index:'per_cumplim_eficiencia'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				
				{name:'dias_revision_acum'	,index:'dias_revision_acum'		,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'solicitudes_acum',index:'solicitudes_acum'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_acum'	,index:'meta_acum'		,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'tiempo_promedio_acum',index:'tiempo_promedio_acum'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplimiento_acum',index:'per_cumplimiento_acum'	,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'rev_en_tiempo_acum'	,index:'rev_en_tiempo_acum'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'eficiencia_acum'	,index:'eficiencia_acum'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_per_efic_acum'	,index:'meta_per_efic_acum'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplim_eficiencia_acum'	,index:'per_cumplim_eficiencia_acum'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				
				{name:'dias_revision_anio'	,index:'dias_revision_anio'		,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'solicitudes_anio',index:'solicitudes_anio'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_anio'	,index:'meta_anio'		,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'tiempo_promedio_anio',index:'tiempo_promedio_anio'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplimiento_anio',index:'per_cumplimiento_anio'	,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'rev_en_tiempo_anio'	,index:'rev_en_tiempo_anio'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'eficiencia_anio'	,index:'eficiencia_anio'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_per_efic_anio'	,index:'meta_per_efic_anio'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplim_eficiencia_anio'	,index:'per_cumplim_eficiencia_anio'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
			],
			rowattr: function(rowData, currentObj, rowId) {				
				if (rowData.nombre !== "") {
					nombre_centro = rowData.nombre;
				}
			},loadComplete: function(data) {
        
				$('#gridIndicadoresCentro-table').setGroupHeaders(
					{
						useColSpanStyle: true,
						groupHeaders: [
						{ "numberOfColumns": 2, "titleText": nombre_centro, "startColumnName": "anio" },
						{ "numberOfColumns": 9, "titleText": "Mensual", "startColumnName": "dias_revision" },
						{ "numberOfColumns": 9, "titleText": "Acumulado", "startColumnName": "dias_revision_acum" },
						{ "numberOfColumns": 9, "titleText": "Anual Móvil", "startColumnName": "dias_revision_anio" }]
					});
			},
			caption: "Indicadores Internos Centro",
			scrollrows: true,
			viewrecords : false,
			rowNum:30,
			// rowList:[10, 20, 30],
			hidegrid: false,
			pager : "#gridIndicadoresCentro-pager",
			// multiselect: false,
			// sortname:'dfecharegistro',
			// sortorder:'asc',
			width: null,
			shrinkToFit: false,
			height: 485,
			postData: {
				'dFecha': dAnio+'-'+dMes+'-01',
				'iTipoDato': 1,
				'iDato': centro
			}
		});		

        //================================ BOTONES =============================================
		barButtongrid({
			pagId:"#gridIndicadoresCentro-pager",
			position:"left",
			Buttons:[
				{
					icon:"icon-print blue",
					title:"Imprimir PDF",
					click: function(event){
						if(($("#gridIndicadoresCentro-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							GenerarPDF("Centro");
							
						}
						event.preventDefault();
					}
				},				
				{
					icon:"icon-list blue",
					title:"Generar Excel",
					click: function(event){
						if(($("#gridIndicadoresCentro-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							exportarExcel("Centro");
							
						}
						event.preventDefault();
					}
				}
			]
		});
		setSizeBtnGrid('id_button0', 35);
		setSizeBtnGrid('id_button1',35);
	}

	//---------------------------------------------------------------------	

	function CargargridColab(){
		var nombre_analista = "N/A";
		dAnio = $('#cbo_anio_Colab').val();
		dMes = $('#cbo_mes_Colab').val();
		analista = $("#cbo_Colaborador").val();
		
		jQuery("#gridIndicadoresColab-table").GridUnload(); //------> Recarga GRID
		jQuery("#gridIndicadoresColab-table").jqGrid({
			url:'ajax/json/json_indicadoresInternos_consultarIndicadores.php?',
			datatype: 'json',
			mtype: 'GET',
			colNames: LengStr.idMSG137,
			colModel:[
				{name:'nombre'	,index:'nombre'	,width:200,	resizable:false,	sortable:true,	align:"center",	fixed: true, hidden:true, sortable: false},
				{name:'anio' ,index:'anio' ,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'mes'	 ,index:'mes' ,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'dias_revision'	,index:'dias_revision'		,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'solicitudes',index:'solicitudes'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta'	,index:'meta'		,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'tiempo_promedio',index:'tiempo_promedio'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplimiento',index:'per_cumplimiento'	,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'rev_en_tiempo'	,index:'rev_en_tiempo'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'eficiencia'	,index:'eficiencia'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_per_efic'	,index:'meta_per_efic'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplim_eficiencia'	,index:'per_cumplim_eficiencia'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'dias_revision_acum'	,index:'dias_revision_acum'		,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'solicitudes_acum',index:'solicitudes_acum'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_acum'	,index:'meta_acum'		,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'tiempo_promedio_acum',index:'tiempo_promedio_acum'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplimiento_acum',index:'per_cumplimiento_acum'	,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'rev_en_tiempo_acum'	,index:'rev_en_tiempo_acum'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplim_eficiencia_acum'	,index:'per_cumplim_eficiencia_acum'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_per_efic_acum'	,index:'meta_per_efic_acum'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'eficiencia_acum'	,index:'eficiencia_acum'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'dias_revision_anio'	,index:'dias_revision_anio'		,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'solicitudes_anio',index:'solicitudes_anio'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_anio'	,index:'meta_anio'		,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'tiempo_promedio_anio',index:'tiempo_promedio_anio'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplimiento_anio',index:'per_cumplimiento_anio'	,width:100,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'rev_en_tiempo_anio'	,index:'rev_en_tiempo_anio'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'eficiencia_anio'	,index:'eficiencia_anio'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'meta_per_efic_anio'	,index:'meta_per_efic_anio'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
				{name:'per_cumplim_eficiencia_anio'	,index:'per_cumplim_eficiencia_anio'	,width:90,	resizable:false,	sortable:true,	align:"center",	fixed: true, sortable: false},
			],
			rowattr: function(rowData, currentObj, rowId) {
				nombre_analista = rowData.nombre;
			},
			loadComplete: function(data) {
        
				$('#gridIndicadoresColab-table').setGroupHeaders(
					{
						useColSpanStyle: true,
						groupHeaders: [
							{ "numberOfColumns": 2, "titleText": nombre_analista, "startColumnName": "anio" },
							{ "numberOfColumns": 9, "titleText": "Mensual", "startColumnName": "dias_revision" },
							{ "numberOfColumns": 9, "titleText": "Acumulado", "startColumnName": "dias_revision_acum" },
							{ "numberOfColumns": 9, "titleText": "Anual Móvil", "startColumnName": "dias_revision_anio" }]
					});
			},
			caption: "Indicadores Internos Colaborador",
			scrollrows: true,
			viewrecords : false,
			rowNum:30,
			// rowList:[10, 20, 30],
			hidegrid: false,
			pager : "#gridIndicadoresColab-pager",
			// multiselect: false,
			// sortname:'dfecharegistro',
			// sortorder:'asc',
			width: null,
			shrinkToFit: false,
			height: 485,
			postData: {
				'dFecha': dAnio+'-'+dMes+'-01',
				'iTipoDato': 2,
				'iDato': analista
			}
		});		

        //================================ BOTONES =============================================
		barButtongrid({
			pagId:"#gridIndicadoresColab-pager",
			position:"left",
			Buttons:[
				{
					icon:"icon-print blue",
					title:"Imprimir PDF",
					click: function(event){
						if(($("#gridIndicadoresColab-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							GenerarPDF("Colab");
							
						}
						event.preventDefault();
					}
				},				
				{
					icon:"icon-list blue",
					title:"Generar Excel",
					click: function(event){
						if(($("#gridIndicadoresColab-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							exportarExcel("Colab");
							
						}
						event.preventDefault();
					}
				}
			]
		});
		setSizeBtnGrid('id_button0', 35);
		setSizeBtnGrid('id_button1',35);
	}   

	function CargargridFactura(){
		dFechaInicio = formatearFecha($('#txt_FechaIniFactura').val());
		dFechaFin = formatearFecha($('#txt_FechaFinFactura').val());
		iEstatus = $("#cbo_Estatus").val();

		jQuery("#gridIndicadoresFactura-table").GridUnload(); //------> Recarga GRID 
		jQuery("#gridIndicadoresFactura-table").jqGrid({
			url:'ajax/json/json_indicadoresInternos_consultarFacturas.php?',
			datatype: 'json',
			mtype: 'GET',
			colNames: ["Número de Colaborador","Nombre", "Monto a Reembolsar (Con ISR)", "Monto a Reembolsar (Sin ISR)", "Región", "Folio Fiscal", "Escolaridad", "Analista", "Fecha Solicitud", "Fecha Autoriza Gerente", "Fecha Revisión Analista", "Fecha Pago", "Estatus","Días de Respuesta", "Año", "Mes", "Centro", "Mes Revisión Analista", "Año Revisión Analista"],
			colModel:[
				{name:'numemp', index:'numemp', width:90, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'nombre', index:'nombre', width:200,	resizable:false,	sortable:true,	align:"left",	fixed: true},
				{name:'reembolsoconisr', index:'reembolsoconisr', width:150,	resizable:false,	sortable:true,	align:"left",	fixed: true},
				{name:'reembolsosinisr', index:'reembolsosinisr', width:150,	resizable:false,	sortable:true,	align:"left",	fixed: true},
				{name:'region', index:'region', width:90, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'folio_fiscal', index:'folio_fiscal', width:250, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'nom_escolaridad', index:'nom_escolaridad', width:90, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'nom_analista', index:'nom_analista', width:250, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'fecha_solicitud', index:'fecha_solicitud', width:80, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'fecha_autoriza_gerente', index:'fecha_autoriza_gerente', width:80, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'fecha_reviso_analista', index:'fecha_reviso_analista', width:80, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'fecha_pago', index:'fecha_pago', width:80, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'nom_estatus', index:'nom_estatus', width:150, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'dias_respuestas', index:'dias_respuestas', width:90, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'anio', index:'anio', width:50, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'mes', index:'mes', width:90, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'numcentro_analista', index:'numcentro_analista', width:200, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'mes_rev_analista', index:'mes_rev_analista', width:90, resizable:false, sortable:true, align:"left",	fixed: true},
				{name:'anio_rev_analista', index:'anio_rev_analista', width:50, resizable:false, sortable:true, align:"left",	fixed: true}
			],
			loadComplete: function(data) {				
				var registros = jQuery("#gridIndicadoresFactura-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
			},
			caption: "Indicadores Internos Factura",
			scrollrows: true,
			viewrecords : true,
			rowNum:10,
			rowList:[10, 20, 30],
			hidegrid: false,
			pager : "#gridIndicadoresFactura-pager",
			multiselect: false,
			sortname:'dias_respuesta',
			sortorder:'desc',
			width: null,
			shrinkToFit: false,
			height: 380,
			postData: {
				'FechaIni': dFechaInicio,
				'FechaFin': dFechaFin,
				'iEstatus': iEstatus
			}
		});		

        //================================ BOTONES =============================================
		barButtongrid({
			pagId:"#gridIndicadoresFactura-pager",
			position:"left",
			Buttons:[
				{
					icon:"icon-print blue",
					title:"Imprimir PDF",
					click: function(event){
						if(($("#gridIndicadoresFactura-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							GenerarPDF("Factura");
						}
						event.preventDefault();
					}
				},				
				{
					icon:"icon-list blue",
					title:"Generar Excel",
					click: function(event){
						if(($("#gridIndicadoresFactura-table").find("tr").length - 1) == 0){
							showalert(LengStrMSG.idMSG87, "", "gritter-info");
						}else{
							exportarExcel("Factura");
							
						}
						event.preventDefault();
					}
				}
			]
		});
		setSizeBtnGrid('id_button0', 35);
		setSizeBtnGrid('id_button1',35);
	}

// BOTONES
$("#btn_ConsultarFactura").click(function(){
	CargargridFactura();
});

$("#btn_ConsultarCentro").click(function(){
	CargargridCentro();
});

$("#btn_ConsultarColab").click(function(){
	CargargridColab();
});

// ---------------------------- FUNCIONES PANTALLA ---------------------------------	
function Limpiar(data){
	// Limpiar grid
	$("#gridIndicadores"+data+"-table").jqGrid('clearGridData'); 

	// Limpiar fechas
	$("#txt_FechaIniFactura").datepicker({dateFormat: 'dd/mm/yy',}).datepicker("setDate", new Date());
	$("#txt_FechaFinFactura").datepicker({dateFormat: 'dd/mm/yy',}).datepicker("setDate", new Date());

	// Limpiar combos
	switch (data) {
		case 'Centro':
				$("#cbo_Centro").val(-1);
			break;
		case 'Colab':
				$("#cbo_Colab").val(-1);
			break;
		case 'Factura':
			$("#cbo_Estatus").val(-1);
			break;
	}
}

function setSizeBtnGrid(id,tamanio) {
	$("#"+id).attr('width',tamanio+'px');
	$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"80%"})
}

// ---------------------------- VULNERABILIDADES ---------------------------------
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

/*************** Combos  ***********************/
function CargarCombo(data){
	switch(data){
		case "Centro":
			sUrl = 'ajax/json/json_indicadoresInternos_consultarCentros.php';
		break;
		case "Colaborador":
			sUrl = 'ajax/json/json_indicadoresInternos_consultarAnalistas.php';
		break;
		case "Estatus":
			sUrl = 'ajax/json/json_indicadoresInternos_consultarEstatus.php';
		break;
	}

	var option="";
	$.ajax(
		{
			type: "POST",
			url: sUrl,
			data: { } 
		})
	.done(function(datag){
		var sanitizedData = limpiarCadena(datag);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			if(data == "Estatus"){
				option = option + "<option value='-1'>TODOS</option>";
			}else{
				option = option + "";
			}

			for(var i=0;i<dataJson.datos.length; i++)
			{
				option = option + "<option value='" + dataJson.datos[i].idu_data + "'>" + dataJson.datos[i].nom_data + "</option>";
			}
			$("#cbo_"+data).html(option);
			$("#cbo_"+data).trigger("chosen:updated");
			
			//$("#cbo_"+data).val(1);
			$("#cbo_"+data).trigger("chosen:updated");
		}
		else
		{
			showalert(LengStrMSG.idMSG88+" los datos", "", "gritter-error");
		}
	})
	.fail(function(s) {
		showalert(LengStrMSG.idMSG88+" los datos", "", "gritter-error");
		$('#cbo_'+data).fadeOut();
	});
}

/*************** Cambio de check  ***********************/
function CambioCheck()
{    
	if($("#chk_indicadores").hasClass("On")){
		$("#press_tab2").click();
		$("#chk_indicadores").removeClass("On");
	}else{
		$("#press_tab1").click();
		$("#chk_indicadores").addClass("On");
	}
}

$(".indicadores_radio").click(function(){
	if($(this).val() == 1){
		$("#press_tabi1").click();
	}else{
		$("#press_tabi2").click();
	}
});

// 
function GenerarPDF(data){
	dFechaInicio = formatearFecha($('#txt_FechaIniFactura').val());
	dFechaFin = formatearFecha($('#txt_FechaFinFactura').val());	
	dAnio = $('#cbo_anio_'+data).val();
	dMes = $('#cbo_mes_'+data).val();
	
	var sUrl = 'ajax/json/';
	if (data == "Factura"){
		sUrl += 'impresion_json_indicadoresInternos_ConsultarFacturas.php?';
		sUrl += '&FechaIni='+dFechaInicio;
		sUrl += '&FechaFin='+dFechaFin;
		sUrl += '&iEstatus='+$("#cbo_Estatus").val();
			
		location.href = sUrl;
	}else{
		if(data == "Centro"){
			iTipoDato = 1;
			iDato = $("#cbo_Centro").val();
		}else{
			iTipoDato = 2;
			iDato = $("#cbo_Colaborador").val();
		}

		sUrl += 'impresion_json_indicadoresInternos_CentroColab.php?';
		sUrl += '&dFecha='+dAnio+'-'+dMes+'-01';
		sUrl += '&iTipoDato='+iTipoDato;
		sUrl += '&iDato='+iDato;
			
		location.href = sUrl;
	}
	
}

function exportarExcel(data)
{	
	dFechaInicio = formatearFecha($('#txt_FechaIniFactura').val());
	dFechaFin = formatearFecha($('#txt_FechaFinFactura').val());
	dAnio = $('#cbo_anio_'+data).val();
	dMes = $('#cbo_mes_'+data).val();

	
	
	var sUrl = 'ajax/proc/';
	if (data == "Factura"){
		iFiltro = $("#cbo_Estatus").val();
		sUrl += 'proc_excel_indicadoresInternos_Facturas.php?';
		sUrl += '&FechaIni='+dFechaInicio;
		sUrl += '&FechaFin='+dFechaFin;
		sUrl += '&iEstatus='+iFiltro;
			
		location.href = sUrl;
	}else{
		if(data == "Centro"){
			iTipoDato = 1;
			iDato = $("#cbo_Centro").val();
		}else{
			iTipoDato = 2;
			iDato = $("#cbo_Colaborador").val();
		}
	
		sUrl += 'proc_excel_indicadoresInternos_CentroColab.php?';
		sUrl += '&dFecha='+dAnio+'-'+dMes+'-01';
		sUrl += '&iTipoDato='+iTipoDato;
		sUrl += '&iDato='+iDato;
				
		location.href = sUrl;
	}
}

// Cargar los años que hay en DB


function fnCargarAnios(){
	// Fechas para filtros de mes y año
	var fechaActual = new Date();
	var anioActual = fechaActual.getFullYear();
	var option = "";

	$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
		data: {}
	}).done(function(data){
		var sanitizedData = limpiarCadena(data);
		var dataJson = JSON.parse(sanitizedData);
		if(dataJson.estado == 0)
		{
			for(var i=0;i<dataJson.datos.length; i++)
			{
				if(dataJson.datos[i].value <= anioActual){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].value + "</option>";
				}
			}
			$("#cbo_anio_Centro").html(option);
			$("#cbo_anio_Colab").html(option);

			fnCargarMeses(1,anioActual,"ALL");
		}
	});

}

function fnCargarMeses(iOpcion, cbo_anio, cbo_mes){
	// iOpcion 1 es para cargar meses con el año en curso y 2 para consultar por año en select año
		var fechaActual = new Date();
		var mesActual = fechaActual.getMonth() + 1;
		var anioActual = fechaActual.getFullYear();
		
		var anioSeleccionado = (iOpcion == 1) ? cbo_anio : $('#'+cbo_anio).val();
		var numMeses = (anioSeleccionado == anioActual) ? mesActual : 12;
		
		if(cbo_mes == "ALL"){
			for (var mes = numMeses; mes >= 1; mes--) {
				$('#cbo_mes_Centro').append('<option value="' + mes + '">' + obtenerNombreMes(mes) + '</option>');
				$('#cbo_mes_Colab').append('<option value="' + mes + '">' + obtenerNombreMes(mes) + '</option>');
			}
		}else{
			$('#'+cbo_mes).empty();

			for (var mes = numMeses; mes >= 1; mes--) {
				$('#'+cbo_mes).append('<option value="' + mes + '">' + obtenerNombreMes(mes) + '</option>');
			}
		}
}

$(".cbo_anio").change(function(){
	var cbo_anio = limpiarCadena($(this).attr('id'));	
	cbo_mes = cbo_anio.replace("anio", "mes")
	
	fnCargarMeses(2,cbo_anio,cbo_mes);
		
});



function obtenerNombreMes(mes) {
    var meses = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'];
    return meses[mes - 1];
}