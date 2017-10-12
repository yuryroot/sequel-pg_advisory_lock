# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel/pg_advisory_lock/version'

Gem::Specification.new do |spec|
  spec.name          = 'sequel-pg_advisory_lock'
  spec.version       = Sequel::PgAdvisoryLock::VERSION
  spec.authors       = ['Yury Shchyhlinski']
  spec.email         = ['Shchyhlinski.YL@gmail.com']

  spec.summary       = "#{spec.name} is an extension for ruby Sequel library that helps using pg_advisory_lock functions of Postgres"
  spec.homepage      = "https://github.com/yuryroot/#{spec.name}"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
