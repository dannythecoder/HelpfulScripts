#!/usr/bin/env python
"""
runElsewhere.py
Written by Danny Caudill (DannyTheCoder).
June 28, 2014

          Copyright Danny Caudill. 2014.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE_1_0.txt or copy at
         http://www.boost.org/LICENSE_1_0.txt)

How to use:
This module contains a class that could be used in other scripts,
as well as a main() that handles a simple use-case.

1. Create a file named 'hostlist.txt' in the current directory and
   place hostnames or IP addresses inside, one per line.
2. Create a file named 'commands.txt' in the current directory and
   place shell commands inside, one per line.  All of them will
   be executed from within different shell sessions, so commands like
   'cd' are not useful unless paired with other commands through something
   like && or ||.
3. When run, it will ask for a username and password, which it assumes
   will work for all the hosts in the list.
4. sudo and paramiko do not seem to get along very well.  There are a few
   schemes that work on some systems, and this code uses the most popular.  If
   it doesn't work, don't be too surprised.
5. Enjoy your newly available free time!

"""

# Imports
from __future__ import print_function
import socket
import paramiko
import getpass


class RunElsewhere(object):
    """ Main class for this module.

    Attributes:

        host_list (List[str]): The list of hosts to operate on.
        command_list (List[str]): The list of commands to run.
        username (str): The username to use.
        password (str): The password to use.
    """

    def __init__(self, host_file=None, cmd_file=None):
        """ Initialize the object. """
        self.host_list = []
        self.command_list = []
        self.username = ''
        self.password = ''

        if host_file:
            self.load_host_list(host_file)

        if cmd_file is not None:
            self.load_command_list(cmd_file)

        self.collect_login_creds()

    def load_host_list(self, filename):
        """ Load the list of hosts from the file. """
        with open(filename, 'r') as content:
            self.host_list = content.read().splitlines()

    def load_command_list(self, filename):
        """ Load the list of commands from the file. """
        with open(filename, 'r') as content:
            self.command_list = content.read().splitlines()

    def collect_login_creds(self):
        """ Collect the username and password from the user. """
        print('Enter Username: ')
        self.username = raw_input()
        print('Enter Password: ')
        self.password = getpass.getpass()

    def run(self):
        """ Run the commands on all the hosts

        Tip: Use the constructor that takes filenames, or call
             loadHostList(), load_command_list(), and collect_login_creds()
             before calling run().
        """
        # Debug print statements
        # print(self.host_list)
        # print(self.command_list)

        # Ensure that all config info is available
        if len(self.host_list) == 0:
            print('Hosts list is empty! Aborting.')
            exit(1)

        if len(self.command_list) == 0:
            print('Command list is empty! Aborting.')
            exit(2)

        # Connect to each host and run the commands
        for host in self.host_list:
            print('\n+++++++++++++++++++++++++++++++++++++')
            print('Connecting to', host)

            # Connect to this host
            try:
                ssh = paramiko.SSHClient()
                ssh.load_system_host_keys()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh.connect(host, username=self.username,
                            password=self.password, timeout=20)
                print('Connected.')

            except (paramiko.AuthenticationException, paramiko.SSHException,
                    paramiko.BadHostKeyException, socket.error) as exc:
                print('Failed to connect, moving on to the next host...')
                print('Reason: ', repr(exc))
                continue

            try:
                # Run the commands (if we get here, the connect() call did
                # not throw an exception, so it must have worked)
                for cmd in self.command_list:
                    print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n')
                    print('->Running Command:', cmd)
                    stdin, stdout, stderr = ssh.exec_command(cmd)
                    if cmd.startswith('sudo'):
                        stdin.write(self.password + '\n')
                        stdin.flush()

                    # Save the output
                    print('-->Output:')
                    lines = stdout.read()
                    print(lines)

                    # Save the errors
                    print('-->Errors:')
                    lines = stderr.read()
                    print(lines)
                    print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n')

                ssh.close()

            except paramiko.SSHException as exc:
                print('Failed to execute command, moving on to the '
                      'next host...')
                print('Reason: ', repr(exc))

        # Inform the user of the results
        print('\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-')
        print('Finished running commands, have a great day!')
        print('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n')

        # Done


def main():
    """Main subroutine when run as a script. """
    runner = RunElsewhere('hostlist.txt', 'commands.txt')
    runner.run()

if __name__ == '__main__':
    main()
