#!/bin/bash

# clear screen
clear

source colors.sh
source helpers.sh


function menu {
    printf "Heroku PG Upgrader Main Menu\n"
    printf "(1) Set / Change Heroku appname \"$cname\"\n"
    if [ "$state" == "joined" ]
        then
            printf "(2) DB Upgrade Menu\n"
    fi
    printf "(x) Exit\n"
    printf "Choice: "
    read choice
    case "$choice" in
        "1")
            get_app_name
            join_app
            database_upgrader_menu
            ;;
        
        "2")
            if [ "$state" == "joined" -o "$state" == "addon_created" ]
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
    printf "Database Upgrade Menu for \"$cname\"\n"
    printf "(1) View ${GREEN}pg:info${NC} + ${GREEN}pg:backups schedules${NC} + ${GREEN}dynos${NC}\n"
    if [ "$state" != "addon_created" ]
        then
            # option 2 will go here
            printf "(2) Create new pg addon\n"
    fi
    if [ "$state" == "addon_created" ]
        then
                printf "(3) Promote and Copy ${BLUE}$new_db${NC}\n"
    fi
    if [ "$state" == "addon_promoted" ]
        then
            printf "Set ${BLUE}$new_db${NC} Schedule and Backup\n"
    fi
    if [ "$state" == "backed_up" ]
        then
            printf "%sUpgrade Completed%s" ${RED} ${NC}
    fi
    printf "(10) Clean Schedules\n"
    printf "(x) Exit to Main Menu\n"
    printf "Choice: "
    read choice

        case "$choice" in
            "1")
                printf "\n${GREEN}pg:info\n-------${NC}\n"
                get_pg_info
                printf "%s" "${pg_info}"
                printf "\n\n${GREEN}pg:backup schedules\n-------------------${NC}\n"
                get_pg_backups_schedules
                printf "%s" "${schedules}"
                printf "\n\n${GREEN}dynos\n-----${NC}\n"
                get_dynos
                printf "%s\n\n" "${dynos}"
                
                # set as this checks whether these commands have been run for this name
                database_upgrader_menu
                ;;
            "2")
                create_addon
                database_upgrader_menu
                ;;
            "3")
                promote_copy
                database_upgrader_menu
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
                database_upgrader_menu
                ;;
        esac
}


# allow name to be entered from command line
# get length of $@
arg_len=${#@}
if [ $arg_len -eq 0 ]
    then
        menu
    else
        name=$@
        cname="${BLUE}$name${NC}"
        join_app
fi
