class AddVkontakteIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :vk_id, :string
  end

  def self.down
   remove_column :users, :vk_id
  end
end
