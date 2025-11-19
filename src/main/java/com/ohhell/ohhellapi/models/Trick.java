package com.ohhell.ohhellapi.models;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Trick {
    private int trickNumber;
    private String leadingSuit;  // Palo que lidera la baza
    private Map<Long, Card> cardsPlayed;  // playerId -> Card
    private Long winnerId;
    
    public Trick(int trickNumber) {
        this.trickNumber = trickNumber;
        this.cardsPlayed = new HashMap<>();
    }
    
    // Getters y Setters
    public int getTrickNumber() {
        return trickNumber;
    }
    
    public void setTrickNumber(int trickNumber) {
        this.trickNumber = trickNumber;
    }
    
    public String getLeadingSuit() {
        return leadingSuit;
    }
    
    public void setLeadingSuit(String leadingSuit) {
        this.leadingSuit = leadingSuit;
    }
    
    public Map<Long, Card> getCardsPlayed() {
        return cardsPlayed;
    }
    
    public void setCardsPlayed(Map<Long, Card> cardsPlayed) {
        this.cardsPlayed = cardsPlayed;
    }
    
    public Long getWinnerId() {
        return winnerId;
    }
    
    public void setWinnerId(Long winnerId) {
        this.winnerId = winnerId;
    }
    
    // Jugar una carta en la baza
    public void playCard(Long playerId, Card card) {
        if (cardsPlayed.isEmpty()) {
            this.leadingSuit = card.getSuit();
        }
        cardsPlayed.put(playerId, card);
    }
    
    // Determinar el ganador de la baza
    public Long determineWinner(String trumpSuit) {
        Long winner = null;
        Card winningCard = null;
        
        for (Map.Entry<Long, Card> entry : cardsPlayed.entrySet()) {
            Card card = entry.getValue();
            
            if (winningCard == null) {
                winner = entry.getKey();
                winningCard = card;
                continue;
            }
            
            // Triunfo gana sobre cualquier cosa
            if (card.getSuit().equals(trumpSuit) && !winningCard.getSuit().equals(trumpSuit)) {
                winner = entry.getKey();
                winningCard = card;
            }
            // Si ambas son triunfo, la más alta gana
            else if (card.getSuit().equals(trumpSuit) && winningCard.getSuit().equals(trumpSuit)) {
                if (card.getValue() > winningCard.getValue()) {
                    winner = entry.getKey();
                    winningCard = card;
                }
            }
            // Si ninguna es triunfo, debe seguir el palo
            else if (!card.getSuit().equals(trumpSuit) && !winningCard.getSuit().equals(trumpSuit)) {
                if (card.getSuit().equals(leadingSuit) && card.getValue() > winningCard.getValue()) {
                    winner = entry.getKey();
                    winningCard = card;
                }
            }
        }
        
        this.winnerId = winner;
        return winner;
    }
    
    public boolean isComplete(int totalPlayers) {
        return cardsPlayed.size() == totalPlayers;
    }
}
