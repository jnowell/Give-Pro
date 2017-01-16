class AddAmountRegexToNonProfits < ActiveRecord::Migration
  def change
    add_column :non_profits, :amount_regex, :string
  end
end
