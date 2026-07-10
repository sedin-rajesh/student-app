source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"

# The modern asset pipeline for Rails
gem "propshaft"

# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"

# Use the Puma web server
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps
gem "importmap-rails"

# Hotwire's SPA-like page accelerator
gem "turbo-rails"

# Hotwire's modest JavaScript framework
gem "stimulus-rails"

# Build JSON APIs with ease
gem "jbuilder"

# Use Active Model has_secure_password
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma
gem "thruster", require: false

# Use Active Storage variants
gem "image_processing", "~> 1.2"

gem "devise"

gem "devise-jwt"

gem "prawn"

gem "sidekiq"

group :development, :test do
  # Debugging
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Security audit for gems
  gem "bundler-audit", require: false

  # Security scanner for Rails applications
  gem "brakeman", require: false

  # Rails style guide and RuboCop configuration
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exception pages
  gem "web-console"

  # Detect N+1 queries and unused eager loading
  gem "bullet"

  gem "letter_opener"

  gem "letter_opener_web", "~> 3.0"
end

group :test do
  # System testing
  gem "capybara"
  gem "selenium-webdriver"
end
