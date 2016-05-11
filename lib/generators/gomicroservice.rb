require "generators/gomicroservice/version"

require 'minke/generators/register'
require 'minke/generators/config'

module Minke
  module Generators
    module GoMicroservice
      # Register the template with minke
      config = Minke::Generators::Config.new
      config.name = 'minke-generator-go'
      config.template_location = File.expand_path(File.dirname(__FILE__)) + '/gomicroservice/scaffold'

      config.build_settings = Minke::Generators::BuildSettings.new
      config.build_settings.build_commands = Minke::Generators::BuildCommands.new.tap do |bc|
        bc.fetch = [['/bin/bash', '-c', 'go get -t -v -d ./... && ls > /dev/null']]
        bc.build = [['/bin/bash', '-c', 'go build -a -installsuffix cgo -ldflags \'-s\' -o application_name']]
        bc.test = [['/bin/bash', '-c', 'go test ./...']]
      end
      config.build_settings.docker_settings = Minke::Generators::DockerSettings.new.tap do |bs|
        bs.image = 'golang:latest'
        bs.env = ['CGO_ENABLED=0']
        bs.binds = ["#{ENV['GOPATH']}/src:/go/src"]
        #bs.working_directory = 'sdsds'#{}"#{self.working_directory}"
      end

      # we need lazy evaluation of this property
      class << config.build_settings.docker_settings
        def working_directory
          dir = File.expand_path('../.')
          gopath = "#{ENV['GOPATH']}"
          "/go" + dir.gsub(gopath,'')
        end
      end

      Minke::Generators.register config
    end
  end
end
