
defmodule TokenHandlerFacts do
  use Amrita.Sweet

  describe "AuthHandler.get_token" do
    # TODO: Figure out how to actually test this stuff.
    #       Dependency injection adds un-neccesary complication to code
    #       Mocking doesn't seem to work

    it "requests token on first request" do
      response = HTTPotion.Response[body: "", status_code: 200, headers: {}]
      provided [HTTPotion.post |> response] do
        Elk.TokenHandler.handle_call(:get_token, nil, nil) |> { :reply, _, _ }
      end
    end

    it "uses cache on second request" do
      assert false == true
    end

    it "re-requests token on expiry" do
    end

    it "errors on non 200" do

    end

  end
end
