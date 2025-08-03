# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create a test user if it doesn't exist
user = User.find_or_create_by!(email: 'test@example.com') do |user|
  user.password = 'password123'
  user.name = 'Tester'
end

# Create a test post
post = Post.create!(
  user_id: user.id,
  state: 'awaiting_confirmation'
)

puts "Created test post with ID: #{post.id}"
