# Controllers
@SidebarController = ($scope) ->
  $scope.pages = [
    {
      id: 'dashboard'
      url: "#/dashboard"
      icon: "eye"
      label: "Auf einen Blick"
    }
    {
      id: 'team'
      url: "#/team"
      icon: "user-2"
      label: "Mannschaft"
      subpages: [
        {
          url: "#/team"
          icon: "user-2"
          label: "Mitarbeiter"
        }
        {
          url: "#/team/departments"
          icon: "tree-view"
          label: "Abteilungen"
        }
      ]
    }
    {
      id: 'calendar'
      url: "#/calendar"
      icon: "calendar"
      label: "Fehlzeiten"
    }
  ]
@SidebarController.$inject = ['$scope']

@DashboardController = ($rootScope) ->
  $rootScope.activeView = "dashboard"
  $rootScope.pageTitle = "Dashboard"
@DashboardController.$inject = ["$rootScope"]

@TeamController = ($rootScope, $scope, $routeParams, $location, teamService) ->
  $rootScope.activeView = "team"
  $rootScope.pageTitle = "Mitarbeiter"

  $scope.team = teamService.team

  $scope.departments = ->
    departments = {}
    delete departments[id] for id, department of departments

    for member in $scope.team
      for department in member.departments
        unless departments[department._id]
          departments[department._id] = {department: department, $$hashKey: -> JSON.stringify(this)}
        departments[department._id].count ||= 0
        departments[department._id].count += 1
    departments

  $scope.newTeamMember = ->
    new mannschaft.models.TeamMember()

  $scope.loadTeamMember = ->
    teamService.load($routeParams.memberId)

  $scope.saveTeamMember = (teamMember) ->
    teamService.save(teamMember).then ->
      $location.path('/team')

  $scope.deleteTeamMember = (teamMember) ->
    if window.confirm('Wirklich löschen?')
      teamService.delete(teamMember).then ->
        $location.path('/team')

  $scope.toggleDepartmentFilter = (department) ->
    $rootScope.departmentFilter ||= {}
    $rootScope.departmentFilter[department._id] = !$rootScope.departmentFilter[department._id]


  $scope.clearDepartmentFilter = ->
    delete $rootScope.departmentFilter

@TeamController.$inject = ["$rootScope", "$scope", "$routeParams", "$location", "teamService"]

@MyCtrl2 = ($rootScope) ->
  $rootScope.activeView = "view2"
@MyCtrl2.$inject = ["$rootScope"]