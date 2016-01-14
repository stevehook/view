require 'test_helper'

describe 'Framework configuration' do
  before do
    # Store::View.configuration.root(__dir__ + '/../fixtures/templates/store/templates')
    # CardDeck::View.configuration.root(__dir__ + '/../fixtures/templates/card_deck/app/templates')
    Lotus::View.load!
    Store::View.load!
    CardDeck::View.load!
  end

  it "Store application can render a view containing one of it's own partials" do
    rendered = Store::Views::Products::Index.render(format: :html)
    rendered.must_include 'index partial'
  end

  it "CardDeck application can render a view containing one of it's own partials" do
    rendered = CardDeck::Views::Home::Edit.render(format: :html)
    rendered.must_include 'edit partial'
  end

  it "Store application cannot render a view containing a partial from CardDeck application" do
    -> {
      Store::Views::Products::Edit.render(format: :html)
    }.must_raise(Lotus::View::MissingTemplateError)
  end
end
