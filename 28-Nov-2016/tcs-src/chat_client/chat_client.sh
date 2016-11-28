#!/bin/bash

function get_unique_id
{
echo "REQUEST" >> $UNIQUE_ID_SERVICE_DIRECTORY/request_$CHAT_CLIENT_ID

while true
do
  if [[ -f $UNIQUE_ID_SERVICE_DIRECTORY/response_$CHAT_CLIENT_ID ]]; then
      unique_id=`cat $UNIQUE_ID_SERVICE_DIRECTORY/response_$CHAT_CLIENT_ID` 
      rm -rf $UNIQUE_ID_SERVICE_DIRECTORY/response_$CHAT_CLIENT_ID
  fi
done
return unique_id
}

function user_login
{
     echo "Please enter the user name"
     read ul_user_name
     echo "Pleass enter the password"
     read -s ul_password
     get_unique_id 
     uid=$?
     echo "AUTH_USER:$ul_user_name:$ul_password" >> $REGISTRY_SERVICE_DIRECTORY/request_$uid
     
     while true
     do
         if [[  -f $REGISTRY_SERVICE_DIRECTORY/reply_$uid ]]; then
              result=`cat $REGISTRY_SERVICE_DIRECTORY/reply_$uid`
              rm -rf $REGISTRY_SERVICE_DIRECTORY/reply_$uid
              if [[ $result = "OK" ]]; then
                  return 0
              else:
                  return 1
              fi
              
         fi
     done
}

function user_sign_up()
{
 echo "Enter username and password"
 echo "Enter username"
 read username
 echo "Enter password"
 read password
 echo "$username $password"
 get_unique_id
 uid=$?
 echo "${REGISTRY_SERVICE_DIRECTORY}"
 echo "ADD_USER:$username:$password" > ${REGISTRY_SERVICE_DIRECTORY}/request_$uid

 while true
     do
         if [[  -f $REGISTRY_SERVICE_DIRECTORY/reply_$uid ]]; then
              result=`cat $REGISTRY_SERVICE_DIRECTORY/reply_$uid`
              if [[ $result == "OK" ]]; then
                  echo "User is successfully created"
                  break
              elif [[ $result == "ERROR_USER_EXISTS" ]]; then
                  echo "User already exists"
                  exit 1
              fi
         fi
    done
 
}


echo "List of options below"
echo "1.SIGN_UP"
echo "2.LOGIN"

echo "Select one of the options mentioned above"
read option
case $option in
1)
   user_sign_up
  ;;
2)
   user_login
  ;;
*)
  echo "Please enter a valid option"
 ;;
esac

