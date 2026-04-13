<?php
require_once __DIR__ . '/../../config/bootstrap.php';

$bidSvc   = new BidService();
$bid_id   = (int)  ($_POST['bid_id']     ?? 0);
$newSt    = trim(  $_POST['new_status']  ?? '');

if ($bid_id > 0 && $newSt !== '') {
    try {
        $bidSvc->updateStatus($bid_id, $newSt);
    } catch (InvalidArgumentException $e) {
        // Invalid status — ignore and fall through to display current status
    }
}

// Re-query to get fresh status
$statusMap = [
    'Draft'    => ['css' => 'badge-draft',    'icon' => 'bi-pencil'],
    'Sent'     => ['css' => 'badge-sent',     'icon' => 'bi-send'],
    'Accepted' => ['css' => 'badge-accepted', 'icon' => 'bi-check-circle'],
    'Declined' => ['css' => 'badge-declined', 'icon' => 'bi-x-circle'],
];

$db   = get_pdo();
$stmt = $db->prepare('SELECT bid_id, status FROM bb_bids WHERE bid_id = ?');
$stmt->execute([$bid_id]);
$row  = $stmt->fetch();

if ($row) {
    $bid_id     = (int) $row['bid_id'];
    $bid_status = $row['status'];
    include __DIR__ . '/_status_cell.php';
}
