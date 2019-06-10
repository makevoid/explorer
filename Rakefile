desc "Run the app"
task :run do
  sh "bundle exec rackup -p 3000"
end

task default: :run

desc "Run the app (rerun)"
task :run_dev do
  sh "rerun -s KILL -p \"**/*.{rb}\" -- bundle exec rackup -p 3000"
end

desc "Docker build and push to docker hub"
task :docker_push do
  sh "docker build . -t makevoid/explorer && docker push makevoid/explorer:latest"
end
