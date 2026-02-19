import http from "node:http";
import express from "express";
import cors from "cors";
import { Server } from "socket.io";

const PORT = Number(process.env.PORT ?? 3000);
const CORS_ORIGIN = process.env.CORS_ORIGIN ?? "*";

const app = express();
app.disable("x-powered-by");

app.use(cors({ origin: CORS_ORIGIN === "*" ? true : CORS_ORIGIN }));
app.use(express.json({ limit: "200kb" }));

// Healthcheck (obligatoire Render)
app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "api", ts: new Date().toISOString() });
});

const server = http.createServer(app);

// Socket.IO (temps réel)
const io = new Server(server, {
  cors: { origin: CORS_ORIGIN === "*" ? true : CORS_ORIGIN }
});

io.on("connection", (socket) => {
  socket.emit("room:system", { message: "connected", ts: Date.now() });
});

server.listen(PORT, () => {
  console.log(`[api] listening on :${PORT}`);
});
