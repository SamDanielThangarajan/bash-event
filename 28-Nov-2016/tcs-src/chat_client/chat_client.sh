#!/bin/bash

function get_unique_id
{
   echo "REQUEST" >> $UNIQUE_ID_SERVICE_DIRECTORY/request_$CHAT_CLIENT_ID

   while true
   do
      if [[ -f $UNIQUE_ID_SERVICE_DIRECTORY/response_$CHAT_CLIENT_ID ]]; then
         unique_id=`cat $UNIQUE_ID_SERVICE_DIRECTORY/response_$CHAT_CLIENT_ID` 
         rm -rf $UNIQUE_ID_SERVICE_DIRECTORY/response_$CHAT_CLIENT_ID
         break
      fi
   done
   return $unique_id
}

function user_login
{
   echo "Please enter the user name"
   read ul_user_name
   echo "Pleass enter the password"
   read -s ul_password
   get_unique_id
   uid=$?
   echo "request_$uid"
   echo "AUTH_USER:$ul_user_name:$ul_password" >> $REGISTRY_SERVICE_DIRECTORY/request_$uid

   echo "$REGISTRY_SERVICE_DIRECTORY/reply_$uid"
   while true
   do
      if [[  -f $REGISTRY_SERVICE_DIRECTORY/reply_$uid ]]; then
         result=`cat $REGISTRY_SERVICE_DIRECTORY/reply_$uid`
         rm -rf $REGISTRY_SERVICE_DIRECTORY/reply_$uid
         if [[ $result = "OK" ]]; then
            echo "return 0 : $result"
            USER_NAME=${ul_user_name}
            return 0
         else
            echo "return 1 : $result"
            return 1
         fi
      fi
   done
}

#Params
#Username to chat with
#Message
function send_message_to
{

   get_unique_id
   local uniq_id=$?.chatsrv

   cat >${MESSAGING_SERVICE_DIRECTORY}/${uniq_id}-send <<EOF
Title:title
FROM:${USER_NAME}
TO:${1}
MSG:${2}
EOF

}

function read_message_from
{
   count=1
   while :
   do
      for file in `ls -tr1 ${MAIL_BOX_DIRECTORY}/${USER_NAME}/${1}-* 2>/dev/null`
      do
         cat $file | sed "s/^/$1:/"
         cat $file | sed "s/^/$1:/" >> ${USER_NAME}_chatwith_${1}
         rm -rf $file
      done
      count=$(expr ${count} + 1)
      [[ ${count} -eq 3 ]] && break;
   done
}

function chat
{
   printf "Enter User to chat with :"
   read c_user

   touch ${USER_NAME}_chatwith_${c_user}

   echo "Type quit to end the chat session"
   while :
   do
      printf "${USER_NAME} :"
      read -t 10 _cw_txt
      if [[ $? -ne 0 ]];then
         read_message_from ${c_user}
         continue
      fi
      [[ ${_cw_txt} = "quit" ]] && break
      echo "${USER_NAME} : ${_cw_txt}" >> ${USER_NAME}_chatwith_${c_user}
      send_message_to ${c_user} "${_cw_txt}"
      read_message_from ${c_user}
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
         if [[ $result = "OK" ]]; then
            echo "User is successfully created"
            break
         elif [[ $result = "ERROR_USER_EXISTS" ]]; then
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
      user_login
      ;;
   2)
      user_login
      response=$?
      if [[ response -eq 0  ]]; then
         echo "Select one of the below options to start chat service"
         echo "1.CHAT"
         echo "2.SEND_MESSAGE"
         echo "3.READ_MESSAGE"
         read chat_option
         case $chat_option in
            1)
               chat
               ;;
            2)
               send_message
               ;;
            3)
               read_message
               ;;
         esac
      fi
esac

