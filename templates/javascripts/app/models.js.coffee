class TeamMember
  constructor: (attributes = {}) ->
    @update(attributes)
    @departments ||= []

  name: ->
    "#{@firstName} #{@lastName}"

  addDepartment: (departmentName) =>
    for department in @departments
      return if department.name is departmentName
    @departments.push({name: departmentName})

  isNew: =>
    !@_id

  matchedByDepartmentFilter: (departmentFilter) =>
    return true unless departmentFilter

    departmentObject = {}
    for department in @departments
      departmentObject[department._id] = true

    return false for filterDepartment, turnedOn of departmentFilter when turnedOn and !departmentObject[filterDepartment]
    true

  update: (attributes) =>
    @_id = attributes._id
    @firstName = attributes.firstName
    @lastName = attributes.lastName
    @departments = attributes.departments

@mannschaft ||= {}
@mannschaft.models = {
  TeamMember: TeamMember
}
