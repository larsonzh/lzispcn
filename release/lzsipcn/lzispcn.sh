#!/bin/sh
# lzispcn.sh v1.0.2
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# IP address data acquisition tool for ISP network operators in China

# Purpose:
# 1.Download the latest IP information data from APNIC.
# 2.Extract the latest IPv4/6 address raw data of Chinese Mainland, Hong Kong, Macao and Taiwan from the APINC IP
#   information data.
# 3.Query the original IPv4/6 address data in Chinese Mainland from APNIC one by one to get the attribution information,
#   so as to generate the ISP operator address data of TELECOM, UNICOM/CNC, CMCC, CRTC, CERNET, GWBN and other ISPs,
#   which covers all IPv4/6 addresses in Chinese Mainland.
# 4.Generate compressed IPv4/6 CIDR format address data through the CIDR aggregation algorithm.

# Script Command (e.g., in the lzispcn Directory)
# Ubuntu | Deepin | ...
# Launch Script        bash ./lzispcn.sh
# Forced Unlocking     bash ./lzispcn.sh unlock
# ASUSWRT-Merlin | OpenWrt | ...
# Launch Script             ./lzispcn.sh
# Forced Unlocking          ./lzispcn.sh unlock

# Warning: 
# 1.After the script is launched through the Shell terminal, do not close the terminal window during operation, as it may
#   cause unexpected interruption of the program execution process.
# 2.When creating ISP operator data, the program needs to access APNIC through the internet for massive information queries,
#   which may take over an hour or two. During this process, please do not interrupt the execution process of the script
#   program and remain patient.

#BEIGIN

# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
# shellcheck disable=SC2034

# Project File Deployment & Work Path
PATH_CURRENT="${0%/*}"
! echo "${PATH_CURRENT}" | grep -q '^[\/]' && PATH_CURRENT="$( pwd )${PATH_CURRENT#*.}"
PATH_APNIC="${PATH_CURRENT}/apnic"
PATH_ISP="${PATH_CURRENT}/isp"
PATH_CIDR="${PATH_CURRENT}/cidr"
PATH_IPV6="${PATH_CURRENT}/ipv6"
PATH_IPV6_CIDR="${PATH_CURRENT}/ipv6_cidr"
PATH_TMP="${PATH_CURRENT}/tmp"

# APNIC IP Information File Target Name
APNIC_IP_INFO="lz_apnic_ip_info.txt"

# IPv4 Data
# 0--Raw Data & CIDR Data (Default)
# 1--Raw Data & Pure CIDA Data
# 2--Raw Data
# Other--Disable
IPV4_DATA="0"

# China ISP IPv4 Raw Data Target File Name
ISP_DATA_0="lz_all_cn.txt"
ISP_DATA_1="lz_chinatelecom.txt"
ISP_DATA_2="lz_unicom_cnc.txt"
ISP_DATA_3="lz_cmcc.txt"
ISP_DATA_4="lz_crtc.txt"
ISP_DATA_5="lz_cernet.txt"
ISP_DATA_6="lz_gwbn.txt"
ISP_DATA_7="lz_othernet.txt"
ISP_DATA_8="lz_hk.txt"
ISP_DATA_9="lz_mo.txt"
ISP_DATA_10="lz_tw.txt"

# CIDR Aggregated IPv4 Data Target File Name
ISP_CIDR_DATA_0="lz_all_cn_cidr.txt"
ISP_CIDR_DATA_1="lz_chinatelecom_cidr.txt"
ISP_CIDR_DATA_2="lz_unicom_cnc_cidr.txt"
ISP_CIDR_DATA_3="lz_cmcc_cidr.txt"
ISP_CIDR_DATA_4="lz_crtc_cidr.txt"
ISP_CIDR_DATA_5="lz_cernet_cidr.txt"
ISP_CIDR_DATA_6="lz_gwbn_cidr.txt"
ISP_CIDR_DATA_7="lz_othernet_cidr.txt"
ISP_CIDR_DATA_8="lz_hk_cidr.txt"
ISP_CIDR_DATA_9="lz_mo_cidr.txt"
ISP_CIDR_DATA_10="lz_tw_cidr.txt"

# IPv6 Data
# 0--Raw Data & CIDR Data
# 1--Raw Data & Pure CIDR Data
# 2--Raw Data (Default)
# Other--Disable
IPV6_DATA="2"

# China ISP IPv6 Raw Data Target File Name
ISP_IPV6_DATA_0="lz_all_cn_ipv6.txt"
ISP_IPV6_DATA_1="lz_chinatelecom_ipv6.txt"
ISP_IPV6_DATA_2="lz_unicom_cnc_ipv6.txt"
ISP_IPV6_DATA_3="lz_cmcc_ipv6.txt"
ISP_IPV6_DATA_4="lz_crtc_ipv6.txt"
ISP_IPV6_DATA_5="lz_cernet_ipv6.txt"
ISP_IPV6_DATA_6="lz_gwbn_ipv6.txt"
ISP_IPV6_DATA_7="lz_othernet_ipv6.txt"
ISP_IPV6_DATA_8="lz_hk_ipv6.txt"
ISP_IPV6_DATA_9="lz_mo_ipv6.txt"
ISP_IPV6_DATA_10="lz_tw_ipv6.txt"

# CIDR Aggregated IPv6 Data Target File Name
ISP_IPV6_CIDR_DATA_0="lz_all_cn_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_1="lz_chinatelecom_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_2="lz_unicom_cnc_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_3="lz_cmcc_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_4="lz_crtc_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_5="lz_cernet_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_6="lz_gwbn_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_7="lz_othernet_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_8="lz_hk_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_9="lz_mo_cidr_ipv6.txt"
ISP_IPV6_CIDR_DATA_10="lz_tw_cidr_ipv6.txt"

# APNIC IP Information Download URL
DOWNLOAD_URL="http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"

# IP Address Information Details Query Host
WHOIS_HOST="whois.apnic.net"

# Maximum Number Of Retries After IP Address Query Failure
# 0--Unlimited, 5--Default
RETRY_NUM="5"

# Progress Bar
# 0--Enable (Default), Other--Disable
PROGRESS_BAR="0"

# System Event Log File
SYSLOG=""
#SYSLOG="/tmp/syslog.log"

# Program Process Synchronization Protection
# 0--Enable (Default), Other--Disable
LOCK_ENABLE="0"

# Synchronization Lock File Path & Name
PATH_LOCK="/var/lock"
LOCK_FILE="lzispcn.lock"
LOCK_FILE_ID="333"

# Forced Unlocking Command Word
UNLOCK_CMD="unlock"

LZ_VERSION="v1.0.2"


lz_date() { date +"%F %T"; }

lz_echo() {
    if [ -n "${SYSLOG}" ] && [ -d "${SYSLOG%/*}" ]; then
        if [ "${1%% *}" = "-e" ]; then
            echo -e "$( lz_date ) [$$]:" "${1#* }" | tee -ai "${SYSLOG}" 2> /dev/null
        else
            echo "$( lz_date ) [$$]:" "${1}" | tee -ai "${SYSLOG}" 2> /dev/null
        fi
    else
        if [ "${1%% *}" = "-e" ]; then
            echo -e "$( lz_date ) [$$]:" "${1#* }"
        else
            echo "$( lz_date ) [$$]:" "${1}"
        fi
    fi
}

set_lock() {
    [ "${LOCK_ENABLE:="0"}" != "0" ] && return "0"
    if [ ! -d "${PATH_LOCK:="/var/lock"}" ]; then
        mkdir -p "${PATH_LOCK}"
        chmod 777 "${PATH_LOCK}"
        if [ ! -d "${PATH_LOCK}" ]; then
            LOCK_ENABLE="1"
            return "1"
        fi
    fi
    ps | awk '!/awk/ && !/grep/' | grep -qw 'bash' \
        && ! ps | awk '$1 == "'"$$"'" && !/awk/ && !/grep/' | grep -qw 'bash' \
        && ! ps a 2> /dev/null | awk '$1 == "'"$$"'" && !/awk/ && !/grep/' | grep -qw 'bash' \
        && LOCK_FILE_ID="9"
    eval "exec ${LOCK_FILE_ID:="333"}<>${PATH_LOCK}/${LOCK_FILE:="lzispcn.lock"}"
    if ! flock -xn "${LOCK_FILE_ID}"; then
        lz_echo "Another instance is already running."
        LOCK_ENABLE="1"
        return "1"
    fi
    return "0"
}

unset_lock() {
    [ "${LOCK_ENABLE:="0"}" = "0" ] && [ -f "${PATH_LOCK:="/var/lock"}/${LOCK_FILE:="lzispcn.lock"}" ] \
        && flock -u "${LOCK_FILE_ID:="333"}" 2> /dev/null \
        && { eval "exec ${LOCK_FILE_ID}<&-"; eval "exec ${LOCK_FILE_ID}>&-"; }
}

forced_unlock() {
    [ "$( awk 'BEGIN{print tolower("'"${1}"'")}' )" != "${UNLOCK_CMD:="unlock"}" ] && return "1"
    if [ -f "${PATH_LOCK:="/var/lock"}/${LOCK_FILE:="lzispcn.lock"}" ]; then
        rm -f "${PATH_LOCK}/${LOCK_FILE}"
        lz_echo "Forced Unlocking OK"
    else
        lz_echo "No Locking"
    fi
    return "0"
}

check_module() {
    [ "${1}" = "wget" ] && uname -a | grep -qi "openwrt" \
        && [ -z "$( opkg list-installed "wget-ssl" 2> /dev/null )" ] && {
            lz_echo "No wget-ssl module. Game Over !!!"
            return "1"
        }
    which "${1}" > /dev/null 2>&1 && return "0"
    lz_echo "No ${1} module. Game Over !!!"
    return "1"
}

init_project_dir() {
    chmod -R 775 "${PATH_CURRENT}"/*
    [ "${PATH_TMP}" = "${PATH_APNIC}" ] && {
        lz_echo "The PATH_TMP directory cann't have the same name"
        lz_echo "as PATH_APNIC directory. Game Over !!!"
        return "1"
    }
    [ "${PATH_TMP}" = "${PATH_ISP}" ] && {
        lz_echo "The PATH_TMP directory cann't have the same name"
        lz_echo "as PATH_ISP directory. Game Over !!!"
        return "1"
    }
    [ "${PATH_TMP}" = "${PATH_CIDR}" ] && {
        lz_echo "The PATH_TMP directory cann't have the same name"
        lz_echo "as PATH_CIDR directory. Game Over !!!"
        return "1"
    }
    [ "${PATH_TMP}" = "${PATH_IPV6}" ] && {
        lz_echo "The PATH_TMP directory cann't have the same name"
        lz_echo "as PATH_IPV6 directory. Game Over !!!"
        return "1"
    }
    [ "${PATH_TMP}" = "${PATH_IPV6_CIDR}" ] && {
        lz_echo "The PATH_TMP directory cann't have the same name"
        lz_echo "as PATH_IPV6_CIDR directory. Game Over !!!"
        return "1"
    }
    [ ! -d "${PATH_APNIC}" ] && mkdir -p "${PATH_APNIC}"
    if [ "${IPV4_DATA:="0"}" = "0" ] || [ "${IPV4_DATA}" = "1" ] || [ "${IPV4_DATA}" = "2" ]; then
        [ ! -d "${PATH_ISP}" ] && mkdir -p "${PATH_ISP}"
    fi
    if [ "${IPV4_DATA}" = "0" ] || [ "${IPV4_DATA}" = "1" ]; then
        [ ! -d "${PATH_CIDR}" ] && mkdir -p "${PATH_CIDR}"
    fi
    if [ "${IPV6_DATA:="2"}" = "0" ] || [ "${IPV6_DATA}" = "1" ] || [ "${IPV6_DATA}" = "2" ]; then
        [ ! -d "${PATH_IPV6}" ] && mkdir -p "${PATH_IPV6}"
    fi
    if [ "${IPV6_DATA}" = "0" ] || [ "${IPV6_DATA}" = "1" ]; then
        [ ! -d "${PATH_IPV6_CIDR}" ] && mkdir -p "${PATH_IPV6_CIDR}"
    fi
    [ ! -d "${PATH_TMP}" ] && mkdir -p "${PATH_TMP}"
    chmod -R 775 "${PATH_CURRENT}"/*
    [ -z "${APNIC_IP_INFO}" ] && {
        lz_echo "The APNIC_IP_INFO file name is null."
        lz_echo "Game Over !!!"
        return "1"
    }
    [ -f "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat" ] && rm -f "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat"
    local index="0" fname="" cidr_fname="" ipv6_fname="" cidr_ipv6_fname=""
    until [ "${index}" -gt "10" ]
    do
        eval fname="\${ISP_DATA_${index}}"
        eval cidr_fname="\${ISP_CIDR_DATA_${index}}"
        eval ipv6_fname="\${ISP_IPV6_DATA_${index}}"
        eval cidr_ipv6_fname="\${ISP_IPV6_CIDR_DATA_${index}}"
        [ -z "${fname}" ] && {
            lz_echo "The ISP_DATA_${index} file name is null."
            lz_echo "Game Over !!!"
            return "1"
        }
        [ -z "${cidr_fname}" ] && {
            lz_echo "The ISP_CIDR_DATA_${index} file name is null."
            lz_echo "Game Over !!!"
            return "1"
        }
        [ -z "${ipv6_fname}" ] && {
            lz_echo "The ISP_IPV6_DATA_${index} file name is null."
            lz_echo "Game Over !!!"
            return "1"
        }
        [ -z "${cidr_ipv6_fname}" ] && {
            lz_echo "The ISP_IPV6_CIDR_DATA_${index} file name is null."
            lz_echo "Game Over !!!"
            return "1"
        }
        [ "${APNIC_IP_INFO}" = "${fname}" ] && {
            lz_echo "The APNIC_IP_INFO file cann't have the same name"
            lz_echo "as ISP_DATA_${index} file. Game Over !!!"
            return "1"
        }
        [ "${APNIC_IP_INFO}" = "${cidr_fname}" ] && {
            lz_echo "The APNIC_IP_INFO file cann't have the same name"
            lz_echo "as ISP_CIDR_DATA_${index} file. Game Over !!!"
            return "1"
        }
        [ "${APNIC_IP_INFO}" = "${ipv6_fname}" ] && {
            lz_echo "The APNIC_IP_INFO file cann't have the same name"
            lz_echo "as ISP_IPV6_DATA_${index} file. Game Over !!!"
            return "1"
        }
        [ "${APNIC_IP_INFO}" = "${cidr_ipv6_fname}" ] && {
            lz_echo "The APNIC_IP_INFO file cann't have the same name"
            lz_echo "as ISP_IPV6_CIDR_DATA_${index} file. Game Over !!!"
            return "1"
        }
        [ "${fname}" = "${cidr_fname}" ] && {
            lz_echo "ISP_DATA_${index} files and ISP_CIDR_DATA_${index} files"
            lz_echo "cann't have the same name. Game Over !!!"
            return "1"
        }
        [ "${fname}" = "${ipv6_fname}" ] && {
            lz_echo "ISP_DATA_${index} files and ISP_IPV6_DATA_${index} files"
            lz_echo "cann't have the same name. Game Over !!!"
            return "1"
        }
        [ "${fname}" = "${cidr_ipv6_fname}" ] && {
            lz_echo "ISP_DATA_${index} files and ISP_IPV6_CIDR_DATA_${index} files"
            lz_echo "cann't have the same name. Game Over !!!"
            return "1"
        }
        [ "${cidr_fname}" = "${ipv6_fname}" ] && {
            lz_echo "ISP_CIDR_DATA_${index} files and ISP_IPV6_DATA_${index} files"
            lz_echo "cann't have the same name. Game Over !!!"
            return "1"
        }
        [ "${cidr_fname}" = "${cidr_ipv6_fname}" ] && {
            lz_echo "ISP_CIDR_DATA_${index} files and ISP_IPV6_CIDR_DATA_${index} files"
            lz_echo "cann't have the same name. Game Over !!!"
            return "1"
        }
        [ "${ipv6_fname}" = "${cidr_ipv6_fname}" ] && {
            lz_echo "ISP_IPV6_DATA_${index} files and ISP_IPV6_CIDR_DATA_${index} files"
            lz_echo "cann't have the same name. Game Over !!!"
            return "1"
        }
        [ -f "${PATH_TMP}/${fname%.*}.dat" ] && rm -f "${PATH_TMP}/${fname%.*}.dat"
        [ -f "${PATH_TMP}/${cidr_fname%.*}.dat" ] && rm -f "${PATH_TMP}/${cidr_fname%.*}.dat"
        [ -f "${PATH_TMP}/${ipv6_fname%.*}.dat" ] && rm -f "${PATH_TMP}/${ipv6_fname%.*}.dat"
        [ -f "${PATH_TMP}/${cidr_ipv6_fname%.*}.dat" ] && rm -f "${PATH_TMP}/${cidr_ipv6_fname%.*}.dat"
        index="$(( index + 1 ))"
    done
    return "0"
}

get_apnic_info() {
    [ -z "${DOWNLOAD_URL}" ] && DOWNLOAD_URL="http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
    local progress="--progress=bar:force"
    [ "${PROGRESS_BAR:="0"}" != "0" ] && progress="-q"
    lz_echo "Download......"
    eval wget -c "${progress}" --prefer-family=IPv4 --no-check-certificate "${DOWNLOAD_URL}" -O "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat"
    if [ ! -f "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat" ]; then
        lz_echo "${APNIC_IP_INFO} Failed. Game Over !!!"
        return "1"
    elif ! grep -qE '[\|]([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}[\|]' "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat"; then
        lz_echo "${APNIC_IP_INFO} Failed. Game Over !!!"
        rm -f "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat"
        return "1"
    fi
    lz_echo "${APNIC_IP_INFO} OK"
    return "0"
}

get_area_data() {
    if [ "${2}" = "ipv4" ]; then
        [ "${IPV4_DATA:="0"}" != "0" ] && [ "${IPV4_DATA}" != "1" ] && [ "${IPV4_DATA}" != "2" ] && return "0"
        awk -F '|' '$1 == "apnic" \
            && $2 == "'"${1}"'" \
            && $3 == "ipv4" \
            {print $4" "32-log($5)/log(2)}' "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat" \
            | sed 's/[\.]/ /g' \
            | awk '{printf "%03u %03u %03u %03u %02u\n",$1,$2,$3,$4,$5}' \
            | sort -n -t ' ' -k 1 -k 2 -k 3 -k 4 -k 5 \
            | awk '{printf "%u.%u.%u.%u/%u\n",$1,$2,$3,$4,$5}' > "${PATH_TMP}/${3%.*}.dat"
    elif [ "${2}" = "ipv6" ]; then
        [ "${IPV6_DATA:="2"}" != "0" ] && [ "${IPV6_DATA}" != "1" ] && [ "${IPV6_DATA}" != "2" ] && return "0"
        awk -F '|' '$1 == "apnic" \
            && $2 == "'"${1}"'" \
            && $3 == "ipv6" \
            {print $4"/"$5}' "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat" > "${PATH_TMP}/${3%.*}.dat"
    fi
    [ -f "${PATH_TMP}/${3%.*}.dat" ] && {
        local total="$( grep -EIc '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$|^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${PATH_TMP}/${3%.*}.dat" )"
        if [ "${total}" = "0" ]; then
            rm -f "${PATH_TMP}/${3%.*}.dat"
            lz_echo "${3} Failed. Game Over !!!"
            return "1"
        fi
        lz_echo "${3} ${total} OK"
        return "0"
    }
    lz_echo "${3} Failed. Game Over !!!"
    return "1"
}

divide_data_into_four() {
    [ ! -f "${1}" ] && return "1"
    local index="0"
    until [ "${index}" -ge "4" ]
    do
        eval [ -f "\${1}_${index}" ] && eval rm -f "\${1}_${index}"
        index="$(( index + 1 ))"
    done
    local total="$( grep -Eic '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$|^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${1}" )"
    [ "${total}" = "0" ] && return "1"
    local max_line_num="$(( total / 4 ))"
    [ "${total}" -lt "4" ] && {
        cp -p "${1}" "${1}_0"
        return "0"
    }
    local bp="0" sp="0" nsp="$(( max_line_num * 4 ))"
    index="0"
    until [ "${index}" -ge "4" ]
    do
        bp="$(( index * max_line_num + 1 ))"
        sp="$(( bp + max_line_num - 1 ))"
        awk -v count="0" -v flag="1" -v bp="${bp}" -v sp="${sp}" -v nsp="${nsp}" '{
            count++
            if (count == bp) flag = "0"
            if (flag == "0") print $1
            if (NR == sp && count != nsp) exit
        }' "${1}" >> "${1}_${index}"
        ! grep -qEi '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$|^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${1}_${index}" \
            && rm -f "${1}_${index}"
        index="$(( index + 1 ))"
    done
    return "0"
}

init_isp_data_buf() {
    local index="1"
    until [ "${index}" -gt "7" ]
    do
        eval DATA_BUF_"${index}"=""
        index="$(( index + 1 ))"
    done
}

unset_isp_data_buf() {
    local index="1"
    until [ "${index}" -gt "7" ]
    do
        eval unset DATA_BUF_"${index}"
        index="$(( index + 1 ))"
    done
}

get_isp_details() {
    whois -h "${WHOIS_HOST}" "${1%/*}" \
        | awk 'NR == "1" || $1 ~ /netname|mnt-|e-mail/ {if (NR == "1" && $2 != "'"[${WHOIS_HOST}]"'") exit; else print $2}'
}

write_isp_data_buf() {
    # CNC
    # CHINAUNICOM
    echo "${1}" | grep -qEi 'CNC|UNICOM' && { DATA_BUF_2="$( echo -e "${DATA_BUF_2}\n${2}" )"; return; }
    # CHINATELECOM
    echo "${1}" | grep -qEi 'CHINANET|TELECOM|BJTEL' && { DATA_BUF_1="$( echo -e "${DATA_BUF_1}\n${2}" )"; return; }
    # CHINAMOBILE
    echo "${1}" | grep -qEi 'CMCC|CMNET' && { DATA_BUF_3="$( echo -e "${DATA_BUF_3}\n${2}" )"; return; }
    # CRTC
    echo "${1}" | grep -qEi 'CRTC' && { DATA_BUF_4="$( echo -e "${DATA_BUF_4}\n${2}" )"; return; }
    # CERNET
    echo "${1}" | grep -qEi 'CERNET' && { DATA_BUF_5="$( echo -e "${DATA_BUF_5}\n${2}" )"; return; }
    # GWBN
    echo "${1}" | grep -qEi 'GWBN|GXBL|DXTNET|BITNET|ZBTNET|drpeng|btte' && { DATA_BUF_6="$( echo -e "${DATA_BUF_6}\n${2}" )"; return; }
    # OTHER
    DATA_BUF_7="$( echo -e "${DATA_BUF_7}\n${2}" )"
}

write_isp_data_file() {
    local prefix="ISP_DATA_" index="1" buf="" fname=""
    [ "${1}" != "ipv4" ] && prefix="ISP_IPV6_DATA_"
    until [ "${index}" -gt "7" ]
    do
        eval buf="\${DATA_BUF_${index}}"
        eval fname="${PATH_TMP}/\${${prefix}${index}}"
        [ -n "${buf}" ] && buf="$( echo "${buf}" | sed '/^[ ]*$/d' )"
        [ -n "${buf}" ] && echo "${buf}" >> "${fname%.*}.dat"
        index="$(( index + 1 ))"
    done
    init_isp_data_buf
}

add_isp_data() {
    local DATA_BUF="" retval="0" count="0" line="" isp_info="" retry="0" suffix="s"
    [ -z "${WHOIS_HOST}" ] && WHOIS_HOST="whois.apnic.net"
    if [ "${1}" = "ipv4" ]; then
        lz_echo "Obtain ISP IPv4 item data takes a long time."
        DATA_BUF="$( grep -Eo '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$' "${PATH_TMP}/${ISP_DATA_0%.*}.dat" )"
    else
        lz_echo "Obtain ISP IPv6 item data takes a long time."
        DATA_BUF="$( grep -Eio '^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${PATH_TMP}/${ISP_IPV6_DATA_0%.*}.dat" )"
    fi
    ! echo "${RETRY_NUM:="5"}" | grep -qE '^[0-9]*$' && RETRY_NUM="5"
    lz_echo "Don't interrupt & Please wait......"
    while IFS= read -r line
    do
        [ "${PROGRESS_BAR}" = "0" ] && [ "$(( count % 10 ))" = "0" ] && echo -n "."
        isp_info="$( get_isp_details "${line}" )"
        if [ -z "${isp_info}" ]; then
            [ "${PROGRESS_BAR}" = "0" ] && echo ""
            retval="1"
            retry="0"
            while true
            do
                lz_echo "Transmission failure."
                lz_echo "${line} details weren't received from ${WHOIS_HOST}."
                lz_echo "Retrying($(( retry + 1 )))......."
                isp_info="$( get_isp_details "${line}" )"
                [ -n "${isp_info}" ] && {
                    retval="0"
                    lz_echo "Data received, continue......."
                    break
                }
                retry="$(( retry + 1 ))"
                if [ "${RETRY_NUM}" != "0" ]; then
                    [ "${retry}" -ge "${RETRY_NUM}" ] && break
                    sleep "$( awk 'BEGIN{printf "%d\n", "'"${RETRY_NUM}"'"*rand()+1}' )s"
                else
                    sleep "$( awk 'BEGIN{printf "%d\n", 10*rand()+1}' )s"
                fi
            done
            [ "${retval}" != "0" ] && {
                [ "${RETRY_NUM}" -le "1" ] && suffix=""
                lz_echo "Failed to retry ${RETRY_NUM} time${suffix}. Game Over !!!"
                break
            }
        fi
        write_isp_data_buf "${isp_info}" "${line}"
        count="$(( count + 1 ))"
        [ "$(( count % 200 ))" = "0" ] && write_isp_data_file "${1}"
    done <<DATA_BUF_INPUT
${DATA_BUF}
DATA_BUF_INPUT
    write_isp_data_file "${1}"
    unset_isp_data_buf
    [ "${PROGRESS_BAR:="0"}" = "0" ] && [ "${retval}" = "0" ] && echo "."
    return "${retval}"
}

check_isp_data() {
    local prefix="ISP_DATA_" index="1" fname="" total="0"
    [ "${1}" != "ipv4" ] && prefix="ISP_IPV6_DATA_"
    until [ "${index}" -gt "7" ]
    do
        eval fname="\${${prefix}${index}}"
        if [ -f "${PATH_TMP}/${fname%.*}.dat" ]; then
            total="$( grep -Eic '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$|^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${PATH_TMP}/${fname%.*}.dat" )"
            if [ "${total}" = "0" ]; then
                rm -f "${PATH_TMP}/${fname%.*}.dat"
                lz_echo "${fname} Failed. Game Over !!!"
                return "1"
            fi
            lz_echo "${fname} ${total} OK"
        else
            lz_echo "${fname} Failed. Game Over !!!"
            return "1"
        fi
        index="$(( index + 1 ))"
    done
    return "0"
}

get_isp_data() {
    [ "${1}" = "ipv4" ] && [ "${IPV4_DATA:="0"}" != "0" ] && [ "${IPV4_DATA}" != "1" ] && [ "${IPV4_DATA}" != "2" ] && return "0"
    [ "${1}" = "ipv6" ] && [ "${IPV6_DATA:="2"}" != "0" ] && [ "${IPV6_DATA}" != "1" ] && [ "${IPV6_DATA}" != "2" ] && return "0"
    init_isp_data_buf
    add_isp_data "${1}" || return "1"
    check_isp_data "${1}" || return "1"
    return "0"
}

aggregate_ipv4_data() {
    if [ ! -f "${1}" ] || [ ! -d "${2%/*}" ]; then return "1"; fi;
    cp -p "${1}" "${2}"
    [ ! -f "${2}" ] && return "1"
    sed -i '/^\([0-9]\{1,3\}[\.]\)\{3\}[0-9]\{1,3\}\([\/][0-9]\{1,2\}\)\{0,1\}$/!d' "${2}"
    ! grep -qE '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$' "${2}" && { rm -f "${2}"; return "1"; }
    local index="0" mask="24" IP_BUF="" step="2" ip_item="" addr4="" addr3="" net3="" addr2="" net2="" addr1="" net1="" count="0"
    [ "${PROGRESS_BAR}" = "0" ] && echo -n "."
    until [ "${index}" -ge "24" ]
    do
        mask="$(( 24 - index ))"
        step="$(( 1 << ( index % 8 ) ))"
        if [ "${index}" -lt "8" ]; then
            IP_BUF="$( awk -F '.' '!/#/ && ($3 / "'"${step}"'") % 2 == "0" && $4 == "'"0/${mask}"'" {print $0}' "${2}" )"
        elif [ "${index}" -lt "16" ]; then
            IP_BUF="$( awk -F '.' '!/#/ && ($2 / "'"${step}"'") % 2 == "0" && $3 == "0" && $4 == "'"0/${mask}"'" {print $0}' "${2}" )"
        else
            IP_BUF="$( awk -F '.' '!/#/ && ($1 / "'"${step}"'") % 2 == "0" && $2 == "0" && $3 == "0" && $4 == "'"0/${mask}"'" {print $0}' "${2}" )"
        fi
        while IFS= read -r ip_item
        do
            ! grep -q "^${ip_item}$" "${2}" && continue
            addr4="${ip_item%/*}"
            addr3="${addr4%.*}"
            net3="${addr3##*.}"
            addr2="${addr3%.*}"
            net2="${addr2##*.}"
            addr1="${addr2%.*}"
            net1="${addr1}"
            if [ "${index}" -lt "8" ]; then
                next_item="${addr2}.$(( net3 + step )).0/${mask}"
            elif [ "${index}" -lt "16" ]; then
                next_item="${addr1}.$(( net2 + step )).0.0/${mask}"
            else
                next_item="$(( net1 + step )).0.0.0/${mask}"
            fi
            if grep -q "^${next_item}$" "${2}"; then
                sed -i -e "s:^${ip_item}$:${ip_item%/*}/$(( mask - 1 )):" -e "s:^${next_item}$:#&:" "${2}"
                [ "${PROGRESS_BAR}" = "0" ] && [ "$(( count % 10 ))" = "0" ] && echo -n "."
                count="$(( count + 1 ))"
                if [ "${IPV4_DATA:="0"}" = "1" ]; then
                    # Used to correct APNIC raw data errors. In principle, this situation should not occur, 
                    # otherwise it will cause chaos in the online world.
                    # This portion of code will extend the host runtime used in the CIDR data aggregation process.
                    local addr_header="" nno=""
                    local tail_no="$(( 2 - index / 8 ))"
                    [ "${tail_no}" != "0" ] && eval addr_header="\${addr${tail_no}}:"
                    eval nno="\${net$(( tail_no + 1 ))}"
                    local i="$(( nno + 1 ))"
                    until [ "${i}" -ge "$(( nno + step ))" ]
                    do
                        if grep -qE "^${addr_header//"."/"\."}${i}[\.]" "${2}"; then
                            sed -i "s:^${addr_header//"."/"\."}${i}[\.]:#&:" "${2}"
                            [ "${PROGRESS_BAR}" = "0" ] && [ "$(( count % 10 ))" = "0" ] && echo -n "."
                            count="$(( count + 1 ))"
                        fi
                        i="$(( i + 1 ))"
                    done
                fi
            fi
        done <<IP_BUF_INPUT
${IP_BUF}
IP_BUF_INPUT
        index="$(( index + 1 ))"
    done
    sed -i '/#/d' "${2}"
    [ "${PROGRESS_BAR}" = "0" ] && echo "."
    ! grep -qE '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$' "${2}" && { rm -f "${2}"; return "1"; }
    return "0"
}

get_ipv4_cidr_data() {
    [ "${IPV4_DATA:="0"}" != "0" ] && [ "${IPV4_DATA}" != "1" ] && return "0"
    lz_echo "Generating IPv4 CIDR data takes some time."
    lz_echo "Don't interrupt & Please wait......"
    local index="0" sfname="" fname="" total="0"
    until [ "${index}" -gt "10" ]
    do
        eval sfname="\${ISP_DATA_${index}}"
        eval fname="\${ISP_CIDR_DATA_${index}}"
        if aggregate_ipv4_data "${PATH_TMP}/${sfname%.*}.dat" "${PATH_TMP}/${fname%.*}.dat"; then
            total="$( grep -Ec '^([0-9]{1,3}[\.]){3}[0-9]{1,3}([\/][0-9]{1,2}){0,1}$' "${PATH_TMP}/${fname%.*}.dat" )"
            lz_echo "${fname} ${total} OK"
        else
            lz_echo "${fname} Failed. Game Over !!!"
            return "1"
        fi
        index="$(( index + 1 ))"
    done
    return "0"
}

get_ipv6_extend() {
    awk -F '/' 'NF == 2 {
        val = $1
        str = ""
        for (i = gsub(":", ":", val); i < 8; ++i) {str = str":0"}
        str = str":"
        sub("::", str, val)
        if (val ~ /:$/) val = val"0"
        if (val ~ /^:/) val = "0"val
        print tolower(val)":"$2
    }' "${1}" | awk -F ':' 'NF == 9 {printf "%05d %05d %05d %05d %05d %05d %05d %05d %05d\n","0x"$1,"0x"$2,"0x"$3,"0x"$4,"0x"$5,"0x"$6,"0x"$7,"0x"$8,$9}' \
    | sort -n -t ' ' -k 1 -k 2 -k 3 -k 4 -k 5 -k 6 -k 7 -k 8 -k 9 \
    | awk 'NF == 9 {printf "%x:%x:%x:%x:%x:%x:%x:%x/%u\n",$1,$2,$3,$4,$5,$6,$7,$8,$9}'
}

aggregate_ipv6_data() {
    if [ ! -f "${1}" ] || [ ! -d "${2%/*}" ]; then return "1"; fi;
    get_ipv6_extend "${1}" > "${2}"
    [ ! -f "${2}" ] && return "1"
    sed -i -e'/^[\:0-9a-f]\{0,4\}[\:][\:0-9a-fA-F]*\([\/][0-9]\{1,3\}\)\{0,1\}$/!d' -e '/[\:][\:]/d' "${2}"
    ! grep -qEi '^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${2}" && { rm -f "${2}"; return "1"; }
    local index="0" mask="112" IP_BUF="" step="2" ip_item="" count="0"
    local addr8="" addr7="" net7="" addr6="" net6="" addr5="" net5="" addr4="" net4="" addr3="" net3="" addr2="" net2="" addr1="" net1=""
    [ "${PROGRESS_BAR}" = "0" ] && echo -n "."
    until [ "${index}" -ge "112" ]
    do
        mask="$(( 112 - index ))"
        step="$(( 1 << ( index % 16 ) ))"
        if [ "${index}" -lt "16" ]; then
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$7) / "'"${step}"'") % 2 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        elif [ "${index}" -lt "32" ]; then
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$6) / "'"${step}"'") % 2 == "0" && $7 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        elif [ "${index}" -lt "48" ]; then
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$5) / "'"${step}"'") % 2 == "0" && $6 == "0" && $7 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        elif [ "${index}" -lt "64" ]; then
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$4) / "'"${step}"'") % 2 == "0" && $5 == "0" && $6 == "0" && $7 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        elif [ "${index}" -lt "80" ]; then
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$3) / "'"${step}"'") % 2 == "0" && $4 == "0" && $5 == "0" && $6 == "0" && $7 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        elif [ "${index}" -lt "96" ]; then
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$2) / "'"${step}"'") % 2 == "0" && $3 == "0" && $4 == "0" && $5 == "0" && $6 == "0" && $7 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        else
            IP_BUF="$( awk -F ':' '!/#/ && (("0x"$1) / "'"${step}"'") % 2 == "0" && $2 == "0" && $3 == "0" && $4 == "0" && $5 == "0" && $6 == "0" && $7 == "0" && $8 == "'"0/${mask}"'" {print $0}' "${2}" )"
        fi
        while IFS= read -r ip_item
        do
            ! grep -qE "^${ip_item}$" "${2}" && continue
            addr8="${ip_item%/*}"
            addr7="${addr8%:*}"
            net7="${addr7##*:}"
            addr6="${addr7%:*}"
            net6="${addr6##*:}"
            addr5="${addr6%:*}"
            net5="${addr5##*:}"
            addr4="${addr5%/*}"
            net4="${addr4##*:}"
            addr3="${addr4%:*}"
            net3="${addr3##*:}"
            addr2="${addr3%:*}"
            net2="${addr2##*:}"
            addr1="${addr2%:*}"
            net1="${addr1}"
            if [ "${index}" -lt "16" ]; then
                next_item="${addr6}:$( awk 'BEGIN{printf "%x\n", "'"0x${net7}"'" + "'"${step}"'"}' ):0/${mask}"
            elif [ "${index}" -lt "32" ]; then
                next_item="${addr5}:$( awk 'BEGIN{printf "%x\n", "'"0x${net6}"'" + "'"${step}"'"}' ):0:0/${mask}"
            elif [ "${index}" -lt "48" ]; then
                next_item="${addr4}:$( awk 'BEGIN{printf "%x\n", "'"0x${net5}"'" + "'"${step}"'"}' ):0:0:0/${mask}"
            elif [ "${index}" -lt "64" ]; then
                next_item="${addr3}:$( awk 'BEGIN{printf "%x\n", "'"0x${net4}"'" + "'"${step}"'"}' ):0:0:0:0/${mask}"
            elif [ "${index}" -lt "80" ]; then
                next_item="${addr2}:$( awk 'BEGIN{printf "%x\n", "'"0x${net3}"'" + "'"${step}"'"}' ):0:0:0:0:0/${mask}"
            elif [ "${index}" -lt "96" ]; then
                next_item="${addr1}:$( awk 'BEGIN{printf "%x\n", "'"0x${net2}"'" + "'"${step}"'"}' ):0:0:0:0:0:0/${mask}"
            else
                next_item="$( awk 'BEGIN{printf "%x\n", "'"0x${net1}"'" + "'"${step}"'"}' ):0:0:0:0:0:0:0/${mask}"
            fi
            if grep -qE "^${next_item}$" "${2}"; then
                sed -i -e "s|^${ip_item}$|${ip_item%/*}/$(( mask - 1 ))|" -e "s|^${next_item}$|#&|" "${2}"
                [ "${PROGRESS_BAR}" = "0" ] && [ "$(( count % 10 ))" = "0" ] && echo -n "."
                count="$(( count + 1 ))"
                if [ "${IPV6_DATA:="2"}" = "1" ]; then
                    local addr_header="" nno=""
                    local tail_no="$(( 6 - index / 16 ))"
                    [ "${tail_no}" != "0" ] && eval addr_header="\${addr${tail_no}}:"
                    eval nno="\${net$(( tail_no + 1 ))}"
                    local i="$( awk 'BEGIN{printf "%x\n", "'"0x${nno}"'" + 1}' )"
                    until [ "${i}" -ge "$( awk 'BEGIN{printf "%x\n", "'"0x${nno}"'" + "'"${step}"'"}' )" ]
                    do
                        if grep -qE "^${addr_header//":"/"\:"}${i}[\:]" "${2}"; then
                            sed -i "s|^${addr_header//":"/"\:"}${i}[\:]|#&|" "${2}"
                            [ "${PROGRESS_BAR}" = "0" ] && [ "$(( count % 10 ))" = "0" ] && echo -n "."
                            count="$(( count + 1 ))"
                        fi
                        i="$( awk 'BEGIN{printf "%x\n", "'"0x${i}"'" + 1}' )"
                    done
                fi
            fi
        done <<IP_BUF_INPUT
${IP_BUF}
IP_BUF_INPUT
        index="$(( index + 1 ))"
    done
    [ "${PROGRESS_BAR}" = "0" ] && echo -n "."
    sed -i -e '/#/d' -e 's/\([:][0]\)\{2,7\}/::/' -e 's/:::/::/' -e 's/^0::/::/' -e '/^[ ]*$/d' "${2}"
    [ "${PROGRESS_BAR}" = "0" ] && echo "."
    ! grep -qEi '^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${2}" && { rm -f "${2}"; return "1"; }
    return "0"
}

get_ipv6_cidr_data() {
    [ "${IPV6_DATA:="2"}" != "0" ] && [ "${IPV6_DATA}" != "1" ] && return "0"
    lz_echo "Generating IPv6 CIDR data takes some time."
    lz_echo "Don't interrupt & Please wait......"
    local index="0" sfname="" fname="" total="0"
    until [ "${index}" -gt "10" ]
    do
        eval sfname="\${ISP_IPV6_DATA_${index}}"
        eval fname="\${ISP_IPV6_CIDR_DATA_${index}}"
        if aggregate_ipv6_data "${PATH_TMP}/${sfname%.*}.dat" "${PATH_TMP}/${fname%.*}.dat"; then
            total="$( grep -Eic '^[\:0-9a-f]{0,4}[\:][\:0-9a-f]*([\/][0-9]{1,3}){0,1}$' "${PATH_TMP}/${fname%.*}.dat" )"
            lz_echo "${fname} ${total} OK"
        else
            lz_echo "${fname} Failed. Game Over !!!"
            return "1"
        fi
        index="$(( index + 1 ))"
    done
    return "0"
}

save_target_data() {
    [ -f "${PATH_TMP}/${2%.*}.dat" ] && mv -f "${PATH_TMP}/${2%.*}.dat" "${1}/${2}"
    [ -f "${1}/${2}" ] && {
        touch -c -r "${PATH_APNIC}/${APNIC_IP_INFO}" "${1}/$2}"
        return "0"
    }
    lz_echo "Save ${2} Failed. Game Over !!!"
    return "1"
}

save_data() {
    [ -f "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat" ] && mv -f "${PATH_TMP}/${APNIC_IP_INFO%.*}.dat" "${PATH_APNIC}/${APNIC_IP_INFO}"
    [ ! -f "${PATH_APNIC}/${APNIC_IP_INFO}" ] && {
        lz_echo "Save ${APNIC_IP_INFO} Failed. Game Over !!!"
        return "1"
    }
    local index="0"
    if [ "${IPV4_DATA:="0"}" = "0" ] || [ "${IPV4_DATA}" = "1" ] || [ "${IPV4_DATA}" = "2" ]; then
        until [ "${index}" -gt "10" ]
        do
            eval save_target_data "${PATH_ISP}" "\${ISP_DATA_${index}}" || return "1"
            index="$(( index + 1 ))"
        done
        if [ "${IPV4_DATA}" = "0" ] || [ "${IPV4_DATA}" = "1" ]; then
            index="0"
            until [ "${index}" -gt "10" ]
            do
                eval save_target_data "${PATH_CIDR}" "\${ISP_CIDR_DATA_${index}}" || return "1"
                index="$(( index + 1 ))"
            done
        fi
    fi
    if [ "${IPV6_DATA:="2"}" = "0" ] || [ "${IPV6_DATA}" = "1" ] || [ "${IPV6_DATA}" = "2" ]; then
        index="0"
        until [ "${index}" -gt "10" ]
        do
            eval save_target_data "${PATH_IPV6}" "\${ISP_IPV6_DATA_${index}}" || return "1"
            index="$(( index + 1 ))"
        done
        if [ "${IPV6_DATA}" = "0" ] || [ "${IPV6_DATA}" = "1" ]; then
            index="0"
            until [ "${index}" -gt "10" ]
            do
                eval save_target_data "${PATH_IPV6_CIDR}" "\${ISP_IPV6_CIDR_DATA_${index}}" || return "1"
                index="$(( index + 1 ))"
            done
        fi
    fi
    return "0"
}

get_file_time_stamp() {
    local time_stamp="$( stat -c %y "${1}" 2> /dev/null | awk -F '.' '{print $1}' )"
    [ -z "${time_stamp}" ] && {
        # shellcheck disable=SC2012
        if uname -a | grep -qi "asuswrt-merlin"; then
            time_stamp="$( ls -let "${1}" 2> /dev/null \
                        | awk 'NF >= "11" \
                            && $7 ~ /^[A-S][a-u][b-y]$/ \
                            && $8 ~ /^[1-9]$|^[1-2][0-9]$|^[3][0-1]$|^[0][1-9]$/ \
                            && $9 ~ /^[0-2][0-9][:][0-5][0-9][:][0-5][0-9]$/ \
                            && $10 ~ /^[1-9][0-9][0-9][0-9]$/ {
                                month = ""
                                if ($7 == "Jan") month = "01"
                                else if ($7 == "Feb") month = "02"
                                else if ($7 == "Mar") month = "03"
                                else if ($7 == "Apr") month = "04"
                                else if ($7 == "May") month = "05"
                                else if ($7 == "Jun") month = "06"
                                else if ($7 == "Jul") month = "07"
                                else if ($7 == "Aug") month = "08"
                                else if ($7 == "Sep") month = "09"
                                else if ($7 == "Oct") month = "10"
                                else if ($7 == "Nov") month = "11"
                                else if ($7 == "Dec") month = "12"
                                if (month != "") print $10"-"month"-"$8,$9}' )"
        elif uname -a | grep -qi "openwrt"; then
            time_stamp="$( ls -lt --full-time "${1}" 2> /dev/null | awk 'NF >= "9" {print $6,$7}' )"
        else
            time_stamp="$( ls -lt "${1}" 2> /dev/null \
                        | awk 'NF >= "9" \
                            && $6 ~ /^[A-S][a-u][b-y]$/ \
                            && $7 ~ /^[1-9]$|^[1-2][0-9]$|^[3][0-1]$|^[0][1-9]$/ \
                            && $8 ~ /^[0-2][0-9][:][0-5][0-9][:][0-5][0-9]$/ {
                                month = ""
                                if ($6 == "Jan") month = "01"
                                else if ($6 == "Feb") month = "02"
                                else if ($6 == "Mar") month = "03"
                                else if ($6 == "Apr") month = "04"
                                else if ($6 == "May") month = "05"
                                else if ($6 == "Jun") month = "06"
                                else if ($6 == "Jul") month = "07"
                                else if ($6 == "Aug") month = "08"
                                else if ($6 == "Sep") month = "09"
                                else if ($6 == "Oct") month = "10"
                                else if ($6 == "Nov") month = "11"
                                else if ($6 == "Dec") month = "12"
                                if (month != "") print month"-"$7,$8}' )"
        fi
    }
    echo "${time_stamp}"
}

show_header() {
    BEGIN_TIME="$( date +%s -d "$( date +"%F %T" )" )"
    lz_echo
    lz_echo "LZ ISPCN ${LZ_VERSION:="v1.0.2"} script commands start......"
    lz_echo "By LZ (larsonzhang@gmail.com)"
    lz_echo "---------------------------------------------"
    lz_echo "Command (in the ${PATH_CURRENT})"
    lz_echo "Ubuntu | Deepin | ..."
    lz_echo "Launch Script      bash ./lzispcn.sh"
    lz_echo "Forced Unlocking   bash ./lzispcn.sh unlock"
    lz_echo "ASUSWRT-Merlin | OpenWrt | ..."
    lz_echo "Launch Script           ./lzispcn.sh"
    lz_echo "Forced Unlocking        ./lzispcn.sh unlock"
    lz_echo "---------------------------------------------"
}

show_data_path() {
    local file_time_stamp="$( get_file_time_stamp "${PATH_APNIC}/${APNIC_IP_INFO}" )"
    lz_echo "---------------------------------------------"
    [ -n "${file_time_stamp}" ] && lz_echo "Data Time       ${file_time_stamp}"
    lz_echo "APNIC IP INFO   ${PATH_APNIC}"
    if [ "${IPV4_DATA:="0"}" = "0" ] || [ "${IPV4_DATA}" = "1" ] || [ "${IPV4_DATA}" = "2" ]; then
        lz_echo "ISP IPv4        ${PATH_ISP}"
        if [ "${IPV4_DATA}" = "0" ] || [ "${IPV4_DATA}" = "1" ]; then
            lz_echo "ISP IPv4 CIDR   ${PATH_CIDR}"
        fi
    fi
    if [ "${IPV6_DATA:="2"}" = "0" ] || [ "${IPV6_DATA}" = "1" ] || [ "${IPV6_DATA}" = "2" ]; then
        lz_echo "ISP IPv6        ${PATH_IPV6}"
        if [ "${IPV6_DATA}" = "0" ] || [ "${IPV6_DATA}" = "1" ]; then
            lz_echo "ISP IPv6 CIDR   ${PATH_IPV6_CIDR}"
        fi
    fi
    local end_time="$( date +%s -d "$( date +"%F %T" )" )"
    local elapsed_hour="$( printf "%02u\n" "$(( ( end_time - BEGIN_TIME ) / 3600 ))" )"
    local elapsed_min="$( printf "%02u\n" "$(( ( ( end_time - BEGIN_TIME ) % 3600 ) / 60 ))" )"
    local elapsed_sec="$( printf "%02u\n" "$(( ( end_time - BEGIN_TIME ) % 60 ))" )"
    lz_echo "Elapsed Time           ${elapsed_hour}:${elapsed_min}:${elapsed_sec}"
}

show_tail() {
    lz_echo "---------------------------------------------"
    lz_echo "LZ ISPCN ${LZ_VERSION} script commands executed!"
    lz_echo
}

show_header
while true
do
    forced_unlock "${1}" && break
    set_lock || break
    check_module "whois" || break
    check_module "wget" || break
    init_project_dir || break
    get_apnic_info || break
    get_area_data "CN" "ipv4" "${ISP_DATA_0}" || break
    get_isp_data "ipv4" || break
    get_area_data "HK" "ipv4" "${ISP_DATA_8}" || break
    get_area_data "MO" "ipv4" "${ISP_DATA_9}" || break
    get_area_data "TW" "ipv4" "${ISP_DATA_10}" || break
    get_ipv4_cidr_data || break
    get_area_data "CN" "ipv6" "${ISP_IPV6_DATA_0}" || break
    get_isp_data "ipv6" || break
    get_area_data "HK" "ipv6" "${ISP_IPV6_DATA_8}" || break
    get_area_data "MO" "ipv6" "${ISP_IPV6_DATA_9}" || break
    get_area_data "TW" "ipv6" "${ISP_IPV6_DATA_10}" || break
    get_ipv6_cidr_data || break
    save_data || break
    show_data_path
    break
done
unset_lock
show_tail

exit "0"

#END
