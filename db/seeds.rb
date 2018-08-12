# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

raise "Empty databse using 'rake db:reset'" if User.count > 0 ||
                        NonProfit.count > 0 ||
                        Donation.count > 0

puts "Creating demo user..."

User.create!([{
  email: 'charityemailtest@gmail.com',
  password_digest: '$2a$10$V5ODZlA92n5AgcYr2OOMg.dQfjfUmYLKeUwfOtWbEnP...',
}