require "md5"
require "vkontakte/authentication"
require "vkontakte/session"
require "vkontakte/helper"

# TODO: may be rake task..
unless File.exists?("#{RAILS_ROOT}/public/javascripts/vkontakte.js")
  require "ftools"
  File.copy("#{File.dirname(__FILE__)}/vkontakte.js", "#{RAILS_ROOT}/public/javascripts")
end

ActiveRecord::Base.send(:include, VkontakteAuthentication::ActsAsAuthentic)
Authlogic::Session::Base.send(:include, VkontakteAuthentication::Session)
ActionController::Base.helper VkontakteAuthentication::Helper
