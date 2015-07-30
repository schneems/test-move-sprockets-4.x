namespace :assets do
  namespace :precompile do
    desc "precompile with stackprof profiling"
    task :profile do
      StackProf.run(mode: :wall, out: 'stackprof.dump') do
        Rake::Task["assets:precompile"].invoke
      end

      system 'stackprof stackprof.dump'
    end
  end
end
