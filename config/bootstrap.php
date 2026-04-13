<?php
/**
 * BaceBuilt BidCore — Bootstrap
 * Include this file at the top of every page.
 */

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// ── Company profile — update to match your letterhead ────────────
$company = [
    'name'    => 'BaceBuilt',
    'tagline' => 'Built on Trust. Priced with Precision.',
    'address' => '123 Construction Way',
    'city'    => 'Your City',
    'state'   => 'TX',
    'zip'     => '00000',
    'phone'   => '(555) 000-0000',
    'email'   => 'bids@bacebuilt.com',
    'website' => 'www.bacebuilt.com',
    'license' => 'Lic. #000000',
];

require_once __DIR__ . '/db.php';
require_once __DIR__ . '/../src/BidService.php';
require_once __DIR__ . '/../src/ClientService.php';

// ── Helper functions ──────────────────────────────────────────────

/** HTML-escape a value for safe output. */
function h($s): string
{
    return htmlspecialchars($s ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** Format a number as USD: $1,234.56 */
function dollar($n): string
{
    return '$' . number_format((float)($n ?? 0), 2);
}

/**
 * Format a date string with a given PHP date() format.
 * Returns '' if the value is empty/null.
 */
function fmt_date($d, string $format = 'M j, Y'): string
{
    if (!$d) return '';
    $ts = strtotime((string)$d);
    return $ts !== false ? date($format, $ts) : '';
}

/** Format for display: "April 13, 2026" */
function fmt_date_long($d): string
{
    return fmt_date($d, 'F j, Y');
}

/** Format for HTML date inputs: "2026-04-13" */
function fmt_date_input($d): string
{
    return fmt_date($d, 'Y-m-d');
}

/**
 * Format a quantity with up to 3 decimal places, trimming trailing zeros.
 * e.g. 1.500 → "1.5",  2.000 → "2",  1.250 → "1.25"
 */
function fmt_qty($n): string
{
    return rtrim(rtrim(number_format((float)$n, 3), '0'), '.');
}

/**
 * Format a percentage with up to 2 decimal places, trimming trailing zeros.
 * e.g. 8.50 → "8.5",  8.00 → "8"
 */
function fmt_pct($n): string
{
    return rtrim(rtrim(number_format((float)$n, 2), '0'), '.');
}

/** Redirect to $url and exit. */
function redirect(string $url): never
{
    header('Location: ' . $url);
    exit;
}
