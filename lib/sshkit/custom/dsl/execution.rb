module SSHKit
  module Custom
    module DSL
      module Execution


        [:execute, :make, :rake, :test, :capture, :upload!, :download!].each do |method|
          define_method method do |*args, &block|
            config_store.runner.send_cmd method, *args, &block
          end
        end

      end
    end
  end
end
