#!/bin/bash

set -euo pipefail

# Bootstrap script to set up the environment
source $(dirname "$0")/logger.sh

frame "Bootstraping the environment"

# Run the installation script
title "Starting installation process..."
bash ./scripts/install.sh

# run the setup script
title "Starting setup process..."
bash ./scripts/setup.sh