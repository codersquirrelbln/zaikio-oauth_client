
# Zaikio Directory Gem

This Gem enables you to easily connect to the Zaikio Directory and use the OAuth2 flow as well as query the API for information about the User and connected Organizations.

-- STILL A WORKING DRAFT --


## Installation

To provide all functionality this gem is a **Ruby Gem** as well as a **Node Package**, both are currently hosted privately in the **GitHub Package Registry**.

To fetch both from the GitHub Package Registry follow these steps:

1. You must use a personal access token with the `read:packages` and `write:packages` scopes to publish and delete public packages in the GitHub Package Registry with RubyGems. Your personal access token must also have the `repo` scope when the repository is private. For more information, see "[Creating a personal access token for the command line](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line)."

2. Set an ENV variable that will be used for both gem and npm. *This will also work on Heroku or your CI App if you set the ENV variable there.*
```bash
export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=#Your-Token-Here#
```

3. For the **Ruby Gem**, add in your Gemfile

```ruby
source "https://rubygems.pkg.github.com/crispymtn" do
  gem "zaikio"
end
```
Then run `bundle install`.

4. For the **Node Package** you have to add a file `.npmrc` to your Rails project, with the following content:

```
//npm.pkg.github.com/:_authToken=${BUNDLE_RUBYGEMS__PKG__GITHUB__COM}
@crispymtn:registry=https://npm.pkg.github.com
```
Then run `yarn add @crispymtn/zaikio` - your `package.json` should have `@crispymtn/zaikio` added as a dependency afterwards.


## Setup & Configuration

1. Copy & run Migrations
```bash
rails zaikio:install:migrations
rails db:migrate
```
This will create the tables:
+ `zaikio_people`
+ `zaikio_organizations`
+ `zaikio_organization_memberships`
+ `zaikio_access_tokens`
+ `zaikio_sites`

2. Mount routes
```ruby
mount Zaikio::Engine => "/zaikio"
```

3. Setup config in `config/initializers/zaikio_directory.rb`
```ruby
Zaikio.tap do |config|
  # App Settings
  config.client_id      = '52022d7a-7ba2-41ed-8890-97d88e6472f6'
  config.client_secret  = 'ShiKTnHqEf3M8nyHQPyZgbz7'
  config.directory_url  = 'https://directory.sandbox.zaikio.com'
end
```

## Use the Rails Engine in your application

### Models and relations

The engine provides you with the following models to use in your application:
+ `Zaikio::Person`
+ `Zaikio::Organization`
+ `Zaikio::OrganizationMembership`
+ `Zaikio::AccessToken` (you should not require to use this one)
+ `Zaikio::Site`

A `Zaikio::Person` has many `:memberships` and `:organizations`.
A `Zaikio::Organization` has many `:memberships` and `:members` and and `:sites`.

#### Add references between Zaikio models and your models

If you want to establish a reference between your own models and the Zaikio models:

```ruby
# add migration
def change
  add_reference :items, :person, type: :uuid, foreign_key: { to_table: :zaikio_people }
end

# in your item.rb model
belongs_to :person, class_name: 'Zaikio::Person'
```

Of course you could also reference to `zaikio_organizations`.

#### Add logic to the Zaikio models

You can easily make your own model and let it inherit from one of the Zaikio models do add more behaviour and relations:

```ruby
# in your customer.rb
class Customer < Zaikio::Organization
  # Associations
  has_many :vehicles
  has_many :facilities

  def your_own_methods
  end
end
```

### OAuth Flow

From any point in your application you can start using the Zaikio Directory OAuth2 flow with

```ruby
redirect_to zaikio.new_session_path
```

This will redirect the user to the OAuth Authorize endpoint of the Zaikio Directory `.../oauth/authorize` and include all necessary parameters like your client_id.

#### Create or update Person and Organization data

After the user logged in successfully at the Zaikio Directory a redirect will happen back to your application to `.../zaikio/sessions/approve` (or whatever you mounted the Engine to) - including the Authorization Grant Code.

Exchanging the Code for an AccessToken and querying user data from the API will happen automatically in the `Zaikio::SessionsController`.

All Zaikio models (`Zaikio::Person, Zaikio::Organization, Zaikio::OrganizationMembership`) in relation to the signed in user will automatically be created or updated (depending on if already present in your database).

#### Session handling

The Zaikio gem engine will set a cookie for the user after a successful OAuth flow: `cookies.encrypted[:zaikio_person_id]`.

In your controllers include the concern `Zaikio::CookieBasedAuthentication` which will set:
```ruby
Current.user ||= Person.find_by(id: cookies.encrypted[:zaikio_person_id])
````

You can then use `Current.user` anywhere.

As an alternative build your own concern and use the `zaikio_person_id` from the encrypted cookie within your application as you like.


For **logout** use: `zaikio.session_path, method: :delete` or build your own controller for deleting the cookie.

#### Redirecting

The `zaikio.new_session_path` which was used for the first initiation of the OAuth flow, accepts an optional parameter `origin` which will then be used to redirect the user at the end of a completed & successful OAuth flow.


## Use Sandbox for testing

With the above described credentials you can connect right away to our Sandbox environment to get access to the demo app with demo users.

The UUID of people and organizations within the Sandbox are the same as within the fixtures of this gem (see `zaikio_people.yml`and `zaikio_organizations.yml`).

### OAuth workflow testing

This gem provides a test which will initiate th OAuth process, open the Sandbox Directory within the Chrome browser, enter the credentials of a demo user and check if will be successfully redirected.

To run the test use
```bash
rails app:test:system
```


#### Prerequisites

Make sure you have used `bundle install` for the `selenium-webdriver` gem and make sure chromedriver is working:

```bash
chromedriver -v
```

You might encounter some version issues with Rbenv and Chromedriver, to resolve [follow these steps](https://medium.com/fusionqa/issues-with-rbenv-and-chromedriver-990bb14aa57a).

#### Manual Testing

To log in by yourself and test the process manually, use the demo person with the credentials you can find in `test/system/zaikio/sessions_test.rb`.


## Use of dummy app

You can use the included dummy app as a showcase for the workflow and to adjust your own application. To set up the dummy application properly, go into `test/dummy` and use [puma-dev](https://github.com/puma/puma-dev) like this:

```shell
puma-dev link -n 'zaikio-app'
```
This will make the dummy app available at: [http://zaikio-app.test](http://zaikio-app.test/)

If you use the provided OAuth credentials from above and test this against the Sandbox, everything should work as the redirect URLs for [http://zaikio-app.test](http://zaikio-app.test/) are approved within the Sandbox.

## Use Zaikio UI Elements

This gem provides you with a convenient toolbox for building HEI.OS apps easy and fast.
By providing common styles and scripts, the gem makes sure that all apps look and feel the same.

### Helpers
To use tools like the FormBuilder or helpful methods like `link_to_modal` include the following in your `application_controller.rb`

```ruby
default_form_builder Zaikio::FormBuilder
helper Zaikio::ApplicationHelper
```

### CSS
Import all selected styles to your app by adding the following line to your
`application.sass` file (recommended!):

```sass
@import zaikio/all
```

Alternatively, only single parts can be imported, eg.

```sass
@import zaikio/common
@import zaikio/components
…
```

Add navigation and main stage by adding the following to your `application.html.erb`:
```erb
  <body>
    <nav>
      <%= link_to 'Home', '#', class: controller_name == 'pages' && 'is-active' %>
      <%= link_to 'Foobar', '#', class: controller_name == 'foobar' && 'is-active' %>
    </nav>
    <div id="stage">
      <%= yield %>
    </div>
  </body>
```

### JS

In your Rails project at `/javascript/packs/application.js` import the different JS components:

```javascript
import '@crispymtn/zaikio/controllers';
```


---

All available modules will be documented in this repo's [WIKI](https://github.com/crispymtn/zaikio-gem/wiki) soon.



## Contributing

**Make sure you have the dummy app running locally to validate your changes.**

Depending on if you changed functionality of the **Ruby Gem** components or the UI components from the **Node Package** you have to deploy either one of them to the GitHub Package Registry.

### Ruby Gem

Follow the setup instructions for gem credentials and bundler that can be found [in the GitHub docs](https://help.github.com/en/articles/configuring-rubygems-for-use-with-github-package-registry#authenticating-to-github-package-registry).

Make your changes and adjust `version.rb`.

**To push a new release:**

- `gem build zaikio.gemspec`
- `gem push --key github --host https://rubygems.pkg.github.com/crispymtn zaikio-0.1.0.gem`
*Adjust the version accordingly.*

### Node Package

Edit your global `~/.npmrc` and add
```
//npm.pkg.github.com/:_authToken=YOUR-GITHUB-TOKEN
```
If you do not yet have created one from the Installation Guide above, see "[Creating a personal access token for the command line](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line)."

Within the gem navigate into `test/dummy/app/javascript/zaikio` where the Node Package is situated and your changes will take place.

Adjust the `version` information within `package.json` (**important**: the one `test/dummy/app/javascript/zaikio`).

**To push a new release:**

`npm publish` within the folder of `test/dummy/app/javascript/zaikio`


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
