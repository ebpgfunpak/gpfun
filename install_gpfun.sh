#!/bin/bash
#               gpfun installation script v2

# This script will download gpfun from github, then will
# unpack the tar file in /usr/local/bin/ebpg_funpak, creating
# the folder /usr/local/bin/ebpg_funpak/gpfun.
# It will check your command PATH and update it in /etc/bashrc.
#
# This installation works only for RHEL-8 or Rocky-8 Linux.
# Gpfun is for EBPG system with UPG pattern generators,
# not for older GPG systems.

#
# You can run this script from a terminal window with
#
#      ./install_gpfun.sh 
#
# This script will check that you have 
# python3, gpfgtx, gtxgpf, and cview.

# The .ui files describing dialog boxes will be in
# /usr/local/bin/ebpg_funpak/gpfun, along with png files
# and the utility gpfmerge. If you have an old version
# of gpfmerge then this new one will appear ahead of it
# in the PATH. You can rename the old gpfmerge, if you
# want it for some reason. You really should not.

# Gpfun is packaged with fbs and so the package
# contains all the required libraries and modules.
# For now, source code for gpfun is not included.
 
# Changing the 'path=' line below will change the
# installation directory, but that's a bad idea
# because it has not been tested.

# The 'update' button in gpfun passes in the command 
# path directory, so let's look at the argument list.

argc=$#

if [ $argc != 1 ]; then
    path="/usr/local/bin/ebpg_funpak/gpfun"
else
    path="$1"
fi


if ! command -v python3 > /dev/null ; then
    echo
    echo "ERROR"
    echo "gpfun requires python3, which is"
    echo "normally installed by default. "
    echo "If your system is registered"
    echo "with a linux repository, you can "
    echo "install python3 with..."
    echo
    echo "dnf install -y python3-devel"
    echo "dnf install -y PyQt5"
    echo
    echo "gpfun installation failed."
    echo
    exit
fi

# trim 'gpfun' off the command path to get the target directory
# it is important that the path not end with /

target=`python3 -c "x='$path' ; y=x.split('/') ; print(x[:-(len(y[-1])+1)] )"`
basedir=`python3 -c "x='$target' ; y=x.split('/') ; print(x[:-(len(y[-1])+1)] )"`
    
echo
echo
echo "Installation of gpfun on a RHEL or Rocky system."
echo
echo "Target directory: $target"
echo


# target is normally /usr/local/bin/ebpg_funpak

# check the Linux version

RHEL=`uname -r | grep -Po ".el\K[^.]"`

echo
if [ $RHEL == "7" ]; then
    echo "RHEL 7"
    echo
    RHEL7=1
    tarfile="gpfun_el7.tar.gz"
    #
elif [ $RHEL == "8" ]; then
    echo "RHEL 8"
    echo
    RHEL7=0
    tarfile="gpfun_el8.tar.gz"
    #
elif [ $RHEL == "9" ]; then
    echo "RHEL 9"
    echo
    echo "Sorry, this installation is for RHEL-7 or RHEL-8, not RHEL-9."
    echo
    exit
elif [ $RHEL == "10" ]; then
    echo "RHEL 10"
    echo
    echo "Sorry, this installation is for RHEL-7 or RHEL-8, not RHEL-10."
    echo
    exit
else
    echo "Is this a Red Hat or Rocky linux system? "
    echo "This installation script works only for "
    echo "RHEL or Rocky 8."
    echo
    echo "An EBPG console normally runs version 8."
    echo 
    exit
fi

echo  


if [ `whoami` != "root" ]; then
    echo
    echo "ERROR: You must be root to install or update gpfun."
    echo "       please use su to become root, then run this "
    echo "       script again (or click on 'update' in gpfun)."
    echo
    exit
fi


# check the command path for the Raith utilities

# It's tempting to run
# . /etc/bashrc
# . /home/pg/pg_local
# but this might cd $HOME, which confuses the heck
# out of the shell, causing it to get the default
# directory wrong. Then pwd doesn't work
# and it's a mess.


ok=1

if ! command -v gpfgtx > /dev/null ; then
    echo
    echo "ERROR: gpfgtx is not installed on this system."
    echo "       You can copy gpfgtx from an EBPG system, or"
    echo "       you can install gpfun on an EBPG console."
    echo
    ok=0
else
    echo "gpfgtx ok"
fi

if ! command -v gtxgpf > /dev/null ; then
    echo
    echo "ERROR: gtxgpf is not installed on this system."
    echo "       You can copy gtxgpf from an EBPG system, or"
    echo "       you can install gpfun on an EBPG console."
    echo
    ok=0
else
    echo "gtxgpf ok"
fi

if ! command -v cview > /dev/null ; then
    echo
    echo "ERROR: cview is not installed on this system."
    echo "       You can copy cview from an EBPG system, or"
    echo "       you can install gpfun on an EBPG console."
    echo "       Look for the file INSTALL_CVIEW for instructions."
    echo
    ok=0
else
    echo "cview ok"
fi

if [ $ok == 0 ]; then exit ; fi


    
echo
echo "Downloading the update..."
echo

if [ -f $tarfile ]; then rm $tarfile ; fi

wget https://github.com/ebpgfunpak/gpfun/blob/main/$tarfile?raw=true -O $tarfile

if [ ! -f $tarfile ]; then
    echo
    echo "ERROR: unable to download $tarfile"
    echo
    exit
fi

pushd .

if [ `pwd` != $target ]; then
    mv $tarfile $target/
    cd $target
fi



# we do not need to check for the python modules
# since fbs packages them for us - even QT5.

# target is normally /usr/local/bin/ebpg_funpak
# first we check that $basedir, /usr/local/bin, exists


if [ ! -d $basedir ]; then
    echo
    echo "The directory $basedir does not exist."
    read -p "Do you want me to create this directory?  y/n > " ans
    if [ $ans == 'y' ] || [ $ans == 'Y' ]; then
        echo
        echo "ok..."
        mkdir $basedir
        if [ ! -d $basedir ]; then
            echo
            echo "ERROR: unable to create $basedir"
            echo
            exit
        fi
    else
        echo
        echo "Well ok, but I will have to stop here."
        echo "You can change the target directory at the top of this script,"
        echo "or you can create the directory manually with 'mkdir'."
        echo
        exit
    fi
fi
    

if [ ! -d $target ]; then
    echo "The directory $target does not exist."
    echo "Now I will create it..."
    mkdir $target
    if [ ! -d $target ]; then
        echo
        echo "ERROR: Unable to create $target"
        echo
        exit
    fi
fi

# move the distro to $target, normally /usr/local/bin/ebpg_funpak
# wget put the tar file in the default directory.

here=`pwd`
echo "Current directory: $here"
echo

if [ $here == $target ]; then
    echo
    echo "We are in the right folder, $here"
    echo "That's great!"
    echo
    if [ ! -f $tarfile ]; then
        echo
        echo "ERROR: I was expecting to find $tarfile in this directory."
        echo "       Please put $tarfile in the same folder as install_gpfun.sh"
        echo "       Put them both in $target and try again."
        echo
        exit
    fi
else
    echo
    echo "Moving the gpfun distro to $target ..."
    echo
    if [ ! -f $tarfile ]; then
        echo
        echo "ERROR: I was expecting to find $tarfile in the default directory."
        echo "       Please put $tarfile and install_gpfun.sh in the folder $target."
        echo "       Then 'cd $target' and try ./install_gpfun.sh again."
        echo
        exit
    fi
       
    mv $tarfile $target/
fi

echo
echo "Unpacking the tar file..."
echo

cd $target 
tar xzf $tarfile
ls -F --color=auto

echo
echo "Copying the desktop icon to /home/$USER/Desktop, /home/pg/Desktop and /etc/skel..."
echo
echo "                    If you want all the current users to see the icon, you should copy"
echo "                    gpfun.desktop to each /home/username/Desktop folder."
echo

if [ ! -d /etc/skel/Desktop ]; then
    mkdir /etc/skel/Desktop
fi

cp gpfun.desktop /etc/skel/Desktop/

cp gpfun.desktop /home/$USER/Desktop/

if [ -d /home/pg ]; then
    cp gpfun.desktop /home/pg/Desktop/
fi



echo "Checking the command path... "

if [ `echo $PATH | grep -c $target/gpfun` != "1" ]; then
    echo
    echo "        adding $target/gpfun to command path... "
    echo
    if [ -f /home/pg/pg_local ]; then
        echo -e "\nexport PATH=$target/gpfun:\$PATH\n" >> /home/pg/pg_local
    elif [ -f /etc/bashrc ]; then
        echo -e "\nexport PATH=$target/gpfun:\$PATH\n" >> /etc/bashrc
    else
	echo
	echo "I can't find either /etc/bashrc or /home/pg/pg_local"
	echo "So this is probably not a Red Hat or Rocky linux box."
	echo "I'm going to stop now."
        echo "Try editing install_gpfun.sh to make it set PATH correctly,"
        echo "or add $target/gpfun to PATH manually."
	echo
	exit
    fi
else
    echo
    echo "        $target/gpfun is in the command path already!"
    echo
fi


echo
echo "We can test the installation now. Please IGNORE whiney warning messages like..."
echo
echo "     QstardardPths...not owned by UID"
echo "     Qt: Session management error Authentication..."
echo "     QXcbConnection XCB error BadWindow..."
echo
echo "Note that you must be using a graphical display, not just a remote terminal."
echo "You can test your graphics with the command 'gedit' (a common editing program.) "
echo "If this command does not pop up new window, then something is wrong with "
echo "your connection. For example, you might try 'ssh -Y' instead of 'ssh' "
echo
read -p "Are you ready to proceed with the test?  y/n > " answer

if [ $answer != 'y' ] && [ $answer != 'yes' ] && [ $answer != 'Y' ]; then
    echo
    echo "Very well, please test gpfun yourself by typing 'gpfun' in a terminal window."
    echo
    echo "You must also have installed the Raith utilities gpfgtx, gtxgpf, and cview."
    echo "These programs are available on any EBPG console computer."
    echo
else
    if [ -f /home/pg/pg_local ]; then
        bash -c ". /home/pg/pg_local ; cd ; gpfun"
    else
	bash -c ". /etc/bashrc ; cd ; gpfun"
    fi
    echo
fi

popd

echo
echo "====================================================================="
echo
echo "If the gpfun window poped up, then the installation was successful."
echo "If not, please try again or send a message to ebpgfunpak@gmail.com"
echo
echo "You can run gpfun with the desktop icon, or you can type 'gpfun'"
echo "in a terminal window. Use 'gpfun filname' to set the output file name"
echo "with fewer clicks."
echo
echo "====================================================================="
echo



