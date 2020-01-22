# DeviceTracker

An example app used for a really great Elixir testing training! This application
is "complete" and "works". The thing is, it has bugs. Lots of bugs 🐛🐞🐛🐞🐛🐞

Our goal today is to find these bugs! If you have time and you want to you can
try and fix them, but that's not actually the goal of the exercises today. Today
we're just writing tests that will illustrate these bugs, and hopefully give us
some really great error messages so we can have a really easy time fixing the
bug (and get good information if we happen to introduce a regression in the
future).

## What it does

This application serves as an API for devices out in the world that send
measurements to the application. There is no database backing the app - all
information about these devices is stored in memory. These measurements can then
be accessed in a web app to get data about the devices.

Devices can be registered, unregistered and configured. The configuration
includes the following options:

* Is the device on or off?
* What type of measurements does it store?
* What is the maximum number of measurements a device should store for a certain
  type? For all types?
* Is there a warning threshold for a certain type of measurement?
* Does a device belong to a group of devices?

# Bugs

## Unit tests
* Division by 0 error when calculating the average of an empty list.
* Measurements don't show up in views if there aren't any measurements, but
    should show that there are 0 measurements.
* Exception when trying to get information for a device that hasn't been
    registered.

## Unit test GenServer
* Adding a measurement to a type that hasn't been registered doesn't raise an
    error
* Triggering the alarm when a device is turned off shouldn't be possible because
    we shouldn't accept new measurements when the device is off
* Max number of measurements doesn't get updated when adding a new measurement
  type and so we go over the max number of all measurements
* Test crash and restart behavior for linked devices
* Improve tests in DeviceTests because they're flakey and not isolated

## Wallaby integration tests (UI and API)
* UI only displays 3 measurement types even if a fourth is added.
* UI shows data for a device that is off even though it shouldn't.
* Return 500 for the API because of malformed JSON (include a tuple or
  something that can't be encoded).

## Stateless property based tests (UI fuzzing, number crunching)
* Ensure the API never returns 500.
* Ensure that all webpages can always be rendered correctly in the UI.

## Stateful property based tests (Device server state transitions)
* Ensure allowed actions for device states.
*   Only config that can change when off is to turn it back on again
*   No measurements are stored when the device is off
*   We remain in a warning state when we've gone over the threshold until we've
    seen another measurement that is under the threshold
* We never exceed the max number of measurements (if set).
* We never have more than the max number of measurements after setting the max
    number of measurements.
