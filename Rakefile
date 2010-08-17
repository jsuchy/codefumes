require 'bundler'
Bundler.setup

%w[hoe rake rake/clean fileutils].each { |f| require f }

$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')
require 'lib/codefumes'

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

Hoe.plugin :git

$hoe = Hoe.spec('codefumes') do
  self.summary = "A client-side implementation of the CodeFumes.com API."
  self.extra_dev_deps = [['metric_fu', "1.3.0"],
                         ['rubigen', "1.5.5"],
                         ['fakeweb', "1.2.8"],
                         ['activesupport', "2.3.5"],
                         ['rspec', ">= 1.2.6"],
                         ['cucumber', "0.8.5"],
                         ['aruba', "0.2.1"]
                        ]
  self.extra_deps     = [['httparty','>= 0.6.1'], ['caleb-chronic', '>= 0.3.0'], ['gli', '1.1.1']]
  developer('Tom Kersten', 'tom.kersten@cosyntech.com')
  developer('Joe Banks', 'freemarmoset@gmail.com')
end

Dir['tasks/**/*.rake'].each { |t| load t}

task :default => [:spec]
