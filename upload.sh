#!/bin/bash

file_name=$1
to_path=$2
alist_url=$3
user_name=$4
password=$5

urlencode() {
    local string="$1"
    local strlen=${#string}
    local encoded=""
    local pos c o
    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [a-zA-Z0-9.~_-]) o="$c" ;;
            *) printf -v o '%%%02X' "'$c" ;;
        esac
        encoded+="$o"
    done
    echo "$encoded"
}


password="$(echo -n "$password-https://github.com/alist-org/alist" | sha256sum | awk '{print $1}')"
responseCode=$(curl --location --request POST "$alist_url/api/auth/login/hash" \
--header 'User-Agent: Apifox/1.0.0 (https://apifox.com)' \
--header 'Content-Type: application/json' \
--data-raw '{
    "username": "'$user_name'",
    "password": "'$password'"
    }')
codeRes=$(echo "$responseCode"|jq '.code')
authCode=$(echo "$responseCode"|jq '.data.token')
authCode=$(echo "$authCode" | tr -d '"')
encoded=$(urlencode "$to_path")
fileLength=$(wc -c < $file_name)
if [[ "$codeRes" -eq 200 ]] ; then
    echo "Logged in,and uploading..."
     uploadRes=$(curl --location --request PUT "$alist_url/api/fs/put" \
        --header "Authorization: $authCode" \
        --header "Content-Length: $fileLength" \
        --header "File-Path:$encoded" \
        --header "As-Task=false" \
        --header "User-Agent: Apifox/1.0.0 (https://apifox.com)"   \
        --header "Content-Type:application/octet-stream"  \
        --data-binary "@$file_name" )
    codeRes=$(echo "$uploadRes"|jq '.code')
        if [[ "$codeRes" -eq 200 ]] ; then
            echo "Upload completed"
         else
        echo "Upload failed"
        echo "$uploadRes"
        fi
else
    echo "Login failed"
    echo "$responseCode"
fi
