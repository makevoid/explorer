desc "Run the app"
task :run do
  sh "bundle exec rackup -p 3000"
end

task default: :run

desc "Run the app (rerun)"
task :run_dev do
  sh "rerun -s KILL -p \"**/*.{rb}\" -- bundle exec rackup -p 3000"
end


# ----
# rancher deployment

require_relative 'config/env'
require_relative 'config/rancher_auth_lib'
include RancherAuthLib

RNCH_PROJECT = "1a5"
RNCH_SERVICE = "1s89"

desc 'Deploy task, build container, push to dockerhub, trigger rancher upgrade'
task :deploy do
  Rake::Task["rancher_finish"].invoke
  Rake::Task["docker_push"].invoke
  Rake::Task["rancher_upgrade"].invoke
end

desc "Docker build and push to docker hub"
task :docker_push do
  sh "docker build . -t makevoid/explorer && docker push makevoid/explorer:latest"
end

desc "rancher_launchconf"
task :rancher_launchconf do
  conf = get "http://ranch.mkv.run:8080/v2-beta/projects/#{RNCH_PROJECT}/services/#{RNCH_SERVICE}"
  puts Oj.dump conf.fetch("upgrade").fetch("inServiceStrategy")
end

desc "rancher_upgrade"
task :rancher_upgrade do
  conf = get "http://ranch.mkv.run:8080/v2-beta/projects/#{RNCH_PROJECT}/services/#{RNCH_SERVICE}"
  strategy = conf.fetch("upgrade").fetch("inServiceStrategy")
  params = {
    "inServiceStrategy" => strategy
  }
  post "http://ranch.mkv.run:8080/v2-beta/projects/#{RNCH_PROJECT}/services/#{RNCH_SERVICE}/?action=upgrade", params
  puts "Rancher upgrade started"
end

desc "rancher_finish"
task :rancher_finish do
  post "http://ranch.mkv.run:8080/v2-beta/projects/#{RNCH_PROJECT}/services/#{RNCH_SERVICE}/?action=finishupgrade", {}
end
