require 'yaml'

filename = 'test.txt'

File.open(filename, 'r+') do |file|
  file.flock(File::LOCK_EX)

  content = YAML.load(file.read)
  puts content
  sleep(10)
  file.rewind
  cookies = {'a'=>rand(100), 'b'=>rand(100)}
  file.write(cookies.to_yaml)

  file.truncate(file.pos)
end