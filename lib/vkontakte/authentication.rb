module VkontakteAuthentication
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        extend Config
        if defined? AuthlogicRpx::ActsAsAuthentic::Methods
          remove_acts_as_authentic_module AuthlogicRpx::ActsAsAuthentic::Methods
          add_acts_as_authentic_module Methods, :prepend
          add_acts_as_authentic_module AuthlogicRpx::ActsAsAuthentic::Methods
        else
          add_acts_as_authentic_module Methods, :prepend
        end
      end
    end
    
    class NotInitializedError < StandardError
    end

    module Config
      def vkontakte_enabled(vk_app_data = {})
        value  = vk_app_data.present? ? vk_app_data[:vk_app_id].present? && vk_app_data[:vk_app_password] : false
        vkontakte_enabled_value(value)
        if vkontakte_enabled_value
          rw_config(:vk_app_id, vk_app_data[:vk_app_id])
          rw_config(:vk_app_password, vk_app_data[:vk_app_password])
          rw_config(:vk_app_cookie, "vk_app_#{vk_app_data[:vk_app_id]}")

          message = "Set vk_app_id and vk_app_password in your environment."
          raise NotInitializedError, message if vkontakte_enabled_value && VK_APP_ID.blank? && VK_APP_PASSWORD.blank? && VK_APP_COOKIE.blank?
        end
      end
      alias_method :vkontakte_enabled=,:vkontakte_enabled

      def vkontakte_enabled_value(value = nil)
        rw_config(:vkontakte_enabled, value, false)
      end
    end

    module Methods
      def self.included(klass)
        klass.class_eval do
          validates_length_of_password_field_options validates_length_of_password_field_options.merge(:if => :validate_password_not_vkontakte?)
          validates_confirmation_of_password_field_options validates_confirmation_of_password_field_options.merge(:if => :validate_password_not_vkontakte?)
          validates_length_of_password_confirmation_field_options validates_length_of_password_confirmation_field_options.merge(:if => :validate_password_not_vkontakte?)
        end
      end

      private
      def validate_password_not_vkontakte?
        !authenticating_with_vkontakte? && (defined? AuthlogicRpx::ActsAsAuthentic::Methods ? !using_rpx? : true) && require_password?
      end

      def authenticating_with_vkontakte?
        vk_id.present? 
      end
    end

  end
end
