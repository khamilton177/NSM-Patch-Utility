# NSM-Patch-Utility
#### Just a sampe of Perl scripts created for patching Unicenter NSM

This scipt will do windows and all unix flavors in Server environment.  It will identify flavor, CAM version and build then update accordingly.


1. Create a text file server list that can consist of either server names, FQN's (for unix), or IP addresses.  The list must begin on the second line.  Only like type OS machines in the list ie...Windows or Unix.

2. Script will prompt user for User name and Password.  Window machines need a user with administrative rights.

3. Script will prompt for server list file name.

4. Script will prompt for OS type.

5. For Unix-

* Script will FTP all required files to /opt/tng/aw/services.
* Script will TELNET to machine and uncompress then run executable.

7. For Windows-

* Script will use bat file to map, copy, and execute Xcmd.

* Xcmd is a telnet like program that will do the uncompress and run executable.
