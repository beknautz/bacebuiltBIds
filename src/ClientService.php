<?php

class ClientService
{
    private PDO $db;

    public function __construct()
    {
        $this->db = get_pdo();
    }

    public function getAll(bool $activeOnly = false): array
    {
        $sql = 'SELECT client_id, company_name, contact_name, email, phone,
                       address, city, state, zip, notes, created_at
                  FROM bb_clients';
        if ($activeOnly) {
            $sql .= ' WHERE is_active = 1';
        }
        $sql .= ' ORDER BY company_name';
        return $this->db->query($sql)->fetchAll();
    }

    public function getById(int $clientId): array
    {
        $stmt = $this->db->prepare('SELECT * FROM bb_clients WHERE client_id = ?');
        $stmt->execute([$clientId]);
        return $stmt->fetch() ?: [];
    }

    public function save(array $d): int
    {
        $clientId = (int) ($d['client_id'] ?? 0);

        if ($clientId > 0) {
            $stmt = $this->db->prepare('
                UPDATE bb_clients SET
                    company_name = ?,
                    contact_name = ?,
                    email        = ?,
                    phone        = ?,
                    address      = ?,
                    city         = ?,
                    state        = ?,
                    zip          = ?,
                    notes        = ?
                WHERE client_id = ?
            ');
            $stmt->execute([
                $d['company_name'] ?? '',
                $d['contact_name'] ?? '',
                $d['email']        ?? '',
                $d['phone']        ?? '',
                $d['address']      ?? '',
                $d['city']         ?? '',
                $d['state']        ?? '',
                $d['zip']          ?? '',
                $d['notes']        ?? '',
                $clientId,
            ]);
            return $clientId;
        }

        $stmt = $this->db->prepare('
            INSERT INTO bb_clients (company_name, contact_name, email, phone, address, city, state, zip, notes)
            VALUES (?,?,?,?,?,?,?,?,?)
        ');
        $stmt->execute([
            $d['company_name'] ?? '',
            $d['contact_name'] ?? '',
            $d['email']        ?? '',
            $d['phone']        ?? '',
            $d['address']      ?? '',
            $d['city']         ?? '',
            $d['state']        ?? '',
            $d['zip']          ?? '',
            $d['notes']        ?? '',
        ]);
        return (int) $this->db->lastInsertId();
    }

    public function softDelete(int $clientId): void
    {
        $stmt = $this->db->prepare('UPDATE bb_clients SET is_active = 0 WHERE client_id = ?');
        $stmt->execute([$clientId]);
    }

    public function getBidCount(int $clientId): int
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) FROM bb_bids WHERE client_id = ?');
        $stmt->execute([$clientId]);
        return (int) $stmt->fetchColumn();
    }
}
