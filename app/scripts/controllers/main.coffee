'use strict'

###*
 # @ngdoc function
 # @name som311App.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the som311App
###
angular.module 'som311App'
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
