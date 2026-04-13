<?php

class BidService
{
    private PDO $db;

    public function __construct()
    {
        $this->db = get_pdo();
    }

    // ── Bid number generator  BB-YYYY-NNNN ───────────────────────────
    public function generateBidNumber(): string
    {
        $yr   = (int) date('Y');
        $stmt = $this->db->prepare(
            'SELECT COUNT(*) FROM bb_bids WHERE YEAR(created_at) = ?'
        );
        $stmt->execute([$yr]);
        $count = (int) $stmt->fetchColumn();
        return "BB-{$yr}-" . str_pad($count + 1, 4, '0', STR_PAD_LEFT);
    }

    // ── List bids (with client join) ──────────────────────────────────
    public function getAll(string $status = '', string $search = ''): array
    {
        $sql    = 'SELECT b.bid_id, b.bid_number, b.bid_title, b.bid_date, b.valid_until,
                          b.status, b.total, b.created_at, b.updated_at,
                          c.company_name, c.contact_name, c.email, c.phone
                     FROM bb_bids b
                     JOIN bb_clients c ON b.client_id = c.client_id
                    WHERE 1=1';
        $params = [];

        if ($status !== '') {
            $sql      .= ' AND b.status = ?';
            $params[]  = $status;
        }
        if ($search !== '') {
            $sql      .= ' AND (c.company_name LIKE ? OR b.bid_title LIKE ? OR b.bid_number LIKE ?)';
            $like      = "%{$search}%";
            $params[]  = $like;
            $params[]  = $like;
            $params[]  = $like;
        }

        $sql .= ' ORDER BY b.created_at DESC';
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    // ── Get single bid + all sub-records ─────────────────────────────
    public function getById(int $bidId): array
    {
        $stmt = $this->db->prepare('
            SELECT b.*,
                   c.company_name, c.contact_name, c.email AS client_email,
                   c.phone AS client_phone,
                   c.address AS client_address, c.city AS client_city,
                   c.state AS client_state, c.zip AS client_zip
              FROM bb_bids b
              JOIN bb_clients c ON b.client_id = c.client_id
             WHERE b.bid_id = ?
        ');
        $stmt->execute([$bidId]);
        $bid = $stmt->fetch();
        if (!$bid) {
            return [];
        }

        $fetch = function (string $sql) use ($bidId): array {
            $s = $this->db->prepare($sql);
            $s->execute([$bidId]);
            return $s->fetchAll();
        };

        return [
            'bid'             => $bid,
            'lineItems'       => $fetch('SELECT * FROM bb_line_items      WHERE bid_id = ? ORDER BY sort_order, item_id'),
            'scopeItems'      => $fetch('SELECT * FROM bb_scope_items     WHERE bid_id = ? ORDER BY sort_order, scope_id'),
            'timelinePhases'  => $fetch('SELECT * FROM bb_timeline_phases WHERE bid_id = ? ORDER BY sort_order, phase_id'),
            'paymentSchedule' => $fetch('SELECT * FROM bb_payment_schedule WHERE bid_id = ? ORDER BY sort_order, payment_id'),
        ];
    }

    // ── Save (insert or update) a full bid ───────────────────────────
    public function saveBid(array $d): int
    {
        $bidId    = (int) ($d['bid_id']   ?? 0);
        $taxRate  = (float) ($d['tax_rate'] ?? 0);

        // Compute subtotal from submitted line item arrays
        $descs    = $d['item_description'] ?? [];
        $qtys     = $d['item_qty']         ?? [];
        $prices   = $d['item_unit_price']  ?? [];
        $subtotal = 0.0;
        $n        = count($descs);
        for ($i = 0; $i < $n; $i++) {
            if (trim($descs[$i] ?? '') !== '') {
                $subtotal += (float) ($qtys[$i] ?? 1) * (float) ($prices[$i] ?? 0);
            }
        }
        $taxAmount  = $subtotal * ($taxRate / 100);
        $total      = $subtotal + $taxAmount;
        $validUntil = trim($d['valid_until'] ?? '') ?: null;

        if ($bidId > 0) {
            $stmt = $this->db->prepare('
                UPDATE bb_bids SET
                    client_id       = ?,
                    bid_title       = ?,
                    project_address = ?,
                    project_city    = ?,
                    project_state   = ?,
                    project_zip     = ?,
                    bid_date        = ?,
                    valid_until     = ?,
                    status          = ?,
                    scope_notes     = ?,
                    terms           = ?,
                    internal_notes  = ?,
                    tax_rate        = ?,
                    subtotal        = ?,
                    tax_amount      = ?,
                    total           = ?
                WHERE bid_id = ?
            ');
            $stmt->execute([
                (int) ($d['client_id']       ?? 0),
                $d['bid_title']              ?? '',
                $d['project_address']        ?? '',
                $d['project_city']           ?? '',
                $d['project_state']          ?? '',
                $d['project_zip']            ?? '',
                $d['bid_date']               ?? date('Y-m-d'),
                $validUntil,
                $d['status']                 ?? 'Draft',
                $d['scope_notes']            ?? '',
                $d['terms']                  ?? '',
                $d['internal_notes']         ?? '',
                $taxRate,
                $subtotal,
                $taxAmount,
                $total,
                $bidId,
            ]);
        } else {
            $bidNum = $this->generateBidNumber();
            $stmt   = $this->db->prepare('
                INSERT INTO bb_bids
                    (client_id, bid_number, bid_title, project_address, project_city,
                     project_state, project_zip, bid_date, valid_until, status,
                     scope_notes, terms, internal_notes, tax_rate, subtotal, tax_amount, total)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            ');
            $stmt->execute([
                (int) ($d['client_id']       ?? 0),
                $bidNum,
                $d['bid_title']              ?? '',
                $d['project_address']        ?? '',
                $d['project_city']           ?? '',
                $d['project_state']          ?? '',
                $d['project_zip']            ?? '',
                $d['bid_date']               ?? date('Y-m-d'),
                $validUntil,
                'Draft',
                $d['scope_notes']            ?? '',
                $d['terms']                  ?? '',
                $d['internal_notes']         ?? '',
                $taxRate,
                $subtotal,
                $taxAmount,
                $total,
            ]);
            $bidId = (int) $this->db->lastInsertId();
        }

        $this->saveLineItems($bidId, $d);
        $this->saveScopeItems($bidId, $d);
        $this->saveTimelinePhases($bidId, $d);
        $this->savePaymentSchedule($bidId, $d);

        return $bidId;
    }

    // ── Line Items ────────────────────────────────────────────────────
    private function saveLineItems(int $bidId, array $d): void
    {
        $descs  = $d['item_description'] ?? [];
        $ids    = $d['item_id']          ?? [];
        $cats   = $d['item_category']    ?? [];
        $qtys   = $d['item_qty']         ?? [];
        $units  = $d['item_unit']        ?? [];
        $prices = $d['item_unit_price']  ?? [];
        $kept   = [];
        $n      = count($descs);

        for ($i = 0; $i < $n; $i++) {
            $desc = trim($descs[$i] ?? '');
            if ($desc === '') {
                continue;
            }
            $itemId  = (int) ($ids[$i]    ?? 0);
            $qty     = (float) ($qtys[$i]   ?? 1);
            $price   = (float) ($prices[$i] ?? 0);
            $lineTot = $qty * $price;

            if ($itemId > 0) {
                $stmt = $this->db->prepare('
                    UPDATE bb_line_items SET
                        sort_order  = ?,
                        category    = ?,
                        description = ?,
                        quantity    = ?,
                        unit        = ?,
                        unit_price  = ?,
                        line_total  = ?
                    WHERE item_id = ? AND bid_id = ?
                ');
                $stmt->execute([$i + 1, $cats[$i] ?? '', $desc, $qty, $units[$i] ?? 'EA', $price, $lineTot, $itemId, $bidId]);
                $kept[] = $itemId;
            } else {
                $stmt = $this->db->prepare('
                    INSERT INTO bb_line_items
                        (bid_id, sort_order, category, description, quantity, unit, unit_price, line_total)
                    VALUES (?,?,?,?,?,?,?,?)
                ');
                $stmt->execute([$bidId, $i + 1, $cats[$i] ?? '', $desc, $qty, $units[$i] ?? 'EA', $price, $lineTot]);
                $kept[] = (int) $this->db->lastInsertId();
            }
        }

        if (count($kept) > 0) {
            $placeholders = implode(',', array_fill(0, count($kept), '?'));
            $stmt = $this->db->prepare(
                "DELETE FROM bb_line_items WHERE bid_id = ? AND item_id NOT IN ({$placeholders})"
            );
            $stmt->execute(array_merge([$bidId], $kept));
        } else {
            $this->db->prepare('DELETE FROM bb_line_items WHERE bid_id = ?')->execute([$bidId]);
        }
    }

    // ── Scope Items ───────────────────────────────────────────────────
    private function saveScopeItems(int $bidId, array $d): void
    {
        $descs = $d['scope_desc'] ?? [];
        $ids   = $d['scope_id']   ?? [];
        $kept  = [];
        $n     = count($descs);

        for ($i = 0; $i < $n; $i++) {
            $desc = trim($descs[$i] ?? '');
            if ($desc === '') {
                continue;
            }
            $scopeId = (int) ($ids[$i] ?? 0);

            if ($scopeId > 0) {
                $stmt = $this->db->prepare('
                    UPDATE bb_scope_items SET sort_order = ?, description = ?
                     WHERE scope_id = ? AND bid_id = ?
                ');
                $stmt->execute([$i + 1, $desc, $scopeId, $bidId]);
                $kept[] = $scopeId;
            } else {
                $stmt = $this->db->prepare('
                    INSERT INTO bb_scope_items (bid_id, sort_order, description) VALUES (?,?,?)
                ');
                $stmt->execute([$bidId, $i + 1, $desc]);
                $kept[] = (int) $this->db->lastInsertId();
            }
        }

        if (count($kept) > 0) {
            $placeholders = implode(',', array_fill(0, count($kept), '?'));
            $stmt = $this->db->prepare(
                "DELETE FROM bb_scope_items WHERE bid_id = ? AND scope_id NOT IN ({$placeholders})"
            );
            $stmt->execute(array_merge([$bidId], $kept));
        } else {
            $this->db->prepare('DELETE FROM bb_scope_items WHERE bid_id = ?')->execute([$bidId]);
        }
    }

    // ── Timeline Phases ───────────────────────────────────────────────
    private function saveTimelinePhases(int $bidId, array $d): void
    {
        $names = $d['phase_name'] ?? [];
        $ids   = $d['phase_id']   ?? [];
        $descs = $d['phase_desc'] ?? [];
        $days  = $d['phase_days'] ?? [];
        $kept  = [];
        $n     = count($names);

        for ($i = 0; $i < $n; $i++) {
            $nm = trim($names[$i] ?? '');
            if ($nm === '') {
                continue;
            }
            $phaseId = (int) ($ids[$i] ?? 0);

            if ($phaseId > 0) {
                $stmt = $this->db->prepare('
                    UPDATE bb_timeline_phases
                       SET sort_order = ?, phase_name = ?, description = ?, duration_days = ?
                     WHERE phase_id = ? AND bid_id = ?
                ');
                $stmt->execute([$i + 1, $nm, $descs[$i] ?? '', (int) ($days[$i] ?? 0), $phaseId, $bidId]);
                $kept[] = $phaseId;
            } else {
                $stmt = $this->db->prepare('
                    INSERT INTO bb_timeline_phases (bid_id, sort_order, phase_name, description, duration_days)
                    VALUES (?,?,?,?,?)
                ');
                $stmt->execute([$bidId, $i + 1, $nm, $descs[$i] ?? '', (int) ($days[$i] ?? 0)]);
                $kept[] = (int) $this->db->lastInsertId();
            }
        }

        if (count($kept) > 0) {
            $placeholders = implode(',', array_fill(0, count($kept), '?'));
            $stmt = $this->db->prepare(
                "DELETE FROM bb_timeline_phases WHERE bid_id = ? AND phase_id NOT IN ({$placeholders})"
            );
            $stmt->execute(array_merge([$bidId], $kept));
        } else {
            $this->db->prepare('DELETE FROM bb_timeline_phases WHERE bid_id = ?')->execute([$bidId]);
        }
    }

    // ── Payment Schedule ──────────────────────────────────────────────
    private function savePaymentSchedule(int $bidId, array $d): void
    {
        $names  = $d['pay_milestone'] ?? [];
        $ids    = $d['pay_id']        ?? [];
        $amts   = $d['pay_amount']    ?? [];
        $pcts   = $d['pay_pct']       ?? [];
        $ddescs = $d['pay_desc']      ?? [];
        $kept   = [];
        $n      = count($names);

        for ($i = 0; $i < $n; $i++) {
            $nm = trim($names[$i] ?? '');
            if ($nm === '') {
                continue;
            }
            $payId = (int) ($ids[$i] ?? 0);

            if ($payId > 0) {
                $stmt = $this->db->prepare('
                    UPDATE bb_payment_schedule
                       SET sort_order = ?, milestone_name = ?, amount = ?, percent = ?, due_description = ?
                     WHERE payment_id = ? AND bid_id = ?
                ');
                $stmt->execute([
                    $i + 1, $nm,
                    (float) ($amts[$i] ?? 0),
                    (float) ($pcts[$i] ?? 0),
                    $ddescs[$i] ?? '',
                    $payId, $bidId,
                ]);
                $kept[] = $payId;
            } else {
                $stmt = $this->db->prepare('
                    INSERT INTO bb_payment_schedule
                        (bid_id, sort_order, milestone_name, amount, percent, due_description)
                    VALUES (?,?,?,?,?,?)
                ');
                $stmt->execute([
                    $bidId, $i + 1, $nm,
                    (float) ($amts[$i] ?? 0),
                    (float) ($pcts[$i] ?? 0),
                    $ddescs[$i] ?? '',
                ]);
                $kept[] = (int) $this->db->lastInsertId();
            }
        }

        if (count($kept) > 0) {
            $placeholders = implode(',', array_fill(0, count($kept), '?'));
            $stmt = $this->db->prepare(
                "DELETE FROM bb_payment_schedule WHERE bid_id = ? AND payment_id NOT IN ({$placeholders})"
            );
            $stmt->execute(array_merge([$bidId], $kept));
        } else {
            $this->db->prepare('DELETE FROM bb_payment_schedule WHERE bid_id = ?')->execute([$bidId]);
        }
    }

    // ── Status workflow ───────────────────────────────────────────────
    public function updateStatus(int $bidId, string $newStatus): void
    {
        $valid = ['Draft', 'Sent', 'Accepted', 'Declined'];
        if (!in_array($newStatus, $valid, true)) {
            throw new InvalidArgumentException("Invalid status: {$newStatus}");
        }
        $stmt = $this->db->prepare('UPDATE bb_bids SET status = ? WHERE bid_id = ?');
        $stmt->execute([$newStatus, $bidId]);
    }

    public function deleteBid(int $bidId): void
    {
        $stmt = $this->db->prepare('DELETE FROM bb_bids WHERE bid_id = ?');
        $stmt->execute([$bidId]);
    }
}
