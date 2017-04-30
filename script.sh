#!/usr/bin/env bash

###
# Prepare request
###
while read line ; do
  get=("${get[@]}" -H "$line")
done < getHeader.txt

while read line ; do
  post=("${post[@]}" -H "$line")
done < postHeader.txt

###
# Prepare variables
###
logged=0
code=0
userCount=0
logCount=0

###
# Prepare skeleton function
###
function getStack() {
  if [ "$2" ]
  then
    msg="$2"
    userCount=0
    logCount=0
    rm -f output.std
    rm -f output.err
  else
    msg="GET $1"
  fi

  printf "`date +[%d/%m/%y\ %H:%M:%S]` \e[1;34m$msg: \e[m"
  curl -L -v -i -s --request GET "${get[@]}" -b cookies.txt.hide -c cookies.txt.hide -e stackoverflow.com $1 >> output.std 2>> output.err
  code=$(cat output.err | grep "< HTTP/.*[0-9][0-9][0-9] " | tail -1 | sed -e 's~< HTTP/.*\([0-9][0-9][0-9]\).*$~\1~')

  local newUserCount=$(grep "malinator" output.std | wc -l)
  userCount=$((newUserCount-userCount))
  local newLogCount=$(grep "logout" output.std | wc -l)
  logCount=$((newLogCount-logCount))

  if [ $code -eq 200 ]
  then
    printf "\e[1;32mC[$code]\e[m "

    if [ $userCount -ge 3 ]
    then
      printf "\e[1;32mU[$userCount]\e[m "
    else
      printf "\e[31mU[$userCount]\e[m "
    fi

    if [ $logCount -ge 1 ]
    then
      echo -e "\e[1;32mL[$logCount]\e[m"
    else
      echo -e "\e[31mL[$logCount]\e[m"
    fi

    [ $userCount -ge 3 ] && [ $logCount -ge 1 ] && logged=1
  else
    echo -e "\e[31mC[$code] FAIL\e[m"
  fi

  userCount=$newUserCount
  logCount=$newLogCount
}

###
# Check log in
###
url="http://stackoverflow.com/"
getStack $url "CHECK LOGIN"
[ $code != 200 ] && exit 1

###
# Not logged in
###
if [ $logged = 0 ]
then
  rm -f cookies.txt.hide
  curl -v -i -s --request POST "${post[@]}" -d @body.txt.hide -b cookies.txt.hide -c cookies.txt.hide -e stackoverflow.com https://stackoverflow.com/users/login > output.std 2> output.err
  printf "`date +[%d/%m/%y\ %H:%M:%S]` \e[33mLOG IN: \e[m"
  if grep "< HTTP/.* 30" output.err > /dev/null
  then
    echo -e "\e[1;32mOK\e[m"
  else
    echo -e "\e[31mFAIL\e[m"
    exit 1
  fi

  url="http://stackoverflow.com/"
  getStack $url "CONFIRM LOGIN"
  [ $code != 200 ] && exit 1
  [ $logged = 0 ] && exit 1
fi

###
# After log in
###
if [ $((RANDOM%2)) -gt 0 ]
then	
  url="http://stackoverflow.com/questions/tagged/java"
  getStack $url
fi

i=$(((RANDOM%3)+2))
while  [ $i -ge 0 ]
do
  sleep $(((RANDOM%10)+5))
  url="http://stackoverflow.com/questions/$((RANDOM%3400))$((RANDOM%10000))"
  getStack $url

  ((i--))
done
exit 0
