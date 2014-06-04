module SSHKit
  module Backend
    class Abstract
      attr_writer :pwd, :env, :host, :user, :group

      def pwd
        @pwd ||= []
      end

      def env
        @env ||= {}
      end

      def host
        @host
      end

      def user
        @user
      end

      def group
        @group
      end

    end
  end
end