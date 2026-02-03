$(function(){
	SessionIs();
	var iOpcion = 0,
		FechaIni = 0,
		FechaFin = 0,
		iUsuario = 0,
		iEstatus = 0,
		cFolio = '';
		
	 //** VULNERABILIDADES
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

	CargarGridFacturas(1);
	llenarComboEstatus();
	// Cargargrid();
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
	
	$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
	$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );

	$(".ui-datepicker-trigger").css('display','none');

	$("#txt_FechaIni").prop('disabled', true);
	$("#txt_FechaFin").prop('disabled', true);
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------C O N T R O L E S-----------------------------------------------------------------------------------------
	
	//----------------Checkbox Rango
	$("#ckb_rango").change(function(){
		if($("#ckb_rango").is(":checked")){
			$("#txt_FechaIni").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
			iOpcion = 1;
		}else{
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
			LimpiarFechas();
			iOpcion = 0;
		}
		// alert(iOpcion);
	});
	
	//--------------Combo Estatus
	$("#cbo_estatus").change(function(){
		iEstatus = $("#cbo_estatus").val();
	});
	
	//-----------------Numero de colaborador
	$("#txt_Numemp").keydown(function(event) {
		// console.log(event.which);
		if (event.which == 13 || event.which == 9 || event.which == 0){
			if($("#txt_Numemp").val().length == 8){
				Cargar_Empleado();
			}else {
				$("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Numemp").focus();
				//message('Ingrese un número de empleado para realizar la búsqueda');
				showalert(LengStrMSG.idMSG118, "", "gritter-info");
			}
		}
		if(event.which == 8 || event.which == 46 || event.which == 110){
			// $("#txt_Numemp").val("");
			$("#txt_Nombre").val("");
			$("#txt_Folio").val("");
			$("#cbo_estatus").val(-1);
			$("#ckb_rango").prop("checked", false);
			iOpcion = 0;
			$("#txt_FechaIni").datepicker("setDate",new Date());
			$("#txt_FechaFin").datepicker("setDate",new Date());
			$("#gridFacturasExt-table").jqGrid('clearGridData');
			sUrl = '';
			$("#gridFacturasExt-table").jqGrid('setGridParam',
				{url:sUrl}).trigger("reloadGrid");
		}
		if(event.which == 113){
			$("#dlg_BusquedaEmpleados").modal('show');
			CargarGridColaborador();
			event.preventDefault();
		}
	});
	$("#txt_Folio").keydown(function(event){
		if(event.which == 8 || event.which == 46 || event.which == 110){
			// $("#txt_Folio").val("");
			$("#txt_Numemp").val("");
			$("#txt_Nombre").val("");
			$("#cbo_estatus").val(-1);
			$("#ckb_rango").prop("checked", false);
			$("#txt_FechaIni").datepicker("setDate",new Date());
			$("#txt_FechaFin").datepicker("setDate",new Date());			
			$("#gridFacturasExt-table").jqGrid('clearGridData');
			sUrl = '';
			$("#gridFacturasExt-table").jqGrid('setGridParam',
				{url:sUrl}).trigger("reloadGrid");			
		}
	})
	$("#txt_Numemp").on('paste', function(event){
		var element = this;
		setTimeout(function(){
			var text = $(element).val();
			if($(element).val().length == 8 && (!isNaN(parseInt(text)) && isFinite(text))){
				$(element).val(text);
				$("#txt_Nombre").val("");
				$("#cbo_estatus").val(-1);
				$("#cbo_estatus").trigger("chosen:updated");
				$("#ckb_rango").prop('checked', false);
				Cargar_Empleado();
			}else{
				event.preventDefault();
			}
		})
	});
	$("#txt_Numemp").on('input propertychange', function(event){
		if($("#txt_Numemp").val().length != 8 || Number.isInteger(parseInt($("#txt_Numemp").val())) == false){
			$("#txt_Nombre").val("");
			$("#cbo_estatus").val(-1);
			$("#cbo_estatus").trigger("chosen:updated");
			$("#ckb_rango").prop('checked', false);
			$("#txt_FechaIni").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);			
		}else if($("#txt_Numemp").val().length == 8 && Number.isInteger(parseInt($("#txt_Numemp").val())) ){
			Cargar_Empleado();
		}
	});
	//----------------------Boton Consultar
	$("#btn_consultar").click(function(event){
		if($("#txt_Folio").val().replace('/^\s+|\s+$/g', '') == '' && $("#txt_Nombre").val().replace('/^\s+|\s+$/g', '') == ''){
			showalert("Proporcione un número de folio, o de colaborador", "", "gritter-info");
			$("#txt_Numemp").focus();
		}else if($("#cbo_estatus").val() == -1){
			showalert("Seleccione un estatus", "", "gritter-info");
			$("#cbo_estatus").focus();
		}else{
			// showalert('si la hace', '', 'gritter-info');
			fnConsultaFacturas();
		}
	});
	//-------------------------------------------------------------------------------------------------------------------
	//--------------------------F U N C I O N E S--------------------------------------
	function fnConsultaFacturas(){
			CargarGridFacturas();
		// })
	}
	function Cargar_Empleado(){//----> Datos del colaborador(Nombre)
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
					$("#txt_Numemp").val("");
					$("#txt_Numemp").focus();
			}
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
	
	function llenarComboEstatus() { //Llenar combo estatus
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
	function LimpiarFechas(){
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		//$("#txt_FechaFin" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val());
		
	}	
	//-----------------------------GRID FACTURAS--------------------------------------

	function CargarGridFacturas(inicializar){
		// alert('a');
		if($("#txt_Numemp").val().replace('/^\s+|\s+$/g', '') != ''){
			iUsuario = $("#txt_Numemp").val();
		}else{
			iUsuario = 0;
		}
		cFolio = $("#txt_Folio").val();
		if(iOpcion == 1){
			FechaIni = formatearFecha($("#txt_FechaIni").val());
			FechaFin = formatearFecha($("#txt_FechaFin").val());
			
		}else{
			FechaIni = '19000101';
			FechaFin = '19000101';
			formatearFecha(FechaIni);
			formatearFecha(FechaFin);
		}
		
		var sUrl = 'ajax/json/json_fun_consultar_facturas_externos.php?&session_name='+Session+'&';
		sUrl += 'iUsuario=' + iUsuario + '&';
		sUrl += 'Fol_Fiscal=' + cFolio + '&';
		sUrl += 'iOpcion=' + iOpcion + '&';
		sUrl += 'FechaIni=' + FechaIni + '&';
		sUrl += 'FechaFin=' + FechaFin + '&';
		sUrl += 'iEstatus=' + iEstatus + '&';
		
		if (inicializar == 1) {
			sUrl = '';
		}
		
		jQuery("#gridFacturasExt-table").GridUnload(); //------> Recarga GRID 
		jQuery("#gridFacturasExt-table").jqGrid({
			url:sUrl,
			datatype:'json',
			mtype:'GET',
			colNames:LengStr.idMSG90,
			colModel:[
				{name:'dfechafactura',	index:'dfechafactura'	,width:120,	align:"center", fixed:true},
				{name:'cfolfiscal',		index:'cfolfiscal'		,width:350,	align:"left", fixed:true},
				{name:'nimportefactura',index:'nimportefactura'	,width:120,	align:"right", fixed:true},
				{name:'iprcdescuento',	index:'iprcdescuento'	,width:80,	align:"right", fixed:true},
				{name:'idescuento',	index:'idescuento'	,width:80,	align:"center", fixed:true, hidden: true},
				{name:'nimportecalculado',	index:'nimportecalculado'	,width:130,	align:"right", fixed:true},
				{name:'ibeneficiarioexterno',index:'ibeneficiarioexterno',width:80,	align:"center", fixed:true, hidden:true},
				{name:'cnombeneficiarioexterno',	index:'cnombeneficiarioexterno'		,width:300,	align:"left", fixed:true},
				{name:'iempleadocaptura',	index:'iempleadocaptura',width:70,	align:"center", fixed:true, hidden:true},
				{name:'cnombrecaptura',	index:'cnombrecaptura', width:300,	align:"left", fixed:true},
				{name:'dfecharegistro',	index:'dfecharegistro'	,width:120,	align:"center", fixed:true},
			],
			scrollrows:true,
			width:1560,
			loadonce:false,
			shrinkToFit: false,
			height:400,
			rowNum:10,
			rowList:[10,20,30],
			pager:'#gridFacturasExt-pager',
			viewrecords : true,
			hidegrid: false,
			sortname: 'dfechafactura',
			sortorder:'asc',
			caption:'Listado de Facturas',
			//----------------------------------------------------------------------------------------------
			loadComplete: function(data){
				var registros = jQuery("#gridFacturasExt-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(id){},
		});
		barButtongrid({
			pagId:"#gridFacturasExt-pager",
			position:"left",
			Buttons:[
			{
				icon:"icon-print blue",
				click:function(event){
					if (($("#gridFacturasExt-table").find("tr").length - 1) == 0 ) {
						// showmessage('No existen registros para exportar', '', undefined, undefined, function onclose(){					
						// });
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					}
					else{
						GenerarPdf();
					}
					
					event.preventDefault();	
				},
				title:"Imprimir",
			},
			]
		});
		setSizeBtnGrid('id_button0', 35);
	}
		////////////////EXPORTAR PDF/////////////
	function GenerarPdf(){
				var sUrl = 'ajax/json/json_exportar_facturas_externos.php?&session_name='+Session+'&';
		sUrl += 'iUsuario=' + iUsuario + '&';
		sUrl += 'NomUsuario=' + $("#txt_Nombre").val().replace('/^\s+|\s+$/g', '') + '&';
		sUrl += 'Fol_Fiscal=' + cFolio + '&';
		sUrl += 'iOpcion=' + iOpcion + '&';
		sUrl += 'FechaIni=' + FechaIni + '&';
		sUrl += 'FechaFin=' + FechaFin + '&';
		sUrl += 'iEstatus=' + iEstatus + '&';
		
		location.href = sUrl; //'ajax/json/json_exportar_facturas_externos.php?&session_name=' + Session + '&iUsuarioExterno='+NumEmpleadoParametro+'&NombreEmpleado='+NomEmpleadoParametro;
	}
	function setSizeBtnGrid(id,tamanio){
		$("#"+id).attr('width',tamanio+'px');
		$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"});
	}
	
})	