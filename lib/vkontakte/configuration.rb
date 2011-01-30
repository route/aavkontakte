module VkontakteAuthentication
  module Configuration
    def vkontakte_enabled_value(value = nil)
      rw_config(:vkontakte_enabled, value, false)
    end

    def vk_app_id(value = nil)
      rw_config(:vk_app_id, value)
    end

    def vk_app_password(value = nil)
      rw_config(:vk_app_password, value)
    end

    def vk_app_cookie
      rw_config(:vk_app_cookie, nil) || rw_config(:vk_app_cookie, "vk_app_#{vk_app_id}") if vk_app_id
    end
  end
end