package com.acme.crud;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.json.Json;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Path("fruits")
@ApplicationScoped
@Produces("application/json")
@Consumes("application/json")
public class FruitResource {

    @PersistenceContext
    EntityManager entityManager;

    @GET
    @Path("greeting")
    @Produces({"text/plain"})
    public String greeting(@QueryParam("name") String name) {
        //System.out.println("FR " + (new SimpleDateFormat("HH:mm:ss.SSS")).format(new Date(System.currentTimeMillis())));
        String suffix = (name != null) ? name : "World";
        return String.format("Hello, %s!", new Object[] { suffix });
    }

    @GET
    public Fruit[] get() {
        return entityManager.createNamedQuery("Fruits.findAll", Fruit.class)
              .getResultList().toArray(new Fruit[0]);
    }

    @GET
    @Path("{id}")
    public Fruit getSingle(@PathParam("id") Integer id) {
        Fruit entity = entityManager.find(Fruit.class, id);
        if (entity == null) {
            throw new WebApplicationException("Fruit with id of " + id + " does not exist.", 404);
        }
        return entity;
    }

    @POST
    @Transactional
    public Response create(Fruit fruit) {
        if (fruit.getId() != null) {
            throw new WebApplicationException("Id was invalidly set on request.", 422);
        }

        entityManager.persist(fruit);
        return Response.ok(fruit).status(201).build();
    }

    @PUT
    @Path("{id}")
    @Transactional
    public Fruit update(@PathParam("id") Integer id, Fruit fruit) {
        if (fruit.getName() == null) {
            throw new WebApplicationException("Fruit Name was not set on request.", 422);
        }

        Fruit entity = entityManager.find(Fruit.class, id);

        if (entity == null) {
            throw new WebApplicationException("Fruit with id of " + id + " does not exist.", 404);
        }

        entity.setName(fruit.getName());

        return entity;
    }

    @DELETE
    @Path("{id}")
    @Transactional
    public Response delete(@PathParam("id") Integer id) {
        Fruit entity = entityManager.getReference(Fruit.class, id);
        if (entity == null) {
            throw new WebApplicationException("Fruit with id of " + id + " does not exist.", 404);
        }
        entityManager.remove(entity);
        return Response.status(204).build();
    }
    
    @Provider
    public static class ErrorMapper implements ExceptionMapper<Exception> {

        @Override
        public Response toResponse(Exception exception) {
            int code = 500;
            if (exception instanceof WebApplicationException) {
                code = ((WebApplicationException) exception).getResponse().getStatus();
            }
            //System.out.println("***JTD: ErrorMapper.toResponse " + exception);
            exception.printStackTrace();
            return Response.status(code)
                    .entity(Json.createObjectBuilder().add("error", (exception.getMessage() == null ? exception.toString() : exception.getMessage()) ).add("code", code).build())
                    .build();
        }

    }
}
