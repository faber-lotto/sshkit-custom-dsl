module SSHKit
  module Custom
    module DSL
      module Helper
        LOGGING_METHODS = [:log, :debug, :fatal, :error, :warn, :info, :debug].freeze

        # @api private
        # @!macro [attach] dsl_helper.create_backend_delegator
        #   @!method $1(*args, &block)
        #   @api public
        #   @dsl
        #   Delegates $1 to the active backend
        def self.create_backend_delegator(method)
          define_method method do |*args|
            active_backend.send method, *args
          end
        end

        # Returns the active backend in the current thread
        # @dsl
        # @see SSHKit::Custom::Config::Store#active_backend
        def active_backend
          SSHKit::Custom::Config::Store.active_backend
        end

        # Return the host of the active backend
        def host
          active_backend.host
        end

        create_backend_delegator :log
        create_backend_delegator :debug
        create_backend_delegator :fatal
        create_backend_delegator :error
        create_backend_delegator :warn
        create_backend_delegator :info
        create_backend_delegator :debug

        # Conversion function. Converts a host name into a Host object.
        # @param rh [String, SSHKit::Host] The hostname or a SSHKit::Host object
        # @dsl
        def Host(rh)
          if rh.is_a?(SSHKit::Host)
            rh
          else
            SSHKit::Host.new(rh)
          end
        end

        # @api private
        def _config_store
          @_config_store ||= SSHKit::Custom::Config::Store
        end
      end
    end
  end
end
