# Filters
@angular.module("manschaftApp.filters", []).filter("interpolate", ["version", (version) ->
  (text) ->
    String(text).replace /\%VERSION\%/g, version
]).filter('empty', ->
  (input) ->
    !input or input.length == 0
).filter('or', ->
  (input, theOther) ->
    if input then input else theOther
).filter('departmentFilter', ->
  (team, departmentFilter) ->
    return team unless departmentFilter
    member for member in team when member.matchedByDepartmentFilter(departmentFilter)
).filter('filteredDepartment', ->
  (department, departmentFilter, ifFiltered) ->
    return null unless department
    return null unless departmentFilter
    return ifFiltered if departmentFilter[department._id]
    null
)
