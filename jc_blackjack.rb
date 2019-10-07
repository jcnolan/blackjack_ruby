
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

    numCards = @cards.count()
    print("numCards: #{numCards}\n")

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

  def initialize num_decks

    @num_decks = num_decks
    @cards_used = { }
    @cards = []

   fill_shoe
  end

  def fill_shoe

    puts "filling the shoe"

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
    if @cards.count == 0
        fill_shoe
    end
    card = @cards.pop
    @cards_used[card.rank] += 1
    return card
   # card =
  end

  def say_cards
    cardArr = []
    print "Shoe contains #{@cards.count()} cards\n"
    @cards.each do |card|
      cardArr << card.say_card
    end
    print cardArr.join(",")+"\n"
  end

  def say_cards_used

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
  end

end

class Hand

  # Hand consists of an array of cards - used to track a players hand and is used in determining odds of hitting 21

  @cards

  def  initialize
    @cards = []
  end

  def add_card(card)
    @cards << card
  end

  def get_value()

  end

  def say_cards
    cardArr = []
    print "Hand contains #{@cards.count()} cards\n"
    @cards.each do |card|
      cardArr << card.say_card
    end
    print cardArr.join(",")+"\n"
  end

  def get_values(cards, values)

    puts "get_values - cards in: #{cards}"

    while cards.count() > 0 do

      card = @cards.pop
      card_value = card.get_value

      puts "card_value: #{card_value}"

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

   # values.reject! {|num| num > 21}

    puts "reg_values returning: #{values}"

    return values.sort

  end

  def say_value

    values = get_values(@cards,[0])

    foo = values.join(",")
    vStr = values.count() == 1 ? "Value" : "Values"

    print "Hand #{vStr}: #{foo}\n"
  end

end

##############################

deck = Deck.new
deck.say_suits
deck.say_values

card = Card.new("9","♥")
card.say_value

print("==============\n")

deck.say_cards

print("\n==============\n")

num_decks = 1

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
hand = Hand.new


print("\n==============\n")

num_cards_to_deal = 40
puts "Dealing #{num_cards_to_deal} cards"

for _ in 1..num_cards_to_deal do
  card = shoe.deal_card
  hand.add_card( card )
end

hand.say_cards
hand.say_value

