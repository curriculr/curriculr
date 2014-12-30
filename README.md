Curriculr is a free open-source online course management and delivery system designed specifically for MOOCs (Massive Open Online Courses). It was meant to be:

- **Full-fledged**: Instructors can create courses and organize their contents into units and lectures with videos, audios, images, and documents. Students can enroll in classes, participate in discussions, attend lectures, attempt quizzes and exams, and track their progress.

- **Internationalized**: It comes out of the box with support for two locals `en` (English) and `ar` (Arabic); and other locales can easily be added.

- **Multi-tenant**: Tenants, which are called accounts (not to be confused with user accounts) are identified by subdomains and are completely separate from one another. Each account (tenant) acts as if it is a separate site with its own configuration, courses, users and theme.

- **Themeable**: It supports themes and theme inheritance. Adding a new theme can be as easy as providing a name and changing a few CSS style classes.

- **Extensible**: It was designed to be extensible by means of other gems, plugins or mountable engines; just like any other Rails application.

Refer to the [official site](http://www.curriculr.org) for more information.

## Requirements
On the client side, Curriculr supports all the browsers and platforms supported by [Bootstrap 3](http://getbootstrap.com). For more information on Bootstrap 3 browser support refer to <http://getbootstrap.com/getting-started/#support>.

On the server side, Curriculr is built using

- [Ruby on Rails](http://rubyonrails.org/) &mdash; Our web application framework.
- Either [PostgreSQL](http://www.postgresql.org/) or [MySQL](http://www.mysql.com) &mdash; Our main data store.
- [Redis](http://redis.io/) &mdash; For configuration, translations, and background jobs.
- [Sidekiq](http://sidekiq.org) &mdash; For background processing.
- [ImageMagick](http://www.imagemagick.org) &mdash; For processing images.
- [Minitest](https://github.com/seattlerb/minitest), fixtures, and [Capybara](https://github.com/jnicklas/capybara) &mdash; For testing.
- [MediaElement.js](http://mediaelementjs.com) &mdash; For HTML5 video and audio playing.

A complete list of the gems used in building Curriculr is found at [Gemfile](https://github.com/curriculr/curriculr/blob/master/Gemfile).

Our goal is to keep Curriculr as standard a Rails application as possible so that all the best practices of Rails development and deployment can be easily leveraged.

## Installation
Refer to the [installation guide](http://www.curriculr.org/docs/installation.html) for detailed instructions.

## Configuration
There are three kinds of configurations that can be used to change the behavior of Curriculr. These configurations are stored in Redis and can be changed through the application itself given the proper authorization. They are from the top down:

- **Site settings**: Managed by the site's super user, these configurations apply across accounts to the whole Curriculr site. An example of these configurations is the `supported_locales` which lists all the locales recognized and supported by Curriculr. 

- **Account settings**: Managed by the account administrator, these configurations apply only to a certain account (or tenant). An example of these configurations is the `theme` configuration which apply a specific theme to only the account being configured.

- **Course settings**: Managed by the course instructor, these configurations apply to the course being configured and include configurations such as `grade_distribution`.

Refer to the [configuration guide](http://www.curriculr.org/docs/installation.html) for more detailed information.

## Running the Tests
To run the tests, you need to run

```sh
rake 
```

## Contribution 
Contribution to this project is highly welcomed, from bug fixes to new features and from new locales to new themes. Our ultimate goal is that this application will be as useful to the people as it has been to us, and that overtime a community of developers and users will be formed around it. 

## License 
Curriculr is released under the GNU GPL v3.0 license.

