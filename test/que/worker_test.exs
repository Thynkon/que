defmodule Que.Test.Worker do
  use ExUnit.Case

  alias Que.Test.Meta.TestWorker
  alias Que.Test.Meta.SuccessWorker
  alias Que.Test.Meta.FailureWorker
  alias Que.Test.Meta.ConcurrentWorker

  test "compilation fails if the worker doesn't export a perform/1 method" do
    assert_raise(Que.Error.InvalidWorker, ~r/must export a perform\/1 method/, fn ->
      defmodule InvalidWorker do
        use Que.Worker
      end
    end)
  end

  test "compilation fails if concurrency value isn't an integer or :infinity" do
    assert_raise(Que.Error.InvalidWorker, ~r/invalid concurrency/, fn ->
      defmodule InvalidWorker2 do
        use Que.Worker, concurrency: :something
        def perform(_), do: nil
      end
    end)
  end

  test "compilation fails if concurrency value isn't a positive integer" do
    assert_raise(Que.Error.InvalidWorker, ~r/invalid concurrency/, fn ->
      defmodule InvalidWorker3 do
        use Que.Worker, concurrency: 0
        def perform(_), do: nil
      end
    end)
  end

  test "#valid? returns true for modules that `use` Que.Worker properly" do
    assert Que.Worker.valid?(TestWorker)
    assert Que.Worker.valid?(SuccessWorker)
    assert Que.Worker.valid?(FailureWorker)
  end

  test "#valid? returns false for all other modules that don't `use` Que.Worker" do
    defmodule NotARealWorker do
      def perform(_args), do: nil
    end

    refute Que.Worker.valid?(Que.Worker)
    refute Que.Worker.valid?(NotARealWorker)
    refute Que.Worker.valid?(NonExistentModule)
  end

  test "#validate! returns :ok for proper workers" do
    assert Que.Worker.validate!(TestWorker) == :ok
    assert Que.Worker.validate!(SuccessWorker) == :ok
    assert Que.Worker.validate!(FailureWorker) == :ok
  end

  test "#validate! raises an error for invalid workers" do
    assert_raise(Que.Error.InvalidWorker, ~r/Invalid Worker/, fn ->
      Que.Worker.validate!(NotARealWorker)
    end)

    assert_raise(Que.Error.InvalidWorker, ~r/Invalid Worker/, fn ->
      Que.Worker.validate!(NonExistentModule)
    end)
  end

  test "#concurrency returns 1 when no options are specified" do
    assert TestWorker.concurrency() == 1
    assert SuccessWorker.concurrency() == 1
    assert FailureWorker.concurrency() == 1
  end

  test "#concurrency returns the concurrency option specified" do
    assert ConcurrentWorker.concurrency() == 4
  end
end
