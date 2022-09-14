#!/bin/bash
# vim:set ts=4 sw=4 tw=80 et ai si cindent cino=L0,b1,(1s,U1,m1,j1,J1,)50,*90 cinkeys=0{,0},0),0],\:,0#,!^F,o,O,e,0=break:
#
#/**********************************************************************
#    Lorem Ipsum (loremipsum)
#    Copyright (C) 2012-2022 DaTaPaX (Todd Harbour t/a)
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
# Required:
#     -
# Recommended:
#     -
#
# Thanks to http://www.lipsum.com/ for the initial word list.

# Config paths
_APP_NAME="loremipsum"
_CONF_FILENAME="${_APP_NAME}.conf"
_ETC_CONF="/etc/${_CONF_FILENAME}"



############### STOP ###############
#
# Do NOT edit the CONFIGURATION below. Instead generate the default
# configuration file in your XDG_CONFIG directory thusly:
#
#     ./loremipsum.bash -C >"$XDG_CONFIG_HOME/loremipsum.conf"
#
# or perhaps:
#     ./loremipsum.bash -C >~/.config/loremipsum.conf
#
# or even in your home directory (deprecated):
#     ./loremipsum.bash -C >~/.loremipsum.conf
#
# Consult --help for more complete information.
#
####################################

# [ CONFIG_START

# Lorem Ipsum - Default Configuration
# ===================================

# DEBUG
#   This defines debug mode which will output verbose info to stderr or, if
#   configured, the debug file ( ERROR_LOG ).
DEBUG=0

# ERROR_LOG
#   The file to output errors and debug statements (when DEBUG != 0) instead of
#   stderr.
#ERROR_LOG="${HOME}/loremipsum.log"

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

# ] CONFIG_END



####################################{
###
# Config loading
###

# A list of configs - user provided prioritised over system
# (built backwards to save fiddling with CONFIG_DIRS order)
_CONFS=""

# XDG Base (v0.8) - User level
# ( https://specifications.freedesktop.org/basedir-spec/0.8/ )
# ( xdg_base_spec.0.8.txt )
_XDG_CONF_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}"
# As per spec, non-absolute paths are invalid and must be ignored
[ "${_XDG_CONF_DIR:0:1}" == "/" ] && {
        for conf in\
            "${_XDG_CONF_DIR}/${_APP_NAME}/${_CONF_FILENAME}"\
            "${_XDG_CONF_DIR}/${_CONF_FILENAME}"\
        ; do #{
            [ -r "${conf}" ] && _CONFS="${conf}:${_CONFS}"
        done #}
}

# XDG Base (v0.8) - System level
# ( https://specifications.freedesktop.org/basedir-spec/0.8/ )
# ( xdg_base_spec.0.8.txt )
_XDG_CONF_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
# NOTE: Appending colon as read's '-d' sets the TERMINATOR (not delimiter)
[ "${_XDG_CONF_DIRS: -1:1}" != ":" ] && _XDG_CONF_DIRS="${_XDG_CONF_DIRS}:"
while read -r -d: _XDG_CONF_DIR; do #{
    # As per spec, non-absolute paths are invalid and must be ignored
    [ "${_XDG_CONF_DIR:0:1}" == "/" ] && {
        for conf in\
            "${_XDG_CONF_DIR}/${_APP_NAME}/${_CONF_FILENAME}"\
            "${_XDG_CONF_DIR}/${_CONF_FILENAME}"\
        ; do #{
            [ -r "${conf}" ] && _CONFS="${conf}:${_CONFS}"
        done #}
    }
done <<<"${_XDG_CONF_DIRS}" #}

# OLD standard
[ -r "${HOME}/.${_CONF_FILENAME}" ] && _CONFS="${HOME}/.${_CONF_FILENAME}:${_CONFS}"

# _CONFS now contains a list of config files, in reverse importance order. We
# can therefore source each in turn, allowing the more important to override the
# earlier ones.

# NOTE: Appending colon as read's '-d' sets the TERMINATOR (not delimiter)
[ "${_CONF: -1:1}" != ":" ] && _CONF="${_CONF}:"
while read -r -d: conf; do #{
    . "${conf}"
done <<<"${_CONFS}" #}
####################################}


# Quit on error
set -e

# Version
APP_NAME="LoremIpsum"
APP_VER="0.09"
APP_COPY="(C)2012-2022 Krayon (Todd Harbour)"
APP_URL="http://www.datapax.com.au/apps/loremipsum/"

# Program name
_binname="${_APP_NAME}"
_binname="${0##*/}"
_binnam_="${_binname//?/ }"

# exit condition constants
ERR_NONE=0
ERR_MISSINGDEP=1
ERR_UNKNOWNOPT=2
ERR_INVALIDOPT=3
ERR_MISSINGPARAM=4
ERR_NOWORDLIST=5

# Defaults not in config

classic=1
paragraphs=5



# Params:
#   NONE
show_version() {
    echo -e "\n\
${APP_NAME} v${APP_VER}\n\
${APP_COPY}\n\
${APP_URL}${APP_URL:+\n}\
"
} # show_version()

# Params:
#   NONE
show_usage() {
    show_version

cat <<EOF

${APP_NAME} generates Lorem Ipsum like output.

Usage: ${_binname} [-v|--verbose] -h|--help
       ${_binname} [-v|--verbose] -V|--version
       ${_binname} [-v|--verbose] -C|--configuration

       ${_binname} [-v|--verbose] [-c|--noclassic]
       ${_binnam_} [-p|--paragraphs <PARAGRAPHS>] [--]

-h|--help           - Displays this help
-V|--version        - Displays the program version
-C|--configuration  - Outputs the default configuration that can be placed in a
                      config file in XDG_CONFIG or one of the XDG_CONFIG_DIRS
                      (in order of decreasing precedence):
                          ${XDG_CONFIG_HOME:-${HOME}/.config}/${_APP_NAME}/${_CONF_FILENAME}
                          ${XDG_CONFIG_HOME:-${HOME}/.config}/${_CONF_FILENAME}
EOF
    while read -r -d: _XDG_CONF_DIR; do #{
        # As per spec, non-absolute paths are invalid and must be ignored
        [ "${_XDG_CONF_DIR:0:1}" != "/" ] && continue
cat <<EOF
                          ${_XDG_CONF_DIR}/${_APP_NAME}/${_CONF_FILENAME}
                          ${_XDG_CONF_DIR}/${_CONF_FILENAME}
EOF
    done <<<"${_XDG_CONF_DIRS:-/etc/xdg}:" #}
cat <<EOF
                          ${HOME}/.${_CONF_FILENAME}
                      for editing.
-v|--verbose        - Displays extra debugging information.  This is the same
                      as setting DEBUG=1 in your config.
-c|--noclassic      - Disables classic start. Classic start will always use the
                      first 8 words of the wordlist first which are, by default,
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
-p|--paragraphs     - Sets the number of paragraphs to output
                      (DEFAULT: ${paragraphs}).

Example: ${_binname} -p 5
EOF

} # show_usage()

# Output configuration file
output_config() {
    sed -n '/^# \[ CONFIG_START/,/^# \] CONFIG_END/p' <"${0}"
} # output_config()

# Debug echo
decho() {
    # global $DEBUG
    local line

    # Not debugging, get out of here then
    [ -z "${DEBUG}" ] || [ "${DEBUG}" -le 0 ] && return

    # If message is "-" or isn't specified, use stdin ("" is valid input)
    msg="${@}"
    [ ${#} -lt 1 ] || [ "${msg}" == "-" ] && msg="$(</dev/stdin)"

    while IFS="" read -r line; do #{
        >&2 echo "[$(date +'%Y-%m-%d %H:%M')] DEBUG: ${line}"
    done< <(echo "${msg}") #}
} # decho()



# START #

# Clear DEBUG if it's 0
[ -n "${DEBUG}" ] && [ "${DEBUG}" == "0" ] && DEBUG=

# If debug file, redirect stderr out to it
[ -n "${ERROR_LOG}" ] && exec 2>>"${ERROR_LOG}"

#----------------------------------------------------------

# New sentence, capitalise first letter
newsent() {
    echo "${@}"|sed 's/^\(.\)/\u\1/'
} # newsent()

# Get punctuation character
punc() {
    [ ! -z "${PUNCTUATION}" ]\
        && echo "${PUNCTUATION[$((${RANDOM} % ${#PUNCTUATION[@]}))]}"
} # punc()

# Get line ending character
lineend() {
    [ ! -z "${LINENDERS}" ]\
        && echo "${LINENDERS[$((${RANDOM} % ${#LINENDERS[@]}))]}"
} # lineend()



#----------------------------------------------------------

# Process command line parameters
opts=$(\
    getopt\
        --options v,h,V,C,c,p:\
        --long verbose,help,version,configuration,noclassic,paragraphs:\
        --name "${_binname}"\
        --\
        "$@"\
) || {
    >&2 echo "ERROR: Syntax error"
    >&2 show_usage
    exit ${ERR_USAGE}
}

eval set -- "${opts}"
unset opts

while :; do #{
    case "${1}" in #{
        # Verbose mode # [-v|--verbose]
        -v|--verbose)
            decho "Verbose mode specified"
            DEBUG=1
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

        # Paragraphs # -p|--paragraphs <PARAGRAPHS>
        -p|--paragraphs)
            decho "Paragraphs: ${2}"

            paragraphs="${2}"
            shift 1
        ;;

        # No Classic # -c|--noclassic
        -c|--noclassic)
            decho "No Classic"

            classic=0
        ;;

        --)
            shift
            break
        ;;

        -)
            # Read stdin
            #set -- "/dev/stdin"
            # FALL THROUGH TO FILE HANDLER BELOW
        ;;

        *)
            >&2 echo "ERROR: Unrecognised parameter ${1}..."
            exit ${ERR_USAGE}
        ;;
    esac #}

    shift

done #}

# Unrecognised parameters
[ ${#} -gt 0 ] && {
    >&2 echo "ERROR: Unrecognised parameters: ${@}..."
    exit ${ERR_USAGE}
}

#                [ "${1:0:1}" == "-" ] && {
#                    # Assume a parameter
#                    echo "ERROR: Unrecognised parameter ${1}..." >&2
#                    exit ${ERR_UNKNOWNOPT}
#                }
#
#    # Extra command line options
#    echo "ERROR: Extra unrecognised parameters ${@}..." >&2
#    exit ${ERR_UNKNOWNOPT}



# Check for dependencies
# -

# Check for WORDLIST set
if [ -z "${WORDLIST}" ] || [ ${#WORDLIST[@]} -lt 1 ]; then #{
	echo "ERROR: No word list set." >&2
	exit ${ERR_NOWORDLIST}
fi #}



# Ensure paragraphs is a number
if [ -z "$(echo "${paragraphs}"|sed '/[^[:digit:]]/d')" ]; then
    # Invalid digit
    echo "ERROR: Paragraphs specified not a number: ${paragraphs}" >&2
    exit ${ERR_INVALIDOPT}
fi  
paragraphs=$((${paragraphs} + 0))



decho "START"

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

    echo -en "${output}"; output=""

    p_count=$((${p_count} + 1))
done #}

echo -n "${output}"

decho "DONE"
