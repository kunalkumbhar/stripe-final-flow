# frozen_string_literal: true

class AddCustIdToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :cust_id, :string
  end
end
