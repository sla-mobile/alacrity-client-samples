
# Sample Ruby client application illustrating how to perform two-phase
# transactions against customer's account 'using the Alacrity REST API.
#

# Extends the core 'alacrity' class adding two-step funds
module TwoPhaseCharging

  # Perform a charge request against Alacrity. Returns transaction_id or
  # raises an exception if funds could not be reserved.
  def reserve(account, request = {})
    url = "/#{CGI::escape(account)}/transactions"
    post_json url, {reserve_request: request}
    expect_status! 'RESERVED'
    @response['transaction_id']
  end


  # Capture funds against an open transaction
  def capture(account, merchant, transaction_id)
    url = "/#{CGI::escape(account)}/transactions/#{transaction_id}/capture"
    post_json url, {capture_request: {merchant: merchant}}
    expect_status! 'CAPTURED'
    # puts @response.inspect
  end


  # Release an existing transaction
  def release(account, merchant, transaction_id)
    delete "/#{CGI::escape(account)}/transactions/#{transaction_id}" + "?merchant=#{merchant}"
    expect_status! 'CANCELLED'
  end

  DirectOperatorBilling.send(:include, self)
end

