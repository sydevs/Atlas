# -*- encoding: utf-8 -*-
# stub: sib-api-v3-sdk 9.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sib-api-v3-sdk".freeze
  s.version = "9.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["SendinBlue Developers".freeze]
  s.date = "2022-08-18"
  s.description = "Official SendinBlue provided RESTFul API V3 ruby library".freeze
  s.email = ["contact@sendinblue.com".freeze]
  s.homepage = "https://www.sendinblue.com/".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "SendinBlue API V3 Ruby Gem".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<typhoeus>.freeze, ["~> 1.0", ">= 1.0.1"])
    s.add_runtime_dependency(%q<json>.freeze, ["~> 2.1", ">= 2.1.0"])
    s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.3", ">= 2.3.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.6", ">= 3.6.0"])
    s.add_development_dependency(%q<vcr>.freeze, ["~> 3.0", ">= 3.0.1"])
    s.add_development_dependency(%q<webmock>.freeze, ["~> 1.24", ">= 1.24.3"])
    s.add_development_dependency(%q<autotest>.freeze, ["~> 4.4", ">= 4.4.6"])
    s.add_development_dependency(%q<autotest-rails-pure>.freeze, ["~> 4.1", ">= 4.1.2"])
    s.add_development_dependency(%q<autotest-growl>.freeze, ["~> 0.2", ">= 0.2.16"])
    s.add_development_dependency(%q<autotest-fsevent>.freeze, ["~> 0.2", ">= 0.2.12"])
  else
    s.add_dependency(%q<typhoeus>.freeze, ["~> 1.0", ">= 1.0.1"])
    s.add_dependency(%q<json>.freeze, ["~> 2.1", ">= 2.1.0"])
    s.add_dependency(%q<addressable>.freeze, ["~> 2.3", ">= 2.3.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.6", ">= 3.6.0"])
    s.add_dependency(%q<vcr>.freeze, ["~> 3.0", ">= 3.0.1"])
    s.add_dependency(%q<webmock>.freeze, ["~> 1.24", ">= 1.24.3"])
    s.add_dependency(%q<autotest>.freeze, ["~> 4.4", ">= 4.4.6"])
    s.add_dependency(%q<autotest-rails-pure>.freeze, ["~> 4.1", ">= 4.1.2"])
    s.add_dependency(%q<autotest-growl>.freeze, ["~> 0.2", ">= 0.2.16"])
    s.add_dependency(%q<autotest-fsevent>.freeze, ["~> 0.2", ">= 0.2.12"])
  end
end
