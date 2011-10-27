#!/usr/bin/env ruby

require 'builder/xmlmarkup'
require 'active_support/core_ext'


class ExcelParser < HTTParty::Parser

  SupportedFormats.merge!({'application/vnd.ms-excel' => :excel})

  protected

  def excel
	body
  end
  DirectOperatorBilling.send(:parser, self)
end

# Extends the core 'alacrity' class adding sandbox functions
module Sandbox

  #
  # Provision test customer data in sandbox using XML format.
  #
  # @param customers [Hash] key - msisdn, value - credit to apply
  # @return [HTTParty::Response]
  def provision(customers = { })
	headers = { 'Accept' => 'application/xml', 'content_type' => 'application/xml' }

	builder = Builder::XmlMarkup.new
	body    = builder.tag!('provision-request') do |c|
	  customers.each_pair do |uri, attr|
		attr = { amount: attr } unless attr.is_a? Hash
		uri = (['tel', 'vfacr', 'acr'].include?(URI(uri).scheme) ? uri : "tel:#{uri}")
		c.customer(uri: uri) do |xml|
		  xml.currency attr.delete(:currency) { 'EUR' }
		  xml.credit attr.delete(:amount) { 100 }
		  xml.delay attr.delete(:delay) { 0 }
		end
	  end
	end

	response = self.class.post('/sandbox', format: :xml, timeout: 15, body: body, headers: headers, basic_auth: @auth)
	raise response.inspect.red unless response.code == 200
  end

  def sandbox_test_report(output_file)
	headers = {'Accept' => MIME_XML, 'content_type' => MIME_XML }
	File.open(output_file, 'w:ASCII-8BIT') do |fh|
	  response = self.class.get('/sandbox', timeout: 15, headers: headers, basic_auth: @auth, format: :excel)
	  fh.puts response.body
	end
  end

  DirectOperatorBilling.send(:include, self)


end

