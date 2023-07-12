puts('Seeding...')

return unless Rails.env.development?

# Create admin account to access "/admin"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
