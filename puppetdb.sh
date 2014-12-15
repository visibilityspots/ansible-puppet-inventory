#!/bin/bash
#
# Script which can be used as an ansible dynamic inventory using the puppetdb API
#
# Source: https://github.com/visibilityspots/ansible-puppet-inventory

# DECLARE PARAMETERS
ROOT_DIR='/etc/ansible/'
PUPPETDBHOST=$PUPPETDB_HOST:$PUPPETDB_PORT
HOSTS='\n'
TOTAL_ENVIRONMENTS=`ls $ROOT_DIR/environments | wc -l`
ENVIRONMENTS=$ROOT_DIR/environments/*
i=0
# LOOP THROUGH QUERIES AND STORE THE FOUND NODES INTO THE $HOSTS VARIABLE
for ENVIRONMENT in $ENVIRONMENTS
do
        ENV=`echo $ENVIRONMENT | awk -F "/" '{print $NF}'`
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
  done < <(curl --silent -X GET http://$PUPPETDBHOST/v4/nodes --data-urlencode query@$ENVIRONMENT | grep certname | grep '.*' | awk -F "\"" '{print $(NF-1)}')

        # FIX FOR THE PARSE ERROR WHEN A COMMA IS FOUND AFTER LAST LIST OF NODES
        i=$(expr $i + 1)
        if [ $i == $TOTAL_ENVIRONMENTS ]; then
                HOSTS="${HOSTS} ]\n"
        else
                HOSTS="${HOSTS} ],\n"
        fi
done

# RETURN THE HOSTS IN JSON OUTPUT
echo -e "{${HOSTS}}"
