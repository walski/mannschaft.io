# Services

# Demonstrate how to register services
# In this case it is a simple value service.
services = @angular.module("manschaftApp.services", []).
  value("version", "0.1").
  value("tenant", "Grone")

BACKEND_URL = "/backend/v1"

services.factory('teamService', ['$q', '$http', ($q, $http) ->
  getTeam = (options = {}) ->
    team = []
    $http({method: 'GET', url: "#{BACKEND_URL}/team"}).
    success((data, status, headers, config) ->
      team.push(new mannschaft.models.TeamMember(entry.teamMember)) for entry in data
      options.success(team) if options.success
    ).
    error((data, status, headers, config) ->
      console.log("Could not load team.", data, status, headers, config)
      options.error(data, status, headers, config) if options.error
    );
    team

  team = getTeam()

  {
    team: team
    load: (id) ->
      for member in team
        if member._id is id
          return member
      fakeMember = new mannschaft.models.TeamMember
      team = getTeam(success: ->
        for member in team
          if member._id is id
            fakeMember.update(member)
            return
        alert("Mitarbeiter wurde nicht gefunden.")
      )
      fakeMember

    save: (teamMember) ->
      deferred = $q.defer()
      if teamMember.isNew()
        $http.post("#{BACKEND_URL}/team", {teamMember: teamMember}).
        success((data, status, headers, config) ->
          newMember = new mannschaft.models.TeamMember(data.teamMember)
          team.push(newMember)
          deferred.resolve(newMember)
        ).
        error((data, status, headers, config) ->
          console.log("Could not save team member.", data, status, headers, config)
          deferred.reject(data, status, headers, config)
        )
      else
        $http.put("#{BACKEND_URL}/team/#{teamMember._id}", {teamMember: teamMember}).
        success((data, status, headers, config) ->
          teamMember.update(data.teamMember)
          deferred.resolve(teamMember)
        ).
        error((data, status, headers, config) ->
          console.log("Could not save team member.", data, status, headers, config)
          deferred.reject(data, status, headers, config)
        )
      deferred.promise

    delete: (teamMember) ->
      deferred = $q.defer()
      $http.delete("#{BACKEND_URL}/team/#{teamMember._id}").
      success((data, status, headers, config) ->
        deferred.resolve()
      ).
      error((data, status, headers, config) ->
        console.log("Could not delete team member.", data, status, headers, config)
        deferred.reject(data, status, headers, config)
      )
  }
])