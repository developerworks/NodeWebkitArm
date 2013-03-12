import os
import sys
import subprocess

class setup:

	_targets = [ "CHROMIUM", "NODEWEBKIT" ]
	_platforms = [ "ARM" , "ANDROID" , "LINUX" ]

	_target = ""
	_platform = ""

	_rootpath = ""
	_destpath = ""

	def printError(self, msg):
		print "Setup: " + msg + ". exiting."
		sys.exit(1)

	def printMsg(self, msg):
		print "Setup: " + msg

	def __init__(self, target, platform):

		target = target.lower()
		if any(target in s for s in _targets):
			_target = target
		else:
			printError("target '" + target + "' is not a supported type")

		platform = platform.lower()
		if any(platform in s for s in _platforms):
			_platform = platform
		else:
			printError("platform '" + platform + "' is not a supported type")

		if ! os.environ["CHROMIUM_TOOLS"]:
			printMsg("Environment has not been configured")

	def clean(self):

	def config(self):

	def build(self):

	def install(self):

		with open("~/.bashrc", "a") as bashrc:

			if ! os.environ["CHROMIUM_TOOLS"]:
    			bashrc.write("export CHROMIUM_TOOLS=" + os.getcwd())

    		# create environmental variable for this platform/target combination
    		# also, create path if it doesn't yet exist
    		target_env = (_target + '_' + _platform).upper()
			if ! os.environ[ target_env.upper() ]:
				_destpath = _rootpath + "/" + target_env.lower()
    			bashrc.write("export " + target_env.upper() + "=" + _rootpath + "/" + target_env.lower())
    			subprocess.check_call(["mkdir",_destpath], shell=True)




# do it
