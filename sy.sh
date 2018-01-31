#!/bin/sh

# sy.sh

# Find user defined physical hosts, append user defined host names
# and found IP addresses to a local/remote host file, update
# locally/remotely a host file when an IP address of a host changes,
# and make it easier to share a host file with others.

# This program should work on all Unix-like operating systems, although
# there is a chance that you will need to install the arp-scan package.
# If it is not available for your operating system, download the source
# code from here: https://github.com/royhills/arp-scan

# Copyright (C) 2017, 2018 Scott C. MacCallum
# scm@linux.com

# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

# Is this program being run by root?

CheckUser () {
    if [ "$(id -u)" != "0" ]; then
	echo "Program must be run by root!"

	exit 1
    else
	CheckDepend
    fi
}

# Are the dependent programs installed?

CheckDepend () {
    # arp-scan
    if ! [ "$(command -v arp-scan)" ]; then
	echo "arp-scan program was not found!"

	exit 1
    fi

    # cat
    if ! [ "$(command -v cat)" ]; then
	echo "cat program was not found!"

	exit 1
    fi

    # cp
    if ! [ "$(command -v cp)" ]; then
	echo "cp program was not found!"

	exit 1
    fi

    # echo
    if ! [ "$(command -v echo)" ]; then
	printf "echo program was not found!"

	exit 1
    fi

    # tr
    if ! [ "$(command -v tr)" ]; then
	echo "tr program was not found!"

	exit 1
    fi

    FindHosts
}

# Find defined hosts

FindHosts ()
{
    Host001MAC=""
    Host002MAC=""
    NetworkIP="192.168.0.0"
    CIDRSuffix="24"

    echo
    echo "Finding hosts..."

    arp-scan $NetworkIP/$CIDRSuffix | grep $Host001MAC > /tmp/arp-scan

    cat /tmp/arp | awk "{ print $1 }" > /tmp/ip

    tr -d "\n" < /tmp/ip >> $HOME/hosts

    echo "        $Host001" >> $HOME/hosts

    arp-scan $NetworkIP/$CIDRSuffix | grep $Host002MAC > /tmp/arp-scan

    cat /tmp/arp | awk "{ print $1 }" > /tmp/ip

    tr -d "\n" < /tmp/ip >> $HOME/hosts

    echo "        $Host002" >> $HOME/hosts

    cat $HOME/hosts

    BackupHosts

    exit 1
}

# Backup /etc/hosts

BackupHosts () {
    TimeStamp=$(date +%Y%m%d%H%M%S)

    echo
    echo "(1) Yes"
    echo "(2) No"
    echo -n "Make a backup copy of the local /etc/hosts file? "
    read backup

    case $backup in
	"1")
	    cp /etc/hosts /etc/hosts-$TimeStamp

	    AppendHosts

	    exit 1
	    ;;
	"2")
	    AppendHosts

	    exit 1
	    ;;
	*)
	    BackupHosts

	    exit 1
	    ;;
    esac
}

# Append found hosts to /etc/hosts

AppendHosts () {
    echo
    echo "(1) Yes"
    echo "(2) No"
    echo -n "Append found hosts to the local /etc/hosts file? "
    read append

    case $append in
	"1")
	    cat $HOME/hosts >> /etc/hosts

	    BackupRemoteHosts

	    exit 1
	    ;;
	"2")
	    BackupRemoteHosts

	    exit 1
	    ;;
	*)
	    AppendHosts

	    exit 1
	    ;;
    esac
}

# Remotely backup /etc/hosts

BackupRemoteHosts () {
    local Host001=""
    local Host002=""

    echo
    echo "(1) Yes"
    echo "(2) No"
    echo -n "Remotely backup a copy of each found hosts /etc/hosts file? "
    read RemoteBackup

    case $RemoteBackup in
	"1")
	    echo
	    echo "Preforming remote backup of the /etc/hosts file on $Host001..."

	    ssh root@$Host001 "cp /etc/hosts /etc/hosts-$TimeStamp"

	    echo
	    echo "Preforming remote backup of the /etc/hosts file on $Host002..."

	    ssh root@$Host002 "cp /etc/hosts /etc/hosts-$TimeStamp"

	    AppendRemoteHosts

	    exit 1
	    ;;

	"2")
	    AppendRemoteHosts

	    exit 1
	    ;;
	*)
	    BackupRemoteHosts

	    exit 1
    esac
}

# Remotely append found hosts to their /etc/hosts

AppendRemoteHosts () {
    local Host001=""
    local Host002=""

    echo
    echo "(1) Yes"
    echo "(2) No"
    echo -n "Remotely append each of the found hosts to their /etc/hosts file? "
    read RemoteAppend

    case $RemoteAppend in
	"1")
	    echo
	    echo "Preforming remote appending of found hosts to the /etc/hosts file on $Host001..."
	    
	    cat $HOME/hosts | ssh root@$Host001 "cat >> /etc/hosts"

	    echo
	    echo "Preforming remote appending of found hosts to the /etc/hosts file on $Host002..."
	    
	    cat $HOME/hosts | ssh root@$Host002 "cat >> /etc/hosts"

	    exit 0
	    ;;
	"2")
	    exit 0
	    ;;
	*)
	    AppendRemoteHosts

	    exit 1
	    ;;
    esac
}

CheckUser
