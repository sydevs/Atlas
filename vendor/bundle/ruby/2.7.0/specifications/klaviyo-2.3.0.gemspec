# -*- encoding: utf-8 -*-
# stub: klaviyo 2.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "klaviyo".freeze
  s.version = "2.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Klaviyo Team".freeze]
  s.date = "2021-10-28"
  s.description = "Ruby wrapper for the Klaviyo API".freeze
  s.email = "libraries@klaviyo.com".freeze
  s.homepage = "https://www.klaviyo.com/".freeze
  s.rubygems_version = "3.1.6".freeze
  s.summary = "You heard us, a Ruby wrapper for the Klaviyo API".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<rack>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<escape>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<faraday>.freeze, [">= 0"])
  else
    s.add_dependency(%q<json>.freeze, [">= 0"])
    s.add_dependency(%q<rack>.freeze, [">= 0"])
    s.add_dependency(%q<escape>.freeze, [">= 0"])
    s.add_dependency(%q<faraday>.freeze, [">= 0"])
  end
end
