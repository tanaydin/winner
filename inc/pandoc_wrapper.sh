#!/usr/bin/env bash
#
# pandoc_wrapper.sh - wrapper tool to run pandoc
#
# This tool is intended to be used as a 'pandoc wrapper tool' during HTML phase number 21.
#
# This tool is intended to be invoked by a tool such as 'readme2index.sh"
# and as such, the leading options will include "-p pandoc_wrapper" and -P "optstr",
# the final arg will be in yyyy/dir form, and will be called from
# the topdir directory under which the yyyy/dir winner directory must be found.
#
# Copyright (c) 2023 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo (Landon Curt Noll, http://www.isthe.com/chongo/index.html) /\oo/\
#
# Share and enjoy! :-)

# firewall - must be bash with a version 4.2 or later
#
# We must declare arrays with -ag or -Ag
#
if [[ -z ${BASH_VERSINFO[0]} || ${BASH_VERSINFO[0]} -lt 4 || ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 2 ]]; then
    echo "$0: ERROR: bash version must be >= 4.2: $BASH_VERSION" 1>&2
    exit 4
fi

# setup bash file matching
#
# Requires bash with a version 4.2 or later
#
shopt -s nullglob	# enable expanded to nothing rather than remaining unexpanded
shopt -u failglob	# disable error message if no matches are found
shopt -u dotglob	# disable matching files starting with .
shopt -s globskipdots	# enable never matching . nor ..
shopt -u nocaseglob	# disable strict case matching
shopt -u extglob	# enable extended globbing patterns
shopt -s globstar	# enable ** to match all files and zero or more directories and subdirectories

# set variables referenced in the usage message
#
export VERSION="1.2 2023-12-31"
NAME=$(basename "$0")
export NAME
export V_FLAG=0
export PANDOC_TOOL
GIT_TOOL=$(type -P git)
export GIT_TOOL
if [[ -z "$GIT_TOOL" ]]; then
    echo "$0: FATAL: git tool is not installed or not in PATH" 1>&2
    exit 100
fi
"$GIT_TOOL" rev-parse --is-inside-work-tree >/dev/null 2>&1
status="$?"
if [[ $status -eq 0 ]]; then
    TOPDIR=$("$GIT_TOOL" rev-parse --show-toplevel)
fi
PANDOC_TOOL=$(type -P pandoc)
if [[ -z $PANDOC_TOOL ]]; then
    PANDOC_TOOL="/opt/homebrew/bin/pandoc"
fi
export PANDOC_ARGS="-f markdown -t html --fail-if-warnings=true"
export PANDOC_WRAPPER="inc/pandoc_wapper.sh"
export PANDOC_WRAPPER_OPTSTR="-f markdown -t html --fail-if-warnings=true"
export REPO_URL="https://github.com/ioccc-src/temp-test-ioccc"

# set usage message
#
export USAGE="usage: $0 [-h] [-v level] [-V] [-n] [-N]
			[-d topdir] [-p pandoc_tool] [-P pandoc_opts] [-e string ..] [-E exitcode]
			file.md output.html

	-h		print help message and exit
	-v level	set verbosity level (def level: 0)
	-V		print version string and exit

	-d topdir	set topdir (def: $TOPDIR)

	-n		go thru the actions, but do not update any files (def: do the action)
	-N		do not process file, just parse arguments and ignore the file (def: process the file)

	-p pandoc_tool	path to the pandoc tool (not the wrapper) (def: $PANDOC_TOOL)
	-P pandoc_opts	options given to the pandoc tool (def: $PANDOC_ARGS)

	-e string	output string, followed by newline, to stderr (def: do not)
	-E exitcode	force exit with exitcode (def: exit based on success or failure of the action)

	file.md		markdown file to convert into HTML
	output.html	HTML generated by pandoc from file.md
			NOTE: Use - to write to standard output (stdout)
			NOTE: Without -n, will prepend '-o output.html' as first pandoc options
			      With -n, will append '-o /dev/null' as last pandoc options before file.md

Exit codes:
     0         all OK
     1	       pandoc exited non-zero
     2         -h and help string printed or -V and version string printed
     3         command line error
     4         bash version is < 4.2
     5         file.md file not found or not readable file
     6         pandoc tool not found or not executable
 >= 10 < 100   ((not used))
 >= 100	       internal error

$NAME version: $VERSION"

# setup
#
export NOOP=
export DO_NOT_PROCESS=

# parse command line
#
while getopts :hv:Vd:nNp:P:e:E: flag; do
  case "$flag" in
    h) echo "$USAGE" 1>&2
	exit 2
	;;
    v) V_FLAG="$OPTARG"
	;;
    V) echo "$VERSION"
	exit 2
	;;
    d) TOPDIR="$OPTARG"
	;;
    n) NOOP="-n"
	;;
    N) DO_NOT_PROCESS="-N"
	;;
    p) PANDOC_TOOL="$OPTARG"
	;;
    P) PANDOC_ARGS="$OPTARG"
	;;
    e) echo "$OPTARG" 1>&2
	;;
    E) exit "$OPTARG"
	;;
    \?) echo "$0: ERROR: invalid option: -$OPTARG" 1>&2
	echo 1>&2
	print_usage 1>&2
	exit 3
	;;
    :) echo "$0: ERROR: option -$OPTARG requires an argument" 1>&2
	echo 1>&2
	echo "$USAGE" 1>&2
	exit 3
	;;
    *) echo "$0: ERROR: unexpected value from getopts: $flag" 1>&2
	echo 1>&2
	echo "$USAGE" 1>&2
	exit 3
	;;
  esac
done

# parse the command line arguments
#
if [[ $V_FLAG -ge 1 ]]; then
    echo "$0: debug[1]: debug level: $V_FLAG" 1>&2
fi
#
shift $(( OPTIND - 1 ));
#
if [[ $V_FLAG -ge 5 ]]; then
    echo "$0: debug[5]: argument count: $#" 1>&2
fi
if [[ $# -ne 2 ]]; then
    echo "$0: ERROR: expected 2 args, found: $#" 1>&2
    exit 3
fi
#
export MARKDOWN_INPUT="$1"
export HTML_OUTPUT="$2"
if [[ $V_FLAG -ge 1 ]]; then
    echo "$0: debug[1]: MARKDOWN_INPUT=$MARKDOWN_INPUT" 1>&2
    echo "$0: debug[1]: HTML_OUTPUT=$HTML_OUTPUT" 1>&2
fi

# firewall - validate args
#
if [[ ! -e $MARKDOWN_INPUT ]]; then
    echo "$0: ERROR: markdown input file does not exist: $MARKDOWN_INPUT" 1>&2
    exit 5
fi
if [[ ! -f $MARKDOWN_INPUT ]]; then
    echo "$0: ERROR: markdown input is not a file: $MARKDOWN_INPUT" 1>&2
    exit 5
fi
if [[ ! -r $MARKDOWN_INPUT ]]; then
    echo "$0: ERROR: markdown input is not a readable file: $MARKDOWN_INPUT" 1>&2
    exit 5
fi
if [[ ! -x $PANDOC_TOOL ]]; then
    echo "$0: ERROR: cannot find an executable pandoc tool: $PANDOC_TOOL" 1>&2
    exit 6
fi

# verify that we have a topdir directory
#
REPO_NAME=$(basename "$REPO_URL")
export REPO_NAME
if [[ -z $TOPDIR ]]; then
    echo "$0: ERROR: cannot find top of git repo directory" 1>&2
    echo "$0: Notice: if needed: $GIT_TOOL clone $REPO_URL; cd $REPO_NAME" 1>&2
    exit 101
fi
if [[ ! -d $TOPDIR ]]; then
    echo "$0: ERROR: TOPDIR is not a directory: $TOPDIR" 1>&2
    echo "$0: Notice: if needed: $GIT_TOOL clone $REPO_URL; cd $REPO_NAME" 1>&2
    exit 102
fi

# cd to topdir
#
if [[ ! -e $TOPDIR ]]; then
    echo "$0: ERROR: cannot cd to non-existent path: $TOPDIR" 1>&2
    exit 104
fi
if [[ ! -d $TOPDIR ]]; then
    echo "$0: ERROR: cannot cd to a non-directory: $TOPDIR" 1>&2
    exit 105
fi
export CD_FAILED
if [[ $V_FLAG -ge 5 ]]; then
    echo "$0: debug[5]: about to: cd $TOPDIR" 1>&2
fi
cd "$TOPDIR" || CD_FAILED="true"
if [[ -n $CD_FAILED ]]; then
    echo "$0: ERROR: cd $TOPDIR failed" 1>&2
    exit 106
fi
if [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: now in directory: $(/bin/pwd)" 1>&2
fi

# parameter debugging
#
if [[ $V_FLAG -ge 3 ]]; then
    echo "$0: debug[3]: REPO_URL=$REPO_URL" 1>&2
    echo "$0: debug[3]: REPO_NAME=$REPO_NAME" 1>&2
    echo "$0: debug[3]: DO_NOT_PROCESS=$DO_NOT_PROCESS" 1>&2
    echo "$0: debug[3]: NOOP=$NOOP" 1>&2
fi

# If -N, time to exit
#
if [[ -n $DO_NOT_PROCESS ]]; then
    if [[ $V_FLAG -ge 1 ]]; then
	echo "$0: debug[1]: arguments parsed, -N given, exit 0" 1>&2
    fi
    exit 0
fi

# execute pandoc
#
if [[ -z $NOOP ]]; then
    if [[ $V_FLAG -ge 1 ]]; then
	echo "$0: debug[1]: will execute pandoc as: $PANDOC_TOOL -o $HTML_OUTPUT $PANDOC_ARGS $MARKDOWN_INPUT" 1>&2
    fi
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    # shellcheck disable=SC2086
    "$PANDOC_TOOL" -o "$HTML_OUTPUT" $PANDOC_ARGS "$MARKDOWN_INPUT"
    status="$?"
else
    if [[ $V_FLAG -ge 1 ]]; then
	echo "$0: debug[3]: will execute pandoc as: $PANDOC_TOOL $PANDOC_ARGS -o /dev/null $MARKDOWN_INPUT" 1>&2
    fi
    # SC2086 (info): Double quote to prevent globbing and word splitting.
    # shellcheck disable=SC2086
    "$PANDOC_TOOL" $PANDOC_ARGS -o /dev/null "$MARKDOWN_INPUT"
    status="$?"
fi
if [[ $status -ne 0 ]]; then
    echo "$0: ERROR: pandoc: $PANDOC_TOOL exited non-zero: $status" 1>&2
    exit 1
fi

# All Done!!! -- Jessica Noll, Age 2
#
exit 0
