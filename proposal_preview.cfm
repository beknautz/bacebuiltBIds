<cfscript>
    bidId = val(url.bid_id ?: 0);
    if (NOT bidId) { location(url="admin/bids.cfm", addtoken=false); }

    bidSvc  = new bbcomponents.BidService();
    data    = bidSvc.getById(bidId);

    if (structIsEmpty(data)) { location(url="admin/bids.cfm", addtoken=false); }

    bid             = data.bid;
    lineItems       = data.lineItems;
    scopeItems      = data.scopeItems;
    timelinePhases  = data.timelinePhases;
    paymentSchedule = data.paymentSchedule;
</cfscript>
<!--- Render the shared proposal template directly in the browser --->
<cfinclude template="proposal_template.cfm">
