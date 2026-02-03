$(function(){
	
	setTimeout(function(){
		var params = {};
		loadContent("ajax/frm/frm_cargar_configuracion.php", params);
	}, 0);
	
	$(document).on("focus", "input[type=text]", function() {
        $(this).attr("autocomplete", "off");
    });
	
	/****************Agregar codigo Aqui como funciones que se ejecuten ingresando al sistema****************/
	/*
	var interval = 60 * 1; // 1 minuto, indica cada cuánto se ejecutará la tarea
	
	setInterval(function () {
		minutes = parseInt(interval / 60)
		seconds = parseInt(interval % 60);
		
		minutes = minutes < 10 ? "0" + minutes : minutes;
		seconds = seconds < 10 ? "0" + seconds : seconds;
		
		//console.log(minutes + ":" + seconds);
		
		if (--interval < 0) {
			interval = 60 * 1;
			$.ajax({type:'POST',
				url:'ajax/proc/proc_resetsesion.php',
				data:{'session_name':'Colegiaturas'},
				beforeSend:function(){},
				success:function(data){
					console.log("Reinicio de sesión");
				},
				error:function onError(){},
				complete:function(){},
				timeout: function(){},
				abort: function(){}
			});
		}
	}, 1000);
	*/
	
	$.datepicker.regional['es'] = {
		closeText: 'Cerrar',
		changeMonth: true,
		changeYear: true,
		currentText: 'Hoy',
		monthNames: ['Enero', 'Febrero', 'Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'],
		monthNamesShort: ['Ene', 'Feb', 'Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'],
		dayNames: ['Domingo','Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'],
		dayNamesShort: ['Dom','Lun','Mar','Mié','Jue','Vie','Sáb'],
		dayNamesMin: ['Do','Lu','Ma','Mi','Ju','Vi','Sa'],
		weekHeader: 'Sm',
		dateFormat: 'dd/mm/yy',
		firstDay: 0,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''
	};
	$.datepicker.setDefaults($.datepicker.regional['es']);
	
	$("body").attr("ondragenter", "event.dataTransfer.dropeffect='none'");
	$("body").attr("ondragover", "event.preventDefault();event.dataTransfer.dropEffect = 'none'");
	
	// function ObtenerMensajes()
	// {	
		// $.ajax({type:'POST',
			// url: "ajax/json/json_fun_consultarcatalogomensajes.php?",
			// data:{'session_name' : Session},
			// beforeSend:function(){},
			// success:function(data){
				// var dataJson = jQuery.parseJSON(data);
			// },
			// error:function onError(){},
			// complete:function(){},
			// timeout: function(){},
			// abort: function(){}
		// });
	
	// }
	
	
	
});