require 'sshkit/custom/dsl/version'
require 'core_ext/sshkit'
require 'scoped_storage'

require 'sshkit/custom/dsl/config_store'
require 'sshkit/custom/dsl/configuration'
require 'sshkit/custom/dsl/execution'
require 'sshkit/custom/dsl/helper'

module SSHKit
  module Custom
    module DSL
      include Configuration
      include Execution
      include Helper
    end
  end
end
