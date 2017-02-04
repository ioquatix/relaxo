# Relaxo

Relaxo is a transactional database built on top of git. It's aim is to provide a robust interface for document storage and sorted indexes.

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
		dataset.write("doc1.json", MessagePack.dump({bob: 'dole'}))
	end
	
	DB.commit(message: "Update test data") do |dataset|
		doc = MessagePack.load dataset.read('doc1.json')
		doc[:foo] = 'bar'
		dataset.write("doc2.json", MessagePack.dump(doc))
	end
	
	doc = MessagePack.load DB.current['doc2.json']
	puts doc
	# => {"bob"=>"dole", "foo"=>"bar"}

### Document Storage

Relaxo uses the git persistent data structure for storing documents. This data structure exposes a file-system like interface, which stores any kind of data. This means that you are free to use JSON, or BSON, or MessagePack, or JPEG, or XML, or any combination of those.

The main function for reading is, `data = Dataset#read(path)`, and the main function for writing is `Transaction#write(path, data)`.

Documents are stored using a path, which might be an ID but doesn't need to be. Having lots of documents at the top level is inefficient as the persistent data structure in git would need to work harder, so it's best to store things logically using a path that reflects the natural organisation of what you are dealing with, and if you have a lot of documents, storing them using a prefix subdirectory would be an even better idea.

	require 'relaxo'
	require 'securerandom'
	require 'json'
	
	DB = Relaxo.connect("test")
	animals = ['Neko-san', 'Wan-chan', 'Nezu-chan', 'Chicken-san']
	
	# All writes must occur within a commit:
	DB.commit(message: "Add animals") do |dataset|
		animals.each do |animal|
			dataset.write("animals/#{SecureRandom.uuid}", JSON.dump({name: animal}))
		end
	end
	
	DB.current.each('animals').to_a
	# => [["314874ab-7780-4a46-93e3-67743576ce0b", "{\"name\":\"Nezu-chan\"}"],
 ["36e125e8-fb02-47f5-b829-496c9b296031", "{\"name\":\"Chicken-san\"}"],
 ["ca752b5d-a931-4b58-b384-4fe4f84baf1b", "{\"name\":\"Wan-chan\"}"],
 ["fca923b7-7a42-4812-b0a7-e58508bedbfc", "{\"name\":\"Neko-san\"}"]]

To abort the transaction, either raise an exception or call `transaction.abort!` which is equivalent to `throw :abort`. The code in the transaction block may be run multiple times if conflicts with the data store are detected when the changes is persisted.

### Datasets and Transactions

`Dataset`s and `Transaction`s are important concepts. Relaxo doesn't allow arbitrary access to data, but instead exposes the git persistent model for both reading and writing. The implications of this are that when reading or writing, you always see a consistent snapshot of the data store.

### Suitability

Relaxo is designed to scale to the hundreds of thousands of documents. It's designed around the git persistent data store, and therefore has some performance and concurrency limitations due to the underlying implementation.

Because it maintains a full history of all changes, the repository would continue to grow over time by default.

### Loading Data

As Relaxo is unapologetically based on git, you can use git directly with a non-bare working directory to add any files you like. You can even point Relaxo at an existing git repository.

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
