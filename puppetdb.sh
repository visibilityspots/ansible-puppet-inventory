#!/bin/bash
#
# Script which can be used as an ansible dynamic inventory using the puppetdb API

PUPPETDBHOST='NAME:PORT'

# CATCH HOSTS FOR THE DEVELOPMENT ENVIRONMENT
HOSTS="\n\t\"development\": ["
FIRST_HOST="true"

while read hostname
do
  # this way i don't get a trailing comma
  if [ "${FIRST_HOST}" == "true" ]
  then
    HOSTS="${HOSTS} \"${hostname}\""
    unset FIRST_HOST
  else
    HOSTS="${HOSTS}, \"${hostname}\""
  fi
done < <(curl --silent  -X GET http://$PUPPETDBHOST/v4/nodes --data-urlencode query@development | grep certname | awk -F "\"" '{print $4}')

HOSTS="${HOSTS}],\n"

# CATCH HOSTS FOR THE PRODUCTION ENVIRONMENT
HOSTS="${HOSTS}\t\"production\": ["
FIRST_HOST="true"

while read hostname
do
  # this way i don't get a trailing comma
  if [ "${FIRST_HOST}" == "true" ]
  then
    HOSTS="${HOSTS} \"${hostname}\""
    unset FIRST_HOST
  else
    HOSTS="${HOSTS}, \"${hostname}\""
  fi
done < <(curl --silent  -X GET http://$PUPPETDBHOST/v4/nodes --data-urlencode query@production | grep certname | awk -F "\"" '{print $4}')

HOSTS="${HOSTS} ]\n"

# RETURN THE HOSTS IN JSON OUTPUT
echo -e "{${HOSTS}}"
