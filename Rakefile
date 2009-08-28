%w[hoe rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
gem 'rdoc'
require 'rdoc/rdoc'
require 'hanna/rdoctask'

require File.dirname(__FILE__) + '/lib/codefumes'

$hoe = Hoe.new('codefumes', CodeFumes::VERSION) do |p|
  p.developer('Cosyn Technologies', 'devs@codefumes.com')
  p.summary = "API gem for the CodeFumes website"
  p.changes         = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name  = p.name # TODO this is default value
   p.extra_deps     = [
     ['httparty','>= 0.4.3']
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"],
    ['hanna','>= 0.1.8']
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t}

task :default => [:spec, :features]
