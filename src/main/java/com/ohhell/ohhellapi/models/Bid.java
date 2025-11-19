package com.ohhell.ohhellapi.models;

public class Bid {
    private Long bidId;
    private Long playerId;
    private int bidValue;  // Número de bazas que el jugador predice ganar
    private int tricksWon;  // Número de bazas realmente ganadas
    
    public Bid() {
        this.tricksWon = 0;
    }
    
    public Bid(Long playerId, int bidValue) {
        this();
        this.playerId = playerId;
        this.bidValue = bidValue;
    }
    
    // Getters y Setters
    public Long getBidId() {
        return bidId;
    }
    
    public void setBidId(Long bidId) {
        this.bidId = bidId;
    }
    
    public Long getPlayerId() {
        return playerId;
    }
    
    public void setPlayerId(Long playerId) {
        this.playerId = playerId;
    }
    
    public int getBidValue() {
        return bidValue;
    }
    
    public void setBidValue(int bidValue) {
        this.bidValue = bidValue;
    }
    
    public int getTricksWon() {
        return tricksWon;
    }
    
    public void setTricksWon(int tricksWon) {
        this.tricksWon = tricksWon;
    }
    
    public void incrementTricksWon() {
        this.tricksWon++;
    }
    
    // Verifica si el jugador cumplió su apuesta
    public boolean isBidMet() {
        return this.bidValue == this.tricksWon;
    }
}
