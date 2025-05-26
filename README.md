# Securial

[![Gem Version](https://badge.fury.io/rb/securial.svg)](https://badge.fury.io/rb/securial)
[![Gem Downloads](https://img.shields.io/gem/dt/rails.svg)](https://rubygems.org/gems/securial)
![License](https://img.shields.io/badge/license-MIT-blue)

[![Tests](https://github.com/alybadawy/securial/actions/workflows/ci.yml/badge.svg)](https://github.com/alybadawy/securial/actions)
[![Coverage Status](https://coveralls.io/repos/github/AlyBadawy/Securial/badge.svg?branch=main)](https://coveralls.io/github/AlyBadawy/Securial?branch=main)

**Securial** is a mountable Rails engine that provides robust, extensible authentication and access control for Rails applications. It supports:

- ✅ JWT-based authentication
- ✅ API tokens
- ✅ Session-based auth
- ✅ Simple integration with web and mobile apps
- ✅ Clean, JSON-based API responses
- ✅ Database-agnostic support

Next, mount the engine in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Securial::Engine => "/securial"
end
```

Full installation steps are available in the [Wiki › Installation](https://github.com/AlyBadawy/Securial/wiki/Installation).

## ⚙️ Configuration

**Securial** generates an initializer with sensible defaults and full control over logging, mailers, session settings, and roles.

For all configuration options and examples, refer to the [Wiki › Configuration](https://github.com/AlyBadawy/Securial/wiki/Configuration)

## 📦 Usage

After installation and mounting, **Securial** exposes endpoints like:

- GET /securial/status — Check service availability
- POST /securial/sessions — Sign in (JWT or session)
- DELETE /securial/sessions — Sign out
- GET /securial/accounts/cool_username — get a user profile by username
- GET /securial/admins/roles — View roles

**Securial** returns consistent JSON API responses.

Full details, including authentication flows and protected routes, are available in the [Wiki › Authentication module docs](https://github.com/AlyBadawy/Securial/wiki/Authentication).

🧩 Modules

**Securial** is organized into modular components including:

- Authentication
- User Management
- Generators
- Securial::Identity concern

Explore all modules in the [Wiki](https://github.com/AlyBadawy/Securial/wiki).

## 🛠 Development & Testing

To run the test suite:

```bash
$ RAILS_ENV=test bundle db:schema:load
$ bundle exec rspec
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
