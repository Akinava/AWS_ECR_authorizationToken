#!/bin/bash

#================================================================
#-
#-    version         0.0.1
#-    author          Akinava © 2020
#-    email           akinava@gmail.com
#-    github          https://github.com/Akinava/AWS_ECR_authorizationToken
#-
#================================================================
#
# required tools:
# curl sed openssl base64 date
#
#================================================================

key=$AWS_ACCESS_KEY_ID
secret=$AWS_SECRET_ACCESS_KEY


if [ -z "$region" ]
then
    region="us-east-1"
fi

if [ -z "$key" ]
then
    echo "Error: variable AWS_ACCESS_KEY_ID is not set"
fi

if [ -z "$secret" ]
then
    echo "Error: variable AWS_SECRET_ACCESS_KEY is not set"
fi

if [ -z "$key" ] || [ -z "$secret" ]
then
    exit 1
fi


time_now=$(date -u +%Y%m%dT%H%M%SZ)
day_now=$(date -u +%Y%m%d)


data="{}"
data_hash=$(echo -n $data | openssl dgst -sha256 | sed "s/^.* //")
cr="POST\n/\n\ncontent-type:application/x-amz-json-1.1\nhost:api.ecr.${region}.amazonaws.com\nx-amz-date:${time_now}\nx-amz-target:AmazonEC2ContainerRegistry_V20150921.GetAuthorizationToken\n\ncontent-type;host;x-amz-date;x-amz-target\n${data_hash}"
cr_hash=$(echo -ne $cr | openssl dgst -sha256 | sed "s/^.* //")
string_to_sign="AWS4-HMAC-SHA256\n${time_now}\n${day_now}/${region}/ecr/aws4_request\n${cr_hash}"
k_date=$(echo -n $day_now | openssl dgst -sha256 -hmac "AWS4${secret}" | sed "s/^.* //")
k_region=$(echo -n $region | openssl dgst -sha256 -mac HMAC -macopt hexkey:${k_date} | sed "s/^.* //")
k_service=$(echo -n "ecr" | openssl dgst -sha256 -mac HMAC -macopt hexkey:${k_region} | sed "s/^.* //")
k_signing=$(echo -n "aws4_request" | openssl dgst -sha256 -mac HMAC -macopt hexkey:${k_service} | sed "s/^.* //")
signature=$(echo -ne $string_to_sign | openssl dgst -sha256 -mac HMAC -macopt hexkey:${k_signing} | sed "s/^.* //")


responce=$(curl -s --data ${data} \
    -H "X-Amz-Target: AmazonEC2ContainerRegistry_V20150921.GetAuthorizationToken" \
    -H "Content-Type: application/x-amz-json-1.1" \
    -H "X-Amz-Date: ${time_now}" \
    -H "Authorization: AWS4-HMAC-SHA256 Credential=${key}/${day_now}/${region}/ecr/aws4_request, SignedHeaders=content-type;host;x-amz-date;x-amz-target, Signature=${signature}" \
    -A "Botocore/1.17.22" \
    -X POST https://api.ecr.us-east-1.amazonaws.com/)


authorizationToken=$(echo $responce | sed "s/^.*authorizationToken\":\"\(.*\)\",.*$/\1/")
echo $authorizationToken | base64 -d | sed "s/AWS://"


exit 0
