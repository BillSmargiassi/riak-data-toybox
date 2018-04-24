defmodule Toybox.CS do
	def get_env(app, var) do
		System.get_env(var) || Application.get_env(app, String.to_atom(var))
	end

	def configure_erlcloud do
		access_key = get_env(:toybox, "aws_access_key_id") |> String.to_charlist
		secret_key = get_env(:toybox, "aws_secret_access_key") |> String.to_charlist
		cs_proxy = get_env(:toybox, "cs_proxy_host") |> String.to_charlist
		cs_port = get_env(:toybox, "cs_proxy_port")
		:ok = :erlcloud_s3.configure(access_key, secret_key, 's3.amazonaws.com', 8080, 'http', cs_proxy, cs_port, [])
	end

	def put(bucket, key, value) do
		:erlcloud_s3.put_object(bucket, key, value)
	end

	def make_bucket(bucket) do
		:erlcloud_s3.create_bucket(bucket)
	end

	defp path_name(n, type) when is_integer(n) and is_list(type) do
		type ++ Integer.to_charlist(n)
	end
	
	defp file_name(n) when is_integer(n) do
		path_name(n, 'file')
	end

	defp bucket_name(n) when is_integer(n) do
		path_name(n, 'test')
	end

	def fill_bucket(bucket, count, fun) when is_function(fun) do
		make_bucket(bucket)
		fill_bucket_files(bucket, count, 1, fun)
	end

	defp fill_bucket_files(bucket, count, acc, fun) when acc < count do
		put(bucket, file_name(acc), (fun.()))
		fill_bucket_files(bucket, count, acc + 1, fun)
	end
	defp fill_bucket_files(bucket, count, acc, fun) when acc >= count do
		put(bucket, file_name(acc), (fun.()))
	end

	def fill_data(bucket, end_bucket, object_count, fun) when bucket < end_bucket do
		fill_bucket(bucket_name(bucket), object_count, fun)
		fill_data(bucket + 1, end_bucket, object_count, fun)
	end
	def fill_data(bucket, _end_bucket, object_count, fun) do
		fill_bucket(bucket_name(bucket), object_count, fun)
	end
end
