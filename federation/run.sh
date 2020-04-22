#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

# environmental sanity
DATE_STAMP=`date +"%Y%m%d%H%M"`
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# support notice
echo "This script works on Ubuntu 18.04; it may work on others but is un-tested."

user=${user:-""}
pass=${pass:-""}

department_private_ip=${department_private_ip:-""}
department_public_ip=${department_public_ip:-""}

employee_private_ip=${employee_private_ip:-""}
employee_public_ip=${employee_public_ip:-""} 

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        echo $1 $2
   fi
  shift
done

echo "Creating federation SQL with credentials..."

echo "Enabled storage engines..."
mysql -h ${employee_public_ip} -u ${user} -p${pass} -e "select * from information_schema.engines;"

echo "...creating department federation configuration for the employee member..."
cp -f ./src/department_create_server.sql ./department_create_server.sql
sed  -i "s/EMPLOYEE_PASS/${pass}/" ./department_create_server.sql
sed  -i "s/EMPLOYEE_USER/${user}/" ./department_create_server.sql
sed  -i "s/EMPLOYEE_HOST/${employee_private_ip}/" ./department_create_server.sql

echo "...creating employee federation configuration for the department member..."
cp -f ./src/employee_create_server.sql ./employee_create_server.sql
sed  -i "s/DEPARTMENT_PASS/${pass}/" ./employee_create_server.sql
sed  -i "s/DEPARTMENT_USER/${user}/" ./employee_create_server.sql
sed  -i "s/DEPARTMENT_HOST/${department_private_ip}/" ./employee_create_server.sql

echo "Applying SQL schema to each member of the federated cluster..."

echo "- Creating schemas..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_tables.sql
mysql -h ${employee_public_ip}   -u ${user} -p${pass} < ./employee_tables.sql

echo "- Creating federated servers for department member..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_create_server.sql
mysql -h ${department_public_ip} -u ${user} -p${pass} -e "SELECT Server_name, Host, Db, Username, Port, Socket, Wrapper, Owner FROM mysql.servers;"

echo "- Creating federated servers for employee member..."
mysql -h ${employee_public_ip}   -u ${user} -p${pass} < ./employee_create_server.sql
mysql -h ${employee_public_ip}   -u ${user} -p${pass} -e "SELECT Server_name, Host, Db, Username, Port, Socket, Wrapper, Owner FROM mysql.servers;"

echo "- Creating federated tables..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_federated_tables.sql
mysql -h ${employee_public_ip}   -u ${user} -p${pass} < ./employee_federated_tables.sql

echo "- Apply department views..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_views.sql

echo "- Importing foreign key configs..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_foreign_keys.sql
mysql -h ${employee_public_ip} -u ${user} -p${pass} < ./employee_foreign_keys.sql

echo "- Importing test dataset..."
mysql -h ${employee_public_ip} -u ${user} -p${pass} < ./load_data.sql

echo "- CRC validating imported data..."
mysql -h ${employee_public_ip} -u ${user} -p${pass} < ./test_employees_md5.sql
mysql -h ${employee_public_ip} -u ${user} -p${pass} < ./test_employees_sha.sql

echo "Executing load testing commands..."

# source https://stackoverflow.com/questions/4219199/can-i-use-mysqlslap-on-an-existing-database
# source https://rmohan.com/?p=2239
# source https://dba.stackexchange.com/questions/41645/mysqlslap-chokes-on-strings-that-contain-delimiter
echo "- md5 against department instance..."
mysqlslap \
--create-schema=test \
--delimiter=";" \
--host=${department_public_ip} \
--no-drop \
--password=${pass} \
--query=./test_employees_md5.sql \
--user=${user} \
--verbose

echo "- md5 against employee instance..."
mysqlslap \
--create-schema=test \
--delimiter=";" \
--host=${employee_public_ip} \
--no-drop \
--password=${pass} \
--query=./test_employees_md5.sql \
--user=${user} \
--verbose

echo "- 10 iteration of md5 against department instance *10..."
mysqlslap \
--create-schema=test \
--delimiter=";" \
--host=${department_public_ip} \
--iterations=10 \
--no-drop \
--password=${pass} \
--query=./test_employees_md5.sql \
--user=${user} \
--verbose

echo "- 10 iteration md5 against employee instance *10..."
mysqlslap \
--create-schema=test \
--delimiter=";" \
--host=${employee_public_ip} \
--iterations=10 \
--no-drop \
--password=${pass} \
--query=./test_employees_md5.sql \
--user=${user} \
--verbose

# echo "...done."
