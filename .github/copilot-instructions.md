<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

This is a Flutter app project to help farmers in India. Prioritize code that is simple, readable, and well-documented. Use best practices for Flutter and Dart. When adding features, focus on usability for rural and semi-urban users.

Build an MVP mobile app in Flutter using Firebase and Gemini APIs for the idea "Providing Farmers with Expert Help on Demand."

The app should include the following features:

Image-based Diagnosis: Farmers take a photo of crops. Gemini Vision diagnoses the issue and returns:

Probable disease

Recommended treatments using locally available inputs

Step-by-step application guidance

A short TTS (Text-to-Speech) summary in the farmer's local language

Hyperlocal Agri-Weather Alerts:

Fetch weather data (mock/stub or via Google Weather API)

Use Gemini to generate actionable alerts like “Don’t spray today—rain expected”

Deliver alerts via push notifications and local language TTS

Dynamic Profit Forecaster:

Use mandi price trends (mocked initially)

Gemini forecasts optimal selling windows

Show clear explanations and “what-if” scenarios in text + TTS format

Multilingual Voice & Text Interface:

UI and content localized in at least one regional language

Use TTS for all AI-generated outputs

(Optional) Add STT (Speech-to-Text) for input

Offline-first Support:

Use SQLite/Isar for caching recent diagnoses, forecasts, and alerts

Allow actions while offline; sync data to Firebase when back online

Use Firebase for:

Auth (phone OTP)

Firestore (user data, diagnoses, forecasts, alerts)

Firebase Storage (image uploads)

Cloud Functions (Gemini API calls)

FCM (weather alert notifications)

Remote Config and App Check

Use Gemini APIs via Cloud Functions to:

Diagnose crop diseases from images

Generate hyperlocal risk advisories from weather data

Forecast market price trends and selling advice

Deliverables:

Flutter app source code

Firebase project config

Cloud Function code for Gemini calls
