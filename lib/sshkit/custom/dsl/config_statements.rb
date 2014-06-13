module SSHKit
  module Custom
    module DSL
      module ConfigStatements
        # Starts the action to be done for named hosts
        #
        # @param hosts [Array<String>] the DNS of the hosts to execute the following blocks
        # @option options [Symbol] :in Chooses the runner to be used
        #
        #   * :parallel => Parallel
        #   * :sequence => Sequential
        #   * :groups => Group
        #
        # @option options [Integer] :wait Amount of seconds to sleep between executions for Sequential and Parallel Runner
        # @option options [Integer] :limit Amount of hosts to use in one Batch for Group Runner
        # For a block {|host| ... }
        # @yield Host for further DSL execution
        # @dsl
        # @see SSHKit::Custom::Config::Store#create_runner
        def on(hosts, options = {}, &block)
          hosts = Array(hosts).map { |rh| Host(rh) }.uniq

          _setup_runner(hosts, options)

          _runner.apply_block_to_bcks(&block) if block_given?
        end

        # Executes all following statements within the named directory.
        # Multiple call's will stack the directories together. After the block
        # is executed the working directory is set back.
        #
        # @param directory [String] The directory within the statements are executed
        # @yield Host for further DSL execution
        # @dsl
        def within(directory)
          _guard_dir!(File.join(_config_store.active_backend.pwd + [directory]))

          _config_store.add_pwd directory

          yield if block_given?
        ensure
          _config_store.pop_pwd
        end

        # Executes all following statements with provided environment variables.
        # Multiple call's will the environment variables. After the block
        # is executed the working environment variables are set back.
        #
        # @param environment [Hash<String, String>] Environment variables to be set
        # @yield Host for further DSL execution
        # @dsl
        def with(environment)
          _config_store.add_env environment
          yield if block_given?
        ensure
          _config_store.pop_env
        end

        # Executes all following statements as the provided user and group (sudo).
        # After the block is executed the user and group is set back.
        #
        # @param who [String, Hash<String, String>] User and group to be set.
        # Possible Hash keys are :user and :group
        # @yield Host for further DSL execution
        # @dsl
        def as(who)
          if who.respond_to? :fetch
            user = who.fetch(:user) { who.fetch('user') }
            group = who.fetch(:group) { who.fetch('group', nil) }
          else
            user = who
            group = nil
          end

          _guard_sudo_user!(user)
          _guard_sudo_group!(user, group)

          _config_store.add_user_group user, group

          yield if block_given?
        ensure
          _config_store.pop_user_group
        end

        # Changes the default options for runner creation.
        #
        # @param opts [Hash<Symbol, String>] Default options for the runner
        # @dsl
        def default_runner_opts(opts)
          _config_store.default_runner_opts(opts)
        end

        # @api private
        def _setup_runner(hosts, options)
          _config_store.backends = hosts
          _config_store.create_runner options
        end

        # @api private
        def _runner
          _config_store.runner
        end
      end
    end
  end
end
