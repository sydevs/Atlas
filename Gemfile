source 'https://rubygems.org'
ruby '2.7.2'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

### Core gems
gem 'active_decorator' # Separate view code while keeping it attached to the model
gem 'jbuilder' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'pg' # Use postgres as the database for Active Record
gem 'puma' # Use Puma as the app server
gem 'rails' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'sassc' # Use SASS for stylesheets
gem 'sassc-rails' # Use SASS for stylesheets
gem 'slim-rails' # Use Slim for views
gem 'terser' # Use Uglifier as compressor for JavaScript assets
gem 'sprockets', '3.7.2'
gem 'sidekiq' # For async jobs, including emails

### Security Fix
gem 'loofah', '>= 2.3.1'

### Javascript
gem 'autoprefixer-rails' # For automatic cross browser CSS compatibility
gem 'fomantic-ui-sass' # Integrate Semantic UI for general styling
gem 'jquery-rails' # Add jQuery
gem 'leaflet-rails' # Integrate Leaflet for maps
gem 'normalize-rails' # To normalize CSS

### Administration
gem 'simple_form' # To simplify admin forms
gem 'audited' # Logs changes to any record
gem 'kaminari' # Pagination
gem 'nilify_blanks' # Convert empty string to null in the database
gem 'passwordless' # For email based user authentication
gem 'phonelib' # For telephone validation
gem 'pundit' # Permissions
gem 'aasm' # State machine for managing expiration status
gem 'active_flag' # Bitwise flag for storing notification settings
gem 'after_commit_everywhere', '~> 1.0' # Dependency for aasm

### Communication
gem 'premailer-rails' # Generate inline styles for emails
gem 'messagebird-rest', require: 'messagebird' # Send 

### Geocoding
gem 'geokit-rails'
gem 'timezone'

### File uploads
gem 'carrierwave' # Serverside image uploader
gem 'carrierwave-google-storage' # Let's us store the files in Google Storage
gem 'google-api-client' # An unspecified dependency for carrierwave-google-storage
gem 'mini_magick' # Image processing during upload

### Internationalization
gem 'countries' # Adds localized lists of countries and subdivisions
gem 'i18n_data' # Adds localized lists of countries and languages

### API
gem 'rack-cors'
gem 'rack-attack'
gem 'graphql'
gem 'graphql-cache'
gem 'graphiql-rails'

### Utility
gem 'inline_svg' # Allows SVGs to be rendered inline
gem 'rails_12factor', group: :production # For heroku support
gem 'klaviyo' # For integration with Klaviyo
gem 'httparty' # For http requests (specifically for Klaviyo)
gem 'validate_url' # Validate url fields
gem 'aws-sdk-s3' # For uploading to Mapbox
# gem 'webpacker' # Needed to build properly

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'capybara', '~> 2.13' # Adds support for Capybara system testing and selenium driver
  gem 'faker' # To generate fake data
  gem 'letter_opener' # Let's us capture test emails to verify that they were sent, and what markup was actually sent.
  gem 'selenium-webdriver'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0' # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'dotenv-rails' # Automatically load environmental variables
  gem 'derailed' # To test memory usage for all the gems
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
