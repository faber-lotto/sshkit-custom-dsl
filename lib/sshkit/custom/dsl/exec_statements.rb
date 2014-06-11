module SSHKit
  module Custom
    module DSL
      module ExecStatements
        EXEC_STATEMENTS = [:execute, :make, :rake, :test, :capture, :upload!, :download!].freeze

        # @api private
        # @!macro [attach] dsl.create_delegator
        #   @!method $1(*args, &block)
        #   @api public
        #   @ dsl
        #   Delegates $1 to the runner
        def self.create_delegator(method)
          define_method method do |*args, &block|
            _config_store.runner.send_cmd method, *args, &block
          end
        end

        create_delegator :execute
        create_delegator :make
        create_delegator :rake
        create_delegator :test
        create_delegator :capture
        create_delegator :upload!
        create_delegator :download!

        # @api private
        def _guard_sudo_user!(user)
          execute <<-EOTEST, verbosity: Logger::DEBUG
            if ! sudo -u #{user} whoami > /dev/null
            then echo "You cannot switch to user '#{user}' using sudo, please check the sudoers file" 1>&2
               false
            fi
          EOTEST
        end

        # @api private
        def _guard_sudo_group!(user, group)
          execute <<-EOTEST, verbosity: Logger::DEBUG if group
            if ! sudo -u #{user} -g #{group} whoami > /dev/null
            then echo "You cannot switch to group '#{group}' using sudo, please check the sudoers file" 1>&2
               false
            fi
          EOTEST
        end

        # @api private
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
