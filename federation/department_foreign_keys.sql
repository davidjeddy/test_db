-- database

USE test;

-- department instance table keys

ALTER TABLE dept_manager
-- ADD FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
ADD FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE
;

ALTER TABLE dept_emp
-- ADD FOREIGN KEY (emp_no)  REFERENCES employees   (emp_no)  ON DELETE CASCADE,
ADD FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE
;

SHOW WARNINGS;

flush /*!50503 binary */ logs;

