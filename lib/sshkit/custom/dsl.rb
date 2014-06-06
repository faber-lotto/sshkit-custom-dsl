require 'sshkit/custom/dsl/version'
require 'core_ext/sshkit'
require 'scoped_storage'

require 'sshkit/custom/config/store'
require 'sshkit/custom/config/runner/abstract'
require 'sshkit/custom/config/runner/sequential'
require 'sshkit/custom/config/runner/parallel'
require 'sshkit/custom/config/runner/group'

require 'sshkit/custom/dsl/config_statements'
require 'sshkit/custom/dsl/exec_statements'
require 'sshkit/custom/dsl/helper'

module SSHKit
  module Custom
    module DSL
      include ConfigStatements
      include ExecStatements
      include Helper
    end
  end
end
