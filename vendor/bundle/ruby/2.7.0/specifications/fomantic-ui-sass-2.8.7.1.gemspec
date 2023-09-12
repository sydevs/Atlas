# -*- encoding: utf-8 -*-
# stub: fomantic-ui-sass 2.8.7.1 ruby lib

Gem::Specification.new do |s|
  s.name = "fomantic-ui-sass".freeze
  s.version = "2.8.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["doabit".freeze, "shanecav84".freeze]
  s.date = "2021-07-01"
  s.description = "Fomantic UI, converted to Sass and ready to drop into Rails, Compass, or Sprockets.".freeze
  s.email = ["doinsist@gmail.com".freeze, "shane@shanecav.net".freeze]
  s.homepage = "https://github.com/fomantic/Fomantic-UI-SASS".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Fomantic UI, converted to Sass and ready to drop into Rails, Compass, or Sprockets.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<autoprefixer-rails>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rails>.freeze, [">= 3.2.0"])
    s.add_runtime_dependency(%q<sassc>.freeze, [">= 2.2"])
    s.add_runtime_dependency(%q<sassc-rails>.freeze, [">= 2.1"])
    s.add_runtime_dependency(%q<sprockets-rails>.freeze, [">= 2.1.3"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_development_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec-rails>.freeze, [">= 3.0"])
    s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  else
    s.add_dependency(%q<autoprefixer-rails>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 3.2.0"])
    s.add_dependency(%q<sassc>.freeze, [">= 2.2"])
    s.add_dependency(%q<sassc-rails>.freeze, [">= 2.1"])
    s.add_dependency(%q<sprockets-rails>.freeze, [">= 2.1.3"])
    s.add_dependency(%q<bundler>.freeze, [">= 1.3"])
    s.add_dependency(%q<dotenv>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 3.0"])
    s.add_dependency(%q<rubocop>.freeze, [">= 0"])
  end
end
