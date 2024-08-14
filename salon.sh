#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "Welcome! How may I help you? Which professional would you like to see?\n"

MAIN_MENU(){ 

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE
  do
    ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $SERVICE | sed 's/ //g')
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    0) echo "Thanks for coming! See you soon\n" ;;
    [1-3]) SCHEDULE_SERVICE ;;
    *) MAIN_MENU "This service does not exist, please, try again" ;;
  esac
}

SCHEDULE_SERVICE(){ 

  echo -e "\nPlease, enter your phone number:"
  read CUSTOMER_PHONE
  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $NAME | sed 's/ //g')

  if [[ -z $NAME ]]
  then
    echo -e "\nIt seems you are new here! Can you tell me your name?"
    read CUSTOMER_NAME
    NAME=$(echo $NAME | sed 's/ //g')
    ADDING_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "Input when would you like to make an appointment."
  read SERVICE_TIME
  ADDING_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $ADDING_APPOINTMENTS == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}


MAIN_MENU