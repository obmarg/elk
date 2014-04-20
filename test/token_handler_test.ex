
defmodule TokenHandlerFacts do
  use Amrita.Sweet

  describe "AuthHandler.get_token" do
    # TODO: Figure out how to actually test this stuff.
    #       Dependency injection adds un-neccesary complication to code
    #       Mocking doesn't seem to work

    it "requests token on first request" do
    end

    it "uses cache on second request" do
    end

    it "re-requests token on expiry" do
    end

  end
end
