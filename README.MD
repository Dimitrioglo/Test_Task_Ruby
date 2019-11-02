# Test Task Junior Ruby Developer SaltEdge

1.  Using Watir gem write a script that starts a browser instance and signs into the bank interface. You can use any of your banking accounts or use the following(demo mode):

- https://my.fibank.bg/oauth2-server/login?client_id=E_BANK

2. Write a script that navigates through the bank's page, collects information and prints an array of **Account** objects with the following parameters:

- name
- currency
- balance
- nature
- transactions

3. Create an **Accounts** class that has the following fields:

Example output:

```json

{
"accounts": [
{
"name": "account1",
"balance": 300.22,
"currency": "MDL",
"nature": "checking"
}
]
}

```

4. Write a script that navigates through every account available on bank’s site, collect information, and print an array of **Transaction** objects with the following parameters:

- date
- description
- amount
- currency
- account_name

5. Create a **Transactions** class that has the following fields:

```json

{
"transactions": [
{
"date": "2015-01-15T08:18:26Z",
"description": "bought food",
"amount": -20.31,
"currency": "MDL",
"account_name": "account1"
}
]
}

```

6. Extend your script to output the list of transactions for the last two months.

7. Extend your script in such a way that the stored accounts contain a list of their Transactions.

Example of output:

```json

{
"accounts": [
{
"name": "account1",
"balance": 300.22,
"currency": "MDL",
"description": "My checking account",
"transactions": [
{
"date": "2015-01-15T08:18:26Z",
"description": "bought food",
"amount": -20.31,
"currency": "MDL",
"account_name": "account1"
}
]
}
]
}

```

8. Install Nokogiri gem. Use it to minimize the number of actions in Watir. Rewrite the code responsible for data extraction from Watir objects to Nokogiri.

9. Cover your code with `RSpec` tests using fixtures (optional).
