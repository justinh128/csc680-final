# Capsule — A Time Capsule App  
Final Project for CSC 660/680  
By Justin Ho

## About the App

Capsule is a mobile app built using SwiftUI that lets users create and send digital time capsules. Users can write messages, add images, and set a date and time when the capsule will unlock. Once the time is up, they receive access to view the contents. Users can also add friends and send them capsules.

This app is designed to be fun and thoughtful by sending your future self or a friend a surprise to open later.

## Core Features

### User Accounts
- Sign up and log in using Firebase Authentication
- Each user has a private account to manage their own capsules and friends

### Create a Time Capsule
- Add a title, message, optional image, and unlock date/time
- Capsules remain locked until the unlock date
- Once opened, capsules can be marked as read, saved, or deleted

### Friends System
- Search for other users by email and send friend requests
- Accept or decline incoming friend requests
- View a list of all confirmed friends

### Sending Capsules
- Choose to create a capsule for yourself or send it to a friend
- Sent capsules show who received them
- Received capsules show who sent them
- All capsules stay locked until their unlock date

### Capsule Organization
- View capsules by type:
  - My Capsules (created for yourself)
  - Sent Capsules (you’ve sent to others)
  - Received Capsules (sent to you)
  - Saved Capsules (you chose to save after opening)

## Technologies Used

- SwiftUI for building the user interface
- Firebase Authentication for user login and signup
- Firebase Firestore for storing capsule and friend data
- Firebase Storage for saving images
- MVVM (Model-View-ViewModel) architecture
- PhotosPicker for selecting capsule images

## How It Works

1. Sign up or log in with your email
2. Tap the "+" button to create a new capsule
3. Choose a title, message, optional image, unlock date, and a recipient (yourself or a friend)
4. Capsules will remain locked until the date and time you choose
5. When the time comes, the capsule can be opened
6. You can save, delete, or mark the capsule as read

## Notes
- I was unable to get the styling working across all pages, so I'm leaving it as blank for now. I will likely revisit this. 
