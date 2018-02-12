# RecordNotUnique

ActiveRecord doesn't do a great job of rescuing ActiveRecord::RecordNotUnique exceptions arised from trying to insert a duplicate entry on a unique column.

This gem handles these scenarios and adds a validation error on the field specified for each index to be rescued from, making it behave like a normal activerecord validation.

Even if you have `validates_uniqueness_of :some_field` in your model, it will prevent the `ActiveRecord::RecordNotUnique` from being raised in _some_ cases, but not all, as race conditions between multiple processes could still attempt to insert duplicate entries to your table.

## Installation

Add this line to your application's Gemfile:

    gem 'record_not_unique', git: 'git@github.com:freshdesk/record_not_unique.git'

And then execute:

    $ bundle install

## Usage

You'll need a database that supports unique constraints. This gem has been tested with MySQL(mysql2) and activerecord 3.2.22.x.

```ruby
class AddIndexToUser < ActiveRecord::Migration
  shard: :all

  def change
    add_index :users, :username, unique: true, name: "index_username_on_users"
  end
end
```

Before:

```ruby
class User < ActiveRecord::Base
end

user = User.create(username: "foo")
dupe = User.create(username: "foo")
# => raises ActiveRecord::RecordNotUnique
```

After:

```ruby
class User < ActiveRecord::Base
  handle_record_not_unique(index: "index_username_on_users", message: {name: :taken})
end

user = User.create(username: "foo")
dupe = User.create(username: "foo")
# => false
dupe.errors.full_messages
# => "Username has already been taken"
```

`handle_record_not_unique` supports multiple indices per model and procs for errors messages as well:
```ruby
class User < ActiveRecord::Base
  handle_record_not_unique(
    {index: "index_username_on_users", message: {name: :taken} },
    {index: "index_email_on_users", message: {email: :taken} },
    {index: "index_new_constraint_on_users", message: {base: Proc.new { I18n.t('new_constraint_failed_msg') } } }
  )
end
```

## To Do

Add support for higher versions of activerecord and other activerecord adapters.

## License

This project is Licensed under the MIT License. Further details can be found [here](/LICENSE).