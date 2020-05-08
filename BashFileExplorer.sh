#!/bin/bash

# Author : Seungho Song(KWU. Software. 2019203037)
# Last Update : 2020. 05. 07

#Colors
declare RED='\033[0;31m'
declare SBLUEB='\033[0;30;46m' #skyblue bg with black fg
declare GRAYB='\033[0;30;47m'
declare BLACK='\033[0;30m'
declare NC='\033[0m'

#Cursors
declare UP=[A
declare DOWN=[B
declare RIGHT=[C
declare LEFT=[D

# Basic Utility functions

function Blank() { #Make blanks $1 times
    for (( i=0; i<$1 ; i++))
    do
        printf " "
    done
}


function Repeat_Char() { # Repeat character $2 by $1 times
    for (( i=0; i<$1 ; i++))
    do
        printf "${GRAYB}$2${NC}"
    done
}

# Functions for UI Design

function Print_Sidebar() { # Print | for UI design (side)
    declare temp=$1
    case "$3" in
        1 | cen)
            for (( i=0;i<$2;i++ ))
            do
                tput cup $temp 0
                printf "${GRAYB}|${NC}"
                tput cup $temp 41
                printf "${GRAYB}|${NC}"
                tput cup $temp 83
                printf "${GRAYB}|${NC}"
                temp=`expr $temp + 1`
            done;;
        0 | no)
            for (( i=0;i<$2;i++ ))
            do
                tput cup $temp 0
                printf "${GRAYB}|${NC}"
                tput cup $temp 83
                printf "${GRAYB}|${NC}"
                 temp=`expr $temp + 1`
            done;;
    esac
}

function BackGround() { # $1: startline / $2: howmanylines? /$3: color
    declare temp=$1

    for (( i=$temp;i<=$2;i++))
    do
        tput cup $i 0
        echo -e "$3$(Blank 83)${NC}"
    done
}
# UI Design
function UI_Design() {
    tput clear
    tput cup 0 0
    echo -e "${SBLUEB}File Explorer$(Blank 70)${NC}"
    BackGround 1 26 ${GRAYB}
    tput cup 0 0
    Repeat_Char 83 "-"
    Print_Sidebar 1 1 no #Print Current pwd space
    Repeat_Char 83 "-"
    Print_Sidebar 3 20 cen; #Print ls space
    Repeat_Char 83 "-"
    Print_Sidebar 24 1 no #Print Information about current Directory space
    Repeat_Char 83 "-"
}


# Current pwd
function Current_pwd() {
    tput cup 1 1
    printf "${GRAYB}Current path: ${PWD}${NC}" 
}

#Print Current Path
function Print_Left() {
    tput cup 3 1
    list=`ls -a`
    printf "${GRAYB}${list}${NC}"
}

# Statement bar
function Statement() {
    tput cup 24 1
}

#Main Command
UI_Design
Current_pwd
Print_Left
tput cup 26 0
