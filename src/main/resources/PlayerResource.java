package com.ohhell.ohhellapi.resources;

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

@Path("v1/players")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PlayerResource {
    
    // Simulación de base de datos en memoria (temporal)
    private static final Map<Long, Player> players = new ConcurrentHashMap<>();
    private static final AtomicLong idGenerator = new AtomicLong(1);
    
    // GET /api/v1/players - Obtener todos los jugadores
    @GET
    public Response getAllPlayers(
            @QueryParam("limit") @DefaultValue("10") int limit,
            @QueryParam("offset") @DefaultValue("0") int offset) {
        
        List<Player> allPlayers = new ArrayList<>(players.values());
        
        // Paginación
        int start = Math.min(offset, allPlayers.size());
        int end = Math.min(offset + limit, allPlayers.size());
        List<Player> paginatedPlayers = allPlayers.subList(start, end);
        
        return Response.ok(paginatedPlayers).build();
    }
    
    // GET /api/v1/players/{id} - Obtener un jugador específico
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
    
    // POST /api/v1/players - Crear un nuevo jugador
    @POST
    public Response createPlayer(Player player) {
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
        Long newId = idGenerator.getAndIncrement();
        player.setPlayerId(newId);
        players.put(newId, player);
        
        // Retornar 201 Created con Location header
        URI location = URI.create("/api/v1/players/" + newId);
        return Response.created(location).entity(player).build();
    }
    
    // PUT /api/v1/players/{id} - Actualizar un jugador
    @PUT
    @Path("{id}")
    public Response updatePlayer(@PathParam("id") Long id, Player updatedPlayer) {
        Player existingPlayer = players.get(id);
        
        if (existingPlayer == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Player not found\"}")
                    .build();
        }
        
        // Validaciones
        if (updatedPlayer.getUsername() == null || updatedPlayer.getUsername().trim().isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Username is required\"}")
                    .build();
        }
        
        // Actualizar campos
        existingPlayer.setUsername(updatedPlayer.getUsername());
        existingPlayer.setEmail(updatedPlayer.getEmail());
        
        if (updatedPlayer.getPassword() != null) {
            existingPlayer.setPassword(updatedPlayer.getPassword());
        }
        
        return Response.ok(existingPlayer).build();
    }
    
    // DELETE /api/v1/players/{id} - Eliminar un jugador
    @DELETE
    @Path("{id}")
    public Response deletePlayer(@PathParam("id") Long id) {
        Player player = players.remove(id);
        
        if (player == null) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"Player not found\"}")
                    .build();
        }
        
        return Response.noContent().build();
    }
    
    // POST /api/v1/players/login - Login (simplificado)
    @POST
    @Path("login")
    public Response login(Map<String, String> credentials) {
        String username = credentials.get("username");
        String password = credentials.get("password");
        
        if (username == null || password == null) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Username and password are required\"}")
                    .build();
        }
        
        // Buscar jugador
        Player player = players.values().stream()
                .filter(p -> p.getUsername().equals(username) && 
                           p.getPassword().equals(password))
                .findFirst()
                .orElse(null);
        
        if (player == null) {
            return Response.status(Response.Status.UNAUTHORIZED)
                    .entity("{\"error\": \"Invalid credentials\"}")
                    .build();
        }
        
        // En producción, aquí generarías un token JWT
        return Response.ok(player).build();
    }
}
