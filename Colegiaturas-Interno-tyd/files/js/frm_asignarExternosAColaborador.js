$(function(){
	ConsultaClaveHCM()
	SessionIs();
	
	$('[data-rel=tooltip]').tooltip();
	$('[data-rel=tooltip]').tooltip({container:'body'});
	$('[data-rel=popover]').popover({container:'body'});
	var iEmpleado = 0,
		iBeneficiarios = 0;
	Cargargrid();
	stopScrolling(function(){
		dragablesModal();
	})
	
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

	function stopScrolling(callback) {
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
	//----------------------------------------- C O N T R O L E S ---------------------------------------------------------
	$("#txt_Numemp").keydown(function(event) {
		//console.log(event.which);
		if (event.which == 13 || event.which == 9 || event.which == 0){
			if($("#txt_Numemp").val().length == 8){
				// Cargar_Empleado();
				iEmpleado = $("#txt_Numemp").val();
				validarUsuario();
				// console.log(iEmpleado);
			// $("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
			}else{
				$("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Centro").val("");
				$("#txt_Puesto").val("");
				$("#txt_Numemp").focus();
				//message('Ingrese un número de empleado para realizar la búsqueda');
				showalert(LengStrMSG.idMSG118, "", "gritter-info");
			}
		}
		if(event.which == 8 || event.which == 46 || event.which == 110){
				// $("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Centro").val("");
				$("#txt_Puesto").val("");
				$("#txt_Numemp").focus();
				$("#gridExternos-table").jqGrid('clearGridData');
		}
		if(event.which == 113){
			$("#dlg_BusquedaEmpleados").modal('show');
			$("#txt_NombreEBusqueda").focus();
			CargarGridColaborador();
			event.preventDefault();
		}
	});
	$("#txt_Numemp").on('input propertychange', function(event){
		if($("#txt_Numemp").val().length != 8 || Number.isInteger(parseInt($("#txt_Numemp").val())) == false){
			LimpiarControles();
			$("#gridExternos-table").jqGrid('clearGridData');
		}else if($("#txt_Numemp").val().length == 8 && Number.isInteger(parseInt($("#txt_Numemp").val())) ){
			CargarGridColaborador();
		}
	});
	$("#txt_Numemp").on('paste', function(event){
		var element = this;
		setTimeout(function(){
			var text = $(element).val();
			if($(element).val().length == 8 && $(!isNaN(parseInt(text)) && isFinite(text))){
				$("#txt_Centro").val('');
				$("#txt_Puesto").val('');
				$("#txt_Nombre").val('');
				$("#gridExternos-table").jqGrid('clearGridData');
				CargarGridColaborador();
			}
		})
	})
	//-------------------------------------------B O T O N E S ----------------------------------------------
	$("#btn_Consultar").click(function(){
		if($("#txt_Numemp").val().replace('/^\s+|\s+$/g', '') == ''){
			showalert(LengStrMSG.idMSG118, "", "gritter-info");
			$("#txt_Numemp").focus();
		}else if($("#txt_Numemp").val().length < 8){
			showalert("Proporcione un número de colaborador valido", "", "gritter-info");
			$("#txt_Centro").val('');
			$("#txt_Puesto").val('');
			$("#txt_Nombre").val('');
			// $("#txt_Numemp").val('');
			$("#txt_Numemp").focus();
		}else{
			iEmpleado = $("#txt_Numemp").val();
			if($("#txt_Nombre").val() != ''){
				$("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
			}else{
				event.preventDefault();
			}
		}
	})
	$("#btn_Otro").click(function(){
		$("#txt_Numemp").val("");
		$("#txt_Nombre").val("");
		$("#txt_Centro").val("");
		$("#txt_Puesto").val("");
		$("#gridExternos-table").jqGrid('clearGridData');
		$("#txt_Numemp").focus();
	});
	$("#btn_Guardar").click(function(){
		if($("#txt_Nombre").val().replace('/^\s+|\s+$/g', '') == '' || $("#txt_Numemp").val() == 00000000 || $("#txt_Numemp").val().replace('/^\s+|\s+$/g', '') == '' || $("#txt_Numemp").val().length < 8){
			showalert(LengStrMSG.idMSG118, "", "gritter-info");
			$("#txt_Nombre").val('');
			$("#txt_Numemp").val('');
			$("#txt_Centro").val('');
			$("#txt_Puesto").val('');			
			$("#txt_Numemp").focus();
		}else if (($("#gridExternos-table").find("tr").length - 1) == 0 ) {
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		}else
		{
			iBeneficiarios = obtenerBeneficiariosSeleccionados();
			GuardarBeneficiarios();
		}	
		event.preventDefault();	
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
//------------------Al Cerrar el modal
	$("#dlg_BusquedaEmpleados").on("hide.bs.modal", function(event){
			$("#txt_NombreEBusqueda").val("");
			$("#txt_apepatbusqueda").val("");
			$("#txt_apematbusqueda").val("");
			$('#grid_colaborador').jqGrid('clearGridData');
	});	

	//---------------------------------------- F U N C I O N E S ----------------------------------------------
	function validarUsuario(){
		$.ajax({
			type:"POST",
			data:{'iIduEmpleado': iEmpleado},
			url:'ajax/json/json_fun_validar_usuario_externo.php',
		}).done(function(data){
			json = json_decode(data);
			// console.log(json.mensaje);
			if(json.estado != 1){
				// loadContent({url:'ajax/frm/blank.php', dataIn:{mensaje: json.mensaje}});
				showalert(json.mensaje, "", "gritter-info");
				return;
			} else {
				Cargar_Empleado();
			}
		})
		.fail(function(s){alert("Error al cargar ajax/json/json_fun_validar_usuario_externo.php");})
		.always(function(){callback();});
	}
	//---------------------------------------------------------------------------------------------------------
	function GuardarBeneficiarios(){//Guardar Beneficiarios
		// alert("a")
		if(iBeneficiarios == ''){
			iBeneficiarios = '0';
		}else{
			iBeneficiarios = iBeneficiarios;
		}
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_asignar_beneficiarios_externos.php',
			data:{
				'session_name' : Session,
				'iEmpleado' : $("#txt_Numemp").val(),
				'sBeneficiarios' : iBeneficiarios
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson.estado == 1){
				if(iBeneficiarios!='0'){
					showalert("Beneficiarios asignados correctamente", "", "gritter-success");
					$("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
				}else{
					showalert("Beneficiarios desasignados correctamente", "", "gritter-info");
					$("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
				}
			}else if(dataJson.estado == 2){
				showalert("El colaborador no tiene permisos asignados", "","gritter-info");
				// $("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
			}else if(dataJson.estado == 3){
				showalert("El colaborador no tiene permisos vigentes", "", "gritter-info");
				// $("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
			}
			// showalert(dataJson.mensaje, "", "gritter-info");
			// $("#gridExternos-table").jqGrid('setGridParam',{url:'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php?iEmpleado='+iEmpleado}).trigger("reloadGrid");
			
		})
	}
	//-----------------------------------------------------------
	function Cargar_Empleado(){//Datos del colaborador (MODAL)
		var respon = $('#txt_Numemp').val();	
		$.ajax({type: "POST",
			url: 'ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php',
			data: {
					'iEmpleado':respon
				  }
			})
			.done(function(data){
			json = JSON.parse(data);
			if(json==null){
				showalert(LengStrMSG.idMSG119, "", "gritter-info");
				//showmessage('El Empleado no Existe', '', undefined, undefined, function onclose(){
					$("#txt_Nombre").val('');
					$("#txt_Numemp").val('');
					$("#txt_Numemp").focus();
					
				// });
			}else if (json[0].cancelado == 1){
				showalert(LengStrMSG.idMSG120, "", "gritter-info");
				// showmessage('Empleado Cancelado', '', undefined, undefined, function onclose(){
					$("#txt_Nombre").val('');
					$("#txt_Numemp").val('');
					$("#txt_Numemp").focus();
			}
			else {	
					 $("#txt_Nombre").val(json[0].nombre+' '+json[0].appat+' '+json[0].apmat);
					 $("#txt_Puesto").val(json[0].puesto+' '+json[0].nombrepuesto);
					 $("#txt_Centro").val(json[0].centro+' '+json[0].nombrecentro);
				 }
			})
		.fail(function(s) {
			//alert("Error al cargar " + url ); 
			showalert(LengStrMSG.idMSG88+' los datos del empleado', "", "gritter-info");
		})	
		.always(function() {});
	}
	//-------------------------------------------------------------------------------------------------------------
	function obtenerBeneficiariosSeleccionados(){//Obtener beneficiarios Seleccionados del grid
		sBeneficiarios = "";
		cnt = 0;
		for(var i = 0; i < $("#gridExternos-table").find("tr").length; i++) {
			var data = $("#gridExternos-table").jqGrid('getRowData',i);
			
			if (data.opc_seleccionado == "True") {
				if (cnt == 0) {
					sBeneficiarios += '' + data.idu_beneficiario;
					// console.log(sBeneficiarios);
				} else {
					sBeneficiarios += ',' + data.idu_beneficiario;
					// console.log(sBeneficiarios);
				}
				cnt++;
				// console.log(sBeneficiarios);
			}
		}
		return sBeneficiarios;
	}	
	//=====================================================================GRIDS==========================================================================================

	//-------------- G R I D    P R I N C I P A L  ----------------
	function Cargargrid(){
		jQuery("#gridExternos-table").jqGrid({
			url:'',//'ajax/json/json_fun_obtener_beneficiarios_externos_empleado.php',
			datatype:'json',
			mtype:'POST',
			colNames:LengStr.idMSG85,
			colModel:[
				{name:'opc_seleccionado',index:'opc_seleccionado', width:100, sortable: false,align:"center",fixed: true,
						edittype:'checkbox', editable:true, editoptions:{value:"True:False"},
						formatter:'checkbox', formatoptions:{disabled:false}},
				{name:'idu_beneficiario',index:'idu_beneficiario', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_beneficiario',index:'nom_beneficiario', width:320, sortable: false,align:"left",fixed: true},
				{name:'fec_registro',index:'fec_registro', width:180, sortable: false,align:"center",fixed: true},
				{name:'idu_empleado_registro',index:'idu_empleado_registro', width:100, sortable: false,align:"left",fixed: true, hidden:true },
				{name:'nom_empleado_registro',index:'nom_empleado_registro', width:320, sortable: false,align:"left",fixed: true},
			],
			viewrecords: false,
			rownum:-1,
			hidegrid:false,
			rowlist:[],
			pager:"#gridExternos-pager",
			multiselect: false,
			width: null,
			shrinkToFit: true,
			height:350,//null
			caption:'Externos',
			pgbuttons:false,
			pgtext:null,
			postData:{},
			loadComplete:function(data){
				var registros = jQuery("#gridExternos-table").jqGrid('getGridParam', 'reccount');
				// alert("Cantidad de Registros ="+registros);
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}				
				// opc_seleccionado = $(this).is(":checked") ? 1 : 0;
				$('#gridExternos-table :checkbox').change(function(e){
					var id = $(e.target).closest('tr')[0].id;
					var rowData = $('#gridExternos-table').getRowData(id);
					opc_seleccionado = $(this).is(":checked") ? 1 : 0;
					$("#gridExternos-table").jqGrid("setCell", id, "opc_seleccionado", opc_seleccionado);
				});
				// console.log(opc_seleccionado);
				
			},
			onSelectRow:function(id){},
		});
	}
	//-------------- G R I D    M O D A L     C O L A B O R A D O R E S   ----------------
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
			caption: 'Catálogo de Colaboradores',
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
			ondblClickRow: function(clave){
				var Data = jQuery("#grid_colaborador").jqGrid('getRowData',clave);
				$("#txt_Numemp").val(Data.num_emp);
				$("#txt_Nombre").val(Data.nombre + ' ' + Data.apepat + ' ' + Data.apemat);
				$("#txt_Centro").val(Data.centro + ' ' + Data.nombreCentro);
				$("#txt_Puesto").val(Data.puesto + ' ' + Data.nombrePuesto);
				iEmpleado = Data.num_emp;
				validarUsuario();
				$("#dlg_BusquedaEmpleados").modal('hide');
				// ConsultaEmpleado(
					// function(){ fnObtenerDatosEmpleado(
						// function(){
							// CargarBeneficiario(0);
							// CargarEstudio(1);
						// }
					// );
				// });
			}
		});
	}

	function LimpiarControles(){
		$("#txt_Nombre").val('');
		$("#txt_Puesto").val('');
		$("#txt_Centro").val('');
	}	

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 384
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