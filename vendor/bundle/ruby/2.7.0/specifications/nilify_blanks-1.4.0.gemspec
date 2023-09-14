# -*- encoding: utf-8 -*-
# stub: nilify_blanks 1.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "nilify_blanks".freeze
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.4".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ben Hughes".freeze]
  s.date = "2020-04-19"
  s.description = "Often times you'll end up with empty strings where you really want nil at the database level.  This plugin automatically converts blanks to nil and is configurable.".freeze
  s.email = "ben@railsgarden.com".freeze
  s.homepage = "http://github.com/rubiety/nilify_blanks".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Auto-convert blank fields to nil.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 4.0.0"])
    s.add_runtime_dependency(%q<activerecord>.freeze, [">= 4.0.0"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0.1"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 3.8.0"])
    s.add_development_dependency(%q<appraisal>.freeze, [">= 1.0.2"])
    s.add_development_dependency(%q<sqlite3>.freeze, [">= 1.3.6"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 4.0.0"])
    s.add_dependency(%q<activerecord>.freeze, [">= 4.0.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0.1"])
    s.add_dependency(%q<rspec>.freeze, [">= 3.8.0"])
    s.add_dependency(%q<appraisal>.freeze, [">= 1.0.2"])
    s.add_dependency(%q<sqlite3>.freeze, [">= 1.3.6"])
  end
end
