# - Name
# - Geburtsname
# - Anschrift
# - Geburtstag
# - Privat Telefon / Handy
# - email
# - grone telefonnummer / email
# - männlich / weiblich
# - Titel

isArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

countBits = (x) ->
  x = x - ((x >> 1) & 0x55555555)
  x = (x & 0x33333333) + ((x >> 2) & 0x33333333)
  x = x + (x >> 4)
  x &= 0xF0F0F0F
  (x * 0x01010101) >> 24
countBitsLoop = (x) ->
  result = 0
  until x is 0
    x &= x - 1
    result++
  result

isOnWeekend = (date) ->
  weekday = date.day()
  weekday is 6 or weekday is 0

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
    return false unless @departments

    departmentObject = {}
    for department in @departments
      departmentObject[department._id] = true

    return false for filterDepartment, turnedOn of departmentFilter when turnedOn and !departmentObject[filterDepartment]
    true

  absence: (month, reason) =>
    year = month.year()
    month = month.month()
    @absences[year] ||= {}
    @absences[year][reason] ||= []
    @absences[year][reason][month] ||= 0
    @absences[year][reason][month]

  setAbsence: (month, reason, absence) =>
    year = month.year()
    month = month.month()
    @absences[year][reason][month] = absence

  toggleAbsence: (day, month, reason) =>
    throw new Error("Unsupported reason: #{reason}!") if TeamMember.absenceTypes.indexOf(reason) < 0

    @setAbsence(month, reason, @absence(month, reason) ^ (1 << day))

    @clearAbsence(day, month, 'ill') if reason == 'ill-doctor'
    @clearAbsence(day, month, 'ill-doctor') if reason == 'ill'

  absenceRange: (day, month, reason) =>
    inputMoment = moment(month).date(day)
    #find start
    cursor = moment(inputMoment)
    while @isAbsent(cursor.date(), cursor, reason) or isOnWeekend(cursor)
      cursor.subtract('days', 1)
    start = cursor

    #find end
    cursor = moment(inputMoment)
    while @isAbsent(cursor.date(), cursor, reason) or isOnWeekend(cursor)
      cursor.add('days', 1)
    end = cursor
    moment().range(start.add('days', 1), end.subtract('days', 1))

  clearAbsence: (day, month, reason) =>
    throw new Error("Unsupported reason: #{reason}!") if TeamMember.absenceTypes.indexOf(reason) < 0

    @setAbsence(month, reason, @absence(month, reason) & ~(1 << day))

  isAbsent: (day, month, reason) =>
    @absence(month, reason) & (1 << day)

  countAbsence: (months, reason) =>
    months = [months] unless isArray(months)
    sum = 0
    for month in months
      sum += countBits(@absence(month, reason))
    sum

  setLongTermAbsence: (start, end, reason) =>
    date = moment(start)
    while date <= end
      day = date.date()
      weekday = date.day()
      unless isOnWeekend(date)
        @clearAbsence(day, date, reason)
        @toggleAbsence(day, date, reason)
      date.add('days' , 1)

  clearLongTermAbsence: (start, end, reason) =>
    cursor = moment(start)
    while cursor <= end
      day = cursor.date()
      @clearAbsence(day, cursor, reason)
      cursor.add('days', 1)


  update: (attributes) =>
    @_id = attributes._id
    @firstName = attributes.firstName
    @lastName = attributes.lastName
    @departments = attributes.departments
    @absences = attributes.absences

TeamMember.absenceTypes = ['pto', 'pto-education', 'ill', 'ill-doctor', 'ill-baby', 'unknown']

TeamMember.absenceLabels = {
  "pto": 'Urlaub'
  "pto-education": "Bildungsurlaub"
  "ill": "Krank"
  "ill-doctor": "Krank mit AU"
  "ill-baby": "Kind krank"
  "unknown": "Unbekannt"
}

@mannschaft ||= {}
@mannschaft.models = {
  TeamMember: TeamMember
}
