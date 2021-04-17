# GeoGraph

This is GeoGraph, the project that i have developed as as my undergraduate's thesis.

The GeoGraph is an app designed for enabling real time geolocation sharing between users with a iteractive map or a dynamic list. This Geolocation sharing is restricted for user groups created by the users itself.


## Images and Features

### Menu
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/menu.jpg?raw=true "Title")
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/drawer.jpg?raw=true "Title")drawer

### Group Menu
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/drawe-map.jpg?raw=true "Title")

### Real time iterative map
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/map.jpg?raw=true "Title")

### Real time dinamic members list
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/dinamic-list.jpeg?raw=true "Title")

### Login Screen
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/login.jpg?raw=true "Title")

### Accounts creation
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/register.jpg?raw=true "Title")

### Groups creation
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/create-group.jpg?raw=true "Title")

### Group Invite with deep link
![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/deep-link.jpg?raw=true "Title")


## Architecture

### Components design

For state management, the GeoGraph is using the [BLOC pattern](https://www.raywenderlich.com/4074597-getting-started-with-the-bloc-pattern) with [Mobx](https://pub.dev/packages/mobx) and [Provider](https://pub.dev/packages/provider) libs.

These are the major components implemented:

![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main//bloc-architecture.png?raw=true "Title")

### Cloud 

All cloud infrastructured is being provided by google's Firebase platform.

It is using Cloud authentication for dealing with personal account management and authentication, Firestore real time database for providing real time geopoints write/read and Cloud Storage for storing user profile images and group images.

![Home Page](https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main//cloud-architecture.png?raw=true "Title")

## My Thesis

You can check my complete Thesis PDF with more info about here: https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/TCC%20-%20GeoGraph.pdf
