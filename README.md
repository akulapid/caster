Caster gives you a nice DSL for bulk operations over couchdb databases, and a command line tool that supports database versioning so you can write migration scripts for your database.

#Install

You can fetch it directly from Rubygems:

    [sudo] gem install caster


#Usage

Create a file using the following format for the filename.

    <version>.<database>.<some descriptive name>.cast

Then execute this by

    cast up --db=<database> <directory to cast files>

#Syntax

Caster can add, update, rename, remove fields from all documents over a given view.

```ruby
over 'foobar/by_id' do
  add 'name', 'attila'
end
```

A query can be passed to restrict the scope of the operation.

```ruby
over 'foobar/by_score', { 'key' => '0' } do
  update 'score', 10
end
```

You can refer other fields in the document using the implicit parameter passed to the block. You can freely use ruby code anywhere, so you can call other functions to perform transformations that you want.

```ruby
over 'foobar/by_id' do |doc|
  add 'last_name', extract_last_name(doc['name'])
end
```

If you have a relational model, you can also refer documents across views.

```ruby
over 'foobar/all_authors' do |author|
  add 'last_published', from('foobar/all_books').where{ |book| book.author_id == author.id and book['published_on'] > auhtor['last_published] }['last_published']
end
```

#Configuration

Place a YAML file in the current directory when executing a cast command to provide runtime properties.

```yaml
host: 10.1.3.
port: 5985
metadoc_type: dbver
metadoc_id_prefix: meta
```

caster creates documents in your database to maintain verion information. metadoc\_type will add a type field to the document to let you distinguish this document. The document will be created with an id &lt;metadoc\_id\_prefix&gt;\_&lt;database&gt;.
