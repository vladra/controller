require 'test_helper'

describe Lotus::Action::Rack do
  describe '#language' do
    describe 'when no header is given' do
      describe 'and a custom default language is set' do
        before do
          Language::Show.configuration.default_language 'it'
        end

        after do
          Language::Show.configuration.default_language Lotus::Controller.configuration.default_language
        end

        it 'returns the default language' do
          env = Rack::MockRequest.env_for('/')
          _, _, body = Language::Show.new.call(env)

          body.first.must_equal 'it'
        end
      end

      it 'returns the default language' do
        env = Rack::MockRequest.env_for('/')
        _, _, body = Language::Show.new.call(env)

        body.first.must_equal 'en-US'
      end
    end

    describe 'when wildcard header is given' do
      it 'returns the default language' do
        env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_LANGUAGE' => '*')
        _, _, body = Language::Show.new.call(env)

        body.first.must_equal 'en-US'
      end
    end

    it 'returns the preferred language' do
      env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_LANGUAGE' => 'da, en;q=0.6')
      _, _, body = Language::Show.new.call(env)

      body.first.must_equal 'da'
    end

    it 'returns the language when the header has a complex weight' do
      env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.8,es;q=0.6,fr;q=0.4,it;q=0.2,nb;q=0.2,pl;q=0.2')
      _, _, body = Language::Show.new.call(env)

      body.first.must_equal 'en-US'
    end
  end

  describe '#accept_language?' do
    describe 'when no header is given' do
      it 'checks if a language is accepted' do
        env = Rack::MockRequest.env_for('/')
        _, headers, _ = Language::Accept.new.call(env)

        headers['X-Accept-DA'].must_equal 'true'
        headers['X-Accept-EN'].must_equal 'true'
        headers['X-Accept-FR'].must_equal 'true'
      end
    end

    describe 'when wildcard header is given' do
      it 'checks if a language is accepted' do
        env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_LANGUAGE' => '*')
        _, headers, _ = Language::Accept.new.call(env)

        headers['X-Accept-DA'].must_equal 'true'
        headers['X-Accept-EN'].must_equal 'true'
        headers['X-Accept-FR'].must_equal 'true'
      end
    end

    it 'checks if a language is accepted' do
      env = Rack::MockRequest.env_for('/', 'HTTP_ACCEPT_LANGUAGE' => 'da, en;q=0.6')
      _, headers, _ = Language::Accept.new.call(env)

      headers['X-Accept-DA'].must_equal 'true'
      headers['X-Accept-EN'].must_equal 'true'
      headers['X-Accept-FR'].must_equal 'false'
    end
  end
end
