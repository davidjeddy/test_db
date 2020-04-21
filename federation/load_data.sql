USE test;

SELECT 'LOADING departments' as 'INFO';
source ../dumps/load_departments.dump ;
SELECT 'LOADING employees' as 'INFO';
source ../dumps/load_employees.dump ;
SELECT 'LOADING dept_emp' as 'INFO';
source ../dumps/load_dept_emp.dump ;
SELECT 'LOADING dept_manager' as 'INFO';
source ../dumps/load_dept_manager.dump ;
SELECT 'LOADING titles' as 'INFO';
source ../dumps/load_titles.dump ;
SELECT 'LOADING salaries' as 'INFO';
source ../dumps/load_salaries1.dump ;
source ../dumps/load_salaries2.dump ;
source ../dumps/load_salaries3.dump ;

source ../libs/show_elapsed.sql ;

SHOW WARNINGS;

flush /*!50503 binary */ logs;
