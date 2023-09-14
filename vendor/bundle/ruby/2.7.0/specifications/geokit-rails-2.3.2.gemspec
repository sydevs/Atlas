# -*- encoding: utf-8 -*-
# stub: geokit-rails 2.3.2 ruby lib

Gem::Specification.new do |s|
  s.name = "geokit-rails".freeze
  s.version = "2.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Noack".freeze, "Andre Lewis".freeze, "Bill Eisenhauer".freeze, "Jeremy Lecour".freeze]
  s.date = "2021-01-08"
  s.description = "Official Geokit plugin for Rails/ActiveRecord. Provides location-based goodness for your Rails app. Requires the Geokit gem.".freeze
  s.email = ["michael+geokit@noack.com.au".freeze, "andre@earthcode.com".freeze, "bill_eisenhauer@yahoo.com".freeze, "jeremy.lecour@gmail.com".freeze]
  s.homepage = "http://github.com/geokit/geokit-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Geokit helpers for rails apps.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_runtime_dependency(%q<geokit>.freeze, ["~> 1.5"])
    s.add_development_dependency(%q<bundler>.freeze, ["> 1.0"])
    s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.16.1"])
    s.add_development_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_development_dependency(%q<mocha>.freeze, ["~> 0.9"])
    s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_development_dependency(%q<mysql2>.freeze, ["~> 0.2"])
    s.add_development_dependency(%q<activerecord-mysql2spatial-adapter>.freeze, [">= 0"])
    s.add_development_dependency(%q<pg>.freeze, ["~> 0.10"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 3.0"])
    s.add_dependency(%q<geokit>.freeze, ["~> 1.5"])
    s.add_dependency(%q<bundler>.freeze, ["> 1.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.16.1"])
    s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_dependency(%q<mocha>.freeze, ["~> 0.9"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<mysql2>.freeze, ["~> 0.2"])
    s.add_dependency(%q<activerecord-mysql2spatial-adapter>.freeze, [">= 0"])
    s.add_dependency(%q<pg>.freeze, ["~> 0.10"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 0"])
  end
end
