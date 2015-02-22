(function() {
  'use strict';

  /**
    * @ngdoc overview
    * @name som311App
    * @description
    * # som311App
    *
    * Main module of the application.
   */
  angular.module('som311App', ['ui.bootstrap', 'leaflet-directive', 'ngAnimate', 'ngCookies', 'ngResource', 'ngRoute', 'ngSanitize', 'ngTouch']).config(function($routeProvider) {
    return $routeProvider.when('/', {
      templateUrl: 'views/main.html',
      controller: 'MainCtrl'
    }).when('/tickets', {
      templateUrl: 'views/about.html',
      controller: 'AboutCtrl'
    }).otherwise({
      redirectTo: '/'
    });
  }).controller('TicketTableCtrl', [
    '$scope', function($scope) {
      return $scope.foo = "foobar";
    }
  ]);

}).call(this);

//# sourceMappingURL=app.js.map
