#!/bin/bash

case "$1" in
    state)
        netstat -ant | grep -v -e "Active Internet connections" -e "Foreign Address" | awk '{print $6}' | sort | uniq -c | sort -n
        ;;
    foreign-state)
        netstat -ant | grep -v -e "Active Internet connections" -e "Foreign Address" | awk '{print $5,$6}' | sort | uniq -c | sort -n
        ;;
    local-state)
	netstat -ant | grep -v -e "Active Internet connections" -e "Foreign Address" | awk '{print $4,$6}' | sort | uniq -c | sort -n
	;;
    *)
        echo $"Usage $0 state|foreign-state|local-state"
        ;;
esac
