- [About Sahaj Atlas](#about-sahaj-atlas)
  - [Rationale](#rationale)
  - [Features](#features)
  - [Browser Support](#browser-support)
- [Getting Started](#getting-started)
  - [Setup](#setup)
  - [Framework & Languages](#framework--languages)
  - [Concepts](#concepts)
    - [Models / Views / Controllers](#models--views--controllers)
      - [Concerns](#concerns)
    - [Abstracted CMS Code](#abstracted-cms-code)
  - [Code Structure](#code-structure)
- [Deployment & Infrastructure](#deployment--infrastructure)
- [External Libraries and Services](#external-libraries-and-services)
  - [Libraries](#libraries)
  - [Services](#services)

# About Sahaj Atlas
## Rationale
Sahaj Atlas is a project to solve the persistent worldwide challenge of out-of-date and poorly presented Sahaja Yoga programs.

We've observed 3 key issues
 - Sahaj websites frequently have out of date program information, leading seekers to non-existent programs
 - Maintaining accurate information is a time-consuming process
 - Sahaj program listings are frequenty presented in ways which are not user-friendly or mobile-friendly.
 - Also: Secondary Sahaj projects (like apps, tours, and global websites), don't have a reliable way to refer seekers to local programs.

## Features
Sahaj Atlas is intended as a single database of Sahaja Yoga classes and public events worldwide. This data can be accessed either through an API or a drop-in map embed. The atlas code is divided into 5 sections, roughly corresponding to 3 key featurs.
 - **Map**, a mobile-friendly map that can be embedded in an iframe on any Sahaj website
   - Users can *register* for events on the map
   - Online programs are also supported in a separate tab
   - The map can be *customized* to change the styling, boundaries, and language for different Sahaj websites.
 - **API**, a GraphQL api were all the published Atlas events can be accessed with an api key
   - Also supports filtering events by language, country, etc.
   - Also supports querying for the closest venue to a given latitude & longitude
 - **CMS**, where yogis can manage venues and events
   - Supports adding managers to specific countries or regions so that they can create events and assign event managers.
   - Supports creating API keys and embed codes for specific Sahaj websites/projects
   - Has an automated expiration system that will hide events that are not regularly verified.
 - **Mail**, emails which are sent to managers of the CMS
   - Every few months every event manager is sent an email asking them to verify their program, or else it gets automatically hidden.
   - Monthly summary emails which are sent to country and region managers.
   - Weekly lists of new registrations which are sent to event managers.
 - **Info**, a few information pages such as the Atlas home page, statistics, and privacy page.

Knowing the above features will also help one understand broadly what is going on in the code.

## Browser Support
We support only the most recent versions of Chrome, Safari, Firefox, Edge, and Opera - including the mobile versions of these browsers. No other browser is officially supported. Internet Explorer is not supported.

# Getting Started

## Setup
- Install Postgres on your computer (for Mac, I recommend [Postgress.app](https://postgresapp.com)), for windows you can try the [official installer](https://www.postgresql.org/download/windows/).
- You may need to [install Ruby](https://www.ruby-lang.org/en/documentation/installation/) if your computer does not already have it installed.
- Clone this repository
- Run `rails db:setup` to create and populate the database.
- Run `rails server` to run the server.

Once the server is running you should be able to access the website at [localhost:3000](http://localhost:3000).

To login to the Content Management System (CMS), you can enter this test email address `admin@example.com`, then check the server log for a print out of the login email. Copy the login url from the server log into your browser to access the CMS.

## Framework & Languages
 - **Ruby on Rails** is our core server framework. If you are not familiar with Ruby, I recommend looking through [this summary](https://learnxinyminutes.com/docs/ruby/) of how to do standard programming things in Ruby. This README will not directly explain how Rails works, but rather just explain the things that you need to know to get started. However, you should be familiar with the concept of [Model-View-Controller](https://www.codecademy.com/articles/mvc), which Rails uses heavily.
 - **Postgres** is our database architecture. However, Rails takes care of almost all the details of this, so you won't be dealing with SQL queries much, but instead calling Rails functions.
 - **Vanilla JavaScript** is used for client side programming. jQuery is currently included as well, but we prefer not to use it when it can be avoided, with a mind to eventually phasing it out.
 - **Sass** is used for stylesheets. Sass is basically the same as CSS, but has a more clean syntax and allows you to use variables and basic functions. Otherwise it uses all the same selectors and attributes as CSS. We also use a library called [Autoprefixer](https://github.com/ai/autoprefixer-rails), which automatically add any necessary prefixes (like `-webkit-`) to your CSS rules. So it is not necessary for you to add these yourself. [Sass Documentation](https://sass-lang.com/guide).
 - **Slim** is used for HTML markup. As Sass does for CSS, Slim does for HTML. It creates a cleaner markup to allow us to write HTML more easily. [Slim Documentation](http://slim-lang.com).
 - **GraphQL** is used for the API structure. [GraphQL Documentation](https://graphql.org/learn/).

## Concepts
There are a few pointers that it will be helpful to know when navigating the codebase.

### Models / Views / Controllers
This is a core concept of how Rails works. Models represent entries in the database. Views represent pages of the website that will be shown to users. When a user accesses a URL on the website, the controller will fetch models from the database and prepare any other data, then send that information to a view to be rendered.

#### Concerns
Concerns are packages of code which get added to a model or controller. This are mainly used for grouping related features that can be reused across multiple models or controllers.

### Abstracted CMS Code
The entirety of the CMS rails code is heavily abstracted, because all these models are managed in almost the same patterns. As such, you wll not see the normal rails views folder structures. Instead there is just one `index`, `show`, `edit`, and `new` view for the whole CMS, and each model is rendered using partials within these views.

Similarly, each model's controller also inherits most of it's behaviour from the generic `CMS::ApplicationController` class

## Code Structure
This is mainly useful for those who are not already familiar with Ruby on Rails. This is just a quick overview of the most important folders and files to help you find what you're looking for.

- `/app` - the core files that make this website happenn
  - `/assets` - images, fonts, javascript, and css
    - `/fonts` - custom fonts for the site
    - `/images` - all images used by the site
    - `/javascripts/cms` - javascript for the atlas' content management system (cms)
    - `/javascripts/map` - javascript for the map
    - `/javascripts/info` - javascript for a few of the root pages of the website
    - `/stylesheets/cms` - sass for the atlas' content management system (cms)
    - `/stylesheets/map` - sass for the map
    - `/stylesheets/info` - sass for the home page, privacy page and statistics page.
    - `/stylesheets/mail` - sass for emails that get sent to managers
  - `/controllers` - contains the classes which handle the URL endpoints that are set up in `/config/routes.rb`
  - `/helpers` - extra methods that can be used in the "view" files.
  - `/models` - the classes that handle access to the database.
    - `/concerns` - small independent bits of functionality that are shared across multiple models
  - `/policies` - defines the rules for what actions a logged-in user can take in the site.
  - `/uploaders` - configuration for different kinds of image uploads
  - `/views` - where we render html
- `/db/migrate` - where we define changes to the database
- `/config` - overall configurationn of the project
  - `/locales` - translation files for every language.
  - `/routes.rb` - defines the URLs that our server accepts
- `/public` - contains files that can be accessed simply by adding their path to the end of the website's url.
- `/Gemfile` - this file defines the Ruby packages which get bundle and installed with the server.

# Deployment & Infrastructure
The project's servers and hosted and deployed using Heroku. Any changes which are pushed to the `master` branch will be automatically deployed to the production server (atlas.sydevelopers.com). If you need access to the staging server, please ask and a login will be created for you.

# External Libraries and Services
If you are implementing a new feature that touches on one of these areas, please use the existing integration or library.

## Libraries
This is a list of some of the key libraries that are used to manage major features.

*Ruby Gems:*
 - *Passwordless*, user login
 - *Pundit*, user permissions
 - *CarrierWave*, file uploads

*JavaScript Libraries:*
 - *Mapbox*, for the public map
 - *Leaflet*, for the maps on the cms
 - *Chartist*, for simple graphs
 - *Uppy*, for file uploads

*CSS Libraries:*
 - *Fomantic UI*, css framework used for the admin/CMS pages

## Services
This is a list of all external services used by the WeMeditate project.

This list is provided for reference, to help track down various parts of the site.

 - *Heroku*, server hosting
 - *Google Cloud Storage*, file storage
 - *G Suite For Business*, for an email inbox to send emails from
 - *Klaviyo*, for mailing list campaigns
 - *Mapbox*, for the map

All accounts are managed and billed by the sydevelopers.com account.
