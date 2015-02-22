'use strict'

###*
 # @ngdoc function
 # @name som311App.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the som311App
###
angular.module 'som311App'
  .filter('sortByTotal', () ->

    (assoc, take=10, order='DESC') ->
      _.take(_.sortBy(assoc, 'total'), take)
  )

  .filter('tableDate', ($filter) ->
    (date) ->
      if (date) then $filter('date')(date, "EEE MMM d, yyyy") else date
  )

  .service('GeoSvc', ['$http', ($http) ->
    geoIP: (ip) ->
      url = "http://freegeoip.net/json/#{ip}"
      $http.get(url).then((res) -> res.data)

  ])


  .service('SocrataSvc', ['$log', '$http', ($log, $http) ->
    # categories endpoint
    #
    datamass = "https://data.mass.gov/resource"
    opentickets = "#{datamass}/5d43-5364.json"
    ticketct = "#{datamass}/chr2-q5qh.json"


    tickets: (city) ->
      qry =
       city: city
       $order: "ticket_last_updated_date_time DESC"

      xformTicket = (data) ->
       if (data.location?.latitude and data.location?.longitude)
         data.location.latitude = parseFloat(data.location.latitude)
         data.location.longitude = parseFloat(data.location.longitude)
       data.ticket_created_date_time = new Date(data.ticket_created_date_time)
       data.ticket_last_updated_date_time = new Date(data.ticket_last_updated_date_time)
       data.ticket_closed_date_time = new Date(data.ticket_closed_date_time) if data.ticket_closed_date_time

       return data


      $http.get(opentickets,
        params: qry
        transformResponse: (data, headers) -> _.map(JSON.parse(data), xformTicket)
      )

    categories: (city) ->
      qry =
        "$select": "issue_type as category, count(*) as total"
        "$group": "issue_type"
        "city": city
        # order is too complex for Socrata => "$order": "total"

      $http.get(opentickets, params: qry)

    cities: () ->
      qry = $select: "city"
      $http.get(ticketct, params: qry)


    textQuery: (str, city="") ->
      qry =
        $q: str
        city: city
      $http.get(opentickets, params: qry)

  ])
  .controller 'AboutCtrl', ($scope, SocrataSvc, GeoSvc, leafletData) ->
    ticket2leafmarker = (ticket) ->
      if (! ticket.location?.longitude)
        {}
      else
        message =  "
          <h5>#{ticket.issue_type}<h5>
          <div>
            #{ticket.issue_description||""}
            <dl class='dl-horizontal'>
              <dt class='time-label'>Opened</dt>
                <dd class='time'> #{ticket.ticket_created_date_time}</dd>
              <dt class='time-label'>Closed</dt>
                <dd class='time'>#{ticket.ticket_closed_date_time||"still open"}</dd>
            </dl>
          </div>"

        lng: ticket.location.longitude
        lat: ticket.location.latitude
        message: message
        open: ! ticket.ticket_closed_date_time
        #  description: ticket.description
        #"marker-size": "medium"
        #"marker-color": "#ff0000"


    updateCategories = (city) ->
      SocrataSvc.categories(city).then((response) ->
        console.log(response.data)
        $scope.categories = response.data
      )

    updateTickets = (city) ->
      SocrataSvc.tickets(city).then((response) ->
        $scope.tickets = response.data
      )

    updateMap = (city, tickets) ->
      markers = _.take(_.filter(_.map(tickets, ticket2leafmarker),
        (marker) -> marker.open), 100)
      $scope.data.markers = markers
      console.log("markers:", markers)

      leafletData.getMap().then((map) ->
        map.fitBounds(L.latLngBounds(markers)))
      #leafletData.getMap().then((map) ->
      #  L.GeoIP.centerMapOnPosition(map, 15);
      #)

    update = () ->
      if ((city = $scope.selectedCity?.city))
        updateCategories(city)
        updateTickets(city).then((tickets) -> updateMap(city, tickets))


    # default values
    $scope.data =
      markers: {}

    $scope.selectedCity = city: 'City of Somerville'

    geoIP_ok = (geo) ->
      lat: geo.latitude
      lng: geo.longitude

    geoIP_err = (err) ->
      lat: 42.44
      lng: -71.07


    # updateCategories($scope.selectedCity.city)
    GeoSvc.geoIP("").then(geoIP_ok, geoIP_err).then((loc)->
      $scope.map =
        center: _.extend(loc, zoom:12)
    )
    update()



    SocrataSvc.textQuery("tree").then((response) -> console.log(response))

    SocrataSvc.cities().then((response) ->
      $scope.cities = response.data
    )



    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karmad'
    ]

    $scope.updateCity = () ->
      console.log("foof", $scope.selectedCity)
      update()


###


  .controller('TicketCtrl, ['$scope', 'SocrataSvc', [($scope, SocrataSvc) ->
    $scope.categories = SocrataSvc.categories()
  ])


  .directive('topCategories', [() ->
    replace: true
    templateUrl: 'templates/topCategories.html'
  ])
###
