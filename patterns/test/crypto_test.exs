defmodule CryptoTest do
  use ExUnit.Case

  alias Crypto

  @moduletag :capture_log

  test "hashing" do
    "B060EC95F0BEF0F967671AB6A47196685CC241BF3CD329A8DB3A09E253C7CCA9" =
      :crypto.hash(:blake2s, "This is some data")
      |> Base.encode16()

    "170959DFB421768A00EFDC6C70580C5B473E54691A6E5EF32711D4D102CE8AE8" =
      :crypto.hash(:blake2s, "This is some other data")
      |> Base.encode16()

    "07F6BFDB1BC57D898DD8A9022BF01BB581529323071E21337628C3EF6AB29BD1" =
      :crypto.hash(:sha256, "This is some other data")
      |> Base.encode16()
  end

  test "hmac" do
    payload =
      :erlang.term_to_binary(%{some: "Data", i: "Need"})
      |> Base.encode64()

    secret_key = "this_is_a_secret_and_secure_key"

    correct_hmac = generate_hmac(secret_key, payload)

    false = validate_hmac("INVALID_KEY", payload, correct_hmac)

    true = validate_hmac(secret_key, payload, correct_hmac)
  end

  test "symmetric" do
    message = "This is a very very important message. Keep it secret...keep safe"
    secret_key = :crypto.strong_rand_bytes(32)
    encrypted = encrypt(message, secret_key)

    {:error, _} =
      try do
        decrypt(encrypted, "INVALID_KEY")
      rescue
        e -> {:error, e}
      end

    ^message = decrypt(encrypted, secret_key)
  end

  defp generate_hmac(secret_key, payload) do
    :hmac
    |> :crypto.mac(:sha256, secret_key, payload)
    |> Base.encode64()
  end

  defp validate_hmac(your_key, payload, expected_hash) do
    :hmac
    |> :crypto.mac(:sha256, your_key, payload)
    |> Base.encode64()
    |> Kernel.==(expected_hash)
  end

  defp encrypt(message, key) do
    opts = [encrypt: true, padding: :zero]
    :crypto.crypto_one_time(:aes_256_ecb, key, message, opts)
  end

  defp decrypt(payload, key) do
    opts = [encrypt: false]

    :aes_256_ecb
    |> :crypto.crypto_one_time(key, payload, opts)
    |> String.trim(<<0>>)

    # ^ remove null padding bytes 
  end
end
