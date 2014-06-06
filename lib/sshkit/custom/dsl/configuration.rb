module SSHKit
  module Custom
    module DSL
      module Configuration

        def config_store
          @config_store ||= SSHKit::Custom::DSL::ConfigStore
        end

        def on(hosts, options={}, &block)
          hosts = Array(hosts).map { |rh| rh.is_a?(SSHKit::Host) ? rh : SSHKit::Host.new(rh) }.uniq
          config_store.backends = hosts
          config_store.runner_opts = options
          config_store.runner.apply_block_to_bcks(&block) if block_given?
        end

        def within(directory)

          dir_to_check = File.join(config_store.backend.pwd + [directory])

          execute <<-EOTEST, verbosity: Logger::DEBUG
           if test ! -d #{dir_to_check}
              then echo "Directory does not exist '#{dir_to_check}'" 1>&2
              false
           fi
          EOTEST

          config_store.add_pwd directory

          yield if block_given?
        ensure
          config_store.pop_pwd
        end

        def with(environment)
          config_store.add_env environment
          yield if block_given?
        ensure
          config_store.pop_env
        end

        def as(who)
          if who.is_a? Hash
            user = who[:user] || who["user"]
            group = who[:group] || who["group"]
          else
            user = who
            group = nil
          end

          execute <<-EOTEST, verbosity: Logger::DEBUG
            if ! sudo -u #{user} whoami > /dev/null
            then echo "You cannot switch to user '#{user}' using sudo, please check the sudoers file" 1>&2
               false
            fi
          EOTEST

          execute <<-EOTEST, verbosity: Logger::DEBUG if group
            if ! sudo -u #{user} -g #{group} whoami > /dev/null
            then echo "You cannot switch to group '#{group}' using sudo, please check the sudoers file" 1>&2
               false
            fi
          EOTEST

          config_store.add_user_group user, group

          yield if block_given?
        ensure
          config_store.pop_user_group
        end

      end
    end
  end
end