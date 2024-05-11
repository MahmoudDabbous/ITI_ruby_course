require 'time'

module Logger
  def log_info(message)
    save_to_log_files("info", message)
  end

  def log_warning(message)
    save_to_log_files("warning", message)
  end

  def log_error(message)
    save_to_log_files("error", message)
  end

  private

  def save_to_log_files(log_type, message)
    timestamp = Time.now.iso8601
    File.open("app.log", "a") do |file|
      file.puts "#{timestamp} -- #{log_type} -- #{message}"
    end
  end
end

class User
  attr_reader :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end

  def decrease_balance(amount)
    raise "Not enough balance" if @balance < amount
    @balance -= amount
  end
end

class Transaction
  attr_reader :user, :value

  def initialize(user, value)
    @user = user
    @value = value
  end
end

class Bank
  def process_transactions(transactions, &callback)
    raise "#{self.class} has not implemented method '#{__method__}'"
  end
end

class CBABank < Bank
  include Logger

  def initialize(users)
    @users = users
  end

  def process_transactions(transactions, &callback)
    transactions_list = transactions.map { |t| "#{t.user.name} transaction with value #{t.value}" }
    log_info("Processing Transactions #{transactions_list.join(", ")}")

    transactions.each do |transaction|
      begin
        user = @users.find { |user| user.name == transaction.user.name }

        if user
          user.decrease_balance(transaction.value.abs)
          log_info("User #{transaction.user.name} transaction with value #{transaction.value} succeeded")

          if user.balance == 0
            log_warning("#{user.name} has 0 balance")
          end

          callback.call("success", transaction) 
        else
          raise "#{transaction.user.name} don't exist in the bank."
        end

      rescue => e
        log_error("User #{transaction.user.name} transaction with value #{transaction.value} failed with message #{e.message}")
        callback.call("failure", transaction, e.message) 
      end
    end
  end
end

if __FILE__ == $0
  users = [
    User.new("Ali", 200),
    User.new("Peter", 500),
    User.new("Manda", 100)
  ]

  out_side_bank_users = [
    User.new("Menna", 400)
  ]

  transactions = [
    Transaction.new(users[0], -20),
    Transaction.new(users[0], -30),
    Transaction.new(users[0], -50),
    Transaction.new(users[0], -100),
    Transaction.new(users[0], -100),
    Transaction.new(out_side_bank_users[0], -100)
  ]

  cba_bank = CBABank.new(users)

  cba_bank.process_transactions(transactions) do |status, transaction, reason = nil|
    if status == "success"
      puts "Call endpoint for success of User #{transaction.user.name} transaction with value #{transaction.value}"
    else
      puts "Call endpoint for failure of User #{transaction.user.name} transaction with value #{transaction.value} with reason #{reason}"
    end
  end
end