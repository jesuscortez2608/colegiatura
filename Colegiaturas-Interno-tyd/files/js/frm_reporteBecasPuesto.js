var iRutaPago
	,iEstatus
	,iRegion
	,iCiudad
	,iTipoDeduccion
	,iEscolaridad
	,iArea
	,iEmpresa = 0;
var dFechaInicio, dFechaFin, cRutaPago,	cEstatus, cRegion, cCiudad,	cTipoDeduccion, cEscolaridad = "", nCiclo=0,nombreCiclo='';
var Secciones = '';
var iOpcCiclo = 0;
var	iOpcFecha = 1;
var Secciones = '';
soloNumeros("txt_CentroBusqueda");
var iCentroParametro = 0;

$(function(){
	waitwindow('Cargando','open');
	setTimeout(InicializarFormulario, 0);
});

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


	function stopScrolling(callback) {
		$("#dlg_AyudaCentro").on("show.bs.modal", function () {
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
//==========/ FUNCIONES /=====================================================//
	function InicializarFormulario(){
		CrearControlesFechas();
		CrearGridReporte();
		fnEstructuraGridCentros();
		CargarEmpresas();
		ObtenerAreas(function(){
			ObtenerSecciones(function(){
				
			});
		});
		
		CargarComboRutaPago(function(){
			CargarComboEstatus(function(){
				CargarComboRegiones(function(){
					CargarComboTiposDeducciones(function(){
						CargarComboEscolaridades(function(){
							DesbloquearFormulario();
							 CargarCiclosEscolares();
						});
					});
				});
			});
		});
		stopScrolling(function(){
			dragablesModal();
		});
	}

	function DesbloquearFormulario(){
		waitwindow('Cargando','close');
	}

	function CrearControlesFechas(){
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
		
		$( "#txt_FechaInicio" ).datepicker( "option", "maxDate", $( "#txt_FechaFin" ).val() );
		$( "#txt_FechaFin" ).datepicker( "option", "minDate", $( "#txt_FechaInicio" ).val() );
		
		$(".ui-datepicker-trigger").css('display','none');
	}

	function CrearGridReporte(){
		jQuery("#gridReportePuesto-table").jqGrid({
			//url:'ajax/json/',
			datatype: 'json',
			mtype: 'POST',
			colNames:LengStr.idMSG20,
			colModel:[
				{name:'Empresa',	index:'idu_empresa',	width:200,	sortable: false,	align:"left",	fixed: true},
				{name:'Area',		index:'idu_area',	width:200,	sortable: false,	align:"left",	fixed: true},
				{name:'Seccion',	index:'idu_seccion',	width:200,	sortable: false,	align:"left",	fixed: true},
				{name:'Centro',		index:'idu_centro',	width:200,	sortable: false,	align:"left",	fixed: true},
				{name:'numeropuesto',index:'numeropuesto', width:80, sortable: false,align:"right",fixed: true},
				{name:'nombre_puesto',index:'nombre_puesto', width:250, sortable: false,align:"left",fixed: true},
				{name:'total_colaboradores',index:'total_colaboradores', width:120, sortable: false,align:"right",fixed: true},
				{name:'total_facturas',index:'total_facturas', width:100, sortable: false,align:"right",fixed: true},
				{name:'total_becados',index:'total_becados', width:120, sortable: false,align:"right",fixed: true},
				{name:'total_facturado',index:'total_facturado', width:120, sortable: false,align:"right",fixed: true},
				{name:'total_reembolso',index:'total_reembolso', width:120, sortable: false,align:"right",fixed: true}
			],
			scrollrows: true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			viewrecords: true,
			rowNum: -1,
			hidegrid: false,
			rowList:[],
			//width: 950,
			width: null,
			shrinkToFit: false,
			height: 400,
			caption: 'Becas por Puestos',
			pgbuttons: false,
			pgtext: null,
			pager:'#gridReportePuesto-pager',
			postData:{ session_name:Session },
			loadComplete: function (Data) {
				var registros = jQuery("#gridReportePuesto-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
			},
			onSelectRow: function(Numemp) {
				var Data = jQuery("#gridReportePuesto-table").jqGrid('getRowData',Numemp);
				Numemp =Data.Numemp;
			}
		});
		barButtongrid({
			pagId:"#gridReportePuesto-pager",
			position:"left",//center right
			Buttons:[
			{
				icon:"icon-print blue",
				title:'Imprimir',
				click:function (event){
					if (($("#gridReportePuesto-table").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					} else {
						GenerarPDF();
					}
					event.preventDefault();	
				}
			}]
		});
		setSizeBtnGrid('id_button0',35);
	}
	function fnEstructuraGridCentros(){
		jQuery("#grid_Centros").jqGrid({
			//url:'ajax/json/',
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG57,
			colModel:[
				{name:'numero', index:'numero', width:100, sortable: false, align:"center", fixed: false},
				{name:'nombre', index:'nombre', width:303, sortable: false, align:"left", fixed: false}
			],
			scrollrows: true,
			width: 420,
			loadonce: false,
			shrinkToFit: false,
			height: 200,
			rowNum: 10,
			rowList: [10, 20, 30],
			pager: '#grid_Centros_pager',
			sortname: 'idu_centro',
			viewrecords: true,
			hidegrid: false,
			sortorder: "asc",
			loadComplete: function (Data) {
				var registros = jQuery("#grid_Centros").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			ondblClickRow: function(id) {
				var Data = jQuery("#grid_Centros").jqGrid('getRowData',id);
				$('#txt_CentroF').val(Data['numero']);
				$('#txt_NombreCentroF').val(Data['numero']+' '+Data['nombre']);
				$('#txt_CentroBusqueda').val("");
				$('#txt_NomCentroBusqueda').val("");
				$('#grid_Centros').jqGrid('clearGridData');
				$("#dlg_AyudaCentro").modal('hide');
				
				iCentroParametro = Data['numero'];
				cCentroNombre = Data['nombre'];
				
			}
		});
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}

	function CargarComboRutaPago(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_rutas_pago.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='-1'>TODAS</option>";
				for(var i = 0;i < dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_rutaPago").html(option);
				$("#cbo_rutaPago").trigger("chosen:updated");
				callback();
			} else {
				showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
		})
		.always(function() {});
	}

	function CargarComboEstatus(callback){
		var option="";
		$.ajax({
				type: "POST",
				url: "ajax/json/json_fun_obtener_estatus_facturas.php",
				data: { }
			})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				option = option + "";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].idu_estatus + "'>" + dataJson.datos[i].nom_estatus + "</option>";
				}
				$("#cbo_Estatus").html(option);
				$("#cbo_Estatus").trigger("chosen:updated");
				
				// Por si se desea inicializar el combo en el valor (1).
				// $("#cbo_Estatus").val(1);
				// $("#cbo_Estatus").trigger("chosen:updated");
				
			} else {
				showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los estatus de las facturas", "", "gritter-error");
			$('#cbo_Estatus').fadeOut();})
		.always(function() {callback();});
	}

	function CargarComboRegiones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_Region").html(option);
				$("#cbo_Region").trigger("chosen:updated");
				
			} else {
				showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {callback();});
	}

	function CargarComboCiudades(){
		if($(cbo_Region).val() > 0){
			$.ajax({type: "POST",
				url: "ajax/json/json_fun_catalogociudades.php",
				data: {
					'region':$(cbo_Region).val()
				}
			})
			.done(function(data) {
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0) {
					var option = "<option value='0'>TODAS</option>";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_Ciudad").html(option);
					$("#cbo_Ciudad").trigger("chosen:updated");
				} else {
					showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				}
			})
			.fail(function(s) {
				showalert(LengStrMSG.idMSG88+" las ciudades", "", "gritter-error");
				$('#cbo_Ciudad').fadeOut();
			})
			.always(function() {});
		} else {
			var option = "<option value='0'>TODAS</option>";
			$("#cbo_Ciudad").html(option);
		}
	}

	function CargarComboTiposDeducciones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
			data: {}
		})
		.done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0) {
				var option = "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++) {
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoDeduccion").html(option);
				$("#cbo_tipoDeduccion").trigger("chosen:updated");
				callback();
			} else {
				showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {});
	}

	function CargarComboEscolaridades(callback){
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_escolaridades_combo.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0){
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++){
					option = option + "<option value='" + dataJson.datos[i].idu_escolaridad + "'>" + dataJson.datos[i].nom_escolaridad + "</option>";
				}
				$("#cbo_Escolaridad").html(option);
				$("#cbo_Escolaridad").trigger("chosen:updated");
				callback();
			} else {
				showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
		})
		.always(function() {});
	}

	function Consultar(){
		$("#gridReportePuesto-table").jqGrid('clearGridData');
		CargarVariablesDeConsulta();
		if($("#cbo_area").val() == 0){
			Secciones = "";
			var cnt = 0;
			$("#cbo_seccion option").each(function(){
				if(cnt == 0){
					Secciones += $(this).attr('value');
				} else {
					Secciones += "," + $(this).attr('value');
				}
				cnt++;
			});
		}
		if($("#cbo_seccion").val() == 0){
			Secciones = "";
			var cnt = 0;
			$("#cbo_seccion option").each(function(){
				if(cnt == 0){
					Secciones += $(this).attr('value');
				} else {
					Secciones += "," + $(this).attr('value');
				}
				cnt++;
			});
		} else {
			Secciones = $("#cbo_seccion").val();
		}
		
		var sUrl = 'ajax/json/json_fun_obtener_reporte_colegiaturas_por_puesto.php?&session_name='+Session;
			sUrl += '&iRutaPago='+iRutaPago;
			sUrl += '&iEstatus='+iEstatus;
			sUrl += '&iRegion='+iRegion;
			sUrl += '&iCiudad='+iCiudad;
			sUrl += '&iTipoDeduccion='+iTipoDeduccion;
			sUrl += '&iEscolaridad='+iEscolaridad;
			sUrl += '&iOpcFecha='+iOpcFecha;
			sUrl += '&dFechaInicio='+dFechaInicio;
			sUrl += '&dFechaFin='+dFechaFin;
			sUrl += '&iOpcCiclo='+iOpcCiclo;
			sUrl += '&iCicloEscolar='+nCiclo;
			sUrl += '&iCentro='+iCentroParametro;
			sUrl += '&iArea='+iArea;
			sUrl += '&Seccion='+Secciones;
			sUrl += '&iEmpresa='+iEmpresa;
		// urlu = 'ajax/json/json_fun_obtener_reporte_colegiaturas_por_puesto.php?' +
			// 'session_name=' + Session +
			// '&iRutaPago=' + iRutaPago +
			// '&iEstatus=' + iEstatus +
			// '&iRegion=' + iRegion +
			// '&iCiudad=' + iCiudad +
			// '&iTipoDeduccion=' + iTipoDeduccion +
			// '&iEscolaridad=' + iEscolaridad +
			// '&dFechaInicio=' + dFechaInicio +
			// '&dFechaFin=' + dFechaFin+
			// '&iCicloEscolar='+nCiclo;
			// console.log(sUrl);
			// return;
		$("#gridReportePuesto-table").jqGrid('setGridParam',{ url: sUrl }).trigger("reloadGrid");
	}

	function CargarVariablesDeConsulta(){
		iRutaPago = $("#cbo_rutaPago").val();
		iEstatus = $("#cbo_Estatus").val();
		iRegion = $("#cbo_Region").val();
		iCiudad = $("#cbo_Ciudad").val();
		iTipoDeduccion = $("#cbo_tipoDeduccion").val();
		iEscolaridad = $("#cbo_Escolaridad").val();
		dFechaInicio = formatearFecha($('#txt_FechaInicio').val());
		dFechaFin = formatearFecha($('#txt_FechaFin').val());
		iArea = $("#cbo_area").val();
		iEmpresa = $("#cbo_empresa").val()
		
		
		cRutaPago = $('#cbo_rutaPago option:selected').html();
		cEstatus = $('#cbo_Estatus option:selected').html();
		cRegion = $('#cbo_Region option:selected').html();
		cCiudad = $('#cbo_Ciudad option:selected').html();
		cTipoDeduccion = $('#cbo_tipoDeduccion option:selected').html();
		cEscolaridad = $('#cbo_Escolaridad option:selected').html();
		nCiclo=$("#cbo_CicloEscolar").val();
		nombreCiclo=$('#cbo_CicloEscolar option:selected').html();
	}
	$("#btn_ayudaCentro").click(function(event){
		$("#dlg_AyudaCentro").modal('show');
		event.preventDefault();
	});
	$("#btn_BuscarCentro").click(function(event){
		$('#grid_Centros').jqGrid('clearGridData');
		$("#grid_Centros").jqGrid('setGridParam', {
			url:'ajax/json/json_proc_ayudacentros_grid.php?'
				+ 'iNumRegion=' + $('#cbo_Region').val()
				+ '&iNumCiudad=' + $('#cbo_Ciudad').val()
				+ '&iCentro=' + $('#txt_CentroBusqueda').val()
				+ '&cNomCentro=' + $('#txt_NomCentroBusqueda').val()
				+ '&session_name='+ Session
		}).trigger("reloadGrid");
		event.preventDefault();
	});

	$("#dlg_AyudaCentro").on('hide.bs.modal', function (event) {
		fnLimpiarAyudaCentros();
	});
	
	function fnLimpiarAyudaCentros(){
		$("#txt_CentroBusqueda").val("");
		$("#txt_NomCentroBusqueda").val("");
		$("#grid_Centros").jqGrid('clearGridData');
	}

	function GenerarPDF(){
		var registros = jQuery("#gridReportePuesto-table").jqGrid('getGridParam', 'reccount');
		if(registros == 0){
			showalert(LengStrMSG.idMSG87, "", "gritter-info");
		} else {
			var sNombreReporte = 'rpt_becas_por_puesto'
				, iIdConexion = '190'
				, sFormatoReporte = 'pdf';
			var sUrl = '';
				sUrl += 'nombre_reporte=' + sNombreReporte;
				sUrl += '&id_conexion=' + iIdConexion;
				sUrl += '&dbms=postgres';
				sUrl += '&formato_reporte=' + sFormatoReporte;
				sUrl += '&idclaverutapago=' + iRutaPago;
				sUrl += '&idestatus=' + iEstatus;
				sUrl += '&idempresa=' + iEmpresa;
				sUrl += '&idregion=' + iRegion;
				sUrl += '&idciudad=' + iCiudad;
				sUrl += '&idtipodeduccion=' + iTipoDeduccion;
				sUrl += '&idescolaridad=' + iEscolaridad;
				sUrl += '&iopcrangofecha=' + iOpcFecha;
				sUrl += '&dfechainicial=' + dFechaInicio;
				sUrl += '&dfechafinal=' + dFechaFin;
				sUrl += '&iopcciclo=' + iOpcCiclo;
				sUrl += '&idciclo=' + nCiclo;
				sUrl += '&idarea=' + iArea;
				sUrl += '&idseccion=' + Secciones;
				sUrl += '&idcentro=' + iCentroParametro;
				
				// console.log(sUrl);
				// return;
				
			var xhr = new XMLHttpRequest();
			var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS_SPRING + '/reportes';
			
			xhr.open("POST", report_url, true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			
			xhr.addEventListener("progress", function(evt){
				if(evt.lengthComputable){
					var percentComplete = evt.loaded / evt.total;
					console.log(percentComplete);
				}
			}, false);
			
			xhr.responseType = "blob";
			xhr.onreadystatechange = function(){
				waitwindow('','close');
				if(this.readyState == XMLHttpRequest.DONE && this.status == 200){
					var filename = sNombreReporte + "." + sFormatoReporte;
					
					var link = document.createElement('a');
					link.href = window.URL.createObjectURL(xhr.response);
					link.download = filename;
					link.style.display = 'none';
					
					document.body.appendChild(link);
					
					link.click();
					
					document.body.removeChild(link);
				}
			}
			waitwindow('Obteniendo reporte, por favor espere...', 'open');
			xhr.send(sUrl);
		}
	}

	function CargarCiclosEscolares(){
		$("#cbo_CicloEscolar").html("");
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_ciclos_escolares.php",
			data: {},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
				var dataJson = JSON.parse(sanitizedData);
				if(dataJson.estado == 0){
					var option = "";
					for(var i=0;i<dataJson.datos.length; i++){
						option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
					}
					$("#cbo_CicloEscolar").html(option);
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				} else if(dataJson.estado == 0){
					//message(LengStr.idMSG11);
					// showalert(LengStr.idMSG11, "", "gritter-warning");
					$("#cbo_CicloEscolar").addClass("chosen-select").chosen({no_results_text: "Sin resultado!"});
					$("#cbo_CicloEscolar").trigger("chosen:updated");
				} else {
					//message(dataJson.mensaje);
					showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
				}
			},
			error:function onError(){
				//message("Error al cargar " + url);
				showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-error");
				$('#cbo_CicloEscolar').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function CargarEmpresas(){
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_obtener_listado_empresas_colegiaturas.php',
			data:{},
			beforeSend:function(){},
			success:function(data){
				var sanitizedData = limpiarCadena(data);
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
	$("#cbo_area").trigger("updated");
	function ObtenerAreas(callback){
		sUrl = 'ajax/json/json_WS_obtener_areas.php';
		$.ajax({
			type:'POST',
			url: sUrl,
			data:{},
		})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			// console.log(dataJson[0].nombre);
			// console.log(dataJson.length);
			var option = "<option value='0'>TODAS</option>";
			for( var i=0; i < dataJson.length; i++){
				option = option + "<option value='" + dataJson[i].numero + "'>" + dataJson[i].nombre + "</option>";
			}
			$("#cbo_area").html(option);
			var Sel = $("#cbo_area option").first().val();
			$("#cbo_area").val(Sel);
			callback();
		})
		.fail(function(s) {alert("Error al cargar ajax/'rutaJson'"); $('#pag_content').fadeOut();})
		.always(function() {});
	}
	$("#cbo_seccion").trigger("updated");
	function ObtenerSecciones(callback){
		sUrl = 'ajax/json/json_WS_obtener_secciones.php';
		$.ajax({
			type:'POST',
			url:sUrl,
			data:{'idArea' : $("#cbo_area").val()},
		})
		.done(function(data){
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			// console.log(dataJson);
			var option = "<option value='0'>TODAS</option>";
			for(var i=0; i < dataJson.length; i++){
				option = option + "<option value='" + dataJson[i].seccion + "'>" + dataJson[i].nombreSeccion.toUpperCase() + "</option>";
			}
			$("#cbo_seccion").html(option);
			var Sel = $("#cbo_seccion option").first().val();
			$("#cbo_seccion").val(Sel);
			
			callback();
		})
		.fail(function(s) {alert("Error al cargar ajax/'rutaJson'"); $('#pag_content').fadeOut();})
		.always(function() {});
	}
//==========/ EVENTOS /=====================================================//
	$("#cbo_Region").change(function(event){
		CargarComboCiudades();
		event.preventDefault();
	});
	
	$("#cbo_area").change(function(event){
		// idArea = $("#cbo_area").val();
		ObtenerSecciones();


		if($("#cbo_area").val() == 0){
			$("#cbo_seccion").prop('disabled', true);
		} else {
			$("#cbo_seccion").prop('disabled', false);
		}
		event.preventDefault();
	});

	$("#btn_consultar").click(function(event){
		Consultar();
		event.preventDefault();
	});

	$("#rdbtn_ciclo").change(function(){
		if($("#rdbtn_ciclo").is(":checked")){
			iOpcCiclo = 1;
			iOpcFecha = 0;
			$("#cbo_CicloEscolar").prop('disabled', false);
			$("#txt_FechaInicio").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
		}else if($("#rdbtn_fecha").is(":checked")){
			iOpcFecha = 1;
			iOpcCiclo = 0;
			$("#cbo_CicloEscolar").prop('disabled', true);
			$("#txt_FechaInicio").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
		}
	});
	
	$("#rdbtn_fecha").change(function(){
		if($("#rdbtn_fecha").is(":checked")){
			iOpcFecha = 1;
			iOpcCiclo = 0;
			$("#cbo_CicloEscolar").prop('disabled', true);
			$("#txt_FechaInicio").prop('disabled', false);
			$("#txt_FechaFin").prop('disabled', false);
		} else if($("#rdbtn_ciclo").is(":checked")){
			iOpcCiclo = 1;
			iOpcFecha = 0;
			$("#cbo_CicloEscolar").prop('disabled', false);
			$("#txt_FechaInicio").prop('disabled', true);
			$("#txt_FechaFin").prop('disabled', true);
		}
	});

// $("#btn_imprimir").click(function(event){
	// Imprimir();
	// event.preventDefault();
// });