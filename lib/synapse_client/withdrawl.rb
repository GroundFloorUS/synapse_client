# This endpoint deposits the specified amount from the user's Synapse account into their Bank account.
# amount:   The amount a user wishes to deposit
# bank_id:  The bank id where the user wishes to deposit funds
# status_url:	 Where you want SynapsePay to return the status of the transaction when it changes
# oauth_consumer_key:  The consumer key to include for authentication purposes

module SynapseClient
  class Withdrawl < APIResource
    attr_reader :status
    attr_reader :amount
    attr_reader :bank_id
    attr_reader :date_created
    attr_reader :id
    attr_reader :status_url
    attr_reader :user_id
    attr_reader :note
    attr_reader :resource_uri
    attr_reader :date_settled

    def initialize(options = {})
      options = Map.new(options)
      update_attributes(options)
    end

    def self.create(params={})
      puts "SynapsePay Withdrawl Creation: #{params}"
      response = SynapseClient.request(:post, url + "add", params.merge(status_url: SynapseClient.webhook))

      return response unless response.successful?
      Withdrawl.new(response.data.order)
    end
  end
end

