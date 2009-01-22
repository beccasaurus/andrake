desc 'Run the specs'
task :default => :spec

desc 'Run the specs'
task :spec do
  root  = File.dirname __FILE__
  specs = Dir[ File.join(root, 'spec', '**', '*_spec.rb') ]
  exec "spec -O spec/spec.opts #{specs.join(' ')}"
end
