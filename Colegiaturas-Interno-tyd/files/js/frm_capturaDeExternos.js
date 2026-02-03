$(function(){
	ConsultaClaveHCM()
	SessionIs();
	$('[data-rel=tooltip]').tooltip();
	$('[data-rel=tooltip]').tooltip({container:'body'});
	$('[data-rel=popover]').popover({container:'body'});	
	//Variables Globales
	var	id_beneficiario = 0,
		id_empleado	= 0,
		nom_empleado = '',
		porcentaje_desc	= 0,
		id_bloqueado	= 0,
		fec_registro	= 0,
		id_empleado_agg = 0
		nom_empleado_registro = '';
	var nEmpleado = 0,
		sNombre = '',
		iDesc = 0;
		iBeneficiario = 0;
		
	Cargargrid();
	CargarDescuentos();
	stopScrolling(function(){
		dragablesModal();
	});
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

///// función para hacer trim una variable para evitar vulnerabilidad
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
//------------------------------- PESTAÑAS (TABS)----------------------
	$( '#tabs' ).tabs();
	function getSelectedTabIndex(){
		return $("#tabs").tabs('option', 'active');
	}
	$(".tabbable").tabs({
		beforeActivate: function (event, ui) {
			//console.log(ui.newPanel.attr('id'));
		}
	});
	$(".ui-tabs-anchor").click(function(){
		CambiarTab();
		Limpiar();
		// id_beneficiario = 0;
		// $("#gridExternos-table").jqGrid('resetSelection');
		// id_empleado = 0;
		// alert(sNombre);
	});
//----------------------------------------------------------------------
	// $("#txt_Numemp").focusout(function(event){
		// if($("#txt_Numemp").val().length == 8)
		// {
			// Cargar_Empleado();
		// }
		// else
		// {
			// $("#txt_Numemp").val("");
			// $("#txt_Nombre").val("");
			// message('Ingrese un número de empleado para realizar la búsqueda');
		// }		
		// event.preventDefault()
	// });
	$("#txt_Numemp").keydown(function(event) {
		// console.log(event.which);
		if (event.which == 13 || event.which == 9 || event.which == 0){
			if($("#txt_Numemp").val().length == 8){
				Cargar_Empleado();
			}else{
				$("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Numemp").focus();
				//message('Ingrese un número de empleado para realizar la búsqueda');
				showalert(LengStrMSG.idMSG118, "", "gritter-info");
			}
		}
		if(event.which == 113){
			$("#dlg_BusquedaEmpleados").modal('show');
			$("#txt_NombreEBusqueda").focus();
			CargarGridColaborador();
			event.preventDefault();
		}
		if(event.which == 8 || event.which == 46 || event.which == 110){
			$("#txt_Nombre").val('');
		}
	});	

	$("#txt_Numemp").on('input propertychange', function(event){
		//if($("#txt_Numemp").val().length != 8 || ($.isNumeric($("#txt_Numemp").val())) == false){
		if($("#txt_Numemp").val().length != 8 || (Number.isInteger(parseInt($("#txt_Numemp").val()))) == false){ // se cambia funcion por vulnerabilidad
			$("#txt_Nombre").val('');
			$("#cbo_DescuentoNum").val(0);
			$("#cbo_DescuentoNum").trigger("chosen:updated");
		//}else if($("#txt_Numemp").val().length == 8 && $.isNumeric($("#txt_Numemp").val()) ){
		}else	if($("#txt_Numemp").val().length == 8 && (Number.isInteger(parseInt($("#txt_Numemp").val()))) ){// se cambia funcion por vulnerabilidad
			Cargar_Empleado();
		}
	});
	$("#txt_NomEmp").on('paste', function(event){
		$("#cbo_DescuentoNom").val(0);
		$("#cbo_DescuentoNom").trigger("chosen:updated");
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
	
	function Cargar_Empleado(){
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
			}/*else if (json[0].cancelado == 1){
				showalert(LengStrMSG.idMSG120, "", "gritter-info");
				// showmessage('Empleado Cancelado', '', undefined, undefined, function onclose(){
					$("#txt_Nombre").val('');
					$("#txt_Numemp").val('');
					$("#txt_Numemp").focus();
			}*/
			else {	
					 $("#txt_Nombre").val(json[0].nombre+' '+json[0].appat+' '+json[0].apmat);
				 }
			})
		.fail(function(s) {
			//alert("Error al cargar " + url ); 
			showalert(LengStrMSG.idMSG88+' los datos del empleado', "", "gritter-info");
		})	
		.always(function() {});
	}	
//-------------------------------------------------BOTON GUARDAR-------------------------------------------	
	$("#btn_GuardarNum").click(function(){
		if($("#txt_Numemp").val().makeTrim(" ") == ''){
			showalert("Favor de ingresar número de colaborador", "", "gritter-info");
			$("#txt_Numemp").focus();
			//console.log(iBeneficiario);
		}else if($("#txt_Numemp").val().length < 8){
			showalert("Proporcione un número de colaborador valido", "", "gritter-info");
			$("#txt_Numemp").focus();
			$("#txt_Nombre").val('');
		}else if($("#cbo_DescuentoNum").val() == 0){
			showalert("Seleccione un descuento", "", "gritter-info");
			$("#cbo_DescuentoNum").focus();
		}else{
			GuardarExterno();
		}
	});
	$("#btn_GuardarNom").click(function(){
		if($("#txt_NomEmp").val().makeTrim(" ") == '' || $("#txt_NomEmp").val().length < 5){
			showalert("Favor de ingresar nombre del colaborador", "", "gritter-info");
			$("#txt_NomEmp").focus();
			//console.log(iBeneficiario);
		}else if($("#cbo_DescuentoNom").val() == 0){
			showalert("Seleccione un descuento", "", "gritter-info");
			$("#cbo_DescuentoNom").focus();
		}else{
			GuardarExterno();
		}
	});
	////------------------------------------------- GRIDS----------------------------------
	function Cargargrid(){
		jQuery("#gridExternos-table").GridUnload();
		jQuery("#gridExternos-table").jqGrid({
			url:'ajax/json/json_fun_obtener_beneficiarios_externos.php?&iOpcion=1&session_name='+Session,
			datatype:'json',
			mtype:'GET',
			colNames:LengStr.idMSG82,
			// idMSG82:["Número Beneficiario", "Número Empleado", "Nombre De", "Porcentaje Descuento", "Bloqueado", "Fecha Captura", "iCapturo", "Colaborador Capturó"],
			colModel:[
			{name:'idu_beneficiario',	index:'idu_beneficiario',	width:250, sortable:true, align:'left', fixed:true, hidden:true},
			{name:'idu_empleado',		index:'idu_empleado',		width:250, sortable:true, align:'left', fixed:true, hidden:true},
			{name:'nom_empleado',		index:'nom_empleado',		width:350, sortable:true, align:'left', fixed:true},
			{name:'snom_emp',			index:'snom_emp',			width:350, sortable:true, align:'left', fixed:true, hidden:true},
			{name:'iDescuento', 		index:'iDescuento',			width:100, sortable:true, align:'center', fixed:true, hidden:true},
			{name:'prc_descuento', 		index:'prc_descuento',		width:187, sortable:true, align:'center', fixed:true},
			{name:'iBloqueado',			index:'iBloqueado',			width:150, sortable:true, align:'center', fixed:true, hidden:true},
			{name:'opc_beneficiario_bloqueado', index:'opc_beneficiario_bloqueado',	width:150, sortable:true, align:'center', fixed:true},
			{name:'fec_registro', 		index:'fec_registro', 		width:150, sortable:true, align:'center', fixed:true},
			{name:'idu_empleado_registro',	index:'idu_empleado_registro', 	width:250, sortable:true, align:'left', fixed:true, hidden:true},
			{name:'nom_empleado_registro', 	index:'nom_empleado_registro', 	width:350, sortable:true, align:'left', fixed:true},
			],
			caption:'Listado Externos',
			scrollsrows: true,
			viewrecords: true,
			width:null,
			height: 450,
			rowNum:-1,
			// rowList:[10, 20, 30],
			pager:'#gridExternos-pager',
			hidegrid:false,
			sortname:'fec_registro',
			sortorder:'asc',
			pgbuttons:false,
			pgtext:null,
			loadComplete:function(Data){
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);				
			},
			onSelectRow:function(id){
				if(id >= 0){
					var row = jQuery("#gridExternos-table").getRowData(id);
					id_beneficiario = row['idu_beneficiario'];
					id_empleado		= row['idu_empleado'];
					nom_empleado	= row['snom_emp'];
					porcentaje_desc	= row['iDescuento'];
					id_bloqueado	= row['iBloqueado'];
					fec_registro	= row['fec_registro'];
					id_empleado_agg = row['idu_empleado_registro'];
					nom_empleado_registro = row['nom_empleado_registro'];
					// showalert(id_bloqueado, "", "gritter-info");
				}
			},
			
		});
		
		barButtongrid({
			pagId:"#gridExternos-pager",
			position:"left",//center rigth
			Buttons:[{
				icon:"icon-lock red",
				click:function (event){
					if(id_beneficiario > 0){
						if(id_bloqueado == 0){
							bootbox.confirm("Se rechazarán todas las facturas de este beneficiario, ¿Desea bloquearlo?",
							function(result){
								if(result){
									BloquearExterno();
								}
							});							
						}else{
							bootbox.confirm("¿Desea desbloquear al beneficiario?",
							function(result){
								if(result){
									BloquearExterno();
								}else if(!result){
									$("#gridExternos-table").jqGrid('resetSelection');
									id_beneficiario = 0;
								}
							});
						}
					}else{
						showalert("Seleccione un registro", "", "gritter-info");
					}
				},
				title:"Bloquear/Desbloquear",
			},
			{
				icon:"icon-edit orange",
				click:function(event){
					// alert(id_beneficiario);
					if(id_beneficiario > 0){
						if (id_empleado != 0) {
							if (id_bloqueado == 1){
								showalert("Externo bloqueado", "", "gritter-info");
								$("#txt_Numemp").val("");
								$("#txt_Nombre").val("");
								$("#txt_NomEmp").val("");
								$("#cbo_DescuentoNom").val(0);
								$("#cbo_DescuentoNum").val(0);
								return;
							} else {
								$('#tabs a[href="#porNumero"]').tab('show');
								$('#tabs a[href="#porNumero"]').trigger('click');
								$("#txt_Numemp").val(id_empleado);
								$("#txt_Nombre").val(nom_empleado);
								$("#cbo_DescuentoNum").val(porcentaje_desc);
								$("#cbo_DescuentoNum").trigger("chosen:updated");
								iBeneficiario = id_beneficiario;
								$("#txt_Numemp").prop("readOnly", true);
							}
						} else {
							if(id_bloqueado == 1){
								showalert("Externo bloqueado", "", "gritter-info");
								$("#txt_Numemp").val("");
								$("#txt_Nombre").val("");
								$("#txt_NomEmp").val("");
								$("#cbo_DescuentoNom").val(0);
								$("#cbo_DescuentoNum").val(0);
								return;
							} else {
								$('#tabs a[href="#porNombre"]').tab('show');
								$('#tabs a[href="#porNombre"]').trigger('click');
								nEmpleado = 0;
								iBeneficiario = id_beneficiario;
								$("#txt_NomEmp").val(nom_empleado);
								$("#cbo_DescuentoNom").val(porcentaje_desc);
								$("#cbo_DescuentoNom").trigger("chosen:updated");
								$("#txt_NomEmp").prop("readOnly", true);
							}
						}
					}else{
						showalert("Seleccione un registro", "", "gritter-info");
					}
				},
				title:"Editar",
			},
			]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
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
			ondblClickRow: function(clave) {
				var Data = jQuery("#grid_colaborador").jqGrid('getRowData',clave);
				$("#txt_Numemp").val(Data.num_emp);
				$("#txt_Nombre").val(Data.nombre + ' ' + Data.apepat + ' ' + Data.apemat);
				$("#dlg_BusquedaEmpleados").modal('hide');
			}
		});	
	}		
	function setSizeBtnGrid(id,tamanio){
	$("#"+id).attr('width',tamanio+'px');
	$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
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
            var $class = (icon.attr('class').replace('ui-icon', ''));
			$class = $class.makeTrim(" ");
           
            if($class in replacement) icon.attr('class', 'ui-icon '+replacement[$class]);
        })
    }	
	//--------------------------------------------------------------------------------------------
	function CambiarTab(){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				$('#porNumero').css('display','block');
				$('#porNombre').css('display','none');
				nEmpleado = $("#txt_Numemp").val();
				sNombre = $("#txt_Nombre").val().toUpperCase();
				sNombre = sNombre.makeTrim(" ");
				iDesc = $("#cbo_DescuentoNum").val();
				$("#txt_Numemp").prop("readOnly", false);
			break;
			case 1:
				$('#porNumero').css('display','none');
				$('#porNombre').css('display','block');	
				nEmpleado = 0;
				sNombre = $("#txt_NomEmp").val().toUpperCase();
				sNombre = sNombre.makeTrim(" ");
				iDesc = $("#cbo_DescuentoNom").val();
				$("#txt_NomEmp").prop("readOnly", false);
			break;
			default:
			break;
			
		}
	}
	function CargarDescuentos()
	{
		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_obtener_descuentos_colegiaturas.php',
			data: {},
			beforeSend:function(){},
			success:function(data){
				var dataS = sanitize(data);
				dataJson = json_decode(dataS);
				if(dataJson.estado == 0)
				{
					var option = "<option value='0'>SELECCIONE</option>";//<option value='0'>SELECCIONE</option>;<option value='0'>TODAS LAS SECCIONES</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
					}
					$("#cbo_DescuentoNum").html(option);
					$("#cbo_DescuentoNom").html(option);
					var Sel = $("#cbo_DescuentoNum").first().val();
					$("#cbo_DescuentoNum").val(Sel);
					$("#cbo_DescuentoNum" ).trigger("chosen:updated");
					$("#cbo_DescuentoNom").val(Sel);
					$("#cbo_DescuentoNom").trigger("chosen:updated");
					
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
	function GuardarExterno(){
		var tab =$("#tabs").tabs('option', 'active');
		switch(tab)
		{
			case 0:
				nEmpleado = $("#txt_Numemp").val();
				sNombre = $("#txt_Nombre").val().toUpperCase();
				sNombre = sNombre.makeTrim(" ");
				iDesc = $("#cbo_DescuentoNum").val();
				break;
			case 1:
				nEmpleado = 0;
				sNombre = $("#txt_NomEmp").val().toUpperCase();
				sNombre = sNombre.makeTrim(" ");
				iDesc = $("#cbo_DescuentoNom").val();
				break;
		}
			$.ajax({
				type:'POST',
				url:'ajax/json/json_fun_grabar_beneficiario_externo.php',
				data:{
					'session_name'	: Session,
					'iBeneficiario' : iBeneficiario,
					'iEmpleado'		: nEmpleado,
					'sNomEmpleado'	: sNombre,
					'iDescuento'	: iDesc,
					'iBloqueado'	: 0
				}
			}).done(function(data){
				var dataJson = JSON.parse(data);
				//console.log(dataJson);
				showalert(dataJson.mensaje, "", "gritter-info");
				iEmpleado = 0;
				nEmpleado = 0;
				iBeneficiario = 0;
				id_beneficiario = 0;
				Cargargrid();
				$("#txt_Numemp").prop("readOnly", false);
				$("#txt_NomEmp").prop("readOnly", false);
				Limpiar();
				// $()
			})
	}
	function BloquearExterno(){
		$.ajax({
			type: 'POST',
			url:'ajax/json/json_fun_bloquear_beneficiario_externo.php',
			data:{
				'session_name'	: Session,
				'iBeneficiario'	: id_beneficiario,
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			//console.log(dataJson);
			showalert(dataJson.mensaje, "", "gritter-info");
			id_beneficiario = 0;
			Cargargrid();
		})
		
	}
	function Limpiar(){
		$('#txt_Numemp').val('');
		$('#txt_Nombre').val('');
		$('#txt_NomEmp').val('');
		$("#cbo_DescuentoNom").val(0);
		$("#cbo_DescuentoNum").val(0);
	}	

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 385
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