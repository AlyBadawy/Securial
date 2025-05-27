![image](https://github.com/user-attachments/assets/d7cb9645-c28e-4cca-9c1b-5085a91c11d4)

---
# Securial

[![Gem Version](https://img.shields.io/gem/v/securial?logo=rubygems&logoColor=ffffff&logoSize=auto&label=version&color=violet&cacheSeconds=120)](https://rubygems.org/gems/securial)
[![Gem Downloads](https://img.shields.io/gem/dt/securial.svg)](https://rubygems.org/gems/securial)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/AlyBadawy/Securial?tab=MIT-1-ov-file#readme)

[![Tests](https://github.com/alybadawy/securial/actions/workflows/ci.yml/badge.svg)](https://github.com/alybadawy/securial/actions)
[![Coverage Status](https://coveralls.io/repos/github/AlyBadawy/Securial/badge.svg?branch=main)](https://coveralls.io/github/AlyBadawy/Securial?branch=main)

**Securial** is a mountable Rails engine that provides robust, extensible authentication and access control for Rails applications. It supports:

- ✅ JWT-based authentication
- ✅ API tokens
- ✅ Session-based auth
- ✅ Simple integration with web and mobile apps
- ✅ Clean, JSON-based API responses
- ✅ Database-agnostic support


### 🚀 Why Choose Securial?

Securial isn't just another auth library — it's designed to give you control, flexibility, and peace of mind when building secure Rails APIs.

**🔧 Built for Developers**  
- Easy to mount and extend using familiar Rails conventions.  
- Fully customizable controllers, serializers, and logic — no more black-box auth.

**🧩 Modular by Design**  
- Use only the components you need: JWT, sessions, API tokens — or all of them together.  
- Clean separation of concerns makes testing and debugging simpler.

**⚡ API-First Approach**  
- JSON-only responses make Securial ideal for frontend frameworks and mobile apps.  
- No HTML views or form helpers — just clean endpoints that work out of the box.

**🛡️ Secure by Default**  
- Uses industry best practices for token management and access control.  
- No reliance on client-side sessions or cookies.

**📦 Lightweight, Database-Agnostic**  
- No assumptions about your schema or ORM — works with any relational database.  
- Minimal dependencies, fast to integrate.

**🌱 Ready to Grow With You**  
- Start small with basic JWT auth, scale to multi-token API clients, admin scopes, or full RBAC.  
- Perfect for startups, side projects, and production APIs alike.

## 🚀 Installation

Securial can be installed on an existing Rails application or use the `securial new app_name` command to create a new Securial-ready Rails app.

### Installation on an existing Rails app:

To add Securial to an existing Rails app:

- Add `gem "securial"` to your GemFile
- Run `bundle install`
- run `rails generate securial:install`
- Mount the Securial engine in your Rails application `config/routes.rb` file:
  ```ruby
  Rails.application.routes.draw do
    mount Securial::Engine => "/securial"
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

🧩 Modules

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
