#!/bin/bash
#
# Starts the webserver inside the docker container
#

# set -x

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR
export PYTHONPATH=$SCRIPT_DIR

# Determine which webserver interface to launch (Streamlit vs Default: Gradio)
if [[ ! -z $WEBUI_SCRIPT && $WEBUI_SCRIPT == "webui_streamlit.py" ]]; then
    launch_command="streamlit run scripts/${WEBUI_SCRIPT:-webui.py} $WEBUI_ARGS"
else
    launch_command="python scripts/${WEBUI_SCRIPT:-webui.py} $WEBUI_ARGS"
fi

# Start webserver interface
launch_message="Starting Stable Diffusion WebUI... ${launch_command}..."
if [[ -z $WEBUI_RELAUNCH || $WEBUI_RELAUNCH == "true" ]]; then
    n=0
    while true; do
        echo $launch_message

        if (( $n > 0 )); then
            echo "Relaunch count: ${n}"
        fi

        $launch_command

        echo "entrypoint.sh: Process is ending. Relaunching in 0.5s..."
        ((n++))
        sleep 0.5
    done
else
    echo $launch_message
    $launch_command
fi
