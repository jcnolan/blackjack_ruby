class Card

  # Card comprises a single card

  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @value = @value
  end

  def say_card
    "#{@rank}#{@suit}"
  end

  def get_value

    case @rank
    when "A"
      [11, 1]
    when "2".."9"
      @rank.to_i
    else
      10
    end

  end
end

class Deck

  # Deck is basically an array of 52 cards
  # note - suits are not needed in blackjack but added into class in case of extension into other games, stats purposes

  SUITS = [{id: "♣", desc: "club"}, {id: "♦", desc: "diamond"}, {id: "♥", desc: "hearts"}, {id: "♠", desc: "spades"}]
  RANKS = [
      # *("2".."9"),
      {id: "2", value: 2}, {id: "3", value: 3}, {id: "4", value: 4}, {id: "5", value: 5},
      {id: "6", value: 6}, {id: "7", value: 7}, {id: "8", value: 8}, {id: "9", value: 9}, {id: "10", value: 10},
      {id: "J", value: 10}, {id: "Q", value: 10}, {id: "K", value: 10}, {id: "A", value: [11, 1]}
  ]

  attr_reader :cards

  def initialize

    @cards = Array.new

    # Fill deck with cards in sequential order

    SUITS.each do |suit|
      RANKS.each do |rank|
        @cards << Card.new(rank[:id], suit[:id])
      end
    end

  end

  def get_ranks
    # todo - perhaps a better accessor for constants is available
    RANKS
  end

end

class Shoe

  # SHOE is an array of cards sourced from multiple decks.  Contains the ability to deal cards and
  # track statistics on likelihood of 21 being reached for a given hand.  The SHOE is perpetual in
  # it's ability to deal cards - will refill on-the-fly if needed

  DEFAULT_CHARLIE_VAL = 3 # todo - is this the best location for this? Might be better located elsewhere
  attr_accessor :charlie_val

  def initialize(num_decks)

    @num_decks = num_decks
    @cards_used = {}
    @cards = Array.new
    @charlie_val = DEFAULT_CHARLIE_VAL

    fill_shoe

  end

  def fill_shoe

    puts "Shuffling the shoe - SHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLE"

    Deck.new.get_ranks.each do |rank|
      id = rank[:id]
      @cards_used[id] = 0
    end

    @cards = Array.new

    (1..@num_decks).each { |_|
      deck = Deck.new
      deck.cards.each do |card|
        @cards << card
      end
    }
    @cards.shuffle!

  end

  def deal_card

    # Get card off top of shoe and log it

    card = @cards.pop
    @cards_used[card.rank] += 1

    # If the shoe is empty, refill it automatically

    if @cards.count == 0
      fill_shoe
    end

    card

  end

  def count_possible_blackjacks_for_value(value)

    # Statistical function - Will return the number of cards in the current shoe that will result in a blackjack for given value

    # Determine value for blackjack

    blackjack_val = 21 - value
    cards_in_shoe = 4 * @num_decks

    # Count # of cards remaining in shoe for that value

    if blackjack_val > 11
      0
    elsif blackjack_val == 1 || blackjack_val == 11
      cards_in_shoe - @cards_used["A"]
    elsif blackjack_val == 10
      %w(10 J Q K).map { |key| cards_in_shoe - @cards_used[key.to_s] }.reduce(:+)
    else
      cards_in_shoe - @cards_used[blackjack_val.to_s]
    end

  end

  def is_bust_possible(hand)

  # Statistical function - Returns false if it's not possible to bust given hand with dealing of a new card

  values = hand.get_values_from_hand
    if values.count > 0
      min_value = values.min
      num_busts = count_possible_busts_for_value(min_value)
    else
      num_busts = 0
    end

    num_busts > 0

  end

  def count_possible_busts_for_value(value)

    # Statistical function - Will return the number of cards in the current shoe that will result in a bust for given value

    # Determine value of card that will bust the hand

    bust_val = 21 - value + 1

    cards_in_shoe = 4 * @num_decks

    # Count # of cards (left) in shoe for that value

    if bust_val > 10 # can't bust

      0

    elsif bust_val == 1 # Ace only

      cards_in_shoe - @cards_used["A"]

    else # {bust_val}..K will bust

      num_matches = %w(10 J Q K).map { |key| cards_in_shoe - @cards_used[key.to_s] }.reduce(:+)

      while bust_val < 10 do
        num_matches += cards_in_shoe - @cards_used[bust_val.to_s]
        #      puts "Bust vals (+#{bust_val}): #{num_matches}"
        bust_val += 1
      end

      num_matches

    end
  end

  def say_odds(hand, player_name)

  # Statistical function - Reports various odds on given hand with current shoe state

  values = hand.get_values_from_hand
    min_value = values.min
    num_cards_in_shoe = @cards.count

    # Check for possible blackjacks

    num_blackjacks = 0
    values.each do |value|
      wins = count_possible_blackjacks_for_value(value)
      num_blackjacks += wins
    end

    # Odds of 21 = wins/cards in shoe

    odds_of_blackjack = (num_blackjacks.to_f / num_cards_in_shoe.to_f) * 100.0
    puts "#{player_name} - Odds of blackjack: #{odds_of_blackjack}%"

    # Check for possible busts

    num_busts = count_possible_busts_for_value(min_value)

    # Check for possible charlie match

    if hand.num_cards + 1 == hand.charlie_val

      puts "num_cards_in_shoe: #{num_cards_in_shoe}"
      puts "num_blackjacks: #{num_blackjacks}"
      puts "num_busts: #{num_busts}"

      num_charlies = num_cards_in_shoe - num_blackjacks - num_busts

      odds_of_charlie = (num_charlies.to_f / num_cards_in_shoe.to_f) * 100.0
      puts "#{player_name} - Odds of charlie: #{odds_of_charlie}%"

    end

    # Odds of bust = busts/cards in shoe

    odds_of_bust = (num_busts.to_f / num_cards_in_shoe.to_f) * 100.0
    puts "#{player_name} - Odds of busting: #{odds_of_bust}%"

    # Note - Other stats are possible to calculate based on state of game, but this is a good amount to start

  end
end

class Hand

  # Hand consists of an array of cards - used to track a players hand and is used in determining odds of hitting 21

  attr_accessor :bet
  attr_accessor :charlie_val
  attr_accessor :stay
  attr_accessor :show_odds
  attr_accessor :test_mode

  attr_reader :cards
  attr_reader :player_id

  def initialize(player, charlie_val = 999)
    @cards = Array.new
    @charlie_val = charlie_val
    @stay = false
    @show_odds = player.show_odds
    @test_mode = player.test_mode
    @player_id = player.id
    @bet = 0
  end

  def deal_hand(shoe)
    add_card(shoe.deal_card)
    add_card(shoe.deal_card)
  end

  def clone_hand_for_split

    # Makes copy of given hand with NO cards
    # todo - could probably just be done with a self.dup and clear of cards

    player = Player.new(@player_id)
    player.show_odds = @show_odds
    player.test_mode = @test_mode

    hand = Hand.new(player, @charlie_val)
    hand.bet = @bet
    hand
  end

  def split_hand(shoe)

    hand1 = clone_hand_for_split
    hand2 = clone_hand_for_split

    hand1.add_card(@cards[0])
    hand2.add_card(@cards[1])

    hand1.add_card(shoe.deal_card)
    hand2.add_card(shoe.deal_card)

    [hand1, hand2]

  end

  def say_cards(player_name = nil, is_dealer = false)

    if player_name == nil
      player_name = "Player"
    end

    cards = Array.new

    print "#{player_name} hand contains #{@cards.count} cards: "

    @cards.each do |card|
      cards << card.say_card
    end

    if is_dealer
      cards[0] = "???"
    end

    puts cards.join(",")

  end

  def get_values_from_hand
    # todo - Wanted signature overload for "get_values(cards, values)"
    # todo - This should be called "get_values" (w/no params) but didn't find way to do that yet...
    get_values(@cards, [0])
  end

  def get_values(cards, values)

    # Returns array of possible VALID hand values, sorted smallest to largest.
    # Values > 21 are not returned, therefore if it returns an empty array then hand is invalid

    cards = cards.clone

    while cards.count > 0 do

      card = cards.pop
      card_value = card.get_value

      if !card_value.kind_of?(Array)
        values = values.map { |num| num + card_value }
      else

        # todo - Line below should work fine but does not... using loop below instead for now

        #   newValues = values.map {|toAdd| card_value.map {|num| num+toAdd}}

        new_values = Array.new
        card_value.each do |val|
          new_values += values.map { |num| num + val }
        end
        values = new_values.uniq

      end
    end

    values.reject! { |num| num > 21 }
    values.sort

  end

  def say_value(player_name = nil)

    if player_name == nil
      player_name = "Player"
    end

    values = get_values(@cards, [0])
    v_literal = values.count == 1 ? "value" : "values"
    puts "#{player_name} hand #{v_literal}: #{values.join(",")}"

  end

  def is_viable

    # Determines if hand is still playable.  For purposes here 21 is NOT viable, since it's a winning hand

    values = get_values(@cards, [0])
    if values.include? 21
      viable_vals = Array.new # Note - 21 is not viable, since it's a winning hand
    elsif @cards.count >= @charlie_val
      viable_vals = Array.new # Note - Hand is winning based on charlie card count
    else
      viable_vals = values.select { |val| val < 21 }
    end

    viable_vals.count > 0

  end

  # Helper methods to make game code more clean and readable

  def add_card(card)
    @cards << card
  end

  def num_cards
    @cards.count
  end

  def is_stayed_or_not_viable
    stay || !is_viable
  end

  def is_viable_or_stayed
    is_viable || stay
  end

  def get_max_value_from_hand
    get_values_from_hand.max
  end

end

class Player

  # Contains basic player data and hooks for player interaction

  attr_accessor :hand
  attr_accessor :show_odds
  attr_accessor :test_mode
  attr_accessor :cash
  attr_reader :name
  attr_reader :id

  def initialize(player_id)

    @id           = player_id
    @name         = "Player #{player_id}" # todo - Just using default value for now, could add real name later
    @cash         = 1000.0
    @show_odds    = false # Note - when set to true will show odds of blackjack / bust while playint
    @test_mode    = false # Note - turn on to show additional debugging information while playing
    @player_type  = "manual" # todo - In future versions can be set for [manual, auto, AI] to allow for auto play
    @hand         = nil

  end

  # Note - player contains basic player data but has also been extended to include all choice points by player to allow
  # hooks for automated / AI based play in subsequent versions of the code baseed on "@player_type" which is currently unused

  def player_must_choose_bet

    bet_val = -1

    while true

      puts "#{@name}, what is your bet? "
      bet_val_str = gets.chomp
      bet_val = bet_val_str.to_i

      if bet_val <= 0 || bet_val > @cash
        puts "Bets must be > 0 and < #{@cash}"
      else
        break
      end
    end

    bet_val

  end

  def player_must_choose_hit_or_stay(hand)

    action = ""

    until %w(d o t h s).include? action
      double_down_str = hand.cards.count == 2 ? ", (d)ouble" : ""
      puts "#{@name} do you want to (h)it, (s)tay#{double_down_str}?"
      action = gets.chomp
    end

    action

  end

  def player_must_choose_on_split(card_rank)

    puts "#{@name} you got two #{card_rank}s on deal, would you like to split? (y/n)"

    if gets.chomp == "y"
      true
    else
      false
    end

  end

end

############################## Main Game Code Starts Here ###############################

def print_blank_line
  puts
end

DEALER_ID = -1
DEALER_NAME = "Dealer"
ALLOW_RECURSED_SPLITS = false

def play_hand(shoe, players)

  # Helper functions for play_hand()

  def player_play_is_still_active(player_hands, dealer_hand)
    (player_hands.map { |player_hand| !player_hand.is_stayed_or_not_viable }.any? && dealer_hand.is_viable)
  end

  def player_play_is_not_active_but_dealer_below_17(player_hands, dealer_hand)
    (player_hands.map { |player_hand| player_hand.is_viable_or_stayed }.any? && dealer_hand.is_viable && dealer_hand.get_max_value_from_hand < 17)
  end

  def check_for_blackjack(player_hand, player)
    # basically just a no-op to tell player they hit blackjack and will be ignored for the rest of the hand until results are displayed
    max_value = player_hand.get_max_value_from_hand

    if max_value == 21
      puts "#{player.name} - BLACKJACK!"
    elsif  max_value == nil
      puts "#{player.name} - Busted out!"
    end
  end

  def check_for_split(hand, player, allow_split_on_ace = false)

    if hand.cards.map { |card| card.rank }.uniq.size == 1

      card_rank = hand.cards[0].rank

      if card_rank != "A" || allow_split_on_ace
         player.player_must_choose_on_split(card_rank)
      else
        false
      end

    end

  end

  def dump_hands(hands, players)
    hands.each { |player_hand|
      player = players[player_hand.player_id - 1]
      player_hand.say_cards(player.name)
    }
  end

  def dump_dealer_hand(hands, dealer_hand, hide_hole_card=true)

    if hands.map { |player_hand| !player_hand.test_mode }.all?
      dealer_hand.say_cards(DEALER_NAME, hide_hole_card)
    else
      # note - if anyone is in test mode the dealer cards are shown to all - hmmm...
      dealer_hand.say_cards(DEALER_NAME)
      dealer_hand.say_value(DEALER_NAME)
    end
  end

  ###### Main Code Starts here #######

  player_hands = Array.new
  bets = Array.new

  # Collect bets from viable players

  players.each { |player|
    if player.cash > 0
      bets[player.id] = player.player_must_choose_bet
    end
  }

  # Deal hands and check for splits - note, separate identical loop to allow for bet collection to occur before possible blackjacks

  players.each { |player|

    if player.cash > 0

      player_hand = Hand.new(player, shoe.charlie_val)
      player_hand.bet = bets[player.id]
      player_hand.deal_hand(shoe)
      player_hands << player_hand

      check_for_blackjack(player_hand, player)

    end
  }

  # Initial hands are dealt, now check for splits - rules taken from www.casinocenter.com

  # Split. When a player’s first two cards are of equal point value, he may separate them into two hands with each card
  # being the first card of a new hand. To split, the player must make another wager of equal value to the initial wager
  # for the second hand. In cases where another identical point valued card is dealt following the split, re-splitting
  # may be allowed. (Re-splitting aces is often an exception.) When allowed, players may also double down after splitting.

  splits_found = true
  player_hands_checked = Array.new
  split_check_count = 0

  while splits_found && (split_check_count == 0 || ALLOW_RECURSED_SPLITS)

    splits_found = false

    player_hands.each { |player_hand|

      if !check_for_split(player_hand, players[player_hand.player_id - 1], split_check_count > 0)
        player_hands_checked << player_hand
      else
        player_hands_checked += player_hand.split_hand(shoe)
        splits_found = true
      end

    }

    player_hands = player_hands_checked
    split_check_count += 1

  end

  dump_hands(player_hands, players)

  # initial deal is all handled, now deal dealer hand

  dealer_hand = Hand.new(Player.new(DEALER_ID))
  dealer_hand.deal_hand(shoe)

  dump_dealer_hand(player_hands, dealer_hand)

  print_blank_line

  # While there are any viable hands or non-stayed hands and the dealer is viable OR all hands are stayed or not viable and dealer can still hit...

  while player_play_is_still_active(player_hands, dealer_hand) || player_play_is_not_active_but_dealer_below_17(player_hands, dealer_hand)

    # process all player hands

    player_hands.each { |player_hand|

      unless player_hand.is_stayed_or_not_viable

        # For each player hand - process that hand

        player = players[player_hand.player_id - 1]

        # Process play for this round for this player hand

        player_round_complete = false

        while player_round_complete == false do

          player_round_complete = true # Assume player round will be complete after this ifelse

          if player_hand.stay != true

            player_hand.say_cards(player.name)
            player_hand.say_value(player.name) if player_hand.test_mode
            shoe.say_odds(player_hand, player.name) if player_hand.show_odds

            print_blank_line

            action = player.player_must_choose_hit_or_stay(player_hand)

            if action == "d" && player_hand.cards.count == 2
              puts "#{player.name} bet has been doubled to #{player_hand.bet *= 2}"
              action = "h"
            end

            if action == "h"

              puts "You chose to hit, here's your new hand"
              player_hand.add_card(shoe.deal_card)
              player_hand.say_cards(player.name)
              player_hand.say_value(player.name) if player_hand.test_mode

              check_for_blackjack(player_hand, player)

            elsif action == "o"

              player_hand.show_odds = !player_hand.show_odds
              players[player_hand.player_id - 1].show_odds = player_hand.show_odds
              puts "Odds display turned #{ player_hand.show_odds ? "on" : "off"  } for #{player.name}"
              player_round_complete = false # loop back for more...

            elsif action == "t"

              player_hand.test_mode = !player_hand.test_mode
              players[player_hand.player_id - 1].test_mode = player_hand.test_mode
              puts "Test mode turned #{ player_hand.test_mode ? "on" : "off"  } for #{player.name}"
              player_round_complete = false # loop back for more...

            elsif action == "s"

              puts "You chose to stay"
              player_hand.stay = true

            else
              player_round_complete = false # invalid keypress, loop back around and try again
            end

            print_blank_line

          end
        end
      end
    }

    # Now that player hands are processed, handle the dealer

    puts "===== DEALERDEALERDEALERDEALERDEALERDEALERDEALERDEALER ====="

    if player_play_is_not_active_but_dealer_below_17(player_hands, dealer_hand)
      dealer_hand.add_card(shoe.deal_card)
      dump_dealer_hand(player_hands, dealer_hand)
    end

  end

  print_blank_line
  puts "=== HAND COMPLETED ==="

  dump_dealer_hand(player_hands, dealer_hand, false)

  # Note: win/play rules taken from https://www.casinocenter.com/rules-strategy-blackjack

  player_hands.each do |player_hand|

    player = players[player_hand.player_id - 1]

    print "#{player.name} - "

    if dealer_hand.get_values_from_hand.count == 0 && player_hand.get_values_from_hand.count == 0
      puts "Both dealer and player busted - dealer wins"
      player.cash -= player_hand.bet
    elsif dealer_hand.get_max_value_from_hand == player_hand.get_max_value_from_hand
      puts "PUSH - money is returned"
    elsif dealer_hand.get_values_from_hand.include? 21
      puts "You lose! - dealer hit blackjack"
      player.cash -= player_hand.bet
    elsif dealer_hand.is_viable == false
      puts "You win! - dealer busted out"
      player.cash += player_hand.bet
    elsif player_hand.get_values_from_hand.count == 0
      puts "You busted - womp, womp"
      player.cash -= player_hand.bet
    elsif player_hand.get_values_from_hand.include? 21
      puts "You win! BLACKJACK!"
      player.cash += player_hand.bet * 1.5
    elsif player_hand.num_cards >= player_hand.charlie_val
      puts "You win! #{player_hand.charlie_val} CARD CHARLIE!"
      player.cash += player_hand.bet * 2
    else
      dealer_val = dealer_hand.get_max_value_from_hand
      player_val = player_hand.get_max_value_from_hand

      print "dealer shows #{dealer_val}, player shows #{player_val} - "
      if dealer_val >= player_val
        print "DEALER WINS!\n"
        player.cash -= player_hand.bet
      else
        print "PLAYER WINS!\n"
        player.cash += player_hand.bet
      end
    end
  end

  players.each do |player|
    puts "#{player.name} balance $#{player.cash}"
  end

  print_blank_line

end

puts "Greetings! Welcome to Blackjack!"

num_players = 0

until num_players >= 1 && num_players < 7

  print "How many players? (1-4) "
  num_players = gets.chomp.to_i
end

num_decks = 0
num_deck_options = [1, 2, 4, 6, 8]
until num_deck_options.include? num_decks

  print "And how many decks in the shoe? (#{num_deck_options.join(",")}) "
  num_decks = gets.chomp.to_i
end

print_blank_line

shoe = Shoe.new(num_decks)

players = Array.new

(1..num_players).each { |player_id|
  players[player_id - 1] = Player.new(player_id)
}

print_blank_line

while true

  play_hand(shoe, players)

  puts "Play again? (y)es, (n)o, (r)eset shoe and play?"
  action = gets.chomp
  if action == "y"
  elsif action == "r"
    shoe = Shoe.new(num_decks)
  elsif action == "n" || action == "q"
    print_blank_line
    puts "Okie dokie... Thanks for playing!"
    break
  end

end