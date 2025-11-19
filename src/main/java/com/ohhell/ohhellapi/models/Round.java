package com.ohhell.ohhellapi.models;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Round {
    private int roundNumber;
    private int cardsPerPlayer;
    private String trumpSuit;
    private Long dealerId;
    private List<Bid> bids;
    private List<Trick> tricks;
    private int currentTrick;
    private String status;  // bidding, playing, finished
    private Map<Long, Integer> scores;  // playerId -> score this round
    
    public Round() {
        this.bids = new ArrayList<>();
        this.tricks = new ArrayList<>();
        this.scores = new HashMap<>();
        this.currentTrick = 0;
        this.status = "bidding";
    }
    
    public Round(int roundNumber, int cardsPerPlayer, String trumpSuit, Long dealerId) {
        this();
        this.roundNumber = roundNumber;
        this.cardsPerPlayer = cardsPerPlayer;
        this.trumpSuit = trumpSuit;
        this.dealerId = dealerId;
    }
    
    // Getters y Setters
    public int getRoundNumber() {
        return roundNumber;
    }
    
    public void setRoundNumber(int roundNumber) {
        this.roundNumber = roundNumber;
    }
    
    public int getCardsPerPlayer() {
        return cardsPerPlayer;
    }
    
    public void setCardsPerPlayer(int cardsPerPlayer) {
        this.cardsPerPlayer = cardsPerPlayer;
    }
    
    public String getTrumpSuit() {
        return trumpSuit;
    }
    
    public void setTrumpSuit(String trumpSuit) {
        this.trumpSuit = trumpSuit;
    }
    
    public Long getDealerId() {
        return dealerId;
    }
    
    public void setDealerId(Long dealerId) {
        this.dealerId = dealerId;
    }
    
    public List<Bid> getBids() {
        return bids;
    }
    
    public void setBids(List<Bid> bids) {
        this.bids = bids;
    }
    
    public List<Trick> getTricks() {
        return tricks;
    }
    
    public void setTricks(List<Trick> tricks) {
        this.tricks = tricks;
    }
    
    public int getCurrentTrick() {
        return currentTrick;
    }
    
    public void setCurrentTrick(int currentTrick) {
        this.currentTrick = currentTrick;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Map<Long, Integer> getScores() {
        return scores;
    }
    
    public void setScores(Map<Long, Integer> scores) {
        this.scores = scores;
    }
    
    // Añadir una apuesta
    public void addBid(Bid bid) {
        this.bids.add(bid);
    }
    
    // Validar que la suma de apuestas no sea igual al número de cartas
    public boolean isValidBid(int bidValue, int totalPlayers) {
        int sum = bids.stream().mapToInt(Bid::getBidValue).sum();
        
        // Si es la última apuesta, no puede hacer que la suma sea igual al total de cartas
        if (bids.size() == totalPlayers - 1) {
            return (sum + bidValue) != cardsPerPlayer;
        }
        return true;
    }
    
    // Iniciar una nueva baza
    public void startNewTrick() {
        currentTrick++;
        Trick trick = new Trick(currentTrick);
        tricks.add(trick);
    }
    
    // Obtener la baza actual
    public Trick getCurrentTrickObject() {
        if (tricks.isEmpty() || currentTrick > tricks.size()) {
            return null;
        }
        return tricks.get(currentTrick - 1);
    }
    
    // Calcular scores de la ronda
    public void calculateScores() {
        for (Bid bid : bids) {
            if (bid.isBidMet()) {
                // Acertó: 10 puntos + 5 por cada baza predicha
                scores.put(bid.getPlayerId(), 10 + (bid.getBidValue() * 5));
            } else {
                // Falló: pierde vidas (esto se maneja en Game)
                scores.put(bid.getPlayerId(), 0);
            }
        }
        this.status = "finished";
    }
}
