# -*- encoding: utf-8 -*-
# stub: timezone 1.3.15 ruby lib

Gem::Specification.new do |s|
  s.name = "timezone".freeze
  s.version = "1.3.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Pan Thomakos".freeze]
  s.date = "2021-10-23"
  s.description = "Accurate current and historical timezones for Ruby with support for Geonames and Google latitude - longitude lookups.".freeze
  s.email = ["pan.thomakos@gmail.com".freeze]
  s.extra_rdoc_files = ["README.markdown".freeze, "License.txt".freeze]
  s.files = ["License.txt".freeze, "README.markdown".freeze]
  s.homepage = "https://github.com/panthomakos/timezone".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "timezone-1.3.15".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 12"])
    s.add_development_dependency(%q<rubocop>.freeze, ["= 0.51"])
    s.add_development_dependency(%q<timecop>.freeze, ["~> 0.8"])
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.8"])
    s.add_dependency(%q<rake>.freeze, ["~> 12"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.51"])
    s.add_dependency(%q<timecop>.freeze, ["~> 0.8"])
  end
end
