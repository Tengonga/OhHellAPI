package com.ohhell.ohhellapi.resources;

import com.ohhell.ohhellapi.models.Game;
import com.ohhell.ohhellapi.models.Player;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.net.URI;
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
    
    // Simulación de base de datos en memoria
    private static final Map<Long, Game> games = new ConcurrentHashMap<>();
    private static final AtomicLong idGenerator = new AtomicLong(1);
    
    // GET /api/v1/games - Obtener todas las partidas
    @GET
    public Response getAllGames(
            @QueryParam("status") String status,
            @QueryParam("limit") @DefaultValue("10") int limit,
            @QueryParam("offset") @DefaultValue("0") int offset) {
        
        List<Game> allGames = new ArrayList<>(games.values());
        
        // Filtrar por estado si se proporciona
        if (status != null && !status.isEmpty()) {
            allGames = allGames.stream()
                    .filter(game -> game.getStatus().equals(status))
                    .collect(Collectors.toList());
        }
        
        // Paginación
        int start = Math.min(offset, allGames.size());
        int end = Math.min(offset + limit, allGames.size());
        List<Game> paginatedGames = allGames.subList(start, end);
        
        return Response.ok(paginatedGames).build();
    }
    
    // GET /api/v1/games/{id} - Obtener una partida específica
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
    
    // POST /api/v1/games - Crear una nueva partida
    @POST
    public Response createGame(Map<String, Object> gameConfig) {
        try {
            // Extraer configuración
            int maxPlayers = (int) gameConfig.getOrDefault("max_players", 4);
            int initialLives = (int) gameConfig.getOrDefault("initial_lives", 5);
            int maxRounds = (int) gameConfig.getOrDefault("max_rounds", 10);
            long createdBy = ((Number) gameConfig.get("created_by_player_id")).longValue();
            
            // Validaciones
            if (maxPlayers < 2 || maxPlayers > 6) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\": \"max_players must be between 2 and 6\"}")
                        .build();
            }
            
            if (initialLives < 1 || initialLives > 10) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\": \"initial_lives must be between 1 and 10\"}")
                        .build();
            }
            
            // Crear partida
            Game game = new Game(maxPlayers, initialLives, maxRounds, createdBy);
            Long newId = idGenerator.getAndIncrement();
            game.setGameId(newId);
            
            // El creador se une automáticamente
            game.addPlayer(createdBy);
            
            games.put(newId, game);
            
            URI location = URI.create("/api/v1/games/" + newId);
            return Response.created(location).entity(game).build();
            
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Invalid game configuration: " + e.getMessage() + "\"}")
                    .build();
        }
    }
    
    // POST /api/v1/games/{id}/join - Unirse a una partida
    @POST
    @Path("{id}/join")
    public Response joinGame(@PathParam("id") Long id, Map<String, Long> body) {
        Game game = games.get(id);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        Long playerId = body.get("player_id");
        if (playerId == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"player_id is required\"}")
                    .build();
        }
        
        // Intentar unirse
        boolean success = game.addPlayer(playerId);
        
        if (!success) {
            String message = game.getStatus().equals("waiting") 
                    ? "Game is full" 
                    : "Game already started";
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"" + message + "\"}")
                    .build();
        }
        
        return Response.ok(game).build();
    }
    
    // POST /api/v1/games/{id}/start - Iniciar una partida
    @POST
    @Path("{id}/start")
    public Response startGame(@PathParam("id") Long id) {
        Game game = games.get(id);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        boolean success = game.startGame();
        
        if (!success) {
            String message = game.getPlayerIds().size() < 2
                    ? "Need at least 2 players to start"
                    : "Game already started";
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"" + message + "\"}")
                    .build();
        }
        
        return Response.ok(game).build();
    }
    
    // GET /api/v1/games/{id}/players - Obtener jugadores de una partida
    @GET
    @Path("{id}/players")
    public Response getGamePlayers(@PathParam("id") Long id) {
        Game game = games.get(id);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        // Retornar información de jugadores
        Map<String, Object> playersInfo = new ConcurrentHashMap<>();
        playersInfo.put("player_ids", game.getPlayerIds());
        playersInfo.put("scores", game.getPlayerScores());
        playersInfo.put("lives", game.getPlayerLives());
        playersInfo.put("total_players", game.getPlayerIds().size());
        playersInfo.put("max_players", game.getMaxPlayers());
        
        return Response.ok(playersInfo).build();
    }
    
    // GET /api/v1/games/{id}/status - Obtener estado de la partida
    @GET
    @Path("{id}/status")
    public Response getGameStatus(@PathParam("id") Long id) {
        Game game = games.get(id);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        Map<String, Object> status = new ConcurrentHashMap<>();
        status.put("game_id", game.getGameId());
        status.put("status", game.getStatus());
        status.put("current_round", game.getCurrentRound());
        status.put("max_rounds", game.getMaxRounds());
        status.put("total_players", game.getPlayerIds().size());
        
        if (game.getStatus().equals("finished")) {
            status.put("winner_id", game.getWinner());
        }
        
        return Response.ok(status).build();
    }
    
    // DELETE /api/v1/games/{id} - Eliminar una partida
    @DELETE
    @Path("{id}")
    public Response deleteGame(@PathParam("id") Long id) {
        Game game = games.remove(id);
        
        if (game == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Game not found\"}")
                    .build();
        }
        
        return Response.noContent().build();
    }
}
