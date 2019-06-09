# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'benchmark/ips' if ENV['BENCHMARK']
require 'ruby-prof' if ENV['PROFILE']
require 'flamegraph' if ENV['FLAMEGRAPH']

RSpec.describe "Relaxo Performance" do
	let(:database_path) {File.join(__dir__, 'test')}
	let(:database) {Relaxo.connect(database_path)}
	
	if defined? Benchmark
		def benchmark(name = nil)
			Benchmark.ips do |benchmark|
				# Collect more data for benchmark:
				benchmark.time = 20
				benchmark.warmup = 10
				
				benchmark.report(name) do |i|
					yield i
				end
				
				benchmark.compare!
			end
		end
	elsif defined? RubyProf
		def benchmark(name)
			result = RubyProf.profile do
				yield 1000
			end
			
			#result.eliminate_methods!([/^((?!Utopia).)*$/])
			printer = RubyProf::FlatPrinter.new(result)
			printer.print($stderr, min_percent: 1.0)
			
			printer = RubyProf::GraphHtmlPrinter.new(result)
			filename = name.gsub('/', '_') + '.html'
			File.open(filename, "w") do |file|
				printer.print(file)
			end
		end
	elsif defined? Flamegraph
		def benchmark(name)
			filename = name.gsub('/', '_') + '.html'
			Flamegraph.generate(filename) do
				yield 1
			end
		end
	else
		def benchmark(name)
			yield 1
		end
	end
	
	before(:each) do
		FileUtils.rm_rf(database_path)
	end
	
	it "single transaction should be fast" do
		benchmark("single") do |iterations|
			database.commit(message: "Some Documents") do |dataset|
				iterations.times do |i|
					object = dataset.append("good-#{i}")
					dataset.write("#{i%100}/#{i}", object)
				end
			end
		end
	end
	
	it "multiple transactions should be fast" do
		benchmark("multiple") do |iterations|
			iterations.times do |i|
				database.commit(message: "Some Documents") do |dataset|
					object = dataset.append("good-#{i}")
					dataset.write("#{i%100}/#{i}", object)
				end
			end
		end
	end
end
