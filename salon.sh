#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nHow may I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]
  then
    echo "Sorry, we don't have available services"
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  read SELECTED_SERVICE
    if [[ ! $SELECTED_SERVICE =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Sorry, not a valid number! Please, enter a valid option."
    else
      CHOOSED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SELECTED_SERVICE")
      if [[ -z $CHOOSED_SERVICE ]]
      then
        MAIN_MENU "Non-existent service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          if [[ -z $CUSTOMER_NAME ]]
          then
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SELECTED_SERVICE")
          echo "What time would you like your $(echo $CHOOSED_SERVICE | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $(echo $CHOOSED_SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        else
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SELECTED_SERVICE")
        echo "What time would you like your $(echo $CHOOSED_SERVICE | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SELECTED_SERVICE, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a $(echo $CHOOSED_SERVICE | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi
      fi
    fi
  fi
}

MAIN_MENU
