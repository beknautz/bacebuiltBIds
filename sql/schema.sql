-- ============================================================
-- BaceBuilt BidCore — MySQL Schema
-- Datasource: baceEstimates
-- ============================================================

CREATE TABLE IF NOT EXISTS bb_clients (
    client_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(200) NOT NULL DEFAULT '',
    email        VARCHAR(200) NOT NULL DEFAULT '',
    phone        VARCHAR(50)  NOT NULL DEFAULT '',
    address      VARCHAR(300) NOT NULL DEFAULT '',
    city         VARCHAR(100) NOT NULL DEFAULT '',
    state        VARCHAR(50)  NOT NULL DEFAULT '',
    zip          VARCHAR(20)  NOT NULL DEFAULT '',
    notes        TEXT,
    is_active    TINYINT(1)   NOT NULL DEFAULT 1,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bb_bids (
    bid_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_id       INT UNSIGNED NOT NULL,
    bid_number      VARCHAR(50)  NOT NULL,
    bid_title       VARCHAR(300) NOT NULL,
    project_address VARCHAR(300) NOT NULL DEFAULT '',
    project_city    VARCHAR(100) NOT NULL DEFAULT '',
    project_state   VARCHAR(50)  NOT NULL DEFAULT '',
    project_zip     VARCHAR(20)  NOT NULL DEFAULT '',
    bid_date        DATE         NOT NULL,
    valid_until     DATE             NULL,
    status          ENUM('Draft','Sent','Accepted','Declined') NOT NULL DEFAULT 'Draft',
    scope_notes     TEXT,
    terms           TEXT,
    internal_notes  TEXT,
    subtotal        DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    tax_rate        DECIMAL(6,4)  NOT NULL DEFAULT 0.0000,
    tax_amount      DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    total           DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_bid_number (bid_number),
    CONSTRAINT fk_bid_client FOREIGN KEY (client_id) REFERENCES bb_clients(client_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bb_scope_items (
    scope_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bid_id      INT UNSIGNED NOT NULL,
    sort_order  INT          NOT NULL DEFAULT 0,
    description VARCHAR(500) NOT NULL,
    CONSTRAINT fk_scope_bid FOREIGN KEY (bid_id) REFERENCES bb_bids(bid_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bb_line_items (
    item_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bid_id      INT UNSIGNED  NOT NULL,
    sort_order  INT           NOT NULL DEFAULT 0,
    category    VARCHAR(200)  NOT NULL DEFAULT '',
    description VARCHAR(500)  NOT NULL,
    quantity    DECIMAL(12,3) NOT NULL DEFAULT 1.000,
    unit        VARCHAR(50)   NOT NULL DEFAULT 'EA',
    unit_price  DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    line_total  DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_item_bid FOREIGN KEY (bid_id) REFERENCES bb_bids(bid_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bb_timeline_phases (
    phase_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bid_id        INT UNSIGNED NOT NULL,
    sort_order    INT          NOT NULL DEFAULT 0,
    phase_name    VARCHAR(200) NOT NULL,
    description   TEXT,
    duration_days INT          NOT NULL DEFAULT 0,
    CONSTRAINT fk_phase_bid FOREIGN KEY (bid_id) REFERENCES bb_bids(bid_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bb_payment_schedule (
    payment_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bid_id          INT UNSIGNED  NOT NULL,
    sort_order      INT           NOT NULL DEFAULT 0,
    milestone_name  VARCHAR(200)  NOT NULL,
    amount          DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    percent         DECIMAL(6,3)  NOT NULL DEFAULT 0.000,
    due_description VARCHAR(500)  NOT NULL DEFAULT '',
    CONSTRAINT fk_payment_bid FOREIGN KEY (bid_id) REFERENCES bb_bids(bid_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
