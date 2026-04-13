<?php
require_once __DIR__ . '/../config/bootstrap.php';

$navActive = 'bids';
$bidSvc    = new BidService();
$clientSvc = new ClientService();

$bidId     = (int) ($_GET['bid_id'] ?? 0);
$saved     = (int) ($_GET['saved']  ?? 0);
$isNew     = ($bidId === 0);
$saveError = '';

// ── Handle POST ───────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $d = [
        'bid_id'          => (int)  ($_POST['bid_id']          ?? 0),
        'client_id'       => (int)  ($_POST['client_id']       ?? 0),
        'bid_title'       => trim(  $_POST['bid_title']        ?? ''),
        'project_address' => trim(  $_POST['project_address']  ?? ''),
        'project_city'    => trim(  $_POST['project_city']     ?? ''),
        'project_state'   => trim(  $_POST['project_state']    ?? ''),
        'project_zip'     => trim(  $_POST['project_zip']      ?? ''),
        'bid_date'        => trim(  $_POST['bid_date']         ?? date('Y-m-d')),
        'valid_until'     => trim(  $_POST['valid_until']      ?? ''),
        'status'          => trim(  $_POST['status']           ?? 'Draft'),
        'scope_notes'     => trim(  $_POST['scope_notes']      ?? ''),
        'terms'           => trim(  $_POST['terms']            ?? ''),
        'internal_notes'  => trim(  $_POST['internal_notes']   ?? ''),
        'tax_rate'        => (float)($_POST['tax_rate']        ?? 0),
        // Multi-value arrays — fields use name="field[]" in the form
        'item_id'          => $_POST['item_id']          ?? [],
        'item_category'    => $_POST['item_category']    ?? [],
        'item_description' => $_POST['item_description'] ?? [],
        'item_qty'         => $_POST['item_qty']         ?? [],
        'item_unit'        => $_POST['item_unit']        ?? [],
        'item_unit_price'  => $_POST['item_unit_price']  ?? [],
        'scope_id'         => $_POST['scope_id']         ?? [],
        'scope_desc'       => $_POST['scope_desc']       ?? [],
        'phase_id'         => $_POST['phase_id']         ?? [],
        'phase_name'       => $_POST['phase_name']       ?? [],
        'phase_desc'       => $_POST['phase_desc']       ?? [],
        'phase_days'       => $_POST['phase_days']       ?? [],
        'pay_id'           => $_POST['pay_id']           ?? [],
        'pay_milestone'    => $_POST['pay_milestone']    ?? [],
        'pay_amount'       => $_POST['pay_amount']       ?? [],
        'pay_pct'          => $_POST['pay_pct']          ?? [],
        'pay_desc'         => $_POST['pay_desc']         ?? [],
    ];

    try {
        $savedId = $bidSvc->saveBid($d);
        redirect("bid_edit.php?bid_id={$savedId}&saved=1");
    } catch (Throwable $e) {
        $saveError = $e->getMessage();
    }
}

// ── Load bid data ─────────────────────────────────────────────────
$data = ($bidId > 0) ? $bidSvc->getById($bidId) : [];
if ($bidId > 0 && empty($data)) {
    redirect('bids.php');
}

$bid             = $data['bid']             ?? [];
$lineItems       = $data['lineItems']       ?? [];
$scopeItems      = $data['scopeItems']      ?? [];
$timelinePhases  = $data['timelinePhases']  ?? [];
$paymentSchedule = $data['paymentSchedule'] ?? [];

$clients   = $clientSvc->getAll(true);
$pageTitle = $isNew ? 'New Bid' : 'Edit Bid';

$statusMap = [
    'Draft'    => ['css' => 'badge-draft',    'icon' => 'bi-pencil'],
    'Sent'     => ['css' => 'badge-sent',     'icon' => 'bi-send'],
    'Accepted' => ['css' => 'badge-accepted', 'icon' => 'bi-check-circle'],
    'Declined' => ['css' => 'badge-declined', 'icon' => 'bi-x-circle'],
];

include __DIR__ . '/_header.php';
?>

<!-- Page title bar -->
<div class="d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
  <div>
    <h1 class="page-title mb-0">
      <i class="bi bi-file-earmark-text me-2"></i>
      <?= $isNew ? 'New Bid' : h($bid['bid_number'] ?? 'Edit Bid') ?>
    </h1>
    <?php if (!$isNew): ?>
      <span class="form-hint"><?= h($bid['bid_title'] ?? '') ?></span>
    <?php endif; ?>
  </div>
  <div class="d-flex gap-2 flex-wrap">
    <a href="bids.php" class="btn btn-outline-secondary btn-sm">
      <i class="bi bi-arrow-left me-1"></i>All Bids
    </a>
    <?php if (!$isNew): ?>
      <a href="../proposal_preview.php?bid_id=<?= $bidId ?>" class="btn btn-outline-gold btn-sm" target="_blank">
        <i class="bi bi-eye me-1"></i>Preview
      </a>
      <a href="../proposal_pdf.php?bid_id=<?= $bidId ?>" class="btn btn-gold btn-sm" target="_blank">
        <i class="bi bi-file-pdf me-1"></i>Export PDF
      </a>
    <?php endif; ?>
  </div>
</div>

<?php if ($saveError): ?>
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    <i class="bi bi-exclamation-triangle me-2"></i><strong>Error:</strong> <?= h($saveError) ?>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<?php endif; ?>
<?php if ($saved): ?>
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle me-2"></i>Bid saved successfully.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<?php endif; ?>

<form method="post" action="bid_edit.php" id="bidForm">
<input type="hidden" name="bid_id" value="<?= $bidId ?>">

<!-- ═══════════════════════════════════════════════════════
     ROW 1: Bid Info + Status
═══════════════════════════════════════════════════════ -->
<div class="row g-3 mb-3">

  <!-- Bid Info -->
  <div class="col-lg-8">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-info-circle me-1"></i>Bid Information</div>
      <div class="card-body">
        <div class="row g-2">
          <div class="col-md-4">
            <label class="form-label">Bid #</label>
            <input type="text" class="form-control" value="<?= h($bid['bid_number'] ?? 'Auto-generated') ?>" disabled>
          </div>
          <div class="col-md-8">
            <label class="form-label">Bid Title <span class="text-gold">*</span></label>
            <input type="text" name="bid_title" class="form-control" required
                   value="<?= h($bid['bid_title'] ?? '') ?>"
                   placeholder="e.g. Kitchen Renovation — Smith Residence">
          </div>
          <div class="col-md-6">
            <label class="form-label">Client <span class="text-gold">*</span></label>
            <select name="client_id" class="form-select" required>
              <option value="">— Select Client —</option>
              <?php foreach ($clients as $c): ?>
                <option value="<?= $c['client_id'] ?>"<?= (($bid['client_id'] ?? 0) == $c['client_id']) ? ' selected' : '' ?>>
                  <?= h($c['company_name']) ?><?= $c['contact_name'] ? ' — ' . h($c['contact_name']) : '' ?>
                </option>
              <?php endforeach; ?>
            </select>
            <div class="form-hint mt-1">
              <a href="client_edit.php" class="text-gold" target="_blank">+ Add new client</a>
            </div>
          </div>
          <div class="col-md-3">
            <label class="form-label">Bid Date <span class="text-gold">*</span></label>
            <input type="date" name="bid_date" class="form-control" required
                   value="<?= h(fmt_date_input($bid['bid_date'] ?? null) ?: date('Y-m-d')) ?>">
          </div>
          <div class="col-md-3">
            <label class="form-label">Valid Until</label>
            <input type="date" name="valid_until" class="form-control"
                   value="<?= h(fmt_date_input($bid['valid_until'] ?? null)) ?>">
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Status -->
  <div class="col-lg-4">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-arrow-repeat me-1"></i>Status</div>
      <div class="card-body">
        <?php
          $curStatus = $bid['status'] ?? 'Draft';
          $sc        = $statusMap[$curStatus] ?? ['css' => 'badge-draft', 'icon' => 'bi-circle'];
        ?>
        <p class="form-label mb-1">Current Status</p>
        <p class="mb-3">
          <span class="badge-status <?= $sc['css'] ?> fs-6">
            <i class="bi <?= $sc['icon'] ?> me-1"></i><?= h($curStatus) ?>
          </span>
        </p>
        <label class="form-label">Change Status</label>
        <select name="status" class="form-select">
          <?php foreach (['Draft', 'Sent', 'Accepted', 'Declined'] as $s): ?>
            <option value="<?= h($s) ?>"<?= ($curStatus === $s) ? ' selected' : '' ?>><?= h($s) ?></option>
          <?php endforeach; ?>
        </select>
        <div class="form-hint mt-2">
          Workflow: Draft → Sent → Accepted / Declined
        </div>
      </div>
    </div>
  </div>

</div><!-- /row 1 -->

<!-- ═══════════════════════════════════════════════════════
     Project Address
═══════════════════════════════════════════════════════ -->
<div class="card-bb mb-3">
  <div class="card-header"><i class="bi bi-geo-alt me-1"></i>Project Address</div>
  <div class="card-body">
    <div class="row g-2">
      <div class="col-md-6">
        <label class="form-label">Street Address</label>
        <input type="text" name="project_address" class="form-control"
               value="<?= h($bid['project_address'] ?? '') ?>" placeholder="123 Main St">
      </div>
      <div class="col-md-3">
        <label class="form-label">City</label>
        <input type="text" name="project_city" class="form-control"
               value="<?= h($bid['project_city'] ?? '') ?>">
      </div>
      <div class="col-md-1">
        <label class="form-label">State</label>
        <input type="text" name="project_state" class="form-control"
               value="<?= h($bid['project_state'] ?? '') ?>" maxlength="2" placeholder="TX">
      </div>
      <div class="col-md-2">
        <label class="form-label">ZIP</label>
        <input type="text" name="project_zip" class="form-control"
               value="<?= h($bid['project_zip'] ?? '') ?>">
      </div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════
     Scope of Work
═══════════════════════════════════════════════════════ -->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-list-check me-1"></i>Scope of Work</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_scope_row.php"
            hx-target="#scope-body"
            hx-swap="beforeend">
      <i class="bi bi-plus-lg me-1"></i>Add Item
    </button>
  </div>
  <div class="card-body pb-1">
    <div class="form-hint mb-2">List all work included in this proposal. Each item appears as a checkmark on the proposal.</div>
    <table class="table table-bb mb-1">
      <thead>
        <tr>
          <th style="width:40px">#</th>
          <th>Scope Item Description</th>
          <th style="width:40px"></th>
        </tr>
      </thead>
      <tbody id="scope-body">
        <?php foreach ($scopeItems as $i => $si): ?>
          <tr class="scope-row">
            <td class="text-muted"><?= $i + 1 ?></td>
            <td>
              <input type="hidden" name="scope_id[]" value="<?= $si['scope_id'] ?>">
              <input type="text" name="scope_desc[]" class="form-control"
                     value="<?= h($si['description']) ?>"
                     placeholder="e.g. Demo existing kitchen cabinets and countertops">
            </td>
            <td>
              <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
                <i class="bi bi-x"></i>
              </button>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>

    <label class="form-label mt-2">Scope Notes (printed below checklist)</label>
    <textarea name="scope_notes" class="form-control" rows="3"
              placeholder="Additional scope clarifications, exclusions, allowances…"><?= h($bid['scope_notes'] ?? '') ?></textarea>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════
     Line Items + Live Totals
═══════════════════════════════════════════════════════ -->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-table me-1"></i>Cost Breakdown — Line Items</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_line_item_row.php"
            hx-target="#items-body"
            hx-swap="beforeend"
            hx-on::after-request="calcTotals()">
      <i class="bi bi-plus-lg me-1"></i>Add Item
    </button>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-bb mb-0">
        <thead>
          <tr>
            <th style="width:14%">Category</th>
            <th>Description</th>
            <th style="width:8%" class="text-end">Qty</th>
            <th style="width:7%">Unit</th>
            <th style="width:12%" class="text-end">Unit Price</th>
            <th style="width:12%" class="text-end">Line Total</th>
            <th style="width:38px"></th>
          </tr>
        </thead>
        <tbody id="items-body">
          <?php foreach ($lineItems as $li): ?>
            <tr class="item-row">
              <td>
                <input type="hidden" name="item_id[]" value="<?= $li['item_id'] ?>">
                <input type="text" name="item_category[]" class="form-control"
                       value="<?= h($li['category']) ?>" placeholder="Labor">
              </td>
              <td>
                <input type="text" name="item_description[]" class="form-control"
                       value="<?= h($li['description']) ?>"
                       placeholder="Description of work or material">
              </td>
              <td>
                <input type="number" name="item_qty[]" class="form-control text-end item-qty"
                       value="<?= h($li['quantity']) ?>" step="0.001" min="0" oninput="calcTotals()">
              </td>
              <td>
                <input type="text" name="item_unit[]" class="form-control"
                       value="<?= h($li['unit']) ?>">
              </td>
              <td>
                <input type="number" name="item_unit_price[]" class="form-control text-end item-price"
                       value="<?= h($li['unit_price']) ?>" step="0.01" min="0" oninput="calcTotals()">
              </td>
              <td class="text-end item-line-total align-middle">
                <?= dollar($li['line_total']) ?>
              </td>
              <td>
                <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this); calcTotals();">
                  <i class="bi bi-x"></i>
                </button>
              </td>
            </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>

    <!-- Totals panel -->
    <div class="d-flex justify-content-end p-3">
      <div class="totals-panel">
        <div class="t-row">
          <span class="t-label">Subtotal</span>
          <span class="t-val" id="disp-subtotal"><?= dollar($bid['subtotal'] ?? 0) ?></span>
        </div>
        <div class="t-row align-items-center">
          <span class="t-label d-flex align-items-center gap-1">
            Tax
            <input type="number" id="tax_rate" name="tax_rate" class="form-control tax-input"
                   value="<?= h($bid['tax_rate'] ?? 0) ?>"
                   step="0.01" min="0" max="100" oninput="calcTotals()">
            %
          </span>
          <span class="t-val" id="disp-tax"><?= dollar($bid['tax_amount'] ?? 0) ?></span>
        </div>
        <div class="t-row grand">
          <span>TOTAL</span>
          <span id="disp-total"><?= dollar($bid['total'] ?? 0) ?></span>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════
     Project Timeline
═══════════════════════════════════════════════════════ -->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-calendar3 me-1"></i>Project Timeline</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_phase_row.php"
            hx-target="#phases-body"
            hx-swap="beforeend">
      <i class="bi bi-plus-lg me-1"></i>Add Phase
    </button>
  </div>
  <div class="card-body p-0">
    <table class="table table-bb mb-0">
      <thead>
        <tr>
          <th style="width:22%">Phase Name</th>
          <th>Description</th>
          <th style="width:110px" class="text-end">Duration (days)</th>
          <th style="width:38px"></th>
        </tr>
      </thead>
      <tbody id="phases-body">
        <?php foreach ($timelinePhases as $ph): ?>
          <tr class="phase-row">
            <td>
              <input type="hidden" name="phase_id[]" value="<?= $ph['phase_id'] ?>">
              <input type="text" name="phase_name[]" class="form-control"
                     value="<?= h($ph['phase_name']) ?>" placeholder="e.g. Demolition">
            </td>
            <td>
              <input type="text" name="phase_desc[]" class="form-control"
                     value="<?= h($ph['description'] ?? '') ?>"
                     placeholder="What happens during this phase">
            </td>
            <td>
              <input type="number" name="phase_days[]" class="form-control text-end"
                     value="<?= h($ph['duration_days']) ?>" min="0">
            </td>
            <td>
              <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
                <i class="bi bi-x"></i>
              </button>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════
     Payment Schedule
═══════════════════════════════════════════════════════ -->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-cash-stack me-1"></i>Payment Schedule</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_payment_row.php"
            hx-target="#payments-body"
            hx-swap="beforeend">
      <i class="bi bi-plus-lg me-1"></i>Add Milestone
    </button>
  </div>
  <div class="card-body p-0">
    <table class="table table-bb mb-0">
      <thead>
        <tr>
          <th style="width:22%">Milestone</th>
          <th style="width:14%" class="text-end">Amount ($)</th>
          <th style="width:10%" class="text-end">% of Total</th>
          <th>Due / Terms</th>
          <th style="width:38px"></th>
        </tr>
      </thead>
      <tbody id="payments-body">
        <?php foreach ($paymentSchedule as $ps): ?>
          <tr class="payment-row">
            <td>
              <input type="hidden" name="pay_id[]" value="<?= $ps['payment_id'] ?>">
              <input type="text" name="pay_milestone[]" class="form-control"
                     value="<?= h($ps['milestone_name']) ?>" placeholder="e.g. Deposit">
            </td>
            <td>
              <input type="number" name="pay_amount[]" class="form-control text-end"
                     value="<?= h($ps['amount']) ?>" step="0.01" min="0">
            </td>
            <td>
              <input type="number" name="pay_pct[]" class="form-control text-end"
                     value="<?= h($ps['percent']) ?>" step="0.1" min="0" max="100">
            </td>
            <td>
              <input type="text" name="pay_desc[]" class="form-control"
                     value="<?= h($ps['due_description']) ?>" placeholder="Due upon signing">
            </td>
            <td>
              <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
                <i class="bi bi-x"></i>
              </button>
            </td>
          </tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════
     Terms & Notes
═══════════════════════════════════════════════════════ -->
<div class="row g-3 mb-3">
  <div class="col-lg-6">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-file-text me-1"></i>Terms &amp; Conditions</div>
      <div class="card-body">
        <textarea name="terms" class="form-control" rows="8"
                  placeholder="Standard payment terms, warranty clauses, exclusions, etc."><?= h($bid['terms'] ?? '') ?></textarea>
      </div>
    </div>
  </div>
  <div class="col-lg-6">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-sticky me-1"></i>Internal Notes</div>
      <div class="card-body">
        <textarea name="internal_notes" class="form-control" rows="8"
                  placeholder="Internal notes — not printed on the proposal."><?= h($bid['internal_notes'] ?? '') ?></textarea>
        <div class="form-hint mt-1"><i class="bi bi-lock me-1"></i>Not visible on client proposals.</div>
      </div>
    </div>
  </div>
</div>

<!-- ═══════════════════════════════════════════════════════
     Submit Bar
═══════════════════════════════════════════════════════ -->
<div class="d-flex justify-content-between align-items-center mb-5">
  <?php if (!$isNew): ?>
    <a href="bid_delete.php?bid_id=<?= $bidId ?>" class="btn btn-outline-danger btn-sm"
       onclick="return confirm('Permanently delete this bid?')">
      <i class="bi bi-trash3 me-1"></i>Delete Bid
    </a>
  <?php else: ?>
    <span></span>
  <?php endif; ?>
  <div class="d-flex gap-2">
    <a href="bids.php" class="btn btn-outline-secondary">Cancel</a>
    <button type="submit" class="btn btn-gold px-4">
      <i class="bi bi-check-lg me-1"></i>Save Bid
    </button>
  </div>
</div>

</form>

<script>
// ── Live totals ────────────────────────────────────────────
function fmtMoney(n) {
  return '$' + parseFloat(n || 0).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function calcTotals() {
  var subtotal = 0;
  document.querySelectorAll('#items-body .item-row').forEach(function(row) {
    var qty   = parseFloat(row.querySelector('.item-qty')   ? row.querySelector('.item-qty').value   : 0) || 0;
    var price = parseFloat(row.querySelector('.item-price') ? row.querySelector('.item-price').value : 0) || 0;
    var lt    = qty * price;
    var ltEl  = row.querySelector('.item-line-total');
    if (ltEl) ltEl.textContent = fmtMoney(lt);
    subtotal += lt;
  });

  var taxRate = parseFloat(document.getElementById('tax_rate').value) || 0;
  var taxAmt  = subtotal * (taxRate / 100);
  var total   = subtotal + taxAmt;

  document.getElementById('disp-subtotal').textContent = fmtMoney(subtotal);
  document.getElementById('disp-tax').textContent      = fmtMoney(taxAmt);
  document.getElementById('disp-total').textContent    = fmtMoney(total);
}

// ── Remove any dynamic row ─────────────────────────────────
function removeRow(btn) {
  btn.closest('tr').remove();
}

// Run once on load to sync display
calcTotals();
</script>

<?php include __DIR__ . '/_footer.php'; ?>
