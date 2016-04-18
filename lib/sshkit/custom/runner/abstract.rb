module SSHKit
  module Custom
    # @api public
    # @public
    module Runner
      ExecuteError = SSHKit::Runner::ExecuteError

      # Base class for all runners
      # @abstract Subclass and override {#apply_block_to_bcks} to implement
      # @public
      # rubocop:disable Performance/RedundantBlockCall
      class Abstract
        attr_accessor :backends
        attr_reader :options
        attr_writer :wait_interval

        # Factory method to create a new runner.
        def self.create_runner(opts)
          opts_with_defaults = { in: :parallel }.merge(opts)

          case opts_with_defaults[:in]
          when :parallel
            Parallel
          when :sequence
            Sequential
          when :groups
            Group
          else
            raise "Don't know how to handle run style #{opts_with_defaults[:in].inspect}"
          end.new(opts_with_defaults)
        end

        # @api private
        def self.scope_storage
          ScopedStorage::ThreadLocalStorage
        end

        # @api private
        def self.scope
          @scope ||= ScopedStorage::Scope.new('sshkit_runner', scope_storage)
        end

        # @api private
        def self.active_backend
          scope[:active_backend] || raise(ArgumentError, 'Backend not set')
        end

        # @api private
        def self.active_backend=(new_backend)
          scope[:active_backend] = new_backend
        end

        def initialize(options = nil)
          @options = options || {}
        end

        # @api private
        def active_backend
          self.class.active_backend
        end

        # @api private
        def active_backend=(new_backend)
          self.class.active_backend = new_backend
        end

        # Sends the given command to the backend.
        # @param cmd [Symbol] A command that the sshkit backend supports
        # @param args [Array] Arguments for the backend command
        #
        def send_cmd(cmd, *args, &block)
          args = Array(block.call(active_backend.host)) if block
          active_backend.send(cmd, *args)
        rescue => e
          e2 = ExecuteError.new e
          raise e2, "Exception while executing on host #{active_backend.host}: #{e.message}"
        end

        # @abstract
        def apply_block_to_bcks(&_block)
          raise SSHKit::Backend::MethodUnavailableError
        end

        # @api private
        def apply_to_bck(backend, &block)
          self.active_backend = backend
          block.call(backend.host)
        rescue => e
          e2 = ExecuteError.new e
          raise e2, "Exception while executing on host #{backend.host}: #{e.message}"
        ensure
          self.active_backend = nil
        end

        # @api private
        def do_wait
          sleep wait_interval
        end

        protected

        def wait_interval
          @wait_interval || options[:wait] || 2
        end
      end
      # rubocop:enable Performance/RedundantBlockCall
    end
  end
end
