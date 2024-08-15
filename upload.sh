#!/bin/bash
# 上传文件到服务器
#lastP="-https://github.com/alist-org/alist"
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


passwd="$(echo -n "180612-https://github.com/alist-org/alist" | sha256sum | awk '{print $1}')"
# 获取token
responseCode=$(curl --location --request POST 'http://w2eboy.tpddns.cn:8888/api/auth/login/hash' \
--header 'User-Agent: Apifox/1.0.0 (https://apifox.com)' \
--header 'Content-Type: application/json' \
--data-raw '{
    "username": "ww",
    "password": "'$passwd'"
}')
codeRes=$(echo "$responseCode"|jq '.code')
authCode=$(echo "$responseCode"|jq '.data.token')
authCode=$(echo "$authCode" | tr -d '"')
encoded=$(urlencode "$2")
echo $authCode
echo "------------------------------"
echo $authCode
fileLength=$(wc -c < $1)
# 判断是否登录成功
if [[ "$codeRes" -eq 200 ]] ; then
    echo "登录成功"
     uploadRes=$(curl --location --request PUT 'http://w2eboy.tpddns.cn:8888/api/fs/put' \
        --header "Authorization: $authCode" \
        --header "Content-Length: $fileLength" \
        --header "File-Path:$encoded" \
        --header "As-Task=false" \
        --header "User-Agent: Apifox/1.0.0 (https://apifox.com)"   \
        --header "Content-Type:application/octet-stream"  \
        --data-binary "@$1" )
    codeRes=$(echo "$uploadRes"|jq '.code')
        if [[ "$codeRes" -eq 200 ]] ; then
            echo "上传成功"
         else
        echo "上传失败"
        fi
else
    echo "登录失败"
fi