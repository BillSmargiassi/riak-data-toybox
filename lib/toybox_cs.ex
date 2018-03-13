defmodule Toybox.CS do
	def get_env(app, var) do
		System.get_env(var) || Application.get_env(app, String.to_atom(var))
	end

	def configure_erlcloud do
		access_key = get_env(:toybox, "aws_access_key_id")
		secret_key = get_env(:toybox, "aws_secret_access_key")
		cs_proxy = get_env(:toybox, "cs_proxy_host")
		cs_port = get_env(:toybox, "cs_proxy_port")
		:ok = :erlcloud_s3.configure(access_key, secret_key, 's3.smazonaws.com', 8080, 'http', cs_proxy, cs_port, [])
	end

	def put(bucket, key, value) do
		:erlcloud_s3.put_object(bucket, key, value)
	end

	def make_bucket(bucket) do
		:erlcloud_s3.create_bucket(bucket)
	end

	def fill_bucket(bucket, data) do
		:ok
	end
end
