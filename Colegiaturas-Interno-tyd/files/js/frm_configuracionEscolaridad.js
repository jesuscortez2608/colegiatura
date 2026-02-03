$(function(){
	ConsultaClaveHCM()
	soloNumero('txt_clave');
	soloLetras('txt_escolaridad');
	var id_escolaridad = 0, id_grado = 0;
	var escolaridad  = '', grado = '';

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

	//GRID
	fnCargarGrid(function(){
		definirGridGrados();
	});
	$("#div_grados").hide();
	//----------------------------------------------------------------------------------------------------------
	//----------------------------------------------------------------------------------------------------------
	//			  E   S   C   O   L   A   R   I   D   A   D   E   S
	//----------------------------------------------------------------------------------------------------------
	function fnCargarGrid(callback) {
		jQuery("#gridEscolaridad-table").jqGrid({
		url:'ajax/json/json_fun_obtener_listado_escolaridades.php',
		datatype: 'json',
		mtype: 'POST',
		colNames:LengStr.idMSG16,
			colModel:[
			{name:'idu_escolaridad',index:'idu_escolaridad', width:50, sortable: false,align:"left",fixed: true},
			{name:'nom_escolaridad',index:'nom_escolaridad', width:250, sortable: false,align:"left",fixed: true},
			{name:'fec_captura',index:'fec_captura', width:100, sortable: false,align:"center",fixed: true},
			{name:'idu_empleado_registro',index:'idu_empleado_registro', width:100, sortable: false,align:"left",fixed: true, hidden:true},
			{name:'nom_empleado_registro',index:'nom_empleado_registro', width:350, sortable: false,align:"left",fixed: true},
		],
		scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
		loadonce: false,
		shrinkToFit: false,
		rowNum:-1,
		hidegrid: false,
		width: 810,
		height: 390,
		//----------------------------------------------------------------------------------------------------------
		caption: 'Escolaridades',
		pgbuttons: false,
		pgtext: null,
		pager:'#gridEscolaridad-pager',
		viewrecords: false,
		
		postData:{session_name:Session},
		
		loadComplete: function (Data){
			callback();
		},
		onSelectRow: function(clave) {
			id_grado = 0;
			$("#txt_NomGrado").val('');
			var Data = jQuery("#gridEscolaridad-table").jqGrid('getRowData',clave);
						id_escolaridad = Data.idu_escolaridad;
						escolaridad = Data.nom_escolaridad;
			$("#div_grados").show();
			ObtenerGradosPorEscolaridad();
			iEscolaridadSeleccionada = 1;
		},						
		//DOBLE CLIC AL GRID//
		ondblClickRow: function(clave)
					{
						var Data = jQuery("#gridEscolaridad-table").jqGrid('getRowData',clave);
						$("#txt_clave").val(Data.idu_escolaridad);
						$("#txt_escolaridad").val(Data.nom_escolaridad);
					}					
		});	
		
		barButtongrid({
			pagId:"#gridEscolaridad-pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-edit orange bigger-140",	
				title:'Editar Escolaridad',
				click: function(event)
				{
					if(id_escolaridad>0)
					{		
						$("#txt_clave").val(id_escolaridad);
						$("#txt_escolaridad").val(escolaridad);
					}
					else
					{
						showalert(LengStrMSG.idMSG123, "", "gritter-info");
						//showmessage('Seleccione la escolaridad a modificar', '', undefined, undefined, function onclose(){
							$("#txt_clave").val('');
							$("#txt_escolaridad").val('');
							//Variables del procedimiento
						//});
					}
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid('id_button0',35);
	}
	//RECARGAR GRID Escolaridades
	function recargargridInformacion() {
		id_escolaridad = 0;
		$("#gridEscolaridad-table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_escolaridades.php'}).trigger("reloadGrid"); 
		CargarGridGrados();
	}
	//BOTON GUARDAR ESCOLARIDAD
	$('#btn_guardar').click(function(event) {
		var Clave = $('#txt_clave').val();
		if ($('#txt_escolaridad').val().replace('/^\s+|\s+$/g', '') == "") {
			$('#txt_escolaridad').val("");
			$('#txt_escolaridad').focus();
			//showmessage('Proporcione escolaridad', '', undefined, undefined, function onclose(){});
			showalert(LengStrMSG.idMSG124, "", "gritter-info");
			return false;
		}
		if($('#txt_clave').val()=="") {
			Clave = 0;	
		}

		$.ajax({type: "POST",
			url: 'ajax/json/json_fun_grabar_escolaridad.php',
			data: 
			{
				session_name:Session, 
				'idu_escolaridad':	Clave,
				'txt_escolaridad':	$('#txt_escolaridad').val().toUpperCase()
			},	
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson.estado != 2) {
					recargargridInformacion();
				}
				if (dataJson.estado == 0) { //0 Escolaridad registrada correctamente
					showalert(LengStrMSG.idMSG232,"", "gritter-success");
				} else if(dataJson.estado == 1) {  //1 Escolaridad actualizada correctamente
					showalert(LengStrMSG.idMSG125,"", "gritter-success");
				} else {    //2 La Escolaridad ya existe
					showalert(LengStrMSG.idMSG126,"", "gritter-info");
				}
				//showmessage(dataJson.mensaje, '', undefined, undefined, function onclose(){
				$("#txt_clave").val('');
				$("#txt_escolaridad").val('');
					//Variables del procedimiento
				//});
				//message(dataJson.mensaje);
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}	
		});
		event.preventDefault();
	});
	//--------------------------------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------------------------------
	//	  G  R  A  D  O  S    E  S  C  O  L  A  R  E  S
	//--------------------------------------------------------------------------------------------------------------------------
	function CargarGridGrados(){
		$("#gridGrados-table").jqGrid("GridUnload");
		jQuery("#gridGrados-table").jqGrid({
			// url:'ajax/json/json_fun_obtener_grados_escolares.php?iOpcion=1',
			datatype: 'json',
			mtype: 'POST',
			colNames:LengStr.idMSG124,
				colModel:[
				{name:'idu_grado_escolar',	index:'idu_grado_escolar', 	width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'nom_grado_escolar',	index:'nom_grado_escolar', 	width:500, 	sortable: false,	align:"left",	fixed: true},
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			loadonce: false,
			shrinkToFit: false,
			rowNum:-1,
			hidegrid: false,
			width: 810,
			height: 390,
			//----------------------------------------------------------------------------------------------------------
			caption: 'Grados Escolares',
			pgbuttons: false,
			pgtext: null,
			pager:'#gridGrados-pager',
			viewrecords: false,
			
			postData:{session_name:Session},
			
			loadComplete: function (Data){
				if (( $("#gridGrados-table").find("tr").length - 1 ) == 0 ){
					showalert("Agregue un grado escolar a la escolaridad seleccionada", "", "gritter-info");
					$("#txt_grado").val('');
					$("#txt_NomGrado").val('');
					$("#txt_NomGrado").focus();
					$("html, body").animate({ scrollTop:500 }, "fast");
				}
			},
			onSelectRow: function(clave) {
				var Data = jQuery("#gridGrados-table").jqGrid('getRowData',clave);
							id_grado = Data.idu_grado_escolar;
							grado = Data.nom_grado_escolar;
			},						
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(clave){
				var Data = jQuery("#gridGrados-table").jqGrid('getRowData',clave);
				$("#txt_grado").val(Data.idu_grado_escolar);
				$("#txt_NomGrado").val(Data.nom_grado_escolar);
			}					
		});
	}
	
	function definirGridGrados(){
		$("#gridGrados-table").jqGrid("GridUnload");
		jQuery("#gridGrados-table").jqGrid({
			// url:'ajax/json/json_fun_obtener_grados_escolares.php?iOpcion=1',
			datatype: 'json',
			mtype: 'POST',
			colNames:LengStr.idMSG124,
				colModel:[
				{name:'idu_grado_escolar',	index:'idu_grado_escolar', 	width:250, 	sortable: false,	align:"left",	fixed: true},
				{name:'nom_grado_escolar',	index:'nom_grado_escolar', 	width:500, 	sortable: false,	align:"left",	fixed: true},
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			loadonce: false,
			shrinkToFit: false,
			rowNum:-1,
			hidegrid: false,
			width: 810,
			height: 390,
			//----------------------------------------------------------------------------------------------------------
			caption: 'Grados Escolares',
			pgbuttons: false,
			pgtext: null,
			pager:'#gridGrados-pager',
			viewrecords: false,
			
			postData:{session_name:Session},
			
			loadComplete: function (Data){
				if (( $("#gridGrados-table").find("tr").length - 1 ) == 0 ){
					showalert("Agregue un grado escolar a la escolaridad seleccionada", "", "gritter-info");
					$("#txt_grado").val('');
					$("#txt_NomGrado").val('');
					$("#txt_NomGrado").focus();
					$("html, body").animate({ scrollTop:500 }, "fast");
				}
			},
			onSelectRow: function(clave) {
				var Data = jQuery("#gridGrados-table").jqGrid('getRowData',clave);
							id_grado = Data.idu_grado_escolar;
							grado = Data.nom_grado_escolar;
			},						
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(clave){
				var Data = jQuery("#gridGrados-table").jqGrid('getRowData',clave);
				$("#txt_grado").val(Data.idu_grado_escolar);
				$("#txt_NomGrado").val(Data.nom_grado_escolar);
			}					
		});
		barButtongrid({
			pagId:"#gridGrados-pager",
			position:"left",//center rigth
			Buttons:[
			{},
			{
				icon:"icon-edit orange bigger-140",	
				title:'Editar Grado',
				click: function(event) {
					if(id_grado > 0) {
						$("#txt_grado").val(id_grado);
						$("#txt_NomGrado").val(grado);
					} else {
						showalert("Seleccione el grado escolar a editar", "", "gritter-info");
						$("#txt_grado").val('');
						$("#txt_NomGrado").val('');
					}
					event.preventDefault();
				}
			}]
		});
		setSizeBtnGrid('id_button1',35);
	}
	
	$("#btn_guardarGrado").click(function(event){
		var selr = jQuery('#gridEscolaridad-table').jqGrid('getGridParam','selrow');
		if (selr){
			var iGrado = $("#txt_grado").val().replace('/^\s+|\s+$/g', '');
			if ( $("#txt_NomGrado").val().replace('/^\s+|\s+$/g', '') == "" ) {
				showalert("Proporcione el grado", "", "gritter-info");
				$("#txt_NomGrado").val("");
				$("#txt_NomGrado").focus();
			}
			if ( $("#txt_grado").val().replace('/^\s+|\s+$/g', '') == "" ){
				iGrado = -1;
			}
			$.ajax({
				type:'POST',
				url:'ajax/json/json_fun_grabar_grados_escolares.php',
				data:{
					session_name:Session,
					'iEscolaridad' : id_escolaridad,
					'iGrado' : iGrado,
					'sNomGrado' : $("#txt_NomGrado").val().replace('/^\s+|\s+$/g', '').toUpperCase()
				},
				beforeSend:function(){},
				success:function(data){
					var dataJson = JSON.parse(data);
					if ( dataJson.estado != 2 ) {
						showalert(dataJson.mensaje, "", "gritter-info");
						$("#txt_NomGrado").val("");
						ObtenerGradosPorEscolaridad();
						id_grado = 0;
					} else {
						showalert(dataJson.mensaje, "", "gritter-warning");
						$("#txt_NomGrado").focus();
					}
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		} else {
			showalert("Seleccione una escolaridad", "", "gritter-info");
		}
		event.preventDefault();
	});
	//Cargar grid Grados
	function ObtenerGradosPorEscolaridad(){
		var sUrl = 'ajax/json/json_fun_obtener_grados_escolares.php?&session_name='+Session;
		sUrl += '&iEscolaridad='+id_escolaridad;
		sUrl += '&iOpcion=1';
		$("#gridGrados-table").jqGrid('setGridParam',{url: sUrl,}).trigger("reloadGrid");
	}
	//--------------------------------------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------------------------------------
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 390
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