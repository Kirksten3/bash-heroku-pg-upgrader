#!/bin/bash

state=""
name=""
cname=""

pg_info=""
schedules=""
dynos=""

# grab and set app name
function get_app_name {
    state="new"
    printf "Enter app name: "
    prev_name=$name
    read name
    cname="${BLUE}${name}${NC}"
}


# join the app on heroku
function join_app {
    printf "Joining $cname"
    status=`heroku join -a $name`
    if [ "$status" == "" ]
        then
            # process will be waited for in database_upgrader_menu

            printf "Joined $cname successfully.\n"
            state="joined"
    fi
    # visual spacing
    printf "\n"
}


function get_pg_info {
    pg_info=`heroku pg:info -a $name`
}

function get_pg_backups_schedules {
    schedules=`heroku pg:backups schedules -a $name`
}

function get_dynos {
    dynos=`heroku ps -a $name`
}

function create_addon {
    printf "Create a (B)asic, (F)ree, or (S)tandard PG DB?\n"
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
    printf "$add_on\n"
    pg_wait=`heroku pg:wait -a $name`
    state="addon_created"
}

function test_delete_mode {
    printf "\n${RED}ENTERED TEST DELETE MODE\n------------------------${NC}\n"
    echo "${pg_info}"
    printf "\nWhich database should be deleted? Enter exact name or (x) to cancel.\n"
    printf "Choice: "
    read db_delete
    
    if [ "$db_delete" == "x" -o "$db_delete" == "X" ]
        then
            return 1;
    fi

    printf "\nType CONFIRM to confirm the deletion or (x) to exit: "
    read confirm
    case "$confirm" in
        [cC][oO][nN][fF][iI][rR][mM])
                printf "${RED}$db_delete${NC} will be deleted.\n"
                del=`heroku addons:destroy $db_delete -a $name --confirm mj-hub`
                printf "$del"
                printf "\nDeletion Successful.\n"
                return 0;
            ;;
        [xX])
            return 1;
            ;;
    esac
}
