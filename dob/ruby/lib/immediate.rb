
module SingleStepCharging

  # Perform an immediate charge against a customers account
  def charge(account, request = {})
    post_json "/#{CGI::escape(account)}/transactions", {purchase_request: request}
    expect_status! 'CHARGED', 'purchase_response'
    # puts @response.inspect
    @response['purchase_response']['transaction_id']
  end

  DirectOperatorBilling.send(:include, self)

end


