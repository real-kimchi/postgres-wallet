-- User and Account Table Creation
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    balance NUMERIC(10, 2) CHECK (balance >= 0)
);

-- Create Your Account with $10
BEGIN;
WITH new_user AS (
  INSERT INTO users (username, email, first_name, last_name)
  VALUES ('myUsername', 'myemail@gmail.com', 'MyFirstName', 'MyLastName')
  RETURNING user_id
)
INSERT INTO accounts (user_id, balance)
SELECT user_id, 10.00 FROM new_user;
COMMIT;

-- Create Classmate's Account with $20
BEGIN;
WITH new_user AS (
  INSERT INTO users (username, email, first_name, last_name)
  VALUES ('classmateUsername1', 'classmate@gmail.com', 'ClassmateFirstName1', 'ClassmateLastName1')
  RETURNING user_id
)
INSERT INTO accounts (user_id, balance)
SELECT user_id, 20.00 FROM new_user;
COMMIT;

-- Transfer $5.50 with Additional Checks
BEGIN;

-- First, get user_ids for yourself and your classmate
WITH my_user AS (
  SELECT user_id FROM users WHERE username = 'myUsername'
), classmate_user AS (
  SELECT user_id FROM users WHERE username = 'classmateUsername1'
), transfer_check AS (
  SELECT 
    (SELECT balance FROM accounts WHERE user_id IN (SELECT user_id FROM my_user)) AS my_balance,
    (SELECT balance FROM accounts WHERE user_id IN (SELECT user_id FROM classmate_user)) AS classmate_balance
), valid_transfer AS (
  SELECT 
    CASE 
      WHEN my_balance >= 5.50 AND (my_balance + classmate_balance = 30) THEN TRUE
      ELSE FALSE
    END AS is_valid
  FROM transfer_check
)
-- Perform the transfer if conditions are met
, do_transfer AS (
  UPDATE accounts SET balance = balance - 5.50 
  WHERE user_id IN (SELECT user_id FROM my_user) 
  AND EXISTS (SELECT 1 FROM valid_transfer WHERE is_valid = TRUE)
  RETURNING user_id
)
UPDATE accounts SET balance = balance + 5.50 
WHERE user_id IN (SELECT user_id FROM classmate_user) 
AND EXISTS (SELECT 1 FROM valid_transfer WHERE is_valid = TRUE);

-- Commit if the transfer is valid; otherwise, rollback
COMMIT;


/* Validating Transfer:
The sum of the balances of both accounts after the transfer would still be $30.
Performing the Transfer: If the conditions in valid_transfer hold true, then the do_transfer CTE and the subsequent UPDATE statement will execute, transferring the $5.50.

Commit/Rollback: Finally, the transaction will commit if the transfer was valid according to the conditions. If any of the conditions are not met, the transaction will not make any changes, effectively rolling back.
*/
