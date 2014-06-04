module SSHKit
  module Custom
    module DSL
      module ConfigStore

        module_function
        
        def runner_opts=(opts)
          @runner = nil
          @runner_opts = { in: :parallel }.merge(opts)
        end        

        def runner
          @runner ||= case @runner_opts[:in]
                        when :parallel then SSHKit::Runner::Parallel
                        when :sequence then SSHKit::Runner::Sequential
                        when :groups then SSHKit::Runner::Group
                        else
                          raise RuntimeError, "Don't know how to handle run style #{@runner_opts[:in].inspect}"
                      end.new(nil, @runner_opts)

          @runner.tap{|r| r.backends = backends}
        end

        def backends=(hosts)
          @backends = hosts.map { |host| SSHKit.config.backend.new(host) }
        end

        def backends
          @backends ||= []
        end

        def add_pwd(directory)
          backend.pwd ||= [];  backend.pwd << directory
        end

        def pop_pwd
          backend.pwd ||= [];  backend.pwd.pop
        end

        def _envs
          Thread.current[:_envs] ||= []
        end

        def add_env(env)
          old_env =  backends.first.env.clone
          _envs << old_env
          env = old_env.merge(env)
          backend.env = env
        end

        def pop_env
          old_env = _envs.pop || {}
          backends.each {|backend| backend.env = old_env}
        end

        def _user_groups
          Thread.current[:_user_groups] ||= []
        end

        def add_user_group(user, group)
          _user_groups << {user: backend.user, group:  backend.group }
          backend.user = user; backend.group = group
        end

        def pop_user_group
          old_user_group = _user_groups.pop || {}
          backend.user = old_user_group[:user]; backend.group = old_user_group[:group]
        end

        def backend
          SSHKit::Runner::Abstract.active_backend
        end
      end
    end
  end
end