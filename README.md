# Recursive Case Indifferent Ostruct

Takes a hash of snake, camel, train, or kabab case and make its
attributes accessible with any other case.

The main application is for working with JSON from an API and standardizing
to a Ruby-centric underscore/snake case interface.

##Usage

Gemfile

```ruby
gem "recursive_case_indifferent_ostruct"
````


## Examples
```ruby
user = RecursiveCaseIndifferentOstruct.new({
  "firstName"   => "Tommy",
  "first-name"  => "Bobby",
  "LAST_NAME"   => "Johnson",
  "Birth-Place" => "Springfield",
  "father"      => {
    "age"     72
  },
  "siblings"    => [
    {relation: "brother", age: 12}
  ]
}, :lower_camel)

# access attributes like so
user.first_name # "Tommy"
user.last_name # "Johnson"
user.father.age # 72
user.siblings[0].age # 12

user.birth_place    = "New York" # set fields
user.first_name     = "Ken" # sets {"firstName" => "Ken", "first-name" => "Ken"}
user.mothers_maiden = "Woods" # Since case is mixed in that hash, use default :lower_camel


user.to_h
# {
#   "firstName"   => "Ken",
#   "first-name"  => "Bobby",
#   "LAST_NAME"   => "Johnson",
#   "Birth-Place" => "New York",
#   "father"      => {
#     "age"     72
#   },
#   "siblings"    => [
#     {relation: "brother", age: 12}
#   ],
#   "mothersMaiden" => "Woods",
# }
```


### Case Matching
Since the key matching is fuzzy, should there be two attributes with
the same name but different case (`first-name` and `firstName`), the
library will return first value that it finds. For an assignment it
will assign all matching attributes to the new value.

### Default Case
Should you assign an attribute to the hash that does not already exist
the library will try to figure out which case to use based on other
keys in the hash. If it cannot determine which case is being used
it will fall back to `RecursiveCaseIndifferentOstruct::DEFAULT_CASE=:snake`
which you could set to override. Another option is to pass the default
case on initialization `RecursiveCaseIndifferentOstruct.new(hash, :snake)`.

Available options:
  * `:snake` *this_is_snake*
  * `:lower_camel` *thisIsLowerCamel*
  * `:upper_camel` *ThisIsUpperCamel*
  * `:kabab` *this-is-kabab*
  * `:train` *This-Is-Train*

If you need to assign a value to a key that has an odd case you can
use a string with the bracket syntax like so: `json["PI:Value"] = 3.14`.
The value can still be accessed via `json.pi_value`.


### Hash Methods
`RecursiveCaseIndifferentOstruct` will pass methods along to the hash
if the method is not defined and there is not attribute matching that
name. However, all the hash methods operate on the original hash, so
`#has_key?`, `#each`, `#fetch`, etc, will not be case-indifferent.

```ruby
json = RecursiveCaseIndifferentOstruct.new({
  ID: 123,
  userName: "pax"
})

json.has_key?(:user_name) # false
json.has_key?("userName") # true
json.fetch(:id) # nil
json.keys # [:ID, :userName]

```


## Tests
`rake test`


