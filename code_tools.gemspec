Gem::Specification.new do |s|
  s.name = 'code_tools'
  s.version = '4.2.1'
  s.date = '2015-12-30'
  s.summary = "Source code tools"
  s.description = "Tools for source code maintenance, including version stamping, line endings and tab/space conversion."
  s.authors = ["John Lyon-smith"]
  s.email = "john@jamoki.com"
  s.files = [
    "lib/vamper.rb",
    "lib/ender.rb",
    "lib/spacer.rb",
    "lib/core_ext.rb",
    "lib/vamper/default.version.config",
    "lib/vamper/version_config_file.rb",
    "lib/vamper/version_file.rb"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage = 'http://rubygems.org/gems/code_tools'
  s.license  = 'MIT'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency "tzinfo", ["~> 1.2"]
  s.add_runtime_dependency "nokogiri", ["~> 1.6"]
  s.add_runtime_dependency "colorize", ["~> 0.7.7"]
end
