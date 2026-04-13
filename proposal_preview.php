<?php
require_once __DIR__ . '/config/bootstrap.php';

$bidId = (int) ($_GET['bid_id'] ?? 0);
if (!$bidId) {
    redirect('admin/bids.php');
}

$bidSvc = new BidService();
$data   = $bidSvc->getById($bidId);
if (empty($data)) {
    redirect('admin/bids.php');
}

$bid             = $data['bid'];
$lineItems       = $data['lineItems'];
$scopeItems      = $data['scopeItems'];
$timelinePhases  = $data['timelinePhases'];
$paymentSchedule = $data['paymentSchedule'];

// Render the shared proposal template directly in the browser
include __DIR__ . '/proposal_template.php';
