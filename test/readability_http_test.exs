defmodule ReadabilityHttpTest do
  use ExUnit.Case
  import Mock
  require IEx

  test "text/plain response is parsed as plain text" do
    url = "https://tools.ietf.org/rfc/rfc2616.txt"
    response = %HTTPoison.Response{
      status_code: 200,
      headers: [{"Content-Type", "text/plain"}],
      body: TestHelper.read_fixture("rfc2616.txt")}
    
    with_mock HTTPoison, [get!: fn(_url, _headers, _opts) -> response end] do
      %Readability.Summary{article_text: text} = Readability.summarize(url)

      assert text =~ ~r/3 Protocol Parameters/
    end
  end

  test "*ml responses are parsed as markup" do
    url = "https://news.bbc.co.uk/test.html"
    content = TestHelper.read_fixture("bbc.html")
    mimes = ["text/html", "application/xml", "application/xhtml+xml"]

    mimes |> Enum.each(fn(mime) ->
      response = %HTTPoison.Response{
        status_code: 200,
        headers: [{"Content-Type", mime}],
        body: content}
      
      with_mock HTTPoison, [get!: fn(_url, _headers, _opts) -> response end] do
        %Readability.Summary{article_html: html} = Readability.summarize(url)

        assert html =~ ~r/connected computing devices\".<\/p><\/div><\/div>$/
      end
    end)
  end
end
