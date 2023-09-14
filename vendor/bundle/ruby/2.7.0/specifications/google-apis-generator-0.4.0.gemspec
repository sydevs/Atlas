# -*- encoding: utf-8 -*-
# stub: google-apis-generator 0.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "google-apis-generator".freeze
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/googleapis/google-api-ruby-client/issues", "changelog_uri" => "https://github.com/googleapis/google-api-ruby-client/tree/master/google-apis-generator/CHANGELOG.md", "documentation_uri" => "https://googleapis.dev/ruby/google-apis-generator/v0.4.0", "source_code_uri" => "https://github.com/googleapis/google-api-ruby-client/tree/master/google-apis-generator" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Google LLC".freeze]
  s.date = "2021-06-29"
  s.email = "googleapis-packages@google.com".freeze
  s.executables = ["generate-api".freeze]
  s.files = ["bin/generate-api".freeze]
  s.homepage = "https://github.com/google/google-api-ruby-client".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "Code generator for legacy Google REST clients".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0"])
    s.add_runtime_dependency(%q<gems>.freeze, ["~> 1.2"])
    s.add_runtime_dependency(%q<google-apis-core>.freeze, [">= 0.4", "< 2.a"])
    s.add_runtime_dependency(%q<google-apis-discovery_v1>.freeze, ["~> 0.5"])
    s.add_runtime_dependency(%q<thor>.freeze, [">= 0.20", "< 2.a"])
  else
    s.add_dependency(%q<activesupport>.freeze, [">= 5.0"])
    s.add_dependency(%q<gems>.freeze, ["~> 1.2"])
    s.add_dependency(%q<google-apis-core>.freeze, [">= 0.4", "< 2.a"])
    s.add_dependency(%q<google-apis-discovery_v1>.freeze, ["~> 0.5"])
    s.add_dependency(%q<thor>.freeze, [">= 0.20", "< 2.a"])
  end
end
