<cfcomponent>
    <cfset this.name               = "BaceBuiltBidCore_v1">
    <cfset this.datasource         = "baceEstimates">
    <cfset this.sessionManagement  = true>
    <cfset this.sessionTimeout     = createTimeSpan(0, 4, 0, 0)>
    <cfset this.applicationTimeout = createTimeSpan(1, 0, 0, 0)>

    <cffunction name="onApplicationStart" returntype="void">
        <!--- Company profile — update to match your letterhead --->
        <cfset application.company = {
            name:    "BaceBuilt",
            tagline: "Built on Trust. Priced with Precision.",
            address: "123 Construction Way",
            city:    "Your City",
            state:   "TX",
            zip:     "00000",
            phone:   "(555) 000-0000",
            email:   "bids@bacebuilt.com",
            website: "www.bacebuilt.com",
            license: "Lic. #000000"
        }>
    </cffunction>

    <cffunction name="onSessionStart" returntype="void">
    </cffunction>

    <cffunction name="onRequestStart" returntype="boolean" access="public">
        <cfargument name="targetPage" type="string">
        <cfreturn true>
    </cffunction>
</cfcomponent>
