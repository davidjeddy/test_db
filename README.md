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

## Testing the installation

## Single Instance

    ```sh
    cd ./single
    ```

Import data set

    ```sh
    mysql [options] < employees.sql
    # OR If you want to install with two large partitioned tables, run
    mysql [options] < employees_partitioned.sql
    ```

After installing, you can run one of the following

    ```sh
    mysql [options] -t < test_employees_md5.sql
    # OR
    mysql [options] -t < test_employees_sha.sql
    ```

For example:

    ```sh
    mysql [options] -t < test_employees_md5.sql
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
    ```

## Federated Instances

    ```sh
    cd ./federation
    ```

Execute the installer / execution script w/ correct credentials. Example:

    ```sh
    ./run.sh \
    --user db_user \
    --pass db_pass \
    --department_private_ip 10.128.15.206 \
    --department_public_ip 35.223.220.179 \
    --employee_private_ip 10.128.15.204 \
    --employee_public_ip 35.223.75.230
    ```

The process can take a long time depending on the hardware and network connectivity of the database instance. Eventually you should have output similar to the following.

    ```sh
    This script works on Ubuntu 18.04; it may work on others but is un-tested.
    ...
    Creating federation SQL with credentials...
    Enabled storage engines...
    +--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
    | ENGINE             | SUPPORT | COMMENT                                                                          | TRANSACTIONS | XA   | SAVEPOINTS |
    +--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
    | MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                            | NO           | NO   | NO         |
    | CSV                | YES     | Stores tables as CSV files                                                       | NO           | NO   | NO         |
    | BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears)                   | NO           | NO   | NO         |
    | MyISAM             | YES     | Non-transactional engine with good performance and small data footprint          | NO           | NO   | NO         |
    | Aria               | YES     | Crash-safe tables with MyISAM heritage                                           | NO           | NO   | NO         |
    | InnoDB             | DEFAULT | Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
    | FEDERATED          | YES     | Allows to access tables on other MariaDB servers, supports transactions and more | YES          | NO   | YES        |
    | SEQUENCE           | YES     | Generated tables filled with sequential values                                   | YES          | NO   | YES        |
    | PERFORMANCE_SCHEMA | YES     | Performance Schema                                                               | NO           | NO   | NO         |
    | MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                        | NO           | NO   | NO         |
    +--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
    ...creating department federation configuration for the employee member...
    ...creating employee federation configuration for the department member...
    Applying SQL schema to each member of the federated cluster...
    - Creating schemas...
    INFO
    CREATING DATABASE STRUCTURE
    INFO
    storage engine: InnoDB
    INFO
    CREATING DATABASE STRUCTURE
    INFO
    storage engine: InnoDB
    - Creating federated servers for department member...
    Server_name    Host    Db    Username    Password    Port    Socket    Wrapper    Owner
    test_titles    10.128.15.204    test    zeus    olympus    3306        mysql    zeus
    test_salaries    10.128.15.204    test    zeus    olympus    3306        mysql    zeus
    test_departments    @departments_host    test    zeus    olympus    3306        mysql    zeus
    test_employees    10.128.15.204    test    zeus    olympus    3306        mysql    zeus
    +------------------+-------------------+------+----------+------+--------+---------+-------+
    | Server_name      | Host              | Db   | Username | Port | Socket | Wrapper | Owner |
    +------------------+-------------------+------+----------+------+--------+---------+-------+
    | test_titles      | 10.128.15.204     | test | zeus     | 3306 |        | mysql   | zeus  |
    | test_salaries    | 10.128.15.204     | test | zeus     | 3306 |        | mysql   | zeus  |
    | test_departments | @departments_host | test | zeus     | 3306 |        | mysql   | zeus  |
    | test_employees   | 10.128.15.204     | test | zeus     | 3306 |        | mysql   | zeus  |
    +------------------+-------------------+------+----------+------+--------+---------+-------+
    - Creating federated servers for employee member...
    Server_name    Host    Db    Username    Password    Port    Socket    Wrapper    Owner
    test_dept_manager    10.128.15.206    test    zeus    olympus    3306        mysql    zeus
    test_departments    10.128.15.206    test    zeus    olympus    3306        mysql    zeus
    test_dept_emp    10.128.15.206    test    zeus    olympus    3306        mysql    zeus
    +-------------------+---------------+------+----------+------+--------+---------+-------+
    | Server_name       | Host          | Db   | Username | Port | Socket | Wrapper | Owner |
    +-------------------+---------------+------+----------+------+--------+---------+-------+
    | test_dept_manager | 10.128.15.206 | test | zeus     | 3306 |        | mysql   | zeus  |
    | test_departments  | 10.128.15.206 | test | zeus     | 3306 |        | mysql   | zeus  |
    | test_dept_emp     | 10.128.15.206 | test | zeus     | 3306 |        | mysql   | zeus  |
    +-------------------+---------------+------+----------+------+--------+---------+-------+
    - Creating federated tables...
    - Apply department views...
    - Importing foreign key configs...
    - Importing test dataset...
    INFO
    LOADING departments
    INFO
    LOADING employees
    INFO
    LOADING dept_emp
    INFO
    LOADING dept_manager
    INFO
    LOADING titles
    INFO
    LOADING salaries
    data_load_time_diff
    NULL
    - CRC validating imported data...
    INFO
    TESTING INSTALLATION
    table_name    expected_records    expected_crc
    employees    300024    4ec56ab5ba37218d187cf6ab09ce1aa1
    departments    9    d1af5e170d2d1591d776d5638d71fc5f
    dept_manager    24    8720e2f0853ac9096b689c14664f847e
    dept_emp    331603    ccf6fe516f990bdaa49713fc478701b7
    titles    443308    bfa016c472df68e70a03facafa1bc0a8
    salaries    2844047    fd220654e95aea1b169624ffe3fca934
    table_name    found_records       found_crc
    employees    300024    4ec56ab5ba37218d187cf6ab09ce1aa1
    departments    9    d1af5e170d2d1591d776d5638d71fc5f
    dept_manager    24    8720e2f0853ac9096b689c14664f847e
    dept_emp    331603    ccf6fe516f990bdaa49713fc478701b7
    titles    443308    bfa016c472df68e70a03facafa1bc0a8
    salaries    2844047    fd220654e95aea1b169624ffe3fca934
    table_name    records_match    crc_match
    employees    OK    ok
    departments    OK    ok
    dept_manager    OK    ok
    dept_emp    OK    ok
    titles    OK    ok
    salaries    OK    ok
    computation_time
    NULL
    summary    result
    CRC    OK
    count    OK
    INFO
    TESTING INSTALLATION
    table_name    expected_records    expected_crc
    employees    300024    4d4aa689914d8fd41db7e45c2168e7dcb9697359
    departments    9    4b315afa0e35ca6649df897b958345bcb3d2b764
    dept_manager    24    9687a7d6f93ca8847388a42a6d8d93982a841c6c
    dept_emp    331603    d95ab9fe07df0865f592574b3b33b9c741d9fd1b
    titles    443308    d12d5f746b88f07e69b9e36675b6067abb01b60e
    salaries    2844047    b5a1785c27d75e33a4173aaa22ccf41ebd7d4a9f
    table_name    found_records       found_crc
    employees    300024    4d4aa689914d8fd41db7e45c2168e7dcb9697359
    departments    9    4b315afa0e35ca6649df897b958345bcb3d2b764
    dept_manager    24    9687a7d6f93ca8847388a42a6d8d93982a841c6c
    dept_emp    331603    d95ab9fe07df0865f592574b3b33b9c741d9fd1b
    titles    443308    d12d5f746b88f07e69b9e36675b6067abb01b60e
    salaries    2844047    b5a1785c27d75e33a4173aaa22ccf41ebd7d4a9f
    table_name    records_match    crc_match
    employees    OK    ok
    departments    OK    ok
    dept_manager    OK    ok
    dept_emp    OK    ok
    titles    OK    ok
    salaries    OK    ok
    computation_time
    NULL
    summary    result
    CRC    OK
    count    OK
    Executing load testing commands...
    - md5 against department instance..
    Benchmark
        Average number of seconds to run all queries: 12.754 seconds
        Minimum number of seconds to run all queries: 12.754 seconds
        Maximum number of seconds to run all queries: 12.754 seconds
        Number of clients running queries: 1
        Average number of queries per client: 36

    - md5 against employee instance..
    Benchmark
        Average number of seconds to run all queries: 10.135 seconds
        Minimum number of seconds to run all queries: 10.135 seconds
        Maximum number of seconds to run all queries: 10.135 seconds
        Number of clients running queries: 1
        Average number of queries per client: 36

    - 10 iteration of md5 against department instance..
    Benchmark
        Average number of seconds to run all queries: 12.853 seconds
        Minimum number of seconds to run all queries: 12.694 seconds
        Maximum number of seconds to run all queries: 13.129 seconds
        Number of clients running queries: 1
        Average number of queries per client: 36

    - 10 iteration md5 against employee instance..
    Benchmark
        Average number of seconds to run all queries: 10.301 seconds
        Minimum number of seconds to run all queries: 10.102 seconds
        Maximum number of seconds to run all queries: 11.045 seconds
        Number of clients running queries: 1
        Average number of queries per client: 36
    ```

## DISCLAIMER

To the best of my knowledge, this data is fabricated and it does not correspond to real people. Any similarity to existing people is purely coincidental.

## LICENSE

This work is licensed under the  Creative Commons Attribution-Share Alike 3.0 Unported License.

To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to
Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
