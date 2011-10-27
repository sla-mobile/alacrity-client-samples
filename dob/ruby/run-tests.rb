#!/usr/bin/env ruby

# Sample Ruby client application illustrating how to perform a charge
# against customer's account using the Alacrity REST API.

require 'pp'
require 'rubygems'
require 'httparty'
require 'json'
require 'cgi'
require 'colored'

$: << File.expand_path('../lib', __FILE__)

require 'alacrity'
require 'examples'

CUSTOMER1_URI = 'tel:385780000001'
CUSTOMER2_URI = 'tel:385780000002'
CUSTOMER3_URI = 'tel:385780000003'
CUSTOMER4_URI = 'tel:385780000004'

SANDBOX_REPORT_PATH = File.expand_path('../test-report.xls', __FILE__)

$dob = DirectOperatorBilling.new

class DobExamples < ExampleSet

  before do
	$dob.provision CUSTOMER1_URI => { amount: 10.00, currency: 'EUR' },
				   CUSTOMER2_URI => { amount: 15.00, currency: 'EUR' },
				   CUSTOMER3_URI => { amount: 30.00, currency: 'EUR' },
				   CUSTOMER4_URI => { amount: 5.00, currency: 'EUR' }
  end

  after do
	$dob.sandbox_test_report SANDBOX_REPORT_PATH

	# open in default viewer, platform specific may fail on your system. It's just an .xls file
	# so feel free to open in openoffice/libreoffice/excel or other spreadsheet app of your choice
	%x[open #{SANDBOX_REPORT_PATH}] rescue nil
  end


  example 'immediate charge' do
	@txn_id_1 = $dob.charge CUSTOMER1_URI,
							amount:              1.99, purchase_locale: 'en_IE',
							content_description: 'Widget', merchant: MERCHANT_ID
  end


  example 'partial refund of previous charge' do
	$dob.refund CUSTOMER1_URI, @txn_id_1,
				amount:   -1.50, purchase_locale: 'en_IE',
				merchant: MERCHANT_ID, csr_id: 'this is a test refund only'
  end


  example 'two-phase reserve / capture' do
	@txn_id_2 = $dob.reserve CUSTOMER2_URI,
							 amount:              1.99, purchase_locale: 'en_IE',
							 content_description: 'Widget', merchant: MERCHANT_ID
	$dob.capture CUSTOMER2_URI, MERCHANT_ID, @txn_id_2
  end


  example 'two-phase reserve / release' do
	@txn_id_3 = $dob.reserve CUSTOMER2_URI,
							 amount:              1.99, purchase_locale: 'en_IE',
							 content_description: 'Widget', merchant: MERCHANT_ID
	$dob.release CUSTOMER2_URI, MERCHANT_ID, @txn_id_3
  end


  example 'partial refund captured transaction' do
	$dob.refund CUSTOMER2_URI, @txn_id_2,
				amount:   -0.99, purchase_locale: 'en_IE',
				merchant: MERCHANT_ID, csr_id: 'this is a test refund only'
  end


  example 'reserve without capture or release' do
	$dob.reserve CUSTOMER4_URI,
				 amount:              2.50, purchase_locale: 'en_IE',
				 content_description: 'Widget', merchant: MERCHANT_ID
  end


  example 'retrieve customer transaction details' do
	transaction = $dob.get_transaction CUSTOMER1_URI, @txn_id_1
  end


  example 'customer transaction history' do
	all_transactions = $dob.get_transactions CUSTOMER1_URI
  end

end

DobExamples.run!






