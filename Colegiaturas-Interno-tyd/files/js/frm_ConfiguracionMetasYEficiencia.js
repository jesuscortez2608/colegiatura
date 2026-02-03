$(function(){
	SessionIs();
	//CargarComboOpcion();
	// solonumero("txt_Meta");
	// solonumero("txt_Eficiencia");

	/////Variables globales
	var NumColaborador 
		, Fec_capturo
		, i_meta 
		, i_eficiencia 
		, i_anio 
		, i_mes;

		
		var iGuardo = 0;
	CargarGrid();
	ActualizarGrid();

$("#dp_FechaInicio").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
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
			$( "#dp_FechaFin" ).datepicker( "option", "minDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	$("#dp_FechaFin").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
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
			$( "#dp_FechaInicio" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});	


	$("#dp_FechaInicio" ).datepicker("setDate",new Date());
	$("#dp_FechaFin" ).datepicker("setDate",new Date());		
	
	/////////////Validaciones///////////////////////
	
	$("#txt_Eficiencia").change(function(){ //----> Combo Escolaridad Modal (Agregar Escuela)
		var porcentaje=$("#txt_Eficiencia").val();
		console.log(porcentaje);
		if(porcentaje > 100)
		{
			showalert(" Eficiencia no debe ser mayor a 100%", "", "gritter-info");	
			$("#txt_Eficiencia").val('');		
		}
	});
	
	function CargarGrid()	
	{
		console.log("Grid");
		$("#gridConfigMetasEficiencia-table").jqGrid("GridUnload");
		jQuery("#gridConfigMetasEficiencia-table").jqGrid({
		url:'ajax/json/json_fun_obtener_metas_eficiencia_colegiaturas.php',
		datatype: 'json',
		mtype: 'POST',
		colNames:LengStr.idMSG129,
			colModel:[
				{name:'numemp_reg',index:'numemp_reg', width:450, sortable: false,align:"left",fixed: true},
				{name:'fec_captura',index:'fec_captura', width:100, sortable: false,align:"center",fixed: true},
				{name:'imeta',index:'imeta', width:80, sortable: false,align:"center",fixed: true},
				{name:'ieficiencia',index:'ieficiencia', width:80, sortable: false,align:"center",fixed: true},
				{name:'ianio',index:'ianio', width:80, sortable: false,align:"center",fixed: true},
				{name:'imes', index:'imes', width:80, sortable: false, align:"center", fixed: true }
			],
			
			caption:'Colaboradores',
			scrollrows : true,
			width: 1000,
			loadonce: false,
			shrinkToFit: false,
			height: 380,
			rowNum:-1, //20,
			//rowList:[20, 40, 60, 80],
			pager:'#gridConfigMetasEficiencia-pager',
			sortname: 'numemp_reg',
			sortorder: "asc",
			pgbuttons: false,
			pgtext: null,
			viewrecords: true,
			hidegrid:false,
			postData:{session_name:Session},
			
			loadComplete: function (Data) {
			},
			onSelectRow: function(Numemp)
			{			
			var Data = jQuery("#gridConfigMetasEficiencia-table").jqGrid('getRowData',Numemp);
				NumColaborador = Data.numemp_reg;
				Fec_capturo = Data.fec_captura;
				i_meta = Data.imeta;
				i_eficiencia = Data.ieficiencia;
				i_anio = Data.ianio;
				i_mes = Data.imes;
			}
			//ActualizarGrid();
			
		});	
		
	}	
	function ActualizarGrid() {
		$("#gridConfigMetasEficiencia").jqGrid('setGridParam', { url:'ajax/json/json_fun_obtener_metas_eficiencia_colegiaturas.php'}).trigger("reloadGrid");
		$("#dp_FechaInicio" ).val();
		$("#dp_FechaFin" ).val();
		LimpiarFechas();
		CargarGrid();
	}
	
	function GuardarMetaEficiencia()
	{	
		var fecini;
		var fecfin;
		var anio_fecini;
		var anio_fecfin; 
		var mes_fecini;
		var mes_fecfin;
		var totalmes;		
		
		fecini = $("#dp_FechaInicio" ).val();
		fecfin = $("#dp_FechaFin").val();
		mes_fecini = parseInt(fecini.substr(3,2));
		mes_fecfin = parseInt(fecfin.substr(3,2));
		anio_fecini = parseInt(fecini.substr(6,4));
		anio_fecfin = parseInt(fecfin.substr(6,4));
		
		console.log(fecini);
		console.log(fecfin);
		
		if(mes_fecini != mes_fecfin && anio_fecini == anio_fecfin){
			console.log(1);
			var i;
			for(i=mes_fecini;i<=mes_fecfin;i++){
				$.ajax({type: "POST", 
				url:'ajax/json/json_fun_grabar_metas_eficiencia_colegiaturas.php?',
				data: { 
					'session_name': Session,
					//'iUsuario': NumColaborador,
					//'fecha_captura': '20240320',
					'meta' : $("#txt_Meta").val(),
					'eficiencia': $("#txt_Eficiencia").val(),
					'anio': anio_fecini,
					'mes': i
						
					}
				})
				.done(function(data){
					var dataJson = JSON.parse(data);	
					//totalmes = i-1;
					//if(i = mes_fecfin){
						if(dataJson.resultado == 1) 
						{
							iGuardo = 1;
							//showalert("Registros guardado correctamente 1...", "","gritter-success");	
							//ActualizarGrid();
						}
						else if(dataJson.resultado == 0)
						{
							iGuardo = 2;
							//showalert("Se actualiza información correctamente", "", "gritter-info");
							//ActualizarGrid();
						}
						else
						{
							iGuardo = 3;
							//showalert("No se puede guardar en el mes actual", "", "gritter-info");
						}
					//}   
					i+1;
				});	
			}
		}else if(anio_fecini != anio_fecfin){

				var i,j;
				var mIni,mFin;
				for(j=anio_fecini;j<=anio_fecfin;j++){
					mIni = (j == anio_fecini)?mes_fecini:1;
					mFin = (j == anio_fecfin)?mes_fecfin:12;
					for(i=mIni;i<=mFin;i++){
						//console.log("Enviando: año "+ j + " mes " + i);
						$.ajax({type: "POST", 
								url:'ajax/json/json_fun_grabar_metas_eficiencia_colegiaturas.php?',
								data: { 
									'session_name': Session,
									//'iUsuario': NumColaborador,
									//'fecha_captura': '20240320',
									'meta' : $("#txt_Meta").val(),
									'eficiencia': $("#txt_Eficiencia").val(),
									'anio': j,
									'mes': i
									
								}
							})
							.done(function(data){
								var dataJson = JSON.parse(data);	
								totalmes = i-1;
								if(i = mes_fecfin){
									if(dataJson.resultado == 1) 
									{
										//showalert("Registros guardado correctamente 2...", "","gritter-success");	
										iGuardo = 1;
										//ActualizarGrid();
									}
									else if(dataJson.resultado == 0)
									{
										//showalert("Se actualiza información correctamente", "", "gritter-info");
										iGuardo = 2;
										//ActualizarGrid();
									}
									else
									{
										iGuardo = 3;
										//showalert("No se puede guardar en el mes actual", "", "gritter-info");
									}
								}
							});						
							i+1;
					}
					j+1
				}						 				
		} else {
			console.log(3);
			$.ajax({type: "POST", 
				url:'ajax/json/json_fun_grabar_metas_eficiencia_colegiaturas.php?',
				data: { 
					'session_name': Session,
					//'iUsuario': NumColaborador,
					//'fecha_captura': '20240320',
					'meta' : $("#txt_Meta").val(),
					'eficiencia': $("#txt_Eficiencia").val(),
					'anio': anio_fecini,
					'mes': mes_fecini
					
				}
			})
			.done(function(data){
				var dataJson = JSON.parse(data);	
				console.log(data);
				if(dataJson.resultado == 1)
				{
					showalert("Registros guardado correctamente.", "","gritter-success");
					ActualizarGrid();
					//iGuardo = 1;
				}
				else if(dataJson.resultado == 0)
				{
					showalert("Se actualiza información correctamente.", "", "gritter-info");
					//iGuardo = 2;
					ActualizarGrid();
				}
				else
				{
					//iGuardo = 3;
					showalert("No se puede guardar en el mes actual.", "", "gritter-info");
				}
			});

			
		}
		//alert(iGuardo);
		if(iGuardo == 1){
			//console.log(iGuardo);
			showalert("Registros guardado correctamente.", "","gritter-success");
			ActualizarGrid();
		}
		else if(iGuardo == 2){
			showalert("Se actualiza información correctamente.", "", "gritter-info");
			ActualizarGrid();
		}
		else if(iGuardo == 3){
			showalert("No se puede guardar en el mes actual.", "", "gritter-info");
		}
	}
	
	
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
		
	//////////////////////////////////////Guardar//////////////////////////////
	$('#btn_guardar').click(function(event)
	{	
				
		// VALIDACIONES //
		if ($('#txt_Meta').val() == "")
		{
			$('#txt_Meta').focus();
			showalert('Favor de colocar número de meta', "", "gritter-info");
		}
		else
		{
			GuardarMetaEficiencia();
			LimpiarFechas();
		}
		
		event.preventDefault();
	});

		
	function LimpiarFechas()
	{
		$("#dp_FechaInicio" ).datepicker("setDate",new Date());
		$("#dp_FechaFin" ).datepicker("setDate",new Date());
	}

});