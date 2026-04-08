<cfscript>
    // Single-quoted strings: # is literal, no interpolation
    _qtyMask = '0.###';   // up to 3 optional decimal places
    _taxMask = '0.##';    // up to 2 optional decimal places
</cfscript>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Proposal — <cfoutput>#encodeForHtml(bid.bid_number[1] ?: '')#</cfoutput></title>
<style>
  /* ── Reset & base ──────────────────────────────────────── */
  * { margin:0; padding:0; box-sizing:border-box; }
  body {
    font-family: Arial, sans-serif;
    font-size: 10pt;
    color: #1a1a1a;
    background: #fff;
  }
  a { color: #C8941A; text-decoration: none; }

  /* ── Layout containers ─────────────────────────────────── */
  .page-wrap   { max-width: 760px; margin: 0 auto; padding: 0; }
  .content-pad { padding: 18px 24px; }

  /* ── Letterhead ────────────────────────────────────────── */
  .letterhead {
    background-color: #18160F;
    padding: 20px 24px 16px;
  }
  .lh-inner {
    width: 100%;
    border-collapse: collapse;
  }
  .lh-brand {
    font-family: Georgia, serif;
    font-size: 22pt;
    font-weight: bold;
    color: #C8941A;
    letter-spacing: 0.04em;
    vertical-align: bottom;
  }
  .lh-contact {
    text-align: right;
    vertical-align: bottom;
    color: #9a9585;
    font-size: 8pt;
    line-height: 1.6;
  }
  .lh-tagline {
    color: #6a6558;
    font-size: 8pt;
    font-style: italic;
    letter-spacing: 0.05em;
  }
  .lh-gold-bar {
    background-color: #C8941A;
    height: 3px;
  }

  /* ── Proposal header block ─────────────────────────────── */
  .proposal-header {
    background-color: #f7f5f0;
    border-bottom: 1px solid #ddd9cc;
    padding: 14px 24px;
  }
  .proposal-title {
    font-family: Georgia, serif;
    font-size: 16pt;
    font-weight: bold;
    color: #18160F;
    letter-spacing: 0.06em;
    text-transform: uppercase;
  }
  .bid-meta {
    font-size: 8.5pt;
    color: #555;
    margin-top: 4px;
  }
  .bid-meta strong { color: #18160F; }

  /* ── Prepared for / Project block ──────────────────────── */
  .info-table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
  }
  .info-table td {
    width: 50%;
    vertical-align: top;
    padding: 14px 24px;
    border-bottom: 1px solid #e8e4d8;
  }
  .info-table td:first-child {
    border-right: 1px solid #e8e4d8;
  }
  .info-label {
    font-size: 7.5pt;
    font-weight: bold;
    color: #C8941A;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    margin-bottom: 5px;
  }
  .info-name {
    font-family: Georgia, serif;
    font-size: 11pt;
    font-weight: bold;
    color: #18160F;
  }
  .info-line {
    font-size: 9pt;
    color: #444;
    line-height: 1.55;
  }

  /* ── Section bar ────────────────────────────────────────── */
  .section-bar {
    background-color: #C8941A;
    color: #18160F;
    font-family: Georgia, serif;
    font-size: 8.5pt;
    font-weight: bold;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    padding: 5px 24px;
  }

  /* ── Scope checklist ────────────────────────────────────── */
  .scope-wrap { padding: 10px 24px 6px; }
  .scope-item {
    font-size: 9.5pt;
    padding: 3px 0;
    color: #1a1a1a;
  }
  .scope-check {
    color: #C8941A;
    font-weight: bold;
    margin-right: 7px;
  }
  .scope-notes-text {
    font-size: 8.5pt;
    color: #555;
    font-style: italic;
    padding: 6px 24px 10px;
  }

  /* ── Cost table ─────────────────────────────────────────── */
  .cost-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 9pt;
  }
  .cost-table thead th {
    background-color: #2a2820;
    color: #C8941A;
    font-size: 7.5pt;
    font-weight: bold;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 6px 10px;
    border-bottom: 2px solid #C8941A;
  }
  .cost-table tbody td {
    padding: 5px 10px;
    border-bottom: 1px solid #e8e4d8;
    vertical-align: top;
    color: #1a1a1a;
  }
  .cost-table tbody tr.row-alt td { background-color: #faf8f4; }
  .cost-table tfoot td {
    padding: 5px 10px;
    font-weight: bold;
    font-size: 9pt;
  }
  .cost-table .td-num { text-align: right; white-space: nowrap; }
  .cost-table tfoot .totals-row td { border-top: 1px solid #ccc; }
  .cost-table tfoot .grand-row td {
    border-top: 2px solid #C8941A;
    color: #C8941A;
    font-family: Georgia, serif;
    font-size: 11pt;
  }

  /* ── Timeline table ─────────────────────────────────────── */
  .tl-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 9pt;
  }
  .tl-table thead th {
    background-color: #2a2820;
    color: #C8941A;
    font-size: 7.5pt;
    font-weight: bold;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 6px 10px;
    border-bottom: 2px solid #C8941A;
  }
  .tl-table tbody td {
    padding: 5px 10px;
    border-bottom: 1px solid #e8e4d8;
    vertical-align: top;
  }
  .tl-table .phase-num {
    background-color: #C8941A;
    color: #18160F;
    font-weight: bold;
    font-size: 8pt;
    text-align: center;
    width: 30px;
  }

  /* ── Payment table ──────────────────────────────────────── */
  .pay-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 9pt;
  }
  .pay-table thead th {
    background-color: #2a2820;
    color: #C8941A;
    font-size: 7.5pt;
    font-weight: bold;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 6px 10px;
    border-bottom: 2px solid #C8941A;
  }
  .pay-table tbody td {
    padding: 5px 10px;
    border-bottom: 1px solid #e8e4d8;
  }
  .pay-table .td-num { text-align: right; white-space: nowrap; }

  /* ── Terms ──────────────────────────────────────────────── */
  .terms-text {
    font-size: 8pt;
    color: #444;
    line-height: 1.6;
    padding: 10px 24px 14px;
    white-space: pre-wrap;
  }

  /* ── Signature block ────────────────────────────────────── */
  .sig-table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
  }
  .sig-table td {
    width: 50%;
    padding: 14px 24px 20px;
    vertical-align: bottom;
  }
  .sig-table td:first-child { border-right: 1px solid #e8e4d8; }
  .sig-line {
    border-top: 1px solid #1a1a1a;
    margin-top: 30px;
    padding-top: 4px;
    font-size: 8pt;
    color: #555;
  }
  .sig-label {
    font-size: 7.5pt;
    color: #999;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    margin-bottom: 2px;
  }

  /* ── Footer ─────────────────────────────────────────────── */
  .doc-footer {
    background-color: #18160F;
    padding: 8px 24px;
    text-align: center;
    color: #6a6558;
    font-size: 7.5pt;
    letter-spacing: 0.04em;
  }
  .doc-footer span.gold { color: #C8941A; }

  /* ── Spacing helpers ────────────────────────────────────── */
  .section-gap { height: 6px; background: #fff; }
</style>
</head>
<body>
<div class="page-wrap">
<cfoutput>
  <!--- ═══════════════════════════════════════════════
        LETTERHEAD
  ═══════════════════════════════════════════════ --->
  <div class="letterhead">
    <table class="lh-inner">
      <tr>
        <td class="lh-brand">
          #encodeForHtml(application.company.name)#<br>
          <span class="lh-tagline">#encodeForHtml(application.company.tagline)#</span>
        </td>
        <td class="lh-contact">
          #encodeForHtml(application.company.address)#<br>
          #encodeForHtml(application.company.city)#, #encodeForHtml(application.company.state)# #encodeForHtml(application.company.zip)#<br>
          #encodeForHtml(application.company.phone)#<br>
          #encodeForHtml(application.company.email)#<br>
          #encodeForHtml(application.company.license)#
        </td>
      </tr>
    </table>
  </div>
  <div class="lh-gold-bar"></div>

  <!--- ═══════════════════════════════════════════════
        PROPOSAL HEADER
  ═══════════════════════════════════════════════ --->
  <div class="proposal-header">
    <table style="width:100%;border-collapse:collapse;">
      <tr>
        <td>
          <div class="proposal-title">Proposal</div>
          <div class="bid-meta">
            <strong>Bid #:</strong> #encodeForHtml(bid.bid_number[1])# &nbsp;&nbsp;
            <strong>Date:</strong> #dateFormat(bid.bid_date[1], 'mmmm d, yyyy')# &nbsp;&nbsp;
            <cfif NOT isNull(bid.valid_until[1]) AND len(bid.valid_until[1])>
              <strong>Valid Until:</strong> #dateFormat(bid.valid_until[1], 'mmmm d, yyyy')#
            </cfif>
          </div>
          <div class="bid-meta" style="margin-top:3px;font-size:10pt;color:##18160F;font-family:Georgia,serif;">
            #encodeForHtml(bid.bid_title[1])#
          </div>
        </td>
        <td style="text-align:right;vertical-align:top;">
          <span style="display:inline-block;padding:4px 12px;border:2px solid ##C8941A;
                       color:##C8941A;font-family:Georgia,serif;font-size:9pt;font-weight:bold;
                       letter-spacing:0.1em;text-transform:uppercase;">
            #encodeForHtml(bid.status[1])#
          </span>
        </td>
      </tr>
    </table>
  </div>

  <!--- ═══════════════════════════════════════════════
        PREPARED FOR / PROJECT ADDRESS
  ═══════════════════════════════════════════════ --->
  <table class="info-table">
    <tr>
      <td>
        <div class="info-label">Prepared For</div>
        <div class="info-name">#encodeForHtml(bid.company_name[1])#</div>
        <cfif len(bid.contact_name[1])>
          <div class="info-line">#encodeForHtml(bid.contact_name[1])#</div>
        </cfif>
        <cfif len(bid.client_email[1])>
          <div class="info-line">#encodeForHtml(bid.client_email[1])#</div>
        </cfif>
        <cfif len(bid.client_phone[1])>
          <div class="info-line">#encodeForHtml(bid.client_phone[1])#</div>
        </cfif>
        <cfif len(bid.client_address[1])>
          <div class="info-line" style="margin-top:4px;">
            #encodeForHtml(bid.client_address[1])#<br>
            #encodeForHtml(bid.client_city[1])#<cfif len(bid.client_city[1]) AND len(bid.client_state[1])>, </cfif>#encodeForHtml(bid.client_state[1])# #encodeForHtml(bid.client_zip[1])#
          </div>
        </cfif>
      </td>
      <td>
        <div class="info-label">Project Location</div>
        <cfif len(bid.project_address[1])>
          <div class="info-line">
            #encodeForHtml(bid.project_address[1])#<br>
            #encodeForHtml(bid.project_city[1])#<cfif len(bid.project_city[1]) AND len(bid.project_state[1])>, </cfif>#encodeForHtml(bid.project_state[1])# #encodeForHtml(bid.project_zip[1])#
          </div>
        <cfelse>
          <div class="info-line" style="color:##999;">Same as client address</div>
        </cfif>
      </td>
    </tr>
  </table>

  <!--- ═══════════════════════════════════════════════
        SCOPE OF WORK
  ═══════════════════════════════════════════════ --->
  <cfif scopeItems.recordCount>
    <div class="section-gap"></div>
    <div class="section-bar">Scope of Work</div>
    <div class="scope-wrap">
      <cfloop query="scopeItems">
        <div class="scope-item">
          <span class="scope-check">&#10003;</span>#encodeForHtml(scopeItems.description)#
        </div>
      </cfloop>
    </div>
    <cfif len(trim(bid.scope_notes[1]))>
      <div class="scope-notes-text">#encodeForHtml(bid.scope_notes[1])#</div>
    </cfif>
  </cfif>

  <!--- ═══════════════════════════════════════════════
        COST BREAKDOWN
  ═══════════════════════════════════════════════ --->
  <cfif lineItems.recordCount>
    <div class="section-gap"></div>
    <div class="section-bar">Cost Breakdown</div>
    <table class="cost-table">
      <thead>
        <tr>
          <th style="width:16%">Category</th>
          <th>Description</th>
          <th style="width:8%" class="td-num">Qty</th>
          <th style="width:7%">Unit</th>
          <th style="width:13%" class="td-num">Unit Price</th>
          <th style="width:13%" class="td-num">Total</th>
        </tr>
      </thead>
      <tbody>
        <cfloop query="lineItems">
          <tr<cfif lineItems.currentRow mod 2 eq 0> class="row-alt"</cfif>>
            <td style="color:##777;font-size:8.5pt;">#encodeForHtml(lineItems.category)#</td>
            <td>#encodeForHtml(lineItems.description)#</td>
            <td class="td-num">#numberFormat(lineItems.quantity, _qtyMask)#</td>
            <td style="color:##777;">#encodeForHtml(lineItems.unit)#</td>
            <td class="td-num">#dollarFormat(lineItems.unit_price)#</td>
            <td class="td-num">#dollarFormat(lineItems.line_total)#</td>
          </tr>
        </cfloop>
      </tbody>
      <tfoot>
        <tr class="totals-row">
          <td colspan="5" style="text-align:right;color:##555;">Subtotal</td>
          <td class="td-num">#dollarFormat(bid.subtotal[1])#</td>
        </tr>
        <cfif val(bid.tax_rate[1]) GT 0>
          <tr class="totals-row">
            <td colspan="5" style="text-align:right;color:##555;">
              Tax (#numberFormat(bid.tax_rate[1], _taxMask)#%)
            </td>
            <td class="td-num">#dollarFormat(bid.tax_amount[1])#</td>
          </tr>
        </cfif>
        <tr class="grand-row">
          <td colspan="5" style="text-align:right;">Total</td>
          <td class="td-num">#dollarFormat(bid.total[1])#</td>
        </tr>
      </tfoot>
    </table>
  </cfif>

  <!--- ═══════════════════════════════════════════════
        PROJECT TIMELINE
  ═══════════════════════════════════════════════ --->
  <cfif timelinePhases.recordCount>
    <div class="section-gap"></div>
    <div class="section-bar">Project Timeline</div>
    <table class="tl-table">
      <thead>
        <tr>
          <th style="width:30px">##</th>
          <th style="width:24%">Phase</th>
          <th>Description</th>
          <th style="width:110px;text-align:right;">Est. Duration</th>
        </tr>
      </thead>
      <tbody>
        <cfloop query="timelinePhases">
          <tr>
            <td class="phase-num">#timelinePhases.currentRow#</td>
            <td style="font-weight:bold;">#encodeForHtml(timelinePhases.phase_name)#</td>
            <td style="color:##444;">#encodeForHtml(timelinePhases.description ?: '')#</td>
            <td style="text-align:right;color:##555;">
              <cfif timelinePhases.duration_days GT 0>
                #timelinePhases.duration_days# day#(timelinePhases.duration_days neq 1 ? 's' : '')#
              </cfif>
            </td>
          </tr>
        </cfloop>
      </tbody>
    </table>
  </cfif>

  <!--- ═══════════════════════════════════════════════
        PAYMENT SCHEDULE
  ═══════════════════════════════════════════════ --->
  <cfif paymentSchedule.recordCount>
    <div class="section-gap"></div>
    <div class="section-bar">Payment Schedule</div>
    <table class="pay-table">
      <thead>
        <tr>
          <th style="width:26%">Milestone</th>
          <th style="width:16%;text-align:right;">Amount</th>
          <th style="width:10%;text-align:right;">% of Total</th>
          <th>Due / Terms</th>
        </tr>
      </thead>
      <tbody>
        <cfloop query="paymentSchedule">
          <tr>
            <td style="font-weight:bold;">#encodeForHtml(paymentSchedule.milestone_name)#</td>
            <td class="td-num">#dollarFormat(paymentSchedule.amount)#</td>
            <td class="td-num">
              <cfif val(paymentSchedule.percent) GT 0>#numberFormat(paymentSchedule.percent, _taxMask)#%</cfif>
            </td>
            <td style="color:##444;">#encodeForHtml(paymentSchedule.due_description)#</td>
          </tr>
        </cfloop>
      </tbody>
    </table>
  </cfif>

  <!--- ═══════════════════════════════════════════════
        TERMS & CONDITIONS
  ═══════════════════════════════════════════════ --->
  <cfif len(trim(bid.terms[1]))>
    <div class="section-gap"></div>
    <div class="section-bar">Terms &amp; Conditions</div>
    <div class="terms-text">#encodeForHtml(bid.terms[1])#</div>
  </cfif>

  <!--- ═══════════════════════════════════════════════
        SIGNATURE BLOCK
  ═══════════════════════════════════════════════ --->
  <div class="section-gap" style="height:10px;"></div>
  <div style="border-top:1px solid ##e8e4d8;"></div>
  <table class="sig-table">
    <tr>
      <td>
        <div class="sig-label">Authorized by #encodeForHtml(application.company.name)#</div>
        <div class="sig-line">Signature &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Date</div>
        <div style="margin-top:8px;font-size:8pt;color:##555;">
          Printed Name / Title
        </div>
        <div style="border-top:1px solid ##aaa;margin-top:24px;padding-top:3px;font-size:8pt;color:##555;">
          &nbsp;
        </div>
      </td>
      <td>
        <div class="sig-label">Client Acceptance — #encodeForHtml(bid.company_name[1])#</div>
        <div class="sig-line">Signature &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Date</div>
        <div style="margin-top:8px;font-size:8pt;color:##555;">
          Printed Name / Title
        </div>
        <div style="border-top:1px solid ##aaa;margin-top:24px;padding-top:3px;font-size:8pt;color:##555;">
          &nbsp;
        </div>
      </td>
    </tr>
  </table>

  <!--- ═══════════════════════════════════════════════
        FOOTER
  ═══════════════════════════════════════════════ --->
  <div class="doc-footer">
    <span class="gold">#encodeForHtml(application.company.name)#</span>
    &nbsp;&middot;&nbsp; #encodeForHtml(application.company.phone)#
    &nbsp;&middot;&nbsp; #encodeForHtml(application.company.email)#
    &nbsp;&middot;&nbsp; #encodeForHtml(application.company.website)#
    &nbsp;&middot;&nbsp; #encodeForHtml(application.company.license)#
  </div>

</cfoutput>
</div><!--- /page-wrap --->
</body>
</html>
