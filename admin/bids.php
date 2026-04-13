<?php
require_once __DIR__ . '/../config/bootstrap.php';

$navActive     = 'bids';
$pageTitle     = 'Bids';
$bidSvc        = new BidService();

$filterStatus  = trim($_GET['status'] ?? '');
$filterSearch  = trim($_GET['search'] ?? '');
$deleted       = (int) ($_GET['deleted'] ?? 0);

$bids = $bidSvc->getAll($filterStatus, $filterSearch);

$statusMap = [
    'Draft'    => ['css' => 'badge-draft',    'icon' => 'bi-pencil'],
    'Sent'     => ['css' => 'badge-sent',     'icon' => 'bi-send'],
    'Accepted' => ['css' => 'badge-accepted', 'icon' => 'bi-check-circle'],
    'Declined' => ['css' => 'badge-declined', 'icon' => 'bi-x-circle'],
];

include __DIR__ . '/_header.php';
?>

<!-- Page header -->
<div class="d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
  <h1 class="page-title mb-0"><i class="bi bi-file-earmark-text me-2"></i>Bids</h1>
  <a href="bid_edit.php" class="btn btn-gold btn-sm">
    <i class="bi bi-plus-lg me-1"></i>New Bid
  </a>
</div>

<?php if ($deleted): ?>
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle me-2"></i>Bid deleted.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<?php endif; ?>

<!-- Filters -->
<form method="get" action="bids.php" class="row g-2 mb-3">
  <div class="col-auto">
    <select name="status" class="form-select form-select-sm" style="min-width:120px" onchange="this.form.submit()">
      <option value="">All Statuses</option>
      <?php foreach (['Draft', 'Sent', 'Accepted', 'Declined'] as $s): ?>
        <option value="<?= h($s) ?>"<?= ($filterStatus === $s) ? ' selected' : '' ?>><?= h($s) ?></option>
      <?php endforeach; ?>
    </select>
  </div>
  <div class="col-auto d-flex gap-1">
    <input type="text" name="search" class="form-control form-control-sm" placeholder="Search bids…"
           value="<?= h($filterSearch) ?>" style="min-width:200px">
    <button type="submit" class="btn btn-outline-gold btn-sm"><i class="bi bi-search"></i></button>
    <?php if ($filterStatus !== '' || $filterSearch !== ''): ?>
      <a href="bids.php" class="btn btn-outline-secondary btn-sm">Clear</a>
    <?php endif; ?>
  </div>
</form>

<!-- Results count -->
<p class="form-hint mb-2"><?= count($bids) ?> bid<?= count($bids) !== 1 ? 's' : '' ?> found</p>

<!-- Bid table -->
<div class="card-bb">
  <div class="table-responsive">
    <table class="table table-bb mb-0">
      <thead>
        <tr>
          <th>Bid #</th>
          <th>Client</th>
          <th>Title</th>
          <th>Date</th>
          <th>Valid Until</th>
          <th>Status</th>
          <th class="text-end">Total</th>
          <th class="text-center" style="width:160px">Actions</th>
        </tr>
      </thead>
      <tbody>
        <?php if (empty($bids)): ?>
          <tr><td colspan="8" class="text-center py-4 text-gold" style="font-family:Georgia,serif;">
            No bids found. <a href="bid_edit.php" class="text-gold">Create your first bid →</a>
          </td></tr>
        <?php endif; ?>
        <?php foreach ($bids as $bid): ?>
          <?php
            $bid_id     = $bid['bid_id'];
            $bid_status = $bid['status'];
            $sm         = $statusMap[$bid_status] ?? ['css' => 'badge-draft', 'icon' => 'bi-circle'];
          ?>
          <tr>
            <td class="text-gold fw-bold" style="font-family:Georgia,serif;white-space:nowrap">
              <a href="bid_edit.php?bid_id=<?= $bid_id ?>" class="text-gold text-decoration-none"><?= h($bid['bid_number']) ?></a>
            </td>
            <td>
              <div class="fw-bold"><?= h($bid['company_name']) ?></div>
              <div class="form-hint"><?= h($bid['contact_name']) ?></div>
            </td>
            <td><?= h($bid['bid_title']) ?></td>
            <td class="text-nowrap"><?= fmt_date($bid['bid_date']) ?></td>
            <td class="text-nowrap">
              <?= $bid['valid_until'] ? fmt_date($bid['valid_until']) : '<span class="text-muted">—</span>' ?>
            </td>
            <td id="status-cell-<?= $bid_id ?>">
              <?php include __DIR__ . '/htmx/_status_cell.php'; ?>
            </td>
            <td class="text-end text-nowrap fw-bold"><?= dollar($bid['total']) ?></td>
            <td class="text-center text-nowrap">
              <a href="bid_edit.php?bid_id=<?= $bid_id ?>"
                 class="btn btn-outline-gold btn-sm px-2" title="Edit">
                <i class="bi bi-pencil"></i>
              </a>
              <a href="../proposal_preview.php?bid_id=<?= $bid_id ?>"
                 class="btn btn-outline-secondary btn-sm px-2" title="Preview Proposal" target="_blank">
                <i class="bi bi-eye"></i>
              </a>
              <a href="../proposal_pdf.php?bid_id=<?= $bid_id ?>"
                 class="btn btn-outline-secondary btn-sm px-2" title="Export PDF" target="_blank">
                <i class="bi bi-file-pdf"></i>
              </a>
              <a href="bid_delete.php?bid_id=<?= $bid_id ?>"
                 class="btn btn-outline-danger btn-sm px-2" title="Delete"
                 onclick="return confirm('Delete bid <?= h(addslashes($bid['bid_number'])) ?>? This cannot be undone.')">
                <i class="bi bi-trash3"></i>
              </a>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<?php include __DIR__ . '/_footer.php'; ?>
