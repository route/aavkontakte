module VkontakteAuthentication
  module Helper
    def init_vkontakte
      vkontakte_div + vkontakte_init if vk_app_id
    end

    def vkontakte_login_link_to(name, url = user_session_path, html_options = {})
      authenticity_token = protect_against_forgery? ? form_authenticity_token : ''
      options = "{ url: '#{url}', authenticity_token: '#{authenticity_token}', session_key: '#{request.session_options[:key]}', session_id: '#{request.session_options[:id]}' }"
      html_options.merge!(:onclick => "vkLogin(#{options});") if vk_app_id
      link_to name, "#", html_options
    end

    private
    def vkontakte_div
      content_tag(:div, "", :id => "vk_api_transport")
    end

    def vkontakte_init
      javascript_include_tag("vkontakte") + javascript_tag("vkInit(#{vk_app_id});")
    end

    def vk_app_id
      ActiveRecord::Base.send(:rw_config, :vk_app_id, nil)
    end
  end
end
