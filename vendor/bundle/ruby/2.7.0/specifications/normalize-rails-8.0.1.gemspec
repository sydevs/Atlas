# -*- encoding: utf-8 -*-
# stub: normalize-rails 8.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "normalize-rails".freeze
  s.version = "8.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nicolas Gallagher".freeze, "Jonathan Neal".freeze, "Mark McConachie".freeze]
  s.date = "2020-08-16"
  s.description = "Normalize.css is an alternative to CSS resets".freeze
  s.email = ["mark@markmcconachie.com".freeze]
  s.homepage = "https://github.com/markmcconachie/normalize-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Normalize.css is a customisable CSS file that makes browsers render all elements more consistently and in line with modern standards. We researched the differences between default browser styles in order to precisely target only the styles that need normalizing.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rake>.freeze, [">= 0"])
  end
end
