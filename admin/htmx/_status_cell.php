<?php
/**
 * Partial — renders the status badge + quick-transition buttons for ONE bid row.
 * Expects: $bid_id (int), $bid_status (string), $statusMap (array)
 * Called inline from bids.php and returned by htmx/update_bid_status.php
 */
$sm = $statusMap[$bid_status] ?? ['css' => 'badge-draft', 'icon' => 'bi-circle'];
?>
<span class="badge-status <?= $sm['css'] ?>">
  <i class="bi <?= $sm['icon'] ?> me-1"></i><?= h($bid_status) ?>
</span>
<br>
<?php if ($bid_status === 'Draft'): ?>
  <button class="btn btn-outline-secondary btn-sm mt-1 workflow-btn"
          hx-post="htmx/update_bid_status.php"
          hx-vals='{"bid_id":"<?= $bid_id ?>","new_status":"Sent"}'
          hx-target="#status-cell-<?= $bid_id ?>"
          hx-swap="innerHTML">
    <i class="bi bi-send me-1"></i>Mark Sent
  </button>
<?php elseif ($bid_status === 'Sent'): ?>
  <button class="btn btn-outline-success btn-sm mt-1 me-1 workflow-btn"
          hx-post="htmx/update_bid_status.php"
          hx-vals='{"bid_id":"<?= $bid_id ?>","new_status":"Accepted"}'
          hx-target="#status-cell-<?= $bid_id ?>"
          hx-swap="innerHTML">
    <i class="bi bi-check-circle me-1"></i>Accept
  </button>
  <button class="btn btn-outline-danger btn-sm mt-1 workflow-btn"
          hx-post="htmx/update_bid_status.php"
          hx-vals='{"bid_id":"<?= $bid_id ?>","new_status":"Declined"}'
          hx-target="#status-cell-<?= $bid_id ?>"
          hx-swap="innerHTML">
    <i class="bi bi-x-circle me-1"></i>Decline
  </button>
<?php elseif ($bid_status === 'Accepted' || $bid_status === 'Declined'): ?>
  <button class="btn btn-outline-secondary btn-sm mt-1 workflow-btn"
          hx-post="htmx/update_bid_status.php"
          hx-vals='{"bid_id":"<?= $bid_id ?>","new_status":"Draft"}'
          hx-target="#status-cell-<?= $bid_id ?>"
          hx-swap="innerHTML">
    <i class="bi bi-arrow-counterclockwise me-1"></i>Reset Draft
  </button>
<?php endif; ?>
