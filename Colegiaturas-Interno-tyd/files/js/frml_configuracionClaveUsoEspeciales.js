function Cargargrid(){
	jQuery("#gd_Claves").GridUnload();

	jQuery("#gd_Claves").jqGrid({
		url: 'ajax/json/json_fun_obtener_claves_uso_permitidas.php?',
		datatype: 'json',
		mtype: 'POST',
		colNames:LengStr.idMSG135,
		// ["Clave", "Descripción"],
		colModel:[
			{name:'num_Colaborador', 			index:'Num',		width:90, 	sortable: false,	align:"left",	fixed: true},
			{name:'num_Centro',					index:'num_Centro',		width:90, 	sortable: false,	align:"left",	fixed: true},
			{name:'puesto',						index:'puesto',		width:150,  sortable: false,	align:"left",	fixed: true},
			{name:'claveUso', 					index:'claveUso',	width:500, 	sortable: false,	align:"left",	fixed: true},
			{name:'opt_Indefinido',				index:'opt_Indefinido',width:450,	sortable: false,	align:"left",	fixed: true},
			{name:'opt_Bloqueado', 				index:'Fecopt_Bloqueado', 		width:200, 	sortable: false,	align:"left",	fixed: true},¨
			{name:'fecha_inicial', 				index:'fecha_inicial', 		width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'nom_colaboradorRegistro',	index:'nom_colaboradorRegistro', 		width:200, 	sortable: false,	align:"left",	fixed: true},
			{name:'fecha_registro', 			index:'fecha_registro', 		width:200, 	sortable: false,	align:"left",	fixed: true}
	
		],
		viewrecords : false,
		rowNum:-1,
		hidegrid: false,
		rowList:[],
		multiselect: false,
		width: null,
		shrinkToFit: true,
		height: 350,//null,//--> sepuede poner fijo si el alto no se quiere automatico  
		//----------------------------------------------------------------------------------------------------------
		caption: "Colaboradores",
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
				console.log(sel_keyx);
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
					console.log(sel_keyx);
					
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
							console.log(sel_keyx);
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
