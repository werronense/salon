#! /bin/bash
# Scrip to manage the salon database

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT * FROM services")

echo -e "\n***** SALON *****\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo -e "\nWelcome to the Salon main menu. How can I help you?.\n"
  fi
  
  # list all services with a loop
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    # print individual service
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # insert a prompt
  echo -e "\nEnter the number of the service you would like:"

  # read the input
  read SERVICE_ID_SELECTED

  # if selection not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # return to main menu
    MAIN_MENU "Sorry, that is not a valid number. Please enter a number."
  else
    # get the service name
    SERVICE_SELECTED_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    # if service does not exist
    if [[ -z $SERVICE_SELECTED_NAME ]]
    then
      # return to main menu
      MAIN_MENU "Sorry, we do not offer that service. Please choose again."
    else
      # request a phone number
      echo -e "\nPlease enter you phone number:"
      read CUSTOMER_PHONE

      # get customer using phone number
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if customer does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        # create customer
        echo -e "\nPlease enter your name:"
        read CUSTOMER_NAME

        INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # request appointment time
      echo -e "\nPlease enter a time:"
      read SERVICE_TIME

      # create appointment
      INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
      echo -e "\nI have put you down for a $SERVICE_SELECTED_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU
