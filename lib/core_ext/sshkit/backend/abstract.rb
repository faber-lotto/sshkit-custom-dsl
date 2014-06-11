module SSHKit
  module Backend
    # Extend (monkeypatch)the original class with some accessors.
    class Abstract
      attr_writer :pwd, :env, :host, :user, :group

      def pwd
        @pwd ||= []
      end

      def env
        @env ||= {}
      end

      attr_reader :host

      attr_reader :user

      attr_reader :group
    end
  end
end
