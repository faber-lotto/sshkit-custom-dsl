module SSHKit
  module Custom
    module Config
      module Store
        module_function

        # @api private
        def scope_storage
          ScopedStorage::ThreadLocalStorage
        end

        # @api private
        def config_scope
          @config_scope ||= ScopedStorage::Scope.new('sshkit_dsl_config', scope_storage)
        end

        # @api private
        def global_config_scope
          @global_config_scope ||= ScopedStorage::Scope.new('sshkit_dsl_global_config', ScopedStorage::ThreadLocalStorage)
        end

        # Creates a new runner
        # @option opts [Symbol] :in Chooses the runner to be used
        #   :parallel => Parallel
        #   :sequence => Sequential
        #   :groups => Group
        # @option opts [Integer] :wait Amount of seconds to sleep between executions for Sequential and Parallel Runner
        # @option opts [Integer] :limit Amount of hosts to use in one Batch for Group Runner
        #
        def create_runner(opts)
          @runner = Runner::Abstract.create_runner((global_config_scope[:_default_runner_opts] || {}).merge(opts))
        end

        # The actual runner object
        def runner
          @runner.tap { |r| r.backends = backends }
        end

        # Sets the actual backends
        def backends=(hosts)
          @backends = hosts.map { |host| SSHKit.config.backend.new(host) }
        end

        # Get the actual backends
        def backends
          @backends ||= []
        end

        # Set the working directory for the current backend.
        # @param directory [String] The new working directory
        def add_pwd(directory)
          active_backend.pwd ||= []
          active_backend.pwd << directory
        end

        # Set the working directory to the previous working directory for the current backend.
        def pop_pwd
          active_backend.pwd ||= []
          active_backend.pwd.pop
        end

        # @api private
        def _envs
          config_scope[:_envs] ||= []
        end

        # Set the environment for the current backend.
        # @param env [Hash<String, String>] The new ENV-Vars to be used.
        def add_env(env)
          old_env =  active_backend.env.clone
          _envs << old_env
          env = old_env.merge(env)
          active_backend.env = env
        end

        # Resets the environment variables to the previous one.
        def pop_env
          old_env = _envs.pop || {}
          active_backend.env = old_env
        end

        # @api private
        def _user_groups
          config_scope[:_user_groups] ||= []
        end

        # Set the user and group for the current backend.
        # @param user [String] The new username
        # @param group [String, nil] The new group
        def add_user_group(user, group)
          _user_groups << { user: active_backend.user, group:  active_backend.group }
          active_backend.user = user
          active_backend.group = group
        end

        # Resets user and group to the previous one.
        def pop_user_group
          old_user_group = _user_groups.pop || {}
          active_backend.user = old_user_group[:user]
          active_backend.group = old_user_group[:group]
        end

        # Returns the active backend in the current thread
        def active_backend
          SSHKit::Custom::Runner::Abstract.active_backend
        end

        def default_runner_opts(opts)
          global_config_scope[:_default_runner_opts] = opts
        end
      end
    end
  end
end
