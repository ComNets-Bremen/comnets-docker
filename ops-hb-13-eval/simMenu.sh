#!/bin/sh
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
REQUIRED_OUTPUT_DISK_SPACE=10000000 # in bytes
REQUIRED_RAM=48000000 # in bytes

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
    sleep 2
}

# Simulation A
do_sim_a(){
    calc_wt_size
    if (whiptail --title "Simulation A" --yesno "This is a long simulation which might take forever. Would you like to continue?" $WT_HEIGHT $WT_WIDTH) then
        echo "RUNNING SIMULATION"
        PWD=$(pwd)
        cd /opt/OPS
        ./ops-simu-run.sh -m cmdenv
        RET=$?
        cd $PWD

        if [ $RET -eq 0 ]; then
            sim_okay
        else
            sim_error
        fi
    fi
}

# Simulation B
do_sim_b(){
    calc_wt_size
    if (whiptail --title "Simulation B" --yesno "This is a long simulation which might take forever. Would you like to continue?" $WT_HEIGHT $WT_WIDTH) then
        echo "RUNNING SIMULATION"
        sleep 5
    fi
}

# Simulation C
do_sim_c(){
    calc_wt_size
    if (whiptail --title "Simulation C" --yesno "This is a long simulation which might take forever. Would you like to continue?" $WT_HEIGHT $WT_WIDTH) then
        echo "RUNNING SIMULATION"
        sleep 5
    fi
}


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
    echo "$SIMULATION_OUTPUT_DIR does not exists! This should not happen. Aborting..."
    exit 1
fi

OUTPUT_SPACE=$(df -kP $SIMULATION_OUTPUT_DIR | awk 'int($5)>60{print $4}')
if [ $OUTPUT_SPACE -le $REQUIRED_OUTPUT_DISK_SPACE ]; then
    whiptail --title "Disk space" --msgbox "In the simulation output directory, only $OUTPUT_SPACE bytes are available. The simulations require plenty of space so the authors recommend to have at least $REQUIRED_OUTPUT_DISK_SPACE available to run the simulation." $WT_HEIGHT $WT_WIDTH
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

IN_MENU=true
while $IN_MENU; do
    MENU_OUT=$(whiptail --title "ComNets OPS Simulations" --menu "Select a simulation" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select\
        "1 :" "Simulation A"\
        "2 :" "Simulation B"\
        "3 :" "Simulation C"\
        "4 :" "Start a shell"\
        "5 :" "Exit"\
        3>&1 1>&2 2>&3)

    RET=$?

    if [ $RET -eq 1 ]; then
        echo "Done"
        IN_MENU=false
    elif [ $RET -eq 0 ]; then
        case $MENU_OUT in
            1\ *) do_sim_a ;;
            2\ *) do_sim_b ;;
            3\ *) do_sim_c ;;
            4\ *) start_shell ;;
            5\ *) IN_MENU=false ;;
            *)  whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
        esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
    else
        echo "ERROR: $RET"
        IN_MENU=false
    fi
done

echo "Finalizing everything"
# Give the user access rights to the simulation output
useradd dockeruser
chown -R dockeruser:dockeruser $SIMULATION_OUTPUT_DIR
