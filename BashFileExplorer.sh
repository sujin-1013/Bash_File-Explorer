#!/bin/bash

# Author : Seungho Song(KWU. Software. 2019203037)
# Last Update : 2020. 05. 13 07:48

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

#for cursor
declare CUR='\033[0;44m'

#background with black foreground
declare GRAYB='\033[0;30;47m'
declare SBLUEB='\033[0;30;46m' #skyblue bg with black fg

#Cursors
declare UP=[A
declare DOWN=[B
declare RIGHT=[C
declare LEFT=[D
declare ENTER=""



#data arrays
declare -a D_array1; declare -a D_array2; declare -a D_array3
declare -a X_array1; declare -a X_array2; declare -a X_array3
declare -a F_array1; declare -a F_array2; declare -a F_array3
declare -a Total1;declare -a Total2;declare -a Total3;

# Basic Utility functions

function Coloring() {
    printf "$1"; echo "$2"; printf "${NC}"
    declare original_color=$1
    declare str=$2
}
function ChangeColoring() {
    printf "$2"; echo "$1"; printf "${NC}"
    declare letter=`echo "$1"`
}

function Tree() { 
    declare -ar treearray=("├" "└" "│" "─")
    printf "${GRAYB}"
    case "$1" in
        1) printf "${treearray[0]}" ;;
        2) printf "${treearray[1]}" ;;
        3) printf "${treearray[2]}" ;;
        4) printf "${treearray[3]}" ;;
        *) echo "Error: Invalid answer." ;;
    esac
    printf "${NC}"
}

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


###################################################################


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

#######################################################################

#Print Current Path (List ver.)
function Print_Left() {
    declare -i index
    declare -i temp
    local  -i flag
    local -i flag2
    
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

    Total1+=(${D_array1[@]}); Total1+=(${X_array1[@]}); Total1+=(${F_array1[@]})
    Total2+=(${D_array2[@]}); Total2+=(${X_array2[@]}); Total2+=(${F_array2[@]})
    Total3+=(${D_array3[@]}); Total3+=(${X_array3[@]}); Total3+=(${F_array3[@]})
    #echo "${Total[0]}"

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
         #for Exectue files
        num=${flag:=2}+$i+1
        tput cup ${num} 1
        Coloring $GREEN ${X_array1[$i]}

        tput cup ${num} 18
        Coloring $GREEN ${X_array2[$i]}

        tput cup ${num} 35
        Coloring $GREEN ${X_array3[$i]}
         # End of default fg color
        flag2=$num
    done

    for (( i=0;i<${#F_array1[@]};i++)) #Normal files print
    do
        #for normal files

        num=${flag2:=$flag}+$i+1
        tput cup ${num} 1
        Coloring ${GRAYB} ${F_array1[$i]}

        tput cup ${num} 18
        Coloring ${GRAYB} ${F_array2[$i]}

        tput cup ${num} 35
        Coloring ${GRAYB} ${F_array3[$i]}
        # End of default fg color
    done
#Erase
        declare -i direc2=`expr $2 + 3`
        for (( i=1;i<=40;i++ ))
        do
            tput cup $direc2 $i
            Coloring $GRAYB " "
        done
        tput cup $direc2 1 # $2: wanna direction to cursor
        Coloring $GRAYB ${Total1[$2]}
        
        tput cup $direc2 18 # $2: wanna direction to cursor
        Coloring $GRAYB ${Total2[$2]}

        tput cup $direc2 35 # $2: wanna direction to cursor
        if [ "$direc2" = "3" ] || [ "$direc2" = "4" ]
        then
            Coloring $GRAYB "-"
        else 
            Coloring $GRAYB ${Total3[$2]}
        fi
#Override   
    declare -i direc=`expr $1 + 3`
        for (( i=1;i<=40;i++ ))
        do
            tput cup $direc $i
            Coloring $CUR " "
        done
        tput cup $direc 1 # $1: wanna direction to cursor
        Coloring $CUR ${Total1[$1]}
        
        tput cup $direc 18 # $1: wanna direction to cursor
        Coloring $CUR ${Total2[$1]}

        tput cup $direc 35 # $1: wanna direction to cursor
        if [ "$direc" = "3" ] || [ "$direc" = "4" ]
        then
            Coloring $CUR "-"
        else 
            Coloring $CUR ${Total3[$1]}
        fi
#########################################################
        
}


############################################################################


function STR_to_pwd() { # $1: aimed directory in curdir
    if [ "$1" = "pwd" ]; then
        echo "${PWD}"
    else
    echo "${PWD}/${1}"
    fi
}

#Is directory have any sub-files or sub-directory
function IsitExist() { # $1:want to find directory 1: true 0: false

    #local curpath_d="$(STR_to_pwd $1)"
    local curpath="$(STR_to_pwd $1)"
    local -a arr=(`ls -alF ${curpath} | grep ^d | rev | cut -d " " -f 1 | rev`)
    arr+=(`ls -alF ${curpath} | grep *$ | rev | cut -d " " -f 1 | rev`)
    arr+=(`ls -alF ${curpath} | grep ^- | grep -v *$ | rev | cut -d " " -f 1 | rev`)

    if [ ${#arr[@]} -gt 2 ]; then echo "1"
    else echo "0"
    fi
}

function move_xypos() { # $1: xpos $2: ypos $3:howmany x $3:howmany y
    
    declare -i x=`expr $1 + $3`
    declare -i y=`expr $2 + $4`
    tput cup $x $y
    #echo "test"
}

function Indent() { # $1: counter
    for(( i=0;i<$1;i++ ))
    do
        printf "$(Tree "3")  "
    done
}

declare -i tree_counter=0
declare -i x_counter=3
declare -i y_counter=41
declare -i xpos=3

# function Print_Root() { # $1:xpos $2:ypos $3: finishline
#     local -i temp_x=`expr $1 + 2`; local -i temp_y=$2
#     local -i howmany=`expr $3 - $temp_x`
#     howmany=`expr $howmany + 1`
#     for (( i=0;i<$howmany;i++ ))
#     do
#         tput cup $temp_x $temp_y
#         printf "$GRAYB" ; printf "│" ; printf "$NC"
#         temp_x=`expr $temp_x + 1`
#     done
#}

# Print Current Path (Tree ver.)
function ls_tree() { # $1 : directory name in string type $2:x axls $3: y axls
    local testvar=$(STR_to_pwd $1)
    cd ${testvar}
    local -a list_d=(`ls -al ${testvar}| grep ^d | rev | cut -d " " -f 1 |rev`) 
    local -a list_x=(`ls -alF ${testvar}| grep *$ | rev | cut -d " " -f 1 | rev`)
    local -a list_f=(`ls -alF ${testvar}| grep ^- | grep -v *$ | rev | cut -d " " -f 1 | rev`)
    local -a list_total=()
    list_total+=(${list_d[@]}); list_total+=(${list_x[@]}); list_total+=(${list_f[@]});
    local -i ypos=$3
    local -i totalnum=`expr ${#list_d[@]} + ${#list_x[@]} + ${#list_f[@]}`
    local -i sub_xpos;local -i sub_ypos; local -i i
    totalnum=`expr $totalnum - 2` # ignore "." and ".." dir
     
    move_xypos $xpos $ypos 0 0
    if [ "$1" = "pwd" ]; then Coloring $BLUE "${PWD##*/}"
    else
        Coloring $BLUE $1 
    fi

    ####################################################################################
    #local -a inner_arr=(`find `)
    # if [ $totalnum -gt 1 ]; then
    #     Print_Root $xpos $ypos $finishline
    # fi

    # Tree -> 1: ├  2: └ 3: │ 4:─ 
    for (( i=2;i<${#list_d[@]};i++ ))
    do
        lastindex_d=`expr ${#list_d[@]} - 1`
        lastindex_total=`expr ${#list_total[@]} - 1`
        if [ "${list_d[$i]}" = "${list_d[$lastindex_d]}" ]; then
            if [ "$xpos" -ge "22" ]; then break
            else
                move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "2"; Tree "4"
            fi
        elif [ "${list_d[$i]}" != "${total_list[$lastindex_total]}" ]; then
            if [ "$xpos" -ge "22" ]; then break
            else
                move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "1"; Tree "4"
            fi
        else
            if [ "$xpos" -ge "22" ]; then break
            else
            move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "1"; Tree "4"
            fi
        fi
        #Coloring $BLUE ${list_d[$i]}
        local testvarvar=$(IsitExist ${list_d[$i]})
        while [ true ]
        do
            if [ "$(IsitExist ${list_d[$i]})" = "0" ]; then
                Coloring $BLUE ${list_d[$i]}
                declare -i finishline=$xpos
                break
            else
                sub_xpos=`expr $xpos + 0`
                sub_ypos=`expr $ypos + 2`
                # #printf "  "
                #counter=`expr $counter + 1`
                ls_tree ${list_d[$i]} $xpos $sub_ypos
                #counter=`expr $counter - 1`
                break
            fi
        done
        # move_xypos $xpos $ypos 1 0
        
        
        
        
    done

    for (( i=0;i<${#list_x[@]};i++ ))
    do
        lastindex_x=`expr ${#list_x[@]} - 1`
        if [ "$xpos" -ge "22" ]; then break
        else
            if [ "${list_x[$i]}" = "${list_x[$lastindex_x]}" ]; then
                move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "2"; Tree "4"
            elif [ "${list_x[$i]}" != "${total_list[$lastindex_total]}" ]; then
                move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "1"; Tree "4"
            else move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "1"; Tree "4"
            fi
        fi
        Coloring $GREEN ${list_x[$i]}
       # move_xypos $xpos $ypos 1 0
        #xpos=`expr $xpos + 1`
        
    done

    for (( i=0;i<${#list_f[@]};i++ ))
    do
        lastindex_f=`expr ${#list_f[@]} - 1`
        if [ "$xpos" -ge "22" ]; then break
        else
            if [ "${list_f[$i]}" = "${list_f[$lastindex_f]}" ]; then
                move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "2"; Tree "4"
            else move_xypos $xpos $ypos 1 0; xpos=`expr $xpos + 1`; Tree "1"; Tree "4"
            fi
        fi
        Coloring $GRAYB ${list_f[$i]}
        #move_xypos $xpos $ypos 1 0
        #xpos=`expr $xpos + 1`
        
    done
    cd ..
}



function Print_Right() {
     tput cup 3 42
     ls_tree "pwd" 3 42
    
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

### Main Command ###

declare -i mouse=0

UI_Design
Current_pwd
Print_Left $mouse
Print_Right
Statement

    read -sn 3 key
    if [ "$key" = "$DOWN" ]; then
        mouse=`expr $mouse + 1`
        original=`expr $mouse - 1`
        Print_Left $mouse $original
        
    
    elif [ "$key" = "$ENTER" ]; then
    echo "ENTER"
    fi

tput cup 27 0
