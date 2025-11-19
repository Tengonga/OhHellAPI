#!/bin/bash

# Script para crear todos los Resources REST de Oh Hell API
# Uso: Este script debe ejecutarse en el directorio raíz del proyecto OhHellAPI

PROJECT_DIR="/home/tommy/Programacion/CURSOS/Java/OhHellAPI"
RESOURCES_DIR="$PROJECT_DIR/src/main/java/com/ohhell/ohhellapi/resources"

echo "🎮 Creando Resources REST para Oh Hell API..."
echo "Directorio: $RESOURCES_DIR"

# Crear directorio si no existe
mkdir -p "$RESOURCES_DIR"

# ==================== PLAYER RESOURCE ====================
cat > "$RESOURCES_DIR/PlayerResource.java" << 'PLAYER_EOF'
package com.ohhell.ohhellapi.resources;

import com.ohhell.ohhellapi.models.Player;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Path("v1/players")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PlayerResource {
    
    // Simulación de base de datos en memoria
    private static ConcurrentHashMap<Long, Player> players = new ConcurrentHashMap<>();
    private static AtomicLong idCounter = new AtomicLong(1);
    
    /**
     * GET /api/v1/players
     * Obtener todos los jugadores
     */
    @GET
    public Response getAllPlayers(
            @QueryParam("limit") @DefaultValue("100") int limit,
            @QueryParam("offset") @DefaultValue("0") int offset) {
        
        List<Player> playerList = new ArrayList<>(players.values());
        
        // Aplicar paginación
        int start = Math.min(offset, playerList.size());
        int end = Math.min(start + limit, playerList.size());
        List<Player> paginatedList = playerList.subList(start, end);
        
        return Response.ok(paginatedList).build();
    }
    
    /**
     * GET /api/v1/players/{id}
     * Obtener un jugador específico
     */
    @GET
    @Path("{id}")
    public Response getPlayer(@PathParam("id") Long id) {
        Player player = players.get(id);
        
        if (player == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Player not found\"}")
                    .build();
        }
        
        return Response.ok(player).build();
    }
    
    /**
     * POST /api/v1/players
     * Crear un nuevo jugador
     */
    @POST
    public Response createPlayer(Player player, @Context UriInfo uriInfo) {
        
        // Validaciones
        if (player.getUsername() == null || player.getUsername().trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Username is required\"}")
                    .build();
        }
        
        if (player.getEmail() == null || player.getEmail().trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Email is required\"}")
                    .build();
        }
        
        // Verificar si el username ya existe
        boolean usernameExists = players.values().stream()
                .anyMatch(p -> p.getUsername().equals(player.getUsername()));
        
        if (usernameExists) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Username already exists\"}")
                    .build();
        }
        
        // Asignar ID y guardar
        Long newId = idCounter.getAndIncrement();
        player.setPlayerId(newId);
        players.put(newId, player);
        
        // Construir URI del recurso creado
        UriBuilder builder = uriInfo.getAbsolutePathBuilder();
        builder.path(Long.toString(newId));
        
        return Response.created(builder.build())
                .entity(player)
                .build();
    }
    
    /**
     * PUT /api/v1/players/{id}
     * Actualizar un jugador
     */
    @PUT
    @Path("{id}")
    public Response updatePlayer(@PathParam("id") Long id, Player updatedPlayer) {
        
        Player existingPlayer = players.get(id);
        
        if (existingPlayer == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Player not found\"}")
                    .build();
        }
        
        // Actualizar campos
        if (updatedPlayer.getUsername() != null) {
            existingPlayer.setUsername(updatedPlayer.getUsername());
        }
        if (updatedPlayer.getEmail() != null) {
            existingPlayer.setEmail(updatedPlayer.getEmail());
        }
        if (updatedPlayer.getPassword() != null) {
            existingPlayer.setPassword(updatedPlayer.getPassword());
        }
        
        players.put(id, existingPlayer);
        
        return Response.ok(existingPlayer).build();
    }
    
    /**
     * DELETE /api/v1/players/{id}
     * Eliminar un jugador
     */
    @DELETE
    @Path("{id}")
    public Response deletePlayer(@PathParam("id") Long id) {
        
        Player removed = players.remove(id);
        
        if (removed == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Player not found\"}")
                    .build();
        }
        
        return Response.noContent().build();
    }
    
    // Método helper para obtener el mapa de jugadores (útil para otros resources)
    public static ConcurrentHashMap<Long, Player> getPlayersMap() {
        return players;
    }
}
PLAYER_EOF

echo "✅ PlayerResource.java creado"

# ==================== GAME RESOURCE ====================
cat > "$RESOURCES_DIR/GameResource.java" << 'GAME_EOF'
package com.ohhell.ohhellapi.resources;

import com.ohhell.ohhellapi.models.Game;
import com.ohhell.ohhellapi.models.Player;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.stream.Collectors;

@Path("v1/games")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class GameResource {
    
    private static ConcurrentHashMap<Long, Game> games = new ConcurrentHashMap<>();
    private static AtomicLong idCounter = new AtomicLong(1);
    
    /**
     * GET /api/v1/games
     * Obtener todas las partidas
     */
    @GET
    public Response getAllGames(
            @QueryParam("status") String status,
            @QueryParam("limit") @DefaultValue("100") int limit,
            @QueryParam("offset") @DefaultValue("0") int offset) {
        
        List<Game> gameList = new ArrayList<>(games.values());
        
        // Filtrar por status si se proporciona
        if (status != null && !status.isEmpty()) {
            gameList = gameList.stream()
                    .filter(g -> g.getStatus().equalsIgnoreCase(status))
                    .collect(Collectors.toList());
        }
        
        // Aplicar paginación
        int start = Math.min(offset, gameList.size());
        int end = Math.min(start + limit, gameList.size());
        List<Game> paginatedList = gameList.subList(start, end);
        
        return Response.ok(paginatedList).build();
    }
    
    /**
     * GET /api/v1/games/{id}
     * Obtener una partida específica
     */
    @GET
    @Path("{id}")
    public Response getGame(@PathParam("id") Long id) {
        Game game = games.get(id);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        return Response.ok(game).build();
    }
    
    /**
     * POST /api/v1/games
     * Crear una nueva partida
     */
    @POST
    public Response createGame(Map<String, Object> gameConfig, @Context UriInfo uriInfo) {
        
        // Extraer configuración
        Integer maxPlayers = (Integer) gameConfig.get("max_players");
        Integer initialLives = (Integer) gameConfig.get("initial_lives");
        Integer maxRounds = (Integer) gameConfig.get("max_rounds");
        Long createdBy = ((Number) gameConfig.get("created_by_player_id")).longValue();
        
        // Validaciones
        if (maxPlayers == null || maxPlayers < 2 || maxPlayers > 8) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"max_players must be between 2 and 8\"}")
                    .build();
        }
        
        if (initialLives == null || initialLives < 1) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"initial_lives must be at least 1\"}")
                    .build();
        }
        
        if (maxRounds == null || maxRounds < 1) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"max_rounds must be at least 1\"}")
                    .build();
        }
        
        // Verificar que el creador existe
        if (!PlayerResource.getPlayersMap().containsKey(createdBy)) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Creator player not found\"}")
                    .build();
        }
        
        // Crear partida
        Game game = new Game(maxPlayers, initialLives, maxRounds, createdBy);
        Long newId = idCounter.getAndIncrement();
        game.setGameId(newId);
        
        // Añadir al creador automáticamente
        game.addPlayer(createdBy);
        
        games.put(newId, game);
        
        // Construir URI
        UriBuilder builder = uriInfo.getAbsolutePathBuilder();
        builder.path(Long.toString(newId));
        
        return Response.created(builder.build())
                .entity(game)
                .build();
    }
    
    /**
     * POST /api/v1/games/{id}/join
     * Unirse a una partida
     */
    @POST
    @Path("{id}/join")
    public Response joinGame(@PathParam("id") Long gameId, Map<String, Object> joinRequest) {
        
        Game game = games.get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        Long playerId = ((Number) joinRequest.get("player_id")).longValue();
        
        // Verificar que el jugador existe
        if (!PlayerResource.getPlayersMap().containsKey(playerId)) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Player not found\"}")
                    .build();
        }
        
        // Intentar añadir jugador
        boolean added = game.addPlayer(playerId);
        
        if (!added) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Cannot join game - game is full or already started\"}")
                    .build();
        }
        
        return Response.ok()
                .entity("{\"message\": \"Successfully joined game\", \"game_id\": " + gameId + "}")
                .build();
    }
    
    /**
     * POST /api/v1/games/{id}/start
     * Iniciar una partida
     */
    @POST
    @Path("{id}/start")
    public Response startGame(@PathParam("id") Long gameId) {
        
        Game game = games.get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        boolean started = game.startGame();
        
        if (!started) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Cannot start game - need at least 2 players and game must be in waiting status\"}")
                    .build();
        }
        
        return Response.ok(game).build();
    }
    
    /**
     * DELETE /api/v1/games/{id}
     * Eliminar una partida
     */
    @DELETE
    @Path("{id}")
    public Response deleteGame(@PathParam("id") Long id) {
        
        Game removed = games.remove(id);
        
        if (removed == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        return Response.noContent().build();
    }
    
    // Método helper
    public static ConcurrentHashMap<Long, Game> getGamesMap() {
        return games;
    }
}
GAME_EOF

echo "✅ GameResource.java creado"

# ==================== ROUND RESOURCE ====================
cat > "$RESOURCES_DIR/RoundResource.java" << 'ROUND_EOF'
package com.ohhell.ohhellapi.resources;

import com.ohhell.ohhellapi.models.Game;
import com.ohhell.ohhellapi.models.Round;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import java.util.List;

@Path("v1/games/{gameId}/rounds")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RoundResource {
    
    /**
     * GET /api/v1/games/{gameId}/rounds
     * Obtener todas las rondas de una partida
     */
    @GET
    public Response getAllRounds(@PathParam("gameId") Long gameId) {
        
        Game game = GameResource.getGamesMap().get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        List<Round> rounds = game.getRounds();
        return Response.ok(rounds).build();
    }
    
    /**
     * GET /api/v1/games/{gameId}/rounds/{roundNumber}
     * Obtener una ronda específica
     */
    @GET
    @Path("{roundNumber}")
    public Response getRound(
            @PathParam("gameId") Long gameId,
            @PathParam("roundNumber") int roundNumber) {
        
        Game game = GameResource.getGamesMap().get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        List<Round> rounds = game.getRounds();
        
        if (roundNumber < 1 || roundNumber > rounds.size()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Round not found\"}")
                    .build();
        }
        
        Round round = rounds.get(roundNumber - 1);
        return Response.ok(round).build();
    }
}
ROUND_EOF

echo "✅ RoundResource.java creado"

# ==================== BID RESOURCE ====================
cat > "$RESOURCES_DIR/BidResource.java" << 'BID_EOF'
package com.ohhell.ohhellapi.resources;

import com.ohhell.ohhellapi.models.*;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import java.util.List;
import java.util.Map;

@Path("v1/games/{gameId}/rounds/{roundNumber}/bids")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class BidResource {
    
    /**
     * GET /api/v1/games/{gameId}/rounds/{roundNumber}/bids
     * Obtener todas las apuestas de una ronda
     */
    @GET
    public Response getAllBids(
            @PathParam("gameId") Long gameId,
            @PathParam("roundNumber") int roundNumber) {
        
        Game game = GameResource.getGamesMap().get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        List<Round> rounds = game.getRounds();
        
        if (roundNumber < 1 || roundNumber > rounds.size()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Round not found\"}")
                    .build();
        }
        
        Round round = rounds.get(roundNumber - 1);
        List<Bid> bids = round.getBids();
        
        return Response.ok(bids).build();
    }
    
    /**
     * POST /api/v1/games/{gameId}/rounds/{roundNumber}/bids
     * Hacer una apuesta
     */
    @POST
    public Response makeBid(
            @PathParam("gameId") Long gameId,
            @PathParam("roundNumber") int roundNumber,
            Map<String, Object> bidRequest,
            @Context UriInfo uriInfo) {
        
        Game game = GameResource.getGamesMap().get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        // Verificar que el juego está activo
        if (!game.getStatus().equals("active")) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Game is not active\"}")
                    .build();
        }
        
        List<Round> rounds = game.getRounds();
        
        if (roundNumber < 1 || roundNumber > rounds.size()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Round not found\"}")
                    .build();
        }
        
        Round round = rounds.get(roundNumber - 1);
        
        // Verificar que la ronda está en fase de apuestas
        if (!round.getStatus().equals("bidding")) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Round is not in bidding phase\"}")
                    .build();
        }
        
        Long playerId = ((Number) bidRequest.get("player_id")).longValue();
        Integer bidValue = (Integer) bidRequest.get("bid_value");
        
        // Validaciones
        if (!game.getPlayerIds().contains(playerId)) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Player is not in this game\"}")
                    .build();
        }
        
        if (bidValue < 0 || bidValue > round.getCardsPerPlayer()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Invalid bid value\"}")
                    .build();
        }
        
        // Verificar si el jugador ya apostó
        boolean alreadyBid = round.getBids().stream()
                .anyMatch(b -> b.getPlayerId().equals(playerId));
        
        if (alreadyBid) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Player has already bid\"}")
                    .build();
        }
        
        // Validar regla de Oh Hell (suma de apuestas != número de cartas)
        if (!round.isValidBid(bidValue, game.getPlayerIds().size())) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Invalid bid - total bids cannot equal cards per player (Oh Hell rule)\"}")
                    .build();
        }
        
        // Crear y añadir apuesta
        Bid bid = new Bid(playerId, bidValue);
        round.addBid(bid);
        
        // Si todos han apostado, cambiar fase a "playing"
        if (round.getBids().size() == game.getPlayerIds().size()) {
            round.setStatus("playing");
            round.startNewTrick();  // Iniciar primera baza
        }
        
        return Response.status(Response.Status.CREATED)
                .entity(bid)
                .build();
    }
}
BID_EOF

echo "✅ BidResource.java creado"

# ==================== TRICK RESOURCE ====================
cat > "$RESOURCES_DIR/TrickResource.java" << 'TRICK_EOF'
package com.ohhell.ohhellapi.resources;

import com.ohhell.ohhellapi.models.*;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import java.util.List;
import java.util.Map;

@Path("v1/games/{gameId}/rounds/{roundNumber}")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TrickResource {
    
    /**
     * GET /api/v1/games/{gameId}/rounds/{roundNumber}/current-trick
     * Obtener el estado actual de la baza
     */
    @GET
    @Path("current-trick")
    public Response getCurrentTrick(
            @PathParam("gameId") Long gameId,
            @PathParam("roundNumber") int roundNumber) {
        
        Game game = GameResource.getGamesMap().get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        List<Round> rounds = game.getRounds();
        
        if (roundNumber < 1 || roundNumber > rounds.size()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Round not found\"}")
                    .build();
        }
        
        Round round = rounds.get(roundNumber - 1);
        Trick currentTrick = round.getCurrentTrickObject();
        
        if (currentTrick == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"No active trick\"}")
                    .build();
        }
        
        return Response.ok(currentTrick).build();
    }
    
    /**
     * POST /api/v1/games/{gameId}/rounds/{roundNumber}/play
     * Jugar una carta
     */
    @POST
    @Path("play")
    public Response playCard(
            @PathParam("gameId") Long gameId,
            @PathParam("roundNumber") int roundNumber,
            Map<String, Object> playRequest) {
        
        Game game = GameResource.getGamesMap().get(gameId);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        List<Round> rounds = game.getRounds();
        
        if (roundNumber < 1 || roundNumber > rounds.size()) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Round not found\"}")
                    .build();
        }
        
        Round round = rounds.get(roundNumber - 1);
        
        // Verificar que la ronda está en fase de juego
        if (!round.getStatus().equals("playing")) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Round is not in playing phase\"}")
                    .build();
        }
        
        Long playerId = ((Number) playRequest.get("player_id")).longValue();
        Map<String, String> cardData = (Map<String, String>) playRequest.get("card");
        
        String suit = cardData.get("suit");
        String rank = cardData.get("rank");
        
        // Validaciones básicas
        if (!game.getPlayerIds().contains(playerId)) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Player is not in this game\"}")
                    .build();
        }
        
        Card card = new Card(suit, rank);
        Trick currentTrick = round.getCurrentTrickObject();
        
        if (currentTrick == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"No active trick\"}")
                    .build();
        }
        
        // Jugar la carta
        currentTrick.playCard(playerId, card);
        
        // Verificar si la baza está completa
        if (currentTrick.isComplete(game.getPlayerIds().size())) {
            // Determinar ganador
            Long winnerId = currentTrick.determineWinner(round.getTrumpSuit());
            
            // Actualizar contador de bazas ganadas
            for (Bid bid : round.getBids()) {
                if (bid.getPlayerId().equals(winnerId)) {
                    bid.incrementTricksWon();
                    break;
                }
            }
            
            // Si hay más bazas por jugar, iniciar la siguiente
            if (round.getCurrentTrick() < round.getCardsPerPlayer()) {
                round.startNewTrick();
            } else {
                // Ronda terminada, calcular scores
                round.calculateScores();
                
                // Actualizar vidas y puntos
                for (Bid bid : round.getBids()) {
                    int score = round.getScores().getOrDefault(bid.getPlayerId(), 0);
                    game.addScore(bid.getPlayerId(), score);
                    
                    // Si falló la apuesta, pierde una vida
                    if (!bid.isBidMet()) {
                        game.updatePlayerLives(bid.getPlayerId(), -1);
                    }
                }
                
                // Verificar si el juego debe terminar
                game.checkGameEnd();
                
                // Si el juego no ha terminado, iniciar siguiente ronda
                if (!game.getStatus().equals("finished") && 
                    game.getCurrentRound() < game.getMaxRounds()) {
                    game.startNewRound();
                }
            }
        }
        
        return Response.ok()
                .entity("{\"message\": \"Card played successfully\", \"trick_winner\": " + 
                        (currentTrick.getWinnerId() != null ? currentTrick.getWinnerId() : "null") + "}")
                .build();
    }
}
TRICK_EOF

echo "✅ TrickResource.java creado"

echo ""
echo "🎉 ¡Todos los Resources REST han sido creados exitosamente!"
echo ""
echo "Resources creados:"
echo "  - PlayerResource.java (5 endpoints)"
echo "  - GameResource.java (5 endpoints)"
echo "  - RoundResource.java (2 endpoints)"
echo "  - BidResource.java (2 endpoints)"
echo "  - TrickResource.java (2 endpoints)"
echo ""
echo "Total: 16 endpoints REST"
echo ""
echo "Ubicación: $RESOURCES_DIR"
