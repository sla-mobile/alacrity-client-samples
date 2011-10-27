require File.expand_path('../../settings', __FILE__)

MIME_JSON = 'application/json'
MIME_XML  = 'application/xml'

# This class provides low-level access to the Alacrity DOB API. Default
# parameters are sourced from 'settings.rb'.

$log_file = File.open('transactions.log', 'w')


class DirectOperatorBilling
  
  include HTTParty

  base_uri ALACRITY_URI
  ssl_ca_file 'sla-alacrity-ca-public.crt'
  format :json

  def initialize(username = API_USERNAME, password = API_PASSWORD)
    @auth = {username: username, password: password}
  end

  protected

  def post_json(url, body = {})
    headers = {'Accept' => MIME_JSON ,'content_type' => MIME_JSON, 'x_alacrity_log' => 'sample' }
    body.merge(yield) if block_given?
    body.values.first.merge!(correlator: make_correlator)
    @response = self.class.post(url, timeout: 15, body: body.to_json, headers: headers, basic_auth: @auth)
    raise @response.inspect.red unless @response.success?
  end

  def delete(url)
    headers = {'Accept' => MIME_JSON ,'content_type' => MIME_JSON }
    @response = self.class.delete(url, timeout: 15, headers: headers, basic_auth: @auth)
    raise @response.inspect.red unless @response.success?
  end

  def get(url)
    headers = {'Accept' => MIME_XML,'content_type' => MIME_XML }
    @response = self.class.get(url, timeout: 15, headers: headers, basic_auth: @auth, format: :xml)
    raise @response.inspect.red unless @response.success?
  end


  def expect_status!(expected, ns = nil)
    (ns.nil? ? @response['status'] : @response[ns]['status']) == expected rescue false or
      raise "Wrong status: got #{@response['status']}, expected #{ns.nil? ? expected : "#{ns}:#{expected}"}. Message=#{@response.inspect}"
  end

  debug_output $log_file
  
  private

  def make_correlator
    (1..10).collect { |i| (rand(26)+65).chr }.join("")
  end

end

%w[immediate customer_care two_step sandbox].each do |api|
  require File.expand_path(api, __FILE__ + '/..')
end
