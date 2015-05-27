
module SynapseClient
  class Order < APIResource
    include SynapseClient::APIOperations::List

    attr_reader :status
    attr_reader :amount
    attr_reader :seller_email
    attr_reader :seller_id
    attr_reader :bank_pay
    attr_reader :bank_id
    attr_reader :note
    attr_reader :date_settled
    attr_reader :date
    attr_reader :ticket_number
    attr_reader :resource_uri
    attr_reader :account_type
    attr_reader :fee

    def initialize(options = {})
      options = Map.new(options)

      update_attributes(options)
    end

    def self.all(params={})
      orders = list(params, "recent").orders
      orders.map{|order| Order.new(order)}
    end

    def self.create(params={})
      puts "SynapsePay Order Creation: #{params}"
      response = SynapseClient.request(:post, url + "add", params.merge(status_url: SynapseClient.webhook))

      return response unless response.successful?
      Order.new(response.data.order)
    end

    def self.retrieve_endpoint
      "poll"
    end

    def retrieve_params
      {:order_id => @id}
    end

    def update_attributes(options)
      super(options)
      
      # TODO fix this bad code
      @seller_id     = options[:seller_id] || options[:seller].delete("seller_id") rescue nil
    end

  end
end

