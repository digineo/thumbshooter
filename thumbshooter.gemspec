Gem::Specification.new do |s|
  s.name = %q{thumbshooter}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors     = ["Julian Kornberger"]
  s.date        = %q{2009-11-27}
  s.description = %q{Thumbshooter creates thumbshots of websites using webkit and qt4.}
  s.summary     = %q{Generator for thumbshots of websites.}
  s.email       = %q{kontakt@digineo.de}
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = %w(
    init.rb
    Rakefile
    LICENSE
    README.md
    lib/thumbshooter.rb
    lib/webkit2png.rb
    rails/init.rb
  )
  s.has_rdoc         = true
  s.homepage         = %q{http://github.com/digineo/thumbshooter}
  s.rdoc_options     = ["--inline-source", "--charset=UTF-8"]
  s.require_paths    = ["lib"]
  s.requirements     = %s(rmagick libqt4-ruby libqt4-webkit)
  s.rubygems_version = %q{1.3.0}
  
  s.add_dependency(%q<rmagick>, [">= 2"])
  
end
