module VkontakteAuthentication
  module Helper
    def init_vkontakte
      vkontakte_div + vkontakte_init
    end

    def vkontakte_login_link(name, url = user_sessions_path, html_options = {})
      authenticity_token = protect_against_forgery? ? form_authenticity_token : ''
      options = "{ url: '#{url}', authenticity_token: '#{authenticity_token}', session_name: '#{session_key_name}', session_key: '#{cookies[session_key_name]}' }"
      link_to name, "#", html_options.merge(:onclick => "vkLogin(#{options});")
    end

    private
    def vkontakte_div
      content_tag(:div, "", :id => "vk_api_transport")
    end

    def vkontakte_init
      javascript_include_tag("vkontakte") + javascript_tag("vkInit(#{VK_APP_ID});") if ActiveRecord::Base.vkontakte_enabled_value
    end
  end
end
