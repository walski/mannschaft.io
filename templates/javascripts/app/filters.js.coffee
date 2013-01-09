# Filters

compare = (a,b) ->
  if a > b
    return 1
  if b > a
    return -1
  0

deepAccess = (object, keys) ->
  keys = angular.copy(keys)
  if !keys or keys.length < 1
    return object
  deepAccess(object[keys.shift()], keys)

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
).filter('departmentFilterClass', ->
  (departmentFilter, activeFilterClass, inactiveFilterClass) ->
    activeFilterClass ||= 'departments-filtered'
    inactiveFilterClass ||= ''

    someFilterActive = false

    for id, active of departmentFilter
      someFilterActive = someFilterActive or (!!active)

    if someFilterActive
      activeFilterClass
    else
      inactiveFilterClass
).filter('orderObject', ->
  (object, properties) ->
    ordered = []
    keys = []
    for key,value of object
      keys.push(key)
      ordered.push(key: key, value: value, $$hashKey: angular.toJson(value))
    ordered = ordered.sort (a, b) -> compare(deepAccess(a.value, properties), deepAccess(b.value, properties))
    ordered
).filter('reverse', ->
  (array) ->
    return unless array
    array.reverse()
).filter('teamCount', ->
  (team, scope) ->
    scope.teamCount = team.length
    team
).filter('month', ->
  (date) ->
    return unless date
    date.format("MMMM YYYY")
).filter('wholeDate', ->
  (date) ->
    return unless date
    date.format("DD. MMMM YYYY")
).filter('datepickerMonth', ->
  (date) ->
    date.format('MM-YYYY')
).filter('days', ->
  (date) ->
    day for day in [1..date.daysInMonth()]
).filter('randomIcon', ->
  (random) ->
    Math.random() > 0.95
).filter('openAbsenceCell', ->
  (activeCell, member, day) ->
    if activeCell and activeCell[0] == member and activeCell[1] == day
      "open"
    else
      ""
).filter('absenceClasses', ->
  (member, month, day) ->
    classes = ""
    for absenceType in mannschaft.models.TeamMember.absenceTypes
      classes += " active-#{absenceType}" if member.isAbsent(day, month, absenceType)
    classes
).filter('absenceLabel', ->
  (absenceType) ->
    mannschaft.models.TeamMember.absenceLabels[absenceType]
)