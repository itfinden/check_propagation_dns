#!/bin/bash

#
# Global Variables
#

DOMAIN=""
REGEX="^[a-zA-Z0-9\.-]*(.com|.net|.org|.gov|.br|.cl|.uk)$"

SERVERIPS="
8.8.8.8 
8.8.4.4
208.67.222.222 
208.67.220.220 
68.94.156.1 
4.2.2.1 
203.23.236.66 
202.83.95.227 
189.38.95.95 
200.221.11.100 
202.27.158.40 
212.158.248.5 
9.9.9.9 
149.112.112.112 
1.1.1.1 
1.0.0.1 
185.228.168.9 
185.228.169.9 
64.6.64.6 
64.6.65.6 
198.101.242.72 
23.253.163.53 
176.103.130.130 
176.103.130.131"





SERVERNAMES="
			[US] Google Public 1;
			[US] Google Public 2;
			[US] OpenDNS #1;
			[US] OpenDNS #2;
			[US] AT&T;
			[US] Level 3;
			[AU] Comcel;
			[AU] OpenNIC;
			[BR] GigaDNS;
			[BR] Universo Online (UOL);
			[NZ] Xtra;
			[UK] Bulldog Broadband;
			[US] QuadNine #1;
			[US] QuadNine #2;
			[US] Cloudflare #1;
			[US] Cloudflare #2;
			[US] CleanBrowsing #1;
			[US] CleanBrowsing #2;
			[US] Verisign #1;
			[US] Verisign #2;
			[US] Alternate DNS #1;
			[US] Alternate DNS #2;
			[US] AdGuard DNS #1;
			[US] AdGuard DNS #2"

USAGE="
USAGE: "${0##*/}" DOMAIN

EXAMPLE
 $ ./"${0##*/}" itfinden.com

NOTE
 DOMAIN MUST be a valid domain like www.itfinden.com or 
 itfinden.com. Do NOT use \"http://\" (or something like)
 as prefix.
"

#
# Functions
#

main(){
#
# Iterates over IPs list, getting the respective server name and
# checking what is the IP of $DOMAIN in that server.
#
    local ip
    local name

    # Output's header
    printf "%-30s %50s\n" "     SERVIDOR DNS" "IP REGISTRADA"
    echo "     ============================================================= ==============="
    
    # For each IP, gets its server name,
    # updates server name's list and
    # figure out the IP for $DOMAIN in
    # that DNS server.
    for ip in $SERVERIPS; do
        name="$(echo $SERVERNAMES | cut -d\; -f1)"
        SERVERNAMES="$(echo $SERVERNAMES | cut -d\; -f2-)" 
        
        printf "%-50s %31s\n" "$name ($ip)"  "$(answer "$ip" "$DOMAIN")"
    done

    return $?
}

registers(){
#
# Displays all DNS servers used in Puck, with its IP addresses.
#
    local ip
    local name
    
    ip=0;
    name="";

    # Output's header
    printf "%-30s %15s\n" "     DNS SERVER" "IP ADDRESS"
    echo "     ========================= ==============="

    for ip in $SERVERIPS; do
        name="$(echo $SERVERNAMES | cut -d\; -f1)"
        SERVERNAMES="$(echo $SERVERNAMES | cut -d\; -f2-)" 
        
        printf "%-30s %15s\n" "$name" "$ip"
    done

    return $?
}

answer(){
#
# This is the program's core system.
# Receives DNS's IP and Domain through $1 and $2.
# Returns the IP associated to that Domain.
#
    dig @"$1" "$2" | grep -a1 "ANSWER SECTION" | tail -1 | awk '{print $NF}'
}




#
# Main
#

if [ $# -gt "0" ]; then
    DOMAIN="$1"
else
    echo -n "Ingrese Dominio: "
    read -r
    DOMAIN="$REPLY"
fi

if [[ $DOMAIN =~ $REGEX ]]; then
    if ping -c 1 $DOMAIN > /dev/null 2>&1; then
        main
        exit $?
    else
        echo -e "\n$DOMAIN is offline or there is a problem with your link."
        echo -e "Check out this issue and try again.\n"
        exit 2
    fi
else
    echo "$USAGE"
    exit 1
fi
