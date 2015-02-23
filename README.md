# Hack-Across-311-Snow
![](https://raw.githubusercontent.com/cityofsomerville/Hack-Across-311-Snow/master/app/images/tellus-logo-sm.gif)
Visualizing 311 calls for constituents.

## Toolkit
* Git
* Node.js http://nodejs.org/
* Compass http://compass-style.org/
* Grunt http://gruntjs.com/
* Bower http://bower.io/
* JSHint http://jshint.com/

Installing node.js installs the `npm` package manager. Once installed, grunt, bower and jshint can be installed with the `npm` command:

    npm -g install bower grunt-cli jshint

## Development Framework
* Bootstrap http://getbootstrap.com/
* AngularJS https://angularjs.org/


## Build & development
After you clone repo

Run `grunt` for building and `grunt serve` for preview.

## Testing

Running `grunt test` will run the unit tests with karma.

## 311 Data
  We are using information from Socrata provided by MassDATA. Field names are specific to the MassDATA Open_Tickets database but can be changed to match any JSON 311 work request data source
