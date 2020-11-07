#!/bin/bash
# Watches the traffic by watching new entries stored into the access log.

ENV_VAR_NAMES_FILE='../source/env_var_names.txt'

ACCESS_LOG_PATH_ENV_VAR=$(cat ${ENV_VAR_NAMES_FILE} | grep ACCESS_LOG_PATH_ENV_VAR | awk -F '=' '{print $2}')
INC_PATTERN_ENV_VAR=$(cat ${ENV_VAR_NAMES_FILE} | grep INC_PATTERN_ENV_VAR | awk -F '=' '{print $2}')
EXC_PATTERN_ENV_VAR=$(cat ${ENV_VAR_NAMES_FILE} | grep EXC_PATTERN_ENV_VAR | awk -F '=' '{print $2}')


usage() {
  echo "Usage ${0} [-pie]" >&2
  echo "" >&2
  echo "To save time, you might want to set environment variables to" >&2
  echo "include and exclude patterns. Set \`${INC_PATTERN_ENV_VAR}\` and" >&2
  echo "\`${EXC_PATTERN_ENV_VAR}\` to set include and exclude patterns" >&2
  echo "respective" >&2
  echo "" >&2
  echo "Watches the traffic by watching new entries stored into the access " >&2
  echo "log." >&2
  echo "  -p  ACCESS_LOG_PATH   Explicity specify the access log path or" >&2
  echo "                        store the path as an environment varable" >&2
  echo "                        as \`${ACCESS_LOG_PATH_ENV_VAR}\`" >&2
  echo "  -i  INCLUDE_PATTERN   Pattern to incude. Will be run with" >&2 
  echo "                        grep -iE." >&2
  echo "  -I                    Includes patterns that are set as an env" >&2
  echo "                        var as \`${INC_PATTERN_ENV_VAR}\`" >&2
  echo "                        Seperate with ':'" >&2
  echo "  -e  EXCLUDE_PATTERN   Pattern to exclude. Will be run with" >&2
  echo "                        grep -iEv" >&2
  echo "  -E                    Exclude patterns that are set as as an" >&2
  echo "                        env var as \`${EXC_PATTERN_ENV_VAR}\`" >&2
  echo "                        Seperate with ':'" >&2
  exit 1
}

ACCESS_LOG_PATH=$(printenv $ACCESS_LOG_PATH_ENV_VAR)
INCLUDE_PATTERN=()
EXCLUDE_PATTERN=()

while getopts p:Ii:Ee: OPTION; do
  case ${OPTION} in
    p)
      ACCESS_LOG_PATH="${OPTARG}"
      ;;
    i)
      INCLUDE_PATTERN+=("${OPTARG}")
      ;;
    I)
      if [[ $(printenv $INC_PATTERN_ENV_VAR) == '' ]]; then
        echo -e "\e[1;33m WARN: ${INC_PATTERN_ENV_VAR} is not defined\e[0m"
      fi

      IFS=':' read -ra PATTERNS <<< "$(printenv $INC_PATTERN_ENV_VAR)"
      for pattern in "${PATTERNS[@]}"; do
        INCLUDE_PATTERN+=("${pattern}")
      done
      ;;
    e)
      EXCLUDE_PATTERN+=("${OPTARG}")
      ;;
    E)
    if [[ $(printenv $EXC_PATTERN_ENV_VAR) == '' ]]; then
        echo -e "\e[1;33m WARN: ${EXC_PATTERN_ENV_VAR} is not defined\e[0m"
      fi
      IFS=':' read -ra PATTERNS <<< "$(printenv $EXC_PATTERN_ENV_VAR)"
      for pattern in "${PATTERNS[@]}"; do
        INCLUDE_PATTERN+=("${pattern}")
      done
      ;;
    ?)
      usage
      ;;
  esac
done

# Check if an access log path has been set.
if [[ -z "${ACCESS_LOG_PATH}" ]]; then
  usage
fi

# Prepare the base command which is to tail the access log.
CMD="tail -f $ACCESS_LOG_PATH"

# Add include paterns
for pattern in "${INCLUDE_PATTERN[@]}"
do
  CMD+=" | grep --line-buffered -iE ${pattern}"
done

# Add the exclude patterns to the command.
if [[ ${#EXCLUDE_PATTERN[@]} -gt 0 ]]; then
  CMD+=" | grep --line-buffered -iEv '"
  CMD+=$( IFS=$'|'; echo "${EXCLUDE_PATTERN[*]}" )
  CMD+="'"
fi

# Run the watch command.
# If the command contain '|', we would need to use the `eval` method to call
# the script. This is not a safe method to use, so ask user to run it
# themselves.
if grep -q "|" <<< "$CMD"; then
  echo -e "Run:\n${CMD}"
else
  echo -e "\e[1;32mRunning:\n${CMD}\e[0m"
  ${CMD}
fi

