defmodule Plumbapius.Request do
  @moduledoc "Defines methods for validating requests by schema"

  defmodule NotFoundError do
    defexception [:method, :path]

    @impl true
    def message(exception) do
      "Request.NotFoundError request #{exception.method}: #{exception.path} was not found in schema"
    end

    defimpl String.Chars do
      @spec to_string(Exception.t()) :: String.t()
      def to_string(exc), do: Exception.message(exc)
    end
  end

  defmodule UnknownContentTypeError do
    defexception [:method, :path, :content_type]

    @impl true
    def message(exception) do
      "Request.UnknownContentTypeError request #{exception.method}: #{exception.path} " <>
        "with content-type: #{exception.content_type} was not found. " <>
        "Make sure you have correct `content-type` or `accept` headers in your request"
    end

    defimpl String.Chars do
      @spec to_string(Exception.t()) :: String.t()
      def to_string(exc), do: Exception.message(exc)
    end
  end

  defmodule NoContentTypeError do
    defexception [:method, :path]

    @impl true
    def message(exception) do
      "Request.NoContentTypeError request #{exception.method}: #{exception.path} has no content-type header"
    end

    defimpl String.Chars do
      @spec to_string(Exception.t()) :: String.t()
      def to_string(exc), do: Exception.message(exc)
    end
  end

  alias Plumbapius.Request

  @spec validate_body(Request.Schema.t(), map()) :: :ok | {:error, list()}
  def validate_body(request_schema, request_body) do
    case ExJsonSchema.Validator.validate(request_schema.body, request_body) do
      :ok ->
        :ok

      {:error, errors} ->
        {:error, Enum.map_join(errors, ", ", &format_schema_error/1)}
    end
  end

  @spec match?(Request.Schema.t(), String.t(), String.t()) :: boolean()
  def match?(_schema, _request_method, nil), do: false

  def match?(schema, request_method, request_path) do
    String.match?(request_path, schema.path) && schema.method == request_method
  end

  defp format_schema_error({description, json_path}) do
    "#{json_path}: #{description}"
  end
end
