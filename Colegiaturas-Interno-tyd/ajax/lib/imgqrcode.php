<?php
include('../../../utilidadesweb/librerias/phpqrcode/qrlib.php');
$logitud=strlen(substr($_GET['Comprobante_total'],strpos($_GET['Comprobante_total'], '.')));
$total=str_pad(strval($_GET['Comprobante_total']),strlen($_GET['Comprobante_total'])+(7-$logitud),"0");
$total=str_pad($total, 17,"0",STR_PAD_LEFT);
error_log("logintud total=".strlen(str_pad($total, 17,"0",STR_PAD_LEFT)));
$qrcode="?re=".$_GET['emisor_rfc']."&rr=".$_GET['receptor_rfc']."&tt=".$total."&id=".$_GET['tfd_UUID'];

QRcode::png($qrcode);


?>