#!/bin/bash
#
# A basic simulation menu for OPS / OMNeT++ to be run inside a docker container
# in interactive / terminal mode
#
# This script does the following:
#
# - Check if the output directory is mounted. This is required to ensure that
#       the simulation results will not get lost after the simulation finished
# - Check the available disk space to make sure the hard disk will not be
#       completely filled by the simulation results
#
# Author: Jens Dede, <jd@comnets.uni-bremen.de>
#

SIMULATION_OUTPUT_DIR="/opt/OPS/simulations/out"
REQUIRED_OUTPUT_DISK_SPACE=$((1000**4)) # in bytes, 1TB
REQUIRED_RAM=40000000 # in bytes
BASE_SIMU_COMMAND="time ./ops-simu-run.sh -m cmdenv -p parsers.txt -c"

DURATION_WARNING="This simulation might take a long period of time and require a lot of disk space. Are you sure that you want to start the simulation?"

# Calculate the screen dimensions for whiptail
calc_wt_size() {
  WT_HEIGHT=17
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT - 8))
}

# Message box telling the simulation exited successfully
sim_okay(){
    calc_wt_size
    whiptail --title "Simulation finished" --msgbox "The simulation ended successfully. You will now find the results in the corresponding output directory.\n\
You can now start another simulation or exit." $WT_HEIGHT $WT_WIDTH
}

# Message box telling the simulation exited with an error
sim_error(){
    calc_wt_size
    whiptail --title "Simulation finished" --msgbox "The simulation exited with an error. Please check the log files in the corresponding output directory for further information." $WT_HEIGHT $WT_WIDTH
}

# Start a shell
start_shell(){
    echo "Type \"exit\" to return to the main menu"
    /bin/bash
}

# Run a simulation
# 1st param: Simulation file (.ini file)
# 2nd param: Short desciption
function sim_run {
    SIMFILE=$1
    MESSAGE=$2

    calc_wt_size
    if (whiptail --title "Start a simulation" --yesno "$MESSAGE\n\nini: $SIMFILE\n\n$DURATION_WARNING" $WT_HEIGHT $WT_WIDTH) then
        echo "RUNNING SIMULATION"
        PWD=$(pwd)
        cd /opt/OPS
        #./ops-simu-run.sh -m cmdenv -p parsers.txt
	$BASE_SIMU_COMMAND simulations/$SIMFILE
        RET=$?
        cd $PWD

        if [ $RET -eq 0 ]; then
            sim_okay
        else
            sim_error
        fi
    fi

}


#### Menu definitions


## Main Menu
show_main_menu(){
	IN_MAIN_MENU=true
	while $IN_MAIN_MENU; do
	    MAIN_MENU_OUT=$(whiptail --title "ComNets OPS Simulations" --menu "Select a simulation" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select\
		"1   :" "Reference Scenario Simulations"\
		"2   :" "Evaluation of the Data Injection frequency"\
		"3   :" "Evaluation of the Number of Nodes"\
		"4   :" "Evaluation of the Cache Size"\
		"98  :" "About"\
		"99  :" "Start a shell"\
		"100 :" "Exit"\
		3>&1 1>&2 2>&3)

	    RET=$?

	    if [ $RET -eq 1 ]; then
		echo "Done"
		IN_MAIN_MENU=false
	    elif [ $RET -eq 0 ]; then
		case $MAIN_MENU_OUT in
		    1\ *) show_reference_sim_menu ;;
		    2\ *) show_data_injection_sim_menu ;;
		    3\ *) show_number_of_nodes_sim_menu ;;
		    4\ *) show_cache_size_sim_menu ;;
		    98\ *) show_info_box ;;
		    99\ *) start_shell ;;
		    100\ *) IN_MAIN_MENU=false ;;
		    *)  whiptail --msgbox "Program error: unrecognized option" 20 60 1 ;;
		esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	    else
		echo "ERROR: $RET"
		IN_MAIN_MENU=false
	    fi
	done
}

#### Reference Scenario menu
show_reference_sim_menu() {
	IN_REF_MENU=true
	while $IN_REF_MENU; do
	    REF_MENU_OUT=$(whiptail --title "Reference Scenario Simulations" --menu "Select a simulation" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select\
		"1   :" "Keetchi Reference 30 runs"\
		"2   :" "Keetchi Reference 1 run"\
		"3   :" "Epidemic Reference 30 runs"\
		"4   :" "Epidemic Reference 1 run"\
		"100 :" "Exit"\
		3>&1 1>&2 2>&3)

	    RET=$?

	    if [ $RET -eq 1 ]; then
		echo "Done"
		IN_REF_MENU=false
	    elif [ $RET -eq 0 ]; then
		case $REF_MENU_OUT in
		    1\ *) sim_run "herald-keetchi-random-mob.ini" "Simulation of the default scenario for Keetchi with 500 nodes and 5MB cache (30 runs)" ;;
		    2\ *) sim_run "herald-keetchi-random-mob-single-run.ini" "Simulation of the default scenario for Keetchi with 500 nodes and 5MB cache (single run)" ;;
		    3\ *) sim_run "herald-epidemic-random-mob.ini" "Simulation of the default scenario for Epidemic routing with 500 nodes and 5MB cache (30 runs)" ;;
		    4\ *) sim_run "herald-epidemic-random-mob-single-run.ini" "Simulation of the default scenario for Epidemic routing with 500 nodes and 5MB cache (single run)" ;;
		    100\ *) IN_REF_MENU=false ;;
		    *)  whiptail --msgbox "Program error: unrecognized option" 20 60 1 ;;
		esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	    else
		echo "ERROR: $RET"
		IN_REF_MENU=false
	    fi
	done
}

#### Data injection menu
show_data_injection_sim_menu() {
	IN_INJECTION_MENU=true
	while $IN_INJECTION_MENU; do
	    INJECTION_MENU_OUT=$(whiptail --title "Data Injection Frequency Simulations" --menu "Select a simulation" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select\
		"1   :" "Keetchi 15s 30 runs"\
		"2   :" "Keetchi 15s 1 run"\
		"3   :" "Keetchi 60s 30 runs"\
		"4   :" "Keetchi 60s 1 run"\
		"5   :" "Keetchi 250s 30 runs"\
		"6   :" "Keetchi 250s 1 run"\
		"7   :" "Keetchi 500s 30 runs"\
		"8   :" "Keetchi 500s 1 runs"\
		"9   :" "Epidemic 15s 30 runs"\
		"10  :" "Epidemic 15s 1 run"\
		"11  :" "Epidemic 60s 30 runs"\
		"12  :" "Epidemic 60s 1 run"\
		"13  :" "Epidemic 250s 30 runs"\
		"14  :" "Epidemic 250s 1 run"\
		"15  :" "Epidemic 500s 30 runs"\
		"16  :" "Epidemic 500s 1 run"\
		"100 :" "Exit"\
		3>&1 1>&2 2>&3)

	    RET=$?

	    if [ $RET -eq 1 ]; then
		echo "Done"
		IN_INJECTION_MENU=false
	    elif [ $RET -eq 0 ]; then
		case $INJECTION_MENU_OUT in
		    1\ *) sim_run "herald-keetchi-random-appl-15s.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 15 seconds (30 runs)" ;;
		    2\ *) sim_run "herald-keetchi-random-appl-15s-single-run.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 15 seconds (single run)" ;;
		    3\ *) sim_run "herald-keetchi-random-appl-60s.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 60 seconds (30 runs)" ;;
		    4\ *) sim_run "herald-keetchi-random-appl-60s-single-run.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 60 seconds (single run)" ;;
		    5\ *) sim_run "herald-keetchi-random-appl-250s.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 250 seconds (30 runs)" ;;
      		    6\ *) sim_run "herald-keetchi-random-appl-250s-single-run.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 250 seconds (single run)" ;;
		    7\ *) sim_run "herald-keetchi-random-appl-500s.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 500 seconds (30 runs)" ;;
		    8\ *) sim_run "herald-keetchi-random-appl-500s-single-run.ini" "Simulation of the default scenario for Keetchi with the data injection frequency set to every 500 seconds (single run)" ;;
		    9\ *) sim_run "herald-epidemic-random-appl-15s.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 15 seconds (30 runs)" ;;
		    10\ *) sim_run "herald-epidemic-random-appl-15s-single-run.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 15 seconds (single run)" ;;
		    11\ *) sim_run "herald-epidemic-random-appl-60s.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 60 seconds (30 runs)" ;;
		    12\ *) sim_run "herald-epidemic-random-appl-60s-single-run.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 60 seconds (single run)" ;;
		    13\ *) sim_run "herald-epidemic-random-appl-250s.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 250 seconds (30 runs)" ;;
		    14\ *) sim_run "herald-epidemic-random-appl-250s-single-run.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 250 seconds (single run)" ;;
		    15\ *) sim_run "herald-epidemic-random-appl-500s.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 500 seconds (30 runs)" ;;
		    16\ *) sim_run "herald-epidemic-random-appl-500s-single-run.ini" "Simulation of the default scenario for Epidemic routing with the data injection frequency set to every 500 seconds (single run)" ;;
		    100\ *) IN_INJECTION_MENU=false ;;
		    *)  whiptail --msgbox "Program error: unrecognized option" 20 60 1 ;;
		esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	    else
		echo "ERROR: $RET"
		IN_INJECTION_MENU=false
	    fi
	done
}

#### Number of Nodes
show_number_of_nodes_sim_menu() {
	IN_NUMBER_OF_NODES_MENU=true
	while $IN_NUMBER_OF_NODES_MENU; do
	    NUMBER_OF_NODES_MENU_OUT=$(whiptail --title "Number of Nodes Simulations" --menu "Select a simulation" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select\
		"1   :" "Keetchi 250 nodes 30 runs"\
		"2   :" "Keetchi 250 nodes 1 run"\
		"3   :" "Keetchi 500 nodes 30 runs"\
		"4   :" "Keetchi 500 nodes 1 run"\
		"5   :" "Keetchi 750 nodes 30 runs"\
		"6   :" "Keetchi 750 nodes 1 run"\
		"7   :" "Keetchi 1000 nodes 30 runs"\
		"8   :" "Keetchi 1000 nodes 1 run"\
		"9   :" "Keetchi 1250 nodes 30 runs"\
		"10  :" "Keetchi 1250 nodes 1 run"\
		"11  :" "Keetchi 1500 nodes 30 runs"\
		"12  :" "Keetchi 1500 nodes 1 run"\
		"13  :" "Keetchi 1750 nodes 30 runs"\
		"14  :" "Keetchi 1750 nodes 1 run"\
		"15  :" "Keetchi 2000 nodes 30 runs"\
		"16  :" "Keetchi 2000 nodes 1 run"\
		"17  :" "Epidemic 250 nodes 30 runs"\
		"18  :" "Epidemic 250 nodes 1 run"\
		"19  :" "Epidemic 500 nodes 30 runs"\
		"20  :" "Epidemic 500 nodes 1 run"\
		"21  :" "Epidemic 750 nodes 30 runs"\
		"22  :" "Epidemic 750 nodes 1 run"\
		"23  :" "Epidemic 1000 nodes 30 runs"\
		"24  :" "Epidemic 1000 nodes 1 run"\
		"25  :" "Epidemic 1250 nodes 30 runs"\
		"26  :" "Epidemic 1250 nodes 1 run"\
		"27  :" "Epidemic 1500 nodes 30 runs"\
		"28  :" "Epidemic 1500 nodes 1 run"\
		"29  :" "Epidemic 1750 nodes 30 runs"\
		"30  :" "Epidemic 1750 nodes 1 run"\
		"31  :" "Epidemic 2000 nodes 30 runs"\
		"32  :" "Epidemic 2000 nodes 1 run"\
		"100 :" "Exit"\
		3>&1 1>&2 2>&3)

	    RET=$?

	    if [ $RET -eq 1 ]; then
		echo "Done"
		IN_NUMBER_OF_NODES_MENU=false
	    elif [ $RET -eq 0 ]; then
		case $NUMBER_OF_NODES_MENU_OUT in
		    1\ *) sim_run "herald-keetchi-random-mob-250-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 250 (30 runs)" ;;
		    2\ *) sim_run "herald-keetchi-random-mob-250-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 250 (single run)" ;;
		    3\ *) sim_run "herald-keetchi-random-mob-500-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 500 (30 runs)" ;;
		    4\ *) sim_run "herald-keetchi-random-mob-500-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 500 (single run)" ;;
		    5\ *) sim_run "herald-keetchi-random-mob-750-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 750 (30 runs)" ;;
		    6\ *) sim_run "herald-keetchi-random-mob-750-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 750 (single run)" ;;
		    7\ *) sim_run "herald-keetchi-random-mob-1000-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1000 (30 runs)" ;;
		    8\ *) sim_run "herald-keetchi-random-mob-1000-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1000 (single run)" ;;
		    9\ *) sim_run "herald-keetchi-random-mob-1250-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1250 (30 runs)" ;;
		    10\ *) sim_run "herald-keetchi-random-mob-1250-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1250 (single run)" ;;
		    11\ *) sim_run "herald-keetchi-random-mob-1500-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1500 (30 runs)" ;;
		    12\ *) sim_run "herald-keetchi-random-mob-1500-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1500 (single run)" ;;
		    13\ *) sim_run "herald-keetchi-random-mob-1750-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1750 (30 runs)" ;;
		    14\ *) sim_run "herald-keetchi-random-mob-1750-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 1750 (single run)" ;;
		    15\ *) sim_run "herald-keetchi-random-mob-2000-nodes.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 2000 (30 runs)" ;;
		    16\ *) sim_run "herald-keetchi-random-mob-2000-nodes-single-run.ini" "Simulation of the default scenario for Keetchi with the number of nodes set to 2000 (single run)" ;;
		    17\ *) sim_run "herald-epidemic-random-mob-250-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 250 (30 runs)" ;;
		    18\ *) sim_run "herald-epidemic-random-mob-250-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 250 (single run)" ;;
		    19\ *) sim_run "herald-epidemic-random-mob-500-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 500 (30 runs)" ;;
		    20\ *) sim_run "herald-epidemic-random-mob-500-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 500 (single run)" ;;
		    21\ *) sim_run "herald-epidemic-random-mob-750-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 750 (30 runs)" ;;
		    22\ *) sim_run "herald-epidemic-random-mob-750-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 750 (single run)" ;;
		    23\ *) sim_run "herald-epidemic-random-mob-1000-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1000 (30 runs)" ;;
		    24\ *) sim_run "herald-epidemic-random-mob-1000-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1000 (single run)" ;;
		    25\ *) sim_run "herald-epidemic-random-mob-1250-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1250 (30 runs)" ;;
		    26\ *) sim_run "herald-epidemic-random-mob-1250-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1250 (single run)" ;;
		    27\ *) sim_run "herald-epidemic-random-mob-1500-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1500 (30 runs)" ;;
		    28\ *) sim_run "herald-epidemic-random-mob-1500-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1500 (single run)" ;;
		    29\ *) sim_run "herald-epidemic-random-mob-1750-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1750 (30 runs)" ;;
		    30\ *) sim_run "herald-epidemic-random-mob-1750-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 1750 (single run)" ;;
		    31\ *) sim_run "herald-epidemic-random-mob-2000-nodes.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 2000 (30 runs)" ;;
		    32\ *) sim_run "herald-epidemic-random-mob-2000-nodes-single-run.ini" "Simulation of the default scenario for Epidemic routing with the number of nodes set to 2000 (single run)" ;;
		    100\ *) IN_NUMBER_OF_NODES_MENU=false ;;
		    *)  whiptail --msgbox "Program error: unrecognized option" 20 60 1 ;;
		esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	    else
		echo "ERROR: $RET"
		IN_NUMBER_OF_NODES_MENU=false
	    fi
	done
}

#### Number of Nodes
show_cache_size_sim_menu() {
	IN_CACHE_SIZE_MENU=true
	while $IN_CACHE_SIZE_MENU; do
	    CACHE_SIZE_MENU_OUT=$(whiptail --title "Cache Size Simulations" --menu "Select a simulation" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select\
		"1   :" "Keetchi 20 KB cache 30 runs"\
		"2   :" "Keetchi 20 KB cache 1 run"\
		"3   :" "Keetchi 40 KB cache 30 runs"\
		"4   :" "Keetchi 40 KB cache 1 run"\
		"5   :" "Keetchi 50 KB cache 30 runs"\
		"6   :" "Keetchi 50 KB cache 1 run"\
		"7   :" "Keetchi 100 KB cache 30 runs"\
		"8   :" "Keetchi 100 KB cache 1 run"\
		"9   :" "Keetchi 500 KB cache 30 runs"\
		"10  :" "Keetchi 500 KB cache 1 run"\
		"11  :" "Keetchi 1 MB cache 30 runs"\
		"12  :" "Keetchi 1 MB cache 1 run"\
		"13  :" "Keetchi 3 MB cache 30 runs"\
		"14  :" "Keetchi 3 MB cache 1 run"\
		"15  :" "Epidemic 20 KB cache 30 runs"\
		"16  :" "Epiedmic 20 KB cache 1 run"\
		"17  :" "Epidemic 40 KB cache 30 runs"\
		"18  :" "Epidemic 40 KB cache 1 run"\
		"19  :" "Epidemic 50 KB cache 30 runs"\
		"20  :" "Epidemic 50 KB cache 1 run"\
		"21  :" "Epidemic 100 KB cache 30 runs"\
		"22  :" "Epidemic 100 KB cache 1 run"\
		"23  :" "Epidemic 500 KB cache 30 runs"\
		"24  :" "Epidemic 500 KB cache 1 run"\
		"25  :" "Epidemic 1 MB cache 30 runs"\
		"26  :" "Epidemic 1 MB cache 1 run"\
		"27  :" "Epidemic 3 MB cache 30 runs"\
		"28  :" "Epidemic 3 MB cache 1 run"\
		"100 :" "Exit"\
		3>&1 1>&2 2>&3)

	    RET=$?

	    if [ $RET -eq 1 ]; then
		echo "Done"
		IN_CACHE_SIZE_MENU=false
	    elif [ $RET -eq 0 ]; then
		case $CACHE_SIZE_MENU_OUT in
		    1\ *) sim_run "herald-keetchi-random-mob-netpress-197.ini" "Simulation of the default scenario for Keetchi with the cache size set to 20KB (30 runs)" ;;
		    2\ *) sim_run "herald-keetchi-random-mob-netpress-197-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 20KB (single run)" ;;
		    3\ *) sim_run "herald-keetchi-random-mob-netpress-148.ini" "Simulation of the default scenario for Keetchi with the cache size set to 40KB (30 runs)" ;;
		    4\ *) sim_run "herald-keetchi-random-mob-netpress-148-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 40KB (single run)" ;;
		    5\ *) sim_run "herald-keetchi-random-mob-netpress-118.ini" "Simulation of the default scenario for Keetchi with the cache size set to 50KB (30 runs)" ;;
		    6\ *) sim_run "herald-keetchi-random-mob-netpress-118-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 50KB (single run)" ;;
		    7\ *) sim_run "herald-keetchi-random-mob-netpress-59-2.ini" "Simulation of the default scenario for Keetchi with the cache size set to 100KB (30 runs)" ;;
		    8\ *) sim_run "herald-keetchi-random-mob-netpress-59-2-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 100KB (single run)" ;;
		    9\ *) sim_run "herald-keetchi-random-mob-cache-500kB.ini" "Simulation of the default scenario for Keetchi with the cache size set to 500KB (30 runs)" ;;
		    10\ *) sim_run "herald-keetchi-random-mob-cache-500kB-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 500KB (single run)" ;;
		    11\ *) sim_run "herald-keetchi-random-mob-cache-1MB.ini" "Simulation of the default scenario for Keetchi with the cache size set to 1MB (30 runs)" ;;
		    12\ *) sim_run "herald-keetchi-random-mob-cache-1MB-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 1MB (single run)" ;;
		    13\ *) sim_run "herald-keetchi-random-mob-cache-3MB.ini" "Simulation of the default scenario for Keetchi with the cache size set to 3MB (30 runs)" ;;
		    14\ *) sim_run "herald-keetchi-random-mob-cache-3MB-single-run.ini" "Simulation of the default scenario for Keetchi with the cache size set to 3MB (single run)" ;;
		    15\ *) sim_run "herald-epidemic-random-mob-netpress-197.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 20KB (30 runs)" ;;
		    16\ *) sim_run "herald-epidemic-random-mob-netpress-197-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 20KB (single run)" ;;
		    17\ *) sim_run "herald-epidemic-random-mob-netpress-148.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 40KB (30 runs)" ;;
		    18\ *) sim_run "herald-epidemic-random-mob-netpress-148-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 40KB (single run)" ;;
		    19\ *) sim_run "herald-epidemic-random-mob-netpress-118.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 50KB (30 runs)" ;;
		    20\ *) sim_run "herald-epidemic-random-mob-netpress-118-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 50KB (single run)" ;;
		    21\ *) sim_run "herald-epidemic-random-mob-netpress-59-2.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 100KB (30 runs)" ;;
		    22\ *) sim_run "herald-epidemic-random-mob-netpress-59-2-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 100KB (single run)" ;;
		    23\ *) sim_run "herald-epidemic-random-mob-cache-500kB.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 500KB (30 runs)" ;;
		    24\ *) sim_run "herald-epidemic-random-mob-cache-500kB-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 500KB (single run)" ;;
		    25\ *) sim_run "herald-epidemic-random-mob-cache-1MB.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 1MB (30 runs)" ;;
		    26\ *) sim_run "herald-epidemic-random-mob-cache-1MB-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 1MB (single run)" ;;
		    27\ *) sim_run "herald-epidemic-random-mob-cache-3MB.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 3MB (30 runs)" ;;
		    28\ *) sim_run "herald-epidemic-random-mob-cache-3MB-single-run.ini" "Simulation of the default scenario for Epidemic routing with the cache size set to 3MB (single run)" ;;
		    100\ *) IN_CACHE_SIZE_MENU=false ;;
		    *)  whiptail --msgbox "Program error: unrecognized option" 20 60 1 ;;
		esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
	    else
		echo "ERROR: $RET"
		IN_CACHE_SIZE_MENU=false
	    fi
	done
}

#### Definitions of simulations

# Simulation herald-epidemic-random-appl-15s
do_sim_herald-epidemic-random-appl-15s(){
	sim_run "herald-epidemic-random-appl-15s-single-run.ini" "Random application 15 second interval 30 runs"
}


#### Some general functions
show_info_box(){
    calc_wt_size
	whiptail --title "Image Information" --scrolltext --textbox /opt/INFO.txt $WT_HEIGHT $WT_WIDTH
}

#####################################################
############### Start of main program ###############
#####################################################

calc_wt_size

show_info_box

calc_wt_size

echo "Checking mount status..."

mount | grep $SIMULATION_OUTPUT_DIR
MOUNT_STATUS=$?

if [ $MOUNT_STATUS -eq 0 ]; then
    echo "Mount okay"
else
    whiptail --title "Mount missing" --msgbox "The simulation output directory is not mounted to another filesystem. All simulation results will be lost! Refer to the readme how to fix this problem." $WT_HEIGHT $WT_WIDTH
    echo "Mount missing"
fi

echo "Checking available disk space"

if ! [ -d $SIMULATION_OUTPUT_DIR ]; then
    echo "$SIMULATION_OUTPUT_DIR does not exist! This should not happen. Aborting..."
    whiptail --title "Output directory missing" --msgbox "The output directory $SIMULATION_OUTPUT_DIR does not exist. This script is only tested inside a docker image. Otherwise, it has to be adapted. Aborting..." $WT_HEIGHT $WT_WIDTH
    exit 1
fi

#OUTPUT_SPACE=$(df -kP $SIMULATION_OUTPUT_DIR | awk 'int($5)>60{print $4}')
OUTPUT_SPACE=$(($(stat -f --format="%a*%S" $SIMULATION_OUTPUT_DIR)))
echo "Available space: $OUTPUT_SPACE"

if [ "$OUTPUT_SPACE" -lt "$REQUIRED_OUTPUT_DISK_SPACE" ]; then
    whiptail --title "Disk space" --msgbox "In the simulation output directory, only $(($OUTPUT_SPACE/1024/1024/1024)) GB are available. The simulations require plenty of space so the authors recommend to have at least $(($REQUIRED_OUTPUT_DISK_SPACE/1000/1000/1000)) GB available to run the simulation." $WT_HEIGHT $WT_WIDTH
    echo "Not enough disk space"
else
    echo "Disk space okay!"
fi;

echo "Checking available memory"

AVAILABLE_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')

if [ $AVAILABLE_RAM -le $REQUIRED_RAM ]; then
    whiptail --title "RAM" --msgbox "Some simulations require a lot of RAM.\nIt is recommended to have at least $(($REQUIRED_RAM/1000/1000)) GB available! Your machine has $(($AVAILABLE_RAM/1000/1000)) GB." $WT_HEIGHT $WT_WIDTH
    echo "Not enough RAM"
else
    echo "RAM Okay!"
fi;


## Environment seems to be okay. Create a menu

show_main_menu


echo "Finalizing everything"
# Give the user access rights to the simulation output
useradd dockeruser
chown -R dockeruser:dockeruser $SIMULATION_OUTPUT_DIR
