
module SynapseClient
  class Customer < APIResource
    include SynapseClient::APIOperations::List

    attr_accessor :email, :fullname, :phonenumber, :ip_address
    attr_accessor :access_token, :refresh_token, :expires_in
    attr_accessor :username
    attr_accessor :force_create

    def initialize(options = {})
      options = Map.new(options)

      @id            = options[:id]            || options[:user_id]
      @email         = options[:email]
      @fullname      = options[:fullname]      || options[:name]
      @phonenumber   = options[:phonenumber]   || options[:phone_number]
      @ip_address    = options[:ip_address]

      @access_token  = options[:access_token]
      @refresh_token = options[:refresh_token]
      @expires_in    = options[:expires_in]
      @username      = options[:username]

      @force_create  = options[:force_create]
    end

    def self.api_resource_name
      "user" # see README.md
    end

    def self.create(opts={})
      Customer.new(opts).create
    end
    
    def self.list(search="")
      headers  = {"REMOTE_ADDR" => @ip_address}
      response = SynapseClient.request(:post, url + "search", {}, headers)
      return response
    end

    def create
      headers  = {"REMOTE_ADDR" => @ip_address}
      response = SynapseClient.request(:post, url + "create", to_hash, headers)

      return response unless response.successful?
      update_attributes(response.data)
    end
    
    def update(params={})
      response = SynapseClient.request(:post, url + "edit", params.merge({:access_token => access_token}))
      return response unless response.successful?
      update_attributes(response.data)
    end

    def self.retrieve(access_token)
      response = SynapseClient.request(:post, url + "show", {:access_token => access_token})

      return response unless response.successful?
      Customer.new(response.data.user.merge({
        :access_token  => access_token
      }))
    end

    # TODO
    def login
      # use http://synapsepay.readme.io/v1.0/docs/authentication-login
    end

  #
    def bank_accounts
      BankAccount.all({:access_token => @access_token})
    end
    
    
    # Bank methods for customer
    def find_bank_account_id(id=nil)
      return bank_accounts unless id.present?
      bank_accounts.each do |bank_account|
        return bank_account if bank_account.id == id
      end
    end
    
    def primary_bank_account
      @bank_accounts.select{|ba| ba.is_buyer_default}.first
    end

    def add_bank_account(params={})
      BankAccount.add(params.merge({
        :access_token => @access_token,
        :fullname     => @fullname
      }))
    end

    def remove_bank_account(bank_id=nil)
      raise ArgumentException, "No Synapsepay Bank Account ID Passed To Remove Method" unless bank_id.present?
      BankAccount.remove({
        access_token: @access_token,
        bank_id: bank_id
      })
    end

    def link_bank_account(params={})
      BankAccount.link(params.merge({
        :access_token => @access_token
      }))
    end

    def finish_linking_bank_account(params={})
      BankAccount.finish_linking(params.merge({
        :access_token => @access_token
      }))
    end

  #
    def orders
      Order.all({:access_token => @access_token})
    end

    def deposit_status(params={})
      Deposit.show(params.merge({
        :access_token => @access_token
      }))
    end

    def deposit(params={})
      Deposit.link(params.merge({
        :access_token => @access_token
      }))
    end

    def add_micro_deposits(params={})
      Deposit.micro(params.merge({
        :access_token => @access_token
      }))
    end

    def withdrawl(params={})
      Withdrawl.link(params.merge({
        :access_token => @access_token
      }))
    end


    def add_order(params={})
      if SynapseClient.merchant_synapse_id.nil?
        raise ArgumentError.new("You need to set SynapseClient.merchant_synapse_id before you can submit orders.")
      else
        Order.create(params.merge({
          access_token: @access_token,
          seller_id: SynapseClient.merchant_synapse_id,
          bank_pay: "yes",
          status_url: SynapseClient.webhook
        }))
      end
    end

=begin
    def link_account(options = {}, client)
      options.to_options!.compact

      data = {
        :bank               => options[:bank_name],
        :password           => options[:password],
        :pin                => options[:pin] || "1234",
        :username           => options[:username]
      }

      request  = SynapseClient::Request.new("/api/v2/bank/login/", data, client)
      response = request.post

      if response.instance_of?(SynapseClient::Error)
        response
      elsif response["is_mfa"]
        SynapseClient::MFA.new(response["response"])
      else
        add_bank_accounts response["banks"]
        @bank_accounts
      end
    end
    def unlink_account(options = {}, client)
      data = {
        :bank_id => options.delete(:bank_id),
      }

      request  = SynapseClient::Request.new("/api/v2/bank/delete/", data, client)
      request.post
    end
=end
  end
end


