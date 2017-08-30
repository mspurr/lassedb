class AddGTickerToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :GTicker, :string
  end
end
