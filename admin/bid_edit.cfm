<cfscript>
    navActive  = "bids";
    bidSvc     = new bbcomponents.BidService();
    clientSvc  = new bbcomponents.ClientService();

    bidId = val(url.bid_id ?: 0);
    saved = val(url.saved  ?: 0);
    isNew = (bidId EQ 0);
    saveError = "";

    // ── Page-level helpers (var is only valid INSIDE functions) ──
    // Multi-value form field → CF array via Java servlet request
    function getParams(name) {
        var v = getPageContext().getRequest().getParameterValues(name);
        return (isNull(v) ? [] : listToArray(arrayToList(v)));
    }

    // Safe query-field read with a default
    function fld(q, col, def="") {
        try {
            var v = q[col][1];
            return (isNull(v) ? def : v);
        } catch(any e) { return def; }
    }

    // ── Handle POST ───────────────────────────────────────
    if (cgi.REQUEST_METHOD EQ "POST") {

        data = {
            bid_id:           val(form.bid_id           ?: 0),
            client_id:        val(form.client_id         ?: 0),
            bid_title:        trim(form.bid_title        ?: ""),
            project_address:  trim(form.project_address  ?: ""),
            project_city:     trim(form.project_city     ?: ""),
            project_state:    trim(form.project_state    ?: ""),
            project_zip:      trim(form.project_zip      ?: ""),
            bid_date:         trim(form.bid_date         ?: dateFormat(now(),"yyyy-mm-dd")),
            valid_until:      trim(form.valid_until      ?: ""),
            status:           trim(form.status           ?: "Draft"),
            scope_notes:      trim(form.scope_notes      ?: ""),
            terms:            trim(form.terms            ?: ""),
            internal_notes:   trim(form.internal_notes   ?: ""),
            tax_rate:         val(form.tax_rate           ?: 0),
            item_id:          getParams("item_id"),
            item_category:    getParams("item_category"),
            item_description: getParams("item_description"),
            item_qty:         getParams("item_qty"),
            item_unit:        getParams("item_unit"),
            item_unit_price:  getParams("item_unit_price"),
            scope_id:         getParams("scope_id"),
            scope_desc:       getParams("scope_desc"),
            phase_id:         getParams("phase_id"),
            phase_name:       getParams("phase_name"),
            phase_desc:       getParams("phase_desc"),
            phase_days:       getParams("phase_days"),
            pay_id:           getParams("pay_id"),
            pay_milestone:    getParams("pay_milestone"),
            pay_amount:       getParams("pay_amount"),
            pay_pct:          getParams("pay_pct"),
            pay_desc:         getParams("pay_desc")
        };

        try {
            savedId = bidSvc.saveBid(data);
            location(url="bid_edit.cfm?bid_id=#savedId#&saved=1", addtoken=false);
        } catch (any e) {
            saveError = e.message;
        }
    }

    // ── Load bid data ──────────────────────────────────────
    bidData = (bidId GT 0) ? bidSvc.getById(bidId) : {};
    if (NOT structIsEmpty(bidData) AND NOT bidData.bid.recordCount) {
        location(url="bids.cfm", addtoken=false);
    }

    bid             = bidData.bid             ?: queryNew("");
    lineItems       = bidData.lineItems       ?: queryNew("");
    scopeItems      = bidData.scopeItems      ?: queryNew("");
    timelinePhases  = bidData.timelinePhases  ?: queryNew("");
    paymentSchedule = bidData.paymentSchedule ?: queryNew("");

    clients   = clientSvc.getAll(true);
    pageTitle = isNew ? "New Bid" : "Edit Bid";
</cfscript>
<cfinclude template="_header.cfm">
<cfoutput>

<!--- Page title bar --->
<div class="d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
  <div>
    <h1 class="page-title mb-0">
      <i class="bi bi-file-earmark-text me-2"></i>
      <cfif isNew>New Bid<cfelse>#encodeForHtml(fld(bid,'bid_number','Edit Bid'))#</cfif>
    </h1>
    <cfif NOT isNew>
      <span class="form-hint">#encodeForHtml(fld(bid,'bid_title'))#</span>
    </cfif>
  </div>
  <div class="d-flex gap-2 flex-wrap">
    <a href="bids.cfm" class="btn btn-outline-secondary btn-sm">
      <i class="bi bi-arrow-left me-1"></i>All Bids
    </a>
    <cfif NOT isNew>
      <a href="../proposal_preview.cfm?bid_id=#bidId#" class="btn btn-outline-gold btn-sm" target="_blank">
        <i class="bi bi-eye me-1"></i>Preview
      </a>
      <a href="../proposal_pdf.cfm?bid_id=#bidId#" class="btn btn-gold btn-sm" target="_blank">
        <i class="bi bi-file-pdf me-1"></i>Export PDF
      </a>
    </cfif>
  </div>
</div>

<cfif len(saveError)>
  <div class="alert alert-danger alert-dismissible fade show" role="alert">
    <i class="bi bi-exclamation-triangle me-2"></i><strong>Error:</strong> #encodeForHtml(saveError)#
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</cfif>
<cfif saved>
  <div class="alert alert-success alert-dismissible fade show" role="alert">
    <i class="bi bi-check-circle me-2"></i>Bid saved successfully.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</cfif>

<form method="post" action="bid_edit.cfm" id="bidForm">
<input type="hidden" name="bid_id" value="#bidId#">

<!--- ═══════════════════════════════════════════════════════
      ROW 1: Bid Info + Status
═══════════════════════════════════════════════════════ --->
<div class="row g-3 mb-3">

  <!--- Bid Info --->
  <div class="col-lg-8">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-info-circle me-1"></i>Bid Information</div>
      <div class="card-body">
        <div class="row g-2">
          <div class="col-md-4">
            <label class="form-label">Bid ##</label>
            <input type="text" class="form-control" value="#encodeForHtml(fld(bid,'bid_number','Auto-generated'))#" disabled>
          </div>
          <div class="col-md-8">
            <label class="form-label">Bid Title <span class="text-gold">*</span></label>
            <input type="text" name="bid_title" class="form-control" required
                   value="#encodeForHtml(fld(bid,'bid_title'))#"
                   placeholder="e.g. Kitchen Renovation — Smith Residence">
          </div>
          <div class="col-md-6">
            <label class="form-label">Client <span class="text-gold">*</span></label>
            <select name="client_id" class="form-select" required>
              <option value="">— Select Client —</option>
              <cfloop query="clients">
                <option value="#clients.client_id#"
                  <cfif fld(bid,'client_id',0) EQ clients.client_id>selected</cfif>>
                  #encodeForHtml(clients.company_name)#
                  <cfif len(clients.contact_name)> — #encodeForHtml(clients.contact_name)#</cfif>
                </option>
              </cfloop>
            </select>
            <div class="form-hint mt-1">
              <a href="client_edit.cfm" class="text-gold" target="_blank">+ Add new client</a>
            </div>
          </div>
          <div class="col-md-3">
            <label class="form-label">Bid Date <span class="text-gold">*</span></label>
            <input type="date" name="bid_date" class="form-control" required
                   value="#encodeForHtml(len(fld(bid,'bid_date')) ? dateFormat(fld(bid,'bid_date'),'yyyy-mm-dd') : dateFormat(now(),'yyyy-mm-dd'))#">
          </div>
          <div class="col-md-3">
            <label class="form-label">Valid Until</label>
            <input type="date" name="valid_until" class="form-control"
                   value="#encodeForHtml(len(fld(bid,'valid_until')) ? dateFormat(fld(bid,'valid_until'),'yyyy-mm-dd') : '')#">
          </div>
        </div>
      </div>
    </div>
  </div>

  <!--- Status --->
  <div class="col-lg-4">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-arrow-repeat me-1"></i>Status</div>
      <div class="card-body">
        <cfset curStatus = fld(bid,'status','Draft')>
        <p class="form-label mb-1">Current Status</p>
        <p class="mb-3">
          <cfset statusCfg = {
            "Draft":    {css:"badge-draft",    icon:"bi-pencil"},
            "Sent":     {css:"badge-sent",     icon:"bi-send"},
            "Accepted": {css:"badge-accepted", icon:"bi-check-circle"},
            "Declined": {css:"badge-declined", icon:"bi-x-circle"}
          }>
          <cfset sc = statusCfg[curStatus] ?: {css:"badge-draft",icon:"bi-circle"}>
          <span class="badge-status #sc.css# fs-6">
            <i class="bi #sc.icon# me-1"></i>#curStatus#
          </span>
        </p>
        <label class="form-label">Change Status</label>
        <select name="status" class="form-select">
          <cfloop list="Draft,Sent,Accepted,Declined" index="local.s">
            <option value="#local.s#"<cfif curStatus EQ local.s> selected</cfif>>#local.s#</option>
          </cfloop>
        </select>
        <div class="form-hint mt-2">
          Workflow: Draft → Sent → Accepted / Declined
        </div>
      </div>
    </div>
  </div>

</div><!--- /row 1 --->

<!--- ═══════════════════════════════════════════════════════
      Project Address
═══════════════════════════════════════════════════════ --->
<div class="card-bb mb-3">
  <div class="card-header"><i class="bi bi-geo-alt me-1"></i>Project Address</div>
  <div class="card-body">
    <div class="row g-2">
      <div class="col-md-6">
        <label class="form-label">Street Address</label>
        <input type="text" name="project_address" class="form-control"
               value="#encodeForHtml(fld(bid,'project_address'))#"
               placeholder="123 Main St">
      </div>
      <div class="col-md-3">
        <label class="form-label">City</label>
        <input type="text" name="project_city" class="form-control"
               value="#encodeForHtml(fld(bid,'project_city'))#">
      </div>
      <div class="col-md-1">
        <label class="form-label">State</label>
        <input type="text" name="project_state" class="form-control"
               value="#encodeForHtml(fld(bid,'project_state'))#" maxlength="2" placeholder="TX">
      </div>
      <div class="col-md-2">
        <label class="form-label">ZIP</label>
        <input type="text" name="project_zip" class="form-control"
               value="#encodeForHtml(fld(bid,'project_zip'))#">
      </div>
    </div>
  </div>
</div>

<!--- ═══════════════════════════════════════════════════════
      Scope of Work
═══════════════════════════════════════════════════════ --->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-list-check me-1"></i>Scope of Work</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_scope_row.cfm"
            hx-target="##scope-body"
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
        <cfloop query="scopeItems">
          <tr class="scope-row">
            <td class="text-muted">#scopeItems.currentRow#</td>
            <td>
              <input type="hidden" name="scope_id" value="#scopeItems.scope_id#">
              <input type="text" name="scope_desc" class="form-control"
                     value="#encodeForHtml(scopeItems.description)#"
                     placeholder="e.g. Demo existing kitchen cabinets and countertops">
            </td>
            <td>
              <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
                <i class="bi bi-x"></i>
              </button>
            </td>
          </tr>
        </cfloop>
      </tbody>
    </table>

    <label class="form-label mt-2">Scope Notes (printed below checklist)</label>
    <textarea name="scope_notes" class="form-control" rows="3"
              placeholder="Additional scope clarifications, exclusions, allowances…">#encodeForHtml(fld(bid,'scope_notes'))#</textarea>
  </div>
</div>

<!--- ═══════════════════════════════════════════════════════
      Line Items + Live Totals
═══════════════════════════════════════════════════════ --->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-table me-1"></i>Cost Breakdown — Line Items</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_line_item_row.cfm"
            hx-target="##items-body"
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
          <cfloop query="lineItems">
            <tr class="item-row">
              <td>
                <input type="hidden" name="item_id" value="#lineItems.item_id#">
                <input type="text" name="item_category" class="form-control"
                       value="#encodeForHtml(lineItems.category)#" placeholder="Labor">
              </td>
              <td>
                <input type="text" name="item_description" class="form-control"
                       value="#encodeForHtml(lineItems.description)#"
                       placeholder="Description of work or material">
              </td>
              <td>
                <input type="number" name="item_qty" class="form-control text-end item-qty"
                       value="#lineItems.quantity#" step="0.001" min="0" oninput="calcTotals()">
              </td>
              <td>
                <input type="text" name="item_unit" class="form-control"
                       value="#encodeForHtml(lineItems.unit)#">
              </td>
              <td>
                <input type="number" name="item_unit_price" class="form-control text-end item-price"
                       value="#lineItems.unit_price#" step="0.01" min="0" oninput="calcTotals()">
              </td>
              <td class="text-end item-line-total align-middle">
                #dollarFormat(lineItems.line_total)#
              </td>
              <td>
                <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this); calcTotals();">
                  <i class="bi bi-x"></i>
                </button>
              </td>
            </tr>
          </cfloop>
        </tbody>
      </table>
    </div>

    <!--- Totals panel --->
    <div class="d-flex justify-content-end p-3">
      <div class="totals-panel">
        <div class="t-row">
          <span class="t-label">Subtotal</span>
          <span class="t-val" id="disp-subtotal">#dollarFormat(fld(bid,'subtotal',0))#</span>
        </div>
        <div class="t-row align-items-center">
          <span class="t-label d-flex align-items-center gap-1">
            Tax
            <input type="number" id="tax_rate" name="tax_rate" class="form-control tax-input"
                   value="#numberFormat(fld(bid,'tax_rate',0),'0.##')#"
                   step="0.01" min="0" max="100" oninput="calcTotals()">
            %
          </span>
          <span class="t-val" id="disp-tax">#dollarFormat(fld(bid,'tax_amount',0))#</span>
        </div>
        <div class="t-row grand">
          <span>TOTAL</span>
          <span id="disp-total">#dollarFormat(fld(bid,'total',0))#</span>
        </div>
      </div>
    </div>
  </div>
</div>

<!--- ═══════════════════════════════════════════════════════
      Project Timeline
═══════════════════════════════════════════════════════ --->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-calendar3 me-1"></i>Project Timeline</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_phase_row.cfm"
            hx-target="##phases-body"
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
        <cfloop query="timelinePhases">
          <tr class="phase-row">
            <td>
              <input type="hidden" name="phase_id" value="#timelinePhases.phase_id#">
              <input type="text" name="phase_name" class="form-control"
                     value="#encodeForHtml(timelinePhases.phase_name)#"
                     placeholder="e.g. Demolition">
            </td>
            <td>
              <input type="text" name="phase_desc" class="form-control"
                     value="#encodeForHtml(timelinePhases.description ?: '')#"
                     placeholder="What happens during this phase">
            </td>
            <td>
              <input type="number" name="phase_days" class="form-control text-end"
                     value="#timelinePhases.duration_days#" min="0">
            </td>
            <td>
              <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
                <i class="bi bi-x"></i>
              </button>
            </td>
          </tr>
        </cfloop>
      </tbody>
    </table>
  </div>
</div>

<!--- ═══════════════════════════════════════════════════════
      Payment Schedule
═══════════════════════════════════════════════════════ --->
<div class="card-bb mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <span><i class="bi bi-cash-stack me-1"></i>Payment Schedule</span>
    <button type="button" class="btn btn-outline-gold btn-sm"
            hx-get="htmx/new_payment_row.cfm"
            hx-target="##payments-body"
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
        <cfloop query="paymentSchedule">
          <tr class="payment-row">
            <td>
              <input type="hidden" name="pay_id" value="#paymentSchedule.payment_id#">
              <input type="text" name="pay_milestone" class="form-control"
                     value="#encodeForHtml(paymentSchedule.milestone_name)#"
                     placeholder="e.g. Deposit">
            </td>
            <td>
              <input type="number" name="pay_amount" class="form-control text-end"
                     value="#paymentSchedule.amount#" step="0.01" min="0">
            </td>
            <td>
              <input type="number" name="pay_pct" class="form-control text-end"
                     value="#paymentSchedule.percent#" step="0.1" min="0" max="100">
            </td>
            <td>
              <input type="text" name="pay_desc" class="form-control"
                     value="#encodeForHtml(paymentSchedule.due_description)#"
                     placeholder="Due upon signing">
            </td>
            <td>
              <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
                <i class="bi bi-x"></i>
              </button>
            </td>
          </tr>
        </cfloop>
      </tbody>
    </table>
  </div>
</div>

<!--- ═══════════════════════════════════════════════════════
      Terms & Notes
═══════════════════════════════════════════════════════ --->
<div class="row g-3 mb-3">
  <div class="col-lg-6">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-file-text me-1"></i>Terms &amp; Conditions</div>
      <div class="card-body">
        <textarea name="terms" class="form-control" rows="8"
                  placeholder="Standard payment terms, warranty clauses, exclusions, etc.">#encodeForHtml(fld(bid,'terms'))#</textarea>
      </div>
    </div>
  </div>
  <div class="col-lg-6">
    <div class="card-bb h-100">
      <div class="card-header"><i class="bi bi-sticky me-1"></i>Internal Notes</div>
      <div class="card-body">
        <textarea name="internal_notes" class="form-control" rows="8"
                  placeholder="Internal notes — not printed on the proposal.">#encodeForHtml(fld(bid,'internal_notes'))#</textarea>
        <div class="form-hint mt-1"><i class="bi bi-lock me-1"></i>Not visible on client proposals.</div>
      </div>
    </div>
  </div>
</div>

<!--- ═══════════════════════════════════════════════════════
      Submit Bar
═══════════════════════════════════════════════════════ --->
<div class="d-flex justify-content-between align-items-center mb-5">
  <cfif NOT isNew>
    <a href="bid_delete.cfm?bid_id=#bidId#" class="btn btn-outline-danger btn-sm"
       onclick="return confirm('Permanently delete this bid?')">
      <i class="bi bi-trash3 me-1"></i>Delete Bid
    </a>
  <cfelse>
    <span></span>
  </cfif>
  <div class="d-flex gap-2">
    <a href="bids.cfm" class="btn btn-outline-secondary">Cancel</a>
    <button type="submit" class="btn btn-gold px-4">
      <i class="bi bi-check-lg me-1"></i>Save Bid
    </button>
  </div>
</div>

</form>
</cfoutput>

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

<cfinclude template="_footer.cfm">
