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

$(function(){
	
	$("#btn_generarCierre").click(function(event){
		// showconfirm('¿Confirma que desea realizar el cierre de Colegiaturas?', 'question', undefined, undefined,
			// function onyes(){showalert("HOLA", "", "gritter-warning");});
		$("#btn_generarCierre").prop('disabled', true);
		bootbox.confirm(LengStrMSG.idMSG316, 
		function(result)
		{
			$("#btn_generarCierre").prop('disabled', false);
			if (result)
			{
				generarCierreColegiaturas();
			}	
		});
		
		event.preventDefault();
	});
	
	function generarCierreColegiaturas() {
		$.ajax({type:'POST',
			url:'ajax/json/json_fun_generar_cierre_colegiaturas.php',
			data:{'session_name':Session},
			beforeSend:function(){},
			success:function(data){
				var dataJson = JSON.parse(data);
				if (dataJson.idu_estatus < 0) {
					showalert(dataJson.des_estatus, "","gritter-error");	
				} else {
					showalert(dataJson.des_estatus, "","gritter-info");	
				}
			},
			error:function onError(){},
			complete:function(){},
			timeout: function(){},
			abort: function(){}
		});
	}

	function ConsultaClaveHCM(){
        $.ajax({type: "POST", 
            url:'ajax/json/json_proc_consultaropcionesapagado_hcm.php',
            data: {                 
                'iOpcion': 404
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