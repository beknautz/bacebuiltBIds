<cfcomponent>

    <!--- ═══════════════════════════════════════════════════════
          Bid Number Generator  BB-YYYY-NNNN
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="generateBidNumber" returntype="string" access="public">
        <cfset var yr = year(now())>
        <cfquery name="local.q" datasource="baceEstimates">
            SELECT COUNT(*) AS cnt FROM bb_bids WHERE YEAR(created_at) = <cfqueryparam value="#yr#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
        <cfreturn "BB-#yr#-#numberFormat(local.q.cnt + 1, '0000')#">
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          List bids (with client join)
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="getAll" returntype="query" access="public">
        <cfargument name="status" type="string" default="">
        <cfargument name="search" type="string" default="">
        <cfquery name="local.q" datasource="baceEstimates">
            SELECT b.bid_id, b.bid_number, b.bid_title, b.bid_date, b.valid_until,
                   b.status, b.total, b.created_at, b.updated_at,
                   c.company_name, c.contact_name, c.email, c.phone
              FROM bb_bids b
              JOIN bb_clients c ON b.client_id = c.client_id
             WHERE 1 = 1
            <cfif len(trim(arguments.status))>
               AND b.status = <cfqueryparam value="#arguments.status#" cfsqltype="CF_SQL_VARCHAR">
            </cfif>
            <cfif len(trim(arguments.search))>
               AND (c.company_name LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
                OR b.bid_title    LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">
                OR b.bid_number   LIKE <cfqueryparam value="%#arguments.search#%" cfsqltype="CF_SQL_VARCHAR">)
            </cfif>
             ORDER BY b.created_at DESC
        </cfquery>
        <cfreturn local.q>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Get single bid + all sub-records
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="getById" returntype="struct" access="public">
        <cfargument name="bidId" type="numeric" required="true">
        <cfscript>var result = {};</cfscript>

        <cfquery name="local.bidQ" datasource="baceEstimates">
            SELECT b.*,
                   c.company_name, c.contact_name, c.email AS client_email,
                   c.phone AS client_phone,
                   c.address AS client_address, c.city AS client_city,
                   c.state AS client_state, c.zip AS client_zip
              FROM bb_bids b
              JOIN bb_clients c ON b.client_id = c.client_id
             WHERE b.bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>

        <cfif NOT local.bidQ.recordCount>
            <cfreturn {}>
        </cfif>

        <cfquery name="local.itemsQ" datasource="baceEstimates">
            SELECT * FROM bb_line_items WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> ORDER BY sort_order, item_id
        </cfquery>
        <cfquery name="local.scopeQ" datasource="baceEstimates">
            SELECT * FROM bb_scope_items WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> ORDER BY sort_order, scope_id
        </cfquery>
        <cfquery name="local.phaseQ" datasource="baceEstimates">
            SELECT * FROM bb_timeline_phases WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> ORDER BY sort_order, phase_id
        </cfquery>
        <cfquery name="local.payQ" datasource="baceEstimates">
            SELECT * FROM bb_payment_schedule WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> ORDER BY sort_order, payment_id
        </cfquery>

        <cfset result.bid            = local.bidQ>
        <cfset result.lineItems      = local.itemsQ>
        <cfset result.scopeItems     = local.scopeQ>
        <cfset result.timelinePhases = local.phaseQ>
        <cfset result.paymentSchedule= local.payQ>
        <cfreturn result>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Save (insert or update) a full bid
          Expects data struct with arrays sourced from
          getPageContext().getRequest().getParameterValues()
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="saveBid" returntype="numeric" access="public">
        <cfargument name="data" type="struct" required="true">
        <cfscript>
            var d       = arguments.data;
            var bidId   = val(d.bid_id ?: 0);
            var taxRate = val(d.tax_rate ?: 0);

            // Compute subtotal from submitted line item arrays
            var itemDescs  = d.item_description ?: [];
            var itemQtys   = d.item_qty         ?: [];
            var itemPrices = d.item_unit_price   ?: [];
            var subtotal   = 0;
            var n = arrayLen(itemDescs);
            for (var i = 1; i <= n; i++) {
                if (len(trim(itemDescs[i]))) {
                    subtotal += val(itemQtys[i] ?: 1) * val(itemPrices[i] ?: 0);
                }
            }
            var taxAmount = subtotal * (taxRate / 100);
            var total     = subtotal + taxAmount;

            var validUntilNull = !len(trim(d.valid_until ?: ""));
        </cfscript>

        <cfif bidId GT 0>
            <!--- UPDATE --->
            <cfquery datasource="baceEstimates">
                UPDATE bb_bids SET
                    client_id       = <cfqueryparam value="#d.client_id#"             cfsqltype="CF_SQL_INTEGER">,
                    bid_title       = <cfqueryparam value="#d.bid_title#"             cfsqltype="CF_SQL_VARCHAR">,
                    project_address = <cfqueryparam value="#d.project_address ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    project_city    = <cfqueryparam value="#d.project_city ?: ''#"    cfsqltype="CF_SQL_VARCHAR">,
                    project_state   = <cfqueryparam value="#d.project_state ?: ''#"   cfsqltype="CF_SQL_VARCHAR">,
                    project_zip     = <cfqueryparam value="#d.project_zip ?: ''#"     cfsqltype="CF_SQL_VARCHAR">,
                    bid_date        = <cfqueryparam value="#d.bid_date#"              cfsqltype="CF_SQL_DATE">,
                    valid_until     = <cfqueryparam value="#d.valid_until ?: ''#"     cfsqltype="CF_SQL_DATE"     null="#validUntilNull#">,
                    status          = <cfqueryparam value="#d.status ?: 'Draft'#"     cfsqltype="CF_SQL_VARCHAR">,
                    scope_notes     = <cfqueryparam value="#d.scope_notes ?: ''#"     cfsqltype="CF_SQL_LONGVARCHAR">,
                    terms           = <cfqueryparam value="#d.terms ?: ''#"           cfsqltype="CF_SQL_LONGVARCHAR">,
                    internal_notes  = <cfqueryparam value="#d.internal_notes ?: ''#"  cfsqltype="CF_SQL_LONGVARCHAR">,
                    tax_rate        = <cfqueryparam value="#taxRate#"                 cfsqltype="CF_SQL_DECIMAL">,
                    subtotal        = <cfqueryparam value="#subtotal#"                cfsqltype="CF_SQL_DECIMAL">,
                    tax_amount      = <cfqueryparam value="#taxAmount#"               cfsqltype="CF_SQL_DECIMAL">,
                    total           = <cfqueryparam value="#total#"                   cfsqltype="CF_SQL_DECIMAL">
                WHERE bid_id = <cfqueryparam value="#bidId#" cfsqltype="CF_SQL_INTEGER">
            </cfquery>
        <cfelse>
            <!--- INSERT --->
            <cfset var bidNum = generateBidNumber()>
            <cfquery datasource="baceEstimates" result="local.ins">
                INSERT INTO bb_bids
                    (client_id, bid_number, bid_title, project_address, project_city,
                     project_state, project_zip, bid_date, valid_until, status,
                     scope_notes, terms, internal_notes, tax_rate, subtotal, tax_amount, total)
                VALUES (
                    <cfqueryparam value="#d.client_id#"             cfsqltype="CF_SQL_INTEGER">,
                    <cfqueryparam value="#bidNum#"                  cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.bid_title#"             cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.project_address ?: ''#" cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.project_city ?: ''#"    cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.project_state ?: ''#"   cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.project_zip ?: ''#"     cfsqltype="CF_SQL_VARCHAR">,
                    <cfqueryparam value="#d.bid_date#"              cfsqltype="CF_SQL_DATE">,
                    <cfqueryparam value="#d.valid_until ?: ''#"     cfsqltype="CF_SQL_DATE"  null="#validUntilNull#">,
                    'Draft',
                    <cfqueryparam value="#d.scope_notes ?: ''#"     cfsqltype="CF_SQL_LONGVARCHAR">,
                    <cfqueryparam value="#d.terms ?: ''#"           cfsqltype="CF_SQL_LONGVARCHAR">,
                    <cfqueryparam value="#d.internal_notes ?: ''#"  cfsqltype="CF_SQL_LONGVARCHAR">,
                    <cfqueryparam value="#taxRate#"                 cfsqltype="CF_SQL_DECIMAL">,
                    <cfqueryparam value="#subtotal#"                cfsqltype="CF_SQL_DECIMAL">,
                    <cfqueryparam value="#taxAmount#"               cfsqltype="CF_SQL_DECIMAL">,
                    <cfqueryparam value="#total#"                   cfsqltype="CF_SQL_DECIMAL">
                )
            </cfquery>
            <cfset bidId = local.ins.generatedKey>
        </cfif>

        <!--- Save sub-records --->
        <cfset saveLineItems(bidId, d)>
        <cfset saveScopeItems(bidId, d)>
        <cfset saveTimelinePhases(bidId, d)>
        <cfset savePaymentSchedule(bidId, d)>

        <cfreturn bidId>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Line Items
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="saveLineItems" returntype="void" access="private">
        <cfargument name="bidId" type="numeric" required="true">
        <cfargument name="d"     type="struct"  required="true">
        <cfscript>
            var descs  = d.item_description ?: [];
            var ids    = d.item_id          ?: [];
            var cats   = d.item_category    ?: [];
            var qtys   = d.item_qty         ?: [];
            var units  = d.item_unit        ?: [];
            var prices = d.item_unit_price  ?: [];
            var kept   = [];
            var n      = arrayLen(descs);
        </cfscript>

        <cfloop from="1" to="#n#" index="local.i">
            <cfset var desc = trim(descs[local.i])>
            <cfif NOT len(desc)><cfcontinue></cfif>

            <cfset var itemId  = val(ids[local.i]    ?: 0)>
            <cfset var qty     = val(qtys[local.i]   ?: 1)>
            <cfset var price   = val(prices[local.i] ?: 0)>
            <cfset var lineTot = qty * price>

            <cfif itemId GT 0>
                <cfquery datasource="baceEstimates">
                    UPDATE bb_line_items SET
                        sort_order  = <cfqueryparam value="#local.i#"                cfsqltype="CF_SQL_INTEGER">,
                        category    = <cfqueryparam value="#cats[local.i] ?: ''#"    cfsqltype="CF_SQL_VARCHAR">,
                        description = <cfqueryparam value="#desc#"                   cfsqltype="CF_SQL_VARCHAR">,
                        quantity    = <cfqueryparam value="#qty#"                    cfsqltype="CF_SQL_DECIMAL">,
                        unit        = <cfqueryparam value="#units[local.i] ?: 'EA'#" cfsqltype="CF_SQL_VARCHAR">,
                        unit_price  = <cfqueryparam value="#price#"                  cfsqltype="CF_SQL_DECIMAL">,
                        line_total  = <cfqueryparam value="#lineTot#"                cfsqltype="CF_SQL_DECIMAL">
                    WHERE item_id = <cfqueryparam value="#itemId#" cfsqltype="CF_SQL_INTEGER">
                      AND bid_id  = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
                <cfset arrayAppend(kept, itemId)>
            <cfelse>
                <cfquery datasource="baceEstimates" result="local.ins">
                    INSERT INTO bb_line_items (bid_id, sort_order, category, description, quantity, unit, unit_price, line_total)
                    VALUES (
                        <cfqueryparam value="#arguments.bidId#"           cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#local.i#"                   cfsqltype="CF_SQL_INTEGER">,
                        <cfqueryparam value="#cats[local.i] ?: ''#"       cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#desc#"                      cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#qty#"                       cfsqltype="CF_SQL_DECIMAL">,
                        <cfqueryparam value="#units[local.i] ?: 'EA'#"    cfsqltype="CF_SQL_VARCHAR">,
                        <cfqueryparam value="#price#"                     cfsqltype="CF_SQL_DECIMAL">,
                        <cfqueryparam value="#lineTot#"                   cfsqltype="CF_SQL_DECIMAL">
                    )
                </cfquery>
                <cfset arrayAppend(kept, local.ins.generatedKey)>
            </cfif>
        </cfloop>

        <!--- Delete rows the user removed --->
        <cfif arrayLen(kept)>
            <cfquery datasource="baceEstimates">
                DELETE FROM bb_line_items
                 WHERE bid_id  = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
                   AND item_id NOT IN (<cfqueryparam value="#arrayToList(kept)#" cfsqltype="CF_SQL_INTEGER" list="true">)
            </cfquery>
        <cfelse>
            <cfquery datasource="baceEstimates">
                DELETE FROM bb_line_items WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
            </cfquery>
        </cfif>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Scope Items
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="saveScopeItems" returntype="void" access="private">
        <cfargument name="bidId" type="numeric" required="true">
        <cfargument name="d"     type="struct"  required="true">
        <cfscript>
            var descs = d.scope_desc ?: [];
            var ids   = d.scope_id   ?: [];
            var kept  = [];
            var n     = arrayLen(descs);
        </cfscript>

        <cfloop from="1" to="#n#" index="local.i">
            <cfset var desc = trim(descs[local.i])>
            <cfif NOT len(desc)><cfcontinue></cfif>
            <cfset var scopeId = val(ids[local.i] ?: 0)>

            <cfif scopeId GT 0>
                <cfquery datasource="baceEstimates">
                    UPDATE bb_scope_items SET sort_order = <cfqueryparam value="#local.i#" cfsqltype="CF_SQL_INTEGER">, description = <cfqueryparam value="#desc#" cfsqltype="CF_SQL_VARCHAR">
                     WHERE scope_id = <cfqueryparam value="#scopeId#" cfsqltype="CF_SQL_INTEGER"> AND bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
                <cfset arrayAppend(kept, scopeId)>
            <cfelse>
                <cfquery datasource="baceEstimates" result="local.ins">
                    INSERT INTO bb_scope_items (bid_id, sort_order, description) VALUES (<cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#local.i#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#desc#" cfsqltype="CF_SQL_VARCHAR">)
                </cfquery>
                <cfset arrayAppend(kept, local.ins.generatedKey)>
            </cfif>
        </cfloop>

        <cfif arrayLen(kept)>
            <cfquery datasource="baceEstimates">
                DELETE FROM bb_scope_items WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> AND scope_id NOT IN (<cfqueryparam value="#arrayToList(kept)#" cfsqltype="CF_SQL_INTEGER" list="true">)
            </cfquery>
        <cfelse>
            <cfquery datasource="baceEstimates">DELETE FROM bb_scope_items WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"></cfquery>
        </cfif>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Timeline Phases
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="saveTimelinePhases" returntype="void" access="private">
        <cfargument name="bidId" type="numeric" required="true">
        <cfargument name="d"     type="struct"  required="true">
        <cfscript>
            var names = d.phase_name ?: [];
            var ids   = d.phase_id   ?: [];
            var descs = d.phase_desc ?: [];
            var days  = d.phase_days ?: [];
            var kept  = [];
            var n     = arrayLen(names);
        </cfscript>

        <cfloop from="1" to="#n#" index="local.i">
            <cfset var nm = trim(names[local.i])>
            <cfif NOT len(nm)><cfcontinue></cfif>
            <cfset var phaseId = val(ids[local.i] ?: 0)>

            <cfif phaseId GT 0>
                <cfquery datasource="baceEstimates">
                    UPDATE bb_timeline_phases SET sort_order = <cfqueryparam value="#local.i#" cfsqltype="CF_SQL_INTEGER">, phase_name = <cfqueryparam value="#nm#" cfsqltype="CF_SQL_VARCHAR">, description = <cfqueryparam value="#descs[local.i] ?: ''#" cfsqltype="CF_SQL_LONGVARCHAR">, duration_days = <cfqueryparam value="#val(days[local.i] ?: 0)#" cfsqltype="CF_SQL_INTEGER">
                     WHERE phase_id = <cfqueryparam value="#phaseId#" cfsqltype="CF_SQL_INTEGER"> AND bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
                <cfset arrayAppend(kept, phaseId)>
            <cfelse>
                <cfquery datasource="baceEstimates" result="local.ins">
                    INSERT INTO bb_timeline_phases (bid_id, sort_order, phase_name, description, duration_days) VALUES (<cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#local.i#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#nm#" cfsqltype="CF_SQL_VARCHAR">, <cfqueryparam value="#descs[local.i] ?: ''#" cfsqltype="CF_SQL_LONGVARCHAR">, <cfqueryparam value="#val(days[local.i] ?: 0)#" cfsqltype="CF_SQL_INTEGER">)
                </cfquery>
                <cfset arrayAppend(kept, local.ins.generatedKey)>
            </cfif>
        </cfloop>

        <cfif arrayLen(kept)>
            <cfquery datasource="baceEstimates">DELETE FROM bb_timeline_phases WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> AND phase_id NOT IN (<cfqueryparam value="#arrayToList(kept)#" cfsqltype="CF_SQL_INTEGER" list="true">)</cfquery>
        <cfelse>
            <cfquery datasource="baceEstimates">DELETE FROM bb_timeline_phases WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"></cfquery>
        </cfif>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Payment Schedule
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="savePaymentSchedule" returntype="void" access="private">
        <cfargument name="bidId" type="numeric" required="true">
        <cfargument name="d"     type="struct"  required="true">
        <cfscript>
            var names  = d.pay_milestone ?: [];
            var ids    = d.pay_id        ?: [];
            var amts   = d.pay_amount    ?: [];
            var pcts   = d.pay_pct       ?: [];
            var ddescs = d.pay_desc      ?: [];
            var kept   = [];
            var n      = arrayLen(names);
        </cfscript>

        <cfloop from="1" to="#n#" index="local.i">
            <cfset var nm = trim(names[local.i])>
            <cfif NOT len(nm)><cfcontinue></cfif>
            <cfset var payId = val(ids[local.i] ?: 0)>

            <cfif payId GT 0>
                <cfquery datasource="baceEstimates">
                    UPDATE bb_payment_schedule SET sort_order = <cfqueryparam value="#local.i#" cfsqltype="CF_SQL_INTEGER">, milestone_name = <cfqueryparam value="#nm#" cfsqltype="CF_SQL_VARCHAR">, amount = <cfqueryparam value="#val(amts[local.i] ?: 0)#" cfsqltype="CF_SQL_DECIMAL">, percent = <cfqueryparam value="#val(pcts[local.i] ?: 0)#" cfsqltype="CF_SQL_DECIMAL">, due_description = <cfqueryparam value="#ddescs[local.i] ?: ''#" cfsqltype="CF_SQL_VARCHAR">
                     WHERE payment_id = <cfqueryparam value="#payId#" cfsqltype="CF_SQL_INTEGER"> AND bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
                </cfquery>
                <cfset arrayAppend(kept, payId)>
            <cfelse>
                <cfquery datasource="baceEstimates" result="local.ins">
                    INSERT INTO bb_payment_schedule (bid_id, sort_order, milestone_name, amount, percent, due_description) VALUES (<cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#local.i#" cfsqltype="CF_SQL_INTEGER">, <cfqueryparam value="#nm#" cfsqltype="CF_SQL_VARCHAR">, <cfqueryparam value="#val(amts[local.i] ?: 0)#" cfsqltype="CF_SQL_DECIMAL">, <cfqueryparam value="#val(pcts[local.i] ?: 0)#" cfsqltype="CF_SQL_DECIMAL">, <cfqueryparam value="#ddescs[local.i] ?: ''#" cfsqltype="CF_SQL_VARCHAR">)
                </cfquery>
                <cfset arrayAppend(kept, local.ins.generatedKey)>
            </cfif>
        </cfloop>

        <cfif arrayLen(kept)>
            <cfquery datasource="baceEstimates">DELETE FROM bb_payment_schedule WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"> AND payment_id NOT IN (<cfqueryparam value="#arrayToList(kept)#" cfsqltype="CF_SQL_INTEGER" list="true">)</cfquery>
        <cfelse>
            <cfquery datasource="baceEstimates">DELETE FROM bb_payment_schedule WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER"></cfquery>
        </cfif>
    </cffunction>

    <!--- ═══════════════════════════════════════════════════════
          Status workflow
    ═══════════════════════════════════════════════════════ --->
    <cffunction name="updateStatus" returntype="void" access="public">
        <cfargument name="bidId"     type="numeric" required="true">
        <cfargument name="newStatus" type="string"  required="true">
        <cfscript>
            var valid = ["Draft","Sent","Accepted","Declined"];
            if (!arrayFind(valid, arguments.newStatus))
                throw(type="InvalidStatus", message="Invalid status: #arguments.newStatus#");
        </cfscript>
        <cfquery datasource="baceEstimates">
            UPDATE bb_bids SET status = <cfqueryparam value="#arguments.newStatus#" cfsqltype="CF_SQL_VARCHAR">
             WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>

    <cffunction name="deleteBid" returntype="void" access="public">
        <cfargument name="bidId" type="numeric" required="true">
        <cfquery datasource="baceEstimates">
            DELETE FROM bb_bids WHERE bid_id = <cfqueryparam value="#arguments.bidId#" cfsqltype="CF_SQL_INTEGER">
        </cfquery>
    </cffunction>

</cfcomponent>
