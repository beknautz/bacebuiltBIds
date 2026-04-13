<?php
require_once __DIR__ . '/../config/bootstrap.php';

$navActive  = 'clients';
$pageTitle  = 'Clients';
$clientSvc  = new ClientService();

$deleted = (int) ($_GET['deleted'] ?? 0);
$clients = $clientSvc->getAll(false);

include __DIR__ . '/_header.php';
?>

<div class="d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
  <h1 class="page-title mb-0"><i class="bi bi-people me-2"></i>Clients</h1>
  <a href="client_edit.php" class="btn btn-gold btn-sm">
    <i class="bi bi-plus-lg me-1"></i>New Client
  </a>
</div>

<?php if ($deleted): ?>
  <div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle me-2"></i>Client removed.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<?php endif; ?>

<p class="form-hint mb-2"><?= count($clients) ?> client<?= count($clients) !== 1 ? 's' : '' ?></p>

<div class="card-bb">
  <div class="table-responsive">
    <table class="table table-bb mb-0">
      <thead>
        <tr>
          <th>Company</th>
          <th>Contact</th>
          <th>Email</th>
          <th>Phone</th>
          <th>Location</th>
          <th>Bids</th>
          <th class="text-center" style="width:120px">Actions</th>
        </tr>
      </thead>
      <tbody>
        <?php if (empty($clients)): ?>
          <tr><td colspan="7" class="text-center py-4 text-gold" style="font-family:Georgia,serif;">
            No clients yet. <a href="client_edit.php" class="text-gold">Add your first client →</a>
          </td></tr>
        <?php endif; ?>
        <?php foreach ($clients as $c): ?>
          <?php $bidCount = $clientSvc->getBidCount($c['client_id']); ?>
          <tr>
            <td class="fw-bold"><?= h($c['company_name']) ?></td>
            <td><?= h($c['contact_name']) ?></td>
            <td>
              <?php if ($c['email']): ?>
                <a href="mailto:<?= h($c['email']) ?>" class="text-gold"><?= h($c['email']) ?></a>
              <?php endif; ?>
            </td>
            <td><?= h($c['phone']) ?></td>
            <td>
              <?php
                $parts = array_filter([$c['city'], $c['state']]);
                echo h(implode(', ', $parts));
              ?>
            </td>
            <td>
              <?php if ($bidCount > 0): ?>
                <a href="bids.php" class="text-gold"><?= $bidCount ?> bid<?= $bidCount !== 1 ? 's' : '' ?></a>
              <?php else: ?>
                <span class="text-muted">0</span>
              <?php endif; ?>
            </td>
            <td class="text-center text-nowrap">
              <a href="client_edit.php?client_id=<?= $c['client_id'] ?>"
                 class="btn btn-outline-gold btn-sm px-2" title="Edit">
                <i class="bi bi-pencil"></i>
              </a>
              <a href="client_delete.php?client_id=<?= $c['client_id'] ?>"
                 class="btn btn-outline-danger btn-sm px-2" title="Remove"
                 onclick="return confirm('Remove <?= h(addslashes($c['company_name'])) ?> from your client list?')">
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
