$(function(){	
SessionIs();
ConsultaClaveHCM()
var iEmpleado = 0;
	dFecIni = 0;
	dFecFin = 0;
	idIndefinido = 0;
	idBloqueado = 0;
	
	sel_iEmpleado = 0;
	sel_iIndefinido = 0;
	sel_iBloqueado = 0;
	sel_FechaIni = 0;
	sel_FechaFin = 0;
	sel_iRegistro =  0;
	
	$('[data-rel=tooltip]').tooltip();
	$('[data-rel=tooltip]').tooltip({container:'body'});
	$('[data-rel=popover]').popover({container:'body'});	
	
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
//---------------------------------------------------------------------	
	Cargargrid();
	stopScrolling(function(){
		dragablesModal();
	});
	// ---------------------------- F E C H A S ---------------------------------
	$("#txt_FechaIni").datepicker({
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
			$( "#txt_FechaIni" ).datepicker( "option", "maxDate", selectedDate );
		}
	}).next().on(ace.click_event, function(selectedDate){
			$( this ).prev().focus();
		});	
	$("#txt_FechaIni").prop('disabled',false);
	$("#txt_FechaFin").prop('disabled',false);
	
	
	
	$("#chkbx_indefinido").change(function(){
		if($('#chkbx_indefinido').is(":checked"))//si esta seleccionado
		{//Bloquea las fechas
			
			$("#txt_FechaIni").prop('disabled',true);
			$("#txt_FechaFin").prop('disabled',true);
			LimpiarFechas();
			
		}else
		{
			$("#txt_FechaIni").prop('disabled',false);
			$("#txt_FechaFin").prop('disabled',false);
			// alert($("#txt_FechaFin").val());
		}
	});
	function LimpiarFechas(){
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		//$("#txt_FechaFin" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val())
		
	}
//------------------NUMERO DE EMPLEADO--------------------------------------------------------------------------------------------------
	$("#txt_Numemp").keydown(function(event) {
		// console.log(event.which);
		if (event.which == 13 || event.which == 9 || event.which == 0){
			if($("#txt_Numemp").val().length == 8){
				Cargar_Empleado();
			}else {
				$("#txt_Numemp").val("");
				$("#txt_Nombre").val("");
				$("#txt_Puesto").val('');
				$("#txt_Centro").val('');
				$("#txt_Numemp").focus();
				LimpiarFechas();
				$("#chkbx_indefinido").prop('checked', false);
				
				//message('Ingrese un número de empleado para realizar la búsqueda');
				showalert(LengStrMSG.idMSG118, "", "gritter-info");
			}
		}
		if(event.which == 8 || event.which == 46 || event.which == 110){
			LimpiarControles();
			LimpiarFechas();
			$("#chkbx_indefinido").prop('checked', false);
			$("#txt_Numemp").focus();
		}
		if(event.which == 113){
			$("#dlg_BusquedaEmpleados").modal('show');
			$("#txt_NombreEBusqueda").focus();
			CargarGridColaborador();
			event.preventDefault();
		}
	});
	$("#txt_Numemp").on('paste', function(event){
		var element = this;
		setTimeout(function (){
			var text = $(element).val();
			if($(element).val().length == 8 && (!isNaN(parseInt(text)) && isFinite(text))){
				$(element).val(text);
				$("#txt_Nombre").val("");
				$("#txt_Puesto").val('');
				$("#txt_Centro").val('');
				$("#chkbx_indefinido").prop('checked', false);
				Cargar_Empleado();
			}else{
				event.preventDefault();
			}
		})
	});
	$("#txt_Numemp").on('input propertychange', function(event){
		if($("#txt_Numemp").val().length != 8 || (Number.isInteger(parseInt($("#txt_Numemp").val())))== false){
			LimpiarControles();
			LimpiarFechas();
			$("#chkbx_indefinido").prop('checked', false);
		}else if($("#txt_Numemp").val().length == 8 && (Number.isInteger(parseInt($("#txt_Numemp").val())))){
			Cargar_Empleado();
		}
	})
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
	$("#btn_AyudaEmp").click(function(event){
		$("#txt_Numemp").focus();
	})

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
					$("#txt_Centro").val('');
					$("#txt_Puesto").val('');
					$("#txt_Numemp").focus();
					
				// });
			}else if (json[0].cancelado == 1){
				showalert(LengStrMSG.idMSG120, "", "gritter-info");
				// showmessage('Empleado Cancelado', '', undefined, undefined, function onclose(){
					LimpiarControles();
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
//----------------------BOTONES	
	$("#btn_Guardar").click(function(){
		if($("#txt_Nombre").val().replace('/^\s+|\s+$/g', '') == '' || $("#txt_Numemp").val().replace('/^\s+|\s+$/g', '') == ''){
			showalert(LengStrMSG.idMSG118, "", "gritter-info");
			$("#txt_Nombre").val('');
			// $("#txt_Numemp").val('');
			$("#txt_Centro").val('');
			$("#txt_Puesto").val('');			
			$("#txt_Numemp").focus();
		}else if ($("#txt_Numemp").val().length < 8  || $("#txt_Numemp").val() == 00000000){
			showalert("Proporcione un numero de colaborador valido", "", "gritter-info");
			$("#txt_Nombre").val('');
			// $("#txt_Numemp").val('');
			$("#txt_Centro").val('');
			$("#txt_Puesto").val('');			
			$("#txt_Numemp").focus();
		}else{
			GuardarPermiso();
		}
	})
	$("#btn_Otro").click(function(){
		$("#txt_Numemp").val('');
		$("#txt_Nombre").val('');
		$("#txt_Centro").val('');
		$("#txt_Puesto").val('');
		$("#txt_Numemp").focus();
		$("#txt_FechaIni" ).datepicker("setDate",new Date());
		//$("#txt_FechaFin" ).datepicker("setDate",new Date());
		$("#txt_FechaFin" ).val($("#txt_FechaIni").val());
		$("#chkbx_indefinido").prop("checked", false);
	})
//---------------------------------------------------------------------------------
	function GuardarPermiso(){
			iEmpleado = $("#txt_Numemp").val();
			if($("#chkbx_indefinido").is(":checked")){
				dFecIni = '1900-01-01';
				dFecFin = '1900-01-01';
				idIndefinido = 1;
				// alert("a");
			}else{
				dFecIni = formatearFecha($("#txt_FechaIni").val());
				dFecFin = formatearFecha($("#txt_FechaFin").val());
				idIndefinido = 0;				
				// alert("b");
			}
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_grabar_usuario_para_externos.php',
			data:{
				'session_name'	:	Session,
				'iEmpleado'		:	iEmpleado,
				'dFecIni'		:	dFecIni,
				'dFecFin'		:	dFecFin,
				'idIndefinido'	:	idIndefinido,
				'iBloqueado'	:	idBloqueado
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			//console.log(dataJson);
			showalert(dataJson.mensaje, "", "gritter-info");
			Cargargrid();
		})
	}
	function BloquearUsuario(){

		if(sel_FechaIni != '' || sel_FechaFin != ''){
			sel_FechaIni = sel_FechaIni.split('-');
			sel_FechaIni = sel_FechaIni[2]+sel_FechaIni[1]+sel_FechaIni[0];
			sel_FechaFin = sel_FechaFin.split('-');
			sel_FechaFin = sel_FechaFin[2]+sel_FechaFin[1]+sel_FechaFin[0];			
		}
		if(sel_FechaIni == ''){
			sel_FechaIni = '1900-01-01';
		}
		if(sel_FechaFin == ''){
			sel_FechaFin = '1900-01-01';
		}		
		
		//console.log(sel_FechaIni);
		// showalert("hola", "", "gritter-info");
		$.ajax({
			type:'POST',
			url:'ajax/json/json_fun_grabar_usuario_para_externos.php',
			data:{
				'session_name'	:	Session,
				'iEmpleado'		:	sel_iEmpleado,
				'dFecIni'		:	sel_FechaIni,
				'dFecFin'		:	sel_FechaFin,
				'idIndefinido'	:	sel_iIndefinido,
				'iBloqueado'	:	sel_iBloqueado
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			//console.log(dataJson);
			showalert(dataJson.mensaje, "", "gritter-info");
			sel_iEmpleado = 0;
			Cargargrid();
		})		
	}
	//==========================================================================================================================================================

	//-------------- G R I D  P R I N C I P A L ----------------
	function Cargargrid(){
		jQuery("#gridPermisos-table").GridUnload(); //------> Recarga GRID 
		jQuery("#gridPermisos-table").jqGrid({
			url:'ajax/json/json_fun_obtener_usuarios_para_externos.php?',
			datatype: 'json',
			mtype: 'GET',
			colNames: LengStr.idMSG81,
			colModel:[
				{name:'iempleado'	,index:'iempleado'		,width:200,	resizable:false,	sortable:true,	align:"left",	fixed: true, hidden:true},
				{name:'snombre'		,index:'snombre'		,width:300,	resizable:false,	sortable:true,	align:"left",	fixed: true},
				{name:'icentro'		,index:'icentro'		,width:200,	resizable:false,	sortable:true,	align:"left",	fixed: true, hidden:true},
				{name:'snombrecentro',index:'snombrecentro'	,width:300,	resizable:false,	sortable:true,	align:"left",	fixed: true},
				{name:'ipuesto'		,index:'ipuesto'		,width:20,	resizable:false,	sortable:true,	align:"left",	fixed: true, hidden:true},
				{name:'snombrepuesto',index:'snombrepuesto'	,width:300,	resizable:false,	sortable:true,	align:"left",	fixed: true},
				{name:'idindefinido',index:'idindefinido'	,width:20,	resizable:false,	sortable:true,	align:"left",	fixed: true, hidden:true},
				{name:'iindefinido'	,index:'iindefinido'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true},
				{name:'idu_bloqueado'	,index:'ibloqueado'	,width:70,	resizable:false,	sortable:true,	align:"center",	fixed: true},
				{name:'ibloqueado'		,index:'ibloqueado'	,width:120,	resizable:false,	sortable:true,	align:"left",	fixed: true, hidden:true},
				{name:'dfechainicial',index:'dfechainicial'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true},
				{name:'dfechafinal'	,index:'dfechafinal'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true},
				{name:'dfecharegistro',index:'dfecharegistro'	,width:80,	resizable:false,	sortable:true,	align:"center",	fixed: true},
				{name:'icolaboradorasignopermiso',index:'icolaboradorasignopermiso',width:20,resizable:true,sortable:false,align:"left",fixed: true, hidden:true},
				{name:'scolaboradorasignopermiso',index:'scolaboradorasignopermiso'			,width:350,	resizable:false,	sortable:true,	align:"left",	fixed: true, hidden:false},
			],
			caption: "Colaboradores",
			scrollrows: true,
			viewrecords : true,
			// rowNum:-1,
			hidegrid: false,
			// rowList:[10, 20 , 30],
			pager : "#gridPermisos-pager",
			multiselect: false,
			sortname:'dfecharegistro',
			sortorder:'asc',
			width: null,
			shrinkToFit: true,
			height: 380,//null,//--> sepuede poner fijo si el alto no se quiere automatico  
			//----------------------------------------------------------------------------------------------------------
			pgbuttons: false,
			pgtext: null,
			postData:{},
			loadComplete: function (data){
				var table = this;
				setTimeout(function(){
					updatePagerIcons(table);
				}, 0);				
			},
			onSelectRow: function(id){
				var ret = jQuery("#gridPermisos-table").jqGrid('getRowData',id);
				sel_iEmpleado = ret.iempleado;
				sel_iIndefinido = ret.idindefinido;
				sel_iBloqueado = ret.ibloqueado;
				sel_FechaIni = ret.dfechainicial;
				sel_FechaFin = ret.dfechafinal;
				sel_iRegistro =  ret.icolaboradorasignopermiso;
				// showalert(sel_FechaIni, "", "gritter-info");
				// showalert(sel_FechaFin, "", "gritter-info");
				//console.log(sel_FechaIni);
				
				
			},
			ondblClickRow: function(id){
			}
		});
		barButtongrid({
			pagId:"#gridPermisos-pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-lock red",
				title:'Bloquear/Desbloquear',
				click:function(event){
					if (sel_iEmpleado > 0){
						if(sel_iBloqueado == 0){
							bootbox.confirm("¿Desea Bloquear al colaborador?",
							function(result){
								if(result){
									sel_iBloqueado = 1;
									BloquearUsuario();
								}else if(!result){
									$("#gridPermisos-table").jqGrid('resetSelection');
									sel_iEmpleado = 0;
								}
							});
						}else{
							bootbox.confirm("¿Desea Desbloquear al colaborador?",
							function(result){
								if(result){
									sel_iBloqueado = 0;
									BloquearUsuario();
								}else if(!result){
									$("#gridPermisos-table").jqGrid('resetSelection');
									sel_iEmpleado = 0;
								}
							});
						}
					}else{
						showalert("Seleccione un registro", "", "gritter-info");
					}
				}
			},
			]
		});
		setSizeBtnGrid('id_button0',35);
	}
	//------------------------ G R I D    B U S Q U E D A    E M P L E A D O S ----------------------------------------------
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
				$("#txt_Centro").val(Data.centro + ' ' + Data.nombreCentro);
				$("#txt_Puesto").val(Data.puesto + ' ' + Data.nombrePuesto);
				$("#dlg_BusquedaEmpleados").modal('hide');
			}
		});	
	}	
	function setSizeBtnGrid(id,tamanio){
	$("#"+id).attr('width',tamanio+'px');
	$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
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
                'iOpcion': 383
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