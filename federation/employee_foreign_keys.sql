-- database

USE test;

-- employee instance table keys

ALTER TABLE titles
ADD FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE
;

-- ALTER salaries
-- ADD FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE
-- ;

SHOW WARNINGS;

flush /*!50503 binary */ logs;
