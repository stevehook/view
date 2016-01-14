require 'json'

class HelloWorldView
  include Lotus::View
end

class DisabledLayoutView
  include Lotus::View
  layout false
end

class RenderView
  include Lotus::View
end

class RenderViewMethodOverride
  include Lotus::View

  def select
    'foo'
  end
end

class RenderViewMethodWithArgs
  include Lotus::View

  def planet(name)
    name.to_s
  end
end

class RenderViewMethodWithBlock
  include Lotus::View

  def each_thing
    yield 'thing 1'
    yield 'thing 2'
    yield 'thing 3'
  end
end

class RenderViewWithMissingPartialTemplate
  include Lotus::View
end

class EncodingView
  include Lotus::View
end

class JsonRenderView
  include Lotus::View
  format :json
end

class AppView
  include Lotus::View
  root __dir__ + '/fixtures/templates/app'
  layout :application
end

class AppViewLayout < AppView
  layout false
end

class AppViewRoot < AppView
  root '.'
end

class NestedView
  include Lotus::View
  root __dir__ + '/fixtures/templates'
end


module Organisations
  class Action
    include Lotus::View
    root __dir__ + '/fixtures/templates'
  end

  module OrderTemplates
    class Action
      include Lotus::View
      root __dir__ + '/fixtures/templates'
    end
  end
end

class MissingTemplateView
  include Lotus::View
end

module App
  class View
    include Lotus::View
  end
end

class ApplicationLayout
  include Lotus::Layout

  def title
    'Title:'
  end
end

class GlobalLayout
end

module Articles
  class Index
    include Lotus::View
    layout :application

    def title
      "#{ layout.title } articles"
    end
  end

  class RssIndex < Index
    format :rss
    layout false
  end

  class AtomIndex < RssIndex
    format :atom
    layout false
  end

  class New
    include Lotus::View

    def errors
      {}
    end
  end

  class Create
    include Lotus::View
    template 'articles/new'

    def errors
      {title: 'Title is required'}
    end
  end

  class Show
    include Lotus::View

    def title
      @title ||= article.title.upcase
    end
  end

  class JsonShow < Show
    format :json

    def article
      OpenStruct.new(title: locals[:article].title.reverse)
    end

    def title
      super.downcase
    end
  end
end

class Map
  attr_reader :locations

  def initialize(locations)
    @locations = locations
  end

  def location_names
    @locations.join(', ')
  end

  def names
    location_names
  end
end

class MapPresenter
  include Lotus::Presenter

  def count
    locations.count
  end

  def location_names
    super.upcase
  end

  def escaped_location_names
    @object.location_names
  end

  def raw_location_names
    _raw @object.location_names
  end

  def inspect_object
    _raw @object.inspect
  end
end

module Dashboard
  class Index
    include Lotus::View

    def map
      MapPresenter.new(locals[:map])
    end
  end
end

class IndexView
  include Lotus::View

  layout :application
end

class SongWidget
  attr_reader :song

  def initialize(song)
    @song = song
  end

  def render
    %(<audio src="#{ song.url }">#{ song.title }</audio>)
  end
end

module Songs
  class Show
    include Lotus::View
    format :html

    def render
      _raw SongWidget.new(song).render
    end
  end
end

module Metrics
  class Index
    include Lotus::View

    def render
      %(metrics)
    end
  end
end

module Contacts
  class Show
    include Lotus::View
  end
end

module Nodes
  class Parent
    include Lotus::View
  end
end

module MyCustomModule
end

module MyOtherCustomModule
end

module CardDeck
  View = Lotus::View.duplicate(self) do
    namespace CardDeck
    root __dir__ + '/fixtures/templates/card_deck/app/templates'
    layout :application
    prepare do
      include MyCustomModule
      include MyOtherCustomModule
    end
  end
  View.extend Unloadable

  class ApplicationLayout
    include CardDeck::Layout
  end

  class StandaloneView
    include CardDeck::View
  end

  module Views
    class Standalone
      include CardDeck::View
    end

    module Home
      class Edit
        include CardDeck::View
        template 'home/edit'
      end

      class Index
        include CardDeck::View
      end

      class JsonIndex < Index
        format :json
        layout false
      end

      class RssIndex < Index
        format :rss
        layout false
      end
    end
  end
end

class BrokenLogic
  def run
    raise ArgumentError.new('nope')
  end
end

class LayoutForScopeTest
  def foo
    'x'
  end
end

class ViewForScopeTest
  def bar
    'y'
  end

  def wrong_reference
    unknown_method
  end

  def wrong_method
    "string".unknown
  end

  def raise_error
    BrokenLogic.new.run
  end
end

module Store
  View = Lotus::View.duplicate(self) do
    root __dir__ + '/fixtures/templates/store/templates'
  end
  View.extend Unloadable

  module Helpers
    module AssetTagHelpers
      def javascript_tag(source)
        Lotus::Utils::Escape::SafeString.new %(<script type="text/javascript" src="/javascripts/#{ source }.js" />)
      end
    end
  end

  module Views
    class StoreLayout
      include Store::Layout
      include Store::Helpers::AssetTagHelpers

      def head
        Lotus::Utils::Escape::SafeString.new %(<meta name="lotusrb-version" content="0.3.1">)
      end

      def user_name
        "Joe Blogs"
      end
    end

    module Home
      class Index
        include Store::View
        template 'home/index'
        layout :store
      end

      class JsonIndex < Index
        format :json
      end
    end

    module Products
      class Show
        include Store::View
        layout :store

        def footer
          _raw %(<script src="/javascripts/product-tracking.js"></script>)
        end
      end

      # This view maps to a template that tries to include a partial from the CardDeck app
      class Edit
        include Store::View
      end

      # This view maps to a template that includes a partial from this app
      class Index
        include Store::View
      end
    end
  end
end

Store::View.load!

User = Struct.new(:username)
Book = Struct.new(:title)

class UserXmlSerializer
  def initialize(user)
    @user = user
  end

  def serialize
    @user.to_h.map do |attr, value|
      %(<#{ attr }>#{ value }</#{ attr }>)
    end.join("\n")
  end
end

class UserLayout
  include Lotus::Layout

  def page_title(username)
    "User: #{ username }"
  end
end

module Users
  class Show
    include Lotus::View
    layout :user

    def custom
      %(<script>alert('custom')</script>)
    end

    def username
      user.username
    end

    def raw_username
      _raw user.username
    end

    def book
      _escape(locals[:book])
    end
  end

  class XmlShow < Show
    format :xml

    def render
      UserXmlSerializer.new(user).serialize
    end
  end

  class JsonShow < Show
    format :json

    def render
      _raw JSON.generate(user.to_h)
    end
  end

  class Extra
    include Lotus::View

    def username
      user.username
    end
  end
end
