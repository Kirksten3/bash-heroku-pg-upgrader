#!/bin/bash

# clear screen
clear

#initial state
state="start"
name=""

function menu {
    printf "Heroku PG Upgrader Main Menu\n"
    printf "(1) Set / Change Heroku appname \"$name\"\n"
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
        
        "x")
            exit 0
            ;;
    esac
}

function database_upgrader_menu {
    printf "Database Upgrade Menu for \"$name\"\n"
    printf "(1) View pg:info + pg:backups schedules + dynos\n"
    if [ "$state" != "addon_created" ]
        then
            # option 2 will go here
            printf "(2) Create new addon\n"
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
        "x")
            menu
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

menu
