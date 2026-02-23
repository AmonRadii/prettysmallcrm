/*SEED DATA FOR PRETTYSMALLCRM TESTING*/

-- WARNING: This command wipes all data from the database tables.
-- Use only for testing on a demo/dev environment, otherwise all data will be permanently lost.
TRUNCATE clients, client_contacts, tasks, bookkeeping,transaction_tasks RESTART IDENTITY CASCADE;

-- 1. Add Clients
INSERT INTO clients (client_name, client_address, have_car, comments_for_client) VALUES 
('John Doe', '123 Main St, Anytown USA', true, NULL),
('Jane Smith', '456 Elm St, Anytown USA', false, 'This client locates nearby'),
('Bob Johnson', '789 Oak St, Anytown USA', true, 'This client came through an advertisement'),
('Alice Williams', '101 Pine St, Anytown USA', false, 'This client requests a regular subscription'),
('Charlie Brown', '222 Maple St, Anytown USA', true, NULL);


-- 2. Add Contacts 
INSERT INTO client_contacts (client_id, contact_type, contact_info) VALUES 
(1, '{PHONE}', '555-1234'),
(1, '{EMAIL}', '9dK9M@example.com'),
(2, '{PHONE, VIBER, WHATSAPP}', '555-5678'),
(3, '{TELEGRAM}', '@bobjohnson'),
(3, '{EMAIL}', 'bob@johnson.com'),
(3, '{PHONE, VIBER, SIGNAL}', '555-9012'),
(4, '{PHONE, VIBER, WHATSAPP, TELEGRAM}', '555-3456'),
(5, '{EMAIL}', 'charlie@brown.com');


-- 3. Add Tasks
INSERT INTO tasks (client_id, task_info, price, task_status, 
            task_take_date, task_deadline_date, task_comments) VALUES
(
    (SELECT client_id FROM clients WHERE client_name = 'John Doe' AND client_address = '123 Main St, Anytown USA'),
    'LAN security test', 100.00, 'DONE', '2026-03-01', '2026-03-03', 'Small company WLAN'
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Jane Smith' AND client_address = '456 Elm St, Anytown USA'),
    'Network infrasrtructure audit', 300.00, 'PROGRESS', '2026-03-05', '2026-03-09', NULL
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Jane Smith' AND client_address = '456 Elm St, Anytown USA'),
    'Network infrasrtructure refactoring', 500.00, 'WAITING', '2026-03-09', '2026-03-19', 'Price can be changed based on the audit result'
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Bob Johnson' AND client_address = '789 Oak St, Anytown USA'),
    'Full company website build', 800.00, 'WAITING', '2026-03-25', '2026-04-15', NULL
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Bob Johnson' AND client_address = '789 Oak St, Anytown USA'),
    'Full website hosting configuration', 500.00, 'WAITING', '2026-04-15', '2026-04-20', 'Choose  Datacenter, configure DNS, SSL, firewall, nginx'
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Bob Johnson' AND client_address = '789 Oak St, Anytown USA'),
    'Website support consulting', 200.00, 'WAITING', '2026-04-20', '2026-04-22', NULL
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Alice Williams' AND client_address = '101 Pine St, Anytown USA'),
    'Web Server penetration test', 400.00, 'DONE', '2025-12-01', '2025-12-10', NULL
),
(
    (SELECT client_id FROM clients WHERE client_name = 'Charlie Brown' AND client_address = '222 Maple St, Anytown USA'),
    'Bugfix web application', 400.00, 'DONE', '2025-12-11', '2025-12-13', NULL
);

-- 4. Add bookkeeping entries
INSERT INTO bookkeeping (transaction_date, transaction_type, client_id, 
                        manual_description, amount) VALUES
(
    '2026-03-03', 'DEBIT', 
    (SELECT client_id FROM clients WHERE client_name = 'John Doe' AND client_address = '123 Main St, Anytown USA'),
    'LAN security test', 100.00
),
(
    '2026-03-05', 'DEBIT', 
    (SELECT client_id FROM clients WHERE client_name = 'Jane Smith' AND client_address = '456 Elm St, Anytown USA'),
    'Network infrasrtructure audit', 300.00
),
(
    '2026-03-25', 'DEBIT', 
    (SELECT client_id FROM clients WHERE client_name = 'Bob Johnson' AND client_address = '789 Oak St, Anytown USA'),
    NULL, 1500.00
),
(
    '2025-11-29', 'DEBIT', 
    (SELECT client_id FROM clients WHERE client_name = 'Alice Williams' AND client_address = '101 Pine St, Anytown USA'),
    NULL, 200.00
),
(
    '2025-12-05', 'DEBIT', 
    (SELECT client_id FROM clients WHERE client_name = 'Alice Williams' AND client_address = '101 Pine St, Anytown USA'),
    NULL, 200.00
),
(
    '2025-12-10', 'DEBIT', 
    (SELECT client_id FROM clients WHERE client_name = 'Charlie Brown' AND client_address = '222 Maple St, Anytown USA'),
    'Web application bugfix', 400.00
),
(
    '2026-03-05', 'CREDIT', NULL, 'New Laptop for work', 500.00
);

-- 5. Add connection between tasks and transactions
INSERT INTO transaction_tasks (transaction_id, task_id, amount_allocated)
WITH link_data(c_name, tn_date, tn_amount, tk_info, allocated) AS (
    VALUES
    ('John Doe', '2026-03-03'::date, 100.00, 'LAN security test', 100.00),
    ('Jane Smith', '2026-03-05'::date, 300.00,'Network infrasrtructure audit', 300.00),
    ('Bob Johnson', '2026-03-25'::date, 1500.00, 'Full company website build', 800.00),
    ('Bob Johnson', '2026-03-25'::date, 1500.00, 'Full website hosting configuration', 500.00),
    ('Bob Johnson', '2026-03-25'::date, 1500.00, 'Website support consulting', 200.00),
    ('Alice Williams', '2025-11-29'::date, 200.00, 'Web Server penetration test', 200.00),
    ('Alice Williams', '2025-12-05'::date, 200.00, 'Web Server penetration test', 200.00),
    ('Charlie Brown', '2025-12-10'::date, 400.00, 'Web application bugfix', 400.00)
)
SELECT
    b.transaction_id,
    t.task_id,
    ld.allocated
FROM link_data ld
JOIN clients c ON c.client_name = ld.c_name
JOIN bookkeeping b ON b.client_id = c.client_id 
                    AND b.transaction_date = ld.tn_date
                    AND b.amount = ld.tn_amount
JOIN tasks t ON t.client_id = c.client_id
                AND t.task_info = ld.tk_info;