#!/usr/bin/env python2

import sys
import os
import ConfigParser
import argparse
from pypuppetdb import connect
try:
        import json
except:
        import simplejson as json

class PuppetDBInventory():
    def __init__(self):
        self.read_settings()
        self.parse_cli_args()
        if self.args.list:
            if self.puppetdb_api_version == '4':
                data = self.get_host_list_based_on_environments()
            else:
                data = self.get_host_list()

            print json.dumps(data)

    def read_settings(self):
        config = ConfigParser.SafeConfigParser()
        puppetdb_default_ini_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'puppetdb.ini')
        puppetdb_ini_path = os.environ.get('PUPPETDB_INI_PATH', puppetdb_default_ini_path)
        config.read(puppetdb_ini_path)

        if not config.has_section('server'):
            raise ValueError('puppetdb.ini file must contain a [server] section')

        if config.has_option('server', 'host'):
            self.puppetdb_server = config.get('server', 'host')
        else:
            raise ValueError('puppetdb.ini does not have a server - host param defined')

        if config.has_option('server', 'port'):
            self.puppetdb_server_port = config.get('server','port')
        else:
            raise ValueError('puppetdb.ini does not have a server - port param  defined')

        if config.has_option('server', 'api_version'):
            self.puppetdb_api_version = config.get('server','api_version')
        else:
            raise ValueError('puppetdb.ini does not have a server - api_version param defined')

        if config.has_option('server', 'environments'):
            self.puppetdb_environments = config.get('server','environments').split()
        else:
            raise ValueError('puppetdb.ini does not have a server - environments param defined')

    def parse_cli_args(self):
        parser = argparse.ArgumentParser(description='Produce an Ansible Inventory file based on puppetdb')
        parser.add_argument('--list', action='store_true', default=True,
                           help='List instances (default: True)')
        self.args = parser.parse_args()

    def get_host_list(self):
        db = connect(api_version=3, host=self.puppetdb_server, port=self.puppetdb_server_port)
        nodes = db.nodes()
        nodes_list = []
        for node in nodes:
            nodes_list.append(node.name)
        return { 'all': nodes_list}

    def get_host_list_based_on_environments(self):
        db = connect(api_version=4, host=self.puppetdb_server, port=self.puppetdb_server_port)
        json_data_toReturn = []
        for env in self.puppetdb_environments:
            nodes_list = []
            facts = db.facts('fqdn', environment=env)
            for fact in facts:
                nodes_list.append(fact.value)
            json_data_toReturn.append( { env: nodes_list} )

        return json_data_toReturn

def main():
    PuppetDBInventory()

if __name__ == '__main__':
    main()
