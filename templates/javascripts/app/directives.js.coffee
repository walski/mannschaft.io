# Directives
@angular.module("manschaftApp.directives", []).
  directive("appVersion", ["version", (version) ->
    (scope, elm, attrs) ->
      elm.text version
  ]).
  directive("appTenant", ["tenant", (tenant) ->
    (scope, elm, attrs) ->
      elm.text tenant
  ])