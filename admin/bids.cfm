<cfscript>
    navActive  = "bids";
    pageTitle  = "Bids";
    bidSvc     = new ../components/BidService();

    // Filters from URL
    filterStatus = trim(url.status ?: "");
    filterSearch = trim(url.search ?: "");

    bids = bidSvc.getAll(filterStatus, filterSearch);

    // Status colour map
    statusMap = {
        "Draft":    {css:"badge-draft",    icon:"bi-pencil"},
        "Sent":     {css:"badge-sent",     icon:"bi-send"},
        "Accepted": {css:"badge-accepted", icon:"bi-check-circle"},
        "Declined": {css:"badge-declined", icon:"bi-x-circle"}
    };
</cfscript>
<cfinclude template="_header.cfm">
<cfoutput>

<!--- Page header --->
<div class="d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
  <h1 class="page-title mb-0"><i class="bi bi-file-earmark-text me-2"></i>Bids</h1>
  <a href="bid_edit.cfm" class="btn btn-gold btn-sm">
    <i class="bi bi-plus-lg me-1"></i>New Bid
  </a>
</div>

<!--- Filters --->
<form method="get" action="bids.cfm" class="row g-2 mb-3">
  <div class="col-auto">
    <select name="status" class="form-select form-select-sm" style="min-width:120px" onchange="this.form.submit()">
      <option value="">All Statuses</option>
      <cfloop list="Draft,Sent,Accepted,Declined" index="local.s">
        <option value="#local.s#"<cfif filterStatus eq local.s> selected</cfif>>#local.s#</option>
      </cfloop>
    </select>
  </div>
  <div class="col-auto d-flex gap-1">
    <input type="text" name="search" class="form-control form-control-sm" placeholder="Search bids…" value="#encodeForHtml(filterSearch)#" style="min-width:200px">
    <button type="submit" class="btn btn-outline-gold btn-sm"><i class="bi bi-search"></i></button>
    <cfif len(filterStatus) OR len(filterSearch)>
      <a href="bids.cfm" class="btn btn-outline-secondary btn-sm">Clear</a>
    </cfif>
  </div>
</form>

<!--- Results count --->
<p class="form-hint mb-2">#bids.recordCount# bid#(bids.recordCount neq 1 ? 's' : '')# found</p>

<!--- Bid table --->
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
        <cfif NOT bids.recordCount>
          <tr><td colspan="8" class="text-center py-4 text-gold" style="font-family:Georgia,serif;">
            No bids found. <a href="bid_edit.cfm" class="text-gold">Create your first bid →</a>
          </td></tr>
        </cfif>
        <cfloop query="bids">
          <cfset local.sm = statusMap[bids.status] ?: {css:'badge-draft',icon:'bi-circle'}>
          <tr>
            <td class="text-gold fw-bold" style="font-family:Georgia,serif;white-space:nowrap">
              <a href="bid_edit.cfm?bid_id=#bids.bid_id#" class="text-gold text-decoration-none">#encodeForHtml(bids.bid_number)#</a>
            </td>
            <td>
              <div class="fw-bold">#encodeForHtml(bids.company_name)#</div>
              <div class="form-hint">#encodeForHtml(bids.contact_name)#</div>
            </td>
            <td>#encodeForHtml(bids.bid_title)#</td>
            <td class="text-nowrap">#dateFormat(bids.bid_date, 'mmm d, yyyy')#</td>
            <td class="text-nowrap">
              <cfif NOT isNull(bids.valid_until) AND len(bids.valid_until)>
                #dateFormat(bids.valid_until, 'mmm d, yyyy')#
              <cfelse>
                <span class="text-muted">—</span>
              </cfif>
            </td>
            <td id="status-cell-#bids.bid_id#">
              <cfinclude template="htmx/_status_cell.cfm">
            </td>
            <td class="text-end text-nowrap fw-bold">#dollarFormat(bids.total)#</td>
            <td class="text-center text-nowrap">
              <a href="bid_edit.cfm?bid_id=#bids.bid_id#"
                 class="btn btn-outline-gold btn-sm px-2" title="Edit">
                <i class="bi bi-pencil"></i>
              </a>
              <a href="../proposal_preview.cfm?bid_id=#bids.bid_id#"
                 class="btn btn-outline-secondary btn-sm px-2" title="Preview Proposal" target="_blank">
                <i class="bi bi-eye"></i>
              </a>
              <a href="../proposal_pdf.cfm?bid_id=#bids.bid_id#"
                 class="btn btn-outline-secondary btn-sm px-2" title="Export PDF" target="_blank">
                <i class="bi bi-file-pdf"></i>
              </a>
              <a href="bid_delete.cfm?bid_id=#bids.bid_id#"
                 class="btn btn-outline-danger btn-sm px-2" title="Delete"
                 onclick="return confirm('Delete bid #encodeForJavaScript(bids.bid_number)#? This cannot be undone.')">
                <i class="bi bi-trash3"></i>
              </a>
            </td>
          </tr>
        </cfloop>
      </tbody>
    </table>
  </div>
</div>

</cfoutput>
<cfinclude template="_footer.cfm">
