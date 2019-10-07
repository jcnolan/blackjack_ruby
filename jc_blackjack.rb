
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
          foo = [11,1]
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
  SUITS = [{id:"♣", desc:"club"}, {id:"♦", desc:"diamond"}, {id:"♥", desc:"hearts"}, {id:"♠", desc:"spades" }]
  # todo - tighten up this initialization to make it denser
  RANKS = [
      # *("2".."9"),
      {id:"2", value:2}, {id:"3", value:3}, {id:"4", value:4}, {id:"5", value:5},
      {id:"6", value:6}, {id:"7", value:7}, {id:"8", value:8}, {id:"9", value:9}, {id:"10", value:10},
      {id:"J", value:10}, {id:"Q", value:10}, {id:"K", value:10}, {id:"A", value:[11,1]}
  ]

  attr_reader :cards

  def initialize

    @cards = []

    # Fill deck with cards in sequential order

    SUITS.each do |suit|
      RANKS.each do |rank|
        card = Card.new(rank[:id], suit[:id])
        @cards.push(card)
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
    print cardArr.join(",")+"\n"
  end

end

class Shoe

  # SHOE is an array of cards sourced from multiple decks.  Contains the ability to deal cards and
  # track statistics on liklyhood of 21 being reached for a given hand.  The SHOE is perpetual in
  # it's abililty to deal cards - will refill on-the-fly if needed

  RANKS = [
      # *("2".."9"),
      {id:"2", value:2}, {id:"3", value:3}, {id:"4", value:4}, {id:"5", value:5},
      {id:"6", value:6}, {id:"7", value:7}, {id:"8", value:8}, {id:"9", value:9}, {id:"10", value:10},
      {id:"J", value:10}, {id:"Q", value:10}, {id:"K", value:10}, {id:"A", value:[11,1]}
  ]

  DEFAULT_CHARLIE_VAL = 5

  def initialize num_decks

    @num_decks = num_decks
    @cards_used = { }
    @cards = []
    @charlie_val = DEFAULT_CHARLIE_VAL

   fill_shoe
  end

  attr_accessor :charlie_val

  def fill_shoe

    puts "Shuffling the shoe"

    RANKS.each do |rank|
      id = rank[:id]
      @cards_used[id] = 0
    end

  #  puts "cards_used: #{@cards_used}"
  #  puts

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
    print cardArr.join(",")+"\n"
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
    cards_in_shoe = 4*@num_decks

    # count # of cards (left) in shoe for that value

   # puts "blackjack val needed: #{blackjack_val}\n\n"

    if blackjack_val > 11
      num_matches = 0
    elsif blackjack_val == 1 || blackjack_val == 11
      num_matches = cards_in_shoe-@cards_used["A"]
    elsif blackjack_val == 10
      num_matches = ["10","J","Q","K"].map { |key| cards_in_shoe-@cards_used[key.to_s] }.reduce(:+)
    else
      idx = blackjack_val.to_s
      num_matches = cards_in_shoe-@cards_used[blackjack_val.to_s]
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

    cards_in_shoe = 4*@num_decks

    # count # of cards (left) in shoe for that value

#    puts "bust val needed: #{bust_val} or larger\n\n"

    if bust_val > 10 # can't bust

      num_matches = 0

    elsif bust_val == 1 # Ace only

      num_matches = cards_in_shoe-@cards_used["A"]

    else # {bust_val}..K will bust

      num_matches = ["10","J","Q","K"].map { |key| cards_in_shoe-@cards_used[key.to_s] }.reduce(:+)

#      puts "Facecard/10s bust vals: #{num_matches}"

      while bust_val < 10 do
        num_matches += cards_in_shoe-@cards_used[bust_val.to_s]
  #      puts "Bust vals (+#{bust_val}): #{num_matches}"
        bust_val += 1
      end
    end

#    puts "num_bust_matches: #{num_matches}"

    # return that number

    return num_matches

  end

  def say_odds(hand)

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
    odds_of_blackjack = (num_blackjacks.to_f/num_cards_in_shoe.to_f)*100.0
    puts "Odds of blackjack: #{odds_of_blackjack}%"

    # check for possible busts

    num_busts = get_busts(min_value)

    # check for possible charlie match

    if hand.num_cards+1 == hand.charlie_val

      num_charlies = num_cards_in_shoe-num_blackjacks-num_busts

      #print stats on charlies
      odds_of_charlie = (num_charlies.to_f/num_cards_in_shoe.to_f)*100.0
      puts "Odds of charlie: #{odds_of_charlie}%"

    end

    # Odds of bust = busts/cards in shoe

    odds_of_bust = (num_busts.to_f/num_cards_in_shoe.to_f)*100.0
    puts "Odds of busting: #{odds_of_bust}%"

    # Slightly harder one is odds of beating dealer w/out busting (?)

  end

end

class Hand

  # Hand consists of an array of cards - used to track a players hand and is used in determining odds of hitting 21

  attr_reader :charlie_val
  attr_accessor :stay

  def initialize()
    @cards = []
    @charlie_val = 999
    @stay = false
  end

  def set_charlie(charlie)
    @charlie_val = charlie
  end

  def add_card(card)
    @cards << card
  end

  def num_cards()
    return @cards.count
  end

  def say_cards(player_name=nil)

    if player_name == nil
      player_name = "Player"
    end

    cardArr = []
    print "#{player_name} hand contains #{@cards.count()} cards: "
    @cards.each do |card|
      cardArr << card.say_card
    end
    print cardArr.join(",")+"\n"
    #say_value
  end

  def get_valuez
    # todo - signature overload?
    return get_values(@cards,[0])
  end

  def get_values(cards, values)

##   puts "get_values - cards in: #{cards}"

    cards = cards.clone # todo - is this the right way to handle this? Need destructive, internal appraoch

    while cards.count() > 0 do

      card = cards.pop
      card_value = card.get_value

      if !card_value.kind_of?(Array)
        values = values.map {|num| num+card_value}
      else

     # todo - Line below should work fine but does not... using loop below instead
     #   newValues = values.map {|toAdd| card_value.map {|num| num+toAdd}}

        newValues = []
        card_value.each do |val|
          newValues += values.map {|num| num+val}
        end
        values = newValues.uniq

      end
    end

    values.reject! {|num| num > 21}

   # puts "reg_values returning: #{values}"

    return values.sort

  end

  def say_value(player_name=nil)

    if player_name == nil
      player_name = "Player"
    end

    values = get_values(@cards,[0])

    foo = values.join(",")
    vStr = values.count() == 1 ? "value" : "values"

    print "#{player_name} hand #{vStr}: #{foo}\n\n"
  end

  def is_viable

    # Determines if hand is still playable.  For purposes here 21 is NOT viable, since it's a winning hand

   # puts "In is_viable, charlie: #{@charlie}"

    values = get_values(@cards,[0])
    if values.include? 21
      viable_vals = [] # Note - 21 is not viable, since it's a winning hand
    elsif @cards.count >= @charlie_val
      viable_vals = [] # Note - Hand is winning based on charlie card count
    else
      viable_vals = values.select {|val| val < 21 }
    end

    return viable_vals.count > 0

  end

end

##############################

num_decks = 1

=begin
deck = Deck.new
deck.say_suits
deck.say_values

card = Card.new("9","♥")
card.say_value

print("==============\n")

deck.say_cards

print("\n==============\n")

shoe = Shoe.new(num_decks)

shoe.say_cards
shoe.say_cards_used

num_cards_to_deal = 60
puts "Dealing #{num_cards_to_deal} cards"

for _ in 1..num_cards_to_deal do
  shoe.deal_card
end

shoe.say_cards
shoe.say_cards_used

shoe = Shoe.new(num_decks)

print("\n==============\n")

=end

$show_odds = false # todo - do I want to encapsulate this? globals are BAD

def init_hand(shoe, hand)

  # todo - I don't like having to set charlie for every hand!  Should be on game level or something, "odds" as well

  hand.set_charlie(shoe.charlie_val)

  hand.add_card(shoe.deal_card)
  hand.add_card(shoe.deal_card)

=begin
  while hand.is_viable == true && !shoe.is_bust_possible(hand)
    # todo: note - will "auto-hit" until an actual choice is needed - used for testing
    hand.add_card(shoe.deal_card)
  end
=end

end

def play_hand(shoe)

  # todo - this is lame!  Should be somewhere else so it's not two lines

  hand = Hand.new()
  init_hand(shoe, hand)

  dealer = Hand.new()
  init_hand(shoe, dealer)

  dealer.say_cards("Dealer")
  dealer.say_value("Dealer")

  hand.say_cards

  until hand.is_viable == false || dealer.is_viable == false || (hand.stay == true && dealer.get_valuez.max >= 17)

    if hand.stay != true

      if $show_odds
        shoe.say_odds(hand)
      end

      puts "\nDo you want to (h)it, (s)tay or toggle (o)dds display?"
      action = gets.chomp
      puts

      if action == "h"

        puts "You chose to hit, here's your new hand"
        hand.add_card(shoe.deal_card)
        hand.say_cards
        hand.say_value("Player")

      elsif action == "o"
        $show_odds = !$show_odds
      elsif action == "q"
        break
      else
        puts "You chose to stay"
        hand.stay = true
      end
    end

    if hand.is_viable && dealer.get_valuez.max < 17
      dealer.add_card(shoe.deal_card)
      dealer.say_cards("Dealer")
      dealer.say_value("Dealer")
    end

  end

# puts "closing values: #{hand.get_valuez}"

  puts

  # Note: win rules taken from https://www.casinocenter.com/rules-strategy-blackjack

  if dealer.get_valuez.count == 0 && hand.get_valuez.count == 0
    puts "Both dealer and player busted - dealer wins"
  elsif dealer.get_valuez.max == hand.get_valuez.max
    puts "PUSH - money is returned"
  elsif dealer.get_valuez.include? 21
    puts "You lose! - dealer hit blackjack"
  elsif dealer.is_viable == false
    puts "You win! - dealer busted out"
  elsif hand.get_valuez.count == 0
    puts "You're busted - womp, womp"
  elsif hand.get_valuez.include? 21
    puts "You win! BLACKJACK"
  elsif hand.num_cards >= hand.charlie_val
    puts "You win! #{hand.charlie_val} CARD CHARLIE"
  else
    dealer_val = dealer.get_valuez.max
    player_val = hand.get_valuez.max

    print "dealer: #{dealer_val} / player: #{player_val} - "
    if dealer_val >= player_val
      print "DEALER WINS!\n"
    else
      print "PLAYER WINS!\n"
    end
  end

end

shoe = Shoe.new(num_decks)
play_hand(shoe)

while true
  puts "Play again? (y)es, (n)o, (r)eset and play?"
  action = gets.chomp
  if action == "y"
    play_hand(shoe)
  elsif action == "r"
    shoe = Shoe.new(num_decks)
    play_hand(shoe)
  elsif action == "n" || action == "q"
    break
  else
    next
  end
end