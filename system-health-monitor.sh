#! /bin/bash

# Qn : Build a script that:

#Checks CPU load, memory usage, disk usage, and top 5 processes by memory
#Flags anything over a threshold you define (e.g., disk >85%)
#Logs results with timestamps to a log file
#Optionally sends output to a file in a clean report format

CPU_THRESHOLD=80
MEM_THRESHOLD=90
DISK_THRESHOLD=85

while getopts "l:v" opt
do

    case $opt in
        l) log=$OPTARG ;;
        v) verbose=true ;;
        *) echo "Invalid option: -$OPTARG" >&2

    esac

done

checkfile(){

    if [[ -f $log ]]; then
        if [[ $verbose = true ]]; then
            echo "[INFO] File $log exists." | awk '{print "["strftime("%Y-%m-%d %H:%M:%S")"]", $0}'
        fi
    else

        if [[ -z $log ]]; then
            echo ""
        else
            echo "[ERROR] '$log' does not exist." | awk '{print "["strftime("%Y-%m-%d %H:%M:%S")"]", $0}'
        fi

        read -rp "Would you like to create it? (y/n): " choice

        if [[ $choice == "y" || $choice == "Y" ]]; then
            touch "$log"
            if [[ $verbose = true ]]; then
                echo "[OK] Created '$log'." | awk '{print "["strftime("%Y-%m-%d %H:%M:%S")"]", $0}' | tee -a "$log"
            fi
        else
            echo "No file created exiting....." | awk '{print "["strftime("%Y-%m-%d %H:%M:%S")"]", $0}'
            exit 1
        fi
    fi
}

check_cpu(){

    if [[ $verbose = true ]]; then
        echo "[INFO] Checking CPU Usage."
    fi
    echo -e "CPU Load Average\n- - - - - - - -"
    echo "1 min : $(cat /proc/loadavg | cut -d" " -f1)"
    echo "5 min : $(cat /proc/loadavg | cut -d" " -f2)"
    echo "15 min : $(cat /proc/loadavg | cut -d" " -f3)"
}
cpu_usage(){
    read -ra c < /proc/stat
    total1=$(( c[1] + c[2] + c[3] + c[4] + c[5] + c[6] + c[7] + c[8] ))
    idle1=$(( c[4] + c[5] ))

    sleep 1

    read -ra c < /proc/stat
    total2=$(( c[1] + c[2] + c[3] + c[4] + c[5] + c[6] + c[7] + c[8] ))
    idle2=$(( c[4] + c[5] ))

    totaldiff=$(( total2 - total1 ))
    idlediff=$(( idle2 - idle1 ))

    busy=$(( totaldiff - idlediff ))

    usage=$(( busy * 100 / totaldiff ))

    if(( usage >= CPU_THRESHOLD))
    then
        echo -e "[WARNING]CPU usage : $usage% \n"
    else
        echo -e "[OK]CPU usage : $usage% \n"
    fi

}
check_memory(){

    if [[ $verbose = true ]]; then
        echo "[INFO] Checking memory usage."
    fi
    echo -e "Memory Usage\n- - - - - - -  "
    read -ra mem < <(free -m | awk '/^Mem:/')
    mem_percent=$(( mem[2] * 100 / mem[1] ))
    echo -e "Total : ${mem[1]} MB"
    echo -e "Used : ${mem[2]} MB"

    if(( mem_percent >= MEM_THRESHOLD ))
    then
        echo -e "[WARNING]Percentage : $mem_percent %\n"
    else
        echo -e "[OK]Percentage : $mem_percent %\n"
    fi
}
check_disk(){

    if [[ $verbose = true ]]; then
        echo "[INFO] Checking Disk Usage."
    fi
    echo -e "Disk Info :\n- - - - - -"
    printf "%-10s %-16s %-8s %-6s %s\n" \
    "[!]" "File System" "Type" "Use" "Mounted on"
    df -hT -x tmpfs -x devtmpfs -x efivarfs -x squashfs |
    awk 'NR>1 && !seen[$1]++' |
    while read -r fs type size used avail use mount
    do
        usage=${use%\%}
        if(( usage >= DISK_THRESHOLD ))
        then
            printf "%-10s %-15s %-8s %-6s %s\n" \
            "[WARNING]" "$fs" "$type" "$use" "$mount"
        else 
            printf "%-10s %-15s %-8s %-6s %s\n" \
            "[OK]" "$fs" "$type" "$use" "$mount"
        fi
    done
    echo ""
}
check_top_procs(){

    if [[ $verbose = true ]]; then
        echo "[INFO] Checking top 5 processes."
    fi
    echo -e "Top 5 Processes\n- - - - - - - -"
    ps -eo pid,%mem,%cpu,comm --sort=-%mem | head -6
    echo -e "\n"
}

if [[ -z $log ]]; then
    log="health.log"
fi

if [[ -n $log ]]; then

    checkfile
fi

echo " >>> SYSTEM HEALTH MONITOR <<< " | tee -a "$log"

{
    check_cpu
    cpu_usage
    check_memory
    check_disk
    check_top_procs
} | awk '{print "["strftime("%Y-%m-%d %H:%M:%S")"]", $0}' | tee -a "$log"