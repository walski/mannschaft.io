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
      id: 'absences'
      url: "#/absences"
      icon: "calendar"
      label: "Fehlzeiten"
    }
  ]
@SidebarController.$inject = ['$scope']

@OverallController = ($rootScope, teamService) ->
  $rootScope.team = teamService.team

  $rootScope.toggleDepartmentFilter = (department) ->
    $rootScope.departmentFilter ||= {}
    $rootScope.departmentFilter[department._id] = !$rootScope.departmentFilter[department._id]

  $rootScope.setDepartmentFilter = (department) ->
    filter = {}
    filter[department._id] = true
    $rootScope.departmentFilter = filter

  $rootScope.clearDepartmentFilter = ->
    delete $rootScope.departmentFilter

@OverallController.$inject = ['$rootScope', 'teamService']

@DashboardController = ($rootScope) ->
  $rootScope.activeView = "dashboard"
  $rootScope.pageTitle = "Dashboard"
@DashboardController.$inject = ["$rootScope"]

@TeamController = ($rootScope, $scope, $routeParams, $location, teamService) ->
  $rootScope.activeView = "team"
  $rootScope.pageTitle = "Mitarbeiter"

  $scope.departments = ->
    departments = {}
    delete departments[id] for id, department of departments

    for member in $scope.team
      if member.departments
        for department in member.departments
          unless departments[department._id]
            departments[department._id] = {department: department, $$hashKey: -> JSON.stringify(this)}
          departments[department._id].count ||= 0
          departments[department._id].count += 1
          departments[department._id].name = department.name
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

@TeamController.$inject = ["$rootScope", "$scope", "$routeParams", "$location", "teamService"]


addDatePicker = (datePickerElement, date, format, onChange) ->
  datePickerElement.data('date', date.format(format))
  datePicker = datePickerElement.datepicker()
  datePicker.on 'changeDate', onChange
  datePickerElement


@AbsencesController = ($rootScope, $scope, $timeout, teamService) ->
  $rootScope.activeView = "absences"
  $rootScope.pageTitle = "Fehlzeiten"

  generateWeekdaysTable = (date) ->
    cursor = moment(date)
    startMonth = cursor.month()
    table = {}
    while cursor.month() is startMonth
      table[cursor.date()] = cursor.day()
      cursor.add('days', 1)
    table

  setMonth = (newMonth) ->
    newMonth = newMonth.startOf('month')
    $scope.weekdays = generateWeekdaysTable(newMonth)

    $scope.month = newMonth

  monthChangeCallback = (e) ->
    datePickerElement = $(this)
    datePickerElement.datepicker('hide')
    setMonth(moment(e.date))
    datePickerElement.datepicker('setValue', e.date)
    $scope.closeCell()
    $scope.$apply()

  longTermChangeCallback = (attribute) ->
    (e) ->
      if e.viewMode is 'days'
        datePickerElement = $(this)
        $rootScope.longTermForm[attribute] = moment(e.date)
        datePickerElement.datepicker('hide')
        datePickerElement.datepicker('setValue', e.date)
        $scope.closeCell()
        $scope.$apply()

  workDayDuration = (range) ->
    cursor = moment(range.start)
    days = 0
    while cursor <= range.end
      weekday = cursor.day()
      days++ if weekday < 6 and weekday > 0
      cursor.add('days', 1)
    days

  setMonth(moment())

  addDatePicker($('#absences-date-picker'), $scope.month, 'MM-YYYY', monthChangeCallback)

  longTermStartPicker = addDatePicker($('#long-term-start-date-picker'), $scope.month, 'DD-MM-YYYY', longTermChangeCallback('start'))
  longTermEndPicker = addDatePicker($('#long-term-end-date-picker'  ), $scope.month, 'DD-MM-YYYY', longTermChangeCallback('end'))

  $scope.isCellOpen = (i,j) ->
    $scope.cellOpened and $scope.cellOpened[0] == i and $scope.cellOpened[1] == j

  $scope.openCell = (i, j) ->
    $scope.cellOpened = [i,j]

  $scope.closeCell = (i, j) ->
    $scope.cellOpened = null

  $scope.absenceTypes = mannschaft.models.TeamMember.absenceTypes

  toggleAbsence = (day, month, reason, member) ->
    $('#long-term-turn-off-form').modal('hide')
    member.toggleAbsence(day, month, reason)
    teamService.save(member)
    $scope.closeCell()

  $scope.clearLongTermAbsence = (longTermInfo) ->
    return unless $scope.isCellOpen(longTermInfo.memberIndex, longTermInfo.dayIndex)
    longTermInfo.member.clearLongTermAbsence(longTermInfo.start, longTermInfo.end, longTermInfo.absenceType)
    teamService.save(longTermInfo.member)
    $scope.closeCell()

  $scope.toggleAbsence = (event, memberIndex, dayIndex, member, day, month, reason, forceToggle) ->
    return unless $scope.isCellOpen(memberIndex, dayIndex)

    $scope.clicked = $timeout(->
      unless $scope.stopped
        if member.isAbsent(day, month, reason)
          range = member.absenceRange(day, month, reason)
          duration = (range.end - range.start) / moment.duration(1, 'days') + 1
          if duration > 1 and !forceToggle
            $rootScope.longTermInfo = {
              member: member,
              absenceType: reason
              start: range.start
              end: range.end
              duration: duration
              workDayDuration: workDayDuration(range)
              requestedDay: moment(month).date(day)
              memberIndex: memberIndex
              dayIndex: dayIndex
            }
            $('#long-term-turn-off-form').modal({show: true}).on('hidden', ->
              delete $rootScope.longTermInfo
              $rootScope.$apply()
            )
          else
            toggleAbsence(day, month, reason, member)
        else
          toggleAbsence(day, month, reason, member)
      $scope.stopped = false
    , 200)


    event.stopPropagation()

  $scope.openLongTermAbsenceForm = (event, memberIndex, dayIndex, member, day, month, reason) ->
    $scope.stopped = $timeout.cancel($scope.clicked)
    return unless $scope.isCellOpen(memberIndex, dayIndex)

    start = moment(month).date(day)

    $rootScope.longTermForm = {
      member: member
      absenceType: reason
      start: start
      end: start
    }

    longTermStartPicker.datepicker('setValue', start)
    longTermEndPicker.datepicker('setValue', start)

    $('#long-term-form').modal({show: true}).on('hidden', ->
      longTermStartPicker.datepicker('hide')
      longTermEndPicker.datepicker('hide')
    )
    $scope.closeCell()
    event.stopPropagation()

  $scope.setLongTermAbsence = (longTermForm) ->
    member = longTermForm.member
    member.setLongTermAbsence(longTermForm.start, longTermForm.end, longTermForm.absenceType)
    $('#long-term-form').modal('hide')
    teamService.save(member)

@AbsencesController.$inject = ["$rootScope", "$scope", "$timeout", "teamService"]