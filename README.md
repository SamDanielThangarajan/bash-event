# bash-event

Repository for bash-event

## 1. Terminal Chat System
This event is to build a chat system (A poor man's IRC)... A basic chat system
where each team will develop portion of it using services...

### 1.1 Ambition
To build a terminal based chat system with only bash scripts. Each team will develop small services using bash scripts which when integrated will produce a basic chatting functionality. Files acts as medium of communication between services.

Each service will receive files as inputs and produce the files as its output.  

For example, to request a service to registry service create a file as request_001 and the response would be available as response_001.Every service will have a variable name **${< service_name >_SERVICE_DIRECTORY}** where all the requests and response files for that service will created and consumed.

Each team should decide the input and output format for the files that will be processed by the service and it will be shared to other teams who needs your service.

### 1.2 Sample Communication:
To request a service:
1. Contact the service provider(team) for the request file name format, response file name format and the format of file contents.
2. Create the request file in the **${< service_name >_SERVICE_DIRECTORY}** and monitor for a response in the same directory.
Note: Suffix a unique identifier in the file name to identify the request and response.

### 1.3 Sprint 0
All the teams are expected to first finalize their input and output formats.

Fill In the Format:
1. Request file name format(s):
2, Response file name format(s):
3. Request Content format(s):
4. Response Content format(s):

### Common Requirements
#### 1.4.1 Service Identifiers:
Each service will have a service identifier to identify itself. Services are encouraged to have these identifiers part of the file name format when requesting service from other service providers.  

Variable **${< service_name >_IDENTIFIER}** will be provided and will contain the service identifier assigned to each service.
###### Example:
To request a unique id:   
Create a file **request_${service_identifier}** in **${UNIQUE_ID_SERVICE_DIRECTORY}**, Here ${service_identifier} will help to identify the corresponding response to this request.

#### 1.4.2 Status Report:
In addition to printing debug messages to service specific files, the file path available in ${STATUS_REPORT_FILE} should be updated by all the services with INFO|WARNING|ERROR messages.
###### Example:
echo “[< service_name >.< info|warn|error >] <message>” >> ${STATUS_REPORT_FILE}


#### 1.4.3 Services Description
##### 1.4.3.1 Registry Service
This service is used to manage users and their passwords which will be used when checking for user existence, authenticating the user and registering the user and their passwords. The details are maintained in a internal database(perhaps plain text). **${REGISTRY_SERVICE_DIRECTORY}** is defined and all requests files created in this directory will be served accordingly.

__List of Operations__
1. ADD_USER
2. CHECK_USER_EXISTS  
3. AUTHENTICATE_USER  
4. LIST_USERS

###### Example Input Format:
ADD_USER:username:password  
CHECK_USER:username   
LIST_USERS  
###### Example Outputs:
OK  
ERROR_USER_EXISTS  
ERROR_NO_USER


##### 1.4.3.2 Messaging Service
This is the core service of this chat system. For each request this service will check the existence of each parties involved and deliver the content in the destination user's mail box.
**${MESSAGING_SERVICE_DIRECTORY}** is defined and all messaging requests should land here. The messaging service will publish the **${MAIL_BOX_DIRECTORY}** variable which will have the mailboxes for users where they can fetch the incoming messages.

__List of Operations__  
1. SEND_MESSAGE

###### Sample mail box file and directories :
${MAIL_BOX_DIRECTORY}/<username>/msg1  
${MAIL_BOX_DIRECTORY}/<username>/msg2  

###### Sample Input file Format:
SEND MESSAGE  
FROM:  
TO:  
MSG:  

##### 1.4.3.3 Room Service:
This service adds chat room functionality. The service will monitor the directory in the variable **${ROOM_SERVICE_DIRECTORY}**.   
This Service will create separate directories for each room and maintain a main chat file in its room directory. For every POST_MESSAGE action, the service will append the contents to the main chat message with the senders identity.

__List of Operations__  
1. ADD_ROOM
2. LIST_ROOM  
3. CHECK_ROOM_EXISTS  
4. POST_MESSAGE

###### Sample File and Directories
${ROOM_SERVICE_DIRECTORY}/request_001 #E.g., POST_MESSAGE to room “kista”
${ROOM_SERVICE_DIRECTORY}/request_002 #E.g., POST_MESSAGE to room “KI08”

${ROOM_SERVICE_DIRECTORY}/rooms/kista/main-chat-file
${ROOM_SERVICE_DIRECTORY}/rooms/KI08/main-chat-file


##### 1.4.3.4 Chat Client:
This is the application that will interact with users and speak with other services in the back-end. This can be a basic menu based application where users will be presented with the list of options to interact with the system. All basic operations are listed in the services design diagram.  
To start with chat client can have polling mechanism to retrieve the incoming messages and the chat room updates but it can be enhanced in the future.

__List of Operations__  
--User Management
1.  SIGN_UP
2.  LOGIN
3.  LIST_USERS  
-- Messaging  
4.  CHAT  
5.  SEND_MESSAGE  
6.  READ_MESSAGE  
-- Room
7.  CREATE_ROOM
8.  LIST_ROOM
9.  SEND_MESSAGE  
10. ENTER_ROOM  


##### 1.4.3.5 Unique Id Service *[optional]*:
This service is responsible for generating unique identifiers when requested. The returned identifiers will be used in the file names created by other services when requesting and responding to the service requests. ${UNIQUE_ID_SERVICE_DIRECTORY} is defined and any request in this directory will be responded with a unique number. This is to create a unique file name across the chat system.

Note:   
- Each service should make sure that they create a unique request file when accessing this service too. Ex: request_<service_id>_001, request_<service_id>_002.
- If a sequence number is used, then the service should save its state when going for a temporary shut down, So it can recover its previous sequence number when it restarts.

__List of Operations__   
1. REQUEST_ID

##### 1.4.3.6 Garbage Collector Service *[optional]*:
Since communication is happening via files, it is possible that we might end up in leaking files. A garbage collector service might come in handle in those situations. Any service should register itself with the garbage collector service with the following parameters,
**< Service_name >:Timeout:Path**  
Garbage collector will then look for all files in this path and if they exceed the timeout then this service will delete those files.

__List of Operations__  
1. REGISTER_SERVICE

##### 1.4.3.7 Back Up Service *[optional]*:
This service give the backup feature to the chat system and can be used to backup files and directories is the system. Any service should register itself with the backup service with the following parameters,  
###### Example:
**< Service_name >:BackupPeriod:< comma separated file list. >**

__List of Operations__  
1. REGISTER_SERVICE 
