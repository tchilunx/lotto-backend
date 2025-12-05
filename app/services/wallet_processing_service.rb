class WalletProcessingService
  class InsufficientFundsError < StandardError; end

  def self.credit!(wallet, amount, reference, description = nil)
    wallet.with_lock do
      balance_before = wallet.real_balance
      wallet.real_balance += amount
      wallet.save!

      create_operation(wallet, :credit, amount, balance_before, wallet.real_balance, reference, :completed)
    end
  end

  def self.debit!(wallet, amount, reference, description = nil)
    wallet.with_lock do
      raise InsufficientFundsError, "Solde insuffisant" if wallet.real_balance < amount

      balance_before = wallet.real_balance
      wallet.real_balance -= amount
      wallet.save!

      create_operation(wallet, :debit, amount, balance_before, wallet.real_balance, reference, :completed)
    end
  end

  def self.lock!(wallet, amount, reference, description = nil)
    wallet.with_lock do
      raise InsufficientFundsError, "Solde insuffisant pour blocage" if wallet.real_balance < amount

      balance_before = wallet.real_balance
      wallet.real_balance -= amount
      wallet.theoretical_balance += amount # Move to theoretical_balance (locked)
      wallet.save!

      create_operation(wallet, :lock, amount, balance_before, wallet.real_balance, reference, :completed)
    end
  end

  def self.unlock!(wallet, amount, reference, description = nil)
    wallet.with_lock do
      raise InsufficientFundsError, "Montant bloqué insuffisant" if wallet.theoretical_balance < amount

      balance_before = wallet.real_balance
      wallet.theoretical_balance -= amount
      wallet.real_balance += amount
      wallet.save!

      create_operation(wallet, :unlock, amount, balance_before, wallet.real_balance, reference, :completed)
    end
  end

  def self.burn_lock!(wallet, amount, reference, description = nil)
    wallet.with_lock do
      raise InsufficientFundsError, "Montant bloqué insuffisant" if wallet.theoretical_balance < amount

      balance_before = wallet.real_balance
      wallet.theoretical_balance -= amount
      wallet.save!

      create_operation(wallet, :debit, amount, balance_before, wallet.real_balance, reference, :completed)
    end
  end

  private

  def self.create_operation(wallet, type, amount, balance_before, balance_after, reference, status)
    ClientOperation.create!(
      client: wallet.client,
      client_wallet: wallet,
      operation_type: type,
      amount: amount,
      balance_before: balance_before,
      balance_after: balance_after,
      reference: reference,
      status: status
    )
  end
end
