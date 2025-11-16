cd `dirname $0`

fatal() {
    echo -e "\033[0;31merror: $1\033[0m"
    exit 1
}

APP_NAME=`bash ./scripts/get_sub_dir.sh apps`
echo APP_NAME=$APP_NAME

[ -z $APP_NAME ] && fatal "no app name!"

make APP_NAME=$APP_NAME
