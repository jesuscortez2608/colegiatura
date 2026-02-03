$(function(){
	var iCentroParametro=0,cCentroNombre;
	var iOpcCiclo=0, iOpcFecha = 1;
	var idArea = 0;
	var iCiclo = 0;
	var iFec_inicial, iFec_final = '';
	
	var Secciones = '';
	
	waitwindow('Cargando','open');
	setTimeout(InicializandoFormulario, 0);
	
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

	
	//console.log(Secciones);
	// $('#mySelect option').each(function(){
		// options[$(this).text()] = $(this).val();
	// });
	
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
	
	$("#cbo_area").change(function(event){
		idArea = $("#cbo_area").val();
		ObtenerSecciones();


		if($("#cbo_area").val() == 0){
			$("#cbo_seccion").prop('disabled', true);
		} else {
			$("#cbo_seccion").prop('disabled', false);
		}
		event.preventDefault();
	});
	//-------------FUNCIONES------------------
	function InicializandoFormulario() {

		CrearControlesFechas();
		CrearGridReporte();
		fnEstructuraGridCentros();
		CargarEmpresas();
		ObtenerAreas(function(){			
			ObtenerSecciones(function(){
				// Secciones = "";
				// var cnt = 0;
				// $("#cbo_seccion option").each(function(){
					// if (cnt == 0) {
						// Secciones += $(this).attr('value');
					// } else {
						// Secciones += "," + $(this).attr('value');
					// }
					// cnt++;
				// });
				// console.log("secciones : " + Secciones);
			});
			
		});
		
		CargarComboRutaPago(function(){
			CargarComboRegiones(function(){
				CargarComboCiudades(function(){
					CargarComboTiposDeducciones(function(){
						CargarComboEscolaridades(function(){
							DesbloquearFormulario();
							 CargarCiclosEscolares();
							 stopScrolling(function(){
								 dragablesModal();
							 })
						});
					});	
				});	
			});
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
			//maxDate: "1y",
			//minDate: "-3y",
			// yearRange: "-3:+1",
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
			// maxDate: "1y",
			maxDate: "0D",
			minDate: "0D",
			//minDate: "-1451d",
			// yearRange: "-3:+1",
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
					showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-warning");
				}
			},
			error:function onError(){
				//message("Error al cargar " + url);
				showalert(LengStrMSG.idMSG88+" los ciclos escolares", "", "gritter-warning");
				$('#cbo_CicloEscolar').fadeOut();
			},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}
	function CrearGridReporte(){
		jQuery("#gridReporteCentro-table").jqGrid({
			//url:'ajax/json/json_fun_obtener_reporte_centros.php',
			datatype: 'json',
			mtype: 'GET',
			colNames:LengStr.idMSG42,
			colModel:[
				{name:'Empresa',				index:'idu_empresa', width:200, sortable: false,align:"left",fixed: true},
				{name:'Area',					index:'idu_area', width:200, sortable: false,align:"left",fixed: true},
				{name:'Seccion',				index:'idu_seccion', width:200, sortable: false,align:"left",fixed: true},
				{name:'Centro',					index:'idu_centro', width:360, sortable: false,align:"left",fixed: true},
				{name:'Total colaboradores',	index:'total_colaboradores', width:120, sortable: false,align:"right",fixed: true},
				{name:'Total Facturas',			index:'total_facturas', width:120, sortable: false,align:"right",fixed: true},
				{name:'Total Beneficiarios',	index:'total_beneficiarios', width:120, sortable: false,align:"right",fixed: true},
				{name:'Total importe factura ',	index:'total_importefactura', width:120, sortable: false,align:"right",fixed: true},
				{name:'Total Reembolsado',		index:'total_importepagado', width:120, sortable: false,align:"right",fixed: true}
			],
			scrollrows: true,//PARA QUE FUNCIONE EL SCROLL CON EL SETSELECCION
			viewrecords: true,
			rowNum:-1,
			loadonce: false,
			hidegrid: false,
			rowList:[10,20,30,40,50],
			pager: '#gridReporteCentro-pager',
			width: null,
			shrinkToFit: false,
			sortorder: "asc",
			sortname: 'idu_empresa,tipo',
			height: 280,
			caption: 'Reporte de Becas por Centro',
			postData:{ session_name:Session },
			loadComplete: function (Data) {
				var registros = jQuery("#gridReporteCentro-table").jqGrid('getGridParam', 'reccount');
				if(registros == 0){
					showalert(LengStrMSG.idMSG86, "", "gritter-info");
				}
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);
			},
			onSelectRow: function(Numemp) {
				var Data = jQuery("#gridReporteCentro-table").jqGrid('getRowData',Numemp);
				Numemp = Data.Numemp;
			}
		});
	
		barButtongrid({
			pagId:"#gridReporteCentro-pager",
			position:"left",
			Buttons:[
			{
				icon:"icon-print blue",
				title:'Imprimir',
				click:function (event)
				{
					if (($("#gridReporteCentro-table").find("tr").length - 1) == 0 ) {
						showalert(LengStrMSG.idMSG87, "", "gritter-info");
					} else {
						GenerarPdf();
					}
					
					event.preventDefault();	
				},
				
			}]
		});	
		setSizeBtnGrid('id_button0',35);
	}
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
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

	function CargarComboRutaPago(callback){
		$.ajax({
			type: "POST",
			url: "ajax/json/json_fun_obtener_rutas_pago.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = "<option value='-1'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_rutaPago").html(option);
				$("#cbo_rutaPago").trigger("chosen:updated");
				callback();
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las rutas de pago", "", "gritter-error");
		})
		.always(function() {});
	}

	function CargarComboRegiones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_listado_regiones.php",
			data: {}
		}).done(function(data) {
			CargaCboRegiones = true;
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = "<option value='0'>TODAS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_Region").html(option);
				$("#cbo_Region").trigger("chosen:updated");
				
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las regiones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {callback();});
	}

	function CargarComboTiposDeducciones(callback) {
		$.ajax({type: "POST",
			url: "ajax/json/json_fun_obtener_tipos_deduccion.php",
			data: {}
		}).done(function(data) {
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);
			if(dataJson.estado == 0)
			{
				var option = "<option value='0'>TODOS</option>";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>";
				}
				$("#cbo_tipoDeduccion").html(option);
				$("#cbo_tipoDeduccion").trigger("chosen:updated");
				
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" los tipos de deducciones", "", "gritter-error");
			$('#cbo_CicloEscolar').fadeOut();
		})
		.always(function() {callback();});
	}

	function CargarComboEscolaridades(callback){
		$.ajax({
			type: "POST",
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
				
			}
			else
			{
				showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
			}
		})
		.fail(function(s) {
			showalert(LengStrMSG.idMSG88+" las escolaridades", "", "gritter-error");
		})
		.always(function() {callback();});
	}

	//Trae las ciudades
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
		callback();
	}

	$("#cbo_Region").change(function(event){
		CargarComboCiudades();
		event.preventDefault();
	});

//Boton consultar		
	$("#btn_consultar").click(function(event){
		$('#gridReporteCentro-table').jqGrid('clearGridData');
		if($('#cbo_Estatus').val() == "-1"){
			showalert(LengStrMSG.idMSG321, "", "gritter-info");
		} else {
			llenarGridReporteporCentro();
		}
		event.preventDefault();
	});
	
	//Cargar datos en el grid	
	function llenarGridReporteporCentro(){
		
		var iClave_RutaPago = $('#cbo_rutaPago').val();
		var iEstatus = $('#cbo_Estatus').val();
		var iRegion = $('#cbo_Region').val();
		var iCiudad = $('#cbo_Ciudad').val();
		var iTipo_deduccion = $('#cbo_tipoDeduccion').val();
		var iEmpresa = $("#cbo_empresa").val();
		iCiclo = $("#cbo_CicloEscolar").val();
		iFec_inicial = formatearFecha($("#txt_FechaInicio").val());
		iFec_final = formatearFecha($("#txt_FechaFin").val());
		
		if($("#cbo_area").val() == 0){
			Secciones = "";
				var cnt = 0;
				$("#cbo_seccion option").each(function(){
					if (cnt == 0) {
						Secciones += $(this).attr('value');
					} else {
						Secciones += "," + $(this).attr('value');
					}
					cnt++;
				});
		}
		if($("#cbo_seccion").val() == 0) {
			Secciones = "";
			var cnt = 0;
			$("#cbo_seccion option").each(function(){
				if (cnt == 0) {
					Secciones += $(this).attr('value');
				} else {
					Secciones += "," + $(this).attr('value');
				}
				cnt++;
			});
		} else {
			Secciones = $("#cbo_seccion").val();
		}
		var iNum_escolaridad = $('#cbo_Escolaridad').val();
		
		var sUrl = 'ajax/json/json_fun_obtener_reporte_por_centro.php?&session_name=' + Session;
			sUrl += '&idClvRutaPago='+iClave_RutaPago;
			sUrl += '&idEstatus='+iEstatus;
			sUrl += '&idRegion='+iRegion;
			sUrl += '&idCiudad='+iCiudad;
			sUrl += '&idArea='+idArea;
			sUrl += '&Seccion='+Secciones;
			sUrl += '&iOpcCiclo='+iOpcCiclo;
			sUrl += '&iCiclo='+iCiclo;
			sUrl += '&iOpcFecha='+iOpcFecha;
			sUrl += '&dFechaInicial='+iFec_inicial;
			sUrl += '&dFechaFinal='+iFec_final;
			sUrl += '&idEscolaridad='+iNum_escolaridad;
			sUrl += '&iTipo_deduccion='+iTipo_deduccion;
			sUrl += '&idCentro='+iCentroParametro;
			sUrl += '&iEmpresa='+iEmpresa;
			// console.log(sUrl);
			// return;

		// $("#gridReporteCentro-table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_reporte_por_centro.php?&iClave_RutaPago=' + iClave_RutaPago + '&iEstatus='+ iEstatus+ '&iRegion=' +iRegion+ '&iCiudad=' +iCiudad+ '&iTipo_deduccion='+ iTipo_deduccion+ '&iFec_inicial='+iFec_inicial+'&iFec_final=' +iFec_final+'&iNum_escolaridad='+iNum_escolaridad+'&iCentro=' + iCentroParametro+'&iCiclo='+iCiclo }).trigger("reloadGrid");
		$("#gridReporteCentro-table").jqGrid('setGridParam',{ url: sUrl,}).trigger("reloadGrid");
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
	
	//Exportar e imprimir PDF
	function GenerarPdf(){
		var iClave_RutaPago = $('#cbo_rutaPago').val();
		var iEstatus = $('#cbo_Estatus').val();
		var iRegion = $('#cbo_Region').val();
		var iCiudad = $('#cbo_Ciudad').val();
		var iTipo_deduccion = $('#cbo_tipoDeduccion').val();
		var iEmpresa = $("#cbo_empresa").val();
		iCiclo = $("#cbo_CicloEscolar").val();
		iFec_inicial = formatearFecha($("#txt_FechaInicio").val());
		iFec_final = formatearFecha($("#txt_FechaFin").val());
		
		if($("#cbo_area").val() == 0){
			Secciones = "";
				var cnt = 0;
				$("#cbo_seccion option").each(function(){
					if (cnt == 0) {
						Secciones += $(this).attr('value');
					} else {
						Secciones += "," + $(this).attr('value');
					}
					cnt++;
				});
		}
		if($("#cbo_seccion").val() == 0) {
			Secciones = "";
			var cnt = 0;
			$("#cbo_seccion option").each(function(){
				if (cnt == 0) {
					Secciones += $(this).attr('value');
				} else {
					Secciones += "," + $(this).attr('value');
				}
				cnt++;
			});
		} else {
			Secciones = $("#cbo_seccion").val();
		}
		var iNum_escolaridad = $('#cbo_Escolaridad').val();
		
		
		var sNombreReporte = 'rpt_becas_por_centro'
			, iIdConexion = '190'
			, sFormatoReporte = 'pdf';
		var sUrl = '';
			sUrl += 'nombre_reporte='+sNombreReporte;
			sUrl += '&id_conexion='+iIdConexion;
			sUrl += '&dbms=postgres';
			sUrl += '&formato_reporte='+sFormatoReporte;
			sUrl += '&idclaverutapago='+iClave_RutaPago;
			sUrl += '&idestatus='+iEstatus;
			sUrl += '&idregion='+iRegion;
			sUrl += '&idciudad='+iCiudad;
			sUrl += '&idarea='+idArea;
			sUrl += '&idseccion='+Secciones;
			sUrl += '&idtipodeduccion='+iTipo_deduccion;
			sUrl += '&iopcrangofecha='+iOpcFecha;
			sUrl += '&dfechainicial='+iFec_inicial;
			sUrl += '&dfechafinal='+iFec_final;
			sUrl += '&idescolaridad='+iNum_escolaridad;
			sUrl += '&idcentro='+iCentroParametro;
			sUrl += '&iopcciclo='+iOpcCiclo;
			sUrl += '&idciclo='+iCiclo;
			sUrl += '&idempresa='+iEmpresa;
			
			console.log(sUrl);
			// return;
			
		var xhr = new XMLHttpRequest();
		var report_url = oParametrosColegiaturas.URL_SERVICIO_COLEGIATURAS + '/reportes';
		
		xhr.open("POST", report_url, true);
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		
		xhr.addEventListener("progress", function (evt){
			if(evt.lengthComputable) {
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
});