module VkontakteAuthentication
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include InstanceMethods
        validate :validate_by_vk_cookie, :if => :authenticating_with_vkontakte?
        before_destroy :destroy_vkontakte_cookies
      end
    end

    class NotInitializedError < StandardError
    end

    module Config
      def find_by_vk_id_method(value = nil)
        rw_config(:find_by_vk_id_method, value, "find_by_vk_id")
      end
      alias_method :find_by_vk_id_method=, :find_by_vk_id_method

      def vk_id_field(value = nil)
        rw_config(:vk_id_field, value, :vk_id)
      end
      alias_method :vk_id_field=, :vk_id_field
    end

    module InstanceMethods
      def new_registration=(value)
        @new_registration = value
      end

      def new_registration?
        @new_registration.presence
      end

      private
      def authenticating_with_vkontakte?
        record_class.vkontakte_enabled_value && controller.cookies[record_class.vk_app_cookie].present?
      end

      def validate_by_vk_cookie
        @vkontakte_data  = controller.params[:user_session] if controller.params[:user_session]
        auth_data = CGI::parse(controller.cookies[record_class.vk_app_cookie])
        result = "expire=%smid=%ssecret=%ssid=%s%s" % [ auth_data['expire'], auth_data['mid'], auth_data['secret'], auth_data['sid'], record_class.vk_app_password ]
        if MD5.md5(result).to_s == auth_data['sig'].to_s
          raise(NotInitializedError, "You must define vk_id column in your User model") unless record_class.respond_to? find_by_vk_id_method
          if @vkontakte_data
            self.attempted_record = klass.send(find_by_vk_id_method, @vkontakte_data[:mid])
            if self.attempted_record.blank?
              # creating a new account
              self.new_registration = true
              self.attempted_record = record_class.new
              self.attempted_record.send "#{vk_id_field}=", @vkontakte_data[:mid]
              self.attempted_record.send :persistence_token=, Authlogic::Random.hex_token if self.attempted_record.respond_to? :persistence_token=
              map_vkontakte_data
              self.attempted_record.save_without_session_maintenance
            end
          end
          return true
        else
          errors.add_to_base("Authentication failed. Please try again.")
          return false
        end
      end

      def map_vkontakte_data
        self.attempted_record.send("#{klass.login_field}=", @vkontakte_data[:user][:nickname]) if self.attempted_record.send(klass.login_field).blank?
        self.attempted_record.send("first_name=", @vkontakte_data[:user][:first_name]) if @vkontakte_data[:user][:first_name]
        self.attempted_record.send("last_name=", @vkontakte_data[:user][:last_name]) if @vkontakte_data[:user][:last_name]
      end

      def find_by_vk_id_method
        self.class.find_by_vk_id_method
      end

      def vk_id_field
        self.class.vk_id_field
      end

      def record_class
        self.class.klass
      end
      
      def delete_cookie(key)
        return unless key
        domain = controller.request.domain
        [".#{domain}", "#{domain}"].each { |d| controller.cookies.delete(key, :domain => d) }
      end

      def destroy_vkontakte_cookies
        delete_cookie(record_class.vk_app_cookie)
      end
    end
  end
end
