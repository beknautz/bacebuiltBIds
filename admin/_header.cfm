<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><cfif isDefined("pageTitle") AND len(pageTitle)>#encodeForHtml(pageTitle)# — </cfif>BaceBuilt BidCore</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="../assets/css/bacebuilt.css">
</head>
<body>

<nav class="navbar navbar-bb navbar-expand-lg mb-0">
  <div class="container-fluid">
    <a class="navbar-brand" href="bids.cfm">
      <i class="bi bi-hammer me-1"></i>BaceBuilt BidCore
    </a>
    <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
      <i class="bi bi-list text-gold fs-5"></i>
    </button>
    <div class="collapse navbar-collapse" id="navMain">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item">
          <a class="nav-link<cfif isDefined('navActive') AND navActive eq 'bids'> active</cfif>"
             href="bids.cfm"><i class="bi bi-file-earmark-text me-1"></i>Bids</a>
        </li>
        <li class="nav-item">
          <a class="nav-link<cfif isDefined('navActive') AND navActive eq 'clients'> active</cfif>"
             href="clients.cfm"><i class="bi bi-people me-1"></i>Clients</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="bid_edit.cfm">
            <i class="bi bi-plus-circle me-1"></i>New Bid
          </a>
        </li>
      </ul>
    </div>
  </div>
</nav>

<div class="container-fluid px-4 py-4">
