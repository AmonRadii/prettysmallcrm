CREATE TYPE task_status_type AS ENUM ('WAITING', 'PROGRESS', 'DONE');
CREATE TYPE transaction_type_enum AS ENUM ('DEBIT', 'CREDIT');

CREATE TYPE contact_type_enum AS ENUM 
(
	'PHONE','EMAIL','VIBER', 'TELEGRAM',
	'SIGNAL', 'WHATSAPP', 'OTHER'
);

CREATE TABLE clients
(
	client_id serial PRIMARY KEY,
	client_name varchar(128) NOT NULL,
	client_address varchar(256) NOT NULL,
	have_car boolean DEFAULT false,
	comments_for_client text

	-- Maintain data integrity while handling multiple clients per address and duplicate names across different locations.
	CONSTRAINT unique_client_indentity UNIQUE (client_name, client_address)
);

CREATE TABLE client_contacts 
(
	contact_id serial PRIMARY KEY,
	client_id integer NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
	contact_type contact_type_enum[] NOT NULL DEFAULT '{PHONE}',
	contact_info varchar(256) NOT NULL
	
);

CREATE TABLE tasks
(
	task_id serial PRIMARY KEY,
	client_id integer NOT NULL REFERENCES clients(client_id),
	task_info text NOT NULL,
	price numeric(15, 2) DEFAULT 0, 
	task_status task_status_type NOT NULL DEFAULT 'WAITING',
	task_take_date date NOT NULL DEFAULT CURRENT_DATE,
	task_deadline_date date NOT NULL,
	task_comments text 
);

CREATE TABLE bookkeeping
(
	transaction_id serial PRIMARY KEY,
	transaction_date date NOT NULL DEFAULT CURRENT_DATE,
	transaction_type transaction_type_enum NOT NULL DEFAULT 'DEBIT',
	client_id integer REFERENCES clients(client_id),
	manual_description text,
	amount numeric(15, 2) NOT NULL
);

CREATE TABLE transaction_tasks
(
	transaction_id integer REFERENCES bookkeeping(transaction_id) ON DELETE CASCADE,
	task_id integer REFERENCES tasks(task_id) ON DELETE CASCADE,
	amount_allocated numeric(15, 2),
	PRIMARY KEY (transaction_id, task_id)
);
