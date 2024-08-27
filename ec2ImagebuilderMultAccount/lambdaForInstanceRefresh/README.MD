aws cloudformation create-stack \
    --stack-name InstanceRefreshForImageBuilder \
    --template-body file://template.yaml \
    --parameters file://parameters.json \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

aws cloudformation update-stack \
    --stack-name InstanceRefreshForImageBuilder \
    --template-body file://template.yaml \
    --parameters file://parameters.json \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND