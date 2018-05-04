defmodule Toybox.CS do
	@moduledoc """
	Provide tools to create CS test objects quickly.
	"""

	require Logger

	@doc """
 	Print usage

 	"""
 	def usage do
    	"""A group of functions meant to be used inside of iex.
    	configure/0			- Configure the connection to CS
    	get_bucket_names/0	- Return a list of bucket names
    	put/3				- Put data in s3://bucket/key
    	bucket_exists/1		- Return true if the bucket exists
    	fill_data/4			- Make a numbered set of buckets with a number of objects filled with a fun's output
    	"""
	end

	# Configure connection to CS
	# Currently using erlcloud
	def configure do
		access_key = Toybox.get_env(:toybox, "aws_access_key_id") |> String.to_charlist
		secret_key = Toybox.get_env(:toybox, "aws_secret_access_key") |> String.to_charlist
		cs_proxy = Toybox.get_env(:toybox, "cs_proxy_host") |> String.to_charlist
		cs_port = Toybox.get_env(:toybox, "cs_proxy_port")
		:ok = :erlcloud_s3.configure(access_key, secret_key, 's3.amazonaws.com', 8080, 'http', cs_proxy, cs_port, [])
	end

	def put(bucket, key, value) do
		:erlcloud_s3.put_object(bucket, key, value)
	end

	# This is a little weird, because it pretends that the return is a key/value list, which it sort of is
	def get_bucket_names() do
		:erlcloud_s3.list_buckets() |> Keyword.get(:buckets) |> List.flatten |> Keyword.get_values(:name)
	end

	def bucket_exists(search) do
		:lists.member(search, get_bucket_names())
	end

	def make_bucket(bucket) do
		if bucket_exists(bucket) do
			Logger.error("make_bucket: Bucket #{bucket} already exists!")
			{:error, 'Bucket #{bucket} exists'}
		else 
			:erlcloud_s3.create_bucket(bucket)		
		end
	end

	defp path_name(n, :file) when is_integer(n) and is_atom(type) do
	    'file' ++ Integer.to_charlist(n)
	end
	defp path_name(n, :bucket) when is_integer(n) and is_atom(type) do
	    'test' ++ Integer.to_charlist(n)
	end
	defp path_name(n, _type) when is_integer(n) and is_atom(_type) do
        {:error, 'type must be :bucket or :file'}
	end
		
	def fill_bucket(bucket, count, fun) when is_function(fun) do
		case make_bucket(bucket) do
			:ok -> fill_bucket_files(bucket, count, 1, fun)
			{:error, msg} -> Logger.error("Aborting fill_bucket: #{msg}")
				{:error, msg}
		end
	end

	defp fill_bucket_files(bucket, count, acc, fun) when acc < count do
		put(bucket, path_name(acc, :file), (fun.()))
		fill_bucket_files(bucket, count, acc + 1, fun)
	end
	defp fill_bucket_files(bucket, count, acc, fun) when acc >= count do
		put(bucket, path_name(acc, :file), (fun.()))
	end

	def fill_data(bucket, end_bucket, object_count, fun) when bucket < end_bucket do
		fill_bucket(path_name(bucket, :bucket), object_count, fun)
		fill_data(bucket + 1, end_bucket, object_count, fun)
	end
	def fill_data(bucket, _end_bucket, object_count, fun) do
		fill_bucket(path_name(bucket, :bucket), object_count, fun)
	end
end
