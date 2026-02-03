/*
	Nallely Machado 
	02/09/2016
*/
/*	MODIFICACION
	Rafael Ramos	---->		<-----
	02/03/2018
*/
$(function(){
	ConsultaClaveHCM()
	var id_motivo_seleccionado = 0,
		des_motivo_seleccionado = '',
		tipo_motivo_seleccionado = 0,
		activo_seleccionado = "",
		iOpcion = 0;
	CargarCombo();
	CargarGrid();	

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
	
	$("#cbo_tipoMotivo").change(function(event){//-----------> Se agrego el evento change, para que cuando el combo cambien de valor, muestre la informacion especifica en el grid
	iOpcion = $("#cbo_tipoMotivo").val();
		ConsultarMotivos();
	});//<-----------
	
	//GRID
	function CargarGrid()
	{
		jQuery("#gridMotivo_table").jqGrid({
			url:'ajax/json/json_fun_obtener_listado_motivos.php? iOpcion='+iOpcion,
			datatype: 'json',
			mtype: 'POST',
			colNames:LengStr.idMSG18,
			colModel:[
				{name:'clave',			index:'clave', 			width:40,  sortable: false,	align:"left",	fixed: true},
				{name:'descripcion',	index:'descripcion', 	width:300, sortable: false,	align:"left",	fixed: true},
				{name:'claveTipoMotivo',index:'claveTipoMotivo',width:100, sortable: false,	align:"left",	fixed: true, hidden:true},
				{name:'tipoMotivo',		index:'tipoMotivo', 	width:150, sortable: false,	align:"left",	fixed: true},
				{name:'fechaRegistro',	index:'fechaRegistro', 	width:100, sortable: false,	align:"center",	fixed: true},
				{name:'empleado',		index:'empleado', 		width:350, sortable: false,	align:"left",	fixed: true},
				{name:'estatus',		index:'estatus', 		width:90,  sortable: false,	align:"left",	fixed: true},
			],
			scrollrows : true,//PARA QUE FUNCIONE EL SCROL CON EL SETSELECCION 
			viewrecords : true,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			width: null,
			shrinkToFit: false,
			height: 350,
			//----------------------------------------------------------------------------------------------------------
			caption: 'Motivos',
			pager: '#gridMotivo_pager',
			pgbuttons: false,
			pgtext: null,
			postData:{session_name:Session},
			loadComplete: function (Data) {},
			onSelectRow: function(id) {
				if(id >= 0){
				
					var fila = jQuery("#gridMotivo_table").getRowData(id); 
					id_motivo_seleccionado = fila['clave'];
					des_motivo_seleccionado = fila['descripcion'];
					tipo_motivo_seleccionado = fila['claveTipoMotivo'];
					activo_seleccionado = fila['estatus'];
				} else {
					id_motivo_seleccionado = 0;
					des_motivo_seleccionado = '';
					tipo_motivo_seleccionado = 0;
					estatus_seleccionado = 0;
					activo_seleccionado="";
				}
			},
			//DOBLE CLIC AL GRID//
			ondblClickRow: function(id)
			{
				var Data = jQuery("#gridMotivo_table").jqGrid('getRowData',id);
				$('#txt_claveE').val(id_motivo_seleccionado);  
				$('#cbo_tipoMotivo').val(tipo_motivo_seleccionado);   
				$('#txt_motivo').val(des_motivo_seleccionado);
			}					
		});	
		
		barButtongrid(
		{
			pagId:"#gridMotivo_pager",
			position:"left",//center rigth
			Buttons:[
			{
				icon:"icon-edit orange bigger-140",	
				title:'Editar motivo',
				click: function(event)
				{
					if (id_motivo_seleccionado > 0) {
						$('#txt_claveE').val(id_motivo_seleccionado);  
						$('#cbo_tipoMotivo').val(tipo_motivo_seleccionado);   
						$('#txt_motivo').val(des_motivo_seleccionado);
					} else {
						//message('Seleccione el motivo que desea editar');
						showalert(LengStrMSG.idMSG157, "", "gritter-info");
					}
					event.preventDefault();
				}
			},
			{
				icon:"icon-lock red bigger-140",	
				title:'Bloquear / Desbloquear motivo',
				click: function(event)
				{
					var estatus="";
					if (activo_seleccionado=="ACTIVO")
					{
						estatus="bloquear";
					}
					else
					{
						estatus="desbloquear";
					}
					if (id_motivo_seleccionado > 0) {
					
						bootbox.confirm('¿Desea '+estatus+' el motivo "'+ des_motivo_seleccionado  +'"?'  , 
						function(result){
							if (result){
								$.ajax({type: "POST", 
								url:'ajax/json/json_fun_bloquear_desbloquear_motivo.php?',
								data: { 
									'iClaveMotivo':id_motivo_seleccionado,
									'session_name': Session
								}
							})
							.done(function(data){
								var dataJson = JSON.parse(data);	
								if(dataJson.estado == 0)
								{
									ConsultarMotivos();
									//message('Motivo actualizado correctamente...');
									showalert(LengStrMSG.idMSG158, "", "gritter-success");
								}
								else
								{
									//error
									showalert(LengStrMSG.idMSG230+" el motivo", "", "gritter-info");
								}
							});
							}
						});
						
					} 
					else 
					{
						//message('Seleccione el motivo que desea bloquear/desbloquear');
						showalert(LengStrMSG.idMSG159, "", "gritter-info");
					}
					event.preventDefault();
				}
			
			}]
		});
		setSizeBtnGrid('id_button0',35);
		setSizeBtnGrid('id_button1',35);
	}	
	function setSizeBtnGrid(id,tamanio)
	{//setSizeBtnGrid('id_button0',35);
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	function ConsultarMotivos()
	{
		id_motivo_seleccionado=0;	
		$("#gridMotivo_table").jqGrid('setGridParam',{ url: 'ajax/json/json_fun_obtener_listado_motivos.php?iOpcion='+iOpcion}).trigger("reloadGrid"); 
	};	
	
	$('#btn_guardar').click(function(event)
	{
		var iMotivo=$('#txt_claveE').val();  
		var TipoMotivo=$('#cbo_tipoMotivo').val();   
		if ($('#txt_motivo').val().replace('/^\s+|\s+$/g', '').length == 0)
		{			
			//showmessage('Proporcione el motivo ...', '', undefined, undefined, function onclose(){});
			$('#txt_motivo').val("");
			$('#txt_motivo').focus();
			showalert(LengStrMSG.idMSG160, "", "gritter-info");
			return false;
		}else if($('#cbo_tipoMotivo').val() == 0){
			showalert("Seleccione un Tipo de Motivo","","gritter-info");
			$('#cbo_tipoMotivo').focus();
			return false;
		}
		$.ajax({type: "POST", 
			url:'ajax/json/json_fun_grabar_motivo.php?',
			data: { 
				'iClaveMotivo':iMotivo ? iMotivo: 0,
				'iTipoMotivo' : TipoMotivo,
				'desMotivo':$('#txt_motivo').val().toUpperCase(),
				'session_name': Session
			}
		})
		.done(function(data){
			var dataJson = JSON.parse(data);	
			if(dataJson.estado == 0)
			{
				if(dataJson.mensaje == 1)
				{
					ConsultarMotivos();
					//showmessage('Motivo guardado correctamente...', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG161, '','gritter-success');
				}
				else
				{
					//showmessage('El motivo ya existe, favor de verificar...', '', undefined, undefined, function onclose(){});
					showalert(LengStrMSG.idMSG162, "", "gritter-info");
					$('#txt_motivo').focus();
				}
				$('#txt_claveE').val("");
				// $('#cbo_tipoMotivo').val(0);
				ConsultarMotivos();
				$('#txt_motivo').val("");
				
			}
			else
			{
				//error
				showalert(LengStrMSG.idMSG230+" el motivo", "", "gritter-error");
			}
		});
		event.preventDefault();
	});
	//CARGAR COMBO
	function CargarCombo()
	{
		$.ajax({type: "POST", 
		url: "ajax/json/json_fun_obtener_tipos_motivos.php?",
		data: {}
		})
		.done(function(data){				
			var sanitizedData = limpiarCadena(data);
			var dataJson = JSON.parse(sanitizedData);	
			if(dataJson.estado == 0)
			{
				var option = "<option value='0'>TODOS</option>";	//Se agrega linea(valor) adicional al combo de motivos
				// var option = "";
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + "<option value='" + dataJson.datos[i].value + "'>" + dataJson.datos[i].nombre + "</option>"; 
				}
				$("#cbo_tipoMotivo").html(option);
				$( "#cbo_tipoMotivo" ).val($("#cbo_tipoMotivo option").first().val());
			}
			else
			{
				//error
				showalert(LengStrMSG.idMSG88+" los tipos de motivos", "", "gritter-error");
			}
		});	
	}	
	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 393
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