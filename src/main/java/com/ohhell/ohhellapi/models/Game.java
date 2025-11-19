package com.ohhell.ohhellapi.models;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Game {
    private Long gameId;
    private String status;  // waiting, active, finished
    private int currentRound;
    private int maxRounds;
    private int maxPlayers;
    private int initialLives;
    private Long createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime startedAt;
    private LocalDateTime finishedAt;
    
    private List<Long> playerIds;  // IDs de los jugadores
    private Map<Long, Integer> playerScores;  // playerId -> score total
    private Map<Long, Integer> playerLives;  // playerId -> vidas restantes
    private List<Round> rounds;
    
    public Game() {
        this.playerIds = new ArrayList<>();
        this.playerScores = new HashMap<>();
        this.playerLives = new HashMap<>();
        this.rounds = new ArrayList<>();
        this.currentRound = 0;
        this.status = "waiting";
        this.createdAt = LocalDateTime.now();
    }
    
    public Game(int maxPlayers, int initialLives, int maxRounds, Long createdBy) {
        this();
        this.maxPlayers = maxPlayers;
        this.initialLives = initialLives;
        this.maxRounds = maxRounds;
        this.createdBy = createdBy;
    }
    
    // Getters y Setters
    public Long getGameId() {
        return gameId;
    }
    
    public void setGameId(Long gameId) {
        this.gameId = gameId;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public int getCurrentRound() {
        return currentRound;
    }
    
    public void setCurrentRound(int currentRound) {
        this.currentRound = currentRound;
    }
    
    public int getMaxRounds() {
        return maxRounds;
    }
    
    public void setMaxRounds(int maxRounds) {
        this.maxRounds = maxRounds;
    }
    
    public int getMaxPlayers() {
        return maxPlayers;
    }
    
    public void setMaxPlayers(int maxPlayers) {
        this.maxPlayers = maxPlayers;
    }
    
    public int getInitialLives() {
        return initialLives;
    }
    
    public void setInitialLives(int initialLives) {
        this.initialLives = initialLives;
    }
    
    public Long getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getStartedAt() {
        return startedAt;
    }
    
    public void setStartedAt(LocalDateTime startedAt) {
        this.startedAt = startedAt;
    }
    
    public LocalDateTime getFinishedAt() {
        return finishedAt;
    }
    
    public void setFinishedAt(LocalDateTime finishedAt) {
        this.finishedAt = finishedAt;
    }
    
    public List<Long> getPlayerIds() {
        return playerIds;
    }
    
    public void setPlayerIds(List<Long> playerIds) {
        this.playerIds = playerIds;
    }
    
    public Map<Long, Integer> getPlayerScores() {
        return playerScores;
    }
    
    public void setPlayerScores(Map<Long, Integer> playerScores) {
        this.playerScores = playerScores;
    }
    
    public Map<Long, Integer> getPlayerLives() {
        return playerLives;
    }
    
    public void setPlayerLives(Map<Long, Integer> playerLives) {
        this.playerLives = playerLives;
    }
    
    public List<Round> getRounds() {
        return rounds;
    }
    
    public void setRounds(List<Round> rounds) {
        this.rounds = rounds;
    }
    
    // Añadir un jugador a la partida
    public boolean addPlayer(Long playerId) {
        if (playerIds.size() >= maxPlayers || !status.equals("waiting")) {
            return false;
        }
        playerIds.add(playerId);
        playerScores.put(playerId, 0);
        playerLives.put(playerId, initialLives);
        return true;
    }
    
    // Iniciar la partida
    public boolean startGame() {
        if (playerIds.size() < 2 || !status.equals("waiting")) {
            return false;
        }
        this.status = "active";
        this.startedAt = LocalDateTime.now();
        startNewRound();
        return true;
    }
    
    // Iniciar una nueva ronda
    public void startNewRound() {
        currentRound++;
        // En Oh Hell, el número de cartas varía por ronda
        int cardsThisRound = calculateCardsForRound(currentRound);
        String trumpSuit = determineTrumpSuit();
        Long dealerId = playerIds.get((currentRound - 1) % playerIds.size());
        
        Round round = new Round(currentRound, cardsThisRound, trumpSuit, dealerId);
        rounds.add(round);
    }
    
    // Calcular cartas por ronda (ejemplo: aumenta progresivamente)
    private int calculateCardsForRound(int roundNum) {
        // Puedes personalizar esto según las reglas que quieras
        return Math.min(roundNum, 10);
    }
    
    // Determinar palo de triunfo (aleatorio o predeterminado)
    private String determineTrumpSuit() {
        String[] suits = {"hearts", "diamonds", "clubs", "spades"};
        return suits[(int) (Math.random() * 4)];
    }
    
    // Obtener la ronda actual
    public Round getCurrentRoundObject() {
        if (rounds.isEmpty() || currentRound > rounds.size()) {
            return null;
        }
        return rounds.get(currentRound - 1);
    }
    
    // Actualizar vidas de un jugador
    public void updatePlayerLives(Long playerId, int livesChange) {
        int currentLives = playerLives.getOrDefault(playerId, 0);
        playerLives.put(playerId, Math.max(0, currentLives + livesChange));
        
        // Verificar si el jugador fue eliminado
        if (playerLives.get(playerId) == 0) {
            checkGameEnd();
        }
    }
    
    // Añadir puntos a un jugador
    public void addScore(Long playerId, int points) {
        int currentScore = playerScores.getOrDefault(playerId, 0);
        playerScores.put(playerId, currentScore + points);
    }
    
    // Verificar si el juego debe terminar
    public void checkGameEnd() {
        long playersAlive = playerLives.values().stream().filter(lives -> lives > 0).count();
        
        if (playersAlive <= 1 || currentRound >= maxRounds) {
            this.status = "finished";
            this.finishedAt = LocalDateTime.now();
        }
    }
    
    // Obtener el ganador
    public Long getWinner() {
        if (!status.equals("finished")) {
            return null;
        }
        
        return playerScores.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse(null);
    }
}
