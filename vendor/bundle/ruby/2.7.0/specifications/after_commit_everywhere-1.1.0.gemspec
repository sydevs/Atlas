# -*- encoding: utf-8 -*-
# stub: after_commit_everywhere 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "after_commit_everywhere".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrey Novikov".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-08-05"
  s.description = "Brings before_commit, after_commit, and after_rollback transactional callbacks outside of your ActiveRecord models.".freeze
  s.email = ["envek@envek.name".freeze]
  s.homepage = "https://github.com/Envek/after_commit_everywhere".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Executes code after database commit wherever you want in your application".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.2"])
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_development_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_development_dependency(%q<isolator>.freeze, ["~> 0.7"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.81.0"])
    s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3", ">= 1.3.6"])
  else
    s.add_dependency(%q<activerecord>.freeze, [">= 4.2"])
    s.add_dependency(%q<activesupport>.freeze, [">= 0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 2.0"])
    s.add_dependency(%q<isolator>.freeze, ["~> 0.7"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<rails>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rspec-rails>.freeze, [">= 0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.81.0"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3", ">= 1.3.6"])
  end
end
