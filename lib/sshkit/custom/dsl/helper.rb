module SSHKit
  module Custom
    module DSL
      module Helper

        LOGGING_METHODS = [:log, :debug, :fatal, :error, :warn, :info, :debug].freeze

        def active_backend
          SSHKit::Custom::Config::Store.active_backend
        end

        def host
          active_backend.host
        end

        LOGGING_METHODS.each do |method|
          define_method method do |*args|
            active_backend.send method, *args
          end
        end

        def Host(rh)
          if rh.is_a?(SSHKit::Host)
            rh
          else
            SSHKit::Host.new(rh)
          end
        end

        def _config_store
          @_config_store ||= SSHKit::Custom::Config::Store
        end

      end
    end
  end
end