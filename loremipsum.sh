#!/bin/bash
# vim:set tabstop=4 textwidth=80 shiftwidth=4 expandtab cindent cino=(0,ml,\:0:
# ( settings from: http://datapax.com.au/code_conventions/ )
#
#/**********************************************************************
#    Lorum Ipsum
#    Copyright (C) 2012-2013 DaTaPaX (Todd Harbour t/a)
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

# lorumipsum
#-----------
# A generator of lorum ipsum like text
#
# Thanks to http://www.lipsum.com/ for the initial word list.

# Config paths
_ETC_CONF="/etc/lorumipsum.conf"
_HOME_CONF="${HOME}/.lorumipsumrc"



# [ CONFIG_START

# Lorum Ipsum Default Configuration
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
#   or, if configured, the debug file ( DEBUGFILE ).
DEBUG=0

# DEBUG_FILE
#   The file to debug to in the event DEBUG != 0.  If this is not set,
#   bet DEBUG != 0, debug will be directed to stderr.
#DEBUG_FILE="/tmp/lorumipsum.log"

# ] CONFIG_END

###
# Config loading
###
[ -r "${_ETC_CONF}" ] && . "${_ETC_CONF}"
[ -r "${_HOME_CONF}" ] && . "${_HOME_CONF}"

# Quit on error
set -e

# Version
APP_NAME="LorumIpsum"
APP_VER="0.01"
APP_URL="http://www.datapax.com.au/lorumipsum/"

# Program name
PROG="$(basename "${0}")"

# exit condition constants
ERR_NONE=0
ERR_MISSINGDEP=1
ERR_UNKNOWNOPT=2
ERR_INVALIDOPT=3
ERR_MISSINGPARAM=4
ERR_NOWORDLIST=5



# Params:
#   NONE
show_version() {
    echo -e "\
${APP_NAME} v${APP_VER}\n\
${APP_URL}\n\
"
}

# Params:
#   NONE
show_usage() {
    show_version
cat <<EOF

${APP_NAME} generates Lorum Ipsum like output.

Usage: ${PROG} -h|--help
       ${PROG} -V|--version
       ${PROG} [-v|--verbose] [-c|--noclassic] [-p|--paragraphs <PARAGRAPHS>]

-h|--help           - Displays this help
-V|--version        - Displays the program version
-v|--verbose        - Displays extra debugging information.  This is the same
                      as setting DEBUG=1 in your config.
-c|--noclassic      - Disables classic start. Classic start will always use the
                      first 8 words of the wordlist first which are, by default,
                      "Lorum ipsum dolor sit amet, consectetur adipiscing elit"
-p|--paragraphs     - Set's the number of paragraphs to output.

Example: ${PROG} -p 5
EOF
}

# Params:
#   $1 =  (s) command to look for
#   $2 = [(s) suspected package name]
check_for_cmd() {
    # Check for ${1} command
    cmd="UNKNOWN"
    [ $# -gt 0 ] && cmd="${1}" && shift 1
    pkg="${cmd}"
    [ $# -gt 0 ] && pkg="${1}" && shift 1

    which "${cmd}" >/dev/null 2>&1 || {
cat <<EOF >&2
ERROR: Cannot find ${cmd}.  This is required.
Ensure you have ${pkg} installed or search for ${cmd}
in your distributions' packages.
EOF

        exit ${ERR_MISSINGDEP}
    }

    return ${ERR_NONE}
}

# Debug echo
decho() {
    # Not debugging, get out of here then
    [ ${DEBUG} -le 0 ] && return

    # If debug file NOT set, output to stderr
    if [ -z "${DEBUG_FILE}" ]; then
        echo "DEBUG: ${@}" >&2
        return
    fi

    # Output to debug file
    echo "DEBUG: ${@}" >>"${DEBUG_FILE}"
}

# New sentence, capitalise first letter
newsent() {
    echo "${@}"|sed 's/^\(.\)/\u\1/'
}

# Get punctuation character
punc() {
    [ ! -z "${PUNCTUATION}" ]\
        && echo "${PUNCTUATION[$((${RANDOM} % ${#PUNCTUATION[@]}))]}"
}

# Get line ending character
lineend() {
    [ ! -z "${LINENDERS}" ]\
        && echo "${LINENDERS[$((${RANDOM} % ${#LINENDERS[@]}))]}"
}



# START #

decho "START"

# Check for wget
check_for_cmd "wget" "wget"

# Check for WORDLIST set
if [ -z "${WORDLIST}" ] || [ ${#WORDLIST[@]} -lt 1 ]; then #{
	echo "ERROR: No word list set." >&2
	exit ${ERR_NOWORDLIST}
fi #}



# Default values
paragraphs=5
classic=1

decho "Processing ${#} params..."
while [ ${#} -gt 0 ]; do #{
    decho "Command line param: ${1}"

    case "${1}" in #{
        # Verbose mode # [-v|--verbose]
        -v|--verbose)
            decho "Verbose mode specified"

            DEBUG=1

            shift 1
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

        # Paragraphs # [-p|--paragraphs <PARAGRAPHS>]
        -p|--paragraphs)
            decho "Paragraphs specified ( ${2} )"

            [ -z "${2}" ] && {
                echo "ERROR: Paragraphs required for -p|--paragraphs" >&2
                exit ${ERR_MISSINGPARAM}
            }

            paragraphs="${2}"

            shift 2
        ;;

        # No Classic # [-c|--noclassic]
        -c|--noclassic)
            decho "No Classic specified"

            classic=0

            shift 1
        ;;

        *)
            [ "${1:0:1}" == "-" ] && {
                # Assume a parameter
                echo "ERROR: Unrecognised parameter ${1}..." >&2
                exit ${ERR_UNKNOWNOPT}
            }

            # File
            decho "File ID specified ( ${1} )"
            files+=("${1}")
            shift 1
        ;;

    esac #}
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
