#!/bin/bash

# Deploy to Firebase
# Uses Jenkins pipeline parameters and follows the same deployment pattern

# Firebase connection details (from Workshop2.md)

cd web-performance-project1-initial
firebase deploy --only hosting
