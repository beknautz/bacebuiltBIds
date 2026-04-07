<!---
  Partial — renders the status badge + quick-transition buttons for ONE bid row.
  Expects query variables: bids.bid_id, bids.status
  Called inline from bids.cfm and returned by htmx/update_bid_status.cfm
--->
<cfoutput>
<span class="badge-status #statusMap[bids.status].css#">
  <i class="bi #statusMap[bids.status].icon# me-1"></i>#bids.status#
</span>
<br>
<cfswitch expression="#bids.status#">
  <cfcase value="Draft">
    <button class="btn btn-outline-secondary btn-sm mt-1 workflow-btn"
            hx-post="htmx/update_bid_status.cfm"
            hx-vals='{"bid_id":"#bids.bid_id#","new_status":"Sent"}'
            hx-target="##status-cell-#bids.bid_id#"
            hx-swap="innerHTML">
      <i class="bi bi-send me-1"></i>Mark Sent
    </button>
  </cfcase>
  <cfcase value="Sent">
    <button class="btn btn-outline-success btn-sm mt-1 me-1 workflow-btn"
            hx-post="htmx/update_bid_status.cfm"
            hx-vals='{"bid_id":"#bids.bid_id#","new_status":"Accepted"}'
            hx-target="##status-cell-#bids.bid_id#"
            hx-swap="innerHTML">
      <i class="bi bi-check-circle me-1"></i>Accept
    </button>
    <button class="btn btn-outline-danger btn-sm mt-1 workflow-btn"
            hx-post="htmx/update_bid_status.cfm"
            hx-vals='{"bid_id":"#bids.bid_id#","new_status":"Declined"}'
            hx-target="##status-cell-#bids.bid_id#"
            hx-swap="innerHTML">
      <i class="bi bi-x-circle me-1"></i>Decline
    </button>
  </cfcase>
  <cfcase value="Accepted,Declined">
    <button class="btn btn-outline-secondary btn-sm mt-1 workflow-btn"
            hx-post="htmx/update_bid_status.cfm"
            hx-vals='{"bid_id":"#bids.bid_id#","new_status":"Draft"}'
            hx-target="##status-cell-#bids.bid_id#"
            hx-swap="innerHTML">
      <i class="bi bi-arrow-counterclockwise me-1"></i>Reset Draft
    </button>
  </cfcase>
</cfswitch>
</cfoutput>
