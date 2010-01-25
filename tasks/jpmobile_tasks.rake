# -*- coding: utf-8 -*-
# desc "Explaining what the task does"
# task :jpmobile do
#   # Task goes here
# end

begin
  require 'spec'
  require 'spec/rake/spectask'
  namespace :spec do
    desc 'run unit testing (core test)'
    Spec::Rake::SpecTask.new(:unit) do |t|
      spec_dir = File.join(File.dirname(__FILE__), '..', 'spec')
      test_dir = File.join(File.dirname(__FILE__), '..', 'test')
      t.spec_opts = File.read(File.join(spec_dir, 'spec.opts')).split
      t.spec_files = FileList[File.join(spec_dir, 'unit', '**', '*_spec.rb')]
      t.spec_files += FileList[File.join(test_dir, 'legacy', '**', '*_test.rb')]
      t.libs << '.'
    end
  end
rescue LoadError
  warn "RSpec is not installed. Some tasks were skipped. please install rspec"
end

namespace :test do
  desc "run jpmobile legacy tests"
  Rake::TestTask.new(:legacy) do |t|
    t.libs << '.'
    t.libs << 'lib'
    t.pattern = 'test/legacy/**/*_test.rb'
    t.verbose = true
  end
  desc "Generate rails app and run jpmobile tests in the app"
  task :rails, [:versions] do |t, args|
    is_jruby = RUBY_PLATFORM=="java"
    cmd_rails = "rails"
    cmd_rake  = "rake"
    if is_jruby
      cmd_rails = "jruby -S rails"
      cmd_rake  = "jruby -S rake"
    end

    rails_root     = "test/rails/rails_root"
    relative_root  = "../../../"
    rails_versions = args.versions.split("/") rescue ["2.3.5"]

    puts "Running tests in Rails #{rails_versions.join(', ')}"

    rails_versions.each do |rails_version|
      puts "  for #{rails_version}"
      # generate rails app
      FileUtils.rm_rf(rails_root)
      FileUtils.mkdir_p(rails_root)
      system "#{cmd_rails} _#{rails_version}_ -q --force #{rails_root}"
      if is_jruby
        system "sed -e 's/: sqlite3/: jdbcsqlite3/g' #{rails_root}/config/database.yml > #{rails_root}/config/database.yml.jruby"
        system "mv #{rails_root}/config/database.yml.jruby #{rails_root}/config/database.yml"
        #system "mv #{rails_root}/config/database.yml #{rails_root}/config/database.yml.disable_db"
      end

      # setup jpmobile
      plugin_path = File.join(rails_root, 'vendor', 'plugins', 'jpmobile')
      FileUtils.mkdir_p(plugin_path)
      FileList["*"].exclude("test").each do |file|
        FileUtils.cp_r(file, plugin_path)
      end

      # setup tests
      FileList["test/rails/overrides/*"].each do |file|
        FileUtils.cp_r(file, rails_root)
      end

      # for 2.3.2
      if rails_version == "2.3.2"
        FileList["test/rails/2.3.2/*"].each do |file|
          FileUtils.cp_r(file, rails_root)
        end
      end

      # for cookie_only option
      config_path = File.join(rails_root, 'config', 'environment.rb')
      File.open(config_path, 'a') do |file|
        file.write <<-END

ActionController::Base.session = {:key => "_session_id", :cookie_only => false}
END
      end

      # run tests in rails
      cd rails_root
      sh "#{cmd_rake} db:migrate"
      sh "#{cmd_rake} spec" unless is_jruby # TODO jrubyだと"Task not supported by 'jdbcsqlite3'"となってしまう

      cd relative_root
    end
  end
end
