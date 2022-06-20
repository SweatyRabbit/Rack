# frozen_string_literal: true

RSpec.describe Lib::Entities::Router do
  def app
    Rack::Builder.parse_file('./config.ru').first
  end

  let(:name) { Faker::Name.first_name }
  let(:level) { 'Easy' }
  let(:game) { CodebreakerGem::Entities::Game.new(name, level) }
  let(:guess_number) { CodebreakerGem::Entities::Guess::MIN_RANGE.to_s * CodebreakerGem::Entities::Guess::MAX_INPUT }

  describe 'access to pages through menu' do
    context 'when unknown page' do
      before { get '/unknown' }

      it 'receives page 404' do
        expect(last_response).to be_not_found
      end
    end

    context 'when gets to /' do
      before { get Lib::Entities::Router::COMMANDS[:menu] }

      it 'receives menu page' do
        expect(last_response).to be_ok
      end
    end

    context 'when choosed statistic page' do
      before { get Lib::Entities::Router::COMMANDS[:statistics] }

      it 'shows title for statistic page' do
        expect(last_response.body).to include(I18n.t(:top_of_players))
      end
    end

    context 'when choosed rules page' do
      before { get Lib::Entities::Router::COMMANDS[:rules] }

      it 'shows text for rules page' do
        expect(last_response.body).to include(I18n.t(:rules))
      end
    end
  end

  describe 'accessing game page without any actions' do
    context 'when starting the game' do
      before do
        env 'rack.session', game: game
        get Lib::Entities::Router::COMMANDS[:game], player_name: name, level: level
      end

      it 'receives greetings message with users`s name' do
        expect(last_response.body).to include(I18n.t(:hello_message, name: name))
      end
    end
  end

  describe 'some action on game page' do
    context 'when user try to guess number' do
      before do
        game.use_attempt(guess_number)
        env 'rack.session', game: game
        get Lib::Entities::Router::COMMANDS[:guess]
      end

      it 'receives text with number of attempts' do
        expect(last_response.body).to include(game.user_attempts.to_s)
      end
    end

    context 'when user press hint for the first time' do
      before do
        game.use_hint
        env 'rack.session', game: game
        get Lib::Entities::Router::COMMANDS[:hint], game: game
      end

      it 'receives hint number' do
        expect(last_response.body).to include(game.user_hints.to_s)
      end

      it 'receives a field with the number of hints' do
        expect(last_response.body).to include((game.level.hints - 1).to_s)
      end
    end

    context 'when user press hint 2 times' do
      before do
        2.times { game.use_hint }
        env 'rack.session', game: game
        get Lib::Entities::Router::COMMANDS[:hint], game: game
      end

      it 'receives hint number' do
        expect(last_response.body).to include(game.user_hints.to_s)
      end

      it 'receives a field with the number of hints' do
        expect(last_response.body).to include((game.level.hints - 2).to_s)
      end
    end

    context 'when user guessed the code' do
      let(:secret_code) { game.secret_code.join }

      before do
        env 'rack.session', game: game
        post Lib::Entities::Router::COMMANDS[:guess], number: secret_code
      end

      it 'show win message with user`s name on win page' do
        expect(last_response.body).to include(I18n.t(:win_message, name: name))
      end
    end

    context 'when user lose the game' do
      before do
        env 'rack.session', game: game
        15.times { post Lib::Entities::Router::COMMANDS[:guess], number: guess_number }
      end

      it 'show lose message with user`s name' do
        expect(last_response.body).to include(I18n.t(:lose_message, name: name))
      end
    end
  end

  describe 'shows error message' do
    context 'when user gives wrong name' do
      let(:wrong_name) { 'a' * (CodebreakerGem::Entities::User::STRING_MIN_LENGTH - 1) }

      before { post Lib::Entities::Router::COMMANDS[:game], player_name: wrong_name }

      it do
        expect(last_response.body).to include('Name length must be from 3 to 20')
      end
    end

    context 'when user choose wrong difficulty' do
      let(:wrong_difficulty) { 'none' }

      before { post Lib::Entities::Router::COMMANDS[:game], player_name: name, level: wrong_difficulty }

      it do
        expect(last_response.body).to include('Difficulty must be easy, medium or hell')
      end
    end

    context 'when user entered wrong length of guess code' do
      let(:wrong_guess_code) do
        CodebreakerGem::Entities::Guess::MIN_RANGE * (CodebreakerGem::Entities::Guess::MAX_INPUT + 1)
      end

      before do
        env 'rack.session', game: game
        post Lib::Entities::Router::COMMANDS[:guess], number: wrong_guess_code
      end

      it 'error about code lenth' do
        expect(last_response.body).to include('Length must be 4 digits code')
      end
    end
  end
end
