#!/bin/bash
#
# Script which can be used as an ansible dynamic inventory using the puppetdb API

# DECLARE PARAMETERS
PUPPETDBHOST='HOST:PORT'
HOSTS='\n'
ENVIRONMENTS=`ls environments | wc -l`

# LOOP THROUGH QUERIES AND STORE THE FOUND NODES INTO THE $HOSTS VARIABLE
for ENVIRONMENT in environments/*
do
	ENV=`echo $ENVIRONMENT | awk -F "/" '{print $2}'`
	HOSTS="${HOSTS}\t\"$ENV\": ["
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
	done < <(curl --silent -X GET http://$PUPPETDBHOST/v4/nodes --data-urlencode query@$ENVIRONMENT | grep certname | awk -F "\"" '{print $4}')

        # FIX FOR THE PARSE ERROR WHEN A COMMA IS FOUND AFTER LAST LIST OF NODES
	i=$(expr $i + 1)
	if [ $i == $ENVIRONMENTS ]; then
		HOSTS="${HOSTS} ]\n"
	else
		HOSTS="${HOSTS} ],\n"
	fi
done

# RETURN THE HOSTS IN JSON OUTPUT
echo -e "{${HOSTS}}"
