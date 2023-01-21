aws iot create-thing --thing-name "${1}"

CERT_ARN=$(aws iot create-keys-and-certificate \
    --set-as-active \
    --certificate-pem-outfile "${1}.cert.pem" \
    --public-key-outfile "${1}.public.key" \
    --private-key-outfile "${1}.private.key" \
    --query "certificateArn" \
    --output text)

cat > policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iot:Connect"
            ],
            "Resource": [
                "arn:aws:iot:${3}:${2}:client/${iot:Connection.Thing.ThingName}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:Publish"
            ],
            "Resource": [
                "arn:aws:iot:${3}:${2}:topic/example/${iot:Connection.Thing.Name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:Subscribe"
            ],
            "Resource": [
                "arn:aws:iot:${3}:${2}:topicfilter/example/${4}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iot:Receive"
            ],
            "Resource": [
                "arn:aws:iot:${3}:${2}:topic/example/${4}"
            ]
        }
    ]
}
EOF

aws iot create-policy \
    --policy-name "${1}" \
    --policy-document file://policy.json

aws iot attach-policy \
    --policy-name "${1}" \
    --target "${CERT_ARN}"

aws iot attach-thing-principal \
    --thing-name "${1}" \
    --principal "${CERT_ARN}"

rm policy.json
