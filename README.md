Duroosi is a free open-source online course management and delivery system designed specifically for MOOCs (Massive Open Online Courses). It allows instructors to build courses and allows students to enroll in these courses and interactively access their learning contents. It was meant to be:

- **Full-fledged**: It allows instructors to create courses and organize their learning contents into units and lectures. Videos, audios, images, documents, and other files can then be added/loaded to these units and lectures. It also allows for building question banks which are used to create quizzes and exams. Courses are made available to students through scheduled classes, within which students can participate in discussions, attend lectures, attempt quizzes and exams, and track their progress. For a full list of Duroosi features refer to [Features](https://github.com/duroosi/duroosi/wiki/Features).

- **Internationalized**: I started this project because I wanted to offer my own classes in Arabic. As a result, Duroosi comes out of the box with support for two locals `en` (English) and `ar` (Arabic), and others can easily be added. Refer to [Internationalization](https://github.com/duroosi/duroosi/wiki/Internationalization) for instructions on how to add a new locale.

- **Multi-tenant**: It support multitenancy. Tenants are called accounts (which are identified by subdomains and are different from users). They are completely separate from one another. Each account (tenant) has its own configuration, courses, users and theme. Refer to [Multitenancy](https://github.com/duroosi/duroosi/wiki/Multitenancy) for more information.

- **Themeable**: It supports themes and theme inheritance. It comes with a theme based on Twitter Bootstrap with four flavors (colors if you will). Adding a new theme can be as easy as providing a name and changing a few CSS style classes. [Theming](https://github.com/duroosi/duroosi/wiki/Theming) provides more information on creating a new theme.

- **Extensible**: And because there are always going to be features that are needed or nice to have that Duroosi does not provide out of the box, it was designed to be extensible by means of other gems, plugins or mountable engines. Refer to [Extensions](https://github.com/duroosi/duroosi/wiki/Extensions) for more information on how to extend Duroosi.

For a full list of Duroosi features refer to [Features](https://github.com/duroosi/duroosi/wiki/Features).

## Requirements
On the client side and out of the box, Duroosi comes with a theme based on [Bootstrap 3](http://getbootstrap.com), and therefore supports all the browsers and platforms supported by it. For more information on Bootstrap 3 browser support refer to <http://getbootstrap.com/getting-started/#support>.

On the server side, Duroosi is built using

- [Ruby on Rails](http://rubyonrails.org/) &mdash; Our web application framework.
- Either [PostgreSQL](http://www.postgresql.org/) or [MySQL](http://www.mysql.com)&mdash; Our main data store.
- [Redis](http://redis.io/) &mdash; For configuration and translations.
- [ImageMagick](http://www.imagemagick.org) &mdash; Used for processing images.
- [RSepc](http://rspec.info) &mdash; Our testing framework.
- [SublimeVideo](http://www.sublimevideo.net) and [MediaElement.js](http://mediaelementjs.com) &mdash; For HTML5 video and audio playing.

A complete list of the gems used in building Duroosi is found at [Gemfile](https://github.com/duroosi/duroosi/blob/master/Gemfile).

One of our goals is to keep Duroosi as standard a Rails application as possible so that all the best practices of Rails development and deployment can be easily leveraged.

## Installation
Before Duroosi can be deployed, the following must be done:

- Either PostgreSQL or MySQL server is installed and is ready to accept connections. Change the `Gemfile` to include the gem of the database you installed and comment out the one you did not.

```ruby
...

# Either postgresql  
gem 'pg'
# or mysql
#gem 'mysql2'

...
```

- Redis server is installed and ready to accept connections.
- The application *secrets* has been specified. 

### Specifying Application Secrets
To deploy Duroosi, certain pieces of information (we call secrets) have to be provided. These secrets include, for instance, Rails' `secret_key_base`  or the name, email, and password of the first user (User with `id=1`) which is a special *root-like* or *super* user with ability to do anything and everything. These secrets defer from one environment to another and from one application instance to another and are stored in a file called `config/secrets.yml`.

As the name implies, the information contained in this file are supposed to be private that should not be shared at all. It's also highly advisable that it should not be included in any source control (Git, Mercurial, or Subversion) repository. Refer to [Secrets](https://github.com/duroosi/duroosi/wiki/Secrets) for more information on the secrets file and its contents.

Duroosi comes with an example secrets file [config/secrets_exemple.yml](https://github.com/duroosi/duroosi/blob/master/config/secrets_example.yml) filled with dummy settings. To generate a secrets file based on the example file run the following:

```sh
rake duroosi:secrets:generate

```

This will create the `secrets.yml` under the `config/` folder, if it does not exit already. Open this file and make the necessary changes.


### Deploying the Application

Now that the application secrets are provided, you can follow the steps below to deploy Duroosi into a `development` environment.

1: Run bundler

```sh
bundle install
```

2: Create the database and run migrations

```sh
rake duroosi:db:migrate
```

3: Load the seed data

```sh
rake db:seed
```

This will create the default account(tenant) and the first user based on the information from the secrets file.

4: Reset Redis configurations and translations

```sh
rake duroosi:redis:reset
```

**Please note that** steps 2, 3, and 4 can be combined together by running

```sh
rake duroosi:bootstrap
```

5: Finally, run Rails server to start the application in development

```sh
rails server
```

### Running the Tests
To run the tests, you need to run

```sh
rake spec
```

## Other Configurations
Beside secrets, there are three other kinds of configurations that can be used to change the behavior of Duroosi. These configurations are stored in Redis and can be changed through Duroosi administration. They are from the top down:

- Site settings: These are configurations that apply to the whole Duroosi site. An example of these configurations is the `supported_locales` which lists all the locales recognized and supported by the site.

- Account settings: These configurations apply only to a certain account (or tenant). Example of these configurations is the `theme` configuration which apply a specific theme to only the account being configured.

- Course settings: These configurations apply to the course being configured and include configurations such as `grade_distribution`.

Notice that some configurations like the `locale` defined at a higher-level can be overridden in a lower-level. Refer to [Configuration](https://github.com/duroosi/duroosi/wiki/Configuration) for more information.

## Contribution 
Contribution to this project is highly welcomed from bug fixes to new features and from new locales to new themes. Our ultimate goal is that this application will be as useful to the people as it has been to us and that overtime a community of developers and users will be formed. More information about contributing to this project is available at [Configuration](https://github.com/duroosi/duroosi/wiki/Configuration).

## License 
Duroosi is released under the GNU GPL v3.0 license.

