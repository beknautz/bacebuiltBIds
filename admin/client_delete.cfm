<cfscript>
    clientId = val(url.client_id ?: 0);
    if (NOT clientId) { location(url="clients.cfm", addtoken=false); }

    clientSvc = new bbcomponents.ClientService();
    clientSvc.softDelete(clientId);
    location(url="clients.cfm?deleted=1", addtoken=false);
</cfscript>
