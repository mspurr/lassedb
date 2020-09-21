class AddYtickerToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :yticker, :string
  end
end
