<cfscript>
    bidSvc = new ../../components/BidService();
    bidId  = val(form.bid_id ?: 0);
    newSt  = trim(form.new_status ?: "");

    if (bidId GT 0 AND len(newSt)) {
        try {
            bidSvc.updateStatus(bidId, newSt);
        } catch (any e) {
            // Invalid status — ignore and fall through
        }
    }

    // Re-query to get fresh status
    statusMap = {
        "Draft":    {css:"badge-draft",    icon:"bi-pencil"},
        "Sent":     {css:"badge-sent",     icon:"bi-send"},
        "Accepted": {css:"badge-accepted", icon:"bi-check-circle"},
        "Declined": {css:"badge-declined", icon:"bi-x-circle"}
    };
</cfscript>
<cfquery name="bids" datasource="baceEstimates">
    SELECT bid_id, status FROM bb_bids WHERE bid_id = <cfqueryparam value="#bidId#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
<cfif bids.recordCount>
    <cfinclude template="_status_cell.cfm">
</cfif>
