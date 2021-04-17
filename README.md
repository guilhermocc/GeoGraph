# GeoGraph

This is GeoGraph, the project that i have developed as my undergraduate thesis.

The GeoGraph is an app designed for enabling real-time geolocation sharing between users with an interactive map and a dynamic list. The feature of geolocation sharing includes:
- The distance between locations is kilometers, meters, and centimeters using GPS for getting the geographic coordinates and the [haversine formula](https://en.wikipedia.org/wiki/Haversine_formula) for calculating the distance.
- Reverse geocoding for conversion of geographic coordinates into human-readable addresses.
- Real-time geographic data sync with time interval and position movement detection.

This Geolocation sharing is restricted to user groups created by the users themselves.


## Images and Features

### Menu
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/menu.jpg" widtth="300" height="500"> 
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/drawer.jpg" widtth="300" height="500"> 

### Group Menu
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/drawe-map.jpg" widtth="300" height="500"> 

### Real time iterative map
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/map.jpg" widtth="300" height="500"> 

### Real time dinamic members list
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/dinamic-list.jpeg" widtth="300" height="500">

### Login Screen
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/login.jpg" widtth="300" height="500"> 

### Accounts creation
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/register.jpg" widtth="300" height="500"> 

### Groups creation
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/create-group.jpg" widtth="300" height="500"> 

### Group Invite with deep link
<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/deep-link.jpg" widtth="300" height="500"> 


## Architecture

### Components design

For state management, the GeoGraph is using the [BLOC pattern](https://www.raywenderlich.com/4074597-getting-started-with-the-bloc-pattern) with [Mobx](https://pub.dev/packages/mobx) and [Provider](https://pub.dev/packages/provider) libs.

These are the major components implemented:

<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main//bloc-architecture.png"  widtth="300" height="500"> 

### Cloud 

All cloud infrastructured is being provided by google's Firebase platform.

It is using Cloud authentication for dealing with personal account management and authentication, Firestore real time database for providing real time geopoints write/read and Cloud Storage for storing user profile images and group images.

<img src = "https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main//cloud-architecture.png"  widtth="300" height="500"> 

## My Thesis

You can check my complete Thesis PDF with more info about here: https://github.com/GuilhermBrSp/Undergraduate-Thesis/blob/main/TCC%20-%20GeoGraph.pdf
