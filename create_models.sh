#!/bin/bash

# Script para crear todos los modelos de Oh Hell API
# Uso: Este script debe ejecutarse en el directorio raíz del proyecto OhHellAPI

PROJECT_DIR="/home/tommy/Programacion/CURSOS/Java/OhHellAPI"
MODELS_DIR="$PROJECT_DIR/src/main/java/com/ohhell/ohhellapi/models"

echo "🎮 Creando modelos para Oh Hell API..."
echo "Directorio: $MODELS_DIR"

# Crear directorio si no existe
mkdir -p "$MODELS_DIR"

# ==================== CARD.JAVA ====================
cat > "$MODELS_DIR/Card.java" << 'CARD_EOF'
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
CARD_EOF

echo "✅ Card.java creado"

# ==================== PLAYER.JAVA ====================
cat > "$MODELS_DIR/Player.java" << 'PLAYER_EOF'
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
PLAYER_EOF

echo "✅ Player.java creado"

# ==================== BID.JAVA ====================
cat > "$MODELS_DIR/Bid.java" << 'BID_EOF'
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
BID_EOF

echo "✅ Bid.java creado"

# ==================== TRICK.JAVA ====================
cat > "$MODELS_DIR/Trick.java" << 'TRICK_EOF'
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
TRICK_EOF

echo "✅ Trick.java creado"

# ==================== ROUND.JAVA ====================
cat > "$MODELS_DIR/Round.java" << 'ROUND_EOF'
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
ROUND_EOF

echo "✅ Round.java creado"

# ==================== GAME.JAVA ====================
cat > "$MODELS_DIR/Game.java" << 'GAME_EOF'
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
GAME_EOF

echo "✅ Game.java creado"

echo ""
echo "🎉 ¡Todos los modelos han sido creados exitosamente!"
echo ""
echo "Modelos creados:"
echo "  - Card.java (Cartas)"
echo "  - Player.java (Jugadores)"
echo "  - Bid.java (Apuestas)"
echo "  - Trick.java (Bazas)"
echo "  - Round.java (Rondas)"
echo "  - Game.java (Partidas)"
echo ""
echo "Ubicación: $MODELS_DIR"
