module SynapseClient
  class BankStatus < APIResource
    def self.all
      SynapseClient.request(:get, url + "show")
    end
  end
end
