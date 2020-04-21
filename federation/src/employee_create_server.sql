SET @departments_host = "DEPARTMENT_HOST"

DROP SERVER IF EXISTS 'test_departments';
CREATE SERVER IF NOT EXISTS 'test_departments' foreign data wrapper 'mysql' options (
  HOST '@departments_host',
  DATABASE 'test',
  USER 'DEPARTMENT_USER',
  PASSWORD 'DEPARTMENT_PASS',
  PORT 3306,
  SOCKET '',
  OWNER 'DEPARTMENT_USER'
);

SHOW WARNINGS;

DROP SERVER IF EXISTS 'test_department_manager';
CREATE SERVER IF NOT EXISTS 'test_department_manager' foreign data wrapper 'mysql' options (
  HOST '@departments_host',
  DATABASE 'test',
  USER 'DEPARTMENT_USER',
  PASSWORD 'DEPARTMENT_PASS',
  PORT 3306,
  SOCKET '',
  OWNER 'DEPARTMENT_USER'
);

SHOW WARNINGS;

DROP SERVER IF EXISTS 'test_department_emp';
CREATE SERVER IF NOT EXISTS 'test_department_emp' foreign data wrapper 'mysql' options (
  HOST '@departments_host',
  DATABASE 'test',
  USER 'DEPARTMENT_USER',
  PASSWORD 'DEPARTMENT_PASS',
  PORT 3306,
  SOCKET '',
  OWNER 'DEPARTMENT_USER'
);

SHOW WARNINGS;

SELECT * FROM mysql.servers;
