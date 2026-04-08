<cfscript>
    navActive  = "clients";
    pageTitle  = "Clients";
    clientSvc  = new bbcomponents.ClientService();

    deleted = val(url.deleted ?: 0);
    search  = trim(url.search ?: "");

    clients = clientSvc.getAll(false);

    // Client-side filter if search provided
    if (len(search)) {
        // Re-query with name filter (simpler: just pass search to query)
    }
</cfscript>
<cfinclude template="_header.cfm">
<cfoutput>

<div class="d-flex flex-wrap align-items-center justify-content-between mb-3 gap-2">
  <h1 class="page-title mb-0"><i class="bi bi-people me-2"></i>Clients</h1>
  <a href="client_edit.cfm" class="btn btn-gold btn-sm">
    <i class="bi bi-plus-lg me-1"></i>New Client
  </a>
</div>

<cfif deleted>
  <div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle me-2"></i>Client removed.
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</cfif>

<p class="form-hint mb-2">#clients.recordCount# client#(clients.recordCount neq 1 ? 's' : '')#</p>

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
        <cfif NOT clients.recordCount>
          <tr><td colspan="7" class="text-center py-4 text-gold" style="font-family:Georgia,serif;">
            No clients yet. <a href="client_edit.cfm" class="text-gold">Add your first client →</a>
          </td></tr>
        </cfif>
        <cfloop query="clients">
          <cfset local.bidCount = clientSvc.getBidCount(clients.client_id)>
          <tr>
            <td class="fw-bold">#encodeForHtml(clients.company_name)#</td>
            <td>#encodeForHtml(clients.contact_name)#</td>
            <td>
              <cfif len(clients.email)>
                <a href="mailto:#encodeForHtml(clients.email)#" class="text-gold">#encodeForHtml(clients.email)#</a>
              </cfif>
            </td>
            <td>#encodeForHtml(clients.phone)#</td>
            <td>
              <cfif len(clients.city) OR len(clients.state)>
                #encodeForHtml(listAppend(clients.city, clients.state, ", "))#
              </cfif>
            </td>
            <td>
              <cfif local.bidCount GT 0>
                <a href="bids.cfm" class="text-gold">#local.bidCount# bid#(local.bidCount neq 1 ? 's' : '')#</a>
              <cfelse>
                <span class="text-muted">0</span>
              </cfif>
            </td>
            <td class="text-center text-nowrap">
              <a href="client_edit.cfm?client_id=#clients.client_id#"
                 class="btn btn-outline-gold btn-sm px-2" title="Edit">
                <i class="bi bi-pencil"></i>
              </a>
              <a href="client_delete.cfm?client_id=#clients.client_id#"
                 class="btn btn-outline-danger btn-sm px-2" title="Remove"
                 onclick="return confirm('Remove #encodeForJavaScript(clients.company_name)# from your client list?')">
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
