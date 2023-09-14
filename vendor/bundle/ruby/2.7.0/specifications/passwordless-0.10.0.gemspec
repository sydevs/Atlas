# -*- encoding: utf-8 -*-
# stub: passwordless 0.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "passwordless".freeze
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mikkel Malmberg".freeze]
  s.date = "2020-10-07"
  s.email = ["mikkel@brnbw.com".freeze]
  s.homepage = "https://github.com/mikker/passwordless".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Add authentication to your app without all the ickyness of passwords.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 5.1.4"])
    s.add_runtime_dependency(%q<bcrypt>.freeze, ["~> 3.1.11"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.4.1"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0"])
    s.add_development_dependency(%q<standard>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 5.1.4"])
    s.add_dependency(%q<bcrypt>.freeze, ["~> 3.1.11"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.4.1"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<standard>.freeze, [">= 0"])
  end
end
