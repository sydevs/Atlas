source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

### Core gems
gem 'rails', '~> 5.1.6' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'pg', '~> 0.18' # Use sqlite3 as the database for Active Record
gem 'puma', '~> 3.7' # Use Puma as the app server
gem 'sassc-rails' # Use SASS for stylesheets
gem 'slim-rails' # Use Slim for views
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder

### Javascript
gem 'jquery-rails' # Add jQuery
gem 'normalize-rails' # To normalize CSS
gem 'autoprefixer-rails' # For automatic cross browser CSS compatibility
gem 'fomantic-ui-sass' # Integrate Semantic UI for general styling
gem 'leaflet-rails' # Integrate Leaflet for maps

### Administration
gem 'simple_form' # To simplify admin forms
gem 'recurrence' # For recurring events
# gem 'autosize' # To automatically grow text areas
gem 'nilify_blanks' # Convert empty string to null in the database
gem 'kaminari' # Pagination
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
gem 'i18n_data' # Adds localized lists of countries and languages
gem 'countries' # Adds localized lists of countries and subdivisions

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'capybara', '~> 2.13' # Adds support for Capybara system testing and selenium driver
  gem 'selenium-webdriver'
  gem 'faker' # To generate fake data
  gem 'letter_opener' # Let's us capture test emails to verify that they were sent, and what markup was actually sent.
end

group :development do
  gem 'web-console', '>= 3.3.0' # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'switch_user'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
