%w[hoe rubygems rake rake/clean fileutils newgem rubigen metric_fu codefumes_harvester].each { |f| require f }

require File.dirname(__FILE__) + '/lib/codefumes'

begin
  require "hanna/rdoctask"
rescue LoadError
  require 'rake/rdoctask'
end

$hoe = Hoe.new('codefumes', CodeFumes::VERSION) do |p|
  p.developer('Cosyn Technologies', 'devs@codefumes.com')
  p.summary = "API gem for the CodeFumes website"
  p.changes         = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name  = p.name
  p.extra_deps      = [
     ['httparty','>= 0.4.3']
  ]
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"],
    ['metric_fu', ">= 1.1.5"],
    ['codefumes_harvester', ">= 0.0.1"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t}


task :default => [:spec]
