package com.ohhell.ohhellapi.models;

public class Card {
    private String suit;  // hearts, diamonds, clubs, spades
    private String rank;  // A, 2, 3, 4, 5, 6, 7, 8, 9, 10, J, Q, K
    
    public Card() {}
    
    public Card(String suit, String rank) {
        this.suit = suit;
        this.rank = rank;
    }
    
    public String getSuit() {
        return suit;
    }
    
    public void setSuit(String suit) {
        this.suit = suit;
    }
    
    public String getRank() {
        return rank;
    }
    
    public void setRank(String rank) {
        this.rank = rank;
    }
    
    public int getValue() {
        switch (rank) {
            case "A": return 14;
            case "K": return 13;
            case "Q": return 12;
            case "J": return 11;
            default: return Integer.parseInt(rank);
        }
    }
    
    @Override
    public String toString() {
        return rank + " of " + suit;
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Card card = (Card) obj;
        return suit.equals(card.suit) && rank.equals(card.rank);
    }
}
