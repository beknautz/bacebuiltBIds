<cfscript>
    bidId = val(url.bid_id ?: 0);
    if (NOT bidId) { location(url="admin/bids.cfm", addtoken=false); }

    bidSvc  = new components/BidService();
    data    = bidSvc.getById(bidId);

    if (structIsEmpty(data)) { location(url="admin/bids.cfm", addtoken=false); }

    bid             = data.bid;
    lineItems       = data.lineItems;
    scopeItems      = data.scopeItems;
    timelinePhases  = data.timelinePhases;
    paymentSchedule = data.paymentSchedule;

    // Sanitise filename for Content-Disposition
    safeNum = reReplace(bid.bid_number[1], '[^A-Za-z0-9\-]', '_', 'all');
</cfscript>
<!---
  Wrap the shared proposal template in cfdocument.
  Georgia + Arial render from system fonts — no external URLs needed.
  Table-based layout is fully supported by the CF PDF renderer.
--->
<cfdocument
    format="PDF"
    pageType="letter"
    orientation="portrait"
    marginTop="0.5"
    marginBottom="0.5"
    marginLeft="0.5"
    marginRight="0.5"
    fontembed="true"
    localUrl="true">

  <cfinclude template="proposal_template.cfm">

</cfdocument>
