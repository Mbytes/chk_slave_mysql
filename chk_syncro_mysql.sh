#!/bin/bash
#

#Control para ver MySql Sincronizados

#Extraemos ruta donde se ejecuta y cargamos Variables
CMD=$(echo $0 | awk -F/ '{print $NF}')
RUTA=$(echo $0 | sed "s/\/${CMD}//")

#Cargamos entorno variables
. ${RUTA}/VARS.sh

#Sentencia
SQL="select count(*) from word_lang;"

#Extraemos ruta donde se ejecuta y cargamos Variales
CMD=$(echo $0 | awk -F/ '{print $NF}')
RUTA=$(echo $0 | sed "s/\/${CMD}//")


#Lista Hosts
SERVERS=${RUTA}/chk_syncro_mysql.txt

#Lista SQL
SQLCHK=${RUTA}/chk_syncro_mysql.sql

#Temporales
SLAVETMP=/tmp/slaves.log

#Ejecutamos cada Test 
function TestSQL {

#Master
MASTER=$(grep "^MASTER" ${SERVERS} | awk -F: '{print $2}')

VALMASTER=$(echo "$1" | mysql -N -h${MASTER} -u${USER} -p${PWD} ${DB})

#Datos MASTER
echo "$1"
echo "MASTER ${VALMASTER}"


#Listado esclavos
grep SLAVE ${SERVERS} | grep -v "^#"  > ${SLAVETMP}

#Bucle lectura SERVIDORES
while read  LINEA
do
  SLAVE=$(echo ${LINEA} | awk -F: '{print $2}')
  SERSLAVE=$(echo ${LINEA} | awk -F: '{print $1}')
    
  VALSLAVE=$(echo "$1" | mysql -N -h${SLAVE} -u${USER} -p${PWD} ${DB} | awk '{gsub(/^ +| +$/,"")}1')

  if test ${VALMASTER} -eq ${VALSLAVE}
  then
    ERROR="OK "
  else
    ERROR="KO "
  fi
  
  printf "%8s %17s %5s = %12s \n" ${SERSLAVE} ${SLAVE}  ${ERROR} ${VALSLAVE}
  
done < ${SLAVETMP}

} #EndFunction


#Bucle lectura sentencias SQL
while read  SQL
do
  #No es comentario
  echo ${SQL} | grep -q -v "^#"
  if test $? -eq 0
  then
    echo "<hr>"
    TestSQL  "${SQL}"
  fi
  
done < ${SQLCHK}


