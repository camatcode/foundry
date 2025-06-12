defmodule GenCronTest do
  use ExUnit.Case

  doctest GenCron

  test :gen_cron do
    GenCron.start_link(10_000)
    Process.sleep(31_000)
    GenServer.stop(GenCron)
  end
end
