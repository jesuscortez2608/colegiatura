$(function(){
	ConsultaClaveHCM()
	var nEditar=0, 
		nRegistro=0,
		nEmpleado = 0,
		nSuplente = 0,
		sFechaInicial='',
		sFechaFinal='',
		nIndefinido = 0;
	//Inicializar Formulario
	$("#txt_iduempleado2").prop("disabled", true);
		
	fnCaragarGrid();
	
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

	$("#txt_FechaIni").datepicker({
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
	$("#txt_FechaIni").prop('disabled',true);
	$("#txt_FechaFin").prop('disabled',true);
	$("#chkbx_indefinido").change(function(){
		if($('#chkbx_indefinido').is(":checked"))//si esta seleccionado
		{//Bloquea las fechas
			
			$("#txt_FechaIni").prop('disabled',true);
			$("#txt_FechaFin").prop('disabled',true);
			LimpiarFechas();
			
		}else
		{
			$("#txt_FechaIni").prop('disabled',false);
			$("#txt_FechaFin").prop('disabled',false);
		}
	});
	function LimpiarFechas()
	{
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		//$("#txt_FechaFin" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val())
		
	}
	///////////////////////GRID////////////////////////////
	function fnCaragarGrid()
	{
		jQuery("#gridSuplentes-table").jqGrid({
			url:'ajax/json/json_fun_obtener_bitacora_suplentes.php',
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG4,
				colModel:[
				//{name:'marca', width:70, sortable: false,align:"center",fixed: true},
				{name:'marca',index:'marca', width:50, align: 'center',sortable: false, 
							edittype:'checkbox', editable:true, editoptions: { value:"false"}, 
							formatter: "checkbox", formatoptions: {disabled : false} },
				{name:'idu_id',					index:'idu_id', 				width:100, sortable: false,	align:"left",	fixed: true,  	hidden:true},
				{name:'idu_empleado',			index:'idu_empleado', 			width:100, sortable: false,	align:"left",	fixed: true, 	hidden:true },
				{name:'nom_empleado',			index:'nom_empleado', 			width:320, sortable: false,	align:"left",	fixed: true},
				{name:'idu_centro',				index:'idu_centro', 			width:280, sortable: false,	align:"left",	fixed: true},
				{name:'idu_suplente',			index:'idu_suplente', 			width:100, sortable: false,	align:"left",	fixed: true, 	hidden:true },
				{name:'nom_suplente',			index:'nom_suplente', 			width:320, sortable: false,	align:"left",	fixed: true},
				{name:'idu_centro_suplenete',	index:'idu_centro_suplenete', 	width:280, sortable: false,	align:"left",	fixed: true},
				{name:'idu_empleado_registro',	index:'idu_empleado_registro', 	width:320, sortable: false,	align:"left",	fixed: true},
				{name:'fec_registro',			index:'fec_registro', 			width:100, sortable: false,	align:"left",	fixed: true},
				{name:'fec_inicial',			index:'fec_inicial', 			width:100, sortable: false,	align:"left",	fixed: true},
				{name:'fec_final',				index:'fec_final', 				width:100, sortable: false,	align:"left",	fixed: true},
				{name:'opc_indefinido',			index:'opc_indefinido', 		width:100, sortable: false,	align:"left",	fixed: true, 	hidden:true},
				{name:'nom_indefinido',			index:'nom_indefinido', 		width:100, sortable: false,	align:"center",	fixed: true},
				{name:'fecha_baja',				index:'fecha_baja', 			width:100, sortable: false,	align:"center",	fixed: true},
				{name:'cancelado',				index:'cancelado', 				width:100, sortable: false,	align:"center",	fixed: true, 	hidden:true /*,formatter: rowColorFormatter*/},
				{name:'marcado',				index:'marcado', 				width:100, sortable: false,	align:"left",					hidden: true}
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			//viewrecords : true,
			
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			pager : "#gridSuplentes-pager",
			//--Para que el tamaño sea automatico muy bueno ya con los otros cambios se evita crear tablas
			width: null,
			shrinkToFit: false,
			height: 350,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			//----------------------------------------------------------------------------------------------------------
			caption: 'Suplentes',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			
			loadComplete: function (Data) {
				
				if (!Data.rows){													
					return;
				}else{
					for(var ii=0; ii < Data.rows.length; ii++ )
					{
						if(Data.rows[ii].cell[15] == 1) //campo cancelado del grid 
						{
							$("#" + ii).css("background-color", "#e7230b");
							$("#" + ii).css("color", "#FFF");
						}	
					}		
				}
				
				$('#gridSuplentes-table :checkbox').change(function(e){
					var id = $(e.target).closest('tr')[0].id;
					var rowData = $('#gridSuplentes-table').getRowData(id);
					marcado = $(this).is(":checked") ? 1 : 0;
					$('#gridSuplentes-table').jqGrid("setCell", id, "marcado", marcado);
				});
			},
			onSelectRow: function(id) {
			},	
		});	
		
		barButtongrid({
			pagId:"#gridSuplentes-pager",
			position:"left",//center rigth
			Buttons:[
				{
				icon:"icon-remove red bigger-140",
				title:'Cancelar Suplente',
				click: function(event)
				{
					sjson = recorrerGrid();
					var dataJson = JSON.parse(sjson);
					if(dataJson.length!=0)
					{
						bootbox.confirm(LengStrMSG.idMSG127, 
						function(result)
						{
							if (result)
							{
						
								$.ajax({type: "POST", 
									url:'ajax/json/json_fun_cancelar_suplente_colegiaturas.php?',
									data: { 
										'sjson':sjson,
										'session_name': Session
									},
									beforeSend:function(){},
									success:function(data){
										var dataJson = JSON.parse(data);	
										if(dataJson.estado == 0)
										{
											//ConsultarMotivos();
											//alert('Motivo actualizado correctamente...');
											//i++;
										}
										else
										{
											showalert(LengStrMSG.idMSG128, "", "gritter-success");
											if($("#txt_nomempleado").val()!="")
											{
												ConsultarSuplentes(0);
											}
											$("#gridSuplentes-table").jqGrid('setGridParam',{ }).trigger("reloadGrid"); 
											return;
										}
									},
									error:function onError(){},
									complete:function(){},
									timeout: function(){},
									abort: function(){}		
								});
							}	
						});
					}
					else
					{
						//showmessage('Deberá de marcar los registros a eliminar', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG129, "", "gritter-info");
					}
					event.preventDefault();
				}
			},
			{
				icon:"icon-edit orange bigger-140",	
				title:'Editar Suplente',
				click: function(event)
				{
				
					if ( ($("#gridSuplentes-table").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG130, "", "gritter-info");
						return;
					}
					else
					{
						sjson = recorrerGridModificar();
						var dataJson = JSON.parse(sjson);
						
						if(dataJson.length==0)
						{
							showalert(LengStrMSG.idMSG131, "", "gritter-info");
						}
						else if (dataJson.length>1)
						{
							showalert(LengStrMSG.idMSG132, "", "gritter-info");
						}
						else
						{
							var iSuplente=nSuplente;
							/*if(nEditar==0)
							{
								//showmessage('Seleccione el suplente a modificar', '', undefined, undefined, function onclose(){});
								showalert("Seleccione el suplente a modificar", "", "gritter-info");
								return;
							}*/
							$("#txt_iduempleado").val(nEmpleado);
							ConsultaEmpleado(1, function(){
								ConsultarSuplentes();
								$("#txt_iduempleado2").val(iSuplente);
								ConsultaEmpleado(2, function(){ });
							});
							if (nIndefinido == 1) {
								// Marcar un checkbox
								$("#chkbx_indefinido").attr("checked","checked");
								LimpiarFechas();
								$("#txt_FechaIni").prop('disabled',true);
								$("#txt_FechaFin").prop('disabled',true);
								
							} else {
								// Desmarcar un checkbox
								$("#chkbx_indefinido").removeAttr("checked");
								$('#txt_FechaIni').val(sFechaInicial);
								$('#txt_FechaFin').val(sFechaFinal);
								$("#txt_FechaIni").prop('disabled',false);
								$("#txt_FechaFin").prop('disabled',false);
							}
						}
					}
						
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
	}	
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	function ConsultarSuplentes(inicializar)
	{
		var numEmp=0;
		if($("#txt_iduempleado").val()!='')
		{
			numEmp=$("#txt_iduempleado").val();
		}
		$("#gridSuplentes-table").jqGrid('setGridParam',
		{ url: 'ajax/json/json_fun_obtener_bitacora_suplentes.php?inicializar='+inicializar+'&iNumEmp='+numEmp+'&session_name=' +Session}).trigger("reloadGrid"); 
			
	};	
	
	$('#txt_iduempleado').on('input propertychange paste', function(){
		if(($("#txt_iduempleado").val().length != 8) && ($('#txt_iduempleado').val()!=''))
		{
			//Campos del Gerente
			/*$("#txt_nomempleado").val("");
			$("#txt_iducentro").val("");
			$("#txt_nomcentro").val("");
			$("#txt_idupuesto").val("");
			$("#txt_nompuesto").val("");
			
			//Campos del empleado
			$("#txt_iduempleado2").prop("disabled", true);
			$("#txt_iduempleado2").val("");
			$("#txt_nomempleado2").val("");
			$("#txt_iducentro2").val("");
			$("#txt_nomcentro2").val("");
			$("#txt_idupuesto2").val("");
			$("#txt_nompuesto2").val("");*/
			LimpiarDatos(3);
			$("#txt_iduempleado2").prop("disabled", true);
			//$('#gridSuplentes-table').jqGrid('clearGridData');
		}	
		else //if($( '#txt_Numemp' ).val().length==8)
		{
			
			$("#txt_iduempleado2").prop("disabled", true);
			LimpiarDatos(2);
			/*$("#txt_iduempleado2").val("");
			$("#txt_nomempleado2").val("");
			$("#txt_iducentro2").val("");
			$("#txt_nomcentro2").val("");
			$("#txt_idupuesto2").val("");
			$("#txt_nompuesto2").val("");*/
			ConsultaEmpleado(1, 
				function(){
					ConsultarSuplentes();
				}
			);
		}
	});
	$("#txt_iduempleado").keydown(function(e){
		
		var keycode = e.which;
		if(keycode == 13 || keycode == 9  /*|| keycode == 0*/)
		{
			$("#txt_iduempleado2").val("");
			$("#txt_nomempleado2").val("");
			$("#txt_iducentro2").val("");
			$("#txt_nomcentro2").val("");
			$("#txt_idupuesto2").val("");
			$("#txt_nompuesto2").val("");
			if(($("#txt_iduempleado").val().length != 8) && ($("#txt_iduempleado").val()!=''))
			{
				//Campos del gerente
				$("#txt_iduempleado").focus();
				$("#txt_iduempleado").val();
				$("#txt_nomempleado").val("");
				$("#txt_iducentro").val("");
				$("#txt_nomcentro").val("");
				$("#txt_idupuesto").val("");
				$("#txt_nompuesto").val("");
				
				//Campos del suplente
				$("#txt_iduempleado2").prop("disabled", true);
				$("#txt_iduempleado2").val("");
				$("#txt_nomempleado2").val("");
				$("#txt_iducentro2").val("");
				$("#txt_nomcentro2").val("");
				$("#txt_idupuesto2").val("");
				$("#txt_nompuesto2").val("");
				
				
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");
				//ConsultarSuplentes();
				//$('#gridSuplentes-table').jqGrid('clearGridData');
			}
			else
			{
				ConsultaEmpleado(1, 
				function(){
					ConsultarSuplentes();
				});
			}
		}else if (keycode == 8 || keycode==0){
			LimpiarDatos (1);
		}
	});
	
	$( '#txt_iduempleado2' ).on('input propertychange paste', function(){
		
		if($("#txt_iduempleado2").val().length != 8)
		{
			$("#txt_nomempleado2").val("");
			$("#txt_iducentro2").val("");
			$("#txt_nomcentro2").val("");
			$("#txt_idupuesto2").val("");
			$("#txt_nompuesto2").val("");
		}	
		else 
		{
			ConsultaEmpleado(2, function(){});
		}
	});
	
	$("#txt_iduempleado2").keypress(function(e){
		var keycode = e.which;
		if(keycode == 13 || keycode == 9 /*|| keycode == 0*/)
		{
			if($("#txt_iduempleado2").val().length != 8)
			{
				showalert(LengStrMSG.idMSG133, "", "gritter-warning");
				$("#txt_iduempleado2").focus();
				$("#txt_iduempleado2").val("");
				$("#txt_nomempleado2").val("");
				$("#txt_iducentro2").val("");
				$("#txt_nomcentro2").val("");
				$("#txt_idupuesto2").val("");
				$("#txt_nompuesto2").val("");
			}
			else
			{
				if($("#txt_iduempleado").val()==$("#txt_iduempleado2").val())
				{
					showalert(LengStrMSG.idMSG134, "", "gritter-warning");
					$("#txt_iduempleado2").focus();
					$("#txt_iduempleado2").val("");
					$("#txt_nomempleado2").val("");
					$("#txt_iducentro2").val("");
					$("#txt_nomcentro2").val("");
					$("#txt_idupuesto2").val("");
					$("#txt_nompuesto2").val("");
					
				}
				else
				{
				
					ConsultaEmpleado(2, function(){
					});
				}
			}		
		}else if (keycode == 8 || keycode==0){
			LimpiarDatos (2);
		}
	});
	
	//LIMPIAR DATOS SUPLENTE
	function LimpiarDatos(opc){
		if (opc==1 || opc==3){
			$("#txt_iduempleado2").val("");
			$("#txt_nomempleado").val("");
			$("#txt_iducentro").val("");
			$("#txt_nomcentro").val("");
			$("#txt_idupuesto").val("");
			$("#txt_nompuesto").val("");
		}
		
		if (opc==2 || opc==3){
			$("#txt_iduempleado2").val("");
			$("#txt_nomempleado2").val("");
			$("#txt_iducentro2").val("");
			$("#txt_nomcentro2").val("");
			$("#txt_idupuesto2").val("");
			$("#txt_nompuesto2").val("");
		}
		LimpiarFechas();
		nRegistro=0;
	}
	
	function ConsultarPuestoGerente()
	{
		var iNumEmp=0;
		if(tipo==1)
		{
			iNumEmp=$("#txt_iduempleado").val();
		}
		else
		{
			iNumEmp=$("#txt_iduempleado2").val();
			if($("#txt_iduempleado").val()==$("#txt_iduempleado2").val())
			{
				$("#txt_iduempleado2").val("");
				showalert(LengStrMSG.idMSG134, "", "gritter-warning");
				return;
			}
		}
		$.ajax({type: "POST",
			url: "ajax/json/json_ConsultaGerente.php",
			data: { 'empleado':iNumEmp },
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson.estado==0)
				{
					dataJson.tipo
				}	
				
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}
	function ConsultaEmpleado(tipo, callbackSuplentes)
	{	
		var iNumEmp;
		if(tipo==1)
		{
			iNumEmp=$("#txt_iduempleado").val();
		}
		else
		{
			iNumEmp=$("#txt_iduempleado2").val();
			if($("#txt_iduempleado").val()==$("#txt_iduempleado2").val())
			{
				$("#txt_iduempleado2").val("");
				showalert(LengStrMSG.idMSG134, "", "gritter-warning");
				return;
			}
		}
		if(iNumEmp!='')
		{
			$.ajax({type: "POST", 
			url: "ajax/json/json_fun_consulta_empleado_co.php?",
			data: { 
					'iNumEmp':iNumEmp,
					'session_name': Session
				}
			})
			.done(function(data){				
				var dataJson = JSON.parse(data);
				if(dataJson != null)
				{
					if(tipo==1)
					{	
						if(dataJson.cancelado=='1')
						{
							showalert(LengStrMSG.idMSG135, "", "gritter-warning");
							$("#txt_iduempleado").val("");
							$("#txt_nomempleado").val("");
							$("#txt_iducentro").val("");
							$("#txt_nomcentro").val("");
							$("#txt_idupuesto").val("");
							$("#txt_nompuesto").val("");
							$("#txt_iduempleado").focus();
						}
						else
						{
							$("#txt_nomempleado").val(dataJson.nom_empleado);
							$("#txt_iducentro").val(dataJson.idu_centro);
							$("#txt_nomcentro").val(dataJson.nom_centro);
							$("#txt_idupuesto").val(dataJson.idu_puesto);
							$("#txt_nompuesto").val(dataJson.nom_puesto);
							
							$("#txt_iduempleado2").prop("disabled", false);
							$("#txt_iduempleado2").focus();
							
							if(nRegistro!=0)//Es registro para editar
							{
								if($("#txt_iduempleado").val()!=nEmpleado)
								{
									nRegistro=0;
									nEmpleado = 0;
									nSuplente = 0;
									nIndefinido=0;
									estatus_seleccionado = 0;
									sFechaInicial = '';
									sFechaFinal='';
									
									$("#txt_iduempleado2").val("");
									$("#txt_nomempleado2").val("");
									$("#txt_iducentro2").val("");
									$("#txt_nomcentro2").val("");
									$("#txt_idupuesto2").val("");
									$("#txt_nompuesto2").val("");
									$("#txt_iduempleado2").focus();
								}
							}
							
							/* 11/12/2018
							   Se comenta el código para validar que el suplente 
							   tenga nivel jerárquico gerencial
							--------------------------------------------------------*/
							/*$.ajax({type: "POST",
								url: "ajax/json/json_ConsultaGerente.php",
								data: { 'empleado':iNumEmp },
								beforeSend:function(){},
								success:function(data){
									var dataJsonP = JSON.parse(data);
									if (dataJsonP.estado==0)
									{
										if(dataJsonP.tipo==1)// es gerente
										{
											$("#txt_nomempleado").val(dataJson.nom_empleado);
											$("#txt_iducentro").val(dataJson.idu_centro);
											$("#txt_nomcentro").val(dataJson.nom_centro);
											$("#txt_idupuesto").val(dataJson.idu_puesto);
											$("#txt_nompuesto").val(dataJson.nom_puesto);
											
											$("#txt_iduempleado2").prop("disabled", false);
											$("#txt_iduempleado2").focus();
											
											if(nRegistro!=0)//Es registro para editar
											{
												if($("#txt_iduempleado").val()!=nEmpleado)
												{
													nRegistro=0;
													nEmpleado = 0;
													nSuplente = 0;
													nIndefinido=0;
													estatus_seleccionado = 0;
													sFechaInicial = '';
													sFechaFinal='';
													
													$("#txt_iduempleado2").val("");
													$("#txt_nomempleado2").val("");
													$("#txt_iducentro2").val("");
													$("#txt_nomcentro2").val("");
													$("#txt_idupuesto2").val("");
													$("#txt_nompuesto2").val("");
													$("#txt_iduempleado2").focus();
												}
											}
										}
										else
										{
											showalert(LengStrMSG.idMSG433, "", "gritter-warning");
											$("#txt_iduempleado").val("");
											$("#txt_nomempleado").val("");
											$("#txt_iducentro").val("");
											$("#txt_nomcentro").val("");
											$("#txt_idupuesto").val("");
											$("#txt_nompuesto").val("");
											$("#txt_iduempleado").focus();
										}
									}
								},
								error:function onError(){},
								complete:function(){},
								timeout: function(){},
								abort: function(){}	
							});
							*/
							
						}	
						// callbackSuplentes();
					}
					else
					{
						if(dataJson.cancelado=='1')
						{
							showalert(LengStrMSG.idMSG135, "", "gritter-warning");
							$("#txt_iduempleado2").val("");
							$("#txt_nomempleado2").val("");
							$("#txt_iducentro2").val("");
							$("#txt_nomcentro2").val("");
							$("#txt_idupuesto2").val("");
							$("#txt_nompuesto2").val("");
							$("#txt_iduempleado2").focus();
						}
						else
						{
							/* 11/12/2018
							   Se comenta el código para validar que el suplente 
							   tenga nivel jerárquico gerencial
							--------------------------------------------------------*/
							$("#txt_nomempleado2").val(dataJson.nom_empleado);
							$("#txt_iducentro2").val(dataJson.idu_centro);
							$("#txt_nomcentro2").val(dataJson.nom_centro);
							$("#txt_idupuesto2").val(dataJson.idu_puesto);
							$("#txt_nompuesto2").val(dataJson.nom_puesto);
							
							/* $.ajax({type: "POST",
								url: "ajax/json/json_ConsultaGerente.php",
								data: { 'empleado':iNumEmp },
								beforeSend:function(){},
								success:function(data){
									var dataJsonP = JSON.parse(data);
									if (dataJsonP.estado==0)
									{
										if(dataJsonP.tipo==1)// es gerente
										{
											$("#txt_nomempleado2").val(dataJson.nom_empleado);
											$("#txt_iducentro2").val(dataJson.idu_centro);
											$("#txt_nomcentro2").val(dataJson.nom_centro);
											$("#txt_idupuesto2").val(dataJson.idu_puesto);
											$("#txt_nompuesto2").val(dataJson.nom_puesto);
											// callbackSuplentes();
										}	
										else
										{
											showalert(LengStrMSG.idMSG433, "", "gritter-warning");
											$("#txt_iduempleado2").val("");
											$("#txt_nomempleado2").val("");
											$("#txt_iducentro2").val("");
											$("#txt_nomcentro2").val("");
											$("#txt_idupuesto2").val("");
											$("#txt_nompuesto2").val("");
											$("#txt_iduempleado2").focus();
										}
									}	
									
								},
								error:function onError(){},
								complete:function(){},
								timeout: function(){},
								abort: function(){}	
							});	*/
						}	
					}	
				}
				else
				{
					showalert(LengStrMSG.idMSG136, "", "gritter-warning");
						
					//showmessage('No existe el número de empleado', '', undefined, undefined, function onclose(){
					if(tipo==1)
					{
						$("#txt_iduempleado").val("");
						$("#txt_nomempleado").val("");
						$("#txt_iducentro").val("");
						$("#txt_nomcentro").val("");
						$("#txt_idupuesto").val("");
						$("#txt_nompuesto").val("");
						$("#txt_iduempleado").focus();
						nRegistro=0;
					}
					else			
					{
						$("#txt_iduempleado2").val("");
						$("#txt_nomempleado2").val("");
						$("#txt_iducentro2").val("");
						$("#txt_nomcentro2").val("");
						$("#txt_idupuesto2").val("");
						$("#txt_nompuesto2").val("");
						$("#txt_iduempleado2").focus();
					}
				}
				
				callbackSuplentes();
			});	
		}
		else
		{
			if(tipo==1)
			{
				$("#txt_iduempleado").val("");
				$("#txt_nomempleado").val("");
				$("#txt_iducentro").val("");
				$("#txt_nomcentro").val("");
				$("#txt_idupuesto").val("");
				$("#txt_nompuesto").val("");
				$("#txt_iduempleado").focus();
				nRegistro=0;
			}
			else			
			{
				$("#txt_iduempleado2").val("");
				$("#txt_nomempleado2").val("");
				$("#txt_iducentro2").val("");
				$("#txt_nomcentro2").val("");
				$("#txt_idupuesto2").val("");
				$("#txt_nompuesto2").val("");
				$("#txt_iduempleado2").focus();
			}	
			callbackSuplentes();
		}	
	}
	//Guardar Suplente
	$('#btn_Otro').click(function(event)
	{
		
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).datepicker("setDate",new Date());
		
		$("#txt_iduempleado").val("");
		$("#txt_nomempleado").val("");
		$("#txt_iducentro").val("");
		$("#txt_nomcentro").val("");
		$("#txt_idupuesto").val("");
		$("#txt_nompuesto").val("");
		$("#txt_iduempleado").focus();
		$("#txt_iduempleado2").val("");
		$("#txt_nomempleado2").val("");
		$("#txt_iducentro2").val("");
		$("#txt_nomcentro2").val("");
		$("#txt_idupuesto2").val("");
		$("#txt_nompuesto2").val("");
		$("#txt_iduempleado2").prop("disabled", true);
		
		ConsultarSuplentes(1);
		$("#chkbx_indefinido").attr("checked","checked");
		$("#txt_FechaIni").prop('disabled',true);
		$("#txt_FechaFin").prop('disabled',true);
		
		nEditar=0, 
		nRegistro=0,
		nEmpleado = 0,
		nSuplente = 0,
		sFechaInicial='',
		sFechaFinal='',
		nIndefinido = 0;
		
		event.preventDefault();
	});
	
	$('#btn_guardar').click(function(event)
	{
		var chkIndefinido = 0;
		var id=nRegistro;
		var iEmpleado, iSuplente, sFechaIni, sFechaFin;
		if(nEditar == 0)
		{
			id = 0;
		}
		if($('#chkbx_indefinido').is(":checked"))
		{
			chkIndefinido=1;
		}
		if($("#txt_nomempleado").val() == "")
		{	
			showalert(LengStrMSG.idMSG137, "", "gritter-info");
			return;
		}
		else if($("#txt_nomempleado2").val() == "")
		{
			//showmessage('Proporcione el suplente', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG138, "", "gritter-info");
			return;
		}
		else if($("#txt_nomempleado2").val() == $("#txt_nomempleado").val())
		{
			//showmessage("El gerente no puede capturarse a si mismo como suplente.", '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG134, "", "gritter-warning");
			return;			
		}
		else
		{
			iEmpleado=$('#txt_iduempleado').val();
			iSuplente=$('#txt_iduempleado2').val();
			sFechaIni=formatearFecha($('#txt_FechaIni').val());
			sFechaFin=formatearFecha($('#txt_FechaFin').val());
			$.ajax({type: "POST", 
				url:'ajax/json/json_fun_grabar_suplente_colegiaturas.php?',
				data: {
					'iID':id,
					'iEmpleado':iEmpleado,
					'iEmpleadoSuplente' : iSuplente,
					'cFechaInicial': sFechaIni, 
					'cFechaFinal': sFechaFin,
					'iIdentificador':chkIndefinido,
					'session_name': Session
				}
			})
			.done(function(data){
				var dataJson = JSON.parse(data);	
				if(dataJson.estado == 0)
				{
					if(dataJson.mensaje == 1)
					{
						LimpiarFechas();
						GuardarBitacora(iEmpleado,iSuplente,sFechaIni,sFechaFin,chkIndefinido  );
						ConsultarSuplentes(0);
						nEditar=0;
						return;
					}
					else
					{
						//showmessage('Ya se encuentra capturado el suplente, favor de verificar...', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG139, "", "gritter-info");
					}
				}
				else
				{
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
					//error
					showalert(LengStrMSG.idMSG230+ ' el suplente', "", "gritter-info");
				}
			});
		}
		event.preventDefault();
	});
	
	function GuardarBitacora(iNumEmp, iSuplente, sFechaIni, sFechaFin, iIndefinido)
	{
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_grabar_bitacora_suplentes.php?',
			data: { 
				'iEmpleado':iNumEmp,
				'iEmpleadoSuplente' : iSuplente,
				'cFechaInicial': sFechaIni, 
				'cFechaFinal': sFechaFin,
				'iIdentificador':iIndefinido,
				'iCancelado':0,
				'iEmpleadoCancela':0,
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);	
			if(dataJson.estado == 0)
			{
				  //showmessage('Suplente guardado correctamente...', '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG140, "","gritter-success"); 
				
				$("#txt_iduempleado2").val("");
				$("#txt_nomempleado2").val("");
				$("#txt_iducentro2").val("");
				$("#txt_nomcentro2").val("");
				$("#txt_idupuesto2").val("");
				$("#txt_nompuesto2").val(""); 
				//$("#chkbx_indefinido").removeAttr("checked");
				$("#chkbx_indefinido").attr("checked","checked");
				$("#txt_iduempleado").focus();
				
				$("#txt_FechaIni").prop('disabled',false);
				$("#txt_FechaFin").prop('disabled',false);
				
				
			}
			else
			{
				//error
				showalert(LengStrMSG.idMSG230 +" el suplente", "", "gritter-info");
			}
		});
	}
	function recorrerGrid() {
		var arr_cancelar = [];
		for(var i = 0; i < $("#gridSuplentes-table").find("tr").length - 1; i++) {
			var jdata = $("#gridSuplentes-table").jqGrid('getRowData',i);
			if ( jdata.marcado == 1 ) {
				obj = {'id' : jdata.idu_id};
				arr_cancelar.push(obj);
			}
		}
		var dataJson = JSON.stringify(arr_cancelar);
		return dataJson;
	}	
	function recorrerGridModificar()
	{
		var arr_cancelar = [];
		for(var i = 0; i < $("#gridSuplentes-table").find("tr").length - 1; i++) {
			var jdata = $("#gridSuplentes-table").jqGrid('getRowData',i);
			if ( jdata.marcado == 1 ) {
				obj = {'id' : jdata.idu_id,
				'empleado': jdata.idu_empleado,
				'suplente': jdata.idu_suplente,
				'indefinido': jdata.opc_indefinido,
				'fechaIni': jdata.fec_inicial,
				'fechaFin': jdata.fec_final
				};
				arr_cancelar.push(obj);
			}
		}
		if(arr_cancelar.length==1)
		{
			nRegistro =arr_cancelar[0].id;
			nEmpleado = arr_cancelar[0].empleado;
			nSuplente =arr_cancelar[0].suplente;
			
			nIndefinido=arr_cancelar[0].indefinido;
			sFechaInicial = arr_cancelar[0].fechaIni;
			sFechaFinal = arr_cancelar[0].fechaFin;
			nEditar=1;
		}
		else
		{
			nEditar=0;
		}
		return JSON.stringify(arr_cancelar);
	}
	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 391
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
});
