# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'sequel-pg_advisory_lock'
  spec.version       = '0.1.2'
  spec.authors       = ['Yury Shchyhlinski']
  spec.email         = ['Shchyhlinski.YL@gmail.com']

  spec.summary       = 'Extension for ruby Sequel library that allows using PostgreSQL advisory locks for application-level mutexes.'
  spec.homepage      = "https://github.com/yuryroot/#{spec.name}"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sequel'

  if RUBY_PLATFORM =~ /java/
    spec.add_development_dependency 'jdbc-postgres', '9.4.1200'
  elsif RUBY_VERSION < '2.0.0'
    spec.add_development_dependency 'pg', '<0.19.0'
  else
    spec.add_development_dependency 'pg'
  end

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
