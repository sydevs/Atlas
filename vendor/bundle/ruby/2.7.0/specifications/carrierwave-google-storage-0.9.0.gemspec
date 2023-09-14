# -*- encoding: utf-8 -*-
# stub: carrierwave-google-storage 0.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "carrierwave-google-storage".freeze
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jasdeep Singh".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-09-19"
  s.description = "A slimmer alternative to using Fog for Google Cloud Storage support in CarrierWave. Heavily inspired from carrierwave-aws".freeze
  s.email = ["narang.jasdeep@gmail.com".freeze]
  s.homepage = "https://github.com/metaware/carrierwave-google-storage".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Use gcloud for Google Cloud Storage support in CarrierWave.".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<carrierwave>.freeze, ["~> 1.2.0"])
    s.add_runtime_dependency(%q<google-cloud-storage>.freeze, ["~> 1.10"])
    s.add_runtime_dependency(%q<activemodel>.freeze, [">= 3.2.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.12"])
    s.add_development_dependency(%q<pry>.freeze, ["~> 0.10.3"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<uri-query_params>.freeze, ["~> 0.7.1"])
  else
    s.add_dependency(%q<carrierwave>.freeze, ["~> 1.2.0"])
    s.add_dependency(%q<google-cloud-storage>.freeze, ["~> 1.10"])
    s.add_dependency(%q<activemodel>.freeze, [">= 3.2.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.12"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.10.3"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<uri-query_params>.freeze, ["~> 0.7.1"])
  end
end
