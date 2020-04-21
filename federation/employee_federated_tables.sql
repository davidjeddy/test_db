CREATE TABLE IF NOT EXISTS departments
ENGINE="FEDERATED" DEFAULT CHARSET=ucs2
CONNECTION='test.departments';

CREATE TABLE IF NOT EXISTS dept_manager
ENGINE="FEDERATED" DEFAULT CHARSET=ucs2
CONNECTION='test.dept_manager';

CREATE TABLE IF NOT EXISTS dept_emp
ENGINE="FEDERATED" DEFAULT CHARSET=ucs2
CONNECTION='test.dept_emp';

SHOW WARNINGS;

flush /*!50503 binary */ logs;
