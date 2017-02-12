
require 'benchmark/ips' if ENV['BENCHMARK']
require 'ruby-prof' if ENV['PROFILE']
require 'flamegraph' if ENV['FLAMEGRAPH']

RSpec.describe "Relaxo Performance" do
	let(:database_path) {File.join(__dir__, 'test')}
	let(:database) {Relaxo.connect(database_path)}
	
	let(:prefix) {"records"}
	
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
		benchmark("single") do |i|
			database.commit(message: "Some Documents") do |dataset|
				i.times do |i|
					object = dataset.append("good-#{i}")
					dataset.write("#{prefix}/#{i}", object)
				end
			end
		end
	end
	
	it "multiple transactions should be fast" do
		benchmark("multiple") do |i|
			i.times do |i|
				database.commit(message: "Some Documents") do |dataset|
					object = dataset.append("good-#{i}")
					dataset.write("#{prefix}/#{i}", object)
				end
			end
		end
	end
end
