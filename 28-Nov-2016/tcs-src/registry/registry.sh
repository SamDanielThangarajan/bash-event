#! /bin/bash

DB_FILE=${REGISTRY_SERVICE_DIRECTORY}/db

get_field() {
case "$2" in
0) echo $(echo $1 | awk -F: '{print $1}' ) ;;
1) echo $(echo $1 | awk -F: '{print $2}' ) ;;
2) echo $(echo $1 | awk -F: '{print $3}' ) ;;
*) echo ERROR ;;
esac
}

get_user_line() {
  for line in $(grep $1 $DB_FILE)
    do
      if [ $(get_field $line 0) == $1 ]
         then
           echo $line
      fi
  done
}

add_user() {
  #echo this is add_user $1 $2
  if [ ! -z "$(get_user_line $1)" ]
  then
    echo ERROR_USER_EXISTS
  else
    echo "$1:$2" >> $DB_FILE
    echo OK
  fi
}

check_exists_user() {
  #echo this is check_exists_user $1
  if [ ! -z "$(get_user_line $1)" ]
  then
    echo OK
  else
    echo ERROR_NO_USER
  fi
}

authenticate_user() {
  #echo this is authenticate_user $1 $2
  if [ ! -z "$(get_user_line $1)" ]
  then
    passwd=$(get_field $(get_user_line $1) 1)
    #echo "p:${passwd} 2:$2"
    if [ $passwd == $2 ]
    then
       echo OK
    else
       echo ERROR_WRONG_PASSWORD
    fi
  else
    echo ERROR_NO_USER
  fi
}

list_users() {
  #echo this is list_users.
  for line in $(cat $DB_FILE)
  do
    echo $(get_field $line 0)
  done 
}

get_rep_name() {
  req_base=$(basename $1)
  rep_name=$(echo $req_base | sed s/request_/reply_/)
  echo $rep_name
}

process_req_file() {

cmd_line=$(cat $1 | head -1)
#cmd=$(echo $cmd_line | awk -F: '{print $1}' )
cmd=$(get_field $cmd_line 0)
#echo this is $cmd .

case "$cmd" in
ADD_USER) reply=$(add_user $(get_field $cmd_line 1) $(get_field $cmd_line 2)) ;;
CHECK_USER) reply=$(check_exists_user $(get_field $cmd_line 1)) ;;
AUTH_USER) reply=$(authenticate_user $(get_field $cmd_line 1) $(get_field $cmd_line 2)) ;;
LIST_USERS) reply="$(list_users)" ;;
*) echo ERROR ;;
esac

rep_file="$(dirname $1)/$(get_rep_name $1)"

#echo "|${reply}|${rep_file}|"
echo "${reply}" > ${rep_file}

$(rm $1)
}

listen() {
while true
do
for req_file in $(ls ${REGISTRY_SERVICE_DIRECTORY}/request_* 2>/dev/null)
  do
     process_req_file ${req_file}
  done
done
}

touch $DB_FILE
listen
