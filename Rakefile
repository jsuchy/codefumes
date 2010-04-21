%w[hoe rake rake/clean fileutils rubigen hoe].each { |f| require f }

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

Hoe.plugin :website
Hoe.plugin :git

$hoe = Hoe.spec('codefumes') do
  self.summary = "A client-side implementation of the CodeFumes.com API."
  self.extra_dev_deps = [['metric_fu', ">= 1.3.0"],
                         ['rubigen', ">= 1.5.2"],
                         ['fakeweb', ">= 1.2.6"]
                        ]
  self.extra_deps     = [['httparty','>= 0.4.3'], ['caleb-chronic', '>= 0.3.0']]
  developer('Tom Kersten', 'tom.kersten@cosyntech.com')
  developer('Joe Banks', 'freemarmoset@gmail.com')
end

Dir['tasks/**/*.rake'].each { |t| load t}

task :default => [:spec]
