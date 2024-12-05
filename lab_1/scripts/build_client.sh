#!/bin/bash
CONFIGURATION=${ENV_CONFIGURATION:-development}
NPM_PATH=$(command -v npm)

if [ -z "$NPM_PATH" ]; then
    echo "npm is not installed. Please install npm first"
    exit 1
fi

# Step 1: Install npm dependencies
echo "Installing npm packages..."
npm install

# Step 2: remove client-app.zip file if it exists 
if [ -f "client-app.zip" ]; then
    echo "Removing previous archive of the build files..."
    rm ./dist/ client-app.zip
fi

# Step 3: Invoke the build command with the --configuration flag
echo "Building the app with configuration: $CONFIGURATION..."
npm run build --configuration=$CONFIGURATION

# Step 4: archive content of thce dist folder
echo "Archiving build files..."
zip -r ./dist/client-app.zip ./dist/* 