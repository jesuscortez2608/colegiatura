$(function() {
	SessionIs();
	var dFechaInicial = '',
	dFechaFinal = '',
	
	
	//Campos de descripcion de las impresiones de los filtros.
	cDescripcionFiltros, cEmpleado, cRegion, cCiudad, cEstatus, cFechaInicioString, cFechaFinString = "",
	
	iKeyx, iEmpleado, iRegion, iCiudad, iEstatus = 0, iEmpleadoSel;
	
	var registros = 0;
	var iTipoNomina = 0;
	var myPostData = 0;
	ConsultaRealizada = false;
	var Consulta = 0;
	
	//** PETICION 39116 */	
	CargarEmpresas();

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

	
	setTimeout(InicializarFormulario(), 0);
	if ($("#hid_regresa").val() != ''){
		setTimeout(function(){
			$("#pag_title").html("Seguimiento de Facturas por Personal Administración");
			$("html, body").animate({ scrollTop: 0 }, "fast");
			waitwindow('', 'close');
			if ( $("#txt_idEmpleado").val().replace('/^\s+|\s+$/g', '') != '' && $("#txt_idEmpleado").val().length == 8 ){
				Cargar_Empleado();
			}
			$("#cbo_Region").val($("#hid_region").val());
			CargarComboCiudades(function(){
				$("#cbo_Ciudad").val($("#hid_ciudad").val());				
			});
			$("#cbo_Estatus").val($("#hid_estatus").val());
			$("#cbo_TipoNomina").val($("#hid_tNomina").val());
			$("#txt_FechaInicio").val($("#hid_FechaIni").val());
			// $("#txt_FechaInicio").datepicker("setDate", $("#hid_FechaIni").val());
			$("#txt_FechaFin").val($("#hid_FechaFin").val());
			
			setTimeout(function(){
				$("#btn_Consultar").click();
			}, 500)
		}, 500);
	} else {
		waitwindow('', 'close');
	}
	
	function stopScrolling(callback) {
		$("#dlg_BusquedaEmpleados").on("show.bs.modal", function () {
			$( this ).draggable();
			var top = $("body").scrollTop(); $("body").css('position','fixed').css('overflow','hidden').css('top',-top).css('width','100%').css('height',top+5000);
		}).on("hide.bs.modal", function () {
			var top = $("body").position().top; $("body").css('position','relative').css('overflow','auto').css('top',0).scrollTop(-top);
		});
	}
	function dragablesModal(callback){
		$(".modal").draggable({
			// commenting the line below will make scrolling while dragging work
			// helper: "clone",
			handle: ".modal-header",
			scroll: true,
			// revert: "invalid"
		});
		if ( callback != undefined ) {
			callback();
		}
	}
	
	/* EVENTOS
	---------------------------------------------------- */
	//Campo IdEmpleado.
	$("#txt_idEmpleado").keydown(function(event) {
		if (event.which == 13) {
			if($("#txt_idEmpleado").val().length == 8) {
				Cargar_Empleado();
			}
			else {
				$("#txt_idEmpleado").val('');
				$("#txt_idEmpleado").focus();
				$("#txt_nombreEmpleado").val('');
				$("#txt_Centro").val('');
				$("#txt_NombreCentro").val('');
			}
			event.preventDefault();
		}
	});
	$("#txt_idEmpleado").on('input propertychange paste', function(){
		$("#txt_nombreEmpleado").val('');
		$("#txt_Centro").val('');
		$("#txt_NombreCentro").val('');
		
		if ( $("#txt_idEmpleado").val() != '' && isNaN($("#txt_idEmpleado").val()) == false && $("#txt_idEmpleado").val().length == 8 ) {
			Cargar_Empleado();
		}
		
	});
	//Boton de Busqueda Empleado
	$("#btn_buscar").click(function (event) {
		LimpiarModalBusquedaEmpleados();
		$("#dlg_BusquedaEmpleados").modal('show');
		CargarGridColaborador();
		event.preventDefault();
	});
	
	//Boton Consultar Empleados.
	$("#btn_Consultar").click(function(event){
		// CrearEstructuraGridFacturas();
		Consulta = 1;
		ObtenerEmpleadosConFacturas();
		event.preventDefault();
	});
	
	// Boton Buscar dentro del modal de busqueda de empleado.
	$("#btn_buscarCOL").click(function (event){
		desc= $('#txt_nombusqueda').val();
		desc= $('#txt_apepatbusqueda').val();
		desc= $('#txt_apematbusqueda').val();
		$("#grid_colaborador").jqGrid('setGridParam', { url:'ajax/json/json_proc_busquedaEmpleados_sueldos.php?nombre='+$('#txt_nombusqueda').val()+'&apepat='+$('#txt_apepatbusqueda').val()+'&apemat='+$('#txt_apematbusqueda').val()}).trigger("reloadGrid");
		event.preventDefault();
	});
	//Combo Regiones.
	$("#cbo_Region").change(function(event){
		CargarComboCiudades();
		event.preventDefault();
	});
	
	
	/* MÉTODOS
	---------------------------------------------------- */
	function InicializarFormulario() {
		waitwindow('Por favor espere...', 'open');
		//soloNumero('txt_idEmpleado');
		
		$("#cbo_Periodo").chosen({width:'250px'});
		$("#cbo_Periodo").chosen({height:'200px'});
		$("#cbo_Periodo").chosen({resize:'none'});
		$('#cbo_Periodo').addClass('tag-input-style');
		
		//Cargar Datos de los combos.
		CargarComboRegiones();
		CargarComboCiudades();
		CargarEstatus();
		
		//Crear y configurar Grid.
		CrearEstructuraGridFacturas();
		
		//Configurar campos de fechas.,
		CrearControlesFechas();
		dragablesModal(function(){
			stopScrolling(function(){
				
			});
		});
		$("#txt_idEmpleado").focus();
	};
	
	function LimpiarModalBusquedaEmpleados() {
		$('#txt_nombusqueda').val('');
		$('#txt_apepatbusqueda').val('');
		$('#txt_apematbusqueda').val('');
		$('#grid_colaborador').jqGrid('clearGridData');
	};
	
	function CargarGridColaborador() {
		jQuery("#grid_colaborador").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG45,
			colModel:[
				{ name:'num_emp',index:'num_emp', width:120, sortable: false,align:"center",fixed: true},
				{ name:'nombre',index:'nombre', width:170, sortable: false,align:"center",fixed: true},
				{ name:'apepat',index:'apepat', width:160, sortable: false,align:"center",fixed: true},
				{ name:'apemat',index:'nombre', width:160, sortable: false,align:"center",fixed: true},
				{ name:'centro',index:'centro', width:100, sortable: false,align:"center",fixed: true},
				{ name:'nombreCentro',index:'nombreCentro', width:150, sortable: false,align:"center",fixed: true, hidden:true },
				{ name:'puesto',index:'puesto', width:185, sortable: false,align:"center",fixed: true, hidden:true },
				{ name:'nombrePuesto',index:'nombrePuesto', width:180, sortable: false,align:"center",fixed: true },
			],
			scrollrows : true,
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: 920,
			shrinkToFit: false,
			height: 200,
			caption: 'Colaboradores',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			loadComplete: function (Data) { },
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(clave) {
				var Data = jQuery("#grid_colaborador").jqGrid('getRowData',clave);
				$("#txt_idEmpleado").val(Data.num_emp);
				$("#txt_nombreEmpleado").val(Data.nombre+' '+Data.apepat+' '+Data.apemat);
				$("#txt_Centro").val(Data.centro);
				$("#txt_NombreCentro").val(Data.nombreCentro);
					
				$("#dlg_BusquedaEmpleados").modal('hide');
				 LimpiarModalBusquedaEmpleados();
			}
		});
	};
	
	function Cargar_Empleado() {
		var respon = $('#txt_idEmpleado').val();
		$.ajax({type: "POST",
			url: 'ajax/json/json_proc_obtener_datos_colaborador_colegiaturas.php',
			data: {
					'iEmpleado':respon
				  }
			})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			json = JSON.parse(sanitizedData);
			if(json==null){
				// showmessage('El Empleado no Existe', '', undefined, undefined, function onclose(){
					showalert(LengStrMSG.idMSG340, "", "gritter-info");
					$("#txt_idEmpleado").val('');
					$("#txt_idEmpleado").focus();
					$("#txt_nombreEmpleado").val('');
					$("#txt_Centro").val('');
					$("#txt_NombreCentro").val('');
					$('#grid_colaborador').jqGrid('clearGridData');
			}else if (json[0].cancelado == 1){
				// showmessage('Empleado Cancelado', '', undefined, undefined, function onclose(){
					showalert(LengStrMSG.idMSG341, "", "gritter-info");
					$("#txt_idEmpleado").val('');
					$("#txt_idEmpleado").focus();
					$("#txt_nombreEmpleado").val('');
					$("#txt_Centro").val('');
					$("#txt_NombreCentro").val('');
					$('#grid_colaborador').jqGrid('clearGridData');
			}
			else {	
					 $("#txt_nombreEmpleado").val(json[0].nombre+' '+json[0].appat+' '+json[0].apmat);
					 $("#txt_Centro").val(json[0].centro);
					 $("#txt_NombreCentro").val(json[0].nombrecentro);
				 }
			})
		.fail(function(s) {
			// alert("Error al cargar " + url ); 
			showalert(LengStrMSG.idMSG88+" los datos del colaborador", "", "gritter-warning");
			})
		.always(function() {});
	};
	
	function CrearControlesFechas() {
		//Fecha Inicio
		$("#txt_FechaInicio").datepicker({
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
		//Fecha Fin
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
		
		// $("#txt_FechaInicio" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).datepicker("setDate",new Date());
		
		$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
		$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
		
		$(".ui-datepicker-trigger").css('display','none');
	};
	
	function CrearEstructuraGridFacturas() {
		jQuery("#grd_Empleados").jqGrid({
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG125,
			colModel:[
				{name:'numero_de_facturas', index:'numero_de_facturas', width:60, 	sortable: false, 	align:"center",	fixed: true},
				{name:'idDocumento', 		index:'idDocumento', 		width:70, 	sortable: false, 	align:"left",	fixed: true, hidden:true},
				{name:'TipoDocumento', 		index:'TipoDocumento', 		width:130, 	sortable: false, 	align:"left",	fixed: true},
				{name:'iAclaracion',		index:'iAclaracion',		width:100, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'opc_blog_aclaracion',index:'opc_blog_aclaracion',width:100, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'iRevision', 			index:'iRevision', 			width:100, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'opc_blog_revision', 	index:'opc_blog_revision', 	width:100, 	sortable: false,	align:"center",	fixed: true, hidden:true},
				{name:'num_empleado',		index:'num_empleado', 		width:50, 	sortable: false, 	align:"center",	fixed: true, hidden:true},
				{name:'empleado',			index:'empleado', 			width:350, 	sortable: false, 	align:"left",	fixed: true},
				{name:'num_puesto',			index:'num_puesto', 		width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'puesto',				index:'puesto', 			width:280, 	sortable: false,	align:"left",	fixed: true},
				{name:'num_centro',			index:'num_centro', 		width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'centro',				index:'centro', 			width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'num_region',			index:'num_region', 		width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'region',				index:'region', 			width:200, 	sortable: false,	align:"left",	fixed: true},
				{name:'num_ciudad',			index:'num_ciudad', 		width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'ciudad',				index:'ciudad', 			width:200, 	sortable: false,	align:"left",	fixed: true},
				{name:'num_jefe', 			index:'num_jefe', 			width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'jefe_immediato',		index:'jefe_immediato', 	width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'Empresa',			index:'Empresa', 			width:300, 	sortable: false,	align:"left",	fixed: true},
				{name:'notificacion', 		index:'notificacion', 		width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'status', 			index:'status', 			width:50, 	sortable: false,	align:"left",	fixed: true, hidden:true}
			],
			rowattr: function(rowData, currentObj, rowId) {
				// console.log(rowData)
				if (rowData.notificacion === "1") {
				// if (rowData.opc_blog_aclaracion !== "") {
					return {"style": "background-color: #ffd731;"}; // Aplica un fondo amarillo
				}
				// Puedes agregar más condiciones aquí para aplicar diferentes colores
			},
			caption:'Colaboradores con Factura',
			scrollrows : true,
			width: null,
			loadonce: false,
			shrinkToFit: false,
			height: 400,//null,//--> sepuede poner fijo si el alto no se quiere automatico  :D
			rowNum: 10,
			rowList: [10, 20, 30],
			pager: '#grd_Empleados_pager',
			sortname: 'num_empleado',
			viewrecords: false,
			hidegrid:false,
			sortorder: "asc",
			postData:{ session_name:Session},
			beforeRequest:function(){
				myPostData = $("#grd_Empleados").jqGrid("getGridParam", "postData");
				
			},
			loadComplete: function (Data) {
				Consulta = 0;
				//Cargar leyendas de descripcion de los filtros para mostrar en los campos de impresion.
				cEmpleado = $("#txt_nombreEmpleado").text();
				cRegion = $('#cbo_Region option:selected').html();
				cCiudad = $('#cbo_Ciudad option:selected').html();
				cEstatus = $('#cbo_Estatus option:selected').html();
				cFechaInicioString = $("#txt_FechaInicio").val();
				cFechaFinString = $("#txt_FechaFin").val();
				
				registros = jQuery("#grd_Empleados").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				if ( $("#cbo_Estatus").val() == 4 ) {
					$("#grd_Empleados").jqGrid('showCol',["opc_blog_aclaracion"]);
				} else {
					$("#grd_Empleados").jqGrid('hideCol',["opc_blog_aclaracion"]);
				}
				if ( $("#cbo_Estatus").val() == 5 ) {
					$("#grd_Empleados").jqGrid('showCol',["opc_blog_revision"]);
				} else {
					$("#grd_Empleados").jqGrid('hideCol',["opc_blog_revision"]);
				}
				var table = this;
				setTimeout(function() {
					updatePagerIcons(table);
				}, 0);
				ConsultaRealizada = true;
			},
			ondblClickRow: function(id) {
				var selr = jQuery('#grd_Empleados').jqGrid('getGridParam','selrow');
				if(selr){
					var rowData = jQuery("#grd_Empleados").getRowData(selr);
					
					if(rowData.status == 1|| rowData.status == 2 || rowData.status == 3 || rowData.status == 4 || rowData.status == 5){
						var param = {
							IdEmpleado 		: rowData.num_empleado,
							dFechaIni		: $('#txt_FechaInicio').val(),
							dFechaFin	 	: $('#txt_FechaFin').val(),
							IdEstatus 		: rowData.status,
							iColaborador	: $("#txt_idEmpleado").val(),
							idRegion 		: $("#cbo_Region").val(),
							idCiudad 		: $("#cbo_Ciudad").val(),
							idTipoNom 		: $("#cbo_TipoNomina").val()
						}
						loadContent('ajax/frm/frm_aceptarRechazarFacturas.php', param);
					} else {
						//message('Las facturas no se encuentran en proceso.');
						// showalert(LengStrMSG.idMSG342, "", "gritter-info");
						showalert("No se puede enviar la factura a Aceptar/Rechazar facturas", "", "gritter-info");
					}
				} else {
					// message('Seleccione un empleado para ver sus facturas');
					showalert(LengStrMSG.idMSG343, "", "gritter-info");
				}
			}
		});
		
		barButtongrid({
			pagId:"#grd_Empleados_pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-ok  green ",	
				title:'Aceptar / Rechazar',
				click:function (event){
					if (($("#grd_Empleados").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG86, "", "gritter-info");
					} else {
						var selr = jQuery('#grd_Empleados').jqGrid('getGridParam','selrow');
						if(selr){
							var rowData = jQuery("#grd_Empleados").getRowData(selr);
							if(rowData.status == 1 || rowData.status == 3 || rowData.status == 4 || rowData.status == 5){
								var param = {
									IdEmpleado 		: rowData.num_empleado,
									dFechaIni		: $('#txt_FechaInicio').val(),
									dFechaFin	 	: $('#txt_FechaFin').val(),
									IdEstatus 		: rowData.status,
									iColaborador	: $("#txt_idEmpleado").val(),
									idRegion 		: $("#cbo_Region").val(),
									idCiudad 		: $("#cbo_Ciudad").val(),
									idTipoNom 		: $("#cbo_TipoNomina").val()
								}
								loadContent('ajax/frm/frm_aceptarRechazarFacturas.php', param);
							} else {
								//message('Las facturas no se encuentran en proceso.');
								// showalert(LengStrMSG.idMSG342, "", "gritter-info");
								showalert("No se puede enviar la factura a Aceptar/Rechazar facturas", "", "gritter-info");
							}
						} else {
							// message('Seleccione un empleado para ver sus facturas');
							showalert(LengStrMSG.idMSG343, "", "gritter-info");
						}
					}
				}
			},
			{
				icon:"icon-print blue ",	
				title:'Imprimir',
				click:function (event){
					if (($("#grd_Empleados").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					} else {
						if ( registros > 1 ){
							//Imprimir();
							if(ConsultaRealizada){
								fnImprimir();
							}							
						} else {
							showalert("No existe información para imprimir", "", "gritter-info");
						}
					}
				}
			}]
		});	
		setSizeBtnGrid('id_button0',35); 
		setSizeBtnGrid('id_button1',35);
	};
	
	function CargarComboRegiones() {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
			    $("#cbo_Region").html(option);
				$("#cbo_Region").trigger("chosen:updated");
			} else {
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			}
		})
		.fail(function(s) {
			// message("Error al cargar ajax/json/json_fun_obtener_listado_regiones.php"  );
			showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	};
	
	// function actualizarGridCentros() {
		// var inicializar = inicializarGridCentros;
		// var sCursosSeleccionados = obtenerCursosSeleccionados(1);
		
		// nCargarConsultaCen = 1;
		
		// registrosMarcadosCentro = inicializar ? 0 : registrosMarcadosCentro;
		// empleadosMarcadosCentro = inicializar ? '': empleadosMarcadosCentro;
		
		// $("#grd_cursos_centros").jqGrid('clearGridData');
		// $("#grd_cursos_centros").jqGrid('setGridParam', {
			// url: "ajax/json/json_proc_obtener_cursos_configurados_por_centro.php",
			// postData:{session_name:Session
				// , "iFormato" : iFormato
				// , "iCentro" : $("#txt_iducentro").val()
				// , "iRangoFecha" : $("#chk_rango_fechas_cen").is(":checked") ? 1 : 0
				// , "dFechaInicial" : formatearFecha( $("#txt_fecha_inicial_cen").val() )
				// , "dFechaFinal" : formatearFecha( $("#txt_fecha_final_cen").val() )
				// , "sCursos" : sCursosSeleccionados
				// , "iInicializar" : inicializar ? 1 : 0
			// }
		// }).trigger("reloadGrid");
	// }
	
	function ObtenerEmpleadosConFacturas() {
		iEmpleado = $("#txt_idEmpleado").val();
		if(iEmpleado == "") {
			iEmpleado = 0;
		};
		
		dFechaInicial = formatearFecha($('#txt_FechaInicio').val());
		dFechaFinal = formatearFecha($('#txt_FechaFin').val());
		iRegion = $("#cbo_Region").val();
		iCiudad = $("#cbo_Ciudad").val();
		iEstatus = $("#cbo_Estatus").val();
		iTipoNomina = $("#cbo_TipoNomina").val();
		iEmpresa = $("#cbo_empresa").val();
		
		$("#grd_Empleados").jqGrid('clearGridData');
		var urlu='ajax/json/json_fun_obtener_empleados_con_facturas.php?' +
			'&iEmpleado=' + iEmpleado +
			'&iRegion=' + iRegion +
			'&iCiudad=' + iCiudad +
			'&iEstatus=' + iEstatus +
			'&dFechaInicial=' + dFechaInicial +
			'&dFechaFinal=' + dFechaFinal +
			'&iTipoNomina=' + iTipoNomina +
			'&iEmpresa=' + iEmpresa +
			'&Consulta=' + Consulta;
		$("#grd_Empleados").jqGrid('setGridParam',{ url: urlu}).trigger("reloadGrid");
	};
	
	function CargarComboCiudades(callback){
		if($(cbo_Region).val() > 0){
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_catalogociudades.php",
				data: {
					'region':$(cbo_Region).val()
				}
			}).done(function(data) {
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length; i++)
					{
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Ciudad").html(option);
					$("#cbo_Ciudad").trigger("chosen:updated");
					if(callback != undefined) {
						callback();
					}
				} else {
					// message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				}
			})
			.fail(function(s) {
				//message("Error al cargar ajax/json/json_fun_catalogociudades.php");
				showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				$('#cbo_Ciudad').fadeOut();
			})
			.always(function() {});
		} else {
			var option = "<option value='0'>TODAS</option>";
			$("#cbo_Ciudad").html(option);
		}	
	};
	
	function CargarEstatus(){
		var option="";
		$.ajax(
			{
				type: "POST",
				url: "ajax/json/json_fun_obtener_estatus_facturas.php",
				data: { } 
			})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				option = option + "<option value='-1'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					if(dataJson.datos[i].idu_estatus != 5) //Se elimina el estatus Revision
						option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
				}
				$("#cbo_Estatus").html(option);
				$("#cbo_Estatus").trigger("chosen:updated");
				
				$("#cbo_Estatus").val(1);
				$("#cbo_Estatus").trigger("chosen:updated");
			} else {
				// message(dataJson.mensaje);
				showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			}
		})
		.fail(function(s) {
			//message("Error al cargar json_fun_obtener_estatus_facturas.php" ); 
			showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			$('#cbo_Estatus').fadeOut();})
		.always(function() {});
	};
	
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
	};
	
	function fnImprimir() {
	
	//	var urlu='ajax/json/json_fun_obtener_empleados_con_factura.php?' +
		var urlu='ajax/json/impresion_json_fun_obtener_empleados_con_factura.php?' +
			'&iEmpleado=' + iEmpleado +
			'&iRegion=' + iRegion +
			'&iCiudad=' + iCiudad +
			'&iEstatus=' + iEstatus +
			'&iEmpresa=' + iEmpresa +
			'&dFechaInicial=' + dFechaInicial +
			'&dFechaFinal=' + dFechaFinal +
			'&iTipoNomina=' + iTipoNomina +
			'&cEstatus=' + $("#cbo_Estatus option:selected").html()+
			'&cRegion=' + $("#cbo_Region option:selected").html() +
			'&cCiudad=' + $("#cbo_Ciudad option:selected").html() +
			'&cNomina=' + $("#cbo_TipoNomina option:selected").html() +
			'&page=' + -1 +
			'&rows=' + -1;
			
		location.href = urlu;	
	}
	
	function CrearLeyendaFiltrosImpresion() {
	
		cDescripcionFiltros = "";
		if(cEmpleado != "") {
			cDescripcionFiltros +=  "EMPLEADO: " + cEmpleado + ";";
		}
		cDescripcionFiltros += "REGION:   " + cRegion + ";";
		cDescripcionFiltros += "CIUDAD: " + cCiudad + ";";
		cDescripcionFiltros += "ESTATUS:  " + cEstatus + ";";
		cDescripcionFiltros += "FECHAS DE " + cFechaInicioString + " A " + cFechaFinString;
	}
	function setSizeBtnGrid(id,tamanio){
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	

	// PETICION 39116
	function CargarEmpresas(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_listado_empresas_activas.php',
			data:{},
			beforeSend:function(){},
			success:function(data){
				const sanitizedData = limpiarCadena(data); //Corrección de vulnerabilidad
				dataJson = json_decode(sanitizedData);
				if(dataJson.estado == 0){
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length;i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_empresa").html(option);
					var Sel = $("#cbo_empresa option").first().val();
					$("#cbo_empresa").val(Sel);
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
});