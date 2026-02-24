/*Several queries as an example of database usage*/

--1. Total balance (Income minus Expenses)
SELECT 
    SUM(CASE WHEN transaction_type = 'DEBIT' THEN amount ELSE 0 END) -
    SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount ELSE 0 END) AS net_profit
FROM bookkeeping;

--2. Get all contacts of clients who have a Telegram
SELECT client_name, client_address, contact_info
FROM clients c 
JOIN client_contacts cc ON c.client_id = cc.client_id
WHERE 'TELEGRAM'::contact_type_enum = ANY(cc.contact_type);

--3. Payment report: how much the task costs, how much is paid and what is the balance
SELECT 
    c.client_name,
    c.client_address,
    t.task_info,
    t.price AS task_price,
    COALESCE(SUM(tt.amount_allocated), 0) AS total_paid,
    (t.price - COALESCE(SUM(tt.amount_allocated), 0)) AS balance_due,
    t.task_status
FROM tasks t
JOIN clients c ON t.client_id = c.client_id
LEFT JOIN transaction_tasks tt ON t.task_id = tt.task_id
GROUP BY c.client_name, t.task_id, t.task_info, t.price, t.task_status
ORDER BY balance_due DESC;