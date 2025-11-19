package com.ohhell.ohhellapi.models;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Player {
    private Long playerId;
    private String username;
    private String email;
    private String password;  // En producción debería estar hasheada
    private int totalGames;
    private int totalWins;
    private LocalDateTime createdAt;
    private List<Card> hand;  // Cartas actuales en la mano
    
    public Player() {
        this.hand = new ArrayList<>();
        this.createdAt = LocalDateTime.now();
        this.totalGames = 0;
        this.totalWins = 0;
    }
    
    public Player(String username, String email, String password) {
        this();
        this.username = username;
        this.email = email;
        this.password = password;
    }
    
    // Getters y Setters
    public Long getPlayerId() {
        return playerId;
    }
    
    public void setPlayerId(Long playerId) {
        this.playerId = playerId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public int getTotalGames() {
        return totalGames;
    }
    
    public void setTotalGames(int totalGames) {
        this.totalGames = totalGames;
    }
    
    public int getTotalWins() {
        return totalWins;
    }
    
    public void setTotalWins(int totalWins) {
        this.totalWins = totalWins;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public List<Card> getHand() {
        return hand;
    }
    
    public void setHand(List<Card> hand) {
        this.hand = hand;
    }
    
    public void addCardToHand(Card card) {
        this.hand.add(card);
    }
    
    public void clearHand() {
        this.hand.clear();
    }
    
    public void incrementGames() {
        this.totalGames++;
    }
    
    public void incrementWins() {
        this.totalWins++;
    }
}
