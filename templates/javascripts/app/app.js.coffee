# Declare app level module which depends on filters, and services
angular.module("manschaftApp", ["ngResource", "manschaftApp.filters", "manschaftApp.services", "manschaftApp.directives"]).config ["$routeProvider", ($routeProvider) ->
  $routeProvider.when "/dashboard",
    templateUrl: "partials/dashboard.html"
    controller: DashboardController

  $routeProvider.when "/team",
    templateUrl: "partials/team/index.html"
    controller: TeamController

  $routeProvider.when "/team/new",
    templateUrl: "partials/team/new"
    controller: TeamController

  $routeProvider.when "/team/departments",
    templateUrl: "partials/team/departments"
    controller: TeamController

  $routeProvider.when "/team/:memberId",
    templateUrl: "partials/team/edit"
    controller: TeamController

  $routeProvider.when "/absences",
    templateUrl: "partials/absences.html"
    controller: AbsencesController

  $routeProvider.otherwise redirectTo: "/dashboard"
]