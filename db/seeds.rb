# db/seeds.rb

# Clear existing data in correct order (respecting foreign keys)
puts "🧹 Cleaning database..."
LicenseAssignment.destroy_all
Subscription.destroy_all
User.destroy_all
Product.destroy_all
Account.destroy_all

puts "\n📦 Creating products..."
products = {
  colombia: Product.create!(
    name: "vLex Colombia",
    description: "Comprehensive legal research platform for Colombian law. Includes jurisprudence, doctrine, legislation, and legal forms."
  ),
  costa_rica: Product.create!(
    name: "vLex Costa Rica",
    description: "Legal research platform for Costa Rica with complete legislative database and case law."
  ),
  espana: Product.create!(
    name: "vLex España",
    description: "Spanish legal research platform with extensive coverage of Spanish and EU legislation."
  ),
  mexico: Product.create!(
    name: "vLex México",
    description: "Mexican legal database with federal and state legislation, case law, and legal commentary."
  ),
  argentina: Product.create!(
    name: "vLex Argentina",
    description: "Argentinian legal research tool with comprehensive coverage of national and provincial law."
  )
}

puts "✅ Created #{Product.count} products"

puts "\n🏢 Creating accounts..."
best_law_firm = Account.create!(name: "Best Law Firm")
tech_startup = Account.create!(name: "Tech Startup Legal")
corporate_solutions = Account.create!(name: "Corporate Solutions Inc")
international_law = Account.create!(name: "International Law Partners")

puts "✅ Created #{Account.count} accounts"

puts "\n👥 Creating users for Best Law Firm..."
user_names_blf = [
  "Dean Pendley",
  "Robin Chesterman",
  "Angel Faus",
  "Stu Duff",
  "Kalam Lais",
  "Rose Higgins",
  "Nacho Tinoco",
  "Álvaro Pérez Mompeán",
  "Eserophe Ovie-Okoro",
  "Guillermo Espindola",
  "Rory Campbell",
  "Davide Bonavita"
]

users_best_law = user_names_blf.map do |name|
  email = name.downcase
              .gsub('á', 'a')
              .gsub('é', 'e')
              .gsub('ó', 'o')
              .gsub(' ', '.')
              .gsub(/[^a-z.]/, '') + "@bestlawfirm.com"

  User.create!(
    name: name,
    email: email,
    account: best_law_firm
  )
end

puts "✅ Created #{users_best_law.count} users for Best Law Firm"

puts "\n👥 Creating users for Tech Startup Legal..."
users_tech_startup = []
[
  "Sarah Chen",
  "Michael Rodriguez",
  "Emily Watson",
  "James Kim",
  "Lisa Anderson"
].each do |name|
  email = name.downcase.gsub(' ', '.') + "@techstartup.com"
  users_tech_startup << User.create!(
    name: name,
    email: email,
    account: tech_startup
  )
end

puts "✅ Created #{users_tech_startup.count} users for Tech Startup Legal"

puts "\n👥 Creating users for Corporate Solutions Inc..."
users_corporate = []
[
  "Robert Johnson",
  "Maria Garcia",
  "David Thompson"
].each do |name|
  email = name.downcase.gsub(' ', '.') + "@corporate.com"
  users_corporate << User.create!(
    name: name,
    email: email,
    account: corporate_solutions
  )
end

puts "✅ Created #{users_corporate.count} users for Corporate Solutions Inc"

puts "\n👥 Creating users for International Law Partners..."
users_international = []
[
  "Sophie Martin",
  "Pierre Dubois"
].each do |name|
  email = name.downcase.gsub(' ', '.') + "@intlaw.com"
  users_international << User.create!(
    name: name,
    email: email,
    account: international_law
  )
end

puts "✅ Created #{users_international.count} users for International Law Partners"

puts "\n📋 Creating subscriptions..."

# Best Law Firm subscriptions (well-established firm with multiple products)
sub_colombia_blf = Subscription.create!(
  account: best_law_firm,
  product: products[:colombia],
  number_of_licenses: 10,
  issued_at: 6.months.ago,
  expires_at: 6.months.from_now
)

sub_costa_rica_blf = Subscription.create!(
  account: best_law_firm,
  product: products[:costa_rica],
  number_of_licenses: 10,
  issued_at: 6.months.ago,
  expires_at: 6.months.from_now
)

sub_espana_blf = Subscription.create!(
  account: best_law_firm,
  product: products[:espana],
  number_of_licenses: 15,
  issued_at: 3.months.ago,
  expires_at: 9.months.from_now
)

# Tech Startup subscriptions (smaller team)
sub_mexico_ts = Subscription.create!(
  account: tech_startup,
  product: products[:mexico],
  number_of_licenses: 5,
  issued_at: 2.months.ago,
  expires_at: 10.months.from_now
)

sub_espana_ts = Subscription.create!(
  account: tech_startup,
  product: products[:espana],
  number_of_licenses: 3,
  issued_at: 1.month.ago,
  expires_at: 11.months.from_now
)

# Corporate Solutions subscriptions (mid-size)
sub_colombia_cs = Subscription.create!(
  account: corporate_solutions,
  product: products[:colombia],
  number_of_licenses: 3,
  issued_at: 1.month.ago,
  expires_at: 11.months.from_now
)

sub_argentina_cs = Subscription.create!(
  account: corporate_solutions,
  product: products[:argentina],
  number_of_licenses: 5,
  issued_at: 2.weeks.ago,
  expires_at: 11.months.from_now
)

# International Law Partners subscriptions (small boutique firm)
sub_espana_il = Subscription.create!(
  account: international_law,
  product: products[:espana],
  number_of_licenses: 2,
  issued_at: 3.weeks.ago,
  expires_at: 9.months.from_now
)

# Add an expired subscription for testing
expired_sub = Subscription.create!(
  account: best_law_firm,
  product: products[:mexico],
  number_of_licenses: 5,
  issued_at: 13.months.ago,
  expires_at: 1.month.ago
)

puts "✅ Created #{Subscription.count} subscriptions (including 1 expired)"

puts "\n🎫 Creating license assignments..."

# Best Law Firm - Colombia (5 out of 10 licenses used)
users_best_law.first(5).each do |user|
  LicenseAssignment.create!(
    account: best_law_firm,
    user: user,
    product: products[:colombia]
  )
end

# Best Law Firm - Costa Rica (5 out of 10 licenses used)
users_best_law.first(5).each do |user|
  LicenseAssignment.create!(
    account: best_law_firm,
    user: user,
    product: products[:costa_rica]
  )
end

# Best Law Firm - España (8 out of 15 licenses used)
users_best_law.first(8).each do |user|
  LicenseAssignment.create!(
    account: best_law_firm,
    user: user,
    product: products[:espana]
  )
end

# Tech Startup - México (3 out of 5 licenses used)
users_tech_startup.first(3).each do |user|
  LicenseAssignment.create!(
    account: tech_startup,
    user: user,
    product: products[:mexico]
  )
end

# Tech Startup - España (2 out of 3 licenses used)
users_tech_startup.first(2).each do |user|
  LicenseAssignment.create!(
    account: tech_startup,
    user: user,
    product: products[:espana]
  )
end

# Corporate Solutions - Colombia (2 out of 3 licenses used)
users_corporate.first(2).each do |user|
  LicenseAssignment.create!(
    account: corporate_solutions,
    user: user,
    product: products[:colombia]
  )
end

# Corporate Solutions - Argentina (1 out of 5 licenses used - just started)
LicenseAssignment.create!(
  account: corporate_solutions,
  user: users_corporate.first,
  product: products[:argentina]
)

# International Law Partners - España (2 out of 2 licenses - fully utilized)
users_international.each do |user|
  LicenseAssignment.create!(
    account: international_law,
    user: user,
    product: products[:espana]
  )
end

puts "✅ Created #{LicenseAssignment.count} license assignments"

# Print summary
puts "\n" + "="*60
puts "🎉 Seed data created successfully!"
puts "="*60

puts "\n📊 Summary:"
puts "-" * 60
puts "Accounts: #{Account.count}"
puts "Products: #{Product.count}"
puts "Users: #{User.count}"
puts "Subscriptions: #{Subscription.count} (#{Subscription.active.count} active, #{Subscription.count - Subscription.active.count} expired)"
puts "License Assignments: #{LicenseAssignment.count}"

puts "\n🏢 Account Details:"
puts "-" * 60

Account.all.each do |account|
  puts "\n#{account.name}:"
  puts "  👥 Users: #{account.users.count}"
  puts "  📋 Subscriptions: #{account.subscriptions.count} (#{account.subscriptions.active.count} active)"
  puts "  🎫 License Assignments: #{account.license_assignments.count}"

  account.subscriptions.active.each do |sub|
    used = sub.used_licenses_count
    total = sub.number_of_licenses
    available = sub.remaining_licenses
    percentage = (used.to_f / total * 100).round(1)

    status_icon = if percentage >= 100
      "🔴"
    elsif percentage >= 80
      "🟡"
    else
      "🟢"
    end

    puts "    #{status_icon} #{sub.product.name}: #{used}/#{total} licenses used (#{available} available) - #{percentage}%"
  end
end

puts "\n" + "="*60
puts "✨ You can now:"
puts "  - Visit http://localhost:3000 to see the app"
puts "  - Login to view accounts and manage licenses"
puts "  - Try assigning licenses to users"
puts "  - Test the license limit validations"
puts "="*60
puts ""
