$(function() {
	ConsultaClaveHCM();
	//alert(FlagHCM);
	


	fnCargarGrid();
	var idFactura=0;
	var FlagHCM = 0;
	var MensajeHCM = '';
	

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
	

	//-----------------VER FACTURA--------------------------
	//2707
	$("#btn_ver").on("click", function(event){
		var cnt_ver_factura = $( "#cnt_ver_factura" ).dialog({
			modal: true,
			title: "<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-ok'></i> Factura</h4></div>",
			title_html: true,
			width: 1800,
			height: 900,
			autoOpen: false,
			buttons: [
				{
					text: "Cerrar",
					"class" : "btn btn-primary btn-mini",
					click: function(){
						$("#gridFacturasExternos-table").jqGrid('resetSelection');
						iFactura = 0;
						$( this ).dialog( "close" );
					} 
				}
			]
		});
		
		cnt_ver_factura.dialog("open");
		event.preventDefault();
	});
	//-------------------FIN PARTE DE FUNCIONALIDAD DE VER FACTURA--------------------------
	
	//CARGAR GRID
	function fnCargarGrid()
	{		
		//console.log('Cargar Grid');
		jQuery("#gd_Facturas").jqGrid({
			url:'ajax/json/json_fun_obtener_facturas_externos.php?session_name=' +Session,			
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG91,
				colModel:[				
				{name:'id',index:'id', width:70, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'fechafactura',index:'fechafactura', width:150, sortable: false,align:"center",fixed: true},
				{name:'factura',index:'factura', width:300, sortable: false,salign:"left",fixed: true},
				{name:'importe',index:'importe', width:150, sortable: false,align:"right",fixed: true},
				{name:'porc_descto',index:'porc_descto', width:100, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'importe_calculado',index:'importe_calculado', width:100, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'id_beneficiario',index:'id_beneficiario', width:100, sortable: false,align:"right",fixed: true, hidden:true},
				{name:'beneficiario',index:'beneficiario', width:300, sortable: false,align:"left",fixed: true},
				{name:'id_factura',index:'id_factura', width:50, sortable: false,align:"right",fixed: true, hidden:true}
			],
			caption:'Listado de Facturas',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 200, 
			rowNum:10,
			rowList:[10, 20, 30],
			pager: '#gd_Facturas_pager',
			sortname: 'FechaFactura',
			sortorder: "asc",
			viewrecords: true,
			hidegrid:false,			
			loadComplete: function (datos) {
				/*if(registros == 0 && iMsjConsulta==1){					
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}*/	
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
				/*var Total;
				var grid = $('#gd_Facturas');
				Total = grid.jqGrid('getCol', 'importe', false, 'sum');
				$("#txt_Tolal").val(accounting.formatMoney(Total, "", 2));
				Total=0;
				Total = grid.jqGrid('getCol', 'importepago', false, 'sum');
				$("#txt_TolalPagado").val(accounting.formatMoney(Total, "", 2));*/
			},
			onSelectRow: function(id) {
				var fila = jQuery("#gd_Facturas").getRowData(id);
				idFactura = fila['id_factura'];
			},	
		});	
		
		//setSizeBtnGrid('id_button0',35);
		//setSizeBtnGrid('id_button1',35);
	}
	
	//ACTUALIZAR GRID
	function ActulizarGrid(){
		idFactura=0;
		$("#gd_Facturas").jqGrid('setGridParam', { url: 'ajax/json/json_fun_obtener_facturas_externos.php?session_name=' +Session}).trigger("reloadGrid");
	}

	//BOTON AUTORIZAR
	$("#btn_autorizar_factura").click(function(event){
		if (idFactura == 0) {
			showalert(LengStrMSG.idMSG432, "", "gritter-info");
		}else{
			$("#btn_autorizar_factura").prop('disabled', true);
			bootbox.confirm(LengStr.idMSG92, 
			function(result)
			{
				$("#btn_autorizar_factura").prop('disabled', false);
				if (result)
				{
					$.ajax({type:'POST',
						url:'ajax/json/json_fun_autorizar_factura_externo.php',
						//ajax/json/json_fun_grabar_estatus_factura.php',
						data:{
							'iFactura' : idFactura
							,'session_name': Session
						},
						beforeSend:function(){},
						success:function(data){
							dataJson = json_decode(data);
							if(dataJson.estado == 0)
							{
								showalert(dataJson.mensaje, "", "gritter-info");
								ActulizarGrid();
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
	});
	
	//BOTON CANCELAR		
	$('#btn_cancelar_factura').click(function(event) 
	{
		llenarComboMotivosRechazo();
		$('#txt_Justificacion_Rechazo').prop('disabled', true);
		if (idFactura == 0) {
			showalert(LengStr.idMSG114, "", "gritter-info");
		}else{
			$('#txt_Justificacion_Rechazo').val('');
			$("#dlg_JustificacionRechazo").modal('show');
		}		
		event.preventDefault();		
	});
	
	//BOTON RECHAZAR
	$("#btn_rechazar").click(function(event){
		$("#btn_rechazar").prop('disabled', true);
		//console.log ('Factura en rechazar='+idFactura);
		if (idFactura == 0) {
			showalert(LengStrMSG.idMSG432, "", "gritter-info");
		}else{
			str=$("#txt_Justificacion_Rechazo").val().makeTrim(" ");
			
			//console.log($("#cbo_motivo_rechazo").val());
			
			if ($("#cbo_motivo_rechazo").val() == 0){
				showalert("Favor de seleccionar motivo de rechazo", "", "gritter-info");
				return;
			}
			
			if (str=='') {
				showalert("Favor de agregar justificación", "", "gritter-info");
				return;
			}
			
			//console.log('msg confirmacion='+LengStrMSG.idMSG93);			
			bootbox.confirm(LengStr.idMSG93, 
			function(result)
			{
				$("#btn_rechazar").prop('disabled', false);
				if (result)
				{
					$.ajax({type:'POST',
						url:'ajax/json/json_fun_rechazar_factura_externo.php',						
						data:{
							'iFactura' : idFactura,
							'cObservaciones': $("#txt_Justificacion_Rechazo").val(),
							'iMotivoRechazo': $("#cbo_motivo_rechazo").val(),
							'session_name': Session							
						},
						beforeSend:function(){},
						success:function(data){
							dataJson = json_decode(data);
							if(dataJson.estado == 0)
							{
								showalert(dataJson.mensaje, "", "gritter-info");
								$("#dlg_JustificacionRechazo").modal('hide');
								ActulizarGrid();
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
	});
		
	//COMBO MOTIVOS RECHAZO
	function llenarComboMotivosRechazo(){
			var iOpcion = 3;
			$.ajax({type:'POST',
				url: 'ajax/json/json_fun_obtener_listado_motivos_combo.php?',
				data:{iOpcion},
				beforeSend:function(){},
				success:function(data){
					var dataS = sanitize(data)
					var dataJson = JSON.parse(dataS);
					var option="";
					option = option + "<option value='0'>SELECCIONE</option>";
					for(var i = 0; i < dataJson.datos.length; i++ ){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_motivo_rechazo").trigger("chosen:updated").html(option);
					$("#cbo_motivo_rechazo").trigger("chosen:updated");
				},
				error: function onError(){callback();},
				complete: function(){callback();},
				timeout: function(){callback();},
				abort: function(){callback();}
			});
		}
	
	/*
		if (idFactura == 0) {
			showalert(LengStrMSG.idMSG428, "", "gritter-info");
		}else{
			bootbox.confirm(LengStrMSG.idMSG93, 
			function(result)
			{
				if (result)
				{
					$.ajax({type:'POST',
						url:'ajax/json/json_fun_autorizar_factura_externo.php',
						//ajax/json/json_fun_grabar_estatus_factura.php',
						data:{
							'iFactura' : idFactura
							,'session_name': Session
						},
						beforeSend:function(){},
						success:function(data){
							dataJson = json_decode(data);
							if(dataJson.estado == 0)
							{
								showalert(dataJson.mensaje, "", "gritter-info");
								ActulizarGrid();
							}
						},
						error:function onError(){},
						complete:function(){},
						timeout: function(){},
						abort: function(){}
					});
				}
			});
		}*/
	//MOTIVOS DE RECHAZO
	$('#cbo_motivo_rechazo').change(function(event){
		var valor = $('#cbo_motivo_rechazo').val();
		// alert(valor);
		if( valor != 0){
			$("#txt_Justificacion_Rechazo").prop('disabled', false);
			$('#txt_Justificacion_Rechazo').focus();
		}else{
			$('#txt_Justificacion_Rechazo').prop('disabled', true);
		}
		event.preventDefault();
	})
	$("#btn_ver_factura").click(function(event){
		var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
		if(($("#gd_Facturas").find("tr").length - 1) == 0){
			showalert(LengStrMSG.idMSG86, "", "gritter-info");
		}else if(selr){
			VerFactura();
		}else{
			showalert(LengStrMSG.idMSG348, "", "gritter-info");	
		}
		event.preventDefault();	
	});
	
	function VerFactura(){
		//console.log("VER FACTURA--------------------------");
		var selr = jQuery('#gd_Facturas').jqGrid('getGridParam','selrow');
		var rowData = jQuery('#gd_Facturas').getRowData(selr);
		//if(idFactura != 0){
			$("#nIsFactura").val(0);
			// $("#sFacFiscal").val(rowData.factura);
			$("#idfactura").val(rowData.id_factura);
			$("#sFilename").val('');
			$("#sFiliePath").val('');
			
			cargarFactura();
		//}
	}
	
	function cargarFactura(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_leerfactura.php',
			data:{session_name : Session
				, 'nIsFactura' : $("#nIsFactura").val()
				// , 'sFacFiscal' : $("#sFacFiscal").val()
				, 'idFactura' : $("#idfactura").val()
				, 'sFilename' : $("#sFilename").val()
				, 'sFiliePath' : $("#sFiliePath").val() 
			},
		})
		.done(function(data){
			SessionIs();
			var dataS = sanitize(data)
			data = json_decode(dataS);
			if(data.estado == 0){
				leerFactura(data);
			}else{
				loadIs = true;
				showalert(data.mensaje, "", "gritter-info");
			}
		})
		.fail(function(s) {alert("Error al cargar ajax/json/json_leerfactura.php"); $('#pag_content').fadeOut();})
		.always(function() {});
	}
	function leerFactura(obj){
		if(obj.isFactura == 0){
			$("#div_contenido").html("<img src='"+obj.noDeducible+"' alt='Error: 404 not found'/>");
		}else{
			$("#div_contenido").html(obj.factura);
			$("#btn_ver").click();
		}
		loadIs = true;
	}

	function ConsultaClaveHCM(){
		$.ajax({type: "POST", 
			url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
			data: { 				
				'iOpcion': 381
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

