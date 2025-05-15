#!/usr/bin/env bash
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
#
#  Author  : Jeong Han Lee
#

declare -g SC_SCRIPT;
declare -g SC_TOP;
declare -g SUDO_CMD;
SC_SCRIPT=${BASH_SOURCE[0]:-${0}}
SC_TOP="$( cd -P "$( dirname "$SC_SCRIPT" )" && pwd )"

java -jar NTIDiscover.jar
