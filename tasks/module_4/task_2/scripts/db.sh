#!/bin/bash

typeset fileName=users.db
typeset fileDir=../data
typeset filePath=$fileDir/$fileName
COMMAND="$1"
EXTRA_COMMAND="$2"

function help {
    echo "Manages users in db. It accepts a single parameter with a command name."
    echo
    echo "List of available commands:"
    echo
    echo "add       Adds a new line to the users.db. Script must prompt user to type a
                    username of new entity. After entering username, user must be prompted to
                    type a role."
    echo "backup    Creates a new file, named" $filePath".backup which is a copy of
                    current" $fileName
    echo "restore   Takes the last created backup file and replaces users.db with it"
    echo "find      Prompts user to type a username, then prints username and role if such
                    exists in users.db. If there is no user with selected username, script must print:
                    “User not found”. If there is more than one user with such username, print all
                    found entries."
    echo "list      Prints contents of users.db in format: N. username, role
                    where N – a line number of an actual record
                    Accepts an additional optional parameter inverse which allows to get
                    result in an opposite order – from bottom to top"
}

function validate {
  if [[ "$1" =~ ^[[:alpha:]]+$ ]]; then return 1; else return 0; fi
}

function addToFile {
    echo "${username}, ${role}" | tee -a $filePath >/dev/null
}

function checkCreateFile {
    if [[ ! -d ../data ]];
 then 
    createFolder
 fi
 if [[ ! -f ../data/users.db ]];
 then 
    createFile
 fi
}

function createFile {
    touch $fileName
}

function createFolder {
    mkdir $fileDir
}

function add {
    read -p "Enter user name: " username
    validate $username
    if [[ "$?" == 0 ]];
    then
      echo "User name must have only latin letters. Try again."
      exit 1
    fi

    read -p "Enter user role: " role
    validate $role
    if [[ "$?" == 0 ]]
    then
      echo "User role must have only latin letters. Try again."
      exit 1
    fi

    echo "User and role successfully added"

    addToFile $username $role
}

function backup {
  backupFileName=$(date +%Y%m%d)-users.db.backup
  cp $filePath $fileDir/$backupFileName

  echo "Backup is created."
}

function restore {
  BACKUP_FILE="*-users.db.backup"

  lastBackupFileName=$(find "$fileDir" -type f -name "$BACKUP_FILE" -exec stat -f '%B %N' {} + | sort -n | tail -n 1 | cut -d' ' -f2-)

if [[ -n "$lastBackupFileName" ]]; then
    cp $lastBackupFileName $filePath 
    echo "users.db is restored"
else
    echo “No backup file found”
fi
}

function findUser {
    read -p "Find user name: " username

    if [[ "$username" != "" ]]
    then
    if grep -F -w "$username" "$filePath"
      then 
        exit 1
      fi
    fi

    echo "User not found."
}

function list {
    if [[ "$EXTRA_COMMAND" == "--inverse" ]]
    then
    row_number_inverse=$(grep -c "^" "$filePath")
      while IFS= read -r line; do
      echo "$row_number_inverse. $line"
     ((row_number_inverse--))
    done < "$filePath"
      exit 0
    fi

    row_number=1

    while IFS= read -r line; do
      echo "$row_number. $line"
     ((row_number++))
    done < "$filePath"
}

case $COMMAND in

  "help")
    help
    ;;

  "add")
    checkCreateFile
    add
    ;;

  "backup")
    checkCreateFile
    backup
    ;;

  "restore")
    checkCreateFile
    restore
    ;;

  "find")
    checkCreateFile
    findUser
    ;;

  "list")
    checkCreateFile
    list
    ;;

  *)
    help
    ;;
esac
