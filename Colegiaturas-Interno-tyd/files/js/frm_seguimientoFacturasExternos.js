$(function(){
	CargarGridFacturas(1);
	llenarComboEstatus();
	var iUsuarioExterno = 0,
		iOpcion = 0,
		FechaIni = 0,
		FechaFin = 0,
		iEstatus = 0,
		cFolio = '',
		cNomEmpleadoExterno = ''
		iFactura = 0,
		iEmpleadoExterno = 0,
		sUrl = '';

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
	
	//------------------BOTON DE AYUDA DE LA PAG, PRINCIPAL
	// $('[data-rel=tooltip]').tooltip();
	// $('[data-rel=popover]').popover({container:'body'});
	
	
	$(document).ready(function(){
		$('input[title]').tooltip({placement:'right'});
	});
	
	// $("input[data-toggle='tooltip']").on('focus', function() {
		// $(this).tooltip('show');
	// });
	// $(document).ready(function(){
		// $('input[rel="tooltip"]').tooltip();
	// });
	
	iUsuarioExterno = $("#hid_idu_usuario").val();
	// validarUsuario();
	// iIduEmpleado = iUsuarioExterno;
	// alert(iUsuarioExterno);
	
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
	
	//--------------------------DATE PICKERS--------------------------
	$("#txt_FechaIni").datepicker({
		// showOn: 'both',
		dateFormat: 'dd/mm/yy',
		buttonImageOnly: true,
		numberOfMonths: 1,
		maxDate: "0D",
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
		maxDate: "0D",
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
			$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});
	$("#txt_FechaIni").datepicker("setDate",new Date());
	$("#txt_FechaFin").datepicker("setDate",new Date());
	
	$( "#txt_FechaIni" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaIni" ).val() );

	$(".ui-datepicker-trigger").css('display','none');

	$("#txt_FechaIni").prop('disabled', true);
	$("#txt_FechaFin").prop('disabled', true);	
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------C O N T R O L E S-----------------------------------------------------------------------------------------
//---------------	Text
	$("#txt_NumExterno").keydown(function(event){
		if(event.which == 8 || event.which == 46 || event.which == 110){
			$("#txt_NomExterno").val("");
			$("#txt_Folio").val("");
			$("#cbo_estatus").val(-1);
			$("#ckb_rango").prop('checked', false);
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
			$("#txt_Motivo").val("");
			LimpiarFechas();
			$("#gridFacturasExternos-table").jqGrid('clearGridData');
			sUrl = '';
			$("#gridFacturasExternos-table").jqGrid('setGridParam', 
				{ url:sUrl}).trigger("reloadGrid");
		}
	});	
	$("#txt_NomExterno").keydown(function(event){
		if(event.which == 8 || event.which == 46 || event.which == 110){
			$("#txt_NumExterno").val("");
			$("#txt_Folio").val("");
			$("#cbo_estatus").val(-1);
			$("#ckb_rango").prop('checked', false);
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);	
			$("#txt_Motivo").val("");			
			LimpiarFechas();
			$("#gridFacturasExternos-table").jqGrid('clearGridData');
			sUrl = '';
			$("#gridFacturasExternos-table").jqGrid('setGridParam', 
				{ url:sUrl}).trigger("reloadGrid");
			
		}
	});	
	$("#txt_Folio").keydown(function(event){
		if(event.which == 8 || event.which == 46 || event.which == 110){
			$("#txt_NumExterno").val("");
			$("#txt_NomExterno").val("");
			$("#cbo_estatus").val(-1);
			$("#ckb_rango").prop('checked', false);
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);	
			$("#txt_Motivo").val("");
			LimpiarFechas();
			$("#gridFacturasExternos-table").jqGrid('clearGridData');
			sUrl = '';
			$("#gridFacturasExternos-table").jqGrid('setGridParam', 
				{ url:sUrl}).trigger("reloadGrid");
		}
	});

	//----------------Checkbox Rango
	$("#ckb_rango").change(function(){
		if($("#ckb_rango").is(":checked")){
			$("#txt_FechaIni").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
			iOpcion = 1;
		}else{
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
			$("#txt_FechaIni").datepicker("setDate",new Date());
			$("#txt_FechaFin").datepicker("setDate",new Date());
			// LimpiarFechas();
			iOpcion = 0;
		}
		// alert(iOpcion);
	});
	//--------------Combo Estatus
	$("#cbo_estatus").change(function(){
		iEstatus = $("#cbo_estatus").val();
	});	
	
	//----------------------Boton consultar
	$("#btn_Consultar").click(function(event){
		if($("#txt_Folio").val().replace('/^\s+|\s+$/g', '') == '' && $("#txt_NumExterno").val().length<1 && $("#txt_NomExterno").val().replace('/^\s+|\s+$/g', '') == ''){
			showalert("Proporcione un número o nombre de externo o un folio fiscal", "", "gritter-info");
		}else if ($("#cbo_estatus").val() == -1){
			showalert("Seleccione un estatus", "", "gritter-info");
			$("#cbo_estatus").focus();
		}else{
			CargarGridFacturas();
		}
	})
	//-------------- F U N C I O N E S ----------------------------------------
	function llenarComboEstatus(){ //Llenar combo estatus
		var option="";
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_estatus_facturas_externos.php",
			data: { },
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0){
					option = option + "<option value='-1'>SELECCIONE</option>";
					// option = option + "<option value='-1'>TODOS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
					}
					$("#cbo_estatus").trigger("chosen:updated").html(option);
					$("#cbo_estatus").val(-1);
					$("#cbo_estatus").trigger("chosen:updated");
				}
				else{
					// message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-info");	
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});	
	}
	function validarUsuario(){
		$.ajax({
			type:"POST",
			data:{'iIduEmpleado' : iUsuarioExterno},
			url:'ajax/json/json_fun_validar_usuario_externo.php',
		}).done(function(data){
			json = json_decode(data);
			// console.log(json.mensaje);
			if(json.estado != 1){
				loadContent({url:'ajax/frm/blank.php', dataIn:{mensaje: json.mensaje}});
			}

			// alert(json);
		})
		.fail(function(s){alert("Error al cargar ajax/json/json_fun_validar_usuario_externo.php");})
		.always(function(){});
	}
	function LimpiarFechas(){
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		//$("#txt_FechaFin" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val())
		
	}	
	//-------------- G R I D    P R I N C I P A L  ----------------
	function CargarGridFacturas(inicializar){
		
		if($("#txt_NumExterno").val().replace('/^\s+|\s+$/g', '') != ''){
			iEmpleadoExterno = $("#txt_NumExterno").val()
		}else{
			iEmpleadoExterno = 0;
		}
		cFolio = $("#txt_Folio").val().replace('/^\s+|\s+$/g', '');
		cNomEmpleadoExterno = $("#txt_NomExterno").val().replace('/^\s+|\s+$/g', '').toUpperCase();
		if(iOpcion == 1){
			FechaIni = formatearFecha($("#txt_FechaIni").val());
			FechaFin = formatearFecha($("#txt_FechaFin").val());
		}else{
			FechaIni = '19000101';
			FechaFin = '19000101';
		}
		sUrl = 'ajax/json/json_fun_obtener_facturas_externos_seguimiento.php?session_name='+Session+'&';
		sUrl += 'iUsuarioExterno='+iUsuarioExterno + '&';
		sUrl += 'iEmpleadoExterno='+iEmpleadoExterno + '&';
		sUrl += 'sNomEmpleadoExterno='+cNomEmpleadoExterno + '&';
		sUrl += 'Fol_Fiscal='+cFolio + '&';
		sUrl += 'iOpcRango='+iOpcion + '&';
		sUrl += 'dFechaInicial='+FechaIni + '&';
		sUrl += 'dFechaFinal='+FechaFin + '&';
		sUrl += 'iEstatus='+iEstatus + '&';
		
		if(inicializar == 1){
			sUrl = '';
		}
		
		
		jQuery("#gridFacturasExternos-table").GridUnload();//------>Recarga Grid
		jQuery("#gridFacturasExternos-table").jqGrid({
			url:sUrl,
			datatype:'json',
			mtype:'GET',
			colNames:LengStr.idMSG95,
			colModel:[
			{name:'dfechafactura',			index:'dfechafactura',			width:120,		align:'center',	fixed:true},
			{name:'cfolfiscal',				index:'cfolfiscal',				width:350,		align:'left',	fixed:true},
			{name:'nimportefactura',		index:'nimportefactura',		width:120,		align:'right',	fixed:true},
			{name:'iprcdescuento',			index:'iprcdescuento',			width:100,		align:'right',	fixed:true},
			{name:'iDescuento',				index:'iDescuento',				width:100,		align:'center',	fixed:true, hidden:true},			
			{name:'nimportecalculado',		index:'nimportecalculado',		width:130,		align:'right',	fixed:true},
			{name:'ibeneficiarioexterno',	index:'ibeneficiarioexterno',	width:100,		align:'center',	fixed:true, hidden:true},
			{name:'cnombeneficiarioexterno',index:'cnombeneficiarioexterno',width:350,		align:'left',	fixed:true},
			{name:'dfecharegistro',			index:'dfecharegistro',			width:100,		align:'center',	fixed:true,	hidden:true},
			{name:'iestatus',				index:'iestatus',				width:100,		align:'center',	fixed:true,	hidden:true},
			{name:'snomestatus',			index:'snomestatus',			width:197,		align:'left',	fixed:true},
			{name:'dfechamarcoestatus',		index:'dfechamarcoestatus',		width:120,		align:'center',	fixed:true},
			{name:'ifactura',				index:'ifactura', 				width:50,		align:'left',	fixed:true,	hidden:true},
			{name:'sobservaciones',			index:'sobservaciones',			width:100,		align:'right',	fixed:true, hidden:true},
			
			],
			viewrecords:true,
			rowNum:10,
			rowList:[10,20,30],
			pager:'#gridFacturasExternos-pager',
			hidegrid: false,
			width:null,
			height:400,
			sortname:'dfecharegistro',
			sortorder:'asc',
			caption:'Facturas',
			loadComplete:function(data){
				var registros = jQuery("#gridFacturasExternos-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);				
			},
			onSelectRow:function(id){
				var selr = jQuery('#gridFacturasExternos-table').jqGrid('getGridParam','selrow');
				var rowData = jQuery("#gridFacturasExternos-table").getRowData(selr);
				iFactura = rowData.ifactura;
				var des = rowData.sobservaciones.toUpperCase();
				$("#txt_Motivo").val(des);
				// alert(iFactura);
			},
		});
		barButtongrid({
			pagId:"#gridFacturasExternos-pager",
			position:"left",
			Buttons:[
			{
				icon:"icon-list blue",
				click:function(event){
					// console.log('='+$("#gridFacturasExternos-table").find("tr").length);
					if (($("#gridFacturasExternos-table").find("tr").length - 1) == 0 ) 
					{
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					}
					else
					{
						VerFactura();
					}	
					event.preventDefault();						
				},
				title:"Ver Factura",
			},
			]
		});
		setSizeBtnGrid('id_button0', 35);
	}
	function setSizeBtnGrid(id,tamanio){
		$("#"+id).attr('width',tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"});
	}
	function VerFactura(){
		console.log('Ver factura');
		var selr = jQuery('#gridFacturasExternos-table').jqGrid('getGridParam','selrow');
		var rowData = jQuery("#gridFacturasExternos-table").getRowData(selr);
		if(iFactura != 0){
			console.log('selr');
			var rowData = jQuery("#gridFacturasExternos-table").getRowData(selr);
			
			$("#nIsFactura").val(0);
			// $("#sFacFiscal").val(rowData.cfolfiscal);
			$("#idfactura").val(rowData.ifactura);
			$("#sFilename").val('');
			$("#sFiliePath").val('');
			cargarFactura();
		} else {
			// console.log('no');
			showalert("Seleccione un registro", "", "gritter-info");
		}
	}
	
	function cargarFactura()
	{
		$.ajax({type: "POST",
			data:{session_name:Session
				,"nIsFactura": limpiarCadena($("#nIsFactura").val())
				// ,"sFacFiscal": $("#sFacFiscal").val()
				,"idFactura": $("#idfactura").val()
				,"sFilename": $("#sFilename").val()
				,"sFiliePath": $("#sFiliePath").val()
			},
			url: "ajax/json/json_leerfactura.php"})
		.done(function(data){
				SessionIs();
				var sanitizedData = limpiarCadena(data);
				data =json_decode(sanitizedData);
				if(data.estado == 0)
				{
					leerFactura(data);
				}
				else
				{
					loadIs = true;
					alert(data.mensaje);
				}
		})
		.fail(function(s) {alert("Error al cargar ajax/json/json_leerfactura.php"); $('#pag_content').fadeOut();})
		.always(function() {});
	}
	
	function leerFactura(obj)
	{
		if(obj.isFactura == 0)
		{
			$("#div_contenido").html("<img src='"+obj.noDeducible+"' alt='Error: 404 not found'/>");
		}
		else
		{		
			$("#div_contenido").html(obj.factura);//append('<iframe id="if_frame" src="'+obj.url+'" frameborder="0" scrolling="yes" width="100%" height="100%" 
			
			$("#btn_ver").click();
		}
		loadIs = true;
	}
});