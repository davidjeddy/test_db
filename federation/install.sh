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

# install schemas, enable federation: department <-> employee via linking the department_0 and employee_0 instances

echo "Creating federation SQL with credentials..."

echo "...creating department federation configuration for the employee member..."
cp -f ./src/department_create_server.sql ./department_create_server.sql
sed  -i "s/EMPLOYEE_PASS/${pass}/" ./department_create_server.sql
sed  -i "s/EMPLOYEE_USER/${user}/" ./department_create_server.sql
sed  -i "s/EMPLOYEE_HOST/${department_private_ip}/" ./department_create_server.sql

echo "...creating employee federation configuration for the department member..."
cp -f ./src/employee_create_server.sql ./employee_create_server.sql
sed  -i "s/DEPARTMENT_PASS/${pass}/" ./employee_create_server.sql
sed  -i "s/DEPARTMENT_USER/${user}/" ./employee_create_server.sql
sed  -i "s/DEPARTMENT_HOST/${employee_private_ip}/" ./employee_create_server.sql

echo "Applying SQL schema to each member of the federated cluster..."

echo "- Creating schemas..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_tables.sql
mysql -h ${employee_public_ip}   -u ${user} -p${pass} < ./employee_tables.sql

echo "- Creating federated servers and tables..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_create_server.sql
mysql -h ${employee_public_ip}   -u ${user} -p${pass} < ./employee_create_server.sql
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_federated_tables.sql
mysql -h ${employee_public_ip}   -u ${user} -p${pass} < ./employee_federated_tables.sql

echo "- Apply department views..."
mysql -h ${department_public_ip} -u ${user} -p${pass} < ./department_views.sql

echo "- Checking configuration..."
 mysql -h ${department_public_ip} -u ${user} -p${pass} -e "SELECT Server_name, Host, Db, Username, Port, Socket, Wrapper, Owner FROM mysql.servers;"

# echo "- Creating employee resources in department instance..."
# mysql -h ${department_public_ip} -u ${user} -p${pass} < ./employee_create_server.sql

# mysql -h ${department_public_ip} -u ${user} -p${pass} < ./referance_schemas.sql

# echo "- Creating department schema..."
# mysql -h ${department_public_ip} -u ${user} -p${pass} < ./level3.sql

# echo "- Creating department resources in employee instance..."
# mysql -h ${employee_public_ip} -u ${user} -p${pass} < ./department_create_server.sql
# mysql -h ${department_public_ip} -u ${user} -p${pass} -e "SELECT Server_name, Host, Db, Username, Port, Socket, Wrapper, Owner FROM mysql.servers;"
# mysql -h ${employee_public_ip} -u ${user} -p${pass} < ./department_schemas.sql

echo "...done."
