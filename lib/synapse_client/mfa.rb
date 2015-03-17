
module SynapseClient
  class MFA

    attr_reader :type
    attr_reader :questions
    attr_reader :bank_account_token

    def initialize(options = [])
      options.to_options!.compact

      @bank_account_token = options[:access_token]
      @type               = options[:type]

      if @type == "questions"
        @questions = []
        questions  = options[:mfa]
        questions.each do |q|
          @questions.push q["question"]
        end
      end
    end

  end
end
