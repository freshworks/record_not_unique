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

You'll need a database that supports unique constraints. This gem has been tested with MySQL(mysql2) and activerecord 3.2.22.x, 4.2.10.

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

**Note:** 

1. `record_not_unique` uses class variables to ensure the validations are passed on to child classes to avoid redundant definitions of `handle_record_not_unique` in multiple classes. If you want the error messages to be dynamic, you can use the Proc error handler and customize error messages for each class.

```ruby
class User < ActiveRecord::Base
  handle_record_not_unique(index: "index_username_on_users", message: {base: Proc.new { custom_unique_message })

  # other common user methods, callbacks, validations...

  private
  def self.custom_unique_message
    "Customer username has been taken"
  end
end

class AdminUser < User
  private
  def self.custom_unique_message
    "Admin username has been taken"
  end
end
```

2. We identified a peculiar behavior when using this. When you are using an association to build the object and save it, a rollback on the associated object doesn't guarantee a rollback on the associatee's object. Even when using `save!` For instance:

```ruby
class Tag < ActiveRecord::Base
  has_many :tag_uses
end

class TagUse < ActiveRecord::Base
  handle_record_not_unique(index: "index_taggable_id_taggable_type_on_tag_uses", message: {base: "Tag is already associated to this entity!")
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end

class User < ActiveRecord::Base
  has_many :tag_uses, as: :taggable
  has_many :tags, through: :tag_uses
end

irb:> user = User.new(name: some_name)
irb:> user.tag_uses.build(tag_id: some_tag.id)
irb:> user.save!
```
in case if the tag_uses entry is already present, the above does not rollback the whole transaction as one would expect. The user record will be persisted but the tag_uses entry will not be and the `save!` would return `true`. Peculiar, right?! there's a fix though: `accepts_nested_attributes_for` to the rescue.

```ruby
class User < ActiveRecord::Base
  has_many :tag_uses, as: :taggable
  has_many :tags, through: :tag_uses

  accepts_nested_attributes_for :tag_uses
end

irb:> user = User.new(name: some_name, tag_uses_attributes: [{
  tag_id: some_tag.id
}])
irb:> user.save!
```
in this case, if the tag_uses entry is already present, both user and tag_uses records would be rolled back. Still, there will be no exceptions!!

## To Do

Add support for higher versions of activerecord.

## License

This project is Licensed under the MIT License. Further details can be found [here](/LICENSE).