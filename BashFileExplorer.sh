#!/bin/bash

# Author : Seungho Song(KWU. Software. 2019203037)
# Last Update : 2020. 05. 11

#Colors
#fg(..;**;..) : 30-black / 31-red / 32-green / 33-brown / 34-blue
#bg(..;..;**) : 40-black / 41-red / 42-green / 43-brown / 44-blue / 46-skyblue / 47-gray

#foreground with gray background
declare RED='\033[0;31;47m'
declare BLUE='\033[0;34;47m'
declare GREEN='\033[0;32;47m'
declare BLACK='\033[0;30m'
declare NC='\033[0m'
declare BROWN='\033[2;33;47m'

#background with black foreground
declare GRAYB='\033[0;30;47m'
declare SBLUEB='\033[0;30;46m' #skyblue bg with black fg

#Cursors
declare UP=[A
declare DOWN=[B
declare RIGHT=[C
declare LEFT=[D

#data arrays
declare -a D_array1; declare -a D_array2; declare -a D_array3
declare -a X_array1; declare -a X_array2; declare -a X_array3
declare -a F_array1; declare -a F_array2; declare -a F_array3

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
    printf "${BROWN}Current path: ${PWD}${NC}" 
}

#Print Current Path (List ver.)
function Print_Left() {
    declare -i index
    declare -i temp
    declare -i flag
    declare -i flag2
    
    unset D_array1; unset D_array2; unset D_array3;
    unset X_array1; unset X_array2; unset X_array3;
    unset F_array1; unset F_array2; unset F_array3;

    for (( i=3;i<=22;i++ )) #save in each array
    do
        temp=$i
        index=temp-1
        var=`ls -alh | tr -s " " | sort -k 9 | head -"${index}" | tail -1`
        lvar=`ls -alh | tr -s " " | sort -k 9 | tail -1`
        findvar=`ls -alh | tr -s " " | sort -k 9 | head -"${index}" | tail -1 | cut -d " " -f 9`
        name=`echo "${var}" | cut -d " " -f 9`
        access=`echo "${var}" | cut -d " " -f 1`
        size=`echo "${var}" | cut -d " " -f 5`
        fvar="${PWD}/${findvar}"
        lastlist="${PWD}/${lvar}"

        if [ -d "${fvar}" ]; then #for Directories
            D_array1+=(${name}); D_array2+=(${access}); D_array3+=(${size})
        elif [ -x "${fvar}" ]; then #for Exectue files
            X_array1+=(${name}); X_array2+=(${access}); X_array3+=(${size})
        else #for normal files
            F_array1+=(${name}); F_array2+=(${access}); F_array3+=(${size})
        fi
        if [ "${var}" = "${lvar}" ]; then #if it is the last line, get the end
            break;
        fi
    done

    for (( i=0;i<${#D_array1[@]};i++)) #Directory Print
    do
        printf "${BLUE}"
        declare -i var=$i
        declare -i num=$i+3

        tput cup ${num} 1
        echo "${D_array1[$i]}"

        tput cup ${num} 18
        echo "${D_array2[$i]}"

        tput cup ${num} 35
        if [ "${D_array1[$i]}" = "." ] || [ "${D_array1[$i]}" = ".." ]
        then
            echo "-"
        else
            echo "${D_array3[$i]}"
        fi
        printf "${NC}" # End of default fg color
        flag=$num
    done

    for (( i=0;i<${#X_array1[@]};i++)) #Execute file print
    do
        printf "${GREEN}" #for Exectue files
        num=${flag:=2}+$i+1
        tput cup ${num} 1
        echo "${X_array1[$i]}"

        tput cup ${num} 18
        echo "${X_array2[$i]}"

        tput cup ${num} 35
        echo "${X_array3[$i]}"
        printf "${NC}" # End of default fg color
        flag2=$num
    done

    for (( i=0;i<${#F_array1[@]};i++)) #Normal files print
    do
        printf "${GRAYB}" #for normal files

        num=${flag2:=$flag}+$i+1
        tput cup ${num} 1
        echo "${F_array1[$i]}"

        tput cup ${num} 18
        echo "${F_array2[$i]}"

        tput cup ${num} 35
        echo "${F_array3[$i]}"
        printf "${NC}" # End of default fg color
    done
}

# Print Current Path (Tree ver.)

#Is directory have any sub-files or sub-directory
function IsitExist() { # $1:want to find directory 1: true 2: false
    files=(${1}/*)
    if [ ${#files[@]} -gt 0 ]; then
        return 1
    else    return 2
    fi
}

function PrintTree() {

}

function Print_Right() {
    curdir=`pwd | rev | cut -d "/" -f 1 | rev`

    tput cup 3 42
    echo "${curdir}"
    if [ $(IsitExist curdir)]
   
}

# Statement bar
function Statement() {
    printf "${GRAYB}"
    tput cup 24 5
        dirlen=`ls -al | grep ^d | wc -l`
        declare -i dirnum=${dirlen}-2 # extract . and ..
        echo "Directory : ${dirnum}" 
    
    tput cup 24 25
        filelen=`ls -al | grep ^- | wc -l`
        echo "File : ${filelen}"

    tput cup 24 43
        directory_size=`du -sh | awk '{print $1}'`
        echo "Current Directory Size : ${directory_size}"
    
    printf "${NC}"
}

#Main Command
UI_Design
Current_pwd
Print_Left
Print_Right
Statement
tput cup 27 0
