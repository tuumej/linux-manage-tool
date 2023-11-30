#!/bin/bash
:<<'END'
@2023.11.28~ 
@Monitor Linux Server
@made by tuumej
@Index
1. SYS Info Check
- kernel version
- user
- hostname
- os version

2. Access Info Check
- user count
- access ip
- access time

2. Network Info Check
- private/public ip
- route ip

3. Disk Info Check
- disk list
- usage

4. Process Info Check
- application process
- zombie process

5. Crontab Info Check
- crontab list

6. Security Info Check
- root access y/n
- 

99. Execute Area
END

### 1. SYS Info Check ###
sys_info() {
  # hyper threading check #
  # ㄴ cat /proc/cpuinfo | egrep 'siblings|cpu cores' | head -2
  # ㄴ siblings = cpu cores * 2 => hyber threading on

  HOSTNM=$(hostname)
  CURDT=$(date +%Y.%m.%d' '%T)
  #SYS=$(uname -a)
  UPTIME=$(awk '{print int($1)}' /proc/uptime)
  UPDAY=$((UPTIME / 86400))
  UPHOUR=$((UPTIME / 3600))
  UPMIN=$(((UPTIME % 3600) / 60))
  KERNEL=$(uname -s -r)
  OS=$(cat /etc/*release | grep PRETTY_NAME | cut -d "=" -f2)
  LOAD=$(cat /proc/loadavg | awk '{print $1}')
  MEMTOTAL=$(free | grep -i mem | awk '{print $2}')
  MEMTOTALSIZE=$((MEMTOTAL/1000000))
  MEMUSED=$(free | grep -i mem | awk '{print $3}')
  MEMUSERPER=$((100*MEMUSED/MEMTOTAL))
  #CPUPROCESSOR=$(cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l) # physical cpu count
  CPUCORE=$(grep "cpu cores" /proc/cpuinfo | sed -n 1p | awk '{print $4}')
  CPUUSED=$(top -b -n1 | grep -Po '[0-9.]+ id' | awk '{print 100-$1}' | sed -n 1p)
  # USER INFO : w | grep pts | awk '{print $1" "$2" "$3" "$5" "$8}'

  line_sort "title" "SYSTEM INFO"
  line_sort "content" "CURRENT DATE" "${CURDT}"
  line_sort "content" "UPTIME" "${UPHOUR}h ${UPMIN}m ${UPDAY}days"
  line_sort "content" "HOSTNAME" "${HOSTNM}"
  line_sort "content" "KERNEL" "${KERNEL}"
  line_sort "content" "SYSTEM LOAD" "${LOAD}"
  line_sort "content" "CPU(vcpu/used)" "${CPUCORE} cores, ${CPUUSED} %%"
  line_sort "content" "MEMORY(size/used)" "${MEMTOTALSIZE} GB, ${MEMUSERPER} %%"
  line_sort "content" "DISK USED"
  #echo -e "SYSTEM : ${SYS}"

}

access_info() {
  USERCNT=$(w | grep users | awk '{print $4}')
  #USERIP=$(w | awk '{print $1 $3 $4 $5 $6}')
  line_sort "title" "ACCESS INFO"
  line_sort "content" "ACCESS COUNT" "${USERCNT} users"
 # printf "${USERIP}"
}

### 2. Network Info Check ###
:<<'END'
# curl ident.me
# curl ifconfig.me
# curl icanhazip.com
# curl ipecho.net/plain
# curl ipv4.icanhazip.com
END

net_info() {
  line_sort "title" "NETWORK INFO"

  PUBIP=$(curl -s ipv4.icanhazip.com)
  RRIIP="123123"

  #echo -e "\e[33m[ IP Info ]\e[0m"
  line_sort "content" "Public IP" ${PUBIP}
  line_sort "content" "Private IP" ${RRIIP}
  
  #vNetInfo=($(ip route | awk '{print $3"@"$1}'))
  vNetInfo=($(ip route | awk '{print $3"@"$1}'))

  line_sort "subtitle" "GR" "ROUTE"
  for i in ${vNetInfo[@]}
  do
    t=$(echo $i | tr "@" " ")
    line_sort "content" ${t}
  done

}

### 3. Disk Info Check ###
disk_info() {
  line_sort "title" "DISK INFO"

}

### 4. Process Info Check ###
ps_info() {

  # zombie ps count
  ZBCNT=$(ps -ef | grep defunct | grep -v grep | wc -l)

  line_sort "title" "PROCESS INFO"
  line_sort "subtitle" "GR" "NORMAL"
  line_sort "subtitle" "RED" "ZOMBIE"
  line_sort "content" "COUNT" "${ZBCNT}"

  if [ ${ZBCNT} -gt 0 ]; then
    echo -e "--ZOMBIE PROCESS LIST--"
    ps -ef | grep defunct | grep -v grep
    echo -e "-----------------------"
  fi

}

### 98. ETC
line_sort() {
  :<<'END'
   # Description
   # - 출력물을 정렬하기 위한 함수
   # 정렬구분(PARAM) : title, subtitle, content
   # title parameter    : $1-정렬구분 $2-제목
   # subtitle parameter : $1-정렬구분 $2-표시색상 $2-부제목
   # content parameter    : $1-정렬구분 $2-출력할 KEY $3-출력할 VALUE
  END

  PARAM=$1
  CASE=(title subtitle content)

  if [ ${PARAM} == ${CASE[0]} ]
  then
    TITLE=$2
    STR="======================="
    while [ ${#TITLE} -lt 12 ]
    do
      TITLE+=" "
    done
    printf "\e[33m${STR}[ ${TITLE} ]${STR}\e[0m\n"
  fi
  
  if [ ${PARAM} == ${CASE[1]} ] 
  then
    COLOR=$2
    TITLE=$3
    STR="======================="
    while [ ${#TITLE} -lt 8 ]
    do
      TITLE+=" "
    done
    if [ ${COLOR} == "RED" ]
    then
      printf "\e[31m  [ ${TITLE} ] \e[0m\n"
    else 
      printf "\e[32m  [ ${TITLE} ] \e[0m\n"
    fi
  fi

  if [ ${PARAM} == ${CASE[2]} ] 
  then
    KEY=$2
    VALUE=$3
    # string length equal 100
    while [ ${#KEY} -lt 25 ]
    do
      KEY+=" "
    done
    printf "  ${KEY}: ${VALUE}\n"
  fi
}

### 99. Excute Area ###
main() {
  clear
  type=(sys access net disk ps)
  for i in ${type[@]};
  do
    "$i""_info"
    echo -e ""
  done
}

main