require 'net/ssh'
require 'net/sftp'

module Cloudfoundry
  module Manager
    class Bootstrap
      attr_accessor :vcap_dir

      def initialize(host, user, password)
        @host = host
        @user = user
        @password = password
        @ssh = Net::SSH.start(@host, @user, password: @password)
      end

      #def deploy(id, location, domain)
      #  cmd = "#{@vcap_dir}/dev_setup/bin/vcap_dev_setup -d #{File.dirname @vcap_dir} -a -D #{domain}"
      #  exec_pty_sudo(cmd, @password)
      #  cloud = {
      #    id: id,
      #    location: location,
      #    domain: domain,
      #    nats: {
      #      host: @host,
      #      user: 'nats',
      #      password: 'nats',
      #      port: NATS::DEFAULT_PORT
      #    }
      #  }
      #  Cloudfoundry::Manager::config['clouds'].push(cloud)
      #  Cloudfoundry::Manager.save_config
      #  @domain = domain
      #end

      def setup(id, domain)
        cmd = "/home/#{@user}/setup-cf.bash #{domain}"
        exec_pty(cmd)
        cloud = {
          id: id,
          location: location,
          domain: domain,
          nats: {
            host: @host,
            user: 'nats',
            password: 'nats',
            port: NATS::DEFAULT_PORT
          }
        }
        Cloudfoundry::Manager::config['clouds'].push(cloud)
        Cloudfoundry::Manager.save_config
      end

      def start
        cmd = "/home/#{@user}/cloudfoundry/vcap/dev_setup/bin/vcap_dev start"
        exec_pty(cmd, @password)
      end

      def stop
        cmd = "/home/#{@user}/cloudfoundry/vcap/dev_setup/bin/vcap_dev stop"
        exec_pty(cmd, @password)
      end

      def restart
        cmd = "/home/#{@user}/cloudfoundry/vcap/dev_setup/bin/vcap_dev restart"
        exec_pty(cmd, @password)
      end

      #def self.log(domain)
      #  begin
      #    f = open("/tmp/cf-bootstrap-#{domain}.log", 'r')
      #    f.read
      #  ensure
      #    f.close
      #  end
      #end

      #def upload_file(local_path, remote_path)
      #  raise Errno::ENOENT unless File.exists? local_path
      #  sftp = Net::SFTP::Session.new(@ssh)
      #  sftp.loop { sftp.opening? }
      #  sftp.upload!(local_path, remote_path) do |event, uploader, *args|
      #    case event
      #    when :open then
      #      # args[0] : file metadata
      #      puts "starting upload: #{args[0].local} -> #{args[0].remote} (#{args[0].size} bytes}"
      #    when :put then
      #      # args[0] : file metadata
      #      # args[1] : byte offset in remote file
      #      # args[2] : data being written (as string)
      #      #puts "writing #{args[2].length} bytes to #{args[0].remote} starting at #{args[1]}"
      #    when :close then
      #      # args[0] : file metadata
      #      puts "finished with #{args[0].remote}"
      #    when :mkdir then
      #      # args[0] : remote path name
      #      #puts "creating directory #{args[0]}"
      #    when :finish then
      #      puts "all done!"
      #    end
      #  end
      #  sftp.close_channel if sftp.open?
      #  @ssh.exec!("tar xf #{remote_path}")
      #end

      private

      def exec_pty_sudo(cmd, password)
        exec_pty(cmd) do |channel|
          open("/tmp/cf-bootstrap-#{@domain}.log", 'a+') do |f|
            channel.on_data do |ch, data|
            if data =~ /^\[sudo\] password for #{@user}:/
              ch.send_data "#{@password}\n"
            end
            puts data
          end
          end
        end
      end

      def exec_pty(cmd, &block)
        @ssh.open_channel do |channel|
          channel.request_pty
          channel.exec(cmd)
          yield channel if block
        end
        @ssh.loop
      end

      def close
        @ssh.loop { @ssh.busy? }
        @ssh.close
      end
    end
  end
end
