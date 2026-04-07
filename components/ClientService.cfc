<cfcomponent>

    <cffunction name="getAll" returntype="query" access="public">
        <cfargument name="activeOnly" type="boolean" default="false">
        <cfquery name="local.q" datasource="baceEstimates">
            SELECT client_id, company_name, contact_name, email, phone,
                   address, city, state, zip, notes, created_at
              FROM bb_clients
            <cfif arguments.activeOnly>WHERE is_active = 1</cfif>
             ORDER BY company_name
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <cffunction name="getById" returntype="query" access="public">
        <cfargument name="clientId" type="numeric" required="true">
        <cfquery name="local.q" datasource="baceEstimates">
            SELECT * FROM bb_clients WHERE client_id = <cfqueryparam value="#arguments.clientId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <cffunction name="save" returntype="numeric" access="public">
        <cfargument name="data" type="struct" required="true">
        <cfscript>
            var d = arguments.data;
            var clientId = val(d.client_id ?: 0);
        </cfscript>

        <cfif clientId GT 0>
            <cfquery datasource="baceEstimates">
                UPDATE bb_clients SET
                    company_name = <cfqueryparam value="#d.company_name#" cfsqltype="CF_SQL_VARCHAR">,
                    contact_name = <cfqueryparam value="#d.contact_name ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    email        = <cfqueryparam value="#d.email ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    phone        = <cfqueryparam value="#d.phone ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    address      = <cfqueryparam value="#d.address ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    city         = <cfqueryparam value="#d.city ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    state        = <cfqueryparam value="#d.state ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    zip          = <cfqueryparam value="#d.zip ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    notes        = <cfqueryparam value="#d.notes ?: ''#" cfsqltype="CF_SQL_LONGVARCHAR">
                WHERE client_id = <cfqueryparam value="#clientId#" cfsqltype="CF_SQL_INTEGER">
            </cfquery>
            <cfreturn clientId>
        <cfelse>
            <cfquery datasource="baceEstimates" result="local.ins">
                INSERT INTO bb_clients (company_name, contact_name, email, phone, address, city, state, zip, notes)
                VALUES (
                    <cfqueryparam value="#d.company_name#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.contact_name ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.email ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.phone ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.address ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.city ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.state ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.zip ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.notes ?: ''#" cfsqltype="CF_SQL_LONGVARCHAR">
                )
            </cfquery>
            <cfreturn local.ins.generatedKey>
        </cfif>
    </cffunction>

    <cffunction name="softDelete" returntype="void" access="public">
        <cfargument name="clientId" type="numeric" required="true">
        <cfquery datasource="baceEstimates">
            UPDATE bb_clients SET is_active = 0
             WHERE client_id = <cfqueryparam value="#arguments.clientId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>

    <cffunction name="getBidCount" returntype="numeric" access="public">
        <cfargument name="clientId" type="numeric" required="true">
        <cfquery name="local.q" datasource="baceEstimates">
            SELECT COUNT(*) AS cnt FROM bb_bids
             WHERE client_id = <cfqueryparam value="#arguments.clientId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfreturn local.q.cnt>
    </cffunction>

</cfcomponent>
