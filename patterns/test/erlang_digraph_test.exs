defmodule ErlangDigraphTest do
  use ExUnit.Case

  @moduletag :capture_log

  test "digraphs" do
    # ! Mutable !
    workflow = :digraph.new([:acyclic])
    :digraph.add_vertex(workflow, :create_user, do_work("Create user in database"))
    :digraph.add_vertex(workflow, :upload_avatar, do_work("Upload image to S3"))
    :digraph.add_vertex(workflow, :charge_card, do_work("Bill credit card"))
    :digraph.add_vertex(workflow, :welcome_email, do_work("Send welcome email"))

    :digraph.add_edge(workflow, :create_user, :upload_avatar)
    :digraph.add_edge(workflow, :create_user, :charge_card)
    :digraph.add_edge(workflow, :upload_avatar, :welcome_email)
    :digraph.add_edge(workflow, :charge_card, :welcome_email)

    [cyclicity: :acyclic, memory: _, protection: :protected] = :digraph.info(workflow)
    [:create_user] = :digraph.source_vertices(workflow)
    [:welcome_email] = :digraph.sink_vertices(workflow)

    # note - utils
    true = :digraph_utils.is_acyclic(workflow)

    # Run workflow
    # top sort is topologically sort
    workflow
    |> :digraph_utils.topsort()
    |> Enum.each(fn vertex ->
      {_ver, work_function} = :digraph.vertex(workflow, vertex)
      work_function.()
    end)

    # required to clean up from ETS
    :digraph.delete(workflow)
  end

  def do_work(step) do
    fn ->
      IO.puts("Running the following step: " <> step)

      # Simulate load
      Process.sleep(500)
    end
  end
end
