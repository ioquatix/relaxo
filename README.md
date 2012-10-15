Relaxo
======

* Author: Samuel G. D. Williams (<http://www.oriontransfer.co.nz>)
* Copyright (C) 2012 Samuel G. D. Williams.
* Released under the MIT license.
* [![Build Status](https://secure.travis-ci.org/ioquatix/relaxo.png)](http://travis-ci.org/ioquatix/relaxo)

Relaxo provides a set of tools and interfaces for interacting with CouchDB. It aims to be as simple and efficient as possible while still improving the usability of various CouchDB features.

Installation
------------

Install the ruby gem as follows:

	sudo gem install relaxo

To build and install the gem from source:

	cd build/
	sudo GEM=gem1.9 rake1.9 install_gem

Basic Usage
-----------

Connect to a local database and manipulate some documents.

	require 'relaxo'
	
	database = Relaxo.connect("http://localhost:5984/test")
	
	doc1 = {:bob => 'dole'}
	database.save(doc1)
	
	doc2 = database.get(doc1['_id'])
	doc2[:foo] = 'bar'
	database.save(doc2)

### Transactions/Bulk Save ###

Sessions support a very similar interface to the main database class and can for many cases be used interchangeably, but with added efficiency.

	require 'relaxo'
	require 'relaxo/session'
	
	database = Relaxo.connect("http://localhost:5984/test")
	animals = ['Neko-san', 'Wan-chan', 'Nezu-chan', 'Chicken-san']
	
	database.transaction do |transaction|
		animals.each do |animal|
			transaction.save({:name => animal})
		end
	end
	# => [
	#	{:name=>"Neko-san", "_id"=>"...", "_rev"=>"..."},
	#	{:name=>"Wan-chan", "_id"=>"...", "_rev"=>"..."},
	#	{:name=>"Nezu-chan", "_id"=>"...", "_rev"=>"..."},
	#	{:name=>"Chicken-san", "_id"=>"...", "_rev"=>"..."}
	#]

All documents will allocated UUIDs appropriately and at the end of the session block they will be updated (saved or deleted) using CouchDB `_bulk_save`. The Transactions interface doesn't support any kind of interaction with the server and thus views won't be updated until after the transaction is complete.

To abort the session, either raise an exception or call `session.abort!` which is equivalent to `throw :abort`.

### Loading Data ###

Relaxo includes a command line script to import documents into a CouchDB database:

	% relaxo --help
	Usage: relaxo [options] [server-url] [files]
	This script can be used to import data to CouchDB.

	Document creation:
	        --existing [mode]            Control whether to 'update (new document attributes takes priority), 'merge' (existing document attributes takes priority) or replace (old document attributes discarded) existing documents.
	        --format [type]              Control the input format. 'yaml' files are imported as a single document or array of documents. 'csv' files are imported as records using the first row as attribute keys.
	        --[no-]transaction           Controls whether data is saved using the batch save operation. Not suitable for huge amounts of data.

	Help and Copyright information:
	        --copy                       Display copyright and warranty information
	    -h, --help                       Show this help message.

This command loads the documents stored in `design.yaml` and `sample.yaml` into the database at `http://localhost:5984/test`.

	% relaxo http://localhost:5984/test design.yaml sample.yaml

...where `design.yaml` and `sample.yaml` contain lists of valid documents, e.g.:

	# design.yaml
	-   _id: "_design/services"
	    language: javascript
	    views:
	        service:
	            map: |
	                function(doc) {
	                    if (doc.type == 'service') {
	                        emit(doc._id, doc._rev);
	                    }
	                }

If you specify `--format=csv`, the input files will be parsed as standard CSV. The document schema is inferred from the zeroth (header) row and all subsequent rows will be converted to individual documents. All fields will be saved as text.

If your requirements are more complex, consider writing a custom script either to import directly using the `relaxo` gem or convert your data to YAML and import that as above.

License
-------

Copyright (c) 2010, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>

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
