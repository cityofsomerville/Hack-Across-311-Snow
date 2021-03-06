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

If `compass` is not already installed, you will first need ruby and the ruby dev packages which can be downloaded and installed with your OS's package manager. E.g.`yum install ruby ruby-devel` on RedHat based systems. 

## Development Framework
* Bootstrap http://getbootstrap.com/
* AngularJS https://angularjs.org/


## Build & development
After you clone repo dependencies need to be loaded

    cd Hack-Across-311-Snow
    npm install
    bower install

The grunt utility is then used to execute various tasks. On the command line run `grunt` for building and `grunt serve` for preview and development with live reloading, i.e. changes are immediately reflected in the browser without refresh.

## Testing

Running `grunt test` will run the unit tests with karma.

## 311 Data
  We are using information from Socrata provided by MassDATA. Field names are specific to the MassDATA Open_Tickets database but can be changed to match any JSON 311 work request data source
