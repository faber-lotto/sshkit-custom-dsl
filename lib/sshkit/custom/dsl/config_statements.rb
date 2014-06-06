module SSHKit
  module Custom
    module DSL
      module ConfigStatements

        def on(hosts, options={}, &block)
          hosts = Array(hosts).map { |rh| Host(rh) }.uniq

          _config_store.backends = hosts
          _config_store.create_runner options

          _config_store.runner.apply_block_to_bcks(&block) if block_given?
        end

        def within(directory)
          _guard_dir!(File.join(_config_store.active_backend.pwd + [directory]))

          _config_store.add_pwd directory

          yield if block_given?
        ensure
          _config_store.pop_pwd
        end

        def with(environment)
          _config_store.add_env environment
          yield if block_given?
        ensure
          _config_store.pop_env
        end

        def as(who)

          if who.respond_to? :fetch
            user = who.fetch(:user,  who.fetch("user"))
            group = who.fetch(:group, who.fetch("group", nil))
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

      end
    end
  end
end