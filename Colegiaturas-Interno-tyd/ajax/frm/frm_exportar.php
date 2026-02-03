<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
	date_default_timezone_set('America/Denver');

	$_POSTS = filter_input_array(INPUT_POST,FILTER_SANITIZE_SPECIAL_CHARS);
	
?>
<!-- Vulnerabilidad Potential_Clickjacking_on_Legacy_Browsers -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>
<!-- Vulnerabilidad Potential_Clickjacking_on_Legacy_Browsers -->

<div id="divexportcontent">
	<script>
		$(function(){
			var title=$('#title').val(),
				filter=$('#filter').val(),
				data=$('#data').val(),
				fname=$('#fname').val();
			
			$('#cnt_exportar').dialog({
				autoOpen: true,
				width: 225,
				modal: true,
				resizable: false,
				buttons: {
					Exportar: function() {
						exportData();
					},
					Cerrar: function() {
						$(this).dialog( "close" );
					}
				},
				close: function(event){
					$(this).hide();
					$(this).dialog('destroy');
					$('#divexportcontent').remove();
				}
			});
			
			function exportData() {
				var stringUrl = '';
				if ( $('#cbo_exportar').val() == 'xls' ) {
				    stringUrl = "../../../utilidadesweb/src/com/coppel/utils/export/JsonToExcel.php";
				} else if ( $('#cbo_exportar').val() == 'pdf' ) {
					stringUrl = "../../../utilidadesweb/src/com/coppel/utils/export/JsonToPdf.php";
				} else {
					alert('Formato no disponible: ' + $('#cbo_exportar').val())
				}
				
				var jhq = $.ajax({type: "POST",
							url: stringUrl,
							data: {
								'title' : title,
								'filter' : filter,
								'data' : data,
								'fname' : fname
							}
					})
					.done(function(data) {
						if ( $('#cbo_exportar').val() == 'xls' ) {
							$('#formgetexcelfile').submit();
							$('#cnt_exportar').dialog('close');
	    				} else if ( $('#cbo_exportar').val() == 'pdf' ) {
	    					$('#formgetpdffile').submit();
							$('#cnt_exportar').dialog('close');
						}
					})
					.fail(function() { 
						//alert("error"); 
					})
					.always(function() { 
						//alert("complete"); 
					});
			}
		});
	</script>
	<div id="cnt_exportar" title="Exportar datos">
		<table>
			<tr>
				<td>Enviar documento a:</td>
				<td>
					<select id="cbo_exportar">
						<option value="xls">Excel</option>
						<option value="pdf">Pdf</option>
					</select>
				</td>
			</tr>
		</table>
		<input type="hidden" id="data" value='<?php echo $_POSTS['data']; ?>'/>
		<input type="hidden" id="title" value="<?php echo $_POSTS['title']; ?>"/>
		<input type="hidden" id="filter" value="<?php echo isset($_POST['filter']) ? $_POSTS['filter'] : ''; ?>"/>
		<input type="hidden" id="fname" value="<?php echo isset($_POST['fname']) ? $_POSTS['fname'] : 'file'; ?>"/>
		<form id="formgetexcelfile" name="formgetexcelfile" action="../../../utilidadesweb/src/com/coppel/utils/export/GetExcelFile.php" method="POST">
			<input type="hidden" id="filename" name="filename" value="<?php echo $_POSTS['fname']; ?>"/>
		</form>
		<form id="formgetpdffile" name="formgetpdffile" action="../../../utilidadesweb/src/com/coppel/utils/export/GetPdfFile.php" 
			method="POST" enctype="multipart/form-data">
		</form>
	</div>
</div>