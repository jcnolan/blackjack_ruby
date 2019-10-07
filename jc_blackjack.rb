class Card

  # Card comprises a single card

  attr_reader :rank, :suit

  def initialize rank, suit
    @rank = rank
    @suit = suit
    @value = @value
  end

  def say_card
    return "#{@rank}#{@suit}"
  end

  def get_value

    case @rank
    when "A"
      foo = [11, 1]
    when "2".."9"
      foo = @rank.to_i
    else
      foo = 10
    end
    return foo
  end

  def say_value

    print "rank = #{@rank}\n"

    foo = get_value

    print "value = #{@foo}\n"

  end

end

class Deck

  # Deck is basically an array of 52 cards - may become a simple stub though it also defines SUITS / DECKS
  # May end up removing or tearing back since it's really the "SHOE" we are interested in

  # note - suits are not needed in blackjack but added into class in case of extension into other games
  SUITS = [{id: "♣", desc: "club"}, {id: "♦", desc: "diamond"}, {id: "♥", desc: "hearts"}, {id: "♠", desc: "spades"}]
  # todo - tighten up this initialization to make it denser
  RANKS = [
      # *("2".."9"),
      {id: "2", value: 2}, {id: "3", value: 3}, {id: "4", value: 4}, {id: "5", value: 5},
      {id: "6", value: 6}, {id: "7", value: 7}, {id: "8", value: 8}, {id: "9", value: 9}, {id: "10", value: 10},
      {id: "J", value: 10}, {id: "Q", value: 10}, {id: "K", value: 10}, {id: "A", value: [11, 1]}
  ]

  attr_reader :cards

  def initialize

    @cards = []

    # Fill deck with cards in sequential order

    SUITS.each do |suit|
      RANKS.each do |rank|
        @cards << Card.new(rank[:id], suit[:id])
      end
    end

    # Shuffle the deck

    @cards.shuffle!

  end

  def say_suits
    SUITS.each do |suit|
      puts "'#{suit[:desc]}' (#{suit[:id]})"
    end
  end

  def say_values
    RANKS.each do |rank|
      toprint = rank[:value]
      if toprint.kind_of?(Array)
        toprint = toprint.join(",")
      end
      puts "'#{toprint}' (#{rank[:id]})"
    end
  end

  def say_cards

    # todo - this is just a debug (and is an artfact at this point - unused)

    cardArr = []
    print "Deck contains #{@cards.count()} cards\n"
    @cards.each do |card|
      cardArr << card.say_card
    end
    print cardArr.join(",") + "\n"
  end

end

class Shoe

  # SHOE is an array of cards sourced from multiple decks.  Contains the ability to deal cards and
  # track statistics on likelihood of 21 being reached for a given hand.  The SHOE is perpetual in
  # it's ability to deal cards - will refill on-the-fly if needed

  RANKS = [
      # *("2".."9"),
      {id: "2", value: 2}, {id: "3", value: 3}, {id: "4", value: 4}, {id: "5", value: 5},
      {id: "6", value: 6}, {id: "7", value: 7}, {id: "8", value: 8}, {id: "9", value: 9}, {id: "10", value: 10},
      {id: "J", value: 10}, {id: "Q", value: 10}, {id: "K", value: 10}, {id: "A", value: [11, 1]}
  ]

  DEFAULT_CHARLIE_VAL = 5

  attr_accessor :charlie_val

  def initialize num_decks

    @num_decks = num_decks
    @cards_used = {}
    @cards = []
    @charlie_val = DEFAULT_CHARLIE_VAL

    fill_shoe
  end

  def fill_shoe

    puts "Shuffling the shoe - SHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLESHUFFLE"

    RANKS.each do |rank|
      id = rank[:id]
      @cards_used[id] = 0
    end

    @cards = []

    for _ in 1..@num_decks do
      deck = Deck.new
      deck.cards.each do |card|
        @cards << card
      end
    end
    @cards.shuffle!()

  end

  def deal_card

    # get card off top of shoe and log it

    card = @cards.pop
    @cards_used[card.rank] += 1

    # if the shoe is empty, refill it automatically

    if @cards.count == 0
      fill_shoe
    end

    # return popped card

    return card
    # card =
  end

  def say_cards

    # todo - this is just a debug (and is an artfact at this point - unused)

    cardArr = []
    print "Shoe contains #{@cards.count()} cards\n"
    @cards.each do |card|
      cardArr << card.say_card
    end
    print cardArr.join(",") + "\n"
  end

  def say_cards_used

    # debugging function

    vals_to_print = []

    @cards_used.each do |rank, num_used|
      if num_used > 0
        vals_to_print << "#{rank}=#{num_used}"
      end
    end

    if vals_to_print.count() > 0
      puts vals_to_print.join(",")
    else
      puts "No cards used"
    end

    puts

  end

  def get_blackjacks(value)

    # determine value for blackjack

    blackjack_val = 21 - value
    cards_in_shoe = 4 * @num_decks

    # count # of cards (left) in shoe for that value

    # puts "blackjack val needed: #{blackjack_val}\n\n"

    if blackjack_val > 11
      num_matches = 0
    elsif blackjack_val == 1 || blackjack_val == 11
      num_matches = cards_in_shoe - @cards_used["A"]
    elsif blackjack_val == 10
      num_matches = ["10", "J", "Q", "K"].map { |key| cards_in_shoe - @cards_used[key.to_s] }.reduce(:+)
    else
      idx = blackjack_val.to_s
      num_matches = cards_in_shoe - @cards_used[blackjack_val.to_s]
    end

    #  puts "num_blackjack_matches: #{num_matches}"

    # return that number

    return num_matches

  end

  def is_bust_possible(hand)

    values = hand.get_valuez
    if values.count > 0
      min_value = values.min
      num_busts = get_busts(min_value)
    else
      num_busts = 0
    end

    return num_busts > 0

  end

  def get_busts(value)

    # Determine value of card that will bust the hand

    bust_val = 21 - value + 1

    cards_in_shoe = 4 * @num_decks

    # count # of cards (left) in shoe for that value

    #    puts "bust val needed: #{bust_val} or larger\n\n"

    if bust_val > 10 # can't bust

      num_matches = 0

    elsif bust_val == 1 # Ace only

      num_matches = cards_in_shoe - @cards_used["A"]

    else # {bust_val}..K will bust

      num_matches = ["10", "J", "Q", "K"].map { |key| cards_in_shoe - @cards_used[key.to_s] }.reduce(:+)

#      puts "Facecard/10s bust vals: #{num_matches}"

      while bust_val < 10 do
        num_matches += cards_in_shoe - @cards_used[bust_val.to_s]
        #      puts "Bust vals (+#{bust_val}): #{num_matches}"
        bust_val += 1
      end
    end

    #    puts "num_bust_matches: #{num_matches}"

    # return that number

    return num_matches

  end

  def say_odds(hand, player_name)

    #  puts "Checking Odds:"
    #  say_cards_used

    values = hand.get_valuez
    min_value = values.min
    num_cards_in_shoe = @cards.count

    # check for possible blackjacks

    num_blackjacks = 0
    values.each do |value|
      wins = get_blackjacks(value)
      #   puts "wins: #{wins}"
      num_blackjacks += wins
    end

    # Odds of 21 = wins/cards in shoe

    #   puts "Cards in Shoe: #{num_cards_in_shoe}"
    odds_of_blackjack = (num_blackjacks.to_f / num_cards_in_shoe.to_f) * 100.0
    puts "#{player_name} - Odds of blackjack: #{odds_of_blackjack}%"

    # check for possible busts

    num_busts = get_busts(min_value)

    # check for possible charlie match

    if hand.num_cards + 1 == hand.charlie_val

      num_charlies = num_cards_in_shoe - num_blackjacks - num_busts

      #print stats on charlies
      odds_of_charlie = (num_charlies.to_f / num_cards_in_shoe.to_f) * 100.0
      puts "#{player_name} - Odds of charlie: #{odds_of_charlie}%"

    end

    # Odds of bust = busts/cards in shoe

    odds_of_bust = (num_busts.to_f / num_cards_in_shoe.to_f) * 100.0
    puts "#{player_name} - Odds of busting: #{odds_of_bust}%"

    # Slightly harder one is odds of beating dealer w/out busting (?)

  end

end

class Hand

  # Hand consists of an array of cards - used to track a players hand and is used in determining odds of hitting 21

  attr_accessor :bet
  attr_accessor :charlie_val
  attr_accessor :stay
  attr_accessor :show_odds

  attr_reader :cards
  attr_reader :player_id

  # @player_id
  # @bet - amount bet on play
  # @show_odds - inited on hand creation but also can be set internally while playing

  def initialize(player_id, show_odds = false, charlie_val = 999)
    @cards = []
    @charlie_val = charlie_val
    @stay = false
    @show_odds = show_odds
    @player_id = player_id
    @bet = 0
  end

  def deal_hand(shoe)
    add_card(shoe.deal_card)
    add_card(shoe.deal_card)
  end

  def clone_hand
    # makes copy of given hand with NO cards\
    hand = Hand.new(@player_id, @show_odds, @charlie_val)
    hand.bet = @bet
    return hand
  end

  def split_hand(shoe)

    hand1 = clone_hand
    hand2 = clone_hand

    hand1.add_card(@cards[0])
    hand2.add_card(@cards[1])

    hand1.add_card(shoe.deal_card)
    hand2.add_card(shoe.deal_card)

    return [hand1, hand2]

  end

  def add_card(card)
    @cards << card
  end

  def num_cards()
    return @cards.count
  end

  def say_cards(player_name = nil, is_dealer = false)

    if player_name == nil
      player_name = "Player"
    end

    cardArr = []
    print "#{player_name} hand contains #{@cards.count()} cards: "

    @cards.each do |card|
      cardArr << card.say_card
    end

    if is_dealer == true
      cardArr[0] = "???"
    end

    print cardArr.join(",") + "\n"
    #say_value
  end

  def get_valuez
    # todo - signature overload?
    return get_values(@cards, [0])
  end

  def get_values(cards, values)

##   puts "get_values - cards in: #{cards}"

    cards = cards.clone # todo - is this the right way to handle this? Need destructive, internal appraoch

    while cards.count() > 0 do

      card = cards.pop
      card_value = card.get_value

      if !card_value.kind_of?(Array)
        values = values.map { |num| num + card_value }
      else

        # todo - Line below should work fine but does not... using loop below instead
        #   newValues = values.map {|toAdd| card_value.map {|num| num+toAdd}}

        newValues = []
        card_value.each do |val|
          newValues += values.map { |num| num + val }
        end
        values = newValues.uniq

      end
    end

    values.reject! { |num| num > 21 }

    # puts "reg_values returning: #{values}"

    return values.sort

  end

  def say_value(player_name = nil)

    if player_name == nil
      player_name = "Player"
    end

    values = get_values(@cards, [0])

    foo = values.join(",")
    vStr = values.count() == 1 ? "value" : "values"

    print "#{player_name} hand #{vStr}: #{foo}\n\n"
  end

  def is_viable

    # Determines if hand is still playable.  For purposes here 21 is NOT viable, since it's a winning hand

    # puts "In is_viable, charlie: #{@charlie}"

    values = get_values(@cards, [0])
    if values.include? 21
      viable_vals = [] # Note - 21 is not viable, since it's a winning hand
    elsif @cards.count >= @charlie_val
      viable_vals = [] # Note - Hand is winning based on charlie card count
    else
      viable_vals = values.select { |val| val < 21 }
    end

    return viable_vals.count > 0

  end

  def is_stayed_or_not_viable
    return stay || !is_viable
  end

  def is_viable_or_stayed
    return is_viable || stay
  end

end

class Player

  attr_accessor :hand
  attr_accessor :show_odds
  attr_accessor :cash
  attr_reader :name
  attr_reader :id

  def initialize(player_id)

    @id = player_id
    @name = "Player #{player_id}" # todo - Just using default value for now, could add real name
    @cash = 1000.0
    @show_odds = false # note - when set to true will show odds of blackjack / bust while playint
    @play_type = "manual" # todo - can be set for [manual, auto, AI] to allow for auto play
    @hand = nil

  end

end

##############################

def print_blank_line
  puts
end

DEALER_ID = -1
DEALER_NAME = "Dealer"
ALLOW_RECURSED_SPLITS = false

def play_hand(shoe, players)

  def player_play_is_still_active(player_hands, dealer_hand)
    return (player_hands.map { |player_hand| !player_hand.is_stayed_or_not_viable }.any? && dealer_hand.is_viable)
  end

  def player_play_is_not_active_but_dealer_below_17(player_hands, dealer_hand)
    return (player_hands.map { |player_hand| player_hand.is_viable_or_stayed }.any? && dealer_hand.is_viable && dealer_hand.get_valuez.max < 17)
  end

  def check_for_blackjack(player_hand, player)
    # basically just a noop to tell player they hit blackjack and will be ignored for the rest of the hand until results are displayed
    if player_hand.get_valuez.max() == 21
      puts "#{player.name} - BLACKJACK!"
    end
  end

  def check_for_split(hand, player, allow_split_on_ace = false)

    ret_val = false # always assume failure on function returns, generally

    if hand.cards.map { |card| card.rank }.uniq.size == 1

      card_rank = hand.cards[0].rank

      if card_rank != "A" || allow_split_on_ace

        puts "#{player.name} you got two #{card_rank}s on deal, would you like to split? (y/n)"

        if gets.chomp == "y"
          ret_val = true
        end

      end
    end
    return ret_val
  end

  def dump_hands(hands, players)

    #todo - debug

    for player_hand in hands
      player = players[player_hand.player_id - 1]
      player_hand.say_cards(player.name)
    end
  end

  player_hands = []
  bets = []

  # collect bets

  for player in players do

    while true

      puts "#{player.name}, what is your bet? "
      betValStr = gets.chomp
      betVal = betValStr.to_i

      if betVal <= 0 || betVal > player.cash
        puts "Bets must be > 0 and < #{player.cash}"
      else

        bets[player.id] = betVal
        break
      end
    end

  end

  #deal hands and check for splits

  for player in players do

    if player.cash > 0

      player_hand = Hand.new(player.id, player.show_odds, shoe.charlie_val)
      player_hand.bet = bets[player.id]
      player_hand.deal_hand(shoe)
      player_hands << player_hand

      check_for_blackjack(player_hand, player)
    end
  end

  # initial hands are dealt, now check for splits
  #
  # Split. When a player’s first two cards are of equal point value, he may separate them into two hands with each card
  # being the first card of a new hand. To split, the player must make another wager of equal value to the initial wager
  # for the second hand. In cases where another identical point valued card is dealt following the split, re-splitting
  # may be allowed. (Re-splitting aces is often an exception.) When allowed, players may also double down after splitting.

  splits_found = true
  player_hands_checked = []
  split_check_count = 0

  #  dump_hands(player_hands,players)

  while splits_found && (split_check_count == 0 || ALLOW_RECURSED_SPLITS)

    splits_found = false

    for player_hand in player_hands

      if !check_for_split(player_hand, players[player_hand.player_id - 1], split_check_count > 0)
        player_hands_checked << player_hand
      else
        player_hands_checked += player_hand.split_hand(shoe)
        splits_found = true
      end

    end

    player_hands = player_hands_checked
    split_check_count += 1

  end

  dump_hands(player_hands, players)


  # initial deal is all handled, now deal dealer hand

  dealer_hand = Hand.new(DEALER_ID)
  dealer_hand.deal_hand(shoe)

  dealer_hand.say_cards(DEALER_NAME, true)
  dealer_hand.say_value(DEALER_NAME)

  # While there are any viable hands or non-stayed hands and the dealer is viable OR all hands are stayed or not viable and dealer can still hit...

  while player_play_is_still_active(player_hands, dealer_hand) || player_play_is_not_active_but_dealer_below_17(player_hands, dealer_hand)

    # process all player hands

    for player_hand in player_hands do

      if !player_hand.is_stayed_or_not_viable

        # for each player hand - process that hand

        player = players[player_hand.player_id - 1]

        # Process play for this round for this player hand

        player_round_complete = false

        while player_round_complete == false do

          player_round_complete = true # Assume player round will be complete after this ifelse

          if player_hand.stay != true

            player_hand.say_cards(player.name)
            player_hand.say_value(player.name)

            if player_hand.show_odds
              shoe.say_odds(player_hand, player.name)
            end

            double_down_str = player_hand.cards.count == 2 ? ", (d)ouble" : ""

            puts "#{player.name} do you want to (h)it, (s)tay#{double_down_str} or toggle (o)dds display?"
            action = gets.chomp

            if action == "d" && player_hand.cards.count == 2

              puts "#{player.name} bet has been doubled to #{player_hand.bet *= 2}"
              action = "h"
            end

            if action == "h"

              puts "You chose to hit, here's your new hand"
              player_hand.add_card(shoe.deal_card)
              player_hand.say_cards(player.name)
              player_hand.say_value(player.name)

              check_for_blackjack(player_hand, player)

            elsif action == "o"

              player_hand.show_odds = !player_hand.show_odds
              players[player_hand.player_id - 1].show_odds = player_hand.show_odds
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
    end

    # Now that player hands are processed, handle the dealer

    puts "===== DEALERDEALERDEALERDEALERDEALERDEALERDEALERDEALER ====="

    if player_play_is_not_active_but_dealer_below_17(player_hands, dealer_hand)
      dealer_hand.add_card(shoe.deal_card)
      dealer_hand.say_cards(DEALER_NAME, true)
      dealer_hand.say_value(DEALER_NAME)
    end

  end

  # puts "closing values: #{hand.get_valuez}"
  print_blank_line
  puts "=== HAND COMPLETED ==="

  dealer_hand.say_cards(DEALER_NAME)
  dealer_hand.say_value(DEALER_NAME)

  # Note: win/play rules taken from https://www.casinocenter.com/rules-strategy-blackjack

  for player_hand in player_hands

    player = players[player_hand.player_id - 1]

    print "#{player.name} - "

    if dealer_hand.get_valuez.count == 0 && player_hand.get_valuez.count == 0
      puts "Both dealer and player busted - dealer wins"
      player.cash -= player_hand.bet
    elsif dealer_hand.get_valuez.max == player_hand.get_valuez.max
      puts "PUSH - money is returned"
    elsif dealer_hand.get_valuez.include? 21
      puts "You lose! - dealer hit blackjack"
      player.cash -= player_hand.bet
    elsif dealer_hand.is_viable == false
      puts "You win! - dealer busted out"
      player.cash += player_hand.bet
    elsif player_hand.get_valuez.count == 0
      puts "You busted - womp, womp"
      player.cash -= player_hand.bet
    elsif player_hand.get_valuez.include? 21
      puts "You win! BLACKJACK!"
      player.cash += player_hand.bet * 1.5
    elsif player_hand.num_cards >= player_hand.charlie_val
      puts "You win! #{player_hand.charlie_val} CARD CHARLIE!"
      player.cash += player_hand.bet * 2
    else
      dealer_val = dealer_hand.get_valuez.max
      player_val = player_hand.get_valuez.max

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

  for player in players
    puts "#{player.name} balance $#{player.cash}"
  end

  print_blank_line

end

puts "Greetings! Wecome to Blackjack!"

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

players = []

for player_id in 1..num_players
  players[player_id - 1] = Player.new(player_id)
end

print_blank_line

while true

  play_hand(shoe, players) # todo - pass by value/reference?  set odds was not sticking

  puts "Play again? (y)es, (n)o, (r)eset shoe and play?"
  action = gets.chomp
  if action == "y"
  elsif action == "r"
#    note - hidden value "r" resets shoe, useful for testing in stats verification
    shoe = Shoe.new(num_decks)
  elsif action == "n" || action == "q"
    print_blank_line
    puts "Okie dokie... Thanks for playing!"
    break
  end
end