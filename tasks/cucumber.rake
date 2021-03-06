begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w{--tags ~@jruby} unless defined?(JRUBY_VERSION)
  end

  namespace :cucumber do
    Cucumber::Rake::Task.new(:wip) do |t|
      t.cucumber_opts = %w{--tags @wip}
    end
  end
rescue LoadError
  task :cucumber do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end
