<?php
/**
 * proposal_pdf.php — Export a bid as a PDF using mPDF.
 *
 * Prerequisites:
 *   composer require mpdf/mpdf
 *   (run `composer install` in the project root before using this page)
 */
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

// Sanitise filename for Content-Disposition
$safeNum = preg_replace('/[^A-Za-z0-9\-]/', '_', $bid['bid_number'] ?? 'proposal');

// Capture the proposal template as an HTML string
ob_start();
include __DIR__ . '/proposal_template.php';
$html = ob_get_clean();

// Check that mPDF is available (installed via Composer)
$autoload = __DIR__ . '/vendor/autoload.php';
if (!file_exists($autoload)) {
    // Fallback: stream the HTML with a print stylesheet when Composer deps are missing
    header('Content-Type: text/html; charset=utf-8');
    echo $html;
    exit;
}

require_once $autoload;

$mpdf = new \Mpdf\Mpdf([
    'format'        => 'Letter',
    'margin_top'    => 12.7,
    'margin_bottom' => 12.7,
    'margin_left'   => 12.7,
    'margin_right'  => 12.7,
    'default_font'  => 'arial',
]);

$mpdf->SetTitle('Proposal ' . ($bid['bid_number'] ?? ''));
$mpdf->WriteHTML($html);
$mpdf->Output("Proposal-{$safeNum}.pdf", 'D');
