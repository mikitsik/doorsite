# DoorSite / ДВЕРНОЙ.БЕЛ

DoorSite is a Ruby on Rails application for a modern door catalog and showroom-style e-commerce website.

The project is focused on building a clean, SEO-friendly, server-rendered catalog for entrance doors, interior doors, and door systems. It uses real supplier XML/YML data, normalized product models, Hotwire interactions, and a visual storefront interface.

The public brand name of the project is **ДВЕРНОЙ.БЕЛ**.

## Project goals

The main goal of the project is to create a fast, understandable, and search-engine-friendly catalog for the door market in Belarus.

The application is designed as:

* a product catalog;
* a supplier XML/YML import system;
* an SEO-first Rails website;
* a lightweight e-commerce storefront;
* a foundation for future AI-assisted product visualization features.

## Current status

The project is under active development.

Implemented or partially implemented:

* Rails 8 application structure;
* PostgreSQL database;
* product models for different door types;
* import logic for supplier XML/YML feeds;
* normalized interior door fields;
* product grouping by model;
* color and tone normalization concept;
* public product pages;
* catalog UI;
* Hotwire/Turbo-based interactions;
* SEO layout improvements;
* favicon and PWA-related assets;
* production deployment setup.

## Tech stack

* Ruby
* Ruby on Rails 8
* PostgreSQL
* Hotwire
* Turbo
* Stimulus
* Importmap
* PostCSS
* RSpec
* RuboCop
* Brakeman
* Bundler Audit

## Domain model

The project currently separates different catalog entities instead of using one overloaded universal product model.

Main product areas:

* `EntranceDoor`
* `InteriorDoor`
* door systems
* furniture / accessories

For interior doors, the project uses a normalized structure:

```text
series        # coating / technology line
door_model    # visual model of the door
vendor_color  # supplier's commercial color name
hint_tone     # normalized tone group
```

This makes it possible to group product variants by visual model and later allow users to switch between coatings, colors, and images on one product page.

## Supplier imports

The project works with real supplier data sources.

Current data sources include:

* Magna YML feed;
* Elporta XML feed.

The import logic is intentionally supplier-aware. The goal is not to create a fragile universal XML parser, but to map real supplier structures into a clean catalog model.

Typical import responsibilities:

* parse XML/YML;
* detect relevant product categories;
* extract supplier product data;
* normalize product fields;
* preserve raw source data where useful;
* generate searchable text;
* build stable product URLs.

## SEO approach

DoorSite is built as an SSR-first Rails application.

This means:

* product pages are real HTML pages;
* catalog pages are indexable;
* Hotwire improves UX without turning the site into a client-side SPA;
* metadata can be generated server-side;
* product URLs remain stable and crawlable.

SEO priorities:

* clean product URLs;
* unique page titles;
* unique product descriptions where possible;
* canonical URLs;
* sitemap;
* robots.txt;
* brand/entity signals for ДВЕРНОЙ.БЕЛ;
* fast server-rendered pages.

## UI architecture

The frontend is built with Rails views, Hotwire, Turbo Frames, Stimulus, and PostCSS.

The CSS structure follows a component/section-oriented approach:

```text
app/assets/stylesheets/
  base/
  layout/
  components/
  sections/
  pages/
```

The project prefers nested PostCSS style for component organization.

## Development setup

Clone the repository:

```bash
git clone git@github.com:YOUR_USERNAME/doorsite.git
cd doorsite
```

Install dependencies:

```bash
bundle install
npm install
```

Create and migrate the database:

```bash
bin/rails db:create db:migrate
```

Run the development server:

```bash
bin/dev
```

## Tests and quality checks

Run the test suite:

```bash
bundle exec rspec
```

Run RuboCop:

```bash
bundle exec rubocop -A
```

Run security checks:

```bash
bundle exec brakeman
bundle exec bundle-audit
```

## Deployment notes

The project is prepared for production deployment with environment-based configuration.

Production secrets must not be committed to the repository.

Important files such as the Rails master key and local environment files must remain private:

```text
config/master.key
.env*
```

For production Rails commands on the server, environment variables should be loaded before execution.

Example:

```bash
set -a && source /home/deploy/.doorsite_env && set +a
export RAILS_ENV=production
```

## Repository visibility

This repository can be public, but it must not contain:

* `config/master.key`;
* `.env` files;
* real credentials;
* private API tokens;
* database dumps;
* private customer data.

Before making the repository public, check:

```bash
git ls-files config/master.key
git log --all -- config/master.key
git grep -n "SECRET_KEY_BASE\|RAILS_MASTER_KEY\|DATABASE_URL\|PASSWORD\|TOKEN\|API_KEY\|PRIVATE_KEY"
```

## Roadmap

Planned improvements:

* complete product import pipeline;
* improve product grouping by model;
* add better filters for catalog pages;
* finish product show pages;
* improve image handling;
* generate sitemap for all public pages;
* add structured data;
* improve mobile layout;
* add admin tools for catalog management;
* prepare the project for commercial demonstration.

## License

This project is currently maintained as a personal/commercial development project.

License information may be added later.
