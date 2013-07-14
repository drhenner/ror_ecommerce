# @sales_data
#
# @people = People.all
#json.array! @people do |person|
#  json.name person.name
#  json.age calculate_age(person.birthday)
#end
#
#
# => [ { "name": "David", "age": 32 }, { "name": "Jamie", "age": 31 } ]
#

json.array! @sales_data.weekly_summary
