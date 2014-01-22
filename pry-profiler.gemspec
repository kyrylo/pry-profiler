Gem::Specification.new do |s|
  s.name         = 'pry-profiler'
  s.version      = File.read('VERSION')
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = 'A simple tool for profiling Ruby'
  s.description  = 'Profile Ruby with Pry and stuff'
  s.author       = 'Kyrylo Silin'
  s.email        = 'kyrylosilin@gmail.com'
  s.homepage     = 'https://github.com/kyrylo/pry-profiler'
  s.licenses     = 'zlib'

  s.require_path = 'lib'
  s.files        = `git ls-files`.split("\n")
end
