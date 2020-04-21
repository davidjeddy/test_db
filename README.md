# test_db

A sample database with an integrated test suite, used to test your applications and database servers

This repository was migrated from GitHub project [datacharmer / test_db](https://github.com/datacharmer/test_db).

See usage in the [MySQL docs](https://dev.mysql.com/doc/employee/en/index.html)

## Where it comes from

The original data was created by Fusheng Wang and Carlo Zaniolo at Siemens Corporate Research. The data is in XML format. [http://timecenter.cs.aau.dk/software.htm](http://timecenter.cs.aau.dk/software.htm)

Giuseppe Maxia made the relational schema and Patrick Crews exported the data in relational format.

The database contains about 300,000 employee records with 2.8 million  salary entries. The export data is 167 MB, which is not huge, but heavy enough to be non-trivial for testing.

The data was generated, and as such there are inconsistencies and subtle problems. Rather than removing them, we decided to leave the contents untouched, and use these issues as data cleaning exercises.

## Prerequisites

You need a MySQL database server (5.0+) and run the commands below through a user that has the following privileges:

    SELECT, INSERT, UPDATE, DELETE, 
    CREATE, DROP, RELOAD, REFERENCES, 
    INDEX, ALTER, SHOW DATABASES, 
    CREATE TEMPORARY TABLES, 
    LOCK TABLES, EXECUTE, CREATE VIEW

## Federation

To test MariaDB table federation via **federatedx** table engine the **federatedx** storage engine must be enabled:

/etc/my/*.cnf:

    ```conf
    ...
    [mariadb]
    ...
    plugin_load_add=ha_federatedx
    ...
    ```

Federation seperates the table locations across two databases instances:

- instance `employee` contains the `employees`, `title`, and `salary` tables.
- instance `departemtn` contains the `dept_manager`,`departments`, and `dept_emp` tables.

The desire with this division is to stress the communication between the two databases instance across a network via the federatedx table engine.

## Installation

1. Download the repository
2. Change directory to the repository
3. Change into either `single` or `federated` based on your configuration

Then run

    mysql [options] < ./single/employees.sql

If you want to install with two large partitioned tables, run

    mysql < ./single/employees_partitioned.sql

## Testing the installation

After installing, you can run one of the following

    mysql [options] -t < ./single/test_employees_md5.sql
    # OR
    mysql [options] -t < ./single/test_employees_sha.sql

For example:

    mysql [options] -t < ./single/test_employees_md5.sql
    +----------------------+
    | INFO                 |
    +----------------------+
    | TESTING INSTALLATION |
    +----------------------+
    +--------------+------------------+----------------------------------+
    | table_name   | expected_records | expected_crc                     |
    +--------------+------------------+----------------------------------+
    | employees    |           300024 | 4ec56ab5ba37218d187cf6ab09ce1aa1 |
    | departments  |                9 | d1af5e170d2d1591d776d5638d71fc5f |
    | dept_manager |               24 | 8720e2f0853ac9096b689c14664f847e |
    | dept_emp     |           331603 | ccf6fe516f990bdaa49713fc478701b7 |
    | titles       |           443308 | bfa016c472df68e70a03facafa1bc0a8 |
    | salaries     |          2844047 | fd220654e95aea1b169624ffe3fca934 |
    +--------------+------------------+----------------------------------+
    +--------------+------------------+----------------------------------+
    | table_name   | found_records    | found_crc                        |
    +--------------+------------------+----------------------------------+
    | employees    |           300024 | 4ec56ab5ba37218d187cf6ab09ce1aa1 |
    | departments  |                9 | d1af5e170d2d1591d776d5638d71fc5f |
    | dept_manager |               24 | 8720e2f0853ac9096b689c14664f847e |
    | dept_emp     |           331603 | ccf6fe516f990bdaa49713fc478701b7 |
    | titles       |           443308 | bfa016c472df68e70a03facafa1bc0a8 |
    | salaries     |          2844047 | fd220654e95aea1b169624ffe3fca934 |
    +--------------+------------------+----------------------------------+
    +--------------+---------------+-----------+
    | table_name   | records_match | crc_match |
    +--------------+---------------+-----------+
    | employees    | OK            | ok        |
    | departments  | OK            | ok        |
    | dept_manager | OK            | ok        |
    | dept_emp     | OK            | ok        |
    | titles       | OK            | ok        |
    | salaries     | OK            | ok        |
    +--------------+---------------+-----------+

## DISCLAIMER

To the best of my knowledge, this data is fabricated and it does not correspond to real people. Any similarity to existing people is purely coincidental.

## LICENSE

This work is licensed under the  Creative Commons Attribution-Share Alike 3.0 Unported License.

To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to
Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
