#!/bin/bash
# Watches the traffic by watching new entries stored into the access log.

usage() {
  echo "Usage ${0} [-pie]" >&2
  echo "Watches the traffic by watching new entries stored into the access log." >&2
  echo "  -p  ACCESS_LOG_PATH   Explicity specify the access log path or" >&2
  echo "                        store the path as an environment varable" >&2
  echo "                        as ACCESS_LOG_PATH" >&2
  echo "  -i  INCLUDE_PATTERN   Pattern to incude. Will be run with grep -iE" >&2
  echo "  -e  EXCLUDE_PATTERN   Pattern to exclude. Will be run with grep -iEv" >&2
  exit 1
}

ACCESS_LOG_PATH=$(printenv ACCESS_LOG_PATH)
INCLUDE_PATTERN=()
EXCLUDE_PATTERN=()

while getopts p:i:e: OPTION; do
  case ${OPTION} in
    p)
      ACCESS_LOG_PATH="${OPTARG}"
      ;;
    i)
      INCLUDE_PATTERN+=("${OPTARG}")
      ;;
    e)
      EXCLUDE_PATTERN+=("${OPTARG}")
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
echo "Running ${CMD}"
$CMD
