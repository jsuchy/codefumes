%w[hoe rake rake/clean fileutils rubigen hoe].each { |f| require f }

require File.dirname(__FILE__) + '/lib/codefumes'

begin
  require "hanna/rdoctask"
rescue LoadError
  require 'rake/rdoctask'
end

# Load in the harvester ane metric_fu gems if available so we can collect metrics
begin
  require "metric_fu"
  require "codefumes_harvester"
rescue LoadError
end

$hoe = Hoe.spec('codefumes') do |p|
  p.developer('Cosyn Technologies', 'devs@codefumes.com')
  p.summary = "API gem for the CodeFumes website"
  p.extra_deps      = [
     ['httparty','>= 0.4.3']
  ]
  p.extra_dev_deps = [
    ['jscruggs-metric_fu', ">= 1.1.5"],
  ]
end

Dir['tasks/**/*.rake'].each { |t| load t}

task :default => [:spec]
