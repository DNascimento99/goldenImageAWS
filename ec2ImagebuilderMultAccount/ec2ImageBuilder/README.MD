aws cloudformation create-stack \
    --stack-name Ec2ImageBuilderForLambdaInvoke \
    --template-body file://template.yaml \
    --parameters file://parameters.json \
    --region sa-east-1 \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

aws s3 cp executebash/ s3://bp-arquive-bash-for-recipe-imagebuilder-dev --recursive
