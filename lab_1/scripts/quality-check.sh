lint#!/bin/bash

# Step 1: run tests
npm test

if [ $? -ne 0 ]; then
    echo "Failed to run tests"
    exit 1
fi

# Step 2: run lint checks
npm lint

if [ $? -ne 0 ]; then
    echo "Failed to run lint checks"
    exit 1
fi

# Step 3: run e2e tests
npm e2e

if [ $? -ne 0 ]; then
    echo "Failed to run e2e tests"
    exit 1
fi
