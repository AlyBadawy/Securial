# Securial Gem

[![Gem Version](https://img.shields.io/gem/v/securial?logo=rubygems&logoColor=ffffff&logoSize=auto&label=version&color=violet&cacheSeconds=120)](https://rubygems.org/gems/securial)
[![Gem Downloads](https://img.shields.io/gem/dt/securial.svg)](https://rubygems.org/gems/securial)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/AlyBadawy/Securial?tab=MIT-1-ov-file#readme)

[![Tests](https://github.com/alybadawy/securial/actions/workflows/ci.yml/badge.svg)](https://github.com/alybadawy/securial/actions)
[![Coveralls](https://img.shields.io/coverallsCoverage/github/AlyBadawy/Securial?branch=main&logo=coveralls&logoColor=%233F5767&labelColor=ddeedd)
](https://coveralls.io/github/AlyBadawy/Securial?branch=main)

[![Documentation](https://img.shields.io/badge/yard-Documentation-blue?style=flat&logo=readthedocs&logoColor=%238CA1AF&label=yard&link=https%3A%2F%2Fwww.rubydoc.info%2Fgems%2Fsecurial%2Findex)](https://alybadawy.github.io/Securial/_index.html)

---

## Overview

### 🛡️ What is Securial?

**Securial** is a mountable Rails engine that provides robust, extensible authentication and access control for Rails applications. It supports:

- 🔑 JWT-based authentication
- ↪️ API session tokens, with refresh tokens
- 🤳 Simple integration with web and mobile apps
- 🧹 Clean, JSON-based API responses
- 🧍 User management with roles
- 🫙 Database-agnostic support

### 👀 Why Securial?

Securial was built to offer a clean, modular, and API-first authentication system for Rails developers who want full control without the black-box complexity. Whether you're building for the web, mobile, or both, Securial gives you the flexibility to implement exactly what you need — from simple JWT authentication to more advanced setups involving sessions, API tokens, and role-based access.

It follows familiar Rails conventions, stays lightweight and database-agnostic, and keeps security at the core. With fully customizable controllers, serializers, and logic, Securial is designed to grow with your project — making it an ideal choice for everything from side projects to production-grade APIs.

## 🚀 Installation

Securial can be installed on an existing Rails application or use the `securial new app_name` command to create a new Securial-ready Rails app.

### Installation on an existing Rails app:

Add Securial to an existing Rails app is as simple as 1..2..3:

- Add `gem "securial"` to your GemFile
- Run `bundle install`
- Run `rails generate securial:install`
- Mount the Securial engine in your Rails application `config/routes.rb` file:

  ```ruby
  Rails.application.routes.draw do
    mount Securial::Engine => "/securial"

    # The rest of your routes
  end
  ```

- Run the migrations by running the command: `rails db:migrate`

💡 Full installation steps are available in the [Wiki › Installation](https://github.com/AlyBadawy/Securial/wiki/Installation).

## ⚙️ Configuration

**Securial** generates an initializer with sensible defaults and full control over logging, mailers, session settings, and roles.

For all configuration options and examples, refer to the [Wiki › Configuration](https://github.com/AlyBadawy/Securial/wiki/Configuration)

## 📦 Usage

After installation and mounting, **Securial** exposes endpoints like:

- GET /securial/status — Check service availability
- POST /securial/sessions — Sign in (JWT or session)
- DELETE /securial/sessions — Sign out
- GET /securial/accounts/cool_username — Get a user profile by username
- GET /securial/admins/roles — View roles

**Securial** returns consistent JSON API responses.

Full details, including authentication flows and protected routes, are available in the [Wiki › Authentication module docs](https://github.com/AlyBadawy/Securial/wiki/Authentication).

## 🧩 Modules

**Securial** is organized into modular components including:

- Authentication
- User Management
- Generators
- Identity concern
- Configuration

Explore all modules in the [Wiki](https://github.com/AlyBadawy/Securial/wiki).

## 🛠 Development & Testing

- Clone the repo on your computer
- Run `bundle install`
- Start coding right away 🏃‍♂️

To run the test suite:

```bash
$ bin/test
```

View the coverage report:

```bash
$ open coverage/index.html
```

## 🤝 Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alybadawy/securial.

1. Fork the repo
2. Create your feature branch (git checkout -b my-feature)
3. Commit your changes (git commit -am 'Add my feature')
4. Push to the branch (git push origin my-feature)
5. Open a Pull Request

## ⚖️ License

The gem is available as open source under the terms of the [MIT license](https://github.com/AlyBadawy/Securial?tab=MIT-1-ov-file#readme).

---

\
![logo-e9f16c9b 1](https://github.com/AlyBadawy/AlyBadawy/assets/1198568/471e5332-f8d0-4b78-a333-7e207780ecc1)
