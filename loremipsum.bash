#!/bin/bash
# vim:set tabstop=4 textwidth=80 shiftwidth=4 expandtab cindent cino=(0,ml,\:0:
# ( settings from: http://datapax.com.au/code_conventions/ )
#
#/**********************************************************************
#    Lorem Ipsum
#    Copyright (C) 2012-2016 DaTaPaX (Todd Harbour t/a)
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    version 3 ONLY, as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program, in the file COPYING or COPYING.txt; if
#    not, see http://www.gnu.org/licenses/ , or write to:
#      The Free Software Foundation, Inc.,
#      51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# **********************************************************************/

# loremipsum
#-----------
# A generator of lorem ipsum like text
#
# Thanks to http://www.lipsum.com/ for the initial word list.

# Config paths
_ETC_CONF="/etc/loremipsum.conf"
_HOME_CONF="${HOME}/.loremipsumrc"


############### STOP ###############
#
# Do NOT edit the CONFIGURATION below. Instead generate the default
# configuration file in your home directory thusly:
#
#     ./loremipsum.bash -C >~/.loremipsumrc
#
####################################

# [ CONFIG_START

# Lorem Ipsum Default Configuration
# =================================

# WORDLIST
#   This is the wordlist used for generation.  You can replace this
#   using the format:
#     WORDLIST=(these are example words)
#   or append to it using:
#     WORDLIST+=(more words)
#   The default is as follows.
WORDLIST=(
lorem ipsum dolor sit amet consectetur adipiscing elit
a ac accumsan ad aenean aliquam aliquet ante aptent arcu at auctor augue
bibendum blandit class commodo condimentum congue consequat conubia convallis
cras cubilia cum curabitur curae cursus dapibus diam dictum dictumst dignissim
dis donec dui duis egestas eget eleifend elementum enim erat eros est et etiam
eu euismod facilisi facilisis fames faucibus felis fermentum feugiat fringilla
fusce gravida habitant habitasse hac hendrerit himenaeos iaculis id imperdiet in
inceptos integer interdum justo lacinia lacus laoreet lectus leo libero ligula
litora lobortis luctus maecenas magna magnis malesuada massa mattis mauris metus
mi molestie mollis montes morbi mus nam nascetur natoque nec neque netus nibh
nisi nisl non nostra nulla nullam nunc odio orci ornare parturient pellentesque
penatibus per pharetra phasellus placerat platea porta porttitor posuere potenti
praesent pretium primis proin pulvinar purus quam quis quisque rhoncus ridiculus
risus rutrum sagittis sapien scelerisque sed sem semper senectus sociis sociosqu
sodales sollicitudin suscipit suspendisse taciti tellus tempor tempus tincidunt
torquent tortor tristique turpis ullamcorper ultrices ultricies urna ut varius
vehicula vel velit venenatis vestibulum vitae vivamus viverra volutpat vulputate
)

# PUNCTUATION
#   Punctuation characters to insert into text.  This can be replaced or
#   appended to, as above.  As with the WORDLIST (though more useful here) you
#   can weight the occurance of a given instance by repeating it.
PUNCTUATION=(',' ',' ',' ';' ';' ' -')

# LINENDERS
#   Line ending characters to insert into text.  This can be replaced or
#   appended to, as above.  As with the WORDLIST (though more useful with
#   PUNCTUATION and here) you can weight the occurance of a given instance by
#   repeating it.
LINENDERS=('.' '.' '.' '.' '.' '.' '.' '.' '?' '?' '!')

# DEBUG
#   This defines debug mode which will output verbose info to stderr
#   or, if configured, the debug file ( ERROR_LOG ).
DEBUG=0

# ERROR_LOG
#   The file to output errors and debug statements (when DEBUG != 0) instead of
#   stderr.
#ERROR_LOG="/tmp/loremipsum.log"

# ] CONFIG_END

###
# Config loading
###
[ ! -z "${_ETC_CONF}"  ] && [ -r "${_ETC_CONF}"  ] && . "${_ETC_CONF}"
[ ! -z "${_HOME_CONF}" ] && [ -r "${_HOME_CONF}" ] && . "${_HOME_CONF}"

# Quit on error
set -e

# Version
APP_NAME="LoremIpsum"
APP_VER="0.05"
APP_URL="http://www.datapax.com.au/loremipsum/"

# Program name
PROG="$(basename "${0}")"

# exit condition constants
ERR_NONE=0
ERR_MISSINGDEP=1
ERR_UNKNOWNOPT=2
ERR_INVALIDOPT=3
ERR_MISSINGPARAM=4
ERR_NOWORDLIST=5

# Defaults not in config
paragraphs=5



# Params:
#   NONE
function show_version() {
    echo -e "\
${APP_NAME} v${APP_VER}\n\
${APP_URL}\n\
"
}

# Params:
#   NONE
function show_usage() {
    show_version
cat <<EOF

${APP_NAME} generates Lorem Ipsum like output.

Usage: ${PROG} -h|--help
       ${PROG} -V|--version
       ${PROG} -C|--configuration
       ${PROG} [-v|--verbose] [-c|--noclassic] [-p|--paragraphs <PARAGRAPHS>] [--]

-h|--help           - Displays this help
-V|--version        - Displays the program version
-C|--configuration  - Outputs the default configuration that can be placed in
                          ${_ETC_CONF}
                      or
                          ${_HOME_CONF}
                      for editing.
-v|--verbose        - Displays extra debugging information.  This is the same
                      as setting DEBUG=1 in your config.
-c|--noclassic      - Disables classic start. Classic start will always use the
                      first 8 words of the wordlist first which are, by default,
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
-p|--paragraphs     - Sets the number of paragraphs to output
                      (DEFAULT: ${paragraphs}).

Example: ${PROG} -p 5
EOF
}

# Params:
#   $1 =  (s) command to look for
#   $2 = [(s) suspected package name]
function check_for_cmd() {
    # Check for ${1} command
    cmd="UNKNOWN"
    [ $# -gt 0 ] && cmd="${1}" && shift 1
    pkg="${cmd}"
    [ $# -gt 0 ] && pkg="${1}" && shift 1

    which "${cmd}" >/dev/null 2>&1 || {
cat <<EOF >&2
ERROR: Cannot find ${cmd}.  This is required.
Ensure you have ${pkg} installed or search for ${cmd}
in your distribution's packages.
EOF

        exit ${ERR_MISSINGDEP}
    }

    return ${ERR_NONE}
}

# Output configuration file
function output_config() {
    cat "${0}"|\
         grep -A999 '# \[ CONFIG_START'\
        |grep -v    '# \[ CONFIG_START'\
        |grep -B999 '# \] CONFIG_END'  \
        |grep -v    '# \] CONFIG_END'  \
    #
}

# Debug echo
function decho() {
    # Not debugging, get out of here then
    [ ${DEBUG} -le 0 ] && return

    echo "[$(date +'%Y-%m-%d %H:%M')] DEBUG: ${@}" >&2
}

# New sentence, capitalise first letter
function newsent() {
    echo "${@}"|sed 's/^\(.\)/\u\1/'
}

# Get punctuation character
function punc() {
    [ ! -z "${PUNCTUATION}" ]\
        && echo "${PUNCTUATION[$((${RANDOM} % ${#PUNCTUATION[@]}))]}"
}

# Get line ending character
function lineend() {
    [ ! -z "${LINENDERS}" ]\
        && echo "${LINENDERS[$((${RANDOM} % ${#LINENDERS[@]}))]}"
}



# START #

# If debug file, redirect stderr out to it
[ ! -z "${ERROR_LOG}" ] && exec 2>>"${ERROR_LOG}"

decho "START"

# Check for wget
check_for_cmd "wget" "wget"

# Check for WORDLIST set
if [ -z "${WORDLIST}" ] || [ ${#WORDLIST[@]} -lt 1 ]; then #{
	echo "ERROR: No word list set." >&2
	exit ${ERR_NOWORDLIST}
fi #}



# Default values
classic=1

moreparams=1
decho "Processing ${#} params..."
while [ ${#} -gt 0 ]; do #{
    decho "Command line param: ${1}"

    [ ${moreparams} -gt 0 ] && {
        case "${1}" in #{
            # Verbose mode # [-v|--verbose]
            -v|--verbose)
                decho "Verbose mode specified"

                DEBUG=1

                shift 1; continue
            ;;

            # Help # -h|--help
            -h|--help)
                decho "Help"

                show_usage
                exit ${ERR_NONE}
            ;;

            # Version # -V|--version
            -V|--version)
                decho "Version"

                show_version
                exit ${ERR_NONE}
            ;;

            # Configuration output # -C|--configuration
            -C|--configuration)
                decho "Configuration"

                output_config
                exit ${ERR_NONE}
            ;;

            # Paragraphs # [-p|--paragraphs <PARAGRAPHS>]
            -p|--paragraphs)
                decho "Paragraphs specified ( ${2} )"

                [ -z "${2}" ] && {
                    echo "ERROR: Paragraphs required for -p|--paragraphs" >&2
                    exit ${ERR_MISSINGPARAM}
                }
                shift 1

                paragraphs="${1}"

                shift 1; continue
            ;;

            # No Classic # [-c|--noclassic]
            -c|--noclassic)
                decho "No Classic specified"

                classic=0

                shift 1; continue
            ;;

            *)
                [ "${1}" == "--" ] && {
                    # No more parameters to come
                    moreparams=0
                    shift 1; continue
                }

                [ "${1:0:1}" == "-" ] && {
                    # Assume a parameter
                    echo "ERROR: Unrecognised parameter ${1}..." >&2
                    exit ${ERR_UNKNOWNOPT}
                }
            ;;

        esac #}
    }

    # Extra command line options
    echo "ERROR: Extra unrecognised parameters ${@}..." >&2
    exit ${ERR_UNKNOWNOPT}
done #}

# Ensure paragraphs is a number
if [ -z "$(echo "${paragraphs}"|sed '/[^[:digit:]]/d')" ]; then
    # Invalid digit
    echo "ERROR: Paragraphs specified not a number: ${paragraphs}" >&2
    exit ${ERR_INVALIDOPT}
fi  
paragraphs=$((${paragraphs} + 0))

output=""
#s_count=0
#p_count=0

if [ ${classic} -eq 1 ]; then #{
    output+="$(newsent "${WORDLIST[0]}") "
    for x in $(seq 1 7); do #{
        output+="${WORDLIST[${x}]}"
        [ ${x} -eq 5 ] && output+=","
        [ ${x} -lt 7 ] && output+=" "
    done #}

    output+=". "
#    s_count=$((${s_count} + 1))
fi #}

p_desired=${paragraphs}
p_count=0
while [ ${p_count} -lt ${p_desired} ]; do #{
    # Between 3 and 8 sentences in a paragraph
    s_desired=$(((${RANDOM} % 5) + 3))
    s_count=0

    while [ ${s_count} -lt ${s_desired} ]; do #{
        # Between 6 and 25 words in a sentence
        w_desired=$(((${RANDOM} % 19) + 6))
        w_count=0
        punc_desired=0

        # 1/2 chance of punctuation if the sentence has more than 10 words.
        [ ${w_desired} -gt 10 ]\
            && [ $((${RANDOM} % 2)) == 1 ]\
            && punc_desired=$((${punc_desired} + 1))
        [ ${w_desired} -gt 20 ]\
            && [ $((${RANDOM} % 2)) == 1 ]\
            && punc_desired=$((${punc_desired} + 1))

        while [ ${w_count} -lt ${w_desired} ]; do #{
            wi=$((${RANDOM} % ${#WORDLIST[@]}))
            word="${WORDLIST[${wi}]}"

            [ ${w_count} -eq 0 ] && output+="$(newsent "${WORDLIST[${wi}]}")" || output+="${WORDLIST[${wi}]}"

            [ ${punc_desired} -gt 0 ]\
                && [ ${w_count} -gt 6 ]\
                && [ $((${w_desired} - ${w_count})) -gt 4 ]\
                && [ $((${RANDOM} % 2)) -eq 1 ]\
                && output+="$(punc)"\
                && punc_desired=$((${punc_desired} - 1))

            [ ${punc_desired} -gt 0 ]\
                && [ ${w_count} -gt 16 ]\
                && [ $((${w_desired} - ${w_count})) -gt 4 ]\
                && [ $((${RANDOM} % 2)) -eq 1 ]\
                && output+="$(punc)"\
                && punc_desired=$((${punc_desired} - 1))

            w_count=$((${w_count} + 1))
            [ ${w_count} -lt ${w_desired} ] && output+=" " || output+="$(lineend)"
        done #}

        s_count=$((${s_count} + 1))
        [ ${s_count} -lt ${s_desired} ] && output+=" " || output+="\n"
    done #}

    echo -e "${output}"; output=""

    p_count=$((${p_count} + 1))
done #}

echo "${output}"

decho "DONE"
