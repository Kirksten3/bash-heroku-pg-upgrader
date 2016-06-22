#!/bin/bash

# clear screen
clear

#initial state
state="start"
name=""

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'


function menu {
    printf "Heroku PG Upgrader Main Menu\n"
    printf "(1) Set / Change Heroku appname \"${BLUE}$name${NC}\"\n"
    if [ $state == "joined" ]
        then
            printf "(2) DB Upgrade Menu\n"
    fi
    printf "(x) Exit\n"
    printf "Choice: "
    read choice
    case "$choice" in
        "1")
            get_app_name
            ;;
        
        "2")
            if [ "$state" == "joined" ]
                then
                    # STATE JOIN STUFF
                    database_upgrader_menu
            fi
            ;;
        
        [xX])
            exit 0
            ;;
    esac
}

function database_upgrader_menu {
    printf "Database Upgrade Menu for \"${BLUE}$name${NC}\"\n"
    printf "(1) View ${GREEN}pg:info${NC} + ${GREEN}pg:backups schedules${NC} + ${GREEN}dynos${NC}\n"
    if [ "$state" != "addon_created" ]
        then
            # option 2 will go here
            printf "(2) Create new pg addon\n"
    fi
    if [ "$state" == "addon_created" ]
        then
            printf "Addon created OPTION 3\n"
    fi
    printf "(10) Clean Schedules\n"
    printf "(x) Exit to Main Menu\n"
    printf "Choice: "
    read choice
    
    case "$choice" in
        "1")
            printf "\npg:info\n-------\n"
            pg_info=`heroku pg:info -a $name`
            # needed to output the result
            echo "${pg_info}"
            printf "\npg:backup schedules\n-------------------\n"
            schedules=`heroku pg:backups schedules -a $name`
            echo "${schedules}"
            printf "\ndynos\n-----\n"
            dynos=`heroku ps -a $name`
            echo "${dynos}"
            printf "\n"
            database_upgrader_menu
            ;;
        "2")
            ;;
        "3")
            ;;
        "4")
            ;;
        "10")
            ;;
        [xX])
            menu
            ;;
        [dD])
            test_delete_mode
            ;;
    esac
}

# grab and set app name
function get_app_name {
    state="new"
    printf "Enter app name: "
    read name
    join_app
}

# join the app on heroku
function join_app {
    printf "Joining $name"
    status=`heroku join -a $name`
    if [ "$status" == "" ]
        then
            echo "Joined $name successfully."
            state="joined"
    fi
    # visual spacing
    printf "\n"
    database_upgrader_menu 
}

function create_addon {
    printf "Create a (b)asic, (F)ree, or (S)tandard PG DB?\n"
    printf "Choice: "
    read db_type
    case "$db_type" in
        [bB])
            add_on=`heroku addons:create heroku-postgresql:hobby-basic -a $name`
            ;;
        [fF])
            add_on=`heroku addons:create heroku-postgresql:hobby-dev -a $name`
            ;;
        [sS])
            add_on=`heroku addons:create heroku-postgresql:standard -a $name`
            ;;
    esac
}

function test_delete_mode {
    printf "${RED}ENTERED TEST DELETE MODE${NC}\n"
    echo "${pg_info}"
    printf "\nWhich database should be deleted? Enter exact name.\n"
    printf "Choice: "
    read db_delete
    printf "\nType CONFIRM to confirm the deletion: "
    read confirm
    case "$confirm" in
        [cC][oO][nN][fF][iI][rR][mM])
            
            ;;
}

menu
