require 'test_helper'

describe TransferMoney do
  before do
    @mayur_account = bank_accounts(:mayur)
    @david_account = bank_accounts(:david)
  end

  describe 'existing accounts' do
    it 'adds amount to the balance of target account' do
      existing_balance_of_mayur = @mayur_account.current_balance
      existing_balance_of_david = @david_account.current_balance

      transferred_amount = TransferMoney.new(@mayur_account.id).call(to_account_id: @david_account.id, amount: 10)

      transferred_amount.must_equal 10
      @mayur_account.current_balance.must_equal existing_balance_of_mayur - transferred_amount
      @david_account.current_balance.must_equal existing_balance_of_david + transferred_amount
    end

    it 'should not transfer amount there is not sufficient balance' do
      lambda do
        TransferMoney.new(@david_account.id).call(to_account_id: @mayur_account.id, amount: 10)
      end.must_raise(InsufficientBalanceError)
    end

    it 'should not transfer amount if the amount is negative' do
      lambda { TransferMoney.new(@mayur_account.id).call(to_account_id: @david_account.id, amount: -10) }.must_raise(NegativeAmountError)
    end
  end

  describe 'non existing accounts' do
    it 'should not transfer amount if payer account does not exits' do
      lambda { TransferMoney.new(-1).call(to_account_id: @mayur_account.id, amount: 10) }.must_raise(ActiveRecord::RecordNotFound)
    end

    it 'should not transfer amount if payer account does not exits' do
      lambda { TransferMoney.new(@mayur_account.id).call(to_account_id: -1, amount: 10) }.must_raise(ActiveRecord::RecordNotFound)
    end

  end
end