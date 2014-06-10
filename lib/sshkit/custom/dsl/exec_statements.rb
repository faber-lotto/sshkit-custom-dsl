module SSHKit
  module Custom
    module DSL
      module ExecStatements
        EXEC_STATEMENTS = [:execute, :make, :rake, :test, :capture, :upload!, :download!].freeze

        EXEC_STATEMENTS.each do |method|
          define_method method do |*args, &block|
            _config_store.runner.send_cmd method, *args, &block
          end
        end

        def _guard_sudo_user!(user)
          execute <<-EOTEST, verbosity: Logger::DEBUG
            if ! sudo -u #{user} whoami > /dev/null
            then echo "You cannot switch to user '#{user}' using sudo, please check the sudoers file" 1>&2
               false
            fi
          EOTEST
        end

        def _guard_sudo_group!(user, group)
          execute <<-EOTEST, verbosity: Logger::DEBUG if group
            if ! sudo -u #{user} -g #{group} whoami > /dev/null
            then echo "You cannot switch to group '#{group}' using sudo, please check the sudoers file" 1>&2
               false
            fi
          EOTEST
        end

        def _guard_dir!(dir_to_check)
          execute <<-EOTEST, verbosity: Logger::DEBUG
           if test ! -d #{dir_to_check}
              then echo "Directory does not exist '#{dir_to_check}'" 1>&2
              false
           fi
          EOTEST
        end
      end
    end
  end
end
