module SSHKit
  module Custom
    module Config
      module Store

        module_function

        def scope_storage
          ScopedStorage::ThreadLocalStorage
        end

        def config_scope
          @config_scope ||= ScopedStorage::Scope.new('sshkit_dsl_config', scope_storage)
        end

        def create_runner(opts)
          @runner = Runner::Abstract.create_runner opts
        end        

        def runner
          @runner.tap{|r| r.backends = backends}
        end

        def backends=(hosts)
          @backends = hosts.map { |host| SSHKit.config.backend.new(host) }
        end

        def backends
          @backends ||= []
        end

        def add_pwd(directory)
          active_backend.pwd ||= [];  active_backend.pwd << directory
        end

        def pop_pwd
          active_backend.pwd ||= [];  active_backend.pwd.pop
        end

        def _envs
          config_scope[:_envs] ||= []
        end

        def add_env(env)
          old_env =  backends.first.env.clone
          _envs << old_env
          env = old_env.merge(env)
          active_backend.env = env
        end

        def pop_env
          old_env = _envs.pop || {}
          backends.each {|backend| backend.env = old_env}
        end

        def _user_groups
          config_scope[:_user_groups] ||= []
        end

        def add_user_group(user, group)
          _user_groups << {user: active_backend.user, group:  active_backend.group }
          active_backend.user = user
          active_backend.group = group
        end

        def pop_user_group
          old_user_group = _user_groups.pop || {}
          active_backend.user = old_user_group[:user]
          active_backend.group = old_user_group[:group]
        end

        def active_backend
          SSHKit::Custom::Config::Runner::Abstract.active_backend
        end
      end
    end
  end
end