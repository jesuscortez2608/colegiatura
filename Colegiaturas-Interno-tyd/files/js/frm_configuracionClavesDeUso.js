$(function(){
	ConsultaClaveHCM()
	// showalert('a',"","gritter-info");
	var sel_des = "";
	var	sel_clv = "";
	var sel_keyx = 0;
	soloAlfanumerico('txt_clave');
	soloAlfanumerico('txt_descripcion');
	Cargargrid();
	//console.log(sel_keyx);
	
//------------------------------------------------------------------------------------------------------------

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

//--------------BOTON GUARDAR	
	$("#btn_Guardar").click(function(event){
		if($('#txt_clave').val() == ""){
		showalert("Introduzca la clave", "", "gritter-info");
			$('#txt_clave').focus();
		}else if($("#txt_clave").val().replace('/^\s+|\s+$/g', '') === ""){
			showalert("Ingrese la clave","","gritter-info");
			$('#txt_clave').val("");
			$('#txt_clave').focus();
		}else if($('#txt_descripcion').val() == ""){
			showalert("Ingrese una descripción", "", "gritter-info");
			$('#txt_descripcion').focus();
		}else if($("#txt_descripcion").val().replace('/^\s+|\s+$/g', '') === ""){
			showalert("Ingrese una descripción","","gritter-info");
			$('#txt_descripcion').val("");
			$('#txt_descripcion').focus();			
		}else{
			GuardarClave();	
			// if($("#btn_Guardar").text="Modificar"){
				// $("#btn_Guardar").html("<i class=\"icon-save\"></i>Guardar");
			// }
			//console.log(sel_keyx);
			sel_keyx = 0;
			// console.log(ikeyx);
		}
	});
//-------------------------------------------FUNCIONES-----
	function GuardarClave(){
		$.ajax({ 
			type: "POST",
			url: 'ajax/json/json_fun_guardar_claves_uso_permitidas.php',
			data:{
					'session_name':Session,
					'sel_keyx' : $("#txt_keyx").val(),
					'Clv_uso'  : $("#txt_clave").val().replace('/^\s+|\s+$/g', '').toUpperCase(),
					'Des_uso'  : $("#txt_descripcion").val().replace('/^\s+|\s+$/g', '').toUpperCase(),
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson.estado == -1){
				showalert("La clave ya existe, favor de verificar", "","gritter-info");
				$("#txt_clave").focus();
			}else if(dataJson.estado == 2){
				showalert('Registro modificado',"", "gritter-success");
				LimpiarControles();
				Cargargrid();
				$("#txt_clave").focus();
			} else if(dataJson.estado == -2){
				showalert("Error al guardar la clave de uso","","gritter-info");
				$("#txt_clave").focus();
			}
			else {
				showalert('Clave registrada',"", "gritter-success");
				LimpiarControles();
				Cargargrid();
			}
		})
		.fail(function(s) {message("Error al cargar " + url ); $('#pag_content').fadeOut();})
		.always(function() {});
	}
//---------------------------------------------------------
	function EliminarClave(){
		//console.log("Ruth: "+sel_keyx);
		$.ajax({
			type:"POST",
			url:'ajax/json/json_fun_borrar_clave_uso_permitida.php',
			data:{
				sel_keyx,
				'session_name':Session,
			}
		}).done(function(data){
			var dataJson = JSON.parse(data);
			if(dataJson.estado == 1){
				showalert("Clave Eliminada","", "gritter-info");
				LimpiarControles();
				Cargargrid();
				sel_keyx = 0;
			}else{
				showalert(dataJson.mensaje,"","gritter-info");
			}
		})
		.fail(function(s) {message("Error al cargar " + url);$('#pag_content').fadeOut();})
		.always(function() {});
	}
	function Cargargrid(){
		jQuery("#gd_Claves").GridUnload();
	
		jQuery("#gd_Claves").jqGrid({
			url: 'ajax/json/json_fun_obtener_claves_uso_permitidas.php?',
			datatype: 'json',
			mtype: 'POST',
			colNames:LengStr.idMSG80,
			// ["Clave", "Descripción"],
			colModel:[
				{name:'Num',		index:'Num',		width:90, 	sortable: false,	align:"left",	fixed: true},
				{name:'Clave',		index:'Clave',		width:150,  sortable: false,	align:"left",	fixed: true},
				{name:'Descripcion',index:'Descripcion',width:500, 	sortable: false,	align:"left",	fixed: true},
				{name:'Fecha',		index:'Fecha', 		width:200, 	sortable: false,	align:"left",	fixed: true},
				{name:'Colaborador',index:'Colaborador',width:450,	sortable: false,	align:"left",	fixed: true}
			],
			viewrecords : false,
			rowNum:-1,
			hidegrid: false,
			rowList:[],
			pager : "#gd_Claves_pager",
			multiselect: false,
			width: null,
			shrinkToFit: true,
			height: 350,//null,//--> sepuede poner fijo si el alto no se quiere automatico  
			//----------------------------------------------------------------------------------------------------------
			caption: "Claves de Uso",
			pgbuttons: false,
			pgtext: null,
			postData:{},
			loadComplete: function (data) {
				/*var tamGrid = $("#gd-grid").getGridParam('reccount');
				for(var i = 0; i <= tamGrid; i++ ){
					var ret = jQuery("#gd-grid").jqGrid('getRowData',i);
					if(ret.idestatus == 0){
						$("#"+i).css('background-color','#e2dede');
					}
				}*/
			},
			onSelectRow: function(id){
				if(id >= 0){
					var ret = jQuery("#gd_Claves").jqGrid('getRowData',id);
					sel_clv = ret.Clave;
					sel_des = ret.Descripcion;
					sel_keyx = ret.Num;
					//console.log(sel_keyx);
					// alert(ret.Num);
				}else{
					sel_clv = "";
					sel_des = "";
					sel_keyx = 0;
				}
			},
		});
		// fixGrid({position:true,grid:'#gd_Claves', stretch: true,/* width: '%',*/ctrlbuttons:true, scroll:true});
		barButtongrid({
			pagId:"#gd_Claves_pager",
			position:"left",//center rigth
			Buttons:[{
				icon:"icon-edit orange",
				click:function (event){
					// if (($("#gd_Claves").find("tr").length - 1) != 0 )
					if(sel_keyx > 0){
						// $("#btn_Guardar").html("<i class=\"icon-edit\"></i>Modificar");
						$("#txt_keyx").val(sel_keyx);
						$("#txt_clave").val(sel_clv);
						$("#txt_descripcion").val(sel_des);
						//console.log(sel_keyx);
						
					}else{
						showalert("Seleccione el registro a editar", "", "gritter-info");
					}
				},
				title:"Editar",
			},
			{
				icon:"icon-trash red",
				click:function(event){
					if(sel_keyx > 0){
						LimpiarControles();
						// sel_keyx;
						bootbox.confirm("¿Desea eliminar el registro seleccionado?", function(result)
						{
							if(result){
								//console.log(sel_keyx);
								EliminarClave();
								sel_des = "";
								sel_clv = "";
								sel_keyx = 0;
							}else if (!result){
								$("#gd_Claves").jqGrid('resetSelection');
								sel_keyx = 0;
							}
						});
					}else{	
					showalert("Seleccione el registro a eliminar", "", "gritter-info");
					}
				},
				title:"Eliminar",
			}
			],
		});
			setSizeBtnGrid('id_button0',35);
			setSizeBtnGrid('id_button1',35);		
	}
	function setSizeBtnGrid(id,tamanio)
	{
	$("#"+id).attr('width',tamanio+'px');
	$($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
	function LimpiarControles(){
			$("#txt_keyx").val("0");
			$("#txt_clave").val("");
			$("#txt_descripcion").val("");
			$("#txt_clave").focus();
	}
	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 388
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