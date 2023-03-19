import Config

api_key =
  System.get_env("OPENAI_API_KEY") || raise "Environment variable OPENAI_API_KEY is missing."

organization_key =
  System.get_env("OPENAI_ORGANIZATION_KEY") ||
    raise "Environment variable OPENAI_ORGANIZATION_KEY is missing."

config :openai,
  api_key: api_key,
  organization_key: organization_key
