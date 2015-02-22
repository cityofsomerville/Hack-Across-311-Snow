(function() {
  'use strict';

  /**
    * @ngdoc function
    * @name som311App.controller:AboutCtrl
    * @description
    * # AboutCtrl
    * Controller of the som311App
   */
  angular.module('som311App').filter('sortByTotal', function() {
    return function(assoc, take, order) {
      if (take == null) {
        take = 10;
      }
      if (order == null) {
        order = 'DESC';
      }
      return _.take(_.sortBy(assoc, 'total'), take);
    };
  }).filter('tableDate', function($filter) {
    return function(date) {
      if (date) {
        return $filter('date')(date, "EEE MMM d, yyyy");
      } else {
        return date;
      }
    };
  }).service('GeoSvc', [
    '$http', function($http) {
      return {
        geoIP: function(ip) {
          var url;
          url = "http://freegeoip.net/json/" + ip;
          return $http.get(url).then(function(res) {
            return res.data;
          });
        }
      };
    }
  ]).service('SocrataSvc', [
    '$log', '$http', function($log, $http) {
      var datamass, opentickets, ticketct;
      datamass = "https://data.mass.gov/resource";
      opentickets = "" + datamass + "/5d43-5364.json";
      ticketct = "" + datamass + "/chr2-q5qh.json";
      return {
        tickets: function(city) {
          var qry, xformTicket;
          qry = {
            city: city,
            $order: "ticket_last_updated_date_time DESC"
          };
          xformTicket = function(data) {
            var _ref, _ref1;
            if (((_ref = data.location) != null ? _ref.latitude : void 0) && ((_ref1 = data.location) != null ? _ref1.longitude : void 0)) {
              data.location.latitude = parseFloat(data.location.latitude);
              data.location.longitude = parseFloat(data.location.longitude);
            }
            data.ticket_created_date_time = new Date(data.ticket_created_date_time);
            data.ticket_last_updated_date_time = new Date(data.ticket_last_updated_date_time);
            if (data.ticket_closed_date_time) {
              data.ticket_closed_date_time = new Date(data.ticket_closed_date_time);
            }
            return data;
          };
          return $http.get(opentickets, {
            params: qry,
            transformResponse: function(data, headers) {
              return _.map(JSON.parse(data), xformTicket);
            }
          });
        },
        categories: function(city) {
          var qry;
          qry = {
            "$select": "issue_type as category, count(*) as total",
            "$group": "issue_type",
            "city": city
          };
          return $http.get(opentickets, {
            params: qry
          });
        },
        cities: function() {
          var qry;
          qry = {
            $select: "city"
          };
          return $http.get(ticketct, {
            params: qry
          });
        },
        textQuery: function(str, city) {
          var qry;
          if (city == null) {
            city = "";
          }
          qry = {
            $q: str,
            city: city
          };
          return $http.get(opentickets, {
            params: qry
          });
        }
      };
    }
  ]).controller('AboutCtrl', function($scope, SocrataSvc, GeoSvc, leafletData) {
    var geoIP_err, geoIP_ok, ticket2leafmarker, update, updateCategories, updateMap, updateTickets;
    ticket2leafmarker = function(ticket) {
      var message, _ref;
      if (!((_ref = ticket.location) != null ? _ref.longitude : void 0)) {
        return {};
      } else {
        message = "<h5>" + ticket.issue_type + "<h5> <div> " + (ticket.issue_description || "") + " <dl class='dl-horizontal'> <dt class='time-label'>Opened</dt> <dd class='time'> " + ticket.ticket_created_date_time + "</dd> <dt class='time-label'>Closed</dt> <dd class='time'>" + (ticket.ticket_closed_date_time || "still open") + "</dd> </dl> </div>";
        return {
          lng: ticket.location.longitude,
          lat: ticket.location.latitude,
          message: message,
          open: !ticket.ticket_closed_date_time
        };
      }
    };
    updateCategories = function(city) {
      return SocrataSvc.categories(city).then(function(response) {
        console.log(response.data);
        return $scope.categories = response.data;
      });
    };
    updateTickets = function(city) {
      return SocrataSvc.tickets(city).then(function(response) {
        return $scope.tickets = response.data;
      });
    };
    updateMap = function(city, tickets) {
      $scope.data.markers = _.take(_.filter(_.map(tickets, ticket2leafmarker), function(marker) {
        return marker.open;
      }), 100);
      return console.log("markers:", $scope.data.markers);
    };
    update = function() {
      var city, _ref;
      if ((city = (_ref = $scope.selectedCity) != null ? _ref.city : void 0)) {
        updateCategories(city);
        return updateTickets(city).then(function(tickets) {
          return updateMap(city, tickets);
        });
      }
    };
    $scope.data = {
      markers: {}
    };
    $scope.selectedCity = {
      city: 'City of Somerville'
    };
    geoIP_ok = function(geo) {
      return {
        lat: geo.latitude,
        lng: geo.longitude
      };
    };
    geoIP_err = function(err) {
      return {
        lat: 42.44,
        lng: -71.07
      };
    };
    GeoSvc.geoIP("").then(geoIP_ok, geoIP_err).then(function(loc) {
      return $scope.map = {
        center: _.extend(loc, {
          zoom: 12
        })
      };
    });
    update();
    SocrataSvc.textQuery("tree").then(function(response) {
      return console.log(response);
    });
    SocrataSvc.cities().then(function(response) {
      return $scope.cities = response.data;
    });
    $scope.awesomeThings = ['HTML5 Boilerplate', 'AngularJS', 'Karmad'];
    return $scope.updateCity = function() {
      console.log("foof", $scope.selectedCity);
      return update();
    };
  });


  /*
  
  
    .controller('TicketCtrl, ['$scope', 'SocrataSvc', [($scope, SocrataSvc) ->
      $scope.categories = SocrataSvc.categories()
    ])
  
  
    .directive('topCategories', [() ->
      replace: true
      templateUrl: 'templates/topCategories.html'
    ])
   */

}).call(this);

//# sourceMappingURL=about.js.map
