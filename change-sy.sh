#!/bin/sh

# change-sy.sh

# Change the show yourself program

# Should work on all Unix-like operating systems

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

pwd=$(pwd)

while getopts "cp" opt; do
    case $opt in
	c)
	    git clone https://github.com/scmaccal/sy

	    exit 0
	    ;;
	p)
	    git pull https://github.com/scmaccal/sy

	    exit 0
	    ;;
	\?)
	    echo "Option: -c to clone"
	    echo "        -p to pull\n"

	    exit 1
	    ;;
    esac
done

ls $pwd | more

printf "Local file: "
read file

printf "Commit message: "
read message

printf "Git user: "
read user

git add $file

git commit -m "$message"

git push git@github.com:$user/sy.git

exit 0
