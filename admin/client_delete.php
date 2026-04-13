<?php
require_once __DIR__ . '/../config/bootstrap.php';

$clientId = (int) ($_GET['client_id'] ?? 0);
if (!$clientId) {
    redirect('clients.php');
}

$clientSvc = new ClientService();
$clientSvc->softDelete($clientId);
redirect('clients.php?deleted=1');
