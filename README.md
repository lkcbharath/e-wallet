# E-Wallet
A Flutter app that uses Cloud Firestore included with Google Firebase to provide digital wallets for each user and allow cashless transactions.

To add your own database, create a Firebase app and enable Cloud Firestore, then download google-services.json and add it under /android/app/.
Before building the app, make sure the structure of the database resembles the following:
- players
  - (auto-id)
    - name (string)
    - money (number)
    - id (number)
    - chosen (boolean)

and has atleast one user named 'Banker', with 'chosen' set to `false`.

Take a look at .gitignore, /android/.gitignore and /ios/.gitignore for other files that may be required.
