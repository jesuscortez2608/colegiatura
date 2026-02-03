$(function(){
	ConsultaClaveHCM()
	stopScrolling(function(){
		dragablesModal();
	});
	$.fn.modal.Constructor.prototype.enforceFocus = function () {};
	// $('#ckb_Especial').hide();
	var nBeneficiario=0,
		sNombreB='',
		sApePat='',
		sApeMat='',
		nParentesco=0,
		nEspecial=0,
		sObservaciones='',
		nEmpleado = 0;
	var nEscolaridad=0,
		nEscuela=0;
		CargarParentescos();
		MostrarGridEscuelas();
		//CargarEscolaridades();
	var sEscuela="",
		nEscuelaSeleccionada=0;
	var ModificoEspecial;
	//Variables para controlar las validaciones al momento de bloquear o desbloquear un Empleado.
	var sJustificacionBloqueo = "";
		JustificacionBloqueoGuardada = false;
		CerrarJustifacionAutomatica = false;
	var sJustificacionEspecial = "";
		JustificacionEspecialGuardada = false;
		CerrarJustifacionEspecialAutomatica = false;		

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

	CargarEstados( function(){
		CargarCiudades(function(){
			CargarLocalidades();
		});
	});
	function stopScrolling(callback) {
		$("#dlg_ModalJustificacionBloqueo").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_ModalJustificacionEspecial").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_AgregarB").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_AgregarEstudio").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_AyudaEscuelas").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
		
		$("#dlg_BusquedaEmpleados").on("show.bs.modal", function () {
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
	
	// $("#dlg_AgregarB").draggable();
	
	
	//COMBOS MODAL AGREGAR ESTUDIO
	// $("#cbo_Estado").chosen({no_results_text: 'NO SE ENCUENTRA',width: '150px'});
	// $("#cbo_Ciudad").chosen({no_results_text: 'NO SE ENCUENTRA',width: '150px'});
	// $("#cbo_Localidad").chosen({no_results_text: 'NO SE ENCUENTRA',width: '150px'});
	$("#cbo_TipoConsulta").chosen({no_results_text: 'NO SE ENCUENTRA',width: '150px'});
	
	//Evento de event handler para el cambio de valor del checkBox de bloqueo de empleado.
	var chkBloquearChangeEventHandler = function()
	{
		if($("#txt_Numemp").val().length == 8)
		{
			//Al momento de Bloquear/DesBloquear un empleado se debe de anotar una justificación antes de guardar.
			if($('#ckb_bloquear').is(":checked"))
			{
				bootbox.confirm(LengStrMSG.idMSG194,
				function(result){
					if (result){
						$("#dlg_ModalJustificacionBloqueo").modal("show");
					}
					else
					{
						$("#ckb_bloquear").prop('checked', false);
				
					}
				});
			}
			else
			{
				$("#dlg_ModalJustificacionBloqueo").modal("show");
			}	
		}
	}
	var chkEspecialChangeEventHandler = function()
	{
		if($("#txt_Numemp").val().length == 8)
		{
			//Al momento de Bloquear/DesBloquear un empleado se debe de anotar una justificación antes de guardar.
			if($('#ckb_especial').is(":checked"))
			{
				// bootbox.confirm("¿Desea Marcar/Desmarcar al colaborador como Especial?",
				// function(result){
					// if (result){
						$("#dlg_ModalJustificacionEspecial").modal("show");
					// }
					// else
					// {
						// $("#ckb_especial").prop('checked', false);
				
					// }
				// });
			}
			else
			{
				$("#dlg_ModalJustificacionEspecial").modal("show");
				// $("#ckb_especial").prop('checked', false);
			}	
		}
	}
	$("#ckb_bloquear").on("change", chkBloquearChangeEventHandler);
	$("#ckb_especial").on("change", chkEspecialChangeEventHandler);
	//$('#btn_AgregarColaborador').prop('disabled', true);	
	CargarGrid();
	MostrarGridDetalles();
	$("#cbo_Escolaridad").change(function(){
		CargarGrados();
	});
	//console.log(ModificoEspecial);
	$("#ckb_especial").change(function(){
		if($("#txt_Numemp").val().length==8)
		{
			$("#dlg_ModalJustificacionEspecial").modal("show");
			
			// GuardarEmpleado();
		}
		if($('#ckb_especial').is(':checked')){
			ModificoEspecial = true;
		}else{
			ModificoEspecial = false;
		}
		//console.log(ModificoEspecial);
	});
	$("#ckb_limitado").change(function(){
		if($("#txt_Numemp").val().length==8)
		{
			// GuardarEmpleado();
		}	
	});
	
	$("#ckb_Especial").change(function()
	{
		$("#txt_Observaciones").prop('disabled',false);
		
		$("#txt_Observaciones").val("");
		if(nEspecial==1)
		{
			if($('#ckb_Especial').is(":checked"))
			{
				$("#lblObservaciones").text("Observaciones:");
			}
			else
			{
				$("#lblObservaciones").text("Justicación:");
			}
		}
		else
		{
			if($('#ckb_Especial').is(":checked"))
			{
				$("#txt_Observaciones").prop('disabled',false);
			}
			else
			{
				$("#txt_Observaciones").prop('disabled',true);
			}
		}
	});
	
	$('#btn_Salir').click(function(event){
		//console.log(1);
		$("#dlg_AyudaEscuelas").modal('hide');
		event.preventDefault();	
	});
	
	$( '#txt_Numemp' ).on('paste', function(event){
		var element = this;
		setTimeout(function () {
			var text = $(element).val();
			if ($(element).val().length == 8 &&  (!isNaN(parseInt(text)) && isFinite(text))) {
				// console.log("es numerico");
				$(element).val(text);
				$("#txt_Nombre").val("");
				$("#txt_Centro").val("");
				$("#txt_NombreCentro").val("");
				$("#txt_FechaIngreso").val("");
				$("#txt_Motivo").val("");
				
				$("#ckb_bloquear").prop('checked', false);
				$("#ckb_especial").prop('checked', false);
				$("#ckb_limitado").prop('checked', false);
				
				$('#gd_Beneficiarios').jqGrid('clearGridData');
				$('#gd_Detalles').jqGrid('clearGridData');
				nBeneficiario = 0;			
				
				ConsultaEmpleado( 
					function(){ 
						if($("#txt_Nombre").val()!='')
						{
							fnObtenerDatosEmpleado(
								function(){
									CargarBeneficiario(0);
									CargarEstudio(1);
								}
							);
						}	
				});
			} else {
				// console.log("no es numérico");
				event.preventDefault();
			}
		}, 0);
	});
	
	$( '#txt_Numemp' ).on('input propertychange', function(event){
		if($("#txt_Numemp").val().length != 8 || (isNumeric($("#txt_Numemp").val()))==false)
		{
			$("#txt_Nombre").val("");
			$("#txt_Centro").val("");
			$("#txt_NombreCentro").val("");
			$("#txt_FechaIngreso").val("");
			$("#txt_Motivo").val("");
			
			$("#ckb_bloquear").prop('checked', false);
			$("#ckb_especial").prop('checked', false);
			$("#ckb_limitado").prop('checked', false);
			
			$('#gd_Beneficiarios').jqGrid('clearGridData');
			$('#gd_Detalles').jqGrid('clearGridData');
			nBeneficiario = 0;
		}	
		else if($("#txt_Numemp").val().length == 8 && isNumeric($("#txt_Numemp").val()) )
		{
			ConsultaEmpleado( 
				function(){ 
					if($("#txt_Nombre").val()!='')
					{
						fnObtenerDatosEmpleado(
							function(){
								CargarBeneficiario(0);
								CargarEstudio(1);
							}
						);
					}	
			});
		}else{
			$("#txt_Nombre").val("");
			$("#txt_Centro").val("");
			$("#txt_NombreCentro").val("");
			$("#txt_FechaIngreso").val("");
			$("#txt_Motivo").val("");
			
			$("#ckb_bloquear").prop('checked', false);
			$("#ckb_especial").prop('checked', false);
			$("#ckb_limitado").prop('checked', false);
			
			$('#gd_Beneficiarios').jqGrid('clearGridData');
			$('#gd_Detalles').jqGrid('clearGridData');
			nBeneficiario = 0;			
		}
	});
	
	$("#txt_Numemp").keydown(function(e)
	{
		var keycode = e.which;
		  // console.log(keycode);
		if(keycode == 13 || keycode == 9 || keycode == 0)
		{
			if($("#txt_Numemp").val().length != 8 )
			{
				$("#txt_Numemp").focus();
				$("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Centro").val("");
				$("#txt_NombreCentro").val("");
				$("#txt_FechaIngreso").val("");
				$('#gd_Beneficiarios').jqGrid('clearGridData');
				$('#gd_Detalles').jqGrid('clearGridData');				
				//showmessage('Empleado no valido, favor de verificar', '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG195, "", "gritter-info");
			}else if($("#txt_Numemp").val().length < 8){
				showalert("Proporcione un número de colaborador válido", "", "gritter-info");
				$("#txt_Numemp").focus();
				return;
			}
			else
			{
				ConsultaEmpleado( function(){
					if($("#txt_Nombre").val()!='')
					{
						 fnObtenerDatosEmpleado(
							function(){
								CargarBeneficiario(0);
								CargarEstudio(1);
							}
						);
					}	
				});
				
			}
			$("#txt_Motivo").val("");
		}
	});
	//GRID BENEFCIARIOS
	function CargarGrid()
	{
		jQuery("#gd_Beneficiarios").jqGrid({
			//url:'ajax/json/',
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG9,
					colModel:[
					{name:'idu_empleado',index:'idu_empleado', width:70, sortable: false,align:"center",fixed: false, hidden:true},
					{name:'idu_beneficiario',index:'idu_beneficiario', width:50, sortable: false,align:"center",fixed: false},
					{name:'nom_nombre',index:'nom_nombre', width:230, sortable: false,align:"left",fixed: false , hidden:true},
					{name:'nom_apepat',index:'nom_apepat', width:230, sortable: false,align:"left",fixed: false , hidden:true},
					{name:'nom_apemat',index:'nom_apemat', width:230, sortable: false,align:"left",fixed: false , hidden:true},
					{name:'nombre',index:'nombre', width:300, sortable: false,align:"left",fixed: true},
					{name:'idu_parentesco',index:'idu_parentesco', width:100, sortable: false,align:"left",fixed: true, hidden:true} ,
					{name:'des_parentesco',index:'des_parentesco', width:150, sortable: false,align:"left",fixed: true},
					{name:'des_observacion',index:'des_observacion', width:100, sortable: false,align:"left",fixed: true, hidden:true},
					{name:'id_estudios',index:'id_estudios', width:120, sortable: false,align:"left",fixed: true},
					{name:'idu_especial',index:'idu_especial', width:120, sortable: false,align:"left",fixed: true, hidden:true},
					{name:'des_especial',index:'des_especial', width:120, sortable: false,align:"center",fixed: true}
					],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			//width: 600,
			width: 800,
			shrinkToFit: false,
			height: 200,
			caption: 'Beneficiarios',
			pgbuttons: false,
			pgtext: null,
			pager: '#gd_Beneficiarios_pager',
			postData:{session_name:Session},
			
			loadComplete: function (id) {
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id)
			{			
				if(id >= 0){
				
					var fila = jQuery("#gd_Beneficiarios").getRowData(id); 
					nBeneficiario = fila['idu_beneficiario'];
					nEmpleado = fila['idu_empleado'];
					sNombreB = fila['nom_nombre'];
					sApePat = fila['nom_apepat'];
					sApeMat=fila['nom_apemat'];
					nParentesco=fila['idu_parentesco'];
					sObservaciones=fila['des_observacion'];
					nEspecial=fila['idu_especial'];
					nEscuela=0;
					var des =fila['des_observacion'];
					//alert(des);
					$("#txt_Motivo").val(des);
					$("#div_beneficiarioEstudio").html(' Beneficiario: <b>'+fila['idu_beneficiario']+' '+fila['nombre']+'</b>');
					CargarEstudio();
					//console.log(nEmpleado);
					//console.log(nBeneficiario);
					
				} else {
					nBeneficiario=0;
					nEmpleado = 0;
					$("#txt_Motivo").val("");
					sNombreB = '';
					sApePat = '';
					sApeMat='';
					nParentesco='';
					sObservaciones='';
					nEspecial=0;
					nEscuela=0;
				}
			},					
		});
		
		jQuery("#gd_Beneficiarios")
			.navGrid('#gd_Beneficiarios_pager',{refresh:false,edit:false,add:false,del:false,search:false})
			.navButtonAdd('#gd_Beneficiarios_pager',{
				id: "gd_btn_add",
				caption: "",
				title:"Editar beneficiario", 
				buttonicon:"icon-edit orange bigger-140", 
				onClickButton: function(event){ 
					if (nBeneficiario>0)
					{
						$("#dlg_AgregarB").modal('show');
						$('#txt_Beneficiario').val(nBeneficiario);
						$('#txt_NombreB').val(sNombreB);
						$('#txt_ApPat').val(sApePat);
						$('#txt_ApMat').val(sApeMat);
						$('#cbo_Parentesco').val(nParentesco);
						$('#txt_Observaciones').val(sObservaciones);
						$("#txt_Observaciones").prop('disabled', true);
						$("#lblObservaciones").text("Observaciones:");
						if(nEspecial==1)
						{
							$("#ckb_Especial").prop('checked', true);
							//$("#lblObservaciones").text("Observaciones:");
						} 
						else 
						{
							$("#ckb_Especial").prop('checked', false);
						//	$("#lblObservaciones").text("Justificación:");
						}
					}
					else
					{
						//showmessage('Seleccione el beneficiario a modificar', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG196, "", "gritter-info");
					
					}
					event.preventDefault();
				}, 
				position:"last"
			});
	}	
	//GRID
	function  MostrarGridDetalles()
	{
		jQuery("#gd_Detalles").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG10,
			colModel:[
			{name:'idu_empleado',		index:'idu_empleado',		width:100, sortable: false, align:"center",	fixed: true, hidden:true},
			{name:'idu_beneficiario',	index:'idu_beneficiario',	width:100, sortable: false, align:"center",	fixed: true, hidden:true},
			{name:'fec_registro',		index:'fec_registro',		width:100, sortable: false, align:"center",	fixed: true},
			{name:'por_descuento',		index:'por_descuento',		width:100, sortable: false, align:"left",	fixed: true},
			{name:'idu_escuela',		index:'idu_escuela',		width:150, sortable: false, align:"left",	fixed: true,  hidden:true},
			{name:'nom_rfc_escuela',	index:'nom_rfc_escuela',	width:100, sortable: false, align:"left",	fixed: true},
			{name:'nom_nombre_escuela',	index:'nom_nombre_escuela', width:300, sortable: false, align:"left",	fixed: true},
			{name:'idu_escolaridad',	index:'idu_escolaridad',	width:100, sortable: false, align:"left",	fixed: true,  hidden:true},
			{name:'des_escolaridad',	index:'des_escolaridad',	width:170, sortable: false, align:"left",	fixed: true}
			],		
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			//rowList:[],
			width: null,
			shrinkToFit: false,
			height: 200,
			width:800,
			caption: 'Estudios',
			//pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			pager: '#gd_Detalles_pager',
			loadComplete: function (Data) {
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id)
			{			
				if(id >= 0){
					
					var fila = jQuery("#gd_Detalles").getRowData(id); 
					nEscuela = fila['idu_escuela'];
					nEscolaridad = fila['idu_escolaridad'];
						
				} else {
					nEscuela=0;
					nEscolaridad = 0;
				}
				//console.log(nEscuela);
			},					
		});
		
		jQuery("#gd_Detalles")
			.navGrid('#gd_Detalles_pager',{refresh:false,edit:false,add:false,del:false,search:false})
			.navButtonAdd('#gd_Detalles_pager',{
				id: "gd_btn_eliminar_estudio",
				caption: "",
				title:"Eliminar", 
				buttonicon:"icon-trash red", 
				onClickButton: function(event){ 
					//console.log(1);
					if(nEscuela!=0)
					{
						
						bootbox.confirm(LengStrMSG.idMSG199,
						function(result){
							if (result){
								fnEliminarEstudio();
							}	
						});
							
					}
					else
					{
						//showmessage('Seleccione el estudio a eliminar', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG200, "", "gritter-info");
					}
					event.preventDefault();
				}, 
				position:"last"
			});
		setSizeBtnGrid('gd_btn_add',35);
		setSizeBtnGrid('gd_btn_del',35);
		setSizeBtnGrid('gd_btn_eliminar_estudio',35);
	}
	
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	
	function MostrarGridEscuelas()
	{
		jQuery("#grid_ayudaEscuelas").jqGrid({
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG65,
		colModel:[
				{name:'idu_escuela',index:'idu_escuela', width:100, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'rfc_clave_sep',index:'rfc_clave_sep', width:120, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'nom_escuela',index:'nom_escuela', width:530, sortable: false,align:"left",fixed: true},				
				{name:'opc_tipo_escuela',index:'opc_tipo_escuela', width:100, sortable: false,align:"left",fixed: true, hidden:true },				
				{name:'nom_tipo_escuela',index:'nom_tipo_escuela', width:120, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'clave_sep',index:'clave_sep', width:90, sortable: false,align:"left",fixed: true },
				{name:'escolaridad',index:'escolaridad', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_escolaridad',index:'nom_escolaridad', width:120, sortable: false,align:"left",fixed: true },
				{name:'opc_obligatorio_pdf',index:'opc_obligatorio_pdf', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_obligatorio',index:'nom_obligatorio', width:350, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'opc_escuela_bloqueada',index:'opc_escuela_bloqueada', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_bloqueada',index:'nom_bloqueada', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'fec_captura',index:'fec_captura', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				
				{name:'opc_educacion_especial',index:'opc_educacion_especial', width:100, sortable: false,align:"left",fixed: true,hidden:true },
				{name:'nom_educacion_especial',index:'nom_educacion_especial', width:100, sortable: false,align:"left",fixed: true,hidden:true },
				{name:'idu_tipo_deduccion',index:'idu_tipo_deduccion', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_tipo_deduccion',index:'nom_tipo_deduccion', width:100, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'observaciones',index:'observaciones', width:100, sortable: false,align:"left",fixed: true, hidden:true}
				],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			pgbuttons:true,
			loadonce: null,//false,
			height: 205,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			width:750,
			rowNum:5,
			//rowList:[10, 20, 30],
			pager: '#grid_ayudaEscuelas_pager',
			sortname: 'nom_escuela',
			viewrecords: true,
			hidegrid:false,
			sortorder: "asc",
			caption:'Catálogo de Escuelas',
			loadComplete: function (Data) {
				var registros = jQuery("#grid_ayudaEscuelas").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(id)
			{
				var rowData = jQuery(this).getRowData(id);
				$('#txt_idEscuela').val(rowData.idu_escuela);
				$('#txt_clvSEP').val(rowData.clave_sep);
				$("#txt_escuelaSeleccion").val(rowData.nom_escuela);
				$("#txt_NombreBusqueda").val("");
				
				CargarEscolaridades();
				$("#dlg_AyudaEscuelas").modal('hide');
			}		
		});	
		jQuery("#grid_ayudaEscuelas").jqGrid('navGrid','#grid_ayudaEscuelas_pager',{search:false, edit:false,add:false,del:false});	
		jQuery("#grid_ayudaEscuelas_pager_left").hide();
	}	
	
	
	function updatePagerIcons(table)
	{
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
	
	$('#dlg_AgregarB').on('hide.bs.modal', function (event) {
		$("#txt_Motivo").val("");
		CargarEstudio(1);
		nBeneficiario=0;
		nEmpleado = 0;
		CargarBeneficiario(0);
		$('#grid_ayudaEscuelas').jqGrid('clearGridData');
		$("#cbo_Estado").val(-1);
		$("#cbo_Estado").trigger("chosen:updated");
		$("#cbo_Ciudad").val(-1);
		$("#cbo_Ciudad").trigger("chosen:updated");
		$("#cbo_Localidad").val(-1);
		$("#cbo_Localidad").trigger("chosen:updated");
		// event.preventDefault();
	});
	$('#dlg_AyudaEscuelas').on('hide.bs.modal', function (event) {
		// $('#grid_ayudaEscuelas').jqGrid('clearGridData');
		// $("#cbo_Estado").val(0);
		// $("#cbo_Estado").trigger("chosen:updated");
		// $("#cbo_Ciudad").val(0);
		// $("#cbo_Ciudad").trigger("chosen:updated");
		// $("#cbo_Localidad").val(0);
		// $("#cbo_Localidad").trigger("chosen:updated");
		// event.preventDefault();	
	});
	$('#dlg_AgregarEstudio').on('hide.bs.modal', function(event){
		$("#txt_escuelaSeleccion").val() == "";
		$("#cbo_Escolaridad").val(0);
		$("#cbo_Escolaridad").trigger("chosen:updated");
		$("#cbo_Grado").val(0);
		$("#cbo_Grado").trigger("chosen:updated");
		
		$('#grid_ayudaEscuelas').jqGrid('clearGridData');
		$("#cbo_Estado").val(-1);
		$("#cbo_Estado").trigger("chosen:updated");
		$("#cbo_Ciudad").val(-1);
		$("#cbo_Ciudad").trigger("chosen:updated");
		$("#cbo_Localidad").val(-1);
		$("#cbo_Localidad").trigger("chosen:updated");
		// event.preventDefault();			
	});
	//BOTONES
	$('#btn_Otro').click(function(event){
		CargarBeneficiario(1);
		CargarEstudio(1);
	
		$("#txt_Numemp").val("");
		$("#txt_Nombre").val("");
		$("#txt_Centro").val("");
		$("#txt_NombreCentro").val("");
		$("#txt_Puesto").val("");
		$("#txt_Seccion").val("");
		$("#txt_FechaIngreso").val("");
		$("#txt_Motivo").val("");
		$("#txt_Numemp").focus();
		$("#div_empleado").html("");
		$("#div_empleadoEstudio").html("");
		$("#div_beneficiarioEstudio").html("");
		//BENEFCIARIOS
		$('#txt_NombreB').val("");
		$('#txt_ApPat').val("");
		$('#txt_ApMat').val("");
		$('#txt_Observaciones').val("");
		$('#cbo_Parentesco').val(0);
		$('#txt_motivo').val("");
		
		$("#cbo_Estado").val($("#cbo_Estado option").first().val());
		$("#cbo_Ciudad").val($("#cbo_Ciudad option").first().val());
		$("#cbo_Localidad").val($("#cbo_Localidad option").first().val());
		//desmarcar
		
		$("#ckb_especial").prop('checked', false);
		$("#ckb_bloquear").prop('checked', false);
		$("#ckb_limitado").prop('checked', false);
		
		
		//VARIABLES GLOBALES
		nEmpleado=0;
		nBeneficiario=0;
		nEspecial=0;
		sNombreB="";
		sApePat="";
		sApeMat="";
		sObservaciones="";
		sbeneficiario="";
		
		event.preventDefault();	
	});	
	$('#btn_AgregarBeneficiario').click(function(event){
		if($("#txt_Nombre").val()!="")
		{
			if($("#txt_Numemp").val().length < 8){
				showalert("Proporcione un número de colaborador válido", "", "gritter-info");
				$("#txt_Numemp").focus();
				return;
			}else{
				nEspecial=0;
				fnObtenerNumeroBeneficiario();
				$("#dlg_AgregarB").modal('show');
			}
			
		}
		else
		{
			//showmessage('Proporcione el empleado que desea agregar un beneficiario', '', undefined, undefined, function onclose(){
				// showalert(LengStrMSG.idMSG201, "", "gritter-info");
				showalert("Proporcione el colaborador al que desea agregar un beneficiario", "", "gritter-info");
				$("#txt_Numemp").focus();
			//});
		}
		event.preventDefault();	
	});	
	
	$('#btn_GuardarEstudio').click(function(event){
	
		if($("#cbo_Escolaridad").val()==0)
		{
			//showmessage('Seleccione la escolaridad', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG202, "", "gritter-info");
		}else if($("#cbo_Grado").val()==-1)
		{
			//showmessage('Seleccione el grado', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG203, "", "gritter-info");
		}
		else
		{
			GuardareEstudio();
		}
		event.preventDefault();	
	});
	
	$('#btn_ConsultaEscuela').click(function(event){
	
		$("#txt_NombreBusqueda").val("");
		$("#dlg_AyudaEscuelas").modal('show');
		$("#dlg_AyudaEscuelas").draggable();
		event.preventDefault();	
	});
	$('#dlg_AyudaEscuelas').on('shown', function (event) {
		// $('#txt_NombreBusqueda').focus();
		event.preventDefault();	
	})
	
	$('#btn_GuardarB').click(function(event)
	{
		if($("#txt_Numemp").val().length < 8){
			showalert("Proporcione un número de colaborador válido", "", "gritter-info");
			$("#txt_Numemp").focus();
			return;			
		}else{
			GuardarBeneficiario();
			event.preventDefault();	
		}
	});
	
	function GuardarBeneficiario(){
		// showalert("Guardar Beneficiario A Colaborador", "", "gritter-info");
		var sJustificacion='';
		//console.log(nEspecial);
		var chk_Especial=0;
		if($('#ckb_Especial').is(":checked"))
		{
			chk_Especial=1;
		}
		if($("#txt_NombreB").val().replace('/^\s+|\s+$/g', '')=="")
		{
			//showmessage('Proporcione el nombre del beneficiario', '', undefined, undefined, function onclose(){
				showalert(LengStrMSG.idMSG204, "", "gritter-info");
				$("#txt_NombreB").val("");
				$("#txt_NombreB").focus();
			//});
			return;
		}
		else if($("#txt_ApPat").val().replace('/^\s+|\s+$/g', '')=="")
		{
			//showmessage('Proporcione el apellido paterno del beneficiario', '', undefined, undefined, function onclose(){
			showalert(LengStrMSG.idMSG205, "", "gritter-info");
				$("#txt_ApPat").val("");
				$("#txt_ApPat").focus();
			// });
			return;
		}
		else if($("#cbo_Parentesco").val()=="0")
		{
			//showmessage('Proporcione el parentesco', '', undefined, undefined, function onclose(){
			showalert(LengStrMSG.idMSG206, "", "gritter-info");
				$("#cbo_Parentesco").focus();
			//});
			return;
		}
		if(chk_Especial==1)
		{
			if($('#txt_Observaciones').val().replace('/^\s+|\s+$/g', '').length==0)
			{
				//showmessage('Proporcione la observación', '', undefined, undefined, function onclose(){
				showalert(LengStrMSG.idMSG207, "", "gritter-info");
				$("#txt_Observaciones").focus();
				//});
				return;
			}
		}
		if (nEspecial==1 && chk_Especial==0)
		{
			if($('#txt_Observaciones').val().replace('/^\s+|\s+$/g', '').length==0)
			{	
				//showmessage('Proporcione una justificación', '', undefined, undefined, function onclose(){
				showalert(LengStrMSG.idMSG208, "", "gritter-info");
					$("#txt_Observaciones").focus();
				//});
				return;
			}
			else
			{
				//$("#lblObservaciones").text("Justificación:");
				sJustificacion='SE DESMARCO POR: ';
			}
		}
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_grabar_beneficiario_por_empleado.php?',
			data: { 
				'iEmpleado':$('#txt_Numemp').val(),
				'cNombre' : $('#txt_NombreB').val().toUpperCase(),
				'cApePaterno':$('#txt_ApPat').val().toUpperCase(),
				'cApeMaterno':$('#txt_ApMat').val().toUpperCase(),
				'iParentesco':$('#cbo_Parentesco').val(),
				'iEspecial':chk_Especial,
				'cDescripcion': sJustificacion + $('#txt_Observaciones').val().toUpperCase(),
				'iBeneficiario':$('#txt_Beneficiario').val(),
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if(dataJson.estado == 0)
				{
					if(dataJson.mensaje > 0)
					{
						// if(dataJson.mensaje == 2)
						// {
							//Agregar empleado en la tabla cat_empleados_colegiaturas
							// GuardarEmpleado();
						// }
						//showmessage('Beneficiario guardado correctamente...', '', undefined, undefined, function onclose(){ });
						showalert(LengStrMSG.idMSG209, "", "gritter-success");
						fnObtenerNumeroBeneficiario();
						$("#dlg_AgregarB").modal('hide');
					}
					else
					{
					//	showmessage('El beneficiario ya existe, favor de verificar...', '', undefined, undefined, function onclose(){});
						showalert(LengStrMSG.idMSG210, "", "gritter-info");
					}
				}
				else
				{ //error
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG230+" el beneficiario", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}	
		
	$("#btn_ConsultaAyudaEscuela").click(function(event){
		$('#grid_ayudaEscuelas').jqGrid('clearGridData');
		if($("#cbo_Estado").val() == -1){
			showalert("Seleccione un estado", "", "gritter-info");
			$("#cbo_Estado").focus();
		}else if($("#cbo_Ciudad").val() == -1){
			showalert("Seleccione un municipio", "", "gritter-info");
			$("#cbo_Ciudad").focus();
		}else if($("#cbo_Localidad").val() == -1){
			showalert("Seleccione una localidad", "", "gritter-info");
			$("#cbo_Localidad").focus();
		}else if($("#txt_NombreBusqueda").val().replace('/^\s+|\s+$/g', '')!=""){
			cargarGridEscuelas(0);
		}else{
			showalert(LengStrMSG.idMSG211, "", "gritter-info");
		}	
		event.preventDefault();	
	});
	
	function ConsultaEmpleado(callbackSuplentes)
	{
		var numEmp=$("#txt_Numemp").val();
		
		//url: "ajax/json/json_fun_consulta_empleado_co.php?",
		$.ajax({type: "POST", 
			url: "ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php?",
			data: { 
				'iEmpleado':numEmp,
				'session_name': Session
			},
			beforeSend:function(){},
			success:function(data){			
				var dataJson = JSON.parse(data);
				//console.log(dataJson);
				//if(dataJson == 'null')
				if(dataJson != null)
				{
					if(dataJson != 0)
					{
						if(dataJson[0].cancelado==1)
						{
							//message('El empleado se encuentra cancelado');
							
							showalert(LengStrMSG.idMSG212, "", "gritter-info");
							$("#txt_Numemp").val("");
							$("#txt_Nombre").val("");
							$("#txt_Centro").val("");
							$("#txt_NombreCentro").val("");
							$("#txt_FechaIngreso").val("");
							$("#txt_Puesto").val("");
							$("#txt_Seccion").val("");
							$("#txt_Numemp").focus();
							$("#div_empleado").html("");
							$("#div_empleadoEstudio").html("");
							$("#div_beneficiarioEstudio").html("");
						}
						else
						{
							$("#txt_Nombre").val(dataJson[0].nombre+' '+dataJson[0].appat+' '+dataJson[0].apmat);
							$("#txt_Centro").val(dataJson[0].centro);
							$("#txt_NombreCentro").val(dataJson[0].nombrecentro);
							$("#txt_Puesto").val(dataJson[0].puesto);
							$("#txt_Seccion").val(dataJson[0].seccion);
							$("#txt_FechaIngreso").val(dataJson[0].fec_alta);
							(' Colaborador: <b>'+numEmp+' '+$("#txt_Nombre").val()+'</b>').appendTo("#div_empleado");
							(' Colaborador: <b>'+numEmp+' '+$("#txt_Nombre").val()+'</b>').appendTo("#div_empleadoEstudio");
							// if(dataJson[0].antiguedad !=12){
								// $('#btn_AgregarColaborador').prop('disabled', false);
								// GuardarEmpleado();
							// }else{
								// $('#btn_AgregarColaborador').prop('disabled', true);
								// showalert("Colaborador Cuenta Con Beneficio Colegiatura","Atenci&oacuten","gritter-info");
							// }
						}
					}
					else
					{
						//message('No existe el número de empleado');
						
						showalert(LengStrMSG.idMSG213, "", "gritter-info");
						$("#txt_Numemp").val("");
						$("#txt_Nombre").val("");
						$("#txt_Centro").val("");
						$("#txt_NombreCentro").val("");
						$("#txt_FechaIngreso").val("");
						$("#txt_Puesto").val("");
						$("#txt_Seccion").val("");
						$("#txt_Numemp").focus();
						$("#div_empleado").html("");
						$("#div_empleadoEstudio").html("");
						$("#div_beneficiarioEstudio").html("");
						
					}
				}
				else
				{
					//message('Empleado no válido');
					showalert(LengStrMSG.idMSG214, "", "gritter-info");
					$("#txt_Numemp").val("");
					$("#txt_Nombre").val("");
					$("#txt_Centro").val("");
					$("#txt_NombreCentro").val("");
					$("#txt_FechaIngreso").val("");
					$("#txt_Puesto").val("");
					$("#txt_Seccion").val("");
					$("#txt_Numemp").focus();
					$("#div_empleado").html("");
					$("#div_empleadoEstudio").html("");
					$("#div_beneficiarioEstudio").html("");
						
				}
			},
			error:function onError(){callbackSuplentes();},
			complete:function(){callbackSuplentes();},
			timeout: function(){callbackSuplentes();},
			abort: function(){callbackSuplentes();}	
		});		
	}
	function CargarBeneficiario(inicializar)
	{
		$("#gd_Beneficiarios").jqGrid('setGridParam',
		{ url: 'ajax/json/json_fun_obtener_listado_beneficiarios.php?inicializar='+inicializar+'&iNumEmp='+$("#txt_Numemp").val()+'&session_name=' +Session}).trigger("reloadGrid"); 
	}
	function CargarEstudio(inicializar)
	{
		$("#gd_Detalles").jqGrid('setGridParam',
		{ url: 'ajax/json/json_fun_obtener_listado_beneficiarios_estudios.php?inicializar='+inicializar+'&iNumEmp='+$("#txt_Numemp").val()+
		'&iCentro='+$("#txt_Centro").val()+'&iPuesto='+$("#txt_Puesto").val()+'&iSeccion='+$("#txt_Seccion").val()+'&iBeneficiario='+ nBeneficiario+'&session_name=' +Session}).trigger("reloadGrid"); 
	}
	
	function CargarParentescos()
	{
		$.ajax({type: "POST", 
			url: "ajax/json/json_fun_obtener_parentescos.php?",
			data: { 
				'iTipo':1
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);	
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE PARENTESCO</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Parentesco").html(option);
					$( "#cbo_Parentesco" ).val($("#cbo_Parentesco option").first().val());
				}
				else
				{
					//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG88+" los parentescos", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});	
	}
	$("#cbo_Escolaridad").trigger("chosen:updated");				//-----------------------------------------------------------------------------------------------------
	function CargarEscolaridades(){
		$("#cbo_Escolaridad").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {
				//'iEscuela':$("#txt_idEscuela").val(),
				'iEscuela':DOMPurify.sanitize($("#txt_idEscuela").val()),
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
					}					
					$("#cbo_Escolaridad").html(option);
					$("#cbo_Escolaridad").trigger("chosen:updated");
				}
				else
				{
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-warning");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
		
	}
	$('#btn_GuardarColaborador').click(function(event)
	{
		if($('#txt_Nombre').val()=="" || $('#txt_Numemp').val()== 00000000 || $('#txt_Numemp').val().replace('/^\s+|\s+$/g', '') == '' || $('#txt_Numemp').val().length < 8){
			showalert("Proporcione un número de colaborador válido","","gritter-info");
			$('#txt_Numemp').focus();
		}else if(ModificoEspecial = false){
			showalert("Introduce una justicación","","gritter-info");
		}else{
			GuardarEmpleado();
		}
	});
	
	function GuardarEmpleado()
	{
		var iLimitado=0, iBloqueado=0, iEspecial=0;

		if($('#ckb_especial').is(":checked"))
		{
			iEspecial=1;
		}
		if($('#ckb_limitado').is(":checked"))
		{
			iLimitado=1;
		}
		if($('#ckb_bloquear').is(":checked"))
		{
			iBloqueado=1;
		}
		/*if(sJustificacionEspecial == ""){
			showalert("Introduce Una Justicación","","gritter-info");
			// $("#dlg_ModalJustificacionEspecial").modal('show');
			
		}else{*/
			$.ajax({type: "POST", 
				url:'ajax/json/json_fun_grabar_empleado_colegiaturas.php?',
				data: { 
					'iEmpleado':$("#txt_Numemp").val(),
					'iLimitado' : iLimitado,
					'iEspecial': iEspecial,
					'iBloqueado':iBloqueado,
					'sJustificacionBloqueo': sJustificacionBloqueo,
					'sJustificacionEspecial': sJustificacionEspecial,
					'session_name': Session
				},
				beforeSend:function(){},
				success:function(data){
					//showmessage("Datos Guardados con éxito", '', undefined, undefined, function onclose(){
					//showalert("Datos Guardados con éxito", "","gritter-success");
						//Cerrar automaticamente el modal de Bloqueo de empleado (Asumiendo que este abierto).
						CerrarJustifacionAutomatica = true;
						$("#dlg_ModalJustificacionBloqueo").modal('hide');
					//});
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}	
			});
			showalert("Colaborador guardado correctamente","","gritter-success");
		// }
	}
	
	function GuardareEstudio()
	{
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_grabar_beneficiario_escuela_escolaridad.php?',
			data: { 
				'iEmpleado':nEmpleado,
				'iBeneficiario' : nBeneficiario,
				'iEscuela': $('#txt_idEscuela').val(),
				'iEscolaridad':$("#cbo_Escolaridad").val(),
				'iGrado':$("#cbo_Grado").val(),
				'iTipoBeneficiario':1,
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);	
			if(dataJson.estado == 0)
			{
				if(dataJson.mensaje == 1)
				{
					//showmessage('Estudio guardado correctamente...', '', undefined, undefined, function onclose(){
						showalert(LengStrMSG.idMSG215, "","gritter-success");
						$('#txt_escuelaSeleccion').val('');
						$('#idEscuela').val("");
						$("#cbo_Escolaridad").val(0);
						$("#cbo_Grado").val(-1);
						$("#dlg_AgregarEstudio").modal('hide');
						CargarBeneficiario(0);
						CargarEstudio(0);
					// });
				}
				else if(dataJson.mensaje == 0)
				{
					//showmessage('El estudio para este beneficiario ya existe, favor de verificar...', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG216, "", "gritter-info");
				}
				else
				{
					showalert(LengStrMSG.idMSG217, "", "gritter-info");
				}
			}
			else
			{
				//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG230+" el estudio dle beneficiario", "", "gritter-warning");
			}
		});
	}
	
	function fnObtenerDatosEmpleado(callbackSuplentes)
	{
		var numEmp=$("#txt_Numemp").val();
		ModificoEspecial = false;
		
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_consulta_empleado_colegiatura.php?",
		data: { 
				'iEmpleado':numEmp,
				'session_name': Session
			}
		})
		.done(function(data){				
			var dataJson = JSON.parse(data);
			//console.log(dataJson);
			if(dataJson != null)
			{
				if(dataJson.ESPECIAL==1) {
					// Marcar un checkbox
					$('#ckb_especial').prop('checked', true);
				} else {
					// Desmarcar un checkbox
					$('#ckb_especial').prop('checked', false);
				}
				if(dataJson.LIMITADO==1)
				{
					// Marcar un checkbox
					$("#ckb_limitado").prop('checked', true);
				} 
				else 
				{
					// Desmarcar un checkbox
					$("#ckb_limitado").prop('checked', false);
				}
				if(dataJson.BLOQUEADO==1)
				{
					// Marcar un checkbox
					$("#ckb_bloquear").prop('checked', true);
				} 
				else 
				{
					// Desmarcar un checkbox
					$("#ckb_bloquear").prop('checked', false);
				}
			}
			else
			{
				// Marcar un checkbox
				$("#ckb_limitado").prop('checked', true);
				//GuardarEmpleado();
			}
			if(ModificoEspecial){
				alert(ModificoEspecial);
			}
			callbackSuplentes();
		});		
	}
	
	function fnEliminarEstudio()
	{
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_eliminar_estudio_beneficiario.php?',
			data: { 
				'iEmpleado':nEmpleado,
				'iBeneficiario' : nBeneficiario,
				'iEscuela': nEscuela,
				'iEscolaridad':nEscolaridad,
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);	
			//console.log(dataJson);
			if(dataJson.estado == 0)
			{
				if(dataJson.mensaje == 1)
				{
					//showmessage('Estudio eliminado correctamente...', '', undefined, undefined, function onclose(){
					showalert(LengStrMSG.idMSG218, "","gritter-success");
						CargarEstudio(0);
						CargarBeneficiario(0);
						nEscuela = 0;
					//});
				}
				else
				{
					//showmessage('El estudio no se puede eliminar, favor de verificar...', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG219, "", "gritter-info");
				}
			}
			else
			{
				//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
				
				showalert(LengStrMSG.idMSG231+" el estudio", "", "gritter-warning");
			}
		});
	}
	
	function CargarGrados(){
		$("#cbo_Grado").html("");
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_obtener_grados_escolares.php?",
		data: { 
			'iEscolaridad':$("#cbo_Escolaridad").val()
			}
		})
		.done(function(data){				
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);	
			if(dataJson.estado == 0)
			{
				var option = "";
				
				option = option + "<option value='-1'>" +"SELECCIONE" + "</option>"; 	
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
				}
				$("#cbo_Grado").html(option);
				$( "#cbo_Grado" ).val($("#cbo_Grado option").first().val());
			}
			else
			{
				//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG88+" los grados escolares" , "", "gritter-warning");
			}
		});	
	}
	
	function fnObtenerNumeroBeneficiario(){
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_obtener_consecutivo_colegiaturas.php?',
			data: { 
				'iTipo':1,
				'iBusqueda':$("#txt_Numemp").val(),
				'session_name':Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);	
			if(dataJson.estado == 0)
			{
				$("#txt_Beneficiario").val(dataJson.mensaje);
				/*
				if(dataJson.mensaje == 1)
				{
					showmessage('Estudio eliminado correctamente...', '', undefined, undefined, function onclose(){
						CargarEstudio();
					});
				}
				else
				{
					showmessage('El estudio no se puede eliminar, favor de verificar...', '', undefined, undefined, function onclose(){});
				}*/
			}
			else
			{
				//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){});
				showalert(LengStrMSG.idMSG88+" el número de beneficiario", "", "gritter-info");
			}
		});
	}
	
	function fnValidarJustificacionBloqueo(){
		var sAlerta;
		sJustificacionBloqueo = $("#txt_JustificacionBloqueo").val().replace('/^\s+|\s+$/g', '').toUpperCase();
		if(sJustificacionBloqueo == "")
		{
			var sAccionBloqueo = "Desbloqueo";
			if($('#ckb_bloquear').is(":checked"))
			{
				sAccionBloqueo = "Bloqueo";
			}
			//sAlerta=LengStrMSG.idMSG220;
			//Favor de dar una justificación para el  sAccionBloqueo  de este usuario'
			//sAlerta=replace(sAlerta,'sAccionBloqueo',sAccionBloqueo);
			sAlerta=LengStrMSG.idMSG220.replace('sAccionBloqueo',sAccionBloqueo);
			$("#txt_JustificacionBloqueo").focus();
			
			showalert(sAlerta, "", "gritter-warning");
			return false;
		}
		return true;
	}
	function fnValidarJustificacionEspecial(){
		var sAlertaEspecial;
		sJustificacionEspecial = $("#txt_JustificacionEspecial").val().replace('/^\s+|\s+$/g', '').toUpperCase();
		if(sJustificacionEspecial == ""){
			var sAccionEspecial = "Marcado";
			if($('#ckb_especial').is(":checked")){
				sAccionEspecial = "Desmarcado";
			}
			sAlertaEspecial=LengStrMSG.idMSG220.replace('sAccionEspecial', sAccionEspecial);
			$("#txt_JustificacionEspecial").focus();
			
			showalert("Favor de introducir observaciones", "", "gritter-warning");
			return false;
		}
		return true;
	}
	
	$("#btn_buscar").click(function (event){
		LimpiarModalBusquedaEmpleados();
		
		$("#dlg_BusquedaEmpleados").modal('show');
		CargarGridColaborador();
		event.preventDefault();
	});
	
	function CargarGridColaborador(){
		jQuery("#grid_colaborador").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG45,
			colModel:[
				{name:'num_emp',index:'num_emp', width:80, sortable: false,align:"center",fixed: true},
				{name:'nombre',index:'nombre', width:110, sortable: false,align:"left",fixed: true},
				{name:'apepat',index:'apepat', width:100, sortable: false,align:"left",fixed: true},
				{name:'apemat',index:'apemat', width:100, sortable: false,align:"left",fixed: true},
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
			caption: 'Catálogo de Empleados',
			pgbuttons: false,
			pgtext: null,
			//postData:{session_name:Session},			
			loadComplete: function (Data) {
			var registros = jQuery("#grid_colaborador").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					//showmessage('', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			ondblClickRow: function(clave) {
				var Data = jQuery("#grid_colaborador").jqGrid('getRowData',clave);
				$("#txt_Numemp").val(Data.num_emp);
				$("#txt_Nombre").val(Data.nombre + ' ' + Data.apepat + ' ' + Data.apemat);
				$("#dlg_BusquedaEmpleados").modal('hide');
				
				ConsultaEmpleado( 
					function(){ fnObtenerDatosEmpleado(
						function(){
							CargarBeneficiario(0);
							CargarEstudio(1);
						}
					);
				});
				
				
			}
		});	
	}
	function LimpiarModalBusquedaEmpleados(){
		$("#txt_NombreEBusqueda").val("");
		$("#txt_apepatbusqueda").val("");
		$("#txt_apematbusqueda").val("");
		$('#grid_colaborador').jqGrid('clearGridData');
	}
	
	function fnLimpiarModalAgregarBeneficiario()
	{
		$("#txt_NombreB").val("");
		$("#txt_ApPat").val("");
		$("#txt_ApMat").val("");
		$("#cbo_Parentesco").val(0);
		$("#txt_Observaciones").val("");
		//Desmarcar
		if($('#ckb_Especial').is(":checked"))
		{
			$("#ckb_Especial").prop('checked', false);
			$("#txt_Observaciones").prop('disabled', true);
		}
	}
	
	$("#dlg_AgregarB").on("hide.bs.modal", function(event){
		fnLimpiarModalAgregarBeneficiario();
	});
	
	$("#btn_buscarCOL").click(function (event){
	
		if($("#txt_NombreEBusqueda").val().length != 0 || $("#txt_apepatbusqueda").val().length != 0 || $("#txt_apematbusqueda").val().length != 0)
		{
			$("#grid_colaborador").jqGrid('setGridParam', { url:'ajax/json/json_proc_busquedaEmpleados_sueldos.php?nombre=' + $('#txt_NombreEBusqueda').val()+'&apepat='+$('#txt_apepatbusqueda').val()+'&apemat='+$('#txt_apematbusqueda').val() + '&session_name=' + Session}).trigger("reloadGrid");
		}
		else
		{
			//showmessage('Favor de ingresar un filtro de búsqueda', '', undefined, undefined, function onclose(){
				showalert("Favor de ingresar un filtro de búsqueda", "", "gritter-info");
				$('#grid_colaborador').jqGrid('clearGridData');
			//});
		}
		event.preventDefault();
	});
	
	$("#dlg_ModalJustificacionBloqueo").on("shown.bs.modal", function(event){
		CerrarJustifacionAutomatica = false;
		JustificacionBloqueoGuardada = false;
		$("#lblJustificacionBloqueo").text("");
		if($('#ckb_bloquear').is(":checked"))
		{
			$("#lblJustificacionBloqueo").text("Observaciones de Bloqueo:");
		}
		else
		{
			$("#lblJustificacionBloqueo").text("Observaciones de DesBloqueo:");
		}
		$("#txt_JustificacionBloqueo").val("");
		$("#txt_JustificacionBloqueo").focus();
		event.preventDefault();
	});
	
	$("#dlg_ModalJustificacionBloqueo").on("hide.bs.modal", function(event){
		if(CerrarJustifacionAutomatica == false)
		{
			if(JustificacionBloqueoGuardada == false)
			{
				$("#ckb_bloquear").off("change", chkBloquearChangeEventHandler);
				if($('#ckb_bloquear').is(":checked"))
				{
					$("#ckb_bloquear").prop('checked', false);
				}
				else
				{
					$("#ckb_bloquear").prop('checked', true);
				}
				$("#ckb_bloquear").on("change", chkBloquearChangeEventHandler);
			}
			//al cerrar el modal limpiar el campo de justificación.
			$("#txt_JustificacionBloqueo").val("");
		}
	});
	$("#dlg_ModalJustificacionEspecial").on("hide.bs.modal", function(event){
		if(CerrarJustifacionEspecialAutomatica == false)
		{
			if(JustificacionEspecialGuardada == false)
			{
				$("#ckb_especial").off("change", chkEspecialChangeEventHandler);
				if($('#ckb_especial').is(":checked"))
				{
					$("#ckb_especial").prop('checked', false);
					ModificoEspecial = false;
					$("#txt_JustificacionEspecial").val("");
				}
				else
				{
					$("#ckb_especial").prop('checked', true);
					ModificoEspecial = true;
					$("#txt_JustificacionEspecial").val("");
				}
				$("#ckb_especial").on("change", chkEspecialChangeEventHandler);
			}
			//al cerrar el modal limpiar el campo de justificación.
			$("#txt_JustificacionEspecial").val("");
		}
	});
	
	$("#dlg_ModalJustificacionEspecial").on("shown.bs.modal", function(event){
		CerrarJustifacionEspecialAutomatica = false;
		JustificacionEspecialGuardada = false;
		$("#lblJustificacionEspecial").text("");
		if($('#ckb_especial').is(":checked"))
		{
			$("#lblJustificacionEspecial").text("Observaciones Marcado Especial:");
		}
		else
		{
			$("#lblJustificacionEspecial").text("Observaciones Desmarcado Especial:");
		}
		$("#txt_JustificacionEspecial").val("");
		$("#txt_JustificacionEspecial").focus();
		event.preventDefault();
	});

	
	$("#btn_GuardarJusticacionBloqueo").click(function(event){
		if(fnValidarJustificacionBloqueo() == true)
		{
			$("#txt_JustificacionEspecial").val("");
			$("#dlg_ModalJustificacionBloqueo").modal('hide');
			
			if($('#ckb_bloquear').is(":checked")){
				$('#ckb_bloquear').prop('checked', false);
			}else{
				$('#ckb_bloquear').prop('checked', true);
			}
			
			//GuardarEmpleado();
		}
		event.preventDefault();
	});
	$("#btn_GuardarJusticacionEspecial").click(function(event){
		if(fnValidarJustificacionEspecial() == true){
			$("#dlg_ModalJustificacionEspecial").modal('hide');
			
			if($('#ckb_especial').is(":checked")){
				$('#ckb_especial').prop('checked', false);
			}else{
				$('#ckb_especial').prop('checked', true);
			}
		}
			//GuardarEmpleado();
		event.preventDefault();
	});
	function cargarGridEscuelas()
	{
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		$("#grid_ayudaEscuelas").jqGrid('setGridParam',	{ 
			url: 'ajax/json/json_fun_obtener_escuelas_colegiaturas.php?iTipoEscuela=0&iConfiguracion=1&iOpcion=1' +
			'&iEstado='+$('#cbo_Estado').val()+'&iMunicipio='+$('#cbo_Ciudad').val()+'&iLocalidad='+$('#cbo_Localidad').val()+'&iBusqueda='+$('#cbo_TipoConsulta').val()+
			'&sBuscar='+$('#txt_NombreBusqueda').val().toUpperCase().replace('/^\s+|\s+$/g', '')+'&iAyuda=1'+ '&session_name=' + Session
		}).trigger("reloadGrid");
	}
	$("#cbo_Estado").trigger("chosen:updated");
	function CargarEstados(callback)
	{	
		$("#cbo_Estado").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_estados_escolares.php",
			data: {
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0)
				{
					var option = "<option value='-1'>SELECCIONE</option>";
					for(var i=1;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Estado").html(option);
					$("#cbo_Estado").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'200px'});
					$("#cbo_Estado").trigger("chosen:updated");			
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" los estados", "", "gritter-warning");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
	}
	$("#cbo_Ciudad").trigger("chosen:updated");
	function CargarCiudades(callback)
	{
		$("#cbo_Ciudad").html("");
		$.ajax({
			type: "POST", 
			url: "ajax/json/json_fun_obtener_municipios_escolares.php?",
			data: {
				//'iEstado':$("#cbo_Estado").val()
				'iEstado':DOMPurify.sanitize($("#cbo_Estado").val())
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
						option = option + "<option value='" + dataJson.datos[i].numero + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_Ciudad").html(option);
					$("#cbo_Ciudad").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'200px'});
					$("#cbo_Ciudad").trigger("chosen:updated");
					
				}
				else
				{
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-warning");
				}
			},
			error:function onError(){callback();},
			complete:function(){callback();},
			timeout: function(){callback();},
			abort: function(){callback();}
		});
		
	}
	$("#cbo_Localidad").trigger("chosen:updated");
	function CargarLocalidades(){
		$("#cbo_Localidad").html("");
		 $.ajax({
			type: "POST",
			url: "ajax/json/json_fun_obtener_localidades_escolares.php?",
			data:{
				//'iMunicipio' : $("#cbo_Ciudad").val(),
				//'iEstado' : $("#cbo_Estado").val()
				'iMunicipio' : DOMPurify.sanitize($("#cbo_Ciudad").val()),
				'iEstado' : DOMPurify.sanitize($("#cbo_Estado").val())
			},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='-1'>SELECCIONE</option>";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].numero + "'>"  + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Localidad").html(option);
					$("#cbo_Localidad").chosen({no_results_text:"NO SE ENCUENTRA: ", width:'200px'});
					$("#cbo_Localidad").trigger("chosen:updated");
				}else{
					showalert(LengStrMSG.idMSG88+ " las localidades", "", "gritter-error");
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		 });
	}
	$("#cbo_Estado").change(function(){
		$("#cbo_Ciudad").val(-1);
		$("#cbo_Ciudad").val($("#cbo_Ciudad option").first().val());
		$("#cbo_Ciudad").trigger("chosen:selected");
		$("#cbo_Localidad").val(-1);
		$("#cbo_Localidad").val($("#cbo_Localidad option").first().val());
		$("#cbo_Localidad").trigger("chosen:selected");
		// $("#cbo_Localidad").val(0);
		// $("#cbo_Localidad").trigger("chosen:selected");
		$('#grid_ayudaEscuelas').jqGrid('clearGridData');
		CargarCiudades(function(){
			CargarLocalidades();
		});
		// CargarLocalidades();
	});
	$("#cbo_Ciudad").change(function(){
		CargarLocalidades();
	});
	$('#dlg_AyudaEscuelas').on('show.bs.modal', function (event) {
		// $("#cbo_Estado").val($("#cbo_Estado option").first().val());
		// $("#cbo_Ciudad").val($("#cbo_Ciudad option").first().val());
		$("#cbo_TipoConsulta").val($("#cbo_TipoConsulta option").first().val());
		$("#txt_NombreBusqueda").val("");
		$("#grid_ayudaEscuelas").jqGrid('clearGridData');
		
		
	});
	
	function LimpiarControles(){
		$('#txt_Numemp').val('');
		$('#txt_Nombre').val('');
		$('#txt_Centro').val('');
		$('#txt_NombreCentro').val('');
		$('#txt_FechaIngreso').val('');
		$('#ckb_especial').prop('checked', false);
		$('#ckb_limitado').prop('checked', false);
		$('#ckb_bloquear').prop('checked', false);
		$('#txt_Numemp').focus();		
	}

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 395
            }
        })
        .done(function(data){
            var dataS = limpiarCadena(data)
			var dataJson = JSON.parse(dataS);
            FlagHCM = dataJson.clvApagadoagado;
            MensajeHCM = dataJson.mensaje;

            if(FlagHCM == 1){
                loadContent({url:'ajax/frm/blank.php',dataIn:{mensaje:MensajeHCM}});
            }
        }); 
        
        
    }
});