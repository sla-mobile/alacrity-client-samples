#!/usr/bin/env ruby

# Sample Ruby client application illustrating how to call the customer care
# functions of Alacrity Direct Operator Billing API.

module CustomerCare

  # Perform an immediate charge against a customers account
  def refund(account, transaction_id, request = {})
    post_json "/#{CGI::escape(account)}/transactions/#{transaction_id}",
              {refund_request: request}
    expect_status! 'REFUNDED'
  end

  def get_transaction(account, transaction_id, merchant = nil)
    uri = "/#{CGI::escape(account)}/transactions/#{transaction_id}"
    uri += "?merchant=#{CGI::escape(merchant)}" unless merchant.nil?
    get uri
    @response['transaction']
  end

  def get_transactions(account, merchant = nil)
    uri = "/#{CGI::escape(account)}/transactions"
    uri += "?merchant=#{CGI::escape(merchant)}" unless merchant.nil?
    get uri
    @response['transactions']['transaction']
  end


  DirectOperatorBilling.send(:include, self)

end


