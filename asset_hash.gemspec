# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name = "asset_hash"
  s.summary = "Asset hasher for Cloudfront custom origin domain asset hosting."
  s.description = "This gem allows you to copy your static assets to include a unique hash in their filename. By using this and modifying your Rails asset path you can easily enable your Rails application to serve static content using CloudFront with a custom origin policy."
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Rakefile", "Gemfile", "README.textile"]
  s.version = "0.2.3"
  s.author = "Donald Piret"
  s.email = "donald@donaldpiret.com"
  s.homepage = "http://donaldpiret.com"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 1.16"])
    else
      s.add_dependency(%q<mime-types>, [">= 1.16"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 1.16"])
  end
end