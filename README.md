# Plumbapius

[![Build Status](https://travis-ci.org/funbox/plumbapius.svg?branch=master)](https://travis-ci.org/funbox/plumbapius)
[![Coverage Status](https://coveralls.io/repos/github/funbox/plumbapius/badge.svg?branch=master)](https://coveralls.io/github/funbox/plumbapius?branch=master)

Tool for validation HTTP requests & responses according to API Blueprint specs.

It can be used both in test and production environments.

## Installation

```elixir
def deps do
  [
    {:plumbapius, "~> 0.12.0"}
  ]
end
```

## Preparing JSON schema

Plumbapius requires conversion of APIB to JSON schema.

Some mix tasks to make this process easier are included and described below.
These tasks are supposed to be run manually and resulting JSON schema to be committed.

### `plumbapius.get_docs`

```bash
mix plumbapius.get_docs -c ssh://git@some-repo.com/some-repo.git -b master
```

Clones or updates repository with APIB to local folder (it is useful when APIB specs are stored in separate repo).

### `plumbapius.setup_docs`

```bash
mix plumbapius.setup_docs --from ./.apib/api.apib --into doc.json
```

Converts APIB to JSON schema.

It requires following tools to be installed (globally or locally in Gemfile):

- [drafter](https://github.com/apiaryio/drafter);
- [tomograph](https://github.com/funbox/tomograph).

## Usage

Plumbapius implements [Plug behaviour](https://hexdocs.pm/plug/Plug.html).

Plugs provided:

- `Plumbapius.Plug.LogValidationError` — logs errors.
- `Plumbapius.Plug.SendToSentryValidationError` — posts errors to Sentry.
- `Plumbapius.Plug.RaiseValidationError` — raises error (useful for test environment).

## Examples

router.exs:

```elixir
defmodule DogeApp.Api.Router do
  use DogeApp.Api, :router

  @json_schema_path "../../doc.json"

  @external_resource @json_schema_path
  @json_schema File.read!(@json_schema_path)

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Application.get_env(:doge_app, :plumbapius_plug), json_schema: @json_schema)
  end

 # ...

end
```

test.exs:

```elixir
config :doge_app, plumbapius_plug: Plumbapius.Plug.RaiseValidationError
```

prod.exs:

```elixir
config :doge_app, plumbapius_plug: Plumbapius.Plug.SendToSentryValidationError
```

## Usage in tests

In case you need to ignore Plumbapius validations (for error handling testing etc.), you can use `Plumbapius.ignore`:

```elixir
test "replies with error if request contains malformed json", %{conn: conn} do
  response =
    conn
    |> Plumbapius.ignore()
    |> post("", @bad_params)
    |> json_response(400)
end
```

## Checking coverage

A simple mix task is provided to check uncovered requests.

First configure `preferred_cli_env` for plumbapius task

```
 def project do
    [
      preferred_cli_env: [
        "plumbapius.cover": :test,
      ]
    ]
  end
```

```
> mix plumbapius.cover -s doc.json

Covered cases:

✔ POST  /bot/v1/{chatbot}/messages 202

Missed cases:

✖ POST  /bot/v1/{chatbot}/messages 400

Coverage: 50.0%
```

Task fails with error code if coverage is below given min value

```
> mix plumbapius.cover -s doc.json --min-coverage=0.6

Covered cases:

✔ POST  /bot/v1/{chatbot}/messages 202

Missed cases:

✖ POST  /bot/v1/{chatbot}/messages 400

Coverage: 50.0%

ERROR! min coverage of 50.0% is required
```

To see request/response schemas use `-v` option

```
> mix plumbapius.cover -s doc.json -v
```

You can configure plumbapius to ignore coverage for some requests:

```
config :plumbapius, ignore_coverage: [
  # {method :: String.t() | atom, path :: String.t() | Regex.t(), status :: pos_integer() | :all}
  {"GET", "/bot/v1/{chatbot}/messages", 400},
  {:all, "/admin/users/", :all},
]
```

[![Sponsored by FunBox](https://funbox.ru/badges/sponsored_by_funbox_centered.svg)](https://funbox.ru)
