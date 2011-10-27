class ExampleSet

  class << self

	def before(&block)
	  (@before_hooks ||= []) << ['Initializer', block]
	end

	def after(&block)
	  (@after_hooks ||= []) << ['Finalizer', block]
	end

	def reset!
	  @before_hooks = []
	  @after_hooks  = []
	  @examples     = []
	end

	def example(title, &block)
	  (@examples ||= []) << [title, block]
	end

	def run!
	  [@before_hooks, @examples, @after_hooks].reject(&:"nil?").each do |examples|
		examples.each do |title, block|
		  $log_file.puts "%s\n%s\n%s" % ['-' * 80, title, '-' * 80]
		  print "%-50s" % [title + ':']
		  begin
			block.call
			puts "ok".green
		  rescue Exception => e
			puts "failed:".red + e.message
			$log_file.puts "Failed :#{e.message.red}\n\t#{e.backtrace.join("\n\t")}"
		  end
		end
	  end
	end


  end

end


