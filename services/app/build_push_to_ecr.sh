if [ -z $1 ]; 
then
    echo 'Arg AWS Account id need it'
    exit 0
fi

if [ -z $2 ]; 
then
    echo 'Arg Region need it'
    exit 0
fi

ACCOUNT_ID=$1
REGION=$2
$(aws ecr get-login --no-include-email)
docker build -t app .
docker tag app:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/app:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/app:latest