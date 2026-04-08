<cfscript>
    bidId = val(url.bid_id ?: 0);
    if (NOT bidId) { location(url="bids.cfm", addtoken=false); }

    bidSvc = new bbcomponents.BidService();
    data   = bidSvc.getById(bidId);
    if (structIsEmpty(data)) { location(url="bids.cfm", addtoken=false); }

    bidSvc.deleteBid(bidId);
    location(url="bids.cfm?deleted=1", addtoken=false);
</cfscript>
