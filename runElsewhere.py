from __future__ import print_function
##################################
# runElsewhere.py
#  Written by Dan C.
#  June 28, 2014
#
#           Copyright Dan C. 2014.
# Distributed under the Boost Software License, Version 1.0.
#    (See accompanying file LICENSE_1_0.txt or copy at
#          http://www.boost.org/LICENSE_1_0.txt)
#
# How to use:
# This module contains a class that could be used in other scripts,
# as well as a main() that handles a simple use-case.
#
# 1. Create a file named "hostlist.txt" in the current directory and 
#    place hostnames or IP addresses inside, one per line.
# 2. Create a file named "commands.txt" in the current directory and
#    place bash shell commands inside, one per line.  All of them will
#    be executed from within different shell sessions, so commands like
#    'cd' are not useful unless paired with other commands through something
#    like && or ||.
# 3. When run, it will ask for a username and password, which it assumes
#    will work for all the hosts in the list.
# 4. Enjoy your newly available free time!
#
##################################

# Imports
import sys
import paramiko
import getpass


##################################
# Main class for this module
##################################
class RunElsewhere:
	
	def __init__(self):
		''' Initialize empty lists
		'''
		self.host_list = []
		self.command_list = []
		self.username = ""
		self.password = ""
		
	def __init__(self, host_file, cmd_file):
		''' Load the provided files
		'''
		self.loadHostList(host_file)
		self.loadCommandList(cmd_file)
		self.collectLoginCreds()
		
	def loadHostList(self, filename):
		''' Load the list of hosts from the file
		'''
		with open(filename, "r") as fd:
			self.host_list = fd.read().splitlines()
	
	def loadCommandList(self, filename):
		''' Load the list of commands from the file
		'''
		with open(filename, "r") as fd:
			self.command_list = fd.read().splitlines()
	
	def collectLoginCreds(self):
		''' Collect the username and password from the user
		'''
		print("Enter Username: ")
		self.username = raw_input()
		print("Enter Password: ")
		self.password = getpass.getpass()
		
	def run(self):
		''' Run the commands on all the hosts
			Tip: Use the constructor that takes filenames, or call
			     loadHostList(), loadCommandList(), and collectLoginCreds()
				 before calling run().
		'''
		# Debug print statements
		#print(self.host_list)
		#print(self.command_list)
	
		# Ensure that all config info is available
		if len(self.host_list) == 0:
			print("Hosts list is empty! Aborting.")
			exit(1)
		
		if len(self.command_list) == 0:
			print("Command list is empty! Aborting.")
			exit(2)
		
		# Connect to each host and run the commands
		for host in self.host_list:
			print("\n+++++++++++++++++++++++++++++++++++++")
			print("Connecting to", host)
			
			# Connect to this host
			try:
				ssh = paramiko.SSHClient()
				ssh.load_system_host_keys()
				ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
				ssh.connect(host, username=self.username, 
					password=self.password)
				print("Connected.")
			
			except:
				print("Failed to connect, moving on to the next host...")
				print("Reason: ", sys.exc_info()[0], sys.exc_info()[1])
				continue
				
			try:
				# Run the commands (if we get here, the connect() call did
				# not throw an exception, so it must have worked)
				for cmd in self.command_list:
					print("->Running Command:", cmd)
					stdin, stdout, stderr = ssh.exec_command(cmd)
					if cmd.starts_with("sudo"):
						stdin.write(self.password + '\n')
						stdin.flush()
				
				# Save the output
				print("-->Output:")
				data = stdout.read.splitlines()
				for line in data:
					print(line)

				ssh.close()
				
			except:
				print("Failed to execute command, moving on to the next host...")
				print("Reason: ", sys.exc_info()[0])
				
		# Inform the user of the results
		print("\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-")
		print("Finished running commands, have a great day!")
		print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n")
		
		# Done

##################################
# If run as a script		
##################################
def main(argv):
	runner = RunElsewhere("hostlist.txt", "commands.txt")
	runner.run()
	
if __name__ == "__main__":
	main(sys.argv)	
