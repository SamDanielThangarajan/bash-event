#!/bin/bash

#source ../../setup.sh

#MESSAGE_FILE="/home/eabzmod/work/fun/chatsystem/bash-event/28-Nov-2016/tcs_working_dir/messaging_service/00000-send" 
function parse_message() {
    TITLE_LINE=`grep title $1`
    TITLE=$(echo `grep Title $1` | cut -f2 -d:)
    SENDER=$(echo `grep FROM $1` | cut -f2 -d:)
    RECEIVER=$(echo `grep TO $1` | cut -f2 -d:)
    MSG=$(echo `grep MSG $1` | cut -f2 -d:)
}


function verify_user() {
    # send the rquest
    CHECK_USER_REQ="CHECK_USER:$1"
    FILE_SUFFIX=`uuidgen`
    REQ_FILE_NAME="request_$FILE_SUFFIX"
    echo $CHECK_USER_REQ > "$REGISTRY_SERVICE_DIRECTORY/$REQ_FILE_NAME"

    # read the request
    sleep 1
    REP_FILE_NAME="reply_$FILE_SUFFIX"
    echo "OK" > "$REGISTRY_SERVICE_DIRECTORY/$REP_FILE_NAME"
    if [[ `cat "$REGISTRY_SERVICE_DIRECTORY/$REP_FILE_NAME"` == *"OK"* ]]
    then
	return 0
    fi
    return 1
}


function deliver(){
    mkdir -p "$MAIL_BOX_DIRECTORY/$RECEIVER"
    DELIVERY_FILE="$MAIL_BOX_DIRECTORY/$RECEIVER/$SENDER-$TITLE"
    echo "$MSG" > $DELIVERY_FILE
    return $?
}


function return_response(){
    MESSAGE_REPLY_FILE=`echo "$MESSAGE_FILE" | sed -r 's/send/response/g'`
    echo $1 > $MESSAGE_REPLY_FILE
}



function file_listener(){
    DIR_TO_CHECK=$MESSAGING_SERVICE_DIRECTORY
    SENT_MSGs_DIR="${MESSAGING_SERVICE_DIRECTORY}/sent-msgs/"
    echo $SENT_MSGs_DIR
    mkdir -p $SENT_MSGs_DIR

    echo

    while true; do
	#echo "check the new msges"

	for new_file in `ls ${MESSAGING_SERVICE_DIRECTORY}/*`
	do
	    echo $new_file
	    if [ $(basename $new_file) = "mail-box" ]
	    then
		echo $new_file
	    elif [ $(basename $new_file) = *"response"* ]
	    then
		echo $new_file
	    elif [ ! $(basename $new_file) = "sent-msgs" ]
	    then 
		# mv $MESSAGING_SERVICE_DIRECTORY$new_file $SENT_MSGs_DIR$new_file
		# send_send $SENT_MSGs_DIR$new_file
		sent_file=$(basename $new_file)
		#echo "${SENT_MSGs_DIR}${sent_file}"
		MESSAGE_FILE=${SENT_MSGs_DIR}${sent_file}
		mv $new_file ${SENT_MSGs_DIR}${sent_file}
		####################################
		#		parse_message $MESSAGE_FILE
		TITLE_LINE=`grep title $MESSAGE_FILE`
		TITLE=$(echo `grep Title $MESSAGE_FILE` | cut -f2 -d:)
		SENDER=$(echo `grep FROM $MESSAGE_FILE` | cut -f2 -d:)
		RECEIVER=$(echo `grep TO $MESSAGE_FILE` | cut -f2 -d:)
		MSG=$(echo `grep MSG $MESSAGE_FILE` | cut -f2 -d:)
		
		echo "here"
		echo $MESSAGE_FILE
		verify_user $RECEIVER
		if [[ $? -eq 0 ]]
		then
		    deliver
		    return_response $?
		fi
		##################################
	    fi
	done
	sleep 3
    done
}


file_listener

# echo $TITLE
# echo $SENDER
# echo $RECEIVER
# echo $MSG
