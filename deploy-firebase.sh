#!/bin/bash

# Deploy to Firebase
# Uses Jenkins pipeline parameters and follows the same deployment pattern

# Firebase connection details (from Workshop2.md)
FIREBASE_PROJECT_ID="jenkins-lnd-workshop2-truongtx"

cd web-performance-project1-initial
firebase deploy --token "$FIREBASE_TOKEN" --only hosting
