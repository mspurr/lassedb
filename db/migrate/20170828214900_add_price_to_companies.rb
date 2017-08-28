class AddPriceToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :price, :float
  end
end
