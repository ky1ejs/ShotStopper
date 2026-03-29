# ShotStopper

## Description
This is a monorepo that contains code for software related to Tate Mazer's shotStopper. 

## shotStopper
[Tata Mazer](https://tatemazer.com/) created [shotStopper](https://tatemazer.com/store/p/shotstopper-v2) to delivery brew-by-weight functionality to machines that don't have it.

shotStopper is an ESP32-based device that can be connects to a number of bluetooth scales and stops brewing when the target weight is reached.

You can see the source code for the shotStopper on [GitHub](https://github.com/tatemazer/AcaiaArduinoBLE).

## Motivation
shotStopper used to have an iOS app avaialble on the app store, but it has since been removed. The app is still available on the [Google Play Store](https://play.google.com/store/apps/details?id=com.icapurro.shotStopperCompanion&hl=en_US) for Android devices.

I have an iPhone and I wanted to be able to use the shotStopper with my phone, so I decided to reverse engineer the app and create my own version of it to ensure I always can.

## Structure

- `/ios` contains the code for the iOS app