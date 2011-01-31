module VkontakteAuthentication
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include InstanceMethods
        validate :validate_by_vk_cookie, :if => :authenticating_with_vkontakte?
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
      private
      def authenticating_with_vkontakte?
        if record_class.vkontakte_enabled_value && controller.cookies[record_class.vk_app_cookie].present?
          delete_cookie(record_class.vk_app_cookie)
          return true
        else
          return false
        end
      end

      def validate_by_vk_cookie
        user_session = controller.params[:user_session]
        result = "expire=%smid=%ssecret=%ssid=%s%s" % [user_session[:expire], user_session[:mid], user_session[:secret], user_session[:sid], record_class.vk_app_password]
        if MD5.md5(result).to_s == user_session[:sig].to_s
          raise(NotInitializedError, "You must define vk_id column in your User model") unless record_class.respond_to? find_by_vk_id_method
          possible_record = search_for_record(find_by_vk_id_method, user_session[:mid])
          if possible_record.nil?
            possible_record = record_class.new
            possible_record.send "#{vk_id_field}=", user_session[:mid]
            possible_record.send :persistence_token=, Authlogic::Random.hex_token if possible_record.respond_to? :persistence_token=
            possible_record.send :save, false
          end
          self.attempted_record = possible_record
        end
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
    end
  end
end
