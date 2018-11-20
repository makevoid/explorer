coffeescript_options = {
  input: 'assets/coffee',
  output: 'assets/js',
  patterns: [%r{^assets/coffee/(.+\.(?:coffee))$}]
}

guard 'coffeescript', coffeescript_options do
  coffeescript_options[:patterns].each { |pattern| watch(pattern) }
end
