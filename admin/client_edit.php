<?php
require_once __DIR__ . '/../config/bootstrap.php';

$navActive  = 'clients';
$clientSvc  = new ClientService();

$clientId  = (int) ($_GET['client_id'] ?? 0);
$isNew     = ($clientId === 0);
$pageTitle = $isNew ? 'New Client' : 'Edit Client';
$saveError = '';
$saved     = (int) ($_GET['saved'] ?? 0);

// ── Handle POST ───────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $d = [
        'client_id'   => (int)  ($_POST['client_id']    ?? 0),
        'company_name'=> trim(  $_POST['company_name']  ?? ''),
        'contact_name'=> trim(  $_POST['contact_name']  ?? ''),
        'email'       => trim(  $_POST['email']         ?? ''),
        'phone'       => trim(  $_POST['phone']         ?? ''),
        'address'     => trim(  $_POST['address']       ?? ''),
        'city'        => trim(  $_POST['city']          ?? ''),
        'state'       => trim(  $_POST['state']         ?? ''),
        'zip'         => trim(  $_POST['zip']           ?? ''),
        'notes'       => trim(  $_POST['notes']         ?? ''),
    ];

    if ($d['company_name'] === '') {
        $saveError = 'Company name is required.';
    } else {
        try {
            $savedId = $clientSvc->save($d);
            redirect("client_edit.php?client_id={$savedId}&saved=1");
        } catch (Throwable $e) {
            $saveError = $e->getMessage();
        }
    }
}

// ── Load client ───────────────────────────────────────────────────
$client = $isNew ? [] : $clientSvc->getById($clientId);

include __DIR__ . '/_header.php';
?>

<div class="d-flex align-items-center justify-content-between mb-3">
  <h1 class="page-title mb-0">
    <i class="bi bi-person-vcard me-2"></i><?= h($pageTitle) ?>
  </h1>
  <a href="clients.php" class="btn btn-outline-secondary btn-sm">
    <i class="bi bi-arrow-left me-1"></i>All Clients
  </a>
</div>

<?php if ($saveError): ?>
  <div class="alert alert-danger alert-dismissible fade show">
    <i class="bi bi-exclamation-triangle me-2"></i><?= h($saveError) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<?php endif; ?>
<?php if ($saved): ?>
  <div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle me-2"></i>Client saved successfully.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<?php endif; ?>

<form method="post" action="client_edit.php">
<input type="hidden" name="client_id" value="<?= $clientId ?>">

<div class="row g-3">
  <div class="col-lg-8">
    <div class="card-bb mb-3">
      <div class="card-header"><i class="bi bi-building me-1"></i>Company &amp; Contact</div>
      <div class="card-body">
        <div class="row g-2">
          <div class="col-12">
            <label class="form-label">Company Name <span class="text-gold">*</span></label>
            <input type="text" name="company_name" class="form-control" required
                   value="<?= h($client['company_name'] ?? '') ?>"
                   placeholder="ABC Construction LLC">
          </div>
          <div class="col-md-6">
            <label class="form-label">Primary Contact Name</label>
            <input type="text" name="contact_name" class="form-control"
                   value="<?= h($client['contact_name'] ?? '') ?>" placeholder="Jane Smith">
          </div>
          <div class="col-md-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control"
                   value="<?= h($client['email'] ?? '') ?>" placeholder="jane@example.com">
          </div>
          <div class="col-md-3">
            <label class="form-label">Phone</label>
            <input type="text" name="phone" class="form-control"
                   value="<?= h($client['phone'] ?? '') ?>" placeholder="(555) 000-0000">
          </div>
        </div>
      </div>
    </div>

    <div class="card-bb mb-3">
      <div class="card-header"><i class="bi bi-geo-alt me-1"></i>Address</div>
      <div class="card-body">
        <div class="row g-2">
          <div class="col-12">
            <label class="form-label">Street Address</label>
            <input type="text" name="address" class="form-control"
                   value="<?= h($client['address'] ?? '') ?>">
          </div>
          <div class="col-md-5">
            <label class="form-label">City</label>
            <input type="text" name="city" class="form-control"
                   value="<?= h($client['city'] ?? '') ?>">
          </div>
          <div class="col-md-2">
            <label class="form-label">State</label>
            <input type="text" name="state" class="form-control"
                   value="<?= h($client['state'] ?? '') ?>" maxlength="2">
          </div>
          <div class="col-md-5">
            <label class="form-label">ZIP</label>
            <input type="text" name="zip" class="form-control"
                   value="<?= h($client['zip'] ?? '') ?>">
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="col-lg-4">
    <div class="card-bb mb-3">
      <div class="card-header"><i class="bi bi-sticky me-1"></i>Notes</div>
      <div class="card-body">
        <textarea name="notes" class="form-control" rows="10"
                  placeholder="Notes about this client — preferences, history, contacts…"><?= h($client['notes'] ?? '') ?></textarea>
      </div>
    </div>
  </div>
</div>

<div class="d-flex justify-content-between mb-5">
  <?php if (!$isNew): ?>
    <a href="client_delete.php?client_id=<?= $clientId ?>" class="btn btn-outline-danger btn-sm"
       onclick="return confirm('Remove this client?')">
      <i class="bi bi-trash3 me-1"></i>Remove Client
    </a>
  <?php else: ?>
    <span></span>
  <?php endif; ?>
  <div class="d-flex gap-2">
    <a href="clients.php" class="btn btn-outline-secondary">Cancel</a>
    <button type="submit" class="btn btn-gold px-4">
      <i class="bi bi-check-lg me-1"></i>Save Client
    </button>
  </div>
</div>

</form>

<?php include __DIR__ . '/_footer.php'; ?>
