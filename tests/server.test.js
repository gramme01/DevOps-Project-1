const request = require("supertest");
const app = require("../server");

describe("Server API Tests", () => {
  test("GET / should return welcome message", async () => {
    const response = await request(app).get("/");
    expect(response.status).toBe(200);
    expect(response.body).toEqual({ message: "Hello DevOps Assessment!" });
  });

  test("GET /health should return health status", async () => {
    const response = await request(app).get("/health");
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("status", "healthy");
    expect(response.body).toHaveProperty("service", "node-app");
    expect(response.body).toHaveProperty("timestamp");
  });

  test("GET /api/version should return API version", async () => {
    const response = await request(app).get("/api/version");
    expect(response.status).toBe(200);
    expect(response.body).toEqual({
      version: "1.0.0",
      description: "DevOps Assessment Node.js API",
    });
  });

  test("GET /nonexistent should return 404", async () => {
    const response = await request(app).get("/nonexistent");
    expect(response.status).toBe(404);
    expect(response.body).toHaveProperty("error", "Route not found");
  });

  test("Server should handle CORS", async () => {
    const response = await request(app)
      .get("/health")
      .set("Origin", "http://example.com");

    expect(response.headers["access-control-allow-origin"]).toBe("*");
  });
});
