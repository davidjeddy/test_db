SET @employee_host = "EMPLOYEE_HOST";

DROP SERVER IF EXISTS 'test_employees';
CREATE SERVER 'test_employees' foreign data wrapper 'mysql' options (
  HOST '@employee_host',
  DATABASE 'test',
  USER 'EMPLOYEE_USER',
  PASSWORD 'EMPLOYEE_PASS',
  PORT 3306,
  SOCKET '',
  OWNER 'EMPLOYEE_USER'
);

SHOW WARNINGS;

DROP SERVER IF EXISTS 'test_titles';
CREATE SERVER 'test_titles' foreign data wrapper 'mysql' options (
  HOST '@employee_host',
  DATABASE 'test',
  USER 'EMPLOYEE_USER',
  PASSWORD 'EMPLOYEE_PASS',
  PORT 3306,
  SOCKET '',
  OWNER 'EMPLOYEE_USER'
);

SHOW WARNINGS;

DROP SERVER IF EXISTS 'test_salaries';
CREATE SERVER 'test_salaries' foreign data wrapper 'mysql' options (
  HOST '@employee_host',
  DATABASE 'test',
  USER 'EMPLOYEE_USER',
  PASSWORD 'EMPLOYEE_PASS',
  PORT 3306,
  SOCKET '',
  OWNER 'EMPLOYEE_USER'
);

SHOW WARNINGS;

flush /*!50503 binary */ logs;

SELECT * FROM mysql.servers;
