$(function(){
	ConsultaClaveHCM()
	SessionIs();
	CargarComboOpcion();

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

	//////Variables globales
	var ClaveGrid 
		, MensajeGrid
		, iduOpcion 
		, desOpcion 
		, Fec_iniGRid 
		, Fec_finGrid 
		, IndefinidoGrid 
		, OpcionGrid;
	CargarGrid();	
	
	///////////////////////GRID///////////////////////////////////////
	function CargarGrid()	
	{
		jQuery("#gridAvisosColaboradores-table").jqGrid({
		url:'ajax/json/json_fun_obtener_listado_avisos_colegiaturas.php',
		datatype: 'json',
		mtype: 'GET',
		colNames:LengStr.idMSG40,
			colModel:[
				{name:'idu_aviso',index:'idu_aviso', width:55, sortable: false,align:"center",fixed: true},
				{name:'des_aviso',index:'des_aviso', width:450, sortable: false,align:"left",fixed: true},
				{name:'idu_opcion',index:'idu_opcion', width:200, sortable: false,align:"center",fixed: true, hidden:true},
				{name:'des_opcion',index:'des_opcion', width:250, sortable: false,align:"left",fixed: true, hidden:true},
				{name:'opcion',index:'opcion', width:245, sortable: false,align:"left",fixed: true},
				{name:'fec_ini', index:'fec_ini', width:90, sortable: false, align:"center", fixed: true },
				{name:'fec_fin', index:'fec_fin', width:90, sortable: false, align:"center", fixed: true },
				{name:'indefinido',index:'indefinido', width:80, align: 'center', formatter: 'checkbox', edittype: 'checkbox', editoptions: {value: '1:0', defaultValue: '1'}},
				{name:'empleado_capturo', index:'empleado_capturo', width:75, sortable:false, align:"left", fixed: true, hidden:true },
				{name:'empleado_capturo_nombre', index:'empleado_capturo_nombre', width:320, sortable: false, align:"left", fixed: true }
			],
			
			caption:'Configuración de Avisos',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 380,
			rowNum:-1, //20,
			// rowList:[20, 40, 60, 80],
			pager:'#gridAvisosColaboradores-pager',
			sortname: 'idu_opcion, idu_aviso',
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
			var Data = jQuery("#gridAvisosColaboradores-table").jqGrid('getRowData',Numemp);
				ClaveGrid = Data.idu_aviso;
				MensajeGrid = Data.des_aviso;
				iduOpcion = Data.idu_opcion;
				desOpcion = Data.des_opcion;
				Fec_iniGRid = Data.fec_ini;
				Fec_finGrid = Data.fec_fin;
				IndefinidoGrid = Data.indefinido;
				NumEmpCapturo = Data.empleado_capturo;
			}
			
		});	
		
		 barButtongrid({
			pagId:"#gridAvisosColaboradores-pager",
			position:"left",
			Buttons:[
			{
				icon:"icon-edit orange bigger-140",	
				title:'Editar Aviso',
				click: function(event)
				{
					var fila = jQuery("#gridAvisosColaboradores-table").jqGrid('getGridParam', 'selrow');	
					if(fila == null)
					{	
						// showalert(LengStrMSG.idMSG222, "", "gritter-info");
						showalert("Seleccione registro a editar", "", "gritter-info");
					}
					else
					{	
						$('#txt_Clave').val(ClaveGrid);
						$('#txt_mensaje').val(MensajeGrid);
						if(IndefinidoGrid == 1)
						{
							$("#chk_indefinido").prop("checked", "checked");
							$('#dp_FechaInicio').val($("#txt_fecha").val());
							$('#dp_FechaFin').val($("#txt_fecha").val())
						}
						else
						{
							$("#chk_indefinido").prop("checked", "");
							$('#dp_FechaInicio').val(Fec_iniGRid);
							$('#dp_FechaFin').val(Fec_finGrid);
						}	
						
						$('#cbx_Opcion').val(iduOpcion);
					}
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid('id_button0',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	/////////Configuración DataPicker
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

	//////////////////////////////// COMBO OPCION ////////////////////////////	
	function CargarComboOpcion()
	{
		$.ajax
		({type: "POST",
		data: {session_name:Session},
		url: 'ajax/json/json_fun_obtener_combo_opcion.php'})
		.done(function(data){
				var sanitizedData = limpiarCadena(data);
				json = json_decode(sanitizedData);		
				if(json.estado == 0)
				{
					var select = "<option style='text-align: left;' value='0'>"+"TODAS LAS OPCIONES"+"</option>";
					
					for(var i=0; i < json.datos.length; i++)
					{
						select += "<option style='text-align: left;' value='"+json.datos[i].num_opcion+"'>"+json.datos[i].nom_opcion+"</option>";
					}
					$("#cbx_Opcion").html(select);
					$("#cbx_Opcion").trigger("chosen:updated");														
				}
				else
				{
					//alert(json.mensaje);
					showalert(LengStrMSG.idMSG88+" las opciones", "", "gritter-warning");
				}
			})
		.fail(function(s) {
			//alert("Error al cargar " + url);
			showalert(LengStrMSG.idMSG88+" las opciones", "", "gritter-warning");
		})
		.always(function() {});
	}
	//////////////////////////////////////Guardar//////////////////////////////
	$('#btn_guardar').click(function(event)
	{	
		var Chk_activo = $('#chk_indefinido').prop('checked')?1:0;
		
		// VALIDACIONES //
		if ($('#txt_mensaje').val().replace('/^\s+|\s+$/g', '').length == 0)
		{
			//message ("Ingrese mensaje");
			$('#txt_mensaje').val("");
			$('#txt_mensaje').focus();
			showalert(LengStrMSG.idMSG223, "", "gritter-info");
		}
		else if ($('#dp_FechaInicio').val() == "")
		{
			//message ("Ingrese fecha de inicio");
			$('#dp_FechaInicio').focus();
			showalert(LengStrMSG.idMSG224, "", "gritter-info");
		}
		else if ($('#dp_FechaFin').val() == 0 && Chk_activo == 0)
		{
			//message ("Seleccione fecha final");
			$('#dp_FechaFin').focus();
			showalert(LengStrMSG.idMSG225, "", "gritter-info");
		}	
		else if ($('#cbx_Opcion').val() == '')
		{
			//message ("Seleccione una o todas las opciones");
			$('#cbx_Opcion').focus();
			showalert(LengStrMSG.idMSG226, "", "gritter-info");
		}
		else
		{
			AgregarAvisoColaborador();
		}
		
		event.preventDefault();
	});

	$("#chk_indefinido").change(function(){
		if($('#chk_indefinido').is(":checked"))//si esta seleccionado
		{//Bloquea las fechas
			
			$("#dp_FechaInicio").prop('disabled',true);
			$("#dp_FechaFin").prop('disabled',true);
			LimpiarFechas();
			
		}else
		{
			$("#dp_FechaInicio").prop('disabled',false);
			$("#dp_FechaFin").prop('disabled',false);
		}
	});
	function LimpiarFechas()
	{
		$("#dp_FechaInicio" ).val($("#txt_fecha").val());
		$("#dp_FechaFin" ).val($("#txt_fecha").val())
		
	}
	//////////Funcion para agregar registros de permiso a colaborador
	function AgregarAvisoColaborador()
	{
		var FechaIniParametro;
		var FechaFinParametro;
		
		var FechaIniParametro
		var idu_aviso = $('#txt_Clave').val();
		if($('#chk_indefinido').is(":checked"))//si esta seleccionado
		{
			FechaIniParametro='19000101';
			FechaFinParametro='19000101';
		}
		else
		{
			FechaIniParametro = formatearFecha($('#dp_FechaInicio').val());
			FechaFinParametro =formatearFecha($('#dp_FechaFin').val());
			
		}
		var idu_avisoParametro;
		if (idu_aviso != 0)
		{
			idu_avisoParametro = $('#txt_Clave').val();
		}
		else
		{
			idu_avisoParametro = 0;
		}
	
		$.ajax({type: "POST",
		data: {
			session_name:Session,
			'iAviso':idu_avisoParametro,		
			'cMensaje':$('#txt_mensaje').val().toUpperCase(),		
			'Fec_ini':FechaIniParametro,			
			'Fec_fin':FechaFinParametro,	
			'indefinido':$('#chk_indefinido').prop('checked')?1:0, 		
			'Opcion':$('#cbx_Opcion').val()
		},
			url: 'ajax/json/json_fun_grabar_aviso_colegiaturas.php'}).done(function(data)
			{
				//estado = 1 then 'Datos Actualizados Correctamente' when estado = 0 then 'Datos Guardados Correctamente'
				json = json_decode(data);
				if (json.estado == 0)
				{
					//message(json.mensaje);
					showalert(LengStrMSG.idMSG228, "", "gritter-success");	
				}
				else if (json.estado == 1)
				{
					showalert(LengStrMSG.idMSG227, "", "gritter-info");
				}
				else
				{
					showalert(LengStrMSG.idMSG230+" el aviso", "", "gritter-error");
				}
				RecargagridAvisos();
				LimpiarCombos();
			})
			.fail(function(s) {
				//message("Error al cargar ajax/json/json_fun_grabar_aviso_colegiaturas.php" ); 
				showalert(LengStrMSG.idMSG230+" el aviso", "", "gritter-error");
				})
			.always(function() {});
			 	 
	}
	function RecargagridAvisos(){  //--------recarga el grid al agregarle un registro
		$("#gridAvisosColaboradores-table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_avisos_colegiaturas.php'}).trigger("reloadGrid");
	}
	
	function EliminarAviso()
	{	
		////Se manda el formato correcto de fecha a funcion
		var Fecha_inicio = Fec_iniGRid.split('/');
		var FechaIniParametro = Fecha_inicio[2] + '-' + Fecha_inicio[1] + '-' + Fecha_inicio[0];
		var FechaFinParametro;
		if (Fec_finGrid != 0)
		{
			var Fecha_final = Fec_finGrid.split('/');
			FechaFinParametro = Fecha_final[2] + '-' + Fecha_final[1] + '-' + Fecha_final[0];
		}
		else
		{
			FechaIniParametro = '1900-01-01';
			FechaFinParametro = '1900-01-01';
		}
		
		$.ajax({
			type: "POST",
			url: 'ajax/json/json_fun_eliminar_configuracion_avisos.php',
			data: {
				'session_name': Session,
				'iclave': ClaveGrid,
				'sMensaje':	MensajeGrid,
				'iOpcion': iduOpcion,
				'iIndefinido': IndefinidoGrid,
				'dFec_ini': FechaIniParametro,
				'dFec_fin': FechaFinParametro
				}
			})
			.done(function(data){
			
				//console.log(data);
				
				json = json_decode(data);
				if (json.estado == 0) {
					//message("Registro eliminado correctamente");
					showalert(LengStrMSG.idMSG229, "", "gritter-success");
					RecargagridAvisos();
				}
				else {
					//message("Ocurrio un error");
					showalert(LengStrMSG.idMSG231+" el aviso", "", "gritter-error");
				}
			})
			.fail(function(s) { 
				showalert(LengStrMSG.idMSG231+" el aviso", "", "gritter-error");
			})
			.always(function() {});		
	}	
	/////////Funcion para limpiar controles
	function LimpiarCombos()
	{
		$('#txt_Clave').val("");
		$('#txt_mensaje').val("");
		
		$('#dp_FechaInicio').val($("#txt_fecha").val());
		$('#dp_FechaFin').val($("#txt_fecha").val())
		$("#chk_indefinido").prop("checked", "");
		$('#cbx_Opcion').val(0);	
	}

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 396
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