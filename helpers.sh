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
    printf "Create a ${GREEN}(B)asic${NC}, ${BLUE}(F)ree${NC}, or ${RED}(S)tandard${NC} Postgresql Database?\n"
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
    printf "\n$add_on\n\n"

    db_regex="HEROKU_POSTGRESQL_[A-Z]*_URL"
    # [[ ]] is the test operator and ${BASH_REMATCH[1]} array contains the result of the match
    [[ "$add_on" =~ (HEROKU_POSTGRESQL_[A-Z]*_URL) ]] && new_db="${BASH_REMATCH[1]}"
    #pg_wait=`heroku pg:wait -a $name`
    state="addon_created"
}

function promote_copy {
    printf "pg:wait...\n"
    pg_wait=`heroku pg:wait -a $name`
    main_on=`heroku maintenance:on -a $name`
    copy_db=`heroku pg:copy DATABASE_URL $new_db --confirm $name`
    printf "$copy_db\n"
    promote_db=`heroku pg:promote $new_db -a $name`
    printf "$promote_db\n"
    state="addon_promoted"
    printf "\n"
}

function schedule_and_backup {
    # this prints itself
    main_off=`heroku maintenance:off -a $name`
    schedule=`heroku pg:backups schedule --at '02:00 America/Los_Angeles' DATABASE_URL --app $name`
    printf "$schedule\n"
    backup=`heroku pg:backups capture -a $name`
    printf "$backup\n"
    state="backed_up"
}
