<?php
require_once __DIR__ . '/../config/bootstrap.php';

$bidId = (int) ($_GET['bid_id'] ?? 0);
if (!$bidId) {
    redirect('bids.php');
}

$bidSvc = new BidService();
$data   = $bidSvc->getById($bidId);
if (empty($data)) {
    redirect('bids.php');
}

$bidSvc->deleteBid($bidId);
redirect('bids.php?deleted=1');
