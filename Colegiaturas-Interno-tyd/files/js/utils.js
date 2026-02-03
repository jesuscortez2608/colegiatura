function formatearFecha(fecha){
	// fecha - debe tener formato dd/mm/yyyy para devolverla en formato yyyymmdd
	// ejemplo: 21/05/2013
	//			20130521
	var fecha_aux = fecha.split('/');
	anio =fecha_aux[2];
	mes = fecha_aux[1];
	dia = fecha_aux[0];
	return (anio + mes + dia);
}

function fnObtenerSecuencia(callback) {
	/* Ejemplo:
		fnObtenerSecuencia(function(secuencia){
			alert(secuencia);
		});
	*/
	$.ajax({type:'POST',
		url:'ajax/json/json_fun_obtener_secuencia_colegiaturas.php',
		data:{'session_name' : Session},
		beforeSend:function(){},
		success:function(data){
			//var dataJson = jQuery.parseJSON(data);
			var dataJson = JSON.parse(data);
			if (callback != undefined) {
				callback(dataJson.secuencia);
			}
		},
		error:function onError(){},
		complete:function(){},
		timeout: function(){},
		abort: function(){}
	});
}

function fnConsultaBlog(iNumEmp, iFactura)
{
	$("#div_Blog").html("");
	var option="";
	$.ajax({type: "POST",
	url: "ajax/json/json_fun_obtener_notificaciones_por_empleado.php",
	data: { 'iEmpleado':iNumEmp,'iFactura':iFactura}
	}).done(function(data){
		data = encodeURIComponent(data);
		data = decodeURIComponent(data);
		//var dataJson = jQuery.parseJSON(data);
		var dataJson = JSON.parse(data);
		if(dataJson.estado == 0) {
			for(var i=0;i<dataJson.datos.length; i++) {
				option = option + 
				'<div class="itemdiv dialogdiv">'+
						'<div class="body">'+
							'<div class="time">'+
								'<i class="icon-time"></i>'+
								'<span class="green">'+' '+dataJson.datos[i].fecha+' '+dataJson.datos[i].hora+'</span>'+
							'</div>'+
							'<div class="name">'+
								'<a href="#">'+dataJson.datos[i].nombreOrigen+'</a>'+
							'</div>'+
							'<div class="text">'+dataJson.datos[i].comentario+'</div>'+
						'</div>'+
					'</div>';
			}
			if(dataJson.datos.length==0) {
				option="SIN COMENTARIOS";
			}
			$("#div_Blog").html(option);
			//$("#cbo_Deduccion").trigger("chosen:updated");
		}
		
	})
	.fail(function(s) {message("Error al cargar " + url ); $("#div_Blog").html("");})
	.always(function() {});
}

//BLOG REVISION OMAR LGA 22-06-2018
function fnConsultaBlogRevision(iNumEmp, iFactura)
{
	$("#div_Blog_Csc").html("");
	var option="";
	$.ajax({type: "POST",
	url: "ajax/json/json_fun_blog_revision.php",
	data: { 'iEmpleado':iNumEmp,'iFactura':iFactura}
	}).done(function(data){		
		data = encodeURIComponent(data);
		data = decodeURIComponent(data);
		//var dataJson = jQuery.parseJSON(data);
			var dataJson = JSON.parse(data);
		if(dataJson.estado == 0) {
			for(var i=0;i<dataJson.datos.length; i++) {
				option = option + 
				'<div class="itemdiv dialogdiv">'+
						'<div class="body">'+
							'<div class="time">'+
								'<i class="icon-time"></i>'+
								'<span class="green">'+' '+dataJson.datos[i].fecha+' '+dataJson.datos[i].hora+'</span>'+
							'</div>'+
							'<div class="name">'+
								'<a href="#">'+dataJson.datos[i].nombreOrigen+'</a>'+
							'</div>'+
							'<div class="text">'+dataJson.datos[i].comentario+'</div>'+
						'</div>'+
					'</div>';
			}
			if(dataJson.datos.length==0) {
				option="SIN COMENTARIOS";
			}
			$("#div_Blog_Csc").html(option);
			//$("#cbo_Deduccion").trigger("chosen:updated");
		}
		
	})
	.fail(function(s) {message("Error al cargar " + url ); $("#div_Blog_Csc").html("");})
	.always(function() {});
}

function fnConsultaAvisos(iOpcion)
{//fun_activar_aviso_colegiaturas 
	$("#div_MostrarMensaje").html("");
	var option="";
	$.ajax({type: "POST",
	url: "ajax/json/json_fun_activar_aviso_colegiaturas.php",
	data: { 'iOpcion':iOpcion}
	}).done(function(data){		
		data = encodeURIComponent(data);
		data = decodeURIComponent(data);
		//var dataJson = jQuery.parseJSON(data);
		var dataJson = JSON.parse(data);
		if(dataJson.estado == 0)
		{
			if(dataJson.datos.length>0)
			{
				//option='<div class="alert alert-block"><i class="icon-asterisk blue"></i> ';
				option='<div style="color:black" class="alert alert-block"><div style="color:red;font-size:16px"><b>AVISO IMPORTANTE</b></div>';
				for(var i=0;i<dataJson.datos.length; i++)
				{
					option = option + '<i class="icon-asterisk blue"></i> '+dataJson.datos[i].mensaje+' ' ;
				}
				option = option +'</div>';
				$("#div_MostrarMensaje").html(option);
			}	
			else
			{
				$("#div_MostrarMensaje").css('display','none');
			}
		}
		
	})
	.fail(function(s) {message("Error al cargar " + url ); $("#div_MostrarMensaje").html("");})
	.always(function() {});
}
function showconfirm(cMensaje,cIcono,twidth,theight,onYes,onNot,onCancel,onClose) {
	$('.divconfirm').dialog({
		autoOpen: false,
		title_html: true,
		width: 400,
		height: 200,
		modal: true,
		resizable: false,
		open: function (event, ui) {
			$(this).css('overflow', 'hidden'); //esconde las barras de scroll
		},
		closeOnEscape: true,
		buttons: {
			"Sí" : function() {
				if (onYes != undefined) {
					onYes();
				}
				$( this ).dialog( "close" );
			},
			"No" : function() {
				if (onNot != undefined) {
					onNot();
				}
				$( this ).dialog( "close" );
			},
			"Cancelar": function() {
				if (onCancel != undefined) {
					onCancel();
				}
				$( this ).dialog( "close" );
			}
		}
	});
	
	if (twidth == undefined || twidth <= 0){
		twidth = 400;
	}
	if (theight == undefined || theight <= 0) {
		theight = 200;
	}
	
	var content = '';
	if (cIcono == 'error') {
		$('.divconfirm').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-ban-circle'></i> Error</h4></div>");
		content = '<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else if (cIcono == 'alert') {
		$('.divconfirm').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-warning-sign'></i> Advertencia</h4></div>");
		content = '<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else if (cIcono == 'question') {
		$('.divconfirm').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-question'></i> Confirmar</h4></div>");
		content = '<span class="ui-icon ui-icon-help" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else if (cIcono == 'info') {
		$('.divconfirm').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-info'></i> Información</h4></div>");
		content = '<span class="ui-icon ui-icon-info" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else {
		$('.divconfirm').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-comment-alt'></i> Información</h4></div>");
		content = '';
	}
	
	$('.divconfirm').html('<p>' + content + cMensaje + '</p>');
	
	$('.divconfirm').dialog("option","width",'auto');
	$('.divconfirm').dialog("option","height",'auto');
	$('.divconfirm').dialog("option","close",onClose);
	
	if ( $('.divconfirm').width() < 400 ) {
		$('.divconfirm').dialog("option","width",400);
	}
	
	//$('.divconfirm').dialog("option","height",theight);
	$('.divconfirm').dialog( "open" );
}

function extractJson(data, callback){
	var initPos = data.indexOf('[{') != -1 ? data.indexOf('[{') : data.indexOf('{');
	var ret = '';
	if (initPos !=-1) {
		ret = data.substring(initPos);
	}
	callback(ret);
}

function validateAjaxData(data, onSuccess, onError){
	data = data.makeTrim(" ");
	
	if (data.indexOf('Warning') != -1) {
		extractJson(data, function(extdata){
			//var dataJson = jQuery.parseJSON(extdata);
			var dataJson = JSON.parse(data);
			//var msg = dataJson.mensajeOriginal != undefined? dataJson.mensajeOriginal : dataJson.mensaje;
			var msg = dataJson.mensaje != undefined ? dataJson.mensaje : dataJson[0].mensaje;
			showmessage(msg, 'error', undefined, undefined, function onclose(){
				if (onError != undefined) {
					onError();
				}
			});
		});
	} else {
		if (onSuccess != undefined) {
			onSuccess();
		}
	}
}

// FUNCION TRIM PARA EVITAR VULNERABILIDAD

	String.prototype.makeTrim = function (characters) {

		let result = this;
	
		for (let i = 0; i < characters.length; i++) {
			while (result.charAt(0) === characters[i]) {
				result = result.substring(1);
			}
	
			while (result.charAt(result.length - 1) === characters[i]) {
				result = result.substring(0, result.length - 1);
			}
		}
		return result;
	}

function ajaxcall(cType, cUrl, oData, onBeforeSend, onSuccess, onError, onComplete, onTimeout, onAbort, cWaitMessage){
	$.ajax({type:cType,
		url:cUrl,
		data:oData,
		beforeSend:function(){
			if (cWaitMessage != undefined) {
				waitwindow(cWaitMessage, 'open');
			} else {
				waitwindow('Procesando...', 'open');
			}
			if (onBeforeSend != undefined){
				onBeforeSend();
			}
		},
		success:function(data){
			waitwindow('Proceso terminado', 'close');
			validateAjaxData(data, function ok(){
					if (onSuccess != undefined) {
						onSuccess(data);
					}
				}, function error() {
					if (onError != undefined) {
						onError();
					}
				});
		},
		error:function(){
			waitwindow('Error ...', 'close');
			showmessage('Ocurrió un error en la ejecución del proceso', 'error', undefined, undefined, function onclose(){
				if (onError != undefined){
					onError();
				}
			});
		},
		complete:function(){
			waitwindow('', 'close');
			if (onComplete != undefined){
				onComplete();
			}
		},
		timeout: function(){
			waitwindow('', 'close');
			showmessage('Tiempo de espera agotado', 'error', undefined, undefined, function onclose(){
				if (onTimeout != undefined){
					onTimeout();
				}
			});
		},
		abort: function(){
			waitwindow('', 'close');
			showmessage('Proceso abortado por el usuario', 'error', undefined, undefined, function onclose(){
				if (onAbort != undefined){
					onAbort();
				}
			});
		}
	});
}

function waitwindow(cMensaje,cOpcion,twidth,theight,onClose){
	if (cMensaje == undefined) {
		cMensaje = "Por favor, espere";
	}
	if (cOpcion == undefined) {
		cOpcion = 'open';
	}
	
	if (cOpcion == 'close') {
		$('.divwait').dialog('close');
	} else {
		$('.divwait').dialog({
			autoOpen: false,
			width: 300,
			height: 80,
			modal: true,
			resizable: false,
			closeOnEscape: false,
			dialogClass: 'noTitleStuff',
			open: function (event, ui) {
				$(this).css('overflow', 'hidden'); //esconde las barras de scroll
			}
		});
		
		if (twidth == undefined || twidth <= 0){
			twidth = 'auto';
		}
		
		if (theight == undefined || theight <= 0) {
			theight = '35'; //50;
		}
		
		var opts_spin = {
			lines: 13, // The number of lines to draw
			length: 5, // The length of each line
			width: 2, // The line thickness
			radius: 5, // The radius of the inner circle
			corners: 1, // Corner roundness (0..1)
			rotate: 0, // The rotation offset
			direction: 1, // 1: clockwise, -1: counterclockwise
			color: '#000', // #rgb or #rrggbb or array of colors
			speed: 1, // Rounds per second
			trail: 48, // Afterglow percentage
			shadow: false, // Whether to render a shadow
			hwaccel: false, // Whether to use hardware acceleration
			className: 'spinner', // The CSS class to assign to the spinner
			zIndex: 2e9, // The z-index (defaults to 2000000000)
			top: 'auto', // Top position relative to parent in px
			left: 'auto' // Left position relative to parent in px
		};
		
		var content = '';
		$('.divwait').dialog("option","title","Por favor, espere ...");
		content = '<span id="spanspin" style="float:left; margin: 10px 7px 50px 0px;"></span>';
		cMensaje = '<label style="padding-left:15px;"><i><b>' + cMensaje + '</b></i></label>';
		$('.divwait').html('<p>' + content + cMensaje + '</p>');
		
		$('#spanspin').spin(opts_spin);
		
		$('.divwait').dialog("option","width",'' + twidth + ''); //auto
		$('.divwait').dialog("option","height",'' + theight + ''); //auto
		$('.divwait').dialog("option","close", onClose);
		
		$('.divwait').dialog( "open" );
	}
}

function showmessage(cMensaje,cIcono,twidth,theight,onClose){
	$('.divmsg').dialog({
		autoOpen: false,
		title_html: true,
		width: 400,
		height: 200,
		modal: true,
		resizable: false,
		open: function (event, ui) {
			$(this).css('overflow', 'hidden'); //esconde las barras de scroll
		},
		closeOnEscape: true,
		buttons: {
			"Cerrar": function() {
				$( this ).dialog( "close" );
			}
		}
	});
	
	if (twidth == undefined || twidth <= 0){
		twidth = 400;
	}
	if (theight == undefined || theight <= 0) {
		theight = 200;
	}
	
	var content = '';
	if (cIcono == 'error') {
		$('.divmsg').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-exclamation-sign'></i> Error</h4></div>");
		content = '<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else if (cIcono == 'alert') {
		$('.divmsg').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-warning-sign'></i> Advertencia</h4></div>");
		content = '<span class="ui-icon ui-icon-alert" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else if (cIcono == 'question') {
		$('.divmsg').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-question'></i> Pregunta</h4></div>");
		content = '<span class="ui-icon ui-icon-help" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else if (cIcono == 'info') {
		$('.divmsg').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'><i class='icon-info-sign'></i> Información</h4></div>");
		content = '<span class="ui-icon ui-icon-info" style="float: left; margin: 0 7px 50px 0;"></span>';
	} else {
		$('.divmsg').dialog("option","title","<div class='widget-header widget-header-small'><h4 class='smaller'>Mensaje</h4></div>");
		content = '';
	}
	
	$('.divmsg').html('<p>' + content + cMensaje + '</p>');
	
	$('.divmsg').dialog("option","width",'auto');
	$('.divmsg').dialog("option","height",'auto');
	$('.divmsg').dialog("option","close",onClose);
	
	if ( $('.divmsg').width() < 400 ) {
		$('.divmsg').dialog("option","width",400);
	}
	
	//$('.divmsg').dialog("option","height",theight);
	$('.divmsg').dialog( "open" );
}

//Alertas
function showalert(message, title, grittertype) {
	$.gritter.add({
		title: title,
		text: message,
		style: "",
		sticky: false,
		//font: 20px
		// position: 'top-right',
		time: 3500,
		class_name: grittertype,
		before_open: function(){
			if($('.gritter-without-image').length == 3)
			{
				//Returning false prevents a new gritter from opening.
				return false;
			}
		}
	});
	return false;
}	

$(function(){
	$(".numbersOnly").keypress(function(event) {
		// Backspace, tab, enter, end, home, left, right
		// We don't support the del key in Opera because del == . == 46.
		//var controlKeys = [8, 9, 13, 35, 36, 37, 39];
		var controlKeys = [8, 9, 13]; // Quité 35(#),36($),37(%),13(enter), 39(comilla simple) 
		// IE doesn't support indexOf
		// alert(new RegExp(event.which)); // Por si quieres ver que tecla pulsaste
		var isControlKey = controlKeys.join(",").match(new RegExp(event.which));
		// Some browsers just don't raise events for control keys. Easy.
		// e.g. Safari backspace.
		if (!event.which || // Control keys in most browsers. e.g. Firefox tab is 0
			(48 <= event.which && event.which <= 57) || // Always 1 through 9
			//(48 == event.which && $(this).attr("value")) || // No 0 first digit, not necesary if value could be 0
			isControlKey) { // Opera assigns values for control keys.
			return;
		} else if (118 == event.which && event.ctrlKey ) {
			// Control V
			return;
		} else {
			event.preventDefault();
		}
	});
	
	$('.numbersOnly').on('paste', function(event) {
		var element = this;
		setTimeout(function () {
			var text = $(element).val();
			if ( (!isNaN(parseInt(text)) && isFinite(text)) ) {
				// console.log("es numerico");
				$(element).val(text);
			} else {
				// console.log("no es numérico");
				$(element).val("");
				event.preventDefault();
			}
		}, 0);
	});
	
	$(".currency").keypress(function(event) {
		// Backspace, tab, enter, end, home, left, right
		// We don't support the del key in Opera because del == . == 46.
		//var controlKeys = [8, 9, 13, 35, 36, 37, 39];
		
		var element = this;
		var text = $(element).val();
		var controlKeys = [8, 9, 13]; // Quité 35(#),36($),37(%),13(enter), 39(comilla simple) 
		// IE doesn't support indexOf
		// alert(new RegExp(event.which)); // Por si quieres ver que tecla pulsaste
		// console.log(new RegExp(event.which)); // Por si quieres ver que tecla pulsaste
		var isControlKey = controlKeys.join(",").match(new RegExp(event.which));
		// Some browsers just don't raise events for control keys. Easy.
		// e.g. Safari backspace.
		if (!event.which || // Control keys in most browsers. e.g. Firefox tab is 0
			(48 <= event.which && event.which <= 57) || // Always 1 through 9
			(46 <= event.which && event.which <= 46 &&  text.indexOf(".") < 0 ) || // .
			//(48 == event.which && $(this).attr("value")) || // No 0 first digit, not necesary if value could be 0
			isControlKey) { // Opera assigns values for control keys.
			return;
		} else if (118 == event.which && event.ctrlKey ) {
			// Control V
			return;
		} else {
			event.preventDefault();
		}
	});
	
	$(".textNumbersOnly").keypress(function(event) {
		var controlKeys = [8, 9, 35]; // Quité 35(#),36($),37(%),13(enter), 39 (comilla simple)
		var isControlKey = controlKeys.join(",").match(new RegExp(event.which));
		//alert(new RegExp(event.which));
		if (!event.which || // Control keys in most browsers. e.g. Firefox tab is 0
			(48 <= event.which && event.which <= 57) || // Always 1 through 9
			(event.which >= 97 && event.which <= 122) || // de la A-Z
			(event.which >= 65 && event.which <= 90) || // de la a-z
			(event.which == 241) || // ñ
			(event.which == 209) || // Ñ
			(event.which == 252) || // ü
			(event.which == 220) || // Ü
			(event.which == 193) || // Á
			(event.which == 201) || // É
			(event.which == 205) || // Í
			(event.which == 211) || // Ó
			(event.which == 218) || // Ú
			(event.which == 225) || // á
			(event.which == 233) || // é
			(event.which == 237) || // í
			(event.which == 243) || // ó
			(event.which == 250) || // ú
			(event.which == 33) || // !
			(event.which == 36) || // $
			(event.which == 37) || // %
			(event.which == 61) || // =
			(event.which == 63) || // ?
			(event.which == 191) || // ¿
			(event.which == 161) || // ¡
			(event.which == 38) || // &
			(event.which == 45) || // -
			(event.which == 47) || // /
			(event.which == 40) || // (
			(event.which == 41) || // )
			(event.which == 46) || // .
			(event.which == 58) || // :
			(event.which == 44) || // ,
			(event.which == 59) || // .
			(event.which == 95) || // _
			(event.which == 32) || // espacios en blanco
			isControlKey) { // Opera assigns values for control keys.
			return;
		} else {
			event.preventDefault();
		}
	});
	
	
	$(".textOnly").keypress(function(event) {
		var controlKeys = [8, 9, 35]; // Quité 36($),37(%),13(enter), 39 (comilla simple)
		var isControlKey = controlKeys.join(",").match(new RegExp(event.which));
		//alert(new RegExp(event.which));
		if (!event.which || // Control keys in most browsers. e.g. Firefox tab is 0
			(event.which >= 97 && event.which <= 122) || // de la A-Z
			(event.which >= 65 && event.which <= 90) || // de la a-z
			(event.which == 241) || // ñ
			(event.which == 209) || // Ñ
			(event.which == 252) || // ü
			(event.which == 220) || // Ü
			(event.which == 193) || // Á
			(event.which == 201) || // É
			(event.which == 205) || // Í
			(event.which == 211) || // Ó
			(event.which == 218) || // Ú
			(event.which == 225) || // á
			(event.which == 233) || // é
			(event.which == 237) || // í
			(event.which == 243) || // ó
			(event.which == 250) || // ú
			(event.which == 32) || // espacios en blanco
			isControlKey  ) { // Opera assigns values for control keys.
			return;
		} else {
			event.preventDefault();
		}

	});
/*	
	function setSizeBtnGrid(id,tamanio)
	{
	  $("#"+id).attr('width',tamanio+'px');
	  $($("#"+id+" .ui-icon")[0]).css({"font-size":tamanio+"px","width":"100%"})
	}
*/	
});
