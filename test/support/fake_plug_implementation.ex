defmodule FakePlugImplementation do
  defmodule RequestHandlerRaiseError do
    defexception [:error_message]

    @impl true
    def message(exception) do
      "Plumpabius.RequestError: #{inspect(exception.error_message)}"
    end
  end

  defmodule ResponseHandlerRaiseError do
    defexception [:error_message]

    @impl true
    def message(exception) do
      "Plumpabius.ResponseError: #{inspect(exception.error_message)}"
    end
  end

  @options %Plumbapius.Plug.Options{
    schema: [
      %Plumbapius.Request.Schema{
        body: %ExJsonSchema.Schema.Root{
          custom_format_validator: nil,
          location: :root,
          refs: %{},
          schema: %{
            "$schema" => "http://json-schema.org/draft-04/schema#",
            "properties" => %{
              "login" => %{"type" => "string"},
              "password" => %{"type" => "string"}
            },
            "required" => ["login", "password"],
            "type" => "object"
          }
        },
        content_type: "application/json",
        method: "POST",
        path: ~r/\A\/sessions\z/,
        responses: [
          %Plumbapius.Response.Schema{
            body: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{}
            },
            content_type: "application/json",
            status: 401
          },
          %Plumbapius.Response.Schema{
            body: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{
                "$schema" => "http://json-schema.org/draft-04/schema#",
                "properties" => %{
                  "confirmation" => %{
                    "properties" => %{"id" => %{"type" => "string"}},
                    "required" => ["id"],
                    "type" => "object"
                  }
                },
                "type" => "object"
              }
            },
            content_type: "application/json",
            status: 201
          },
          %Plumbapius.Response.Schema{
            body: %ExJsonSchema.Schema.Root{
              custom_format_validator: nil,
              location: :root,
              refs: %{},
              schema: %{}
            },
            content_type: "application/json",
            status: 200
          }
        ]
      }
    ]
  }

  def options, do: @options

  @spec handle_request_error(map) :: none
  def handle_request_error(error), do: raise(%RequestHandlerRaiseError{error_message: error})

  @spec handle_response_error(map) :: none
  def handle_response_error(error), do: raise(%ResponseHandlerRaiseError{error_message: error})
end