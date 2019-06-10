# Relaxo

Relaxo is a transactional database built on top of git. It's aim is to provide a robust interface for document storage and sorted indexes. If you prefer a higher level interface, you can try [relaxo-model](https://github.com/ioquatix/relaxo-model).

[![Build Status](https://secure.travis-ci.org/ioquatix/relaxo.svg)](http://travis-ci.org/ioquatix/relaxo)
[![Code Climate](https://codeclimate.com/github/ioquatix/relaxo.svg)](https://codeclimate.com/github/ioquatix/relaxo)
[![Coverage Status](https://coveralls.io/repos/ioquatix/relaxo/badge.svg)](https://coveralls.io/r/ioquatix/relaxo)

## Installation

Add this line to your application's Gemfile:

	gem 'relaxo'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install relaxo

## Usage

Connect to a local database and manipulate some documents.

	require 'relaxo'
	require 'msgpack'
	
	DB = Relaxo.connect("test")
	
	DB.commit(message: "Create test data") do |dataset|
		object = dataset.append(MessagePack.dump({bob: 'dole'}))
		dataset.write("doc1.msgpack", object)
	end
	
	DB.commit(message: "Update test data") do |dataset|
		doc = MessagePack.load dataset.read('doc1.msgpack').data
		doc[:foo] = 'bar'
		
		object = dataset.append(MessagePack.dump(doc))
		dataset.write("doc2.msgpack", object)
	end
	
	doc = MessagePack.load DB.current['doc2.msgpack'].data
	puts doc
	# => {"bob"=>"dole", "foo"=>"bar"}

### Document Storage

Relaxo uses the git persistent data structure for storing documents. This data structure exposes a file-system like interface, which stores any kind of data. This means that you are free to use JSON, or BSON, or MessagePack, or JPEG, or XML, or any combination of those.

Relaxo has a transactional model for both reading and writing.

#### Authors

By default, Relaxo sets up the repository author using the login name and hostname of the current session. You can explicitly change this by modifying `database.config`. Additionally, you can set this per-commit:

```ruby
database.commit(message: "Testing Enumeration", author: {user: "Alice", email: "alice@localhost"}) do |dataset|
	object = dataset.append("Hello World!")
	dataset.write("hello.txt", object)
end
```

#### Reading Files

	path = "path/to/document"
	
	DB.current do |dataset|
		object = dataset.read(path)
		
		puts "The object id: #{object.oid}"
		puts "The object data size: #{object.size}"
		puts "The object data: #{object.data.inspect}"
	end

#### Writing Files

	path = "path/to/document"
	data = MessagePack.dump(document)
	
	DB.commit(message: "Adding document") do |changeset|
		object = changeset.append(data)
		changeset.write(path, object)
	end
	
### Datasets and Transactions

`Dataset`s and `Changeset`s are important concepts. Relaxo doesn't allow arbitrary access to data, but instead exposes the git persistent model for both reading and writing. The implications of this are that when reading or writing, you always see a consistent snapshot of the data store.

### Suitability

Relaxo is designed to scale to the hundreds of thousands of documents. It's designed around the git persistent data store, and therefore has some performance and concurrency limitations due to the underlying implementation.

Because it maintains a full history of all changes, the repository would continue to grow over time by default, but there are mechanisms to deal with that.

#### Performance

Relaxo can do anywhere from 1000-10,000 inserts per second depending on how you structure the workload.

	Relaxo Performance
	Warming up --------------------------------------
	              single   129.000  i/100ms
	Calculating -------------------------------------
	              single      6.224k (±14.7%) i/s -    114.036k in  20.000025s
	  single transaction should be fast
	Warming up --------------------------------------
	            multiple   152.000  i/100ms
	Calculating -------------------------------------
	            multiple      1.452k (±15.2%) i/s -     28.120k in  20.101831s
	  multiple transactions should be fast

Reading data is lighting fast as it's loaded directly from disk and cached.

### Loading Data

As Relaxo is unapologetically based on git, you can use git directly with a non-bare working directory to add any files you like. You can even point Relaxo at an existing git repository.

### Durability

Relaxo is based on `libgit2` and asserts that it is a transactional database. We base this assertion on:

- All writes into the object store using `libgit2` are atomic and synchronized to disk.
- All updates to refs are atomic and synchronized to disk.

Provided these two invariants are maintained, the operation of Relaxo will be safe, even if there are unexpected interruptions to the program.

The durability guarantees of Relaxo depend on [`libgit2` calling `fsync`](https://github.com/libgit2/libgit2/pull/4030), and [this being respected by the underlying hardware](http://www.evanjones.ca/intel-ssd-durability.html). Otherwise, durability cannot be guaranteed.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2015, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
