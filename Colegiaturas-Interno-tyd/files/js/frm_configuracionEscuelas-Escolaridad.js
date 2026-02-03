$(function(){
	ConsultaClaveHCM()
	var rfc_clave_sep='';
	var nom_escuela='';
	var idu_escolaridad='';
	var idu_tipo_deduccion = 1;
	var idu_escuela=0;
	var idu_carrera=0;
	var tipo_escuela=0;
	var observaciones='';
	var opc_escuela_bloqueada=0;
	var si_bloqueada='';
	var no_bloqueada='';
	var estatus_bloqueo = 0;
	var tipo_edu=0;
	var iConsultar=0;
	var opc_pdf=0, opc_especial=0, opc_nota=0;
	obtenerEstados();
	Obtenercombo();
	// $('#chkbx_pdf').prop('disabled', 'disabled');
	// $('#radioPrivada').prop('checked', true);

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
	
	

//********************** COMBOS DEL MODAL AGREGAR ESCUELA *********************
$("#cbo_estado_agregar").chosen({no_results_text: 'NO SE ENCUENTRA',width: '350px'});
$("#cbo_municipio_agregar").chosen({no_results_text: 'NO SE ENCUENTRA',width: '350px'});	
$("#cbo_localidad_agregar").chosen({no_results_text: 'NO SE ENCUENTRA',width: '350px'});
$("#cbo_escolaridad_agregar").chosen({no_results_text: 'NO SE ENCUENTRA',width: '200px'});
$("#cbo_carrera").chosen({no_results_text: 'NO SE ENCUENTRA',width: '200px'});
//*****************************************************************************
//********************** COMBOS PANTALLA PRINCIPAL ****************************
$("#cbo_estado").chosen({no_results_text: 'NO SE ENCUENTRA',width: '350px'});
$("#cbo_municipio").chosen({no_results_text: 'NO SE ENCUENTRA',width: '350px'});
$("#cbo_localidad").chosen({no_results_text: 'NO SE ENCUENTRA',width: '350px'});
$("#cbo_tipoEscuela").chosen({no_results_text: 'NO SE ENCUENTRA',width: '200px'});
$("#cbo_tipoBusqueda").chosen({no_results_text: 'NO SE ENCUENTRA',width: '200px'});
//*****************************************************************************
	
	///////////////////////GRID////////////////////////////
	cargarGridEscuelas(true);
	
	//CARGAR LISTADO CARRERAS
	idu_escuela=1;
	//idu_escolaridad=7;
	fnConsultaListadoCarreras();
	stopScrolling(function(){
		draggablesModal();
	});
	
	function stopScrolling(callback){
		$("#dlg_Observaciones").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_Agregar").on("show.bs.modal", function () {
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
	
	$("#cbo_escolaridad_agregar").change(function(){ //----> Combo Escolaridad Modal (Agregar Escuela)
		var nCarrera=$("#cbo_escolaridad_agregar").children(":selected").attr("opc_carrera");
		//console.log(nCarrera);
		if(nCarrera==1)//Mostrar carreras
		{
			$("#cbo_carrera").prop('disabled',false);
			$("#cbo_carrera").trigger("chosen:updated");														
			
		}
		else{
			$("#cbo_carrera").prop('disabled',true);
			$("#cbo_carrera").val(0);
			$("#cbo_carrera").trigger("chosen:updated");	
		}
	});
	function fnConsultaListadoCarreras() {
		var option="<option value='0'> SELECCIONE</option>";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_carreras.php",
			data: { 
				'idu_escuela':idu_escuela
				//'idu_escolaridad':idu_escolaridad
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
				
					for(var i=0;i<dataJson.datos.length; i++) {
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_carrera").trigger("chosen:updated").html(option);
					$("#cbo_carrera").trigger("chosen:updated");
					
				}
				else
				{
					//showalert(dataJson.mensaje, "", "gritter-warning");
					showalert(LengStrMSG.idMSG88+" los tipos de carreras", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
	}

	function cargarGridEscuelas(inicializar){
		var cUrl = "";
		if (!inicializar) {
			// cUrl = "ajax/json/json_fun_obtener_escuelas_escolaridad.php?";
			// cUrl += "opc_tipo_escuela="+$('#cbo_tipoEscuela').val();
			// cUrl += "&term=" + $('#txt_escuela').val() + "&";
			sUrl = 'ajax/json/json_fun_obtener_escuelas_colegiaturas.php?'
			sUrl += 'iEstado='+ $('#cbo_estado').val()+'&';
			sUrl += 'iMunicipio='+ $('#cbo_municipio').val()+'&';
			sUrl += 'iLocalidad='+$('#cbo_localidad').val()+'&';
			sUrl += 'iBusqueda='+ $('#cbo_tipoBusqueda').val()+'&';
			sUrl += 'sBuscar='+ $('#txt_escuela').val().replace('/^\s+|\s+$/g', '').toUpperCase()+'&';
			sUrl += 'iTipoEscuela='+ $('#cbo_tipoEscuela').val()+'&';
			sUrl += 'iConfiguracion=1&';
			sUrl += 'iOpcion=2&';
		}
		
		jQuery("#gridEscuelas-table").jqGrid('GridUnload');
		jQuery("#gridEscuelas-table").jqGrid({
			url:cUrl,
			datatype: 'json',
			colNames:LengStr.idMSG5,		
			colModel:[
				{name:'idu_escuela',			index:'idu_escuela', 			width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'rfc_clave_sep',			index:'rfc_clave_sep',			width:120, sortable: false,	align:"left",	fixed: true},
				{name:'nom_escuela',			index:'nom_escuela',			width:350, sortable: false,	align:"left",	fixed: true},				
				{name:'nom_tipo_escuela',		index:'nom_tipo_escuela', 		width:100, sortable: false,	align:"left",	fixed: true},	
				{name:'des_tipo_deduccion',		index:'des_tipo_deduccion', 	width:150, sortable: false,	align:"left",	fixed: true, hidden: true},			
				{name:'nom_escolaridad',		index:'nom_escolaridad',		width:120, sortable: false,	align:"left",	fixed: true},		
				{name:'des_tipo_carrera',		index:'des_tipo_carrera',		width:150, sortable: false,	align:"left",	fixed: true, hidden: false},
				{name:'escuela_especial',		index:'escuela_especial',		width:80,  sortable: false,	align:"center",	fixed: true},
				{name:'obligatorio_pdf',		index:'obligatorio_pdf',		width:80,  sortable: false,	align:"center",	fixed: true},
				{name:'nota_credito',			index:'nota_credito',			width:80,  sortable: false,	align:"center",	fixed: true},
				{name:'escuela_bloqueada',		index:'escuela_bloqueada',		width:80,  sortable: false,	align:"center",	fixed: true},
				{name:'fec_registro',			index:'fec_registro',			width:100, sortable: false,	align:"left",	fixed: true},
				{name:'empleado_registro',		index:'empleado_registro',		width:350, sortable: false,	align:"left",	fixed: true},
				{name:'idu_tipo_escuela',		index:'idu_tipo_escuela',		width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'idu_escolaridad',		index:'idu_escolaridad',		width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'opc_educacion_especial',	index:'opc_educacion_especial', width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'opc_obligatorio_pdf',	index:'opc_obligatorio_pdf',	width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'opc_nota',				index:'opc_nota',				width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'opc_escuela_bloqueada',	index:'opc_escuela_bloqueada',	width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'observaciones',			index:'observaciones',			width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'idu_tipo_deduccion',		index:'idu_tipo_deduccion',		width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'idu_tipo_carrera',		index:'idu_tipo_carrera',		width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'clave_sep',				index:'clave_sep',				width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'idu_estado',				index:'idu_estado',				width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_estado',				index:'nom_estado',				width:200, sortable: false,	align:"left",	fixed: true, hidden:false},
				{name:'idu_municipio',			index:'idu_municipio',			width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_municipio',			index:'nom_municipio',			width:200, sortable: false,	align:"left",	fixed: true, hidden:false},
				{name:'idu_localidad',			index:'idu_localidad',			width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'nom_localidad',			index:'nom_localidad',			width:350, sortable: false,	align:"left",	fixed: true, hidden:false}
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 400,
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gridEscuelas-pager',
			sortname: 'idu_escuela',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			caption: 'Escuelas',
			loadComplete: function (Data) {
				var registros = jQuery("#gridEscuelas-table").jqGrid('getGridParam', 'reccount');
				
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}	
				
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id)
			{	
				if (id >= 0) {
					var rowData = jQuery(this).getRowData(id);
					idu_escuela =rowData.idu_escuela;
					rfc_clave_sep=rowData.rfc_clave_sep;
					nom_escuela=rowData.nom_escuela;
					idu_escolaridad=rowData.idu_escolaridad;
					idu_carrera=rowData.idu_tipo_carrera;
					idu_tipo_deduccion=rowData.idu_tipo_deduccion;
					tipoescuela=rowData.idu_tipo_escuela;
					observaciones=rowData.observaciones;
					opc_especial=rowData.opc_educacion_especial;
					opc_pdf=rowData.opc_obligatorio_pdf;
					opc_nota=rowData.opc_nota;
					$("#txt_Motivo").val(observaciones);
					estatus_bloqueo=rowData.escuela_bloqueada;
					//console.log(rowData.escuela_bloqueada);
				}
			},				
		});	
		
		barButtongrid(
		{
			pagId:"#gridEscuelas-pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-plus blue bigger-140",	
				title:'Agregar escuela',
				click: function(event){
					$("#Titulo_Modal").html("<i class=\"icon-file-text-alt\"></i>&nbsp;Agregar Escuela");
					limpiarDatosModal();
					$("#dlg_Agregar").modal('show');
					event.preventDefault();
				}
			},
			{
				icon:"icon-edit orange bigger-140",	
				title:'Editar escuela',
				click: function(event)
				{
					$("#Titulo_Modal").html("<i class=\"icon-edit\"></i>&nbsp;Modificar Escuela");
					var selr = jQuery('#gridEscuelas-table').jqGrid('getGridParam','selrow');
					if(selr){
						iEstado = jQuery('#gridEscuelas-table').jqGrid ('getCell', selr, 'idu_estado');
						iMunicipio = jQuery('#gridEscuelas-table').jqGrid ('getCell', selr, 'idu_municipio');
						iLocalidad = jQuery('#gridEscuelas-table').jqGrid('getCell', selr, 'idu_localidad');
						// iCarrera = jQuery('#gridEscuelas-table').jqGrid('getCell', selr, 'idu_localidad');
						
						if(iEstado != 0){
							showalert("Solo puede modificar escuelas extranjeras/en linea", "", "gritter-info");
							return;
						}
					
						obtenerEstadosModal( $("#cbo_estado_agregar"), function() {
							$("#cbo_estado_agregar").val(iEstado);
							$("#cbo_estado_agregar").trigger("chosen:updated");
							actualizarMunicipiosModal(iEstado, $("#cbo_municipio_agregar"), function(){
								$("#cbo_municipio_agregar").val(iMunicipio);
								$("#cbo_municipio_agregar").trigger("chosen:updated");
								actualizarLocalidadesModal(iMunicipio,$("#cbo_localidad_agregar"), function(){
									$("#cbo_localidad_agregar").val(iLocalidad);
									$("#cbo_localidad_agregar").trigger("chosen:updated");
								});
							});
						});
					
						$("#txt_RFC").val(rfc_clave_sep);
						$("#txt_nombre").val(nom_escuela);
					
						$("#cbo_escolaridad_agregar").val(idu_escolaridad);
						$("#cbo_escolaridad_agregar").trigger("chosen:updated");
						$("#cbo_carrera").val(idu_carrera);
						$("#cbo_carrera").trigger("chosen:updated");
						$("#cbo_deduccion").val(idu_tipo_deduccion);
						$("#txt_Motivos").val(observaciones);
					
						if(tipoescuela==1){
							$("#radioPublica").prop('checked', 'checked');
						}	
						else{
							$("#radioPrivada").prop('checked', 'checked');
						}
						if(opc_especial==1){
							$("#chkbx_eduEspecial").prop('checked','checked');
						}else{
							$("#chkbx_eduEspecial").prop('checked',false);
						}
						if(	opc_pdf==1){
							$("#chkbx_pdf").prop('checked','checked');
						}else{
							$("#chkbx_pdf").prop('checked',false);
						}
						if(opc_nota==1){
							$("#chkbx_notaCredito").prop('checked','checked');
						}else{
							$("#chkbx_notaCredito").prop('checked',false);
						}
						if($("#cbo_escolaridad_agregar").children(":selected").attr("opc_carrera")==1){//Mostrar carreras
							$("#cbo_carrera").prop('disabled',false);
							$("#cbo_carrera").trigger("chosen:updated");
						}else{
							$("#cbo_carrera").prop('disabled',true);
							$("#cbo_carrera").val(0);
							$("#cbo_carrera").trigger("chosen:updated");
						}
						$("#cbo_estado_agregar").prop('disabled', true);
						$("#cbo_municipio_agregar").prop('disabled', true);
						$("#cbo_localidad_agregar").prop('disabled', true);
						$("#dlg_Agregar").modal('show');
					
					}else{
						//message('Seleccione la escuela a modificar', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG141, "", "gritter-info");
					}
					event.preventDefault();
				}
			},
			{
				icon:"icon-lock red bigger-140",	
				title:'Bloquear / Desbloquear escuela',
				click: function(event)
				{
					var selr = jQuery("#gridEscuelas-table").jqGrid('getGridParam', 'selrow');
					var bloqueada=0;
					
					if(selr == null)
					{	
						//message('Seleccione al menos una escuela', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG143, "", "gritter-info");
					}
					else
					{	
						var rowData = jQuery("#gridEscuelas-table").getRowData(selr);
						bloqueada=rowData.opc_escuela_bloqueada;
						if(bloqueada==0)
						{
							bootbox.confirm(LengStrMSG.idMSG142,
								function(result){
								if (result){
								
									$("#txt_Motivos").val("");
									$("#dlg_Observaciones").modal('show');
								}
							});	
						}
						else
						{
							$("#txt_Motivos").val("");
							$("#dlg_Observaciones").modal('show');
						}	
					}
					event.preventDefault();
				}
			
			}]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
		setSizeBtnGrid('id_button2',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
///////////////////ACTUALIZAR GRID////////////////////////
	function ActualizarGrid()
	{
		// if ( $.trim( $("#txt_escuela").val() ) == '' ) {
			// if(iConsultar==1)
			// {
				// showalert(LengStrMSG.idMSG144, "", "gritter-info");
				// $("#txt_escuela").focus();
			// }	
		// } else if ( $.trim( $("#txt_escuela").val() ).length < 3 ) {
			// if(iConsultar==1)
			// {
				// showalert(LengStrMSG.idMSG145, "", "gritter-info");
				// $("#txt_escuela").focus();
			// }
			// if($("#cbo_estado").val() == 0){
				// $("#cbo_municipio").val(0);
				// $("#cbo_localidad").val(0);
			// }
		// } else {
			
			var sUrl = 'ajax/json/json_fun_obtener_escuelas_colegiaturas.php?'
			sUrl += 'iEstado='+ $('#cbo_estado').val()+'&';
			sUrl += 'iMunicipio='+ $('#cbo_municipio').val()+'&';
			sUrl += 'iLocalidad='+ $('#cbo_localidad').val()+'&'; // prueba
			sUrl += 'iBusqueda='+ $('#cbo_tipoBusqueda').val()+'&';
			sUrl += 'sBuscar='+ $('#txt_escuela').val().replace('/^\s+|\s+$/g', '').toUpperCase()+'&';
			sUrl += 'iTipoEscuela='+ $('#cbo_tipoEscuela').val()+'&';
			sUrl += 'iConfiguracion=1&';
			sUrl += 'iOpcion=2&';
			
			$("#gridEscuelas-table").jqGrid('setGridParam', {
				url: sUrl
			}).trigger("reloadGrid");
		// }
		iConsultar=0;
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

	//////////Acción de botones de modal dlg_Agregar
	$("#btn_aceptarmod").click(function(event){
		//$("#gridEscuelas-table").jqGrid('clearGridData');
		 Valida_GuardarActualizar();
		 
		 event.preventDefault();
	});
	
	$("#btn_salirmod").click(function(event){
		 $("#dlg_Agregar").modal('hide');
		 event.preventDefault();
	});
	
	//////////Acción de botones de modal dlg_observaciones
	$("#btn_aceptar_observaciones").click(function(event){
		if($("#txt_Motivos").val().replace('/^\s+|\s+$/g', '')!="")
		{
			Bloquea_desbloquea_Escuela();
			$("#dlg_Observaciones").modal('hide');
		}
		else
		{
			showalert(LengStrMSG.idMSG233, "", "gritter-info");
			$("#txt_Motivos").focus();
		}	
		 event.preventDefault();
	});
	
	$("#btn_salir_observaciones").click(function(event){
		 $("#dlg_Observaciones").modal('hide');
		 event.preventDefault();
	});
		
	/////////////RADIO BUTTON////////////////////
	$("#radioPublica").click(function(event){
		$("#chkbx_eduEspecial").prop('checked',false);
		$('#chkbx_pdf').prop('disabled', 'disabled');
		$("#chkbx_pdf").prop('checked',false);
	});
	
	$("#radioPrivada").click(function(event){
		$("#chkbx_eduEspecial").prop('checked',false);
		$("#chkbx_pdf").prop('checked','checked');
		$("#chkbx_pdf").removeAttr("disabled");		
	});
	
	////////////Validar si existe RFC escuela, modal dlg_Agregar //////////
	$("#txt_RFC").keydown(function(evt){
		//console.log(evt.which);
		var tecla = (evt.which) ? evt.which : (document.all)?event.keyCode:evt.keyCode;
		if(tecla == 13 /*|| tecla == 9*/)
		{
			if($("#txt_RFC").val().replace('/^\s+|\s+$/g', '') == ''){
				showalert("Proporcione RFC/Clave SEP", "", "gritter-info");
				$("#txt_RFC").val('');
				$("#txt_RFC").focus();
			}else{
				ValidaRfcEscuela();
			}
		}
	});
	$("#txt_RFC").focusout(function(evt){
		if($("#txt_RFC").val().replace('/^\s+|\s+$/g', '') == ''){
			showalert("Proporcione RFC/Clave SEP", "", "gritter-info");
			$("#txt_RFC").val()== '';
			$("#txt_RFC").focus();
		}else{
			ValidaRfcEscuela();
		}

	});
	function ValidaRfcEscuela()
	{
		$.ajax({type: "POST", 
		url:'ajax/json/json_fun_consultar_escuela_rfc.php?',
		data: { 
			'nOpcion':1,
			'cRFCescuela':$("#txt_RFC").val(),
			session_name: Session
		}
		}).done(function(data){
			json = json_decode(data);
			
			if (json.datos.length >0)
			{
				//message("RFC ingresado ya existe");
				showalert(LengStrMSG.idMSG234, "", "gritter-info");
			}			
		});		
		
	}	
	////////////LIMPIAR DATOS DEL MODAL//////////
	function limpiarDatosModal(){
		$("#txt_RFC").val('');
		$("#txt_nombre").val('');
		$("#cbo_escolaridad_agregar").val(0);
		$("#cbo_escolaridad_agregar").trigger("chosen:updated");	
		$("#cbo_deduccion").val(0);
		$("#txt_nombre").val('');
		$("#txt_Motivos").val('');
		//$("#radioPublica").prop('checked', 'checked');
		$("#radioPrivada").prop('checked', 'checked');
		$("#chkbx_eduEspecial").prop('checked',false);
		$("#chkbx_pdf").prop('checked',false);
		$("#chkbx_notaCredito").prop('checked',false);
		$("#cbo_carrera").prop('disabled',true);
		$("#cbo_carrera").val(0);		
		$("#cbo_carrera").trigger("chosen:updated");
		
		idu_escuela=0;
		
		obtenerEstadosModal( $("#cbo_estado_agregar"), function(){
			actualizarMunicipiosModal( 0, $("#cbo_municipio_agregar"), function(){
				actualizarLocalidadesModal( 0, $("#cbo_localidad_agregar") );
			});
		});
	}	
		
/////////////GUARDAR/ACTUALIZAR/////////////////////////////////////
	function Valida_GuardarActualizar(){		
		
		// if ($('#radioPublica').prop('checked')==true){
			// tipo_escuela = 1;
			
		// }else{			
			tipo_escuela = 2;			
		// }
		
		if ($("#chkbx_eduEspecial").prop('checked')==true){
			tipo_edu=1;
		}else{
			tipo_edu=0;
		}
		
		if ($("#chkbx_pdf").prop('checked')==true){
			opc_pdf=1;
		}else{
			opc_pdf=0;
		}
		if ($("#chkbx_notaCredito").prop('checked')==true){
			opc_nota=1;
		}else{
			opc_nota=0;
		}
		// if($("#cbo_estado_agregar").val() == 0){
			// $("#cbo_municipio_agregar").val(0);
			// $("#cbo_municipio_agregar").trigger("chosen:updated");
			// $("#cbo_localidad_agregar").val(0);
			// $("#cbo_localidad_agregar").trigger("chosen:updated");
		// }
		if ( $("#cbo_estado_agregar").val() == -1 ) {
			// showalert(LengStrMSG.idMSG146, "", "gritter-info");			
			showalert("Seleccione el estado al que corresponde la escuela", "", "gritter-info");			
			$("#cbo_estado_agregar").focus();
			return false;
		} else if ( $("#cbo_municipio_agregar").val() == -1 ) {
			// showalert(LengStrMSG.idMSG147, "", "gritter-info");
			showalert("Seleccione el municipio al que corresponde la escuela", "", "gritter-info");
			$("#cbo_municipio_agregar").focus();
			return false;
		} else if($("#cbo_localidad_agregar").val() == -1){
			showalert("Seleccione la localidad a la que corresponde la escuela","","gritter-info");
			$("#cbo_localidad_agregar").focus();
			return false;
		}else	if ($('#txt_RFC').val().length == 0)
		{
			//showmessage('Proporcione RFC/Clave SEP', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG148, "", "gritter-info");		
			$("#txt_RFC").focus();
			return false;
		}
		else if($("#txt_RFC").val().replace('/^\s+|\s+$/g', '') == '' || $("#txt_RFC").val().length < 12){
			//showmessage('Proporcione RFC/Clave SEP', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG148, "", "gritter-info");		
			$("#txt_RFC").focus();
			return false;
		}
		else if ($('#txt_nombre').val().length == 0 || $('#txt_nombre').val().length < 3)
		{
			//showmessage('Proporcione nombre', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG149, "", "gritter-info");	
			$("#txt_nombre").focus();
			return false;
		}	
		else if ($('#cbo_escolaridad_agregar').val() == 0)
		{
			//showmessage('Proporcione escolaridad', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG150, "", "gritter-info");
			return false;
		}
		else if($("#cbo_escolaridad_agregar").children(":selected").attr("opc_carrera")==1)
		{
			if($("#cbo_carrera").val()==0)
			{
				showalert("Seleccione carrera", "", "gritter-info");
				return false
			}
		}
		
		//else{
			$.ajax({type: "POST",
				data: {
					'session_name':Session, 					
					'idu_escuela':		idu_escuela, 
					'tipoescuela':		tipo_escuela,
					'iEstado'    : 		$("#cbo_estado_agregar").val(),
					'iMunicipio' : 		$("#cbo_municipio_agregar").val(),
					'iLocalidad' :		$("#cbo_localidad_agregar").val(),
					'RFC'        :		$('#txt_RFC').val().toUpperCase(), 
					'nombre'	 :		$('#txt_nombre').val().toUpperCase(), 
					'escolaridad':		$('#cbo_escolaridad_agregar').val(),
					'idu_tipo_deduccion': idu_tipo_deduccion,
					'idu_Carrera':		$('#cbo_carrera').val(), 
					'eduEspecial':		tipo_edu, 
					'pdf'		 :		opc_pdf, 
					'opc_notaCredito':	opc_nota,
					'Motivo'	 :		$('#txt_Motivos').val().toUpperCase(),
					'escuela_bloqueada':1
				},
				url: 'ajax/json/json_fun_grabar_escuela_escolaridad.php'})
				.done(function(data){
						json = json_decode(data);

						if(json.estado==0)
						{
							//case when estado = 1 then 'Los datos se actualizaron' when estado = 2 then 'La escuela con esa escolaridad ya existe, favor de verificar' else 'Los datos se guardaron' END
							showalert(LengStrMSG.idMSG152, "", "gritter-success");
						}
						else if(json.estado==1)	
						{
							showalert(LengStrMSG.idMSG153, "", "gritter-success");
						}
						else if(json.estado==2)	
						{
							showalert(LengStrMSG.idMSG154, "", "gritter-success");
						}
						else
						{	//falta error al guardar
							showalert(LengStrMSG.idMSG230+" la escuela", "", "gritter-error");
						}
						$("#gridEscuelas-table").jqGrid('clearGridData');
						$("#txt_Motivo").val('');
						$("#dlg_Agregar").modal('hide');
						// ActualizarGrid();
						limpiarDatosModal();
					})
				.fail(function(s) {
						//message('Error al cargar ajax/json/json_fun_grabar_escuela_escolaridad.php', '', undefined, undefined, function onclose(){});
							showalert(LengStrMSG.idMSG230+" la escuela", "", "gritter-error");
					})
				.always(function() {});
		//}	
	}
		
///////////////////BOTON AGREGAR////////////////////////////////////
	$('#btn_agregar').click(function(event){
		limpiarDatosModal();
		
		$("#dlg_Agregar").modal('show');
		event.preventDefault();
	});

//	---------------------------------------------------------COMBOS PANTALLA PRINCIPAL-----------------------------------------------------------------			
//////////////////COMBO ESTADOS///////////////////////////////
	$("#cbo_estado").trigger("chosen:updated");
	function obtenerEstados(){
		$("#cbo_estado").html("");
		$.ajax({type:'POST',
			url:"ajax/json/json_fun_obtener_estados_escolares.php",
			data:{},
			beforeSend:function(){
				waitwindow('Obteniendo listado de Estados', 'open');
			},
			success:function(data){
				waitwindow('', 'close');
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='-1'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_estado").html(option);
					$("#cbo_estado").trigger("chosen:updated");
				} else {
					//error
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
				}
			},
			error:function onError(){
				waitwindow('', 'close');
				showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
			},
			complete:function(){
				waitwindow('', 'close');
			},
			timeout: function(){
				waitwindow('', 'close');
			},
			abort: function(){
				waitwindow('', 'close');
			}
		});
	}	
	
//////////////////COMBO MUNICIPIOS///////////////////////////////
	$("#cbo_municipio").trigger("chosen:updated");
	function actualizarMunicipios(){
		$("#cbo_municipio").html("");
		var option ="";
		if ( $("#cbo_estado").val() == -1 ) {
			option = "<option value='-1'>SELECCIONE</option>";
			$("#cbo_municipio").html(option);
			$("#cbo_municipio").trigger("chosen:updated");
		} else {
			$.ajax({type:'POST',
				url:"ajax/json/json_fun_obtener_municipios_escolares.php",
				data:{
					//'iEstado' : $("#cbo_estado").val()
					'iEstado' : DOMPurify.sanitize($("#cbo_estado").val())
				},
				beforeSend:function(){
					waitwindow('Actualizando municipios', 'open');
				},
				success:function(data){
					waitwindow('', 'close');
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0) {
						option = "<option value='-1'>SELECCIONE</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						$("#cbo_municipio").html(option);
						$("#cbo_municipio").trigger("chosen:updated");
					} else {
						//error
						showalert(LengStrMSG.idMSG88+" los municipios", "", "gritter-error");
					}
				},
				error:function onError(){
					waitwindow('', 'close');
					showalert(LengStrMSG.idMSG88+" los municipios", "", "gritter-error");
				},
				complete:function(){
					waitwindow('', 'close');
				},
				timeout: function(){
					waitwindow('', 'close');
				},
				abort: function(){
					waitwindow('', 'close');
				}
			});
		}
	}	
//////////////////COMBO LOCALIDADES///////////////////////////////
$("#cbo_localidad").trigger("chosen:updated");
	function actualizarLocalidades(){
		$("#cbo_localidad").html("");
		var option="";
		if($("#cbo_municipio").val() == -1){
			var option = "<option value='-1'>SELECCIONE</option>";
			$("#cbo_localidad").html(option);
			$("#cbo_localidad").trigger("chosen:updated");
		}else{
			$.ajax({type:'POST',
				url:"ajax/json/json_fun_obtener_localidades_escolares.php",
				data:{
					//'iMunicipio': $("#cbo_municipio").val(),
					//'iEstado'	: $("#cbo_estado").val(),
					'iMunicipio': DOMPurify.sanitize($("#cbo_municipio").val()),
					'iEstado'	: DOMPurify.sanitize($("#cbo_estado").val()),
				},
				beforeSend:function(){
					waitwindow('Actualizando localidades', 'open');
				},
				success:function(data){
					waitwindow('', 'close');
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0) {
						var option = "<option value='-1'>SELECCIONE</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						$("#cbo_localidad").html(option);
						$("#cbo_localidad").trigger("chosen:updated");
						
					}else{
						showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
					}
				},
				error:function onError(){
					waitwindow('', 'close');
					showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
				},
				complete:function(){
					waitwindow('', 'close');
				},
				timeout: function(){
					waitwindow('', 'close');
				},
				abort: function(){
					waitwindow('', 'close');
				}
			});
		}
	}
	//////////////////COMBO ESTADOS MODAL///////////////////////////////
	$("#cbo_estado_agregar").trigger("chosen:updated");
	function obtenerEstadosModal( comboEstados, callback ){
		comboEstados.html("");
		$.ajax({type:'POST',
			url:"ajax/json/json_fun_obtener_estados_escolares.php",
			data:{},
			beforeSend:function(){
				waitwindow('Obteniendo listado de Estados', 'open');
			},
			success:function(data){
				waitwindow('', 'close');
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) 
				{
					
					var option = "<option value='-1'>SELECCIONE</option>";
					for(var i in dataJson.datos){
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					comboEstados.html(option);
					comboEstados.val(-1);
					comboEstados.trigger("chosen:updated");
					
					if (callback != undefined) {
						callback();
					}
				} else {
					//error
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
				}
			},
			error:function onError(){
				waitwindow('', 'close');
				showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-error");
			},
			complete:function(){
				waitwindow('', 'close');
			},
			timeout: function(){
				waitwindow('', 'close');
			},
			abort: function(){
				waitwindow('', 'close');
			}
		});
	}
	$("#cbo_estado_agregar").change(function(event){
		//actualizarMunicipiosModal( $("#cbo_estado_agregar").val(), $("#cbo_municipio_agregar") );
		actualizarMunicipiosModal( DOMPurify.sanitize($("#cbo_estado_agregar").val()), $("#cbo_municipio_agregar") );
		$("#cbo_localidad_agregar").html("");
		$("#cbo_localidad_agregar").trigger("chosen:updated");
		event.preventDefault();
		//console.log($("#cbo_municipio_agregar").val());
	});	
// **************************COMBO MUNICIPIOS MODAL****************************	
	$("#cbo_municipio_agregar").trigger("chosen:updated");
	function actualizarMunicipiosModal( iEstado, comboMunicipios, callback ){
		comboMunicipios.html("");
		//if ( iEstado == -1 /*|| iEstado == 0*/ ) {
		if ( $("#cbo_estado_agregar").val() == -1 /*|| iEstado == 0*/ ) {
			var option = "<option value='-1'>SELECCIONE</option>";
			comboMunicipios.html(option);
			comboMunicipios.trigger("chosen:updated");
			if (callback != undefined) {
				callback();
			}
		} else {
			$.ajax({type:'POST',
				url:"ajax/json/json_fun_obtener_municipios_escolares.php",
				data:{
					'iEstado' : iEstado
				},
				beforeSend:function(){
					waitwindow('Actualizando municipios', 'open');
				},
				success:function(data){
					waitwindow('', 'close');
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0) {
						var option = "<option value='-1'>SELECCIONE</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						comboMunicipios.html(option);
						
						if (callback != undefined) {
							callback();
						} else {
							comboMunicipios.trigger("chosen:updated");
						}
					} else {
					//error
						showalert(LengStrMSG.idMSG88+ " los municipios", "", "gritter-error");
					}
				},
				error:function onError(){
					waitwindow('', 'close');
					showalert(LengStrMSG.idMSG88+" los municipios", "", "gritter-error");
				},
				complete:function(){
					waitwindow('', 'close');
				},
				timeout: function(){
					waitwindow('', 'close');
				},
				abort: function(){
					waitwindow('', 'close');
				}
			});
		}
	}
	$("#cbo_municipio_agregar").change(function(event){
		//actualizarLocalidadesModal( $("#cbo_municipio_agregar").val(), $("#cbo_localidad_agregar") );
		actualizarLocalidadesModal( DOMPurify.sanitize($("#cbo_municipio_agregar").val()), $("#cbo_localidad_agregar") );
		event.preventDefault();
	});	
// *****************************COMBO LOCALIDADES MODAL*************************	
	$("#cbo_localidad_agregar").trigger("chosen:updated");
	function actualizarLocalidadesModal(iMunicipio, comboLocalidades, callback){
		comboLocalidades.html("");
		if( $("#cbo_municipio_agregar").val() == -1 /*||  $("#cbo_estado_agregar").val() == 0*/  ){
			var option = "<option value='-1'> SELECCIONE</option>";
			comboLocalidades.html(option);
			comboLocalidades.trigger("chosen:updated");
			
			if (callback != undefined) {
				callback();
			}
		}else{
			$.ajax({type:'POST',
				url:"ajax/json/json_fun_obtener_localidades_escolares.php",
				data:{
					'iMunicipio': iMunicipio,
					//'iEstado'	: $("#cbo_estado_agregar").val(),
					'iEstado'	: DOMPurify.sanitize($("#cbo_estado_agregar").val()),
				},
				beforeSend:function(){
					waitwindow('Actualizando localidades', 'open');
				},
				success:function(data){
					waitwindow('', 'close');
					var sanitizedData = limpiarCadena(data);
					var dataJson = JSON.parse(sanitizedData);
					if(dataJson.estado == 0) {
						var option = "<option value='-1'>SELECCIONE</option>";
						for(var i=0;i<dataJson.datos.length; i++)
						{
							option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>";
						}
						comboLocalidades.html(option);
						
						if(callback != undefined){
							callback();
						}else{
							comboLocalidades.trigger("chosen:updated");
						}
					}else{
						showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
					}
				},
				error:function onError(){
					waitwindow('', 'close');
					showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
				},
				complete:function(){
					waitwindow('', 'close');
				},
				timeout: function(){
					waitwindow('', 'close');
				},
				abort: function(){
					waitwindow('', 'close');
				}
			});
		}
	}
//////////////////COMBO ESCOLARIDADES///////////////////////////////
	$("#cbo_escolaridad_agregar").trigger("chosen:updated");
	function Obtenercombo(){
		$("#cbo_escolaridad_agregar").html("");
		$.ajax({type: "POST",
		url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
		data: {}
		}).done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = "<option opc_carrera=0 value='0'>SELECCIONE</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option opc_carrera='"+ dataJson.datos[i].opc_carrera+"' value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
				}
				$("#cbo_escolaridad_agregar").html(option);
				$("#cbo_escolaridad_agregar").trigger("chosen:updated");
				$("#cbo_carrera").prop('disabled',true);
				$("#cbo_carrera").val(0);
			}
			else
			{
				//Error
				showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
				//message(dataJson.mensaje, '', undefined, undefined, function onclose(){});
			}
		})
		.fail(function(s) {
			//message("Error al cargar al consultar fun_obtener_listado_escolaridades"); 
			showalert(LengStrMSG.idMSG88+" escolaridades", "", "gritter-error");
		})
		.always(function() {});
	}
// ===============================TERMINAN OPCIONES MODAL===============================================		
	/////////////COMBO TIPO ESCUELA////////////////////////////////////////
	$( "#cbo_tipoEscuela").change(function(event){
		inum_deresp = document.getElementById("cbo_tipoEscuela").options[document.getElementById("cbo_tipoEscuela").selectedIndex].value;
		$("#gridEscuelas-table").jqGrid('clearGridData');
		// ActualizarGrid();
	});
	
	/////////////COMBO ESTADOS////////////////////////////////////////
	$( "#cbo_estado").change(function(event){
		$("#gridEscuelas-table").jqGrid('clearGridData');
		actualizarMunicipios();
		$("#cbo_localidad").val(-1);
		$("#cbo_localidad").trigger("chosen:updated");
		// actualizarLocalidades();			

	});
	/////////////COMBO MUNICIPIOS////////////////////////////////////////
	$("#cbo_municipio").change(function(event){
		$("#gridEscuelas-table").jqGrid('clearGridData');
		actualizarLocalidades();
	});	
	/////////////////////////Función para guardar observaciones en modal dlg_Observaciones
	function Bloquea_desbloquea_Escuela()
	{
		$.ajax({type: "POST", 
		url:'ajax/json/json_fun_bloquear_desbloquear_escuela.php?',
		data: { 
			'iEscuela':idu_escuela,
			'cObservaciones':$("#txt_Motivos").val().toUpperCase(),
			session_name: Session}
		}).
		done(function(data)
		{
			json = json_decode(data);
			if(json.mensaje == "La escuela se bloqueo")
			{
				//message("Escuela Bloqueada", '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG156, '','gritter-success');
				$("#txt_Motivos").val("");
				$("#txt_Motivo").val("");
				$("#gridEscuelas-table").jqGrid('clearGridData');
				ActualizarGrid();
			}
			else if (json.mensaje == "La escuela se desbloqueo")
			{
				//message("Escuela Desbloqueada", '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG155, '','gritter-success');
				$("#txt_Motivos").val("");
				$("#txt_Motivo").val("");
				$("#gridEscuelas-table").jqGrid('clearGridData');
				ActualizarGrid();
			}
			else
			{
			//	se bloqueo
				showalert(json.mensaje, "", "gritter-info");
			}
		});
	}
	/////////////////////BUSCAR////////////////////////////////////////
	$("#btn_buscar").click(function(event){
		iConsultar=1;
		$("#gridEscuelas-table").jqGrid('clearGridData');
		
		if ( $("#cbo_estado").val() == -1 && $("#txt_escuela").val().replace('/^\s+|\s+$/g', '') == '' ) {
			showalert("Seleccione el estado", "", "gritter-info");
			$("#cbo_estado").focus();
			return;
		} else if ( $("#cbo_estado").val() == -1 && $("#txt_escuela").val().replace('/^\s+|\s+$/g', '') != '' && $("#txt_escuela").val().replace('/^\s+|\s+$/g', '').length < 3 ) {
			showalert("Proporcione al menos 3 caracteres para realizar la búsqueda", "", "gritter-info");
			$("#txt_escuela").focus();
			return;
		} else {			
			ActualizarGrid();	
		}
		
		
		event.preventDefault();
	});

	$('#dlg_Agregar').on('hide.bs.modal', function (event) {
		$("#cbo_estado_agregar").val(-1);
		$("#cbo_estado_agregar").prop('disabled', false);
		$("#cbo_estado_agregar").trigger("chosen:updated");
		
		$("#cbo_municipio_agregar").val(-1);
		$("#cbo_municipio_agregar").prop('disabled', false);
		$("#cbo_municipio_agregar").trigger("chosen:updated");
		
		$("#cbo_localidad_agregar").val(-1);
		$("#cbo_localidad_agregar").prop('disabled', false);
		$("#cbo_localidad_agregar").trigger("chosen:updated");
	});	

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 392
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
});		