$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "zaikio/oauth_client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "zaikio-oauth_client"
  spec.version     = Zaikio::OAuthClient::VERSION
  spec.authors     = ["Steffen Boller", "Christian Weyer", "Matthias Prinz"]
  spec.email       = ["sb@crispymtn.com", "cw@crispymtn.com", "mp@crispymtn.com"]
  spec.homepage    = "https://crispymtn.com"
  spec.summary     = "Zaikio Platform Connectivity"
  spec.description = "This gem provides a mountable Rails engine that provides single sign on, directory access and further Zaikio platform connectivity."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/"
    spec.metadata["github_repo"] = "ssh://github.com/crispymtn/zaikio-oauth_client"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.0"
  spec.add_dependency "oauth2"
  spec.add_dependency "zaikio-jwt_auth", "~> 0.2.1"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "byebug"
end
