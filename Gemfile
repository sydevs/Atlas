source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

### Core gems
gem 'active_decorator' # Separate view code while keeping it attached to the model
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'pg', '~> 0.18' # Use sqlite3 as the database for Active Record
gem 'puma', '~> 3.7' # Use Puma as the app server
gem 'rails', '~> 5.1.6' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'sassc-rails' # Use SASS for stylesheets
gem 'slim-rails' # Use Slim for views
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets

### Javascript
gem 'autoprefixer-rails' # For automatic cross browser CSS compatibility
gem 'fomantic-ui-sass' # Integrate Semantic UI for general styling
gem 'jquery-rails' # Add jQuery
gem 'leaflet-rails' # Integrate Leaflet for maps
gem 'normalize-rails' # To normalize CSS

### Administration
gem 'recurrence' # For recurring events
gem 'simple_form' # To simplify admin forms
# gem 'autosize' # To automatically grow text areas
gem 'audited' # Logs changes to any record
gem 'kaminari' # Pagination
gem 'nilify_blanks' # Convert empty string to null in the database
gem 'passwordless' # For email based user authentication
gem 'premailer-rails' # Generate inline styles for emails
gem 'pundit' # Permissions

### Geocoding
gem 'geokit-rails'

# File uploads
gem 'carrierwave' # Serverside image uploader
gem 'carrierwave-google-storage' # Serverside image uploader
gem 'mini_magick' # Image processing during upload

### Internationalization
gem 'countries' # Adds localized lists of countries and subdivisions
gem 'i18n_data' # Adds localized lists of countries and languages

### API
gem 'rack-cors'
gem 'rack-attack'

### Utility
gem 'inline_svg' # Allows SVGs to be rendered inline

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
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
