module VkontakteAuthentication
  module ActsAsAuthentic
    def self.included(klass)
      klass.class_eval do
        extend Config
        if defined? AuthlogicRpx
          remove_acts_as_authentic_module AuthlogicRpx::ActsAsAuthentic::Methods
          add_acts_as_authentic_module Methods, :prepend
          add_acts_as_authentic_module AuthlogicRpx::ActsAsAuthentic::Methods
        else
          add_acts_as_authentic_module Methods, :prepend
        end
      end
    end

    module Config
      def vkontakte_enabled(vk_app_data = {})
        value = vk_app_data.present? && vk_app_data[:vk_app_id] && vk_app_data[:vk_app_password] ? true : false
        if vkontakte_enabled_value(value)
          vk_app_id vk_app_data[:vk_app_id]
          vk_app_password vk_app_data[:vk_app_password]
        end
      end
      alias_method :vkontakte_enabled=, :vkontakte_enabled

      def vkontakte_enabled_value(value = nil)
        rw_config(:vkontakte_enabled, value, false)
      end

      def vkontakte_auto_registration(value = true)
        rw_config(:vkontakte_auto_registration, value, true)
      end
      alias_method :vkontakte_auto_registration=, :vkontakte_auto_registration

      def vkontakte_auto_registration_value(value = nil)
        rw_config(:vkontakte_enabled, value, true)
      end

      def vk_app_id(value = nil)
        rw_config(:vk_app_id, value)
        ActiveRecord::Base.send(:rw_config, :vk_app_id, value)
      end

      def vk_app_password(value = nil)
        rw_config(:vk_app_password, value)
      end

      def vk_app_cookie
        rw_config(:vk_app_cookie, nil) || rw_config(:vk_app_cookie, "vk_app_#{vk_app_id}") if vk_app_id
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

      def using_vkontakte?
        authenticating_with_vkontakte?
      end

      private
      def validate_password_not_vkontakte?
        !authenticating_with_vkontakte? && (defined?(AuthlogicRpx) ? !using_rpx? : true) && require_password?
      end

      def authenticating_with_vkontakte?
        vk_id.present?
      end
    end
  end
end
