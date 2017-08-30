class RemovePriceFromCompanies < ActiveRecord::Migration[5.0]
  def change
    remove_column :companies, :price, :string
  end
end
